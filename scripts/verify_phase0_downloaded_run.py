from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys

from verify_phase0_evidence import sha256_file, verify_evidence
from verify_phase0_launch_evidence import read_launch_report, verify_launch_evidence

SUMMARY_NAME = 'P00_T03_HOSTED_GATE_SUMMARY.md'
SHA256_PATTERN = re.compile(r'^[0-9a-f]{64}$')
COMMIT_SHA_PATTERN = re.compile(r'^[0-9a-f]{40}$')


class DownloadedRunError(RuntimeError):
    pass


def find_unique(root: Path, name: str) -> Path:
    matches = [path for path in root.rglob(name) if path.is_file()]
    if len(matches) != 1:
        raise DownloadedRunError(
            f'Expected exactly one {name!r} under {root}, found {len(matches)}.'
        )
    return matches[0]


def parent_with(root: Path, filename: str) -> Path:
    return find_unique(root, filename).parent


def parse_summary_metadata(text: str) -> dict[str, str]:
    patterns = {
        'repository': r'^- Repository: `([^`]+)`$',
        'run_id': r'^- Workflow run ID: `([^`]+)`$',
        'run_url': r'^- Workflow run: (\S+)$',
        'commit_sha': r'^- Commit SHA: `([0-9a-fA-F]+)`$',
        'git_ref': r'^- Git ref: `([^`]+)`$',
    }
    metadata: dict[str, str] = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, text, flags=re.MULTILINE)
        if match:
            metadata[key] = match.group(1).strip()
    required = ('repository', 'run_id', 'run_url', 'commit_sha', 'git_ref')
    missing = [key for key in required if not metadata.get(key)]
    if missing:
        raise DownloadedRunError(
            'Hosted gate summary is missing metadata: ' + ', '.join(missing)
        )
    metadata['commit_sha'] = metadata['commit_sha'].lower()
    if not COMMIT_SHA_PATTERN.fullmatch(metadata['commit_sha']):
        raise DownloadedRunError('Hosted gate summary commit SHA is invalid.')
    if not metadata['run_id'].isdigit():
        raise DownloadedRunError('Hosted gate summary workflow run ID is invalid.')
    expected_suffix = f"/actions/runs/{metadata['run_id']}"
    if not metadata['run_url'].rstrip('/').endswith(expected_suffix):
        raise DownloadedRunError('Hosted gate summary workflow URL/run ID mismatch.')
    return metadata


def require_summary_ready(text: str) -> None:
    required_lines = (
        '**Verified hosted build evidence ready:** YES',
        '**Verified hosted launch evidence ready:** YES',
        '**P00-T03 gate-closing evidence ready:** YES',
        '| Source quality | PASS |',
    )
    for line in required_lines:
        if line not in text:
            raise DownloadedRunError(f'Hosted gate summary is not gate-ready: missing {line!r}.')


def require_digest(value: object, label: str) -> str:
    if not isinstance(value, str):
        raise DownloadedRunError(f'{label} digest is missing from launch report.')
    digest = value.lower().strip()
    if not SHA256_PATTERN.fullmatch(digest):
        raise DownloadedRunError(f'{label} digest is invalid.')
    return digest


