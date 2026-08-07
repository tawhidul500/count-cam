from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WORKFLOW = ROOT / '.github/workflows/flutter-ci.yml'

EXPECTED_ACTIONS = {
    'actions/checkout': 'de0fac2e4500dabe0009e67214ff5f5447ce83dd',
    'actions/upload-artifact': 'b7c566a772e6b6bfb58ed0dc250532a479d7789f',
}

USE_PATTERN = re.compile(r'^\s*uses:\s*([^\s#]+)', re.MULTILINE)
SHA_PATTERN = re.compile(r'^[0-9a-f]{40}$')


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Verify ClearScan GitHub Actions supply-chain policy.'
    )
    parser.add_argument(
        '--workflow',
        type=Path,
        default=DEFAULT_WORKFLOW,
        help='Workflow file to inspect. Defaults to the ClearScan Flutter workflow.',
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    workflow_path = args.workflow.resolve()
    try:
        text = workflow_path.read_text(encoding='utf-8')
    except OSError as error:
        print(f'Unable to read workflow {workflow_path}: {error}', file=sys.stderr)
        return 1

    errors: list[str] = []

    if 'pull_request_target:' in text:
        errors.append('CI must not use pull_request_target for untrusted pull-request code.')

    if 'permissions:\n  contents: read' not in text:
        errors.append('CI must keep the default token permission at contents: read.')

    uses = USE_PATTERN.findall(text)
    if not uses:
        errors.append('CI workflow contains no action uses entries.')

    counts = {name: 0 for name in EXPECTED_ACTIONS}
    for reference in uses:
        if reference.startswith('./'):
            continue
        if '@' not in reference:
            errors.append(f'Action reference is missing a ref: {reference}')
            continue

        name, ref = reference.rsplit('@', 1)
        if not SHA_PATTERN.fullmatch(ref):
            errors.append(f'Action is not pinned to a full commit SHA: {reference}')
            continue

        expected = EXPECTED_ACTIONS.get(name)
        if expected is None:
            errors.append(f'Unreviewed external action is present: {name}@{ref}')
            continue
        counts[name] += 1
        if ref != expected:
            errors.append(
                f'{name} expected reviewed SHA {expected}, found {ref}.'
            )

    for name, count in counts.items():
        if count == 0:
            errors.append(f'Required reviewed action is missing: {name}')

    checkout_blocks = re.findall(
        r'uses:\s*actions/checkout@[0-9a-f]{40}(.*?)(?=\n\s*-\s+name:|\Z)',
        text,
        flags=re.DOTALL,
    )
    if len(checkout_blocks) != counts['actions/checkout']:
        errors.append('Unable to parse every checkout action block.')
    for index, block in enumerate(checkout_blocks, start=1):
        if 'persist-credentials: false' not in block:
            errors.append(f'Checkout step {index} must set persist-credentials: false.')

    if 'subosito/flutter-action' in text:
        errors.append('CI must use the repository-owned verified Flutter installer.')

    required_commands = (
        'python3 scripts/install_flutter_sdk.py',
        'python3 scripts/verify_ci_pins.py',
        'python3 scripts/verify_platforms.py',
        'python3 scripts/phase0_evidence_test.py',
        'python3 scripts/verify_phase0_evidence.py',
        'python3 scripts/phase0_launch_evidence_test.py',
        './scripts/capture_android_launch_evidence.sh',
        './scripts/capture_ios_launch_evidence.sh',
    )
    for command in required_commands:
        if command not in text:
            errors.append(f'CI is missing required command: {command}')

    if errors:
        for error in errors:
            print(error)
        return 1

    print(
        f'Validated {len(uses)} immutable action references in '
        f'{workflow_path}, least-privilege checkout settings, and '
        'repository-owned Flutter installation.'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
