from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/run_phase0_github_gate.sh'


def main() -> int:
    text = SCRIPT.read_text(encoding='utf-8')
    required = (
        'gh auth status',
        'gh workflow run',
        'gh run watch',
        '--exit-status',
        'gh run download',
        'verify_phase0_downloaded_run.py',
        'record_phase0_hosted_run.py',
        'git status --porcelain',
        'gh api "repos/$REPO/commits/$HEAD_SHA"',
    )
    for token in required:
        assert token in text, f'Missing GitHub gate execution contract token: {token}'
    forbidden = ('GITHUB_TOKEN=', 'GH_TOKEN=', '--token')
    for token in forbidden:
        assert token not in text, f'Execution script must not accept/embed tokens: {token}'
    print('Phase 0 GitHub dispatch/collect contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
