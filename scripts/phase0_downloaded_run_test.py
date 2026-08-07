from __future__ import annotations

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from phase0_evidence_test import make_android as make_android_build
from phase0_evidence_test import make_ios as make_ios_build
from phase0_launch_evidence_test import make_android as make_android_launch
from phase0_launch_evidence_test import make_ios as make_ios_launch
from write_artifact_manifest import sha256_file, write_manifest
from write_phase0_gate_summary import render_summary

ROOT = Path(__file__).resolve().parents[1]
VERIFY = ROOT / 'scripts/verify_phase0_downloaded_run.py'
RECORD = ROOT / 'scripts/record_phase0_hosted_run.py'
COMMIT_SHA = '1' * 40


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def build_download(root: Path) -> None:
    android_artifact = root / 'clearscan-android-phase0'
    android_build = android_artifact / 'phase0_evidence'
    android_launch = android_artifact / 'phase0_launch' / 'android'
    android_build.mkdir(parents=True)
    android_launch.mkdir(parents=True)
    make_android_build(android_build)
    write_manifest(android_build, android_build / 'ARTIFACT_MANIFEST.json')
    make_android_launch(android_launch)

    ios_artifact = root / 'clearscan-ios-phase0'
    ios_build = ios_artifact / 'phase0_evidence'
    ios_launch = ios_artifact / 'phase0_launch' / 'ios'
    ios_build.mkdir(parents=True)
    ios_launch.mkdir(parents=True)
    make_ios_build(ios_build)
    write_manifest(ios_build, ios_build / 'ARTIFACT_MANIFEST.json')
    make_ios_launch(ios_launch)

    android_launch_report = json.loads((android_launch / 'launch-report.json').read_text())
    ios_launch_report = json.loads((ios_launch / 'launch-report.json').read_text())

    summary = render_summary(
        source_result='success',
        android_result='success',
        ios_result='success',
        android_verified=True,
        ios_verified=True,
        android_sha256=sha256_file(android_build / 'clearscan-debug.apk'),
        ios_sha256=sha256_file(ios_build / 'clearscan-ios-simulator.zip'),
        android_launch_verified=True,
        ios_launch_verified=True,
        android_launch_sha256=android_launch_report['screenshot_sha256'],
        ios_launch_sha256=ios_launch_report['screenshot_sha256'],
        repository='example/clearscan',
        run_id='12345',
        run_url='https://github.com/example/clearscan/actions/runs/12345',
        commit_sha=COMMIT_SHA,
        git_ref='refs/heads/main',
    )
    summary_dir = root / 'clearscan-phase0-summary'
    summary_dir.mkdir()
    (summary_dir / 'P00_T03_HOSTED_GATE_SUMMARY.md').write_text(summary, encoding='utf-8')


def main() -> int:
    with tempfile.TemporaryDirectory(prefix='clearscan-downloaded-run-') as tmp:
        base = Path(tmp)
        download = base / 'download'
        download.mkdir()
        build_download(download)

        record_json = base / 'run.json'
        record_md = base / 'run.md'
        result = run(
            str(VERIFY),
            '--root', str(download),
            '--json-output', str(record_json),
            '--markdown-output', str(record_md),
        )
        assert result.returncode == 0, result.stderr
        payload = json.loads(record_json.read_text())
        assert payload['evidence_ready'] is True
        assert payload['commit_sha'] == COMMIT_SHA
        assert payload['run_id'] == '12345'
        assert 'All four downloaded evidence bundles passed' in record_md.read_text()

        evidence_doc = base / 'PHASE0_EVIDENCE.md'
        evidence_doc.write_text(
            '# Evidence\n\n## Required records after the first successful hosted run\n\n- Workflow run URL:\n',
            encoding='utf-8',
        )
        result = run(
            str(RECORD),
            '--record-json', str(record_json),
            '--evidence-doc', str(evidence_doc),
        )
        assert result.returncode == 0, result.stderr
        first = evidence_doc.read_text()
        assert '<!-- P00-T03-VERIFIED-HOSTED-RUN-START -->' in first
        assert COMMIT_SHA in first
        result = run(
            str(RECORD),
            '--record-json', str(record_json),
            '--evidence-doc', str(evidence_doc),
        )
        assert result.returncode == 0, result.stderr
        second = evidence_doc.read_text()
        assert second.count('<!-- P00-T03-VERIFIED-HOSTED-RUN-START -->') == 1

        tampered = base / 'tampered'
        shutil.copytree(download, tampered)
        summary_path = tampered / 'clearscan-phase0-summary' / 'P00_T03_HOSTED_GATE_SUMMARY.md'
        summary_text = summary_path.read_text()
        summary_path.write_text(summary_text.replace(COMMIT_SHA, '2' * 39), encoding='utf-8')
        result = run(str(VERIFY), '--root', str(tampered))
        assert result.returncode != 0
        assert 'commit SHA' in result.stderr or 'missing metadata' in result.stderr

    print('Phase 0 downloaded hosted-run verification/recording contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
