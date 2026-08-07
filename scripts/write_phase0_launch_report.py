from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import sys

CHUNK_SIZE = 1024 * 1024
SHA256_PATTERN = re.compile(r'^[0-9a-f]{64}$')


class LaunchReportError(RuntimeError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        while chunk := handle.read(CHUNK_SIZE):
            digest.update(chunk)
    return digest.hexdigest()


def require_file(path: Path, label: str) -> Path:
    resolved = path.expanduser().resolve()
    if not resolved.is_file():
        raise LaunchReportError(f'Missing {label}: {resolved}')
    return resolved


def write_report(
    *,
    platform: str,
    identifier: str,
    artifact: Path,
    screenshot: Path,
    target_name: str,
    os_version: str,
    output: Path,
) -> dict[str, object]:
    if platform not in {'android', 'ios'}:
        raise LaunchReportError(f'Unsupported platform: {platform}')
    identifier = identifier.strip()
    target_name = target_name.strip()
    os_version = os_version.strip()
    if not identifier:
        raise LaunchReportError('Application identifier is required.')
    if not target_name:
        raise LaunchReportError('Target name is required.')
    if not os_version:
        raise LaunchReportError('OS version is required.')

    artifact = require_file(artifact, 'launch artifact')
    screenshot = require_file(screenshot, 'launch screenshot')
    output = output.expanduser().resolve()

    payload: dict[str, object] = {
        'schema_version': 1,
        'generated_at_utc': datetime.now(timezone.utc).isoformat(),
        'platform': platform,
        'app_identifier': identifier,
        'launched': True,
        'target_name': target_name,
        'os_version': os_version,
        'artifact_file': artifact.name,
        'artifact_sha256': sha256_file(artifact),
        'screenshot_file': screenshot.name,
        'screenshot_sha256': sha256_file(screenshot),
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    return payload


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Write a machine-readable ClearScan Phase 0 launch report.'
    )
    parser.add_argument('--platform', choices=('android', 'ios'), required=True)
    parser.add_argument('--identifier', required=True)
    parser.add_argument('--artifact', type=Path, required=True)
    parser.add_argument('--screenshot', type=Path, required=True)
    parser.add_argument('--target-name', required=True)
    parser.add_argument('--os-version', required=True)
    parser.add_argument('--output', type=Path, required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        payload = write_report(
            platform=args.platform,
            identifier=args.identifier,
            artifact=args.artifact,
            screenshot=args.screenshot,
            target_name=args.target_name,
            os_version=args.os_version,
            output=args.output,
        )
    except (OSError, LaunchReportError) as error:
        print(str(error), file=sys.stderr)
        return 1

    digest = payload['screenshot_sha256']
    assert isinstance(digest, str) and SHA256_PATTERN.fullmatch(digest)
    print(f'Phase 0 {args.platform} launch report written: {args.output.resolve()}')
    print(f'Launch screenshot SHA-256: {digest}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
