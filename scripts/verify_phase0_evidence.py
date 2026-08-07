from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / 'tool/project.env'
MANIFEST_NAME = 'ARTIFACT_MANIFEST.json'
CHUNK_SIZE = 1024 * 1024


class EvidenceError(RuntimeError):
    pass


def parse_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise EvidenceError(f'Malformed environment line: {raw_line}')
        key, value = line.split('=', 1)
        values[key.strip()] = value.strip()
    return values


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        while chunk := handle.read(CHUNK_SIZE):
            digest.update(chunk)
    return digest.hexdigest()


def read_manifest(root: Path) -> dict[str, object]:
    path = root / MANIFEST_NAME
    if not path.is_file():
        raise EvidenceError(f'Missing evidence manifest: {path}')
    try:
        payload = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise EvidenceError(f'Unable to read evidence manifest: {error}') from error
    if payload.get('schema_version') != 1:
        raise EvidenceError('Unsupported evidence manifest schema.')
    if not isinstance(payload.get('files'), list):
        raise EvidenceError('Evidence manifest files field must be a list.')
    return payload


def verify_manifest(root: Path, payload: dict[str, object]) -> None:
    files = payload['files']
    assert isinstance(files, list)
    manifest_records: dict[str, dict[str, object]] = {}

    for raw_record in files:
        if not isinstance(raw_record, dict):
            raise EvidenceError('Evidence manifest contains a non-object file record.')
        relative = raw_record.get('path')
        size = raw_record.get('size_bytes')
        digest = raw_record.get('sha256')
        if not isinstance(relative, str) or not relative or relative.startswith('/'):
            raise EvidenceError(f'Invalid manifest path: {relative!r}')
        if relative in manifest_records:
            raise EvidenceError(f'Duplicate manifest path: {relative}')
        if not isinstance(size, int) or size < 0:
            raise EvidenceError(f'Invalid size for {relative}: {size!r}')
        if not isinstance(digest, str) or not re.fullmatch(r'[0-9a-f]{64}', digest):
            raise EvidenceError(f'Invalid SHA-256 for {relative}.')
        manifest_records[relative] = raw_record

    actual_files: set[str] = set()
    for path in root.rglob('*'):
        if path.is_symlink():
            raise EvidenceError(f'Evidence directory contains a symlink: {path}')
        if not path.is_file() or path.name == MANIFEST_NAME:
            continue
        actual_files.add(path.relative_to(root).as_posix())

    manifest_files = set(manifest_records)
    missing = sorted(manifest_files - actual_files)
    unlisted = sorted(actual_files - manifest_files)
    if missing:
        raise EvidenceError('Manifest references missing files: ' + ', '.join(missing))
    if unlisted:
        raise EvidenceError('Evidence contains unlisted files: ' + ', '.join(unlisted))

    declared_count = payload.get('file_count')
    if declared_count != len(manifest_records):
        raise EvidenceError(
            f'Manifest file_count is {declared_count!r}; expected {len(manifest_records)}.'
        )

    for relative, record in manifest_records.items():
        path = root / relative
        actual_size = path.stat().st_size
        if actual_size != record['size_bytes']:
            raise EvidenceError(
                f'Size mismatch for {relative}: expected {record["size_bytes"]}, '
                f'found {actual_size}.'
            )
        actual_digest = sha256_file(path)
        if actual_digest != record['sha256']:
            raise EvidenceError(f'SHA-256 mismatch for {relative}.')


def require_files(root: Path, names: tuple[str, ...]) -> None:
    missing = [name for name in names if not (root / name).is_file()]
    if missing:
        raise EvidenceError('Missing required evidence files: ' + ', '.join(missing))


