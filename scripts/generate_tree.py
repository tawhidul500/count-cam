from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'docs' / 'PROJECT_TREE.txt'
EXCLUDED_NAMES = {'.dart_tool', '.git', 'build', '__pycache__'}


def walk(directory: Path, prefix: str = '') -> list[str]:
    entries = sorted(
        (entry for entry in directory.iterdir() if entry.name not in EXCLUDED_NAMES),
        key=lambda entry: (entry.is_file(), entry.name.lower()),
    )
    lines: list[str] = []
    for index, entry in enumerate(entries):
        is_last = index == len(entries) - 1
        connector = '└── ' if is_last else '├── '
        lines.append(f'{prefix}{connector}{entry.name}')
        if entry.is_dir():
            extension = '    ' if is_last else '│   '
            lines.extend(walk(entry, prefix + extension))
    return lines


content = ['clearscan/', *walk(ROOT)]
OUTPUT.write_text('\n'.join(content) + '\n', encoding='utf-8')
print(f'Wrote {OUTPUT.relative_to(ROOT)} with {len(content)} lines.')
