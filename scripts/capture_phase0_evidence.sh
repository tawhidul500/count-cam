#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_ROOT=${CLEARSCAN_EVIDENCE_DIR:-"$ROOT_DIR/artifacts/phase0_evidence"}
TIMESTAMP=$(date -u +'%Y%m%dT%H%M%SZ')
OUTPUT_DIR="$OUTPUT_ROOT/$TIMESTAMP"
SUMMARY="$OUTPUT_DIR/SUMMARY.md"

mkdir -p "$OUTPUT_DIR"
cd "$ROOT_DIR"

write_manifest_on_exit() {
  local status=$?
  python3 scripts/write_artifact_manifest.py \
    --root "$OUTPUT_DIR" \
    --output "$OUTPUT_DIR/ARTIFACT_MANIFEST.json" >/dev/null 2>&1 || true
  exit "$status"
}

trap write_manifest_on_exit EXIT

run_step() {
  local name=$1
  shift
  local log="$OUTPUT_DIR/${name}.log"

  printf '\n==> %s\n' "$name"
  if "$@" >"$log" 2>&1; then
    cat "$log"
    printf -- '- %s: PASS\n' "$name" >>"$SUMMARY"
  else
    local status=$?
    cat "$log" >&2
    printf -- '- %s: FAIL (exit %s)\n' "$name" "$status" >>"$SUMMARY"
    printf '\nEvidence capture stopped. Review %s\n' "$log" >&2
    exit "$status"
  fi
}

cat >"$SUMMARY" <<EOF
# ClearScan Phase 0 Evidence

- Captured at (UTC): $TIMESTAMP
- Host OS: $(uname -s)
- Host architecture: $(uname -m)
- Repository: $ROOT_DIR

## Automated results
EOF

run_step environment_doctor ./scripts/environment_doctor.sh
run_step repository_contract python3 scripts/validate_project.py
run_step source_contract python3 scripts/source_contract_test.py
run_step immutable_ci_pins python3 scripts/verify_ci_pins.py
run_step flutter_release_resolution python3 scripts/install_flutter_sdk.py --resolve-only --manifest-file tool/fixtures/flutter_releases_linux.json --platform linux --architecture x64
run_step platform_identifiers python3 scripts/verify_platforms.py --json-output "$OUTPUT_DIR/platform_report.json"
run_step flutter_version flutter --version
run_step flutter_doctor flutter doctor -v
run_step dart_format dart format --output=none --set-exit-if-changed lib test integration_test
run_step flutter_analyze flutter analyze
run_step flutter_test flutter test

case "$(uname -s)" in
  Linux)
    run_step android_debug_build flutter build apk --debug
    if [ -f build/app/outputs/flutter-apk/app-debug.apk ]; then
      cp build/app/outputs/flutter-apk/app-debug.apk "$OUTPUT_DIR/clearscan-debug.apk"
      printf -- '- Android debug APK copied: PASS\n' >>"$SUMMARY"
    else
      printf -- '- Android debug APK copied: FAIL\n' >>"$SUMMARY"
      echo 'Expected Android debug APK was not generated.' >&2
      exit 1
    fi
    ;;
  Darwin)
    run_step ios_simulator_build flutter build ios --simulator --no-codesign
    if [ -d build/ios/iphonesimulator/Runner.app ]; then
      ditto -c -k --sequesterRsrc --keepParent \
        build/ios/iphonesimulator/Runner.app \
        "$OUTPUT_DIR/clearscan-ios-simulator.zip"
      printf -- '- iOS simulator application archived: PASS\n' >>"$SUMMARY"
    else
      printf -- '- iOS simulator application archived: FAIL\n' >>"$SUMMARY"
      echo 'Expected iOS simulator application was not generated.' >&2
      exit 1
    fi
    ;;
  *)
    printf -- '- Native debug build: SKIPPED on unsupported host OS\n' >>"$SUMMARY"
    ;;
esac

cat >>"$SUMMARY" <<'EOF'

## Manual launch evidence still required

- Android emulator or physical-device launch result
- iOS simulator or physical-device launch result
- Representative text-scaling and overflow review
- Final identifier and signing approval
EOF

printf '\nPhase 0 evidence captured in:\n%s\n' "$OUTPUT_DIR"
