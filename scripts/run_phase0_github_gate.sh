#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORKFLOW='flutter-ci.yml'
REPO=''
REF=''
RUN_ID=''
OUTPUT=''
RECORD=0

usage() {
  cat <<'EOF'
Usage: ./scripts/run_phase0_github_gate.sh [options]

Dispatch (or collect) the ClearScan Flutter quality gate with GitHub CLI,
watch it, download all artifacts, verify build+launch evidence locally, and
write a machine-readable hosted-run record.

Requirements:
  - this directory is a git clone of the commit being tested
  - `gh` is installed and already authenticated
  - the commit is pushed to the target GitHub repository

Options:
  --repo OWNER/REPO   GitHub repository. Defaults to `gh repo view`.
  --ref REF           Branch/tag containing the workflow. Defaults to current branch.
  --run-id ID         Collect an existing run instead of dispatching a new one.
  --output PATH       Output directory. Defaults to artifacts/github_phase0/<run-id>.
  --record            After verification, update docs/PHASE0_EVIDENCE.md.
  -h, --help          Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || { echo 'Missing value for --repo.' >&2; exit 2; }
      REPO=$2; shift 2 ;;
    --ref)
      [ "$#" -ge 2 ] || { echo 'Missing value for --ref.' >&2; exit 2; }
      REF=$2; shift 2 ;;
    --run-id)
      [ "$#" -ge 2 ] || { echo 'Missing value for --run-id.' >&2; exit 2; }
      RUN_ID=$2; shift 2 ;;
    --output)
      [ "$#" -ge 2 ] || { echo 'Missing value for --output.' >&2; exit 2; }
      OUTPUT=$2; shift 2 ;;
    --record)
      RECORD=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

cd "$ROOT_DIR"
command -v git >/dev/null 2>&1 || { echo 'git is required.' >&2; exit 1; }
command -v gh >/dev/null 2>&1 || {
  echo 'GitHub CLI (`gh`) is required on the connected host.' >&2
  echo 'Install it, authenticate with `gh auth login`, then rerun this command.' >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo 'This directory is not a git clone. Push/import the repository first.' >&2
  exit 1
}
gh auth status >/dev/null

if [ -z "$REPO" ]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
fi
if [ -z "$REF" ]; then
  REF=$(git branch --show-current)
  [ -n "$REF" ] || REF='main'
fi

HEAD_SHA=$(git rev-parse HEAD)
if [ -n "$(git status --porcelain)" ]; then
  echo 'Working tree must be clean before a gate run so downloaded evidence maps to one commit.' >&2
  exit 1
fi

gh api "repos/$REPO/commits/$HEAD_SHA" >/dev/null || {
  echo "Current commit $HEAD_SHA is not available in $REPO. Push it before dispatching." >&2
  exit 1
}

if [ -z "$RUN_ID" ]; then
  BEFORE_RUN_IDS=$(gh run list \
    --workflow "$WORKFLOW" \
    --commit "$HEAD_SHA" \
    --event workflow_dispatch \
    --limit 20 \
    --json databaseId \
    --jq '.[].databaseId' \
    -R "$REPO" || true)

  echo "Dispatching $WORKFLOW on $REPO at ref $REF (commit $HEAD_SHA)..."
  DISPATCH_OUTPUT=$(gh workflow run "$WORKFLOW" --ref "$REF" -R "$REPO" 2>&1) || {
    printf '%s\n' "$DISPATCH_OUTPUT" >&2
    exit 1
  }
  printf '%s\n' "$DISPATCH_OUTPUT"

  RUN_ID=$(printf '%s\n' "$DISPATCH_OUTPUT" | sed -nE 's#.*actions/runs/([0-9]+).*#\1#p' | tail -1)
  if [ -z "$RUN_ID" ]; then
    echo 'Waiting for the workflow_dispatch run to appear...'
    for _attempt in $(seq 1 30); do
      CANDIDATES=$(gh run list \
        --workflow "$WORKFLOW" \
        --commit "$HEAD_SHA" \
        --event workflow_dispatch \
        --limit 20 \
        --json databaseId,createdAt \
        --jq 'sort_by(.createdAt) | reverse | .[].databaseId' \
        -R "$REPO")
      for candidate in $CANDIDATES; do
        if ! printf '%s\n' "$BEFORE_RUN_IDS" | grep -qx "$candidate"; then
          RUN_ID=$candidate
          break
        fi
      done
      [ -n "$RUN_ID" ] && break
      sleep 2
    done
  fi
  [ -n "$RUN_ID" ] || { echo 'Unable to resolve dispatched workflow run ID.' >&2; exit 1; }
fi

if [ -z "$OUTPUT" ]; then
  OUTPUT="$ROOT_DIR/artifacts/github_phase0/$RUN_ID"
fi
mkdir -p "$OUTPUT"
OUTPUT=$(cd "$OUTPUT" && pwd)

echo "Tracking workflow run $RUN_ID..."
set +e
gh run watch "$RUN_ID" --compact --exit-status -R "$REPO"
WATCH_STATUS=$?
set -e

gh run view "$RUN_ID" \
  --json databaseId,headSha,url,status,conclusion,workflowName,event,createdAt,updatedAt \
  -R "$REPO" > "$OUTPUT/run.json"
RUN_SHA=$(gh run view "$RUN_ID" --json headSha --jq '.headSha' -R "$REPO")
if [ "$RUN_SHA" != "$HEAD_SHA" ]; then
  echo "Run commit mismatch: expected $HEAD_SHA, got $RUN_SHA" >&2
  exit 1
fi

if [ "$WATCH_STATUS" -ne 0 ]; then
  gh run view "$RUN_ID" --log-failed -R "$REPO" > "$OUTPUT/failed.log" 2>&1 || true
fi

rm -rf "$OUTPUT/artifacts"
mkdir -p "$OUTPUT/artifacts"
set +e
gh run download "$RUN_ID" -D "$OUTPUT/artifacts" -R "$REPO"
DOWNLOAD_STATUS=$?
set -e

if [ "$DOWNLOAD_STATUS" -ne 0 ]; then
  echo "Artifact download was incomplete. See $OUTPUT/run.json and $OUTPUT/failed.log if present." >&2
  exit "$DOWNLOAD_STATUS"
fi

VERIFY_JSON="$OUTPUT/P00_T03_VERIFIED_HOSTED_RUN.json"
VERIFY_MD="$OUTPUT/P00_T03_VERIFIED_HOSTED_RUN.md"
set +e
python3 scripts/verify_phase0_downloaded_run.py \
  --root "$OUTPUT/artifacts" \
  --json-output "$VERIFY_JSON" \
  --markdown-output "$VERIFY_MD"
VERIFY_STATUS=$?
set -e

if [ "$VERIFY_STATUS" -ne 0 ]; then
  echo 'Downloaded run is not P00-T03 gate-closing evidence.' >&2
  exit "$VERIFY_STATUS"
fi

if [ "$WATCH_STATUS" -ne 0 ]; then
  echo 'GitHub reported a non-success conclusion even though artifact verification passed; review the run.' >&2
  exit "$WATCH_STATUS"
fi

if [ "$RECORD" -eq 1 ]; then
  python3 scripts/record_phase0_hosted_run.py \
    --record-json "$VERIFY_JSON" \
    --evidence-doc docs/PHASE0_EVIDENCE.md
fi

echo
echo 'P00-T03 hosted gate artifacts are locally verified.'
echo "Run record: $VERIFY_MD"
if [ "$RECORD" -eq 0 ]; then
  echo 'Review the run record, then rerun with --run-id and --record to write it into PHASE0_EVIDENCE.md.'
fi
