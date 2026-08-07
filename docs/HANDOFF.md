# ClearScan Project Handoff

Latest update: 2026-08-07

## Project

- Name: ClearScan
- Tagline: Smart Scanner. Better Documents.
- Product: Original privacy-first document scanner for Android and iOS
- Repository source of truth: This repository and its `/docs` directory
- Conversation language requested by owner: Bangla

## Current position

- Current phase: Phase 0 - Native runtime verification; Phase 1 visible UI source remains in REVIEW
- Current task ID: P00-T03
- Current task status: BLOCKED
- Last completed task: P00-T02 - Implement central configuration, foundation theme tokens, minimal app shell, and startup test source
- Latest completed UI slice: UI Slice 14 - Final responsive, accessibility, state, unsaved-exit, and consistency source audit
- Exact next task: P00-T03 - On a connected host, review then execute `./scripts/bootstrap_phase0_github_repo.sh --repo OWNER/REPO --visibility private --execute` (or use the existing clone collector), review downloaded verified build+launch evidence, and record the run in `docs/PHASE0_EVIDENCE.md`
- P01-T00 status: REVIEW; do not move it to DONE before representative Flutter runtime/accessibility evidence exists

## Work completed in the latest session

- Reconfirmed that this sandbox has Git but no GitHub CLI, GitHub token, authenticated remote, `.git` metadata, Flutter, Android SDK, or iOS toolchain, so an actual hosted/native gate run still cannot be dispatched here.
- Read the ordered backlog and preserved the hard dependency: P00-T04/P01-T01 were not started because P00-T03 has no reviewed hosted run.
- Verified current GitHub CLI repository-creation and credential-helper syntax against the official CLI manual before implementing the bootstrap path.
- Added `scripts/bootstrap_phase0_github_repo.sh`, a guarded plan-first bridge from an extracted source ZIP to a GitHub repository and the existing P00-T03 hosted gate.
- The bootstrap requires explicit `OWNER/REPO` and repository visibility, makes no mutation without `--execute`, never accepts a token argument, and refuses an unexpected existing `origin`.
- For a first commit, the helper requires the operator's configured `git user.name` and `git user.email` rather than inventing identity.
- Existing GitHub repository visibility is checked against the explicit requested visibility before push.
- Added `scripts/check_offline.sh` so repository/source/evidence contracts can run before publication without requiring local Flutter; `scripts/check.sh` now delegates to it before runtime Flutter checks.
- The bootstrap runs offline checks, uses the already-authenticated GitHub CLI credential helper, creates or attaches the target repository, pushes the exact commit, verifies the commit through the GitHub API, and then hands off to `run_phase0_github_gate.sh`.
- Added `scripts/phase0_github_bootstrap_contract_test.py`, including proof that plan-only mode does not create `.git` metadata and invalid visibility is rejected.
- Added the bootstrap contract to the P00-T03 probe, repository validation, QA/security/runbook documentation, and continuity records.

## Files created

- `scripts/bootstrap_phase0_github_repo.sh`
- `scripts/phase0_github_bootstrap_contract_test.py`
- `scripts/check_offline.sh`

## Files modified

- `scripts/check.sh`
- `scripts/validate_project.py`
- `scripts/probe_p00_t03.py`
- `README.md`
- `docs/TASKS.md`
- `docs/ROADMAP.md`
- `docs/DECISIONS.md`
- `docs/CHANGELOG.md`
- `docs/KNOWN_ISSUES.md`
- `docs/QA_CHECKLIST.md`
- `docs/PHASE0_EVIDENCE.md`
- `docs/SIGNING_AND_CI_BASELINE.md`
- `docs/ENVIRONMENT_SETUP.md`
- `docs/CONNECTED_HOST_RUNBOOK.md`
- `docs/HANDOFF.md`
- `docs/PROJECT_TREE.txt`

## Important decisions

- P00-T03 remains BLOCKED until an actual connected/hosted workflow execution produces gate-ready build+launch evidence; repository/bootstrap automation is not execution evidence.
- An extracted ZIP may now use the guarded bootstrap helper rather than requiring the owner to manually reconstruct git/GitHub setup.
- Remote mutation requires explicit `--execute`; repository visibility is never implicit.
- The bootstrap never invents git identity, rewrites an unexpected origin, accepts a GitHub token argument, or requires Flutter on the publishing machine.
- `check_offline.sh` is the pre-publication source/evidence gate; `check.sh` remains the combined offline+Flutter runtime quality command.
- Downloaded hosted artifacts must still be independently verified and manually reviewed before recording or changing P00-T03 status.
- Do not start P00-T04 or P01-T01 until P00-T03 has a reviewed successful run record.

