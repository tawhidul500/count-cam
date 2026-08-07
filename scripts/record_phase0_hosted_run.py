from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

START_MARKER = '<!-- P00-T03-VERIFIED-HOSTED-RUN-START -->'
END_MARKER = '<!-- P00-T03-VERIFIED-HOSTED-RUN-END -->'


class RecordError(RuntimeError):
    pass


def load_record(path: Path) -> dict[str, object]:
    try:
        payload = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise RecordError(f'Unable to read verified hosted-run record: {error}') from error
    if payload.get('schema_version') != 1 or payload.get('evidence_ready') is not True:
        raise RecordError('Hosted-run record is not verified/gate-ready.')
    return payload


def render(record: dict[str, object]) -> str:
    android = record.get('android')
    ios = record.get('ios')
    if not isinstance(android, dict) or not isinstance(ios, dict):
        raise RecordError('Hosted-run record is missing Android/iOS evidence.')
    return '\n'.join(
        [
            START_MARKER,
            '## Verified hosted P00-T03 run',
            '',
            f"- Workflow run URL: {record['run_url']}",
            f"- Workflow run ID: `{record['run_id']}`",
            f"- Commit SHA: `{record['commit_sha']}`",
            f"- Git ref: `{record['git_ref']}`",
            f"- Android target: {android['target_name']} / Android {android['os_version']}",
            f"- Android APK SHA-256: `{android['artifact_sha256']}`",
            f"- Android launch screenshot SHA-256: `{android['launch_screenshot_sha256']}`",
            f"- iOS target: {ios['target_name']} / {ios['os_version']}",
            f"- iOS simulator archive SHA-256: `{ios['artifact_sha256']}`",
            f"- iOS launch screenshot SHA-256: `{ios['launch_screenshot_sha256']}`",
            '- Native build evidence verifier: `PASS`',
            '- Launch evidence verifier: `PASS`',
            '- Hosted summary: `P00-T03 gate-closing evidence ready: YES`',
            '',
            'This block was written only after the downloaded hosted artifacts passed the local repository verifiers. Review warnings/runtime notes before changing P00-T03 to DONE.',
            END_MARKER,
        ]
    )


def update_document(document: Path, block: str) -> None:
    text = document.read_text(encoding='utf-8')
    if START_MARKER in text or END_MARKER in text:
        if START_MARKER not in text or END_MARKER not in text:
            raise RecordError('Evidence document has incomplete hosted-run markers.')
        start = text.index(START_MARKER)
        end = text.index(END_MARKER, start) + len(END_MARKER)
        updated = text[:start].rstrip() + '\n\n' + block + '\n' + text[end:].lstrip('\n')
    else:
        anchor = '## Required records after the first successful hosted run'
        if anchor not in text:
            raise RecordError(f'Evidence document is missing anchor: {anchor}')
        index = text.index(anchor)
        updated = text[:index].rstrip() + '\n\n' + block + '\n\n' + text[index:]
    document.write_text(updated.rstrip() + '\n', encoding='utf-8')


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Record a locally verified hosted P00-T03 run in PHASE0_EVIDENCE.md.'
    )
    parser.add_argument('--record-json', type=Path, required=True)
    parser.add_argument('--evidence-doc', type=Path, required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        record = load_record(args.record_json)
        update_document(args.evidence_doc, render(record))
    except (OSError, KeyError, RecordError) as error:
        print(str(error), file=sys.stderr)
        return 1
    print(f'Recorded verified hosted run in {args.evidence_doc.resolve()}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
