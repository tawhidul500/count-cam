from __future__ import annotations

import json
from pathlib import Path
import tempfile
import zipfile

from verify_phase0_evidence import EvidenceError, verify_evidence
from write_artifact_manifest import write_manifest


PROJECT_ENV = '''\
CLEARSCAN_PROJECT_NAME=clearscan
CLEARSCAN_ORGANIZATION=com.clearscan
CLEARSCAN_PLATFORMS=android,ios
CLEARSCAN_ANDROID_APPLICATION_ID=com.clearscan.clearscan
CLEARSCAN_IOS_BUNDLE_ID=com.clearscan.clearscan
CLEARSCAN_FLUTTER_CHANNEL=stable
CLEARSCAN_FLUTTER_VERSION=3.44.8
CLEARSCAN_DART_VERSION=3.12.2
CLEARSCAN_FLUTTER_RELEASE_HASH=058e0af2c2b57e369d905a03ac9748b0ebf543c6
CLEARSCAN_FLUTTER_ARCHIVE_SHA256_LINUX_X64=672089e001571a9fbb209a495c583580c0c6c73ef98999264ba07fa93ace332d
'''


def write_common(root: Path, platform: str) -> None:
    (root / 'flutter-install.log').write_text('installed pinned Flutter\n', encoding='utf-8')
    (root / 'flutter-version.json').write_text(
        json.dumps({'frameworkVersion': '3.44.8', 'dartSdkVersion': '3.12.2'}) + '\n',
        encoding='utf-8',
    )
    (root / 'dart-version.txt').write_text(
        'Dart SDK version: 3.12.2 (stable) on "linux_x64"\n', encoding='utf-8'
    )
    (root / 'flutter-doctor.log').write_text('Doctor summary: PASS\n', encoding='utf-8')
    (root / 'bootstrap-platforms.log').write_text('Generated android and ios\n', encoding='utf-8')
    report = {
        'project': 'clearscan',
        'android_application_id': 'com.clearscan.clearscan',
        'ios_bundle_id': 'com.clearscan.clearscan',
        'android_runner_present': True,
        'ios_runner_present': True,
        'errors': [],
        'warnings': [],
        'passed': True,
    }
    (root / f'{platform}-platform-report.json').write_text(
        json.dumps(report) + '\n', encoding='utf-8'
    )


def make_android(root: Path) -> None:
    write_common(root, 'android')
    (root / 'android-build.log').write_text('BUILD SUCCESSFUL\n', encoding='utf-8')
    with zipfile.ZipFile(root / 'clearscan-debug.apk', 'w') as archive:
        archive.writestr('AndroidManifest.xml', b'manifest')
        archive.writestr('classes.dex', b'dex')


def make_ios(root: Path) -> None:
    write_common(root, 'ios')
    (root / 'ios-build.log').write_text('Xcode build done.\n', encoding='utf-8')
    with zipfile.ZipFile(root / 'clearscan-ios-simulator.zip', 'w') as archive:
        archive.writestr('Runner.app/Info.plist', b'plist')
        archive.writestr('Runner.app/Runner', b'executable')


def main() -> int:
    with tempfile.TemporaryDirectory(prefix='clearscan-phase0-evidence-') as temporary:
        base = Path(temporary)
        env_path = base / 'project.env'
        env_path.write_text(PROJECT_ENV, encoding='utf-8')

        android = base / 'android'
        android.mkdir()
        make_android(android)
        write_manifest(android, android / 'ARTIFACT_MANIFEST.json')
        verify_evidence(android, 'android', env_path=env_path)

        ios = base / 'ios'
        ios.mkdir()
        make_ios(ios)
        write_manifest(ios, ios / 'ARTIFACT_MANIFEST.json')
        verify_evidence(ios, 'ios', env_path=env_path)

        (android / 'android-build.log').write_text('tampered\n', encoding='utf-8')
        try:
            verify_evidence(android, 'android', env_path=env_path)
        except EvidenceError:
            pass
        else:
            raise AssertionError('Tampered Phase 0 evidence was not rejected.')

    print('Phase 0 evidence verifier contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
