#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ARCHIVE=''
OUTPUT="$ROOT_DIR/artifacts/phase0_launch/ios"
DEVICE=''
SETTLE_SECONDS=5

usage() {
  cat <<'EOF'
Usage: ./scripts/capture_ios_launch_evidence.sh --archive PATH [options]

Install and launch the real ClearScan Flutter iOS simulator app on an available
iPhone simulator, capture screenshot/runtime evidence, and verify its manifest.

Options:
  --archive PATH        ZIP containing Runner.app (required).
  --output PATH         Evidence directory.
  --device UDID         Explicit simulator UDID. A booted/available iPhone is
                        selected automatically when omitted.
  --settle-seconds N    Seconds to wait before screenshot (default: 5).
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --archive) ARCHIVE=${2:?Missing value for --archive}; shift 2 ;;
    --output) OUTPUT=${2:?Missing value for --output}; shift 2 ;;
    --device) DEVICE=${2:?Missing value for --device}; shift 2 ;;
    --settle-seconds) SETTLE_SECONDS=${2:?Missing value for --settle-seconds}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$ARCHIVE" ] || { echo '--archive is required.' >&2; exit 2; }
ARCHIVE=$(cd "$(dirname "$ARCHIVE")" && pwd)/$(basename "$ARCHIVE")
[ -f "$ARCHIVE" ] || { echo "iOS archive not found: $ARCHIVE" >&2; exit 1; }
command -v xcrun >/dev/null 2>&1 || { echo 'xcrun is required.' >&2; exit 1; }
command -v ditto >/dev/null 2>&1 || { echo 'ditto is required.' >&2; exit 1; }

# shellcheck disable=SC1091
source "$ROOT_DIR/tool/project.env"
BUNDLE_ID=$CLEARSCAN_IOS_BUNDLE_ID
mkdir -p "$OUTPUT"
OUTPUT=$(cd "$OUTPUT" && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/clearscan-ios-launch.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT

ditto -x -k "$ARCHIVE" "$TMP_DIR/unpacked"
APP_PATH=$(find "$TMP_DIR/unpacked" -type d -name Runner.app -print -quit)
[ -n "$APP_PATH" ] || { echo 'Runner.app was not found in the simulator archive.' >&2; exit 1; }

SIM_JSON="$TMP_DIR/simulators.json"
xcrun simctl list devices available -j > "$SIM_JSON"
if [ -z "$DEVICE" ]; then
  DEVICE=$(python3 - "$SIM_JSON" <<'PY'
import json, sys
payload = json.load(open(sys.argv[1], encoding='utf-8'))
booted = []
available = []
for runtime, devices in payload.get('devices', {}).items():
    for device in devices:
        if not device.get('isAvailable', False) or 'iPhone' not in device.get('name', ''):
            continue
        record = (device.get('udid', ''), device.get('name', ''), device.get('state', ''), runtime)
        if record[2] == 'Booted':
            booted.append(record)
        else:
            available.append(record)
records = booted or available
if records:
    print(records[0][0])
PY
)
fi
[ -n "$DEVICE" ] || { echo 'No available iPhone simulator found.' >&2; exit 1; }

STATE=$(python3 - "$SIM_JSON" "$DEVICE" <<'PY'
import json, sys
payload = json.load(open(sys.argv[1], encoding='utf-8'))
udid = sys.argv[2]
for runtime, devices in payload.get('devices', {}).items():
    for device in devices:
        if device.get('udid') == udid:
            print(device.get('state', ''))
            raise SystemExit
PY
)
if [ "$STATE" != 'Booted' ]; then
  xcrun simctl boot "$DEVICE" || true
fi
xcrun simctl bootstatus "$DEVICE" -b

{
  echo "ClearScan iOS launch evidence"
  echo "bundle_id=$BUNDLE_ID"
  echo "simulator_udid=$DEVICE"
  xcrun simctl uninstall "$DEVICE" "$BUNDLE_ID" || true
  xcrun simctl install "$DEVICE" "$APP_PATH"
  xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" || true
  echo "launch_command=xcrun simctl launch $DEVICE $BUNDLE_ID"
  xcrun simctl launch "$DEVICE" "$BUNDLE_ID"
} 2>&1 | tee "$OUTPUT/ios-launch.log"

sleep "$SETTLE_SECONDS"

xcrun simctl get_app_container "$DEVICE" "$BUNDLE_ID" app > "$OUTPUT/ios-app-container.txt"
grep -F 'Runner.app' "$OUTPUT/ios-app-container.txt" >/dev/null || {
  echo 'Installed iOS app container does not reference Runner.app.' >&2
  exit 1
}

xcrun simctl io "$DEVICE" screenshot "$OUTPUT/ios-launch.png"

python3 - "$SIM_JSON" "$DEVICE" > "$OUTPUT/ios-simulator.txt" <<'PY'
import json, sys
payload = json.load(open(sys.argv[1], encoding='utf-8'))
udid = sys.argv[2]
for runtime, devices in payload.get('devices', {}).items():
    for device in devices:
        if device.get('udid') == udid:
            print(f"udid={udid}")
            print(f"name={device.get('name', '')}")
            print(f"state={device.get('state', '')}")
            print(f"runtime={runtime}")
            raise SystemExit
raise SystemExit('Simulator UDID not found in simctl output.')
PY

cp "$ARCHIVE" "$OUTPUT/clearscan-ios-simulator.zip"
TARGET_NAME=$(awk -F= '$1 == "name" {print substr($0, index($0,"=")+1)}' "$OUTPUT/ios-simulator.txt")
OS_VERSION=$(awk -F= '$1 == "runtime" {value=substr($0, index($0,"=")+1); sub(/^.*iOS-/, "", value); gsub(/-/, ".", value); print value}' "$OUTPUT/ios-simulator.txt")
[ -n "$OS_VERSION" ] || OS_VERSION='simulator-runtime-unknown'

python3 "$ROOT_DIR/scripts/write_phase0_launch_report.py" \
  --platform ios \
  --identifier "$BUNDLE_ID" \
  --artifact "$OUTPUT/clearscan-ios-simulator.zip" \
  --screenshot "$OUTPUT/ios-launch.png" \
  --target-name "$TARGET_NAME" \
  --os-version "$OS_VERSION" \
  --output "$OUTPUT/launch-report.json"

python3 "$ROOT_DIR/scripts/write_artifact_manifest.py" \
  --root "$OUTPUT" \
  --output "$OUTPUT/ARTIFACT_MANIFEST.json"
python3 "$ROOT_DIR/scripts/verify_phase0_launch_evidence.py" \
  --root "$OUTPUT" \
  --platform ios

printf 'iOS launch evidence captured: %s\n' "$OUTPUT"
