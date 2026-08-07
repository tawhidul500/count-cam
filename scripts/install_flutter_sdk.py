from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
from typing import Any
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
PROJECT_ENV = ROOT / 'tool/project.env'
OFFICIAL_STORAGE_BASE = 'https://storage.googleapis.com'
OFFICIAL_RELEASE_BASE = f'{OFFICIAL_STORAGE_BASE}/flutter_infra_release/releases'
CHUNK_SIZE = 1024 * 1024


class InstallerError(RuntimeError):
    pass


def parse_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise InstallerError(f'Malformed environment line: {raw_line}')
        key, value = line.split('=', 1)
        values[key.strip()] = value.strip()
    return values


def normalise_platform(value: str | None = None) -> str:
    raw = value or platform.system()
    mapping = {
        'Linux': 'linux',
        'linux': 'linux',
        'Darwin': 'macos',
        'darwin': 'macos',
        'macOS': 'macos',
        'macos': 'macos',
    }
    try:
        return mapping[raw]
    except KeyError as error:
        raise InstallerError(
            f'Unsupported platform: {raw}. Install the pinned Flutter SDK manually.'
        ) from error


def normalise_architecture(value: str | None = None) -> str:
    raw = (value or platform.machine()).lower()
    mapping = {
        'x86_64': 'x64',
        'amd64': 'x64',
        'x64': 'x64',
        'arm64': 'arm64',
        'aarch64': 'arm64',
    }
    try:
        return mapping[raw]
    except KeyError as error:
        raise InstallerError(
            f'Unsupported architecture: {raw}. Install the pinned Flutter SDK manually.'
        ) from error


def manifest_url(storage_base: str, target_platform: str) -> str:
    return (
        f'{storage_base.rstrip("/")}/flutter_infra_release/releases/'
        f'releases_{target_platform}.json'
    )


def load_json_from_url(url: str) -> dict[str, Any]:
    request = Request(url, headers={'User-Agent': 'ClearScan-Toolchain-Installer/1.0'})
    try:
        with urlopen(request, timeout=60) as response:  # noqa: S310 - HTTPS URL is controlled.
            payload = response.read()
    except OSError as error:
        raise InstallerError(f'Unable to download Flutter release manifest: {error}') from error

    try:
        value = json.loads(payload.decode('utf-8'))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise InstallerError('Flutter release manifest is not valid UTF-8 JSON.') from error

    if not isinstance(value, dict):
        raise InstallerError('Flutter release manifest root must be a JSON object.')
    return value


def load_manifest(path: Path | None, url: str) -> dict[str, Any]:
    if path is None:
        return load_json_from_url(url)

    try:
        value = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise InstallerError(f'Unable to read manifest fixture {path}: {error}') from error
    if not isinstance(value, dict):
        raise InstallerError('Flutter release manifest root must be a JSON object.')
    return value


def resolve_release(
    manifest: dict[str, Any],
    *,
    version: str,
    channel: str,
    architecture: str,
    expected_hash: str,
) -> dict[str, str]:
    base_url = manifest.get('base_url')
    releases = manifest.get('releases')
    if base_url != OFFICIAL_RELEASE_BASE:
        raise InstallerError(
            'Manifest base_url must match Flutter\'s official release storage.'
        )
    if not isinstance(releases, list):
        raise InstallerError('Manifest releases field must be a list.')

    matches: list[dict[str, Any]] = []
    for item in releases:
        if not isinstance(item, dict):
            continue
        if item.get('version') != version or item.get('channel') != channel:
            continue
        item_arch = item.get('dart_sdk_arch', 'x64')
        if item_arch != architecture:
            continue
        matches.append(item)

    if len(matches) != 1:
        raise InstallerError(
            'Expected exactly one Flutter release for '
            f'{version} {channel} {architecture}; found {len(matches)}.'
        )

    release = matches[0]
    required_fields = ('hash', 'archive', 'sha256', 'dart_sdk_version', 'release_date')
    for field in required_fields:
        if not isinstance(release.get(field), str) or not release[field]:
            raise InstallerError(f'Flutter release entry is missing {field}.')

    if release['hash'] != expected_hash:
        raise InstallerError(
            f'Flutter release hash mismatch: expected {expected_hash}, '
            f'found {release["hash"]}.'
        )

    archive_url = f'{base_url.rstrip("/")}/{release["archive"].lstrip("/")}'
    if not archive_url.startswith('https://'):
        raise InstallerError('Resolved Flutter archive URL must use HTTPS.')

    return {
        'version': version,
        'channel': channel,
        'architecture': architecture,
        'hash': release['hash'],
        'dart_sdk_version': release['dart_sdk_version'],
        'release_date': release['release_date'],
        'archive': release['archive'],
        'archive_url': archive_url,
        'sha256': release['sha256'].lower(),
    }


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        while chunk := handle.read(CHUNK_SIZE):
            digest.update(chunk)
    return digest.hexdigest()