def build_record(root: Path) -> dict[str, object]:
    root = root.expanduser().resolve()
    if not root.is_dir():
        raise DownloadedRunError(f'Downloaded artifact root is not a directory: {root}')

    summary_path = find_unique(root, SUMMARY_NAME)
    summary_text = summary_path.read_text(encoding='utf-8')
    require_summary_ready(summary_text)
    metadata = parse_summary_metadata(summary_text)

    # The APK exists in build evidence and launch evidence. Pick the build directory
    # by the toolchain record instead of relying on artifact extraction depth.
    build_candidates = [
        path.parent for path in root.rglob('flutter-version.json')
        if (path.parent / 'clearscan-debug.apk').is_file()
    ]
    if len(build_candidates) != 1:
        raise DownloadedRunError(
            f'Expected one Android build evidence directory, found {len(build_candidates)}.'
        )
    android_build = build_candidates[0]

    ios_build_candidates = [
        path.parent for path in root.rglob('flutter-version.json')
        if (path.parent / 'clearscan-ios-simulator.zip').is_file()
    ]
    if len(ios_build_candidates) != 1:
        raise DownloadedRunError(
            f'Expected one iOS build evidence directory, found {len(ios_build_candidates)}.'
        )
    ios_build = ios_build_candidates[0]

    android_launch_candidates = [
        path.parent for path in root.rglob('android-launch.png')
        if (path.parent / 'launch-report.json').is_file()
    ]
    ios_launch_candidates = [
        path.parent for path in root.rglob('ios-launch.png')
        if (path.parent / 'launch-report.json').is_file()
    ]
    if len(android_launch_candidates) != 1:
        raise DownloadedRunError(
            f'Expected one Android launch evidence directory, found {len(android_launch_candidates)}.'
        )
    if len(ios_launch_candidates) != 1:
        raise DownloadedRunError(
            f'Expected one iOS launch evidence directory, found {len(ios_launch_candidates)}.'
        )
    android_launch = android_launch_candidates[0]
    ios_launch = ios_launch_candidates[0]

    verify_evidence(android_build, 'android')
    verify_evidence(ios_build, 'ios')
    verify_launch_evidence(android_launch, 'android')
    verify_launch_evidence(ios_launch, 'ios')

    android_report = read_launch_report(android_launch / 'launch-report.json')
    ios_report = read_launch_report(ios_launch / 'launch-report.json')

    android_apk_sha = sha256_file(android_build / 'clearscan-debug.apk')
    ios_archive_sha = sha256_file(ios_build / 'clearscan-ios-simulator.zip')
    android_launch_sha = require_digest(
        android_report.get('screenshot_sha256'), 'Android launch screenshot'
    )
    ios_launch_sha = require_digest(
        ios_report.get('screenshot_sha256'), 'iOS launch screenshot'
    )

    expected_digests = (
        android_apk_sha,
        ios_archive_sha,
        android_launch_sha,
        ios_launch_sha,
    )
    for digest in expected_digests:
        if digest not in summary_text:
            raise DownloadedRunError(
                f'Hosted gate summary does not contain verified digest {digest}.'
            )

    return {
        'schema_version': 1,
        'evidence_ready': True,
        **metadata,
        'summary_file': str(summary_path.relative_to(root)),
        'android': {
            'artifact_sha256': android_apk_sha,
            'launch_screenshot_sha256': android_launch_sha,
            'target_name': android_report['target_name'],
            'os_version': android_report['os_version'],
            'app_identifier': android_report['app_identifier'],
        },
        'ios': {
            'artifact_sha256': ios_archive_sha,
            'launch_screenshot_sha256': ios_launch_sha,
            'target_name': ios_report['target_name'],
            'os_version': ios_report['os_version'],
            'app_identifier': ios_report['app_identifier'],
        },
    }


def render_markdown(record: dict[str, object]) -> str:
    android = record['android']
    ios = record['ios']
    assert isinstance(android, dict) and isinstance(ios, dict)
    return '\n'.join(
        [
            '# ClearScan P00-T03 Verified Hosted Run Record',
            '',
            f"- Workflow run: {record['run_url']}",
            f"- Workflow run ID: `{record['run_id']}`",
            f"- Repository: `{record['repository']}`",
            f"- Commit SHA: `{record['commit_sha']}`",
            f"- Git ref: `{record['git_ref']}`",
            '- Gate state: `P00-T03 gate-closing evidence ready: YES`',
            '',
            '## Android',
            '',
            f"- Target: {android['target_name']} / Android {android['os_version']}",
            f"- APK SHA-256: `{android['artifact_sha256']}`",
            f"- Launch screenshot SHA-256: `{android['launch_screenshot_sha256']}`",
            '',
            '## iOS',
            '',
            f"- Target: {ios['target_name']} / {ios['os_version']}",
            f"- Simulator archive SHA-256: `{ios['artifact_sha256']}`",
            f"- Launch screenshot SHA-256: `{ios['launch_screenshot_sha256']}`",
            '',
            'All four downloaded evidence bundles passed the repository verifiers.',
            '',
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Verify artifacts downloaded from a successful ClearScan P00-T03 hosted run.'
    )
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--json-output', type=Path)
    parser.add_argument('--markdown-output', type=Path)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        record = build_record(args.root)
    except (OSError, DownloadedRunError, RuntimeError) as error:
        print(str(error), file=sys.stderr)
        return 1

    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(
            json.dumps(record, indent=2, sort_keys=True) + '\n', encoding='utf-8'
        )
    if args.markdown_output:
        args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
        args.markdown_output.write_text(render_markdown(record), encoding='utf-8')

    print(
        'Downloaded P00-T03 hosted run verification: PASS '
        f"(run {record['run_id']}, commit {record['commit_sha']})"
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
