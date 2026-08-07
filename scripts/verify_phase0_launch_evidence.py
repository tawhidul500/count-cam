from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys

from verify_phase0_evidence import (
    ENV_PATH,
    EvidenceError,
    parse_env,
    read_manifest,
    require_files,
    sha256_file,
    verify_android_archive,
    verify_ios_archive,
    verify_manifest,
)

PNG_SIGNATURE = b'\x89PNG\r\n\x1a\n'
SHA256_PATTERN = re.compile(r'^[0-9a-f]{64}$')


class LaunchEvidenceError(RuntimeError):
    pass


def read_launch_report(path: Path) -> dict[str, object]:
    try:
        payload = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise LaunchEvidenceError(f'Unable to read launch report: {error}') from error
    if payload.get('schema_version') != 1:
        raise LaunchEvidenceError('Unsupported launch report schema.')
    return payload


def verify_png(path: Path) -> None:
    if path.stat().st_size < len(PNG_SIGNATURE) + 32:
        raise LaunchEvidenceError(f'Launch screenshot is unexpectedly small: {path.name}')
    with path.open('rb') as handle:
        signature = handle.read(len(PNG_SIGNATURE))
    if signature != PNG_SIGNATURE:
        raise LaunchEvidenceError(f'Launch screenshot is not a PNG: {path.name}')


def require_non_empty_string(payload: dict[str, object], key: str) -> str:
    value = payload.get(key)
    if not isinstance(value, str) or not value.strip():
        raise LaunchEvidenceError(f'Launch report field {key!r} must be a non-empty string.')
    return value.strip()


def verify_report(root: Path, platform: str, env: dict[str, str]) -> None:
    report = read_launch_report(root / 'launch-report.json')
    if report.get('platform') != platform:
        raise LaunchEvidenceError('Launch report platform mismatch.')
    if report.get('launched') is not True:
        raise LaunchEvidenceError('Launch report does not record a successful launch.')

    expected_identifier = (
        env['CLEARSCAN_ANDROID_APPLICATION_ID']
        if platform == 'android'
        else env['CLEARSCAN_IOS_BUNDLE_ID']
    )
    if report.get('app_identifier') != expected_identifier:
        raise LaunchEvidenceError('Launch report application identifier mismatch.')

    require_non_empty_string(report, 'target_name')
    require_non_empty_string(report, 'os_version')

    expected_artifact = 'clearscan-debug.apk' if platform == 'android' else 'clearscan-ios-simulator.zip'
    expected_screenshot = 'android-launch.png' if platform == 'android' else 'ios-launch.png'
    if report.get('artifact_file') != expected_artifact:
        raise LaunchEvidenceError('Launch report artifact filename mismatch.')
    if report.get('screenshot_file') != expected_screenshot:
        raise LaunchEvidenceError('Launch report screenshot filename mismatch.')

    artifact_digest = require_non_empty_string(report, 'artifact_sha256').lower()
    screenshot_digest = require_non_empty_string(report, 'screenshot_sha256').lower()
    if not SHA256_PATTERN.fullmatch(artifact_digest):
        raise LaunchEvidenceError('Launch report artifact SHA-256 is invalid.')
    if not SHA256_PATTERN.fullmatch(screenshot_digest):
        raise LaunchEvidenceError('Launch report screenshot SHA-256 is invalid.')
    if sha256_file(root / expected_artifact) != artifact_digest:
        raise LaunchEvidenceError('Launch artifact SHA-256 does not match launch report.')
    if sha256_file(root / expected_screenshot) != screenshot_digest:
        raise LaunchEvidenceError('Launch screenshot SHA-256 does not match launch report.')


def verify_launch_evidence(root: Path, platform: str, env_path: Path = ENV_PATH) -> None:
    root = root.expanduser().resolve()
    if not root.is_dir():
        raise LaunchEvidenceError(f'Launch evidence root is not a directory: {root}')

    env = parse_env(env_path)
    if platform == 'android':
        required = (
            'android-launch.log',
            'android-device.txt',
            'android-activity.txt',
            'android-launch.png',
            'clearscan-debug.apk',
            'launch-report.json',
        )
        identifier = env['CLEARSCAN_ANDROID_APPLICATION_ID']
    elif platform == 'ios':
        required = (
            'ios-launch.log',
            'ios-simulator.txt',
            'ios-app-container.txt',
            'ios-launch.png',
            'clearscan-ios-simulator.zip',
            'launch-report.json',
        )
        identifier = env['CLEARSCAN_IOS_BUNDLE_ID']
    else:
        raise LaunchEvidenceError(f'Unsupported launch-evidence platform: {platform}')

    require_files(root, required)
    payload = read_manifest(root)
    verify_manifest(root, payload)
    verify_report(root, platform, env)

    screenshot = root / ('android-launch.png' if platform == 'android' else 'ios-launch.png')
    verify_png(screenshot)

    if platform == 'android':
        verify_android_archive(root / 'clearscan-debug.apk')
        activity = (root / 'android-activity.txt').read_text(encoding='utf-8', errors='replace')
        launch_log = (root / 'android-launch.log').read_text(encoding='utf-8', errors='replace')
        if identifier not in activity:
            raise LaunchEvidenceError('Android activity evidence does not contain the application ID.')
        if identifier not in launch_log:
            raise LaunchEvidenceError('Android launch log does not contain the application ID.')
    else:
        verify_ios_archive(root / 'clearscan-ios-simulator.zip')
        container = (root / 'ios-app-container.txt').read_text(encoding='utf-8', errors='replace')
        launch_log = (root / 'ios-launch.log').read_text(encoding='utf-8', errors='replace')
        if 'Runner.app' not in container:
            raise LaunchEvidenceError('iOS app-container evidence does not reference Runner.app.')
        if identifier not in launch_log:
            raise LaunchEvidenceError('iOS launch log does not contain the bundle ID.')


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Verify ClearScan Phase 0 Android/iOS launch evidence integrity.'
    )
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--platform', choices=('android', 'ios'), required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        verify_launch_evidence(args.root, args.platform)
    except (OSError, EvidenceError, LaunchEvidenceError) as error:
        print(str(error), file=sys.stderr)
        return 1

    print(f'Phase 0 {args.platform} launch evidence verification: PASS ({args.root.resolve()})')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