def download_file(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = Request(url, headers={'User-Agent': 'ClearScan-Toolchain-Installer/1.0'})
    temporary = destination.with_suffix(destination.suffix + '.part')

    try:
        with urlopen(request, timeout=120) as response:  # noqa: S310 - HTTPS URL is controlled.
            with temporary.open('wb') as output:
                shutil.copyfileobj(response, output, length=CHUNK_SIZE)
        temporary.replace(destination)
    except OSError as error:
        temporary.unlink(missing_ok=True)
        raise InstallerError(f'Unable to download Flutter SDK archive: {error}') from error


def verify_archive(path: Path, expected_sha256: str) -> None:
    actual = sha256_file(path)
    if actual != expected_sha256:
        raise InstallerError(
            'Flutter SDK archive checksum mismatch.\n'
            f'Expected: {expected_sha256}\n'
            f'Actual:   {actual}'
        )


def extract_archive(archive: Path, install_parent: Path) -> None:
    install_parent.mkdir(parents=True, exist_ok=True)
    install_dir = install_parent / 'flutter'
    if install_dir.exists():
        shutil.rmtree(install_dir)

    archive_name = archive.name.lower()
    if archive_name.endswith(('.tar.xz', '.tar.gz', '.tgz')):
        command = ['tar', '-xf', str(archive), '-C', str(install_parent)]
    elif archive_name.endswith('.zip'):
        command = ['unzip', '-q', str(archive), '-d', str(install_parent)]
    else:
        raise InstallerError(f'Unsupported Flutter archive format: {archive.name}')

    tool = command[0]
    if shutil.which(tool) is None:
        raise InstallerError(f'Required archive extraction tool is missing: {tool}')

    result = subprocess.run(command, check=False)
    if result.returncode != 0:
        raise InstallerError(f'Flutter archive extraction failed with exit code {result.returncode}.')

    flutter_binary = install_dir / 'bin' / ('flutter.bat' if os.name == 'nt' else 'flutter')
    if not flutter_binary.is_file():
        raise InstallerError(f'Flutter extraction did not create {flutter_binary}.')


def verify_installed_version(flutter_binary: Path, expected_version: str) -> None:
    try:
        result = subprocess.run(
            [str(flutter_binary), '--version', '--machine'],
            check=False,
            capture_output=True,
            text=True,
            timeout=180,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        raise InstallerError(f'Unable to execute installed Flutter SDK: {error}') from error

    if result.returncode != 0:
        raise InstallerError(
            'Installed Flutter SDK did not report its version successfully.\n'
            + result.stderr.strip()
        )

    try:
        metadata = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise InstallerError('Flutter --version --machine returned invalid JSON.') from error

    actual_version = metadata.get('frameworkVersion')
    if actual_version != expected_version:
        raise InstallerError(
            f'Installed Flutter version mismatch: expected {expected_version}, '
            f'found {actual_version!r}.'
        )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Install ClearScan\'s pinned Flutter SDK from the official release manifest.'
    )
    parser.add_argument(
        '--install-parent',
        type=Path,
        default=ROOT / '.tooling',
        help='Directory that will contain flutter/ and downloads/.',
    )
    parser.add_argument(
        '--manifest-file',
        type=Path,
        help='Use a local release manifest fixture instead of downloading one.',
    )
    parser.add_argument(
        '--archive-file',
        type=Path,
        help='Use an existing Flutter archive instead of downloading it.',
    )
    parser.add_argument('--platform', dest='target_platform', help='Override platform for tests.')
    parser.add_argument('--architecture', help='Override architecture for tests.')
    parser.add_argument(
        '--resolve-only',
        action='store_true',
        help='Resolve and print release metadata without downloading or installing.',
    )
    return parser


def main() -> int:
    try:
        config = parse_env_file(PROJECT_ENV)
        version = config['CLEARSCAN_FLUTTER_VERSION']
        channel = config['CLEARSCAN_FLUTTER_CHANNEL']
        expected_hash = config['CLEARSCAN_FLUTTER_RELEASE_HASH']
        expected_dart_version = config['CLEARSCAN_DART_VERSION']
    except (OSError, KeyError, InstallerError) as error:
        print(f'Configuration error: {error}', file=sys.stderr)
        return 1

    args = build_parser().parse_args()

    try:
        target_platform = normalise_platform(args.target_platform)
        architecture = normalise_architecture(args.architecture)
        url = manifest_url(OFFICIAL_STORAGE_BASE, target_platform)
        manifest = load_manifest(args.manifest_file, url)
        release = resolve_release(
            manifest,
            version=version,
            channel=channel,
            architecture=architecture,
            expected_hash=expected_hash,
        )

        if release['dart_sdk_version'] != expected_dart_version:
            raise InstallerError(
                'Pinned Dart version does not match the official Flutter release manifest: '
                f'expected {expected_dart_version}, found {release["dart_sdk_version"]}.'
            )

        configured_sha = config.get(
            f'CLEARSCAN_FLUTTER_ARCHIVE_SHA256_{target_platform.upper()}_{architecture.upper()}'
        )
        if configured_sha and configured_sha.lower() != release['sha256']:
            raise InstallerError(
                'Configured Flutter archive checksum does not match the official manifest.'
            )

        print(json.dumps(release, indent=2, sort_keys=True))
        if args.resolve_only:
            return 0

        install_parent = args.install_parent.expanduser().resolve()
        downloads = install_parent / 'downloads'
        archive_name = Path(release['archive']).name
        archive_path = downloads / archive_name

        if args.archive_file is not None:
            archive_path = args.archive_file.expanduser().resolve()
            if not archive_path.is_file():
                raise InstallerError(f'Provided archive file does not exist: {archive_path}')
        elif archive_path.is_file():
            try:
                verify_archive(archive_path, release['sha256'])
                print(f'Using verified cached archive: {archive_path}')
            except InstallerError:
                archive_path.unlink(missing_ok=True)
                print('Cached archive failed verification and was removed.', file=sys.stderr)
                download_file(release['archive_url'], archive_path)
        else:
            print(f'Downloading Flutter {version} from {release["archive_url"]}')
            download_file(release['archive_url'], archive_path)

        verify_archive(archive_path, release['sha256'])
        print(f'Archive checksum verified: {release["sha256"]}')
        extract_archive(archive_path, install_parent)

        flutter_binary = install_parent / 'flutter' / 'bin' / 'flutter'
        subprocess.run(
            [str(flutter_binary), 'config', '--no-analytics'],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        verify_installed_version(flutter_binary, version)

        print('\nFlutter installed successfully.')
        print(f'Add this directory to PATH: {flutter_binary.parent}')
        return 0
    except InstallerError as error:
        print(str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
