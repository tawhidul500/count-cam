from __future__ import annotations

import base64
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERIFY = ROOT / 'scripts/verify_phase0_launch_evidence.py'
WRITE_MANIFEST = ROOT / 'scripts/write_artifact_manifest.py'
WRITE_REPORT = ROOT / 'scripts/write_phase0_launch_report.py'
ENV_PATH = ROOT / 'tool/project.env'

# Valid 1x1 PNG. Extra bytes are appended so the verifier also exercises its
# minimum-size guard without depending on Pillow or any external package.
PNG_BYTES = base64.b64decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl2nT8AAAAASUVORK5CYII='
) + b'clearscan-phase0-launch-evidence'


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def write_manifest(root: Path) -> None:
    result = run(str(WRITE_MANIFEST), '--root', str(root), '--output', str(root / 'ARTIFACT_MANIFEST.json'))
    assert result.returncode == 0, result.stderr


def write_report(root: Path, platform: str, identifier: str) -> None:
    artifact = root / ('clearscan-debug.apk' if platform == 'android' else 'clearscan-ios-simulator.zip')
    screenshot = root / ('android-launch.png' if platform == 'android' else 'ios-launch.png')
    result = run(
        str(WRITE_REPORT),
        '--platform', platform,
        '--identifier', identifier,
        '--artifact', str(artifact),
        '--screenshot', str(screenshot),
        '--target-name', 'Synthetic Device',
        '--os-version', '1.0',
        '--output', str(root / 'launch-report.json'),
    )
    assert result.returncode == 0, result.stderr


def make_android(root: Path) -> None:
    (root / 'android-launch.log').write_text(
        'application_id=com.clearscan.clearscan\nStatus: ok\n', encoding='utf-8'
    )
    (root / 'android-device.txt').write_text(
        'model=Synthetic Android\nandroid_release=1\n', encoding='utf-8'
    )
    (root / 'android-activity.txt').write_text(
        'mResumedActivity: com.clearscan.clearscan/.MainActivity\n', encoding='utf-8'
    )
    (root / 'android-launch.png').write_bytes(PNG_BYTES)
    with zipfile.ZipFile(root / 'clearscan-debug.apk', 'w') as archive:
        archive.writestr('AndroidManifest.xml', b'manifest')
        archive.writestr('classes.dex', b'dex\n035\x00synthetic')
    write_report(root, 'android', 'com.clearscan.clearscan')
    write_manifest(root)


def make_ios(root: Path) -> None:
    (root / 'ios-launch.log').write_text(
        'bundle_id=com.clearscan.clearscan\ncom.clearscan.clearscan: 12345\n', encoding='utf-8'
    )
    (root / 'ios-simulator.txt').write_text(
        'name=Synthetic iPhone\nruntime=iOS-1-0\nstate=Booted\n', encoding='utf-8'
    )
    (root / 'ios-app-container.txt').write_text(
        '/tmp/Containers/Bundle/Application/SYNTH/Runner.app\n', encoding='utf-8'
    )
    (root / 'ios-launch.png').write_bytes(PNG_BYTES)
    with zipfile.ZipFile(root / 'clearscan-ios-simulator.zip', 'w') as archive:
        archive.writestr('Runner.app/Info.plist', b'plist')
        archive.writestr('Runner.app/Runner', b'mach-o')
    write_report(root, 'ios', 'com.clearscan.clearscan')
    write_manifest(root)


def verify(root: Path, platform: str) -> subprocess.CompletedProcess[str]:
    return run(str(VERIFY), '--root', str(root), '--platform', platform)


def main() -> int:
    with tempfile.TemporaryDirectory(prefix='clearscan-launch-evidence-') as tmp:
        base = Path(tmp)

        android = base / 'android'
        android.mkdir()
        make_android(android)
        result = verify(android, 'android')
        assert result.returncode == 0, result.stderr

        ios = base / 'ios'
        ios.mkdir()
        make_ios(ios)
        result = verify(ios, 'ios')
        assert result.returncode == 0, result.stderr

        tampered = base / 'tampered'
        shutil.copytree(android, tampered)
        with (tampered / 'android-launch.png').open('ab') as handle:
            handle.write(b'tamper')
        result = verify(tampered, 'android')
        assert result.returncode != 0
        assert 'Size mismatch' in result.stderr or 'SHA-256 mismatch' in result.stderr

        wrong_identifier = base / 'wrong-identifier'
        shutil.copytree(ios, wrong_identifier)
        report_path = wrong_identifier / 'launch-report.json'
        report = json.loads(report_path.read_text(encoding='utf-8'))
        report['app_identifier'] = 'com.example.wrong'
        report_path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        write_manifest(wrong_identifier)
        result = verify(wrong_identifier, 'ios')
        assert result.returncode != 0
        assert 'identifier mismatch' in result.stderr

    print('Phase 0 launch evidence verifier contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
