#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "bootstrap_phase0_github_repo.sh"


def require(text: str, needle: str) -> None:
    if needle not in text:
        raise SystemExit(f"bootstrap contract missing: {needle}")


def main() -> int:
    text = SCRIPT.read_text(encoding="utf-8")
    for needle in (
        "--execute",
        "--visibility",
        "gh auth status --active --hostname github.com",
        "gh auth setup-git --hostname github.com",
        "gh repo create",
        "--source=. --remote=origin --push",
        "git push -u origin",
        "gh api \"repos/$REPO/commits/$HEAD_SHA\"",
        "run_phase0_github_gate.sh",
        "./scripts/check_offline.sh",
        "ACTUAL_VISIBILITY",
    ):
        require(text, needle)
    for forbidden in ("--with-token", "GH_TOKEN=", "GITHUB_TOKEN="):
        if forbidden in text:
            raise SystemExit(f"bootstrap script must not accept/embed tokens: {forbidden}")

    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        scripts = root / "scripts"
        scripts.mkdir()
        local = scripts / SCRIPT.name
        local.write_text(text, encoding="utf-8")
        local.chmod(0o755)

        result = subprocess.run(
            [
                str(local),
                "--repo",
                "example/clearscan",
                "--visibility",
                "private",
                "--branch",
                "main",
            ],
            cwd=root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if result.returncode != 0:
            raise SystemExit(f"plan-only bootstrap failed: {result.stderr}")
        if "mode:        PLAN-ONLY" not in result.stdout:
            raise SystemExit("plan-only output did not disclose non-mutating mode")
        if (root / ".git").exists():
            raise SystemExit("plan-only bootstrap unexpectedly created .git metadata")

        bad = subprocess.run(
            [str(local), "--repo", "example/clearscan", "--visibility", "secret"],
            cwd=root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if bad.returncode == 0:
            raise SystemExit("invalid visibility was accepted")

    print("GitHub bootstrap contract: PASS (guarded plan mode, auth/setup, create/push, commit binding, and gate handoff).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
