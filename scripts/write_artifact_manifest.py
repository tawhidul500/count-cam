from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys

CHUNK_SIZE = 1024 * 1024
SCHEMA_VERSION = 1


class ManifestError(RuntimeError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        while chunk := handle.read(CHUNK_SIZE):
            digest.update(chunk)
    return digest.hexdigest()


def collect_files(root: Path, output: Path) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    output_resolved = output.resolve()

    for path in sorted(root.rglob('*'), key=lambda item: item.as_posix()):
        if path.is_symlink():
            raise ManifestError(f'Evidence directories may not contain symlinks: {path}')
        if not path.is_file() or path.resolve() == output_resolved:
            continue

        relative = path.relative_to(root).as_posix()
        records.append(
            {
                'path': relative,
                'size_bytes': path.stat().st_size,
                'sha256': sha256_file(path),
            }
        )

    if not records:
        raise ManifestError(f'No evidence files found under {root}.')
    return records


def write_manifest(root: Path, output: Path) -> dict[str, object]:
    root = root.expanduser().resolve()
    output = output.expanduser().resolve()

    if not root.is_dir():
        raise ManifestError(f'Evidence root is not a directory: {root}')
    try:
        output.relative_to(root)
    except ValueError as error:
        raise ManifestError('Artifact manifest output must be inside the evidence root.') from error

    records = collect_files(root, output)
    payload: dict[str, object] = {
        'schema_version': SCHEMA_VERSION,
        'generated_at_utc': datetime.now(timezone.utc).isoformat(),
        'evidence_root': root.name,
        'file_count': len(records),
        'files': records,
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + '.part')
    temporary.write_text(json.dumps(payload, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    temporary.replace(output)
    return payload


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Write a SHA-256 manifest for ClearScan Phase 0 evidence artifacts.'
    )
    parser.add_argument('--root', type=Path, required=True, help='Evidence directory to hash.')
    parser.add_argument('--output', type=Path, required=True, help='Manifest JSON path inside root.')
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        payload = write_manifest(args.root, args.output)
    except (OSError, ManifestError) as error:
        print(str(error), file=sys.stderr)
        return 1

    print(
        f'Wrote artifact manifest with {payload["file_count"]} files: '
        f'{args.output.expanduser().resolve()}'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