def verify_toolchain(root: Path, env: dict[str, str]) -> None:
    flutter_path = root / 'flutter-version.json'
    try:
        flutter_info = json.loads(flutter_path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise EvidenceError(f'Unable to parse {flutter_path.name}: {error}') from error

    expected_flutter = env.get('CLEARSCAN_FLUTTER_VERSION', '')
    expected_dart = env.get('CLEARSCAN_DART_VERSION', '')
    actual_flutter = str(flutter_info.get('frameworkVersion', '')).strip()
    actual_dart = str(flutter_info.get('dartSdkVersion', '')).strip()
    if actual_flutter != expected_flutter:
        raise EvidenceError(
            f'Flutter evidence mismatch: expected {expected_flutter}, found {actual_flutter or "unknown"}.'
        )
    if not actual_dart.startswith(expected_dart):
        raise EvidenceError(
            f'Flutter bundled Dart mismatch: expected {expected_dart}, found {actual_dart or "unknown"}.'
        )

    dart_text = (root / 'dart-version.txt').read_text(encoding='utf-8', errors='replace')
    if f'Dart SDK version: {expected_dart}' not in dart_text:
        raise EvidenceError(
            f'dart-version.txt does not prove pinned Dart {expected_dart}.'
        )


def verify_platform_report(root: Path, platform: str, env: dict[str, str]) -> None:
    report_name = f'{platform}-platform-report.json'
    try:
        report = json.loads((root / report_name).read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise EvidenceError(f'Unable to parse {report_name}: {error}') from error

    if report.get('passed') is not True:
        raise EvidenceError(f'{report_name} is not marked passed.')
    if report.get('android_runner_present') is not True:
        raise EvidenceError(f'{report_name} does not prove an Android runner.')
    if report.get('ios_runner_present') is not True:
        raise EvidenceError(f'{report_name} does not prove an iOS runner.')
    if report.get('android_application_id') != env.get('CLEARSCAN_ANDROID_APPLICATION_ID'):
        raise EvidenceError(f'{report_name} Android application ID does not match project.env.')
    if report.get('ios_bundle_id') != env.get('CLEARSCAN_IOS_BUNDLE_ID'):
        raise EvidenceError(f'{report_name} iOS bundle ID does not match project.env.')


def verify_android_archive(path: Path) -> None:
    if not zipfile.is_zipfile(path):
        raise EvidenceError(f'Android artifact is not a valid APK/ZIP archive: {path.name}')
    with zipfile.ZipFile(path) as archive:
        names = set(archive.namelist())
    for required in ('AndroidManifest.xml', 'classes.dex'):
        if required not in names:
            raise EvidenceError(f'Android APK is missing {required}.')


def verify_ios_archive(path: Path) -> None:
    if not zipfile.is_zipfile(path):
        raise EvidenceError(f'iOS simulator artifact is not a valid ZIP archive: {path.name}')
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
    if not any(name.endswith('Runner.app/Info.plist') for name in names):
        raise EvidenceError('iOS simulator archive does not contain Runner.app/Info.plist.')
    if not any(name.endswith('Runner.app/Runner') for name in names):
        raise EvidenceError('iOS simulator archive does not contain the Runner executable.')


def verify_evidence(root: Path, platform: str, env_path: Path = ENV_PATH) -> None:
    root = root.expanduser().resolve()
    if not root.is_dir():
        raise EvidenceError(f'Evidence root is not a directory: {root}')

    env = parse_env(env_path)
    common = (
        'flutter-install.log',
        'flutter-version.json',
        'dart-version.txt',
        'flutter-doctor.log',
        'bootstrap-platforms.log',
        f'{platform}-platform-report.json',
    )
    if platform == 'android':
        required = common + ('android-build.log', 'clearscan-debug.apk')
    elif platform == 'ios':
        required = common + ('ios-build.log', 'clearscan-ios-simulator.zip')
    else:
        raise EvidenceError(f'Unsupported evidence platform: {platform}')

    require_files(root, required)
    payload = read_manifest(root)
    verify_manifest(root, payload)
    verify_toolchain(root, env)
    verify_platform_report(root, platform, env)

    if platform == 'android':
        verify_android_archive(root / 'clearscan-debug.apk')
    else:
        verify_ios_archive(root / 'clearscan-ios-simulator.zip')


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Verify completeness and integrity of ClearScan Phase 0 CI evidence.'
    )
    parser.add_argument('--root', type=Path, required=True, help='Evidence directory to verify.')
    parser.add_argument('--platform', choices=('android', 'ios'), required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        verify_evidence(args.root, args.platform)
    except (OSError, EvidenceError) as error:
        print(str(error), file=sys.stderr)
        return 1

    print(f'Phase 0 {args.platform} evidence verification: PASS ({args.root.resolve()})')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
