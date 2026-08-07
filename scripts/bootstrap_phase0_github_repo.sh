#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REPO=''
VISIBILITY=''
BRANCH='main'
EXECUTE=0
SKIP_GATE=0

usage() {
  cat <<'USAGE'
Usage: ./scripts/bootstrap_phase0_github_repo.sh --repo OWNER/REPO --visibility private|public|internal [options]

Safely bootstrap an extracted ClearScan source bundle into GitHub, push the
exact commit, and then run the existing P00-T03 hosted gate collector.

By default this command is PLAN-ONLY and makes no git/GitHub changes.
Pass --execute to allow git initialization/commit, remote creation/push, and
workflow dispatch. The script never accepts or prints a GitHub token.

Required:
  --repo OWNER/REPO       Target GitHub repository.
  --visibility VALUE      private, public, or internal. Required even when the
                          repository already exists so intent is explicit.

Options:
  --branch NAME           Branch to push and dispatch. Default: main.
  --execute               Perform mutations. Without this flag, print the plan.
  --skip-gate             Create/push only; do not dispatch P00-T03 afterward.
  -h, --help              Show this help.

Connected-host requirements for --execute:
  - git and GitHub CLI (`gh`) installed
  - `gh` already authenticated to github.com
  - git user.name and user.email configured when a first commit is required
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || { echo 'Missing value for --repo.' >&2; exit 2; }
      REPO=$2; shift 2 ;;
    --visibility)
      [ "$#" -ge 2 ] || { echo 'Missing value for --visibility.' >&2; exit 2; }
      VISIBILITY=$2; shift 2 ;;
    --branch)
      [ "$#" -ge 2 ] || { echo 'Missing value for --branch.' >&2; exit 2; }
      BRANCH=$2; shift 2 ;;
    --execute)
      EXECUTE=1; shift ;;
    --skip-gate)
      SKIP_GATE=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

[ -n "$REPO" ] || { echo '--repo OWNER/REPO is required.' >&2; exit 2; }
[ -n "$VISIBILITY" ] || { echo '--visibility private|public|internal is required.' >&2; exit 2; }
case "$VISIBILITY" in
  private|public|internal) ;;
  *) echo "Unsupported visibility: $VISIBILITY" >&2; exit 2 ;;
esac
printf '%s' "$REPO" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' || {
  echo "Invalid repository name: $REPO (expected OWNER/REPO)." >&2
  exit 2
}
printf '%s' "$BRANCH" | grep -Eq '^[A-Za-z0-9._/-]+$' || {
  echo "Invalid branch name: $BRANCH" >&2
  exit 2
}

cd "$ROOT_DIR"

cat <<PLAN
ClearScan P00-T03 GitHub bootstrap plan
  source:      $ROOT_DIR
  repository:  $REPO
  visibility:  $VISIBILITY
  branch:      $BRANCH
  gate:        $([ "$SKIP_GATE" -eq 1 ] && echo 'skip' || echo 'dispatch + watch + download + verify')
  mode:        $([ "$EXECUTE" -eq 1 ] && echo 'EXECUTE' || echo 'PLAN-ONLY')
PLAN

if [ "$EXECUTE" -ne 1 ]; then
  cat <<'PLAN_ONLY'

No files, git metadata, remotes, repositories, or workflow runs were changed.
Review the plan and rerun with --execute when ready.
PLAN_ONLY
  exit 0
fi

command -v git >/dev/null 2>&1 || { echo 'git is required.' >&2; exit 1; }
command -v gh >/dev/null 2>&1 || {
  echo 'GitHub CLI (`gh`) is required. Install it and run `gh auth login` first.' >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || { echo 'python3 is required.' >&2; exit 1; }

gh auth status --active --hostname github.com >/dev/null || {
  echo 'GitHub CLI is not authenticated to github.com. Run `gh auth login` first.' >&2
  exit 1
}
# Configure git to use the already-authenticated GitHub CLI credential helper.
gh auth setup-git --hostname github.com >/dev/null

# Refuse to publish a source tree that fails repository-owned offline checks.
./scripts/check_offline.sh

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git init -b "$BRANCH" >/dev/null 2>&1; then
    :
  else
    git init >/dev/null
    git checkout -b "$BRANCH" >/dev/null
  fi
fi

# If there is no commit yet, make exactly one bootstrap commit. Never invent a
# git identity: require the connected host/account owner to configure it.
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  [ -n "$(git config user.name || true)" ] || {
    echo 'git user.name is not configured. Set it before publishing this repository.' >&2
    exit 1
  }
  [ -n "$(git config user.email || true)" ] || {
    echo 'git user.email is not configured. Set it before publishing this repository.' >&2
    exit 1
  }
  git add --all
  git commit -m 'Bootstrap ClearScan P00-T03 hosted gate' >/dev/null
else
  [ -z "$(git status --porcelain)" ] || {
    echo 'Existing git repository must have a clean working tree before bootstrap.' >&2
    exit 1
  }
fi

HEAD_SHA=$(git rev-parse HEAD)
REMOTE_EXISTS=0
if gh repo view "$REPO" --json nameWithOwner --jq '.nameWithOwner' >/dev/null 2>&1; then
  REMOTE_EXISTS=1
  ACTUAL_VISIBILITY=$(gh repo view "$REPO" --json visibility --jq '.visibility' | tr '[:upper:]' '[:lower:]')
  if [ "$ACTUAL_VISIBILITY" != "$VISIBILITY" ]; then
    echo "Existing repository visibility is $ACTUAL_VISIBILITY, but --visibility requested $VISIBILITY. Refusing to continue." >&2
    exit 1
  fi
fi

if [ "$REMOTE_EXISTS" -eq 0 ]; then
  echo "Creating $VISIBILITY GitHub repository $REPO and pushing $HEAD_SHA..."
  gh repo create "$REPO" "--$VISIBILITY" --source=. --remote=origin --push
else
  echo "GitHub repository $REPO already exists; validating/adding origin and pushing $HEAD_SHA..."
  EXPECTED_HTTPS="https://github.com/$REPO.git"
  EXPECTED_HTTPS_ALT="https://github.com/$REPO"
  EXPECTED_SSH="git@github.com:$REPO.git"
  if git remote get-url origin >/dev/null 2>&1; then
    ORIGIN_URL=$(git remote get-url origin)
    case "$ORIGIN_URL" in
      "$EXPECTED_HTTPS"|"$EXPECTED_HTTPS_ALT"|"$EXPECTED_SSH") ;;
      *)
        echo "origin points to $ORIGIN_URL, not $REPO. Refusing to rewrite it automatically." >&2
        exit 1 ;;
    esac
  else
    git remote add origin "$EXPECTED_HTTPS"
  fi
  git push -u origin "HEAD:$BRANCH"
fi

# Bind the local directory to the selected repository for later gh commands.
gh repo set-default "$REPO" >/dev/null

gh api "repos/$REPO/commits/$HEAD_SHA" >/dev/null || {
  echo "Push verification failed: commit $HEAD_SHA is not visible in $REPO." >&2
  exit 1
}

if [ "$SKIP_GATE" -eq 1 ]; then
  echo "Repository bootstrap complete. Gate dispatch skipped by request. Commit: $HEAD_SHA"
  exit 0
fi

exec ./scripts/run_phase0_github_gate.sh --repo "$REPO" --ref "$BRANCH"
