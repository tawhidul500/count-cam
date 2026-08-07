from __future__ import annotations

import hashlib
import json
from pathlib import Path
import tempfile

from write_artifact_manifest import ManifestError, write_manifest


def expected_sha(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def main() -> int:
    with tempfile.TemporaryDirectory(prefix='clearscan-manifest-test-') as temporary:
        root = Path(temporary) / 'evidence'
        root.mkdir()
        nested = root / 'logs'
        nested.mkdir()

        alpha = b'alpha evidence\n'
        beta = b'beta evidence\n'
        (root / 'SUMMARY.md').write_bytes(alpha)
        (nested / 'flutter_test.log').write_bytes(beta)

        output = root / 'ARTIFACT_MANIFEST.json'
        payload = write_manifest(root, output)
        parsed = json.loads(output.read_text(encoding='utf-8'))

        assert payload['schema_version'] == 1
        assert parsed['file_count'] == 2
        assert [record['path'] for record in parsed['files']] == [
            'SUMMARY.md',
            'logs/flutter_test.log',
        ]
        assert parsed['files'][0]['sha256'] == expected_sha(alpha)
        assert parsed['files'][1]['sha256'] == expected_sha(beta)
        assert all(record['path'] != output.name for record in parsed['files'])

        symlink = root / 'unsafe-link'
        try:
            symlink.symlink_to(root / 'SUMMARY.md')
        except (OSError, NotImplementedError):
            pass
        else:
            try:
                write_manifest(root, output)
            except ManifestError:
                pass
            else:
                raise AssertionError('Symlink evidence was not rejected.')

    print('Artifact manifest contract: PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
