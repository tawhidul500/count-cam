from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

VALID_RESULTS = {'success', 'failure', 'cancelled', 'skipped'}
SHA256_PATTERN = re.compile(r'^[0-9a-f]{64}$')
COMMIT_SHA_PATTERN = re.compile(r'^[0-9a-f]{40}$')


class SummaryError(RuntimeError):
    pass


def normalise_result(value: str, label: str) -> str:
    result = value.strip().lower()
    if result not in VALID_RESULTS:
        raise SummaryError(f'Unsupported {label} result: {value!r}')
    return result


def normalise_verified(value: str) -> bool:
    return value.strip().lower() == 'true'


def validate_digest(value: str, label: str, *, required: bool) -> str:
    digest = value.strip().lower()
    if not digest:
        if required:
            raise SummaryError(f'Missing {label} SHA-256 for successful verified evidence.')
        return ''
    if not SHA256_PATTERN.fullmatch(digest):
        raise SummaryError(f'Invalid {label} SHA-256: {value!r}')
    return digest


def render_summary(
    *,
    source_result: str,
    android_result: str,
    ios_result: str,
    android_verified: bool,
    ios_verified: bool,
    android_sha256: str,
    ios_sha256: str,
    android_launch_verified: bool,
    ios_launch_verified: bool,
    android_launch_sha256: str,
    ios_launch_sha256: str,
    repository: str = '',
    run_id: str = '',
    run_url: str = '',
    commit_sha: str = '',
    git_ref: str = '',
) -> str:
    source = normalise_result(source_result, 'source-quality')
    android = normalise_result(android_result, 'Android')
    ios = normalise_result(ios_result, 'iOS')

    android_digest = validate_digest(
        android_sha256,
        'Android APK',
        required=android == 'success' and android_verified,
    )
    ios_digest = validate_digest(
        ios_sha256,
        'iOS simulator archive',
        required=ios == 'success' and ios_verified,
    )
    android_launch_digest = validate_digest(
        android_launch_sha256,
        'Android launch screenshot',
        required=android == 'success' and android_launch_verified,
    )
    ios_launch_digest = validate_digest(
        ios_launch_sha256,
        'iOS launch screenshot',
        required=ios == 'success' and ios_launch_verified,
    )

    hosted_builds_ready = (
        source == 'success'
        and android == 'success'
        and ios == 'success'
        and android_verified
        and ios_verified
        and bool(android_digest)
        and bool(ios_digest)
    )
    hosted_launches_ready = (
        android == 'success'
        and ios == 'success'
        and android_launch_verified
        and ios_launch_verified
        and bool(android_launch_digest)
        and bool(ios_launch_digest)
    )
    gate_evidence_ready = hosted_builds_ready and hosted_launches_ready

    commit = commit_sha.strip().lower()
    if commit and not COMMIT_SHA_PATTERN.fullmatch(commit):
        raise SummaryError(f'Invalid commit SHA: {commit_sha!r}')
    ref = git_ref.strip()

    def mark(result: str) -> str:
        return 'PASS' if result == 'success' else result.upper()

    def verifier_mark(value: bool) -> str:
        return 'PASS' if value else 'NOT VERIFIED'

    def digest_cell(value: str) -> str:
        return f'`{value}`' if value else 'unavailable'

    lines = [
        '# ClearScan P00-T03 Hosted Gate Summary',
        '',
    ]
    if repository:
        lines.append(f'- Repository: `{repository}`')
    if run_id:
        lines.append(f'- Workflow run ID: `{run_id}`')
    if run_url:
        lines.append(f'- Workflow run: {run_url}')
    if commit:
        lines.append(f'- Commit SHA: `{commit}`')
    if ref:
        lines.append(f'- Git ref: `{ref}`')
    if repository or run_id or run_url or commit or ref:
        lines.append('')

    lines.extend(
        [
            '| Gate | Job result | Evidence verifier | Artifact/evidence | SHA-256 |',
            '|---|---|---|---|---|',
            f'| Source quality | {mark(source)} | n/a | n/a | n/a |',
            f'| Android debug APK | {mark(android)} | {verifier_mark(android_verified)} | '
            f'`clearscan-android-phase0` | {digest_cell(android_digest)} |',
            f'| Android emulator launch | {mark(android)} | {verifier_mark(android_launch_verified)} | '
            f'`android-launch.png` | {digest_cell(android_launch_digest)} |',
            f'| iOS simulator build | {mark(ios)} | {verifier_mark(ios_verified)} | '
            f'`clearscan-ios-phase0` | {digest_cell(ios_digest)} |',
            f'| iOS simulator launch | {mark(ios)} | {verifier_mark(ios_launch_verified)} | '
            f'`ios-launch.png` | {digest_cell(ios_launch_digest)} |',
            '',
            f'**Verified hosted build evidence ready:** {"YES" if hosted_builds_ready else "NO"}',
            f'**Verified hosted launch evidence ready:** {"YES" if hosted_launches_ready else "NO"}',
            f'**P00-T03 gate-closing evidence ready:** {"YES" if gate_evidence_ready else "NO"}',
            '',
        ]
    )

    if gate_evidence_ready:
        lines.extend(
            [
                'The exact pinned Flutter/Dart source checks, native builds, Android emulator launch, '
                'iOS simulator launch, evidence manifests, and launch-evidence verifiers completed.',
                '',
                'This hosted run provides the automated build-and-launch evidence required by P00-T03. '
                'Record the run URL, artifact checksums, launch screenshot checksums, and any warnings '
                'in `docs/PHASE0_EVIDENCE.md` before changing P00-T03 to DONE.',
            ]
        )
    elif hosted_builds_ready:
        lines.extend(
            [
                'Hosted native builds are verified, but one or both launch-evidence checks are incomplete. '
                'Inspect the launch logs/screenshots and retry. Do not close P00-T03.',
            ]
        )
    else:
        lines.extend(
            [
                'Hosted build evidence is incomplete. Inspect the uploaded partial native evidence and '
                'job logs before retrying. Do not close P00-T03.',
            ]
        )

    lines.append('')
    return '\n'.join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Write a single ClearScan Phase 0 hosted CI gate summary.'
    )
    parser.add_argument('--source-result', required=True)
    parser.add_argument('--android-result', required=True)
    parser.add_argument('--ios-result', required=True)
    parser.add_argument('--android-verified', default='false')
    parser.add_argument('--ios-verified', default='false')
    parser.add_argument('--android-sha256', default='')
    parser.add_argument('--ios-sha256', default='')
    parser.add_argument('--android-launch-verified', default='false')
    parser.add_argument('--ios-launch-verified', default='false')
    parser.add_argument('--android-launch-sha256', default='')
    parser.add_argument('--ios-launch-sha256', default='')
    parser.add_argument('--repository', default='')
    parser.add_argument('--run-id', default='')
    parser.add_argument('--run-url', default='')
    parser.add_argument('--commit-sha', default='')
    parser.add_argument('--git-ref', default='')
    parser.add_argument('--output', type=Path, required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        markdown = render_summary(
            source_result=args.source_result,
            android_result=args.android_result,
            ios_result=args.ios_result,
            android_verified=normalise_verified(args.android_verified),
            ios_verified=normalise_verified(args.ios_verified),
            android_sha256=args.android_sha256,
            ios_sha256=args.ios_sha256,
            android_launch_verified=normalise_verified(args.android_launch_verified),
            ios_launch_verified=normalise_verified(args.ios_launch_verified),
            android_launch_sha256=args.android_launch_sha256,
            ios_launch_sha256=args.ios_launch_sha256,
            repository=args.repository,
            run_id=args.run_id,
            run_url=args.run_url,
            commit_sha=args.commit_sha,
            git_ref=args.git_ref,
        )
    except SummaryError as error:
        print(str(error), file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(markdown, encoding='utf-8')
    print(f'Phase 0 gate summary written: {args.output.resolve()}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
