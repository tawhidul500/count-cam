from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / 'tool/project.env'


def parse_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise ValueError(f'Malformed environment line: {raw_line}')
        key, value = line.split('=', 1)
        values[key.strip()] = value.strip()
    return values


def read_existing(paths: list[Path]) -> str:
    return '\n'.join(
        path.read_text(encoding='utf-8', errors='replace')
        for path in paths
        if path.is_file()
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Verify generated ClearScan Android and iOS runner identifiers.'
    )
    parser.add_argument(
        '--json-output',
        type=Path,
        help='Optional path for a machine-readable verification report.',
    )
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []

    if not ENV_PATH.is_file():
        print(f'Missing project environment file: {ENV_PATH}', file=sys.stderr)
        return 1

    try:
        env = parse_env(ENV_PATH)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 1

    android_id = env.get('CLEARSCAN_ANDROID_APPLICATION_ID', '')
    ios_id = env.get('CLEARSCAN_IOS_BUNDLE_ID', '')

    android_dir = ROOT / 'android'
    ios_dir = ROOT / 'ios'

    if not android_dir.is_dir():
        errors.append('Android runner directory is missing: android/')
    if not ios_dir.is_dir():
        errors.append('iOS runner directory is missing: ios/')

    android_files = [
        android_dir / 'app/build.gradle',
        android_dir / 'app/build.gradle.kts',
        android_dir / 'app/src/main/AndroidManifest.xml',
    ]
    android_text = read_existing(android_files)
    if android_dir.is_dir() and not android_text:
        errors.append('No supported Android identifier files were found.')
    elif android_text:
        application_id_patterns = (
            rf'applicationId\s+["\']{re.escape(android_id)}["\']',
            rf'applicationId\s*=\s*["\']{re.escape(android_id)}["\']',
        )
        namespace_patterns = (
            rf'namespace\s+["\']{re.escape(android_id)}["\']',
            rf'namespace\s*=\s*["\']{re.escape(android_id)}["\']',
        )
        if not any(re.search(pattern, android_text) for pattern in application_id_patterns):
            errors.append(
                f'Android applicationId {android_id!r} was not found in the generated app config.'
            )
        if not any(re.search(pattern, android_text) for pattern in namespace_patterns):
            warnings.append(
                f'Android namespace {android_id!r} was not found; review the generated template.'
            )

    ios_project = ios_dir / 'Runner.xcodeproj/project.pbxproj'
    ios_plist = ios_dir / 'Runner/Info.plist'
    ios_text = read_existing([ios_project, ios_plist])
    if ios_dir.is_dir() and not ios_text:
        errors.append('No supported iOS identifier files were found.')
    elif ios_text:
        bundle_pattern = rf'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*{re.escape(ios_id)};'
        if not re.search(bundle_pattern, ios_text):
            errors.append(
                f'iOS bundle identifier {ios_id!r} was not found in Runner.xcodeproj.'
            )
        if '$(PRODUCT_BUNDLE_IDENTIFIER)' not in ios_text:
            warnings.append(
                'Runner/Info.plist does not appear to reference PRODUCT_BUNDLE_IDENTIFIER.'
            )

    report = {
        'project': env.get('CLEARSCAN_PROJECT_NAME', 'clearscan'),
        'android_application_id': android_id,
        'ios_bundle_id': ios_id,
        'android_runner_present': android_dir.is_dir(),
        'ios_runner_present': ios_dir.is_dir(),
        'errors': errors,
        'warnings': warnings,
        'passed': not errors,
    }

    if args.json_output:
        output_path = args.json_output
        if not output_path.is_absolute():
            output_path = ROOT / output_path
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(
            json.dumps(report, indent=2, sort_keys=True) + '\n',
            encoding='utf-8',
        )

    for warning in warnings:
        print(f'WARNING: {warning}')

    if errors:
        for error in errors:
            print(f'ERROR: {error}', file=sys.stderr)
        return 1

    print('Generated platform verification passed.')
    print(f'Android application ID: {android_id}')
    print(f'iOS bundle ID: {ios_id}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
