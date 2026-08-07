from __future__ import annotations

from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/write_phase0_gate_summary.py'
ANDROID_SHA = 'a' * 64
IOS_SHA = 'b' * 64
ANDROID_LAUNCH_SHA = 'c' * 64
IOS_LAUNCH_SHA = 'd' * 64
COMMIT_SHA = 'e' * 40


def run(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def full_args(output: Path) -> list[str]:
    return [
        '--source-result', 'success',
        '--android-result', 'success',
        '--ios-result', 'success',
        '--android-verified', 'true',
        '--ios-verified', 'true',
        '--android-sha256', ANDROID_SHA,
        '--ios-sha256', IOS_SHA,
        '--android-launch-verified', 'true',
        '--ios-launch-verified', 'true',
        '--android-launch-sha256', ANDROID_LAUNCH_SHA,
        '--ios-launch-sha256', IOS_LAUNCH_SHA,
        '--repository', 'example/clearscan',
        '--run-id', '12345',
        '--run-url', 'https://github.com/example/clearscan/actions/runs/12345',
        '--commit-sha', COMMIT_SHA,
        '--git-ref', 'refs/heads/main',
        '--output', str(output),
    ]


def main() -> int:
    with tempfile.TemporaryDirectory(prefix='clearscan-phase0-summary-') as tmp:
        tmp_path = Path(tmp)

        passed = tmp_path / 'passed.md'
        result = run(full_args(passed))
        assert result.returncode == 0, result.stderr
        text = passed.read_text(encoding='utf-8')
        assert '**Verified hosted build evidence ready:** YES' in text
        assert '**Verified hosted launch evidence ready:** YES' in text
        assert '**P00-T03 gate-closing evidence ready:** YES' in text
        assert ANDROID_SHA in text and IOS_SHA in text
        assert ANDROID_LAUNCH_SHA in text and IOS_LAUNCH_SHA in text
        assert 'Record the run URL' in text
        assert f'- Commit SHA: `{COMMIT_SHA}`' in text
        assert '- Git ref: `refs/heads/main`' in text

        launch_missing = tmp_path / 'launch-missing.md'
        args = full_args(launch_missing)
        args[args.index('--android-launch-verified') + 1] = 'false'
        args[args.index('--android-launch-sha256') + 1] = ''
        result = run(args)
        assert result.returncode == 0, result.stderr
        launch_text = launch_missing.read_text(encoding='utf-8')
        assert '**Verified hosted build evidence ready:** YES' in launch_text
        assert '**Verified hosted launch evidence ready:** NO' in launch_text
        assert '**P00-T03 gate-closing evidence ready:** NO' in launch_text
        assert 'Do not close P00-T03.' in launch_text

        partial = tmp_path / 'partial.md'
        result = run(
            [
                '--source-result', 'success',
                '--android-result', 'failure',
                '--ios-result', 'skipped',
                '--output', str(partial),
            ]
        )
        assert result.returncode == 0, result.stderr
        partial_text = partial.read_text(encoding='utf-8')
        assert '**Verified hosted build evidence ready:** NO' in partial_text
        assert '**P00-T03 gate-closing evidence ready:** NO' in partial_text
        assert 'Do not close P00-T03.' in partial_text

        invalid = tmp_path / 'invalid.md'
        args = full_args(invalid)
        args[args.index('--android-launch-sha256') + 1] = ''
        result = run(args)
        assert result.returncode != 0
        assert 'Missing Android launch screenshot SHA-256' in result.stderr

        invalid_commit = tmp_path / 'invalid-commit.md'
        args = full_args(invalid_commit)
        args[args.index('--commit-sha') + 1] = 'not-a-commit'
        result = run(args)
        assert result.returncode != 0
        assert 'Invalid commit SHA' in result.stderr

    print('Phase 0 hosted gate summary contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