## Known problems

- Flutter and Dart are not installed in the current sandbox.
- Android SDK tools/runners are unavailable here, and this Linux host cannot provide Xcode/iOS simulator execution.
- Official Flutter release storage remains inaccessible to shell execution because DNS resolution is blocked in this sandbox.
- GitHub CLI is not installed, no GitHub token is exposed, and the extracted project has no `.git` repository/authenticated remote, so the guarded bootstrap and `workflow_dispatch` cannot be executed in this session.
- The hosted Android/iOS build+launch workflow, collector, and ZIP-to-GitHub bootstrap are statically/synthetically validated but still need their first real GitHub-hosted execution.
- The UI source has still not been formatted, compiled, rendered, or exercised by pinned Flutter in this environment.
- The locally built visual-preview APK is not a Flutter build and never counts as P00-T03 evidence.

## Tests completed

- Repository contract validation: PASSED with 99 required files and 99 ordered task rows.
- Offline source-contract validation: PASSED across 42 Dart source files.
- Immutable CI action validation: PASSED with 7 reviewed immutable action references.
- Artifact-manifest, native-build evidence, hosted gate-summary, launch evidence, downloaded-run, and GitHub dispatch/collect contracts: PASSED.
- GitHub bootstrap contract: PASSED for plan-only non-mutation, explicit visibility, authentication/setup commands, create/push flow, remote commit binding, gate handoff, and token-argument prohibition.
- `check_offline.sh` full source/evidence suite: PASSED without requiring Flutter.
- Python compilation and shell syntax checks: PASSED for the new bootstrap/offline-check tooling.
- P00-T03 network probe hard-timeout protection: PASSED; DNS-blocked Flutter storage now returns a bounded blocker report instead of hanging the probe.
- Actual `dart format`, `flutter analyze`, `flutter test`, native builds, Android launch, iOS simulator launch, and real GitHub dispatch: NOT RUN in this sandbox.

## Tests still required

1. On a connected machine, install/authenticate GitHub CLI and configure `git user.name` / `git user.email`.
2. From an extracted bundle, first run `./scripts/bootstrap_phase0_github_repo.sh --repo OWNER/REPO --visibility private` and review the plan.
3. Rerun with `--execute`, or use `run_phase0_github_gate.sh` directly from an already clean/pushed clone.
4. Confirm source-quality passes on exact Flutter `3.44.8` / Dart `3.12.2`.
5. Confirm Android build and launch evidence both pass after download/re-verification.
6. Confirm iOS build and launch evidence both pass after download/re-verification.
7. Confirm `P00_T03_VERIFIED_HOSTED_RUN.json` reports `evidence_ready: true` and hosted summary says `P00-T03 gate-closing evidence ready: YES`.
8. Review runtime warnings/screenshots, then record the verified run in `docs/PHASE0_EVIDENCE.md`.
9. Move P00-T03 to DONE only after the reviewed record is complete.
10. Start P00-T04 identifier/signing approval only after P00-T03 closes.

## Continuation instructions

1. Respond to the owner in Bangla.
2. Treat this repository, `docs/PHASE0_EVIDENCE.md`, `docs/P00_T03_PROBE_2026-08-07.md`, `docs/UI_AUDIT.md`, and this handoff as the source of truth.
3. Continue P00-T03; do not bypass it to P00-T04/P01-T01.
4. Preferred path for a ZIP with no git metadata is the guarded bootstrap command; preferred path for an existing clean/pushed clone remains `run_phase0_github_gate.sh`.
5. If a run ID is supplied later, collect it with `--run-id`, verify all downloaded evidence, inspect `P00_T03_VERIFIED_HOSTED_RUN.md`, then use `--record` only after review.
6. Do not accept Flutter/Dart versions different from the central pins as gate-closing evidence.
7. Do not accept GitHub success state or artifact filenames unless the downloaded-run verifier passes.
8. Preserve all prototype disclosures during compile/runtime fixes.
9. Record warnings/device details/checksums before changing P00-T03 status.
10. Start P01-T01 only after P00-T04 closes Phase 0.
