#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

python3 scripts/validate_project.py
python3 scripts/source_contract_test.py
python3 scripts/verify_ci_pins.py
python3 scripts/artifact_manifest_test.py
python3 scripts/phase0_evidence_test.py
python3 scripts/phase0_gate_summary_test.py
python3 scripts/phase0_launch_evidence_test.py
python3 scripts/phase0_downloaded_run_test.py
python3 scripts/phase0_github_gate_contract_test.py
python3 scripts/phase0_github_bootstrap_contract_test.py
python3 scripts/install_flutter_sdk.py \
  --resolve-only \
  --manifest-file tool/fixtures/flutter_releases_linux.json \
  --platform linux \
  --architecture x64 >/dev/null

echo "Offline repository/source/evidence checks passed."
