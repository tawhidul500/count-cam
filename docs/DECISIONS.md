# ClearScan Decision Log

Updated: 2026-08-07

## DEC-001 - Use Flutter for the mobile application

- Date: 2026-08-06
- Context: The product targets Android and iOS with one maintainable UI codebase.
- Options considered: Separate native apps, React Native, Flutter.
- Decision: Use Flutter and Dart.
- Reason: Strong cross-platform UI control, native integration access, test support, and suitable performance for a scanner application when image processing is properly isolated.
- Consequences: Native platform code will still be required for some camera, image, OCR, and lifecycle behaviours. Flutter SDK availability is required to generate and validate platform runners.

## DEC-002 - Use a feature-first modular structure

- Date: 2026-08-06
- Context: The app contains scanning, editing, storage, OCR, export, account, and settings concerns.
- Options considered: Layer-first global folders, feature-first modules, one flat structure.
- Decision: Use feature-first modules with data/domain/presentation boundaries where useful.
- Reason: Improves ownership, continuation, testing, and incremental delivery.
- Consequences: Shared contracts must stay in appropriate core or domain locations and circular feature dependencies are prohibited.

## DEC-003 - Make the product offline-first

- Date: 2026-08-06
- Context: Documents are sensitive and essential scanning should work without an account.
- Options considered: Cloud-first, mandatory account, offline-first with optional backup.
- Decision: Local storage is authoritative for core features; cloud backup is optional and introduced later.
- Reason: Privacy, resilience, simpler MVP value, and clear user control.
- Consequences: Sync must later reconcile local history rather than treating the server as the only source of truth.

## DEC-004 - Centralise brand and theme foundations

- Date: 2026-08-06
- Context: Product name, tagline, colours, spacing, and radius must remain consistent and changeable.
- Options considered: Screen-level constants, generated theme package, central source tokens.
- Decision: Use central configuration and theme-token files from the beginning.
- Reason: Prevents UI drift and supports future rebranding.
- Consequences: Screens must not introduce undocumented hard-coded brand values.

## DEC-005 - Defer third-party state management and dependency injection

- Date: 2026-08-06
- Context: Phase 0 requires a minimal shell but the environment cannot fetch or validate packages.
- Options considered: Adopt a package immediately, use Flutter primitives temporarily, defer final selection.
- Decision: Use no external state-management or DI package in Phase 0 and select them in Phase 1 after a maintained-package review.
- Reason: Avoids unverified package locking and unnecessary foundation complexity.
- Consequences: Phase 1 must make and document the decision before significant interactive state is added.

## DEC-006 - Keep native runners generated, not hand-authored

- Date: 2026-08-06
- Context: The current environment has no Flutter SDK and cannot download one.
- Options considered: Handwrite Android/iOS project files, ship only Dart source, generate runners later using the official toolchain.
- Decision: Ship the complete Dart/documentation foundation and generate native runners with `flutter create` on a Flutter-enabled machine.
- Reason: Hand-authored runner files would be fragile and potentially inconsistent with the installed stable Flutter version.
- Consequences: Phase 0 remains in review until platform generation, analysis, and tests pass.

## DEC-007 - Centralise platform identifiers and automate the quality gate

- Date: 2026-08-06
- Context: P00-T03 must be reproducible on another machine or by another AI without relying on chat history or duplicated identifiers.
- Options considered: Keep values embedded in shell commands, hand-write native runners, centralise generation settings and add automated checks.
- Decision: Store provisional platform-generation values in `tool/project.env`, generate native runners only through the official Flutter CLI, and provide both local scripts and a GitHub Actions quality gate.
- Reason: This reduces configuration drift, makes handoff deterministic, and provides repeatable format, analysis, and test commands.
- Consequences: Identifier changes require a documented decision. CI supplements but does not replace Android/iOS launch, signing, permission, or real-device verification. The third-party Flutter setup action must be reviewed and commit-pinned before a production security gate is finalised.


## DEC-008 - Pin the Phase 0 Flutter toolchain

- Date: 2026-08-06
- Context: Using an unbounded `stable` channel can produce different native templates, formatting, analysis, and test results across continuation environments.
- Options considered: Follow the moving stable channel, pin only in CI, pin one version across local scripts and CI.
- Decision: Pin ClearScan Phase 0 to Flutter `3.44.8` on the stable channel through `.flutter-version`, `tool/project.env`, the environment doctor, bootstrap checks, and CI.
- Reason: A single exact toolchain makes generated runner files and quality evidence reproducible across developers and AI environments.
- Consequences: Toolchain upgrades require an explicit decision, compatibility review, documentation update, and rerun of the full quality gate.

## DEC-009 - Separate source, native-build, and device-launch evidence

- Date: 2026-08-06
- Context: P00-T03 requires more than a successful widget test. It also requires official native runner generation, identifier validation, Android and iOS build evidence, and actual launch evidence.
- Options considered: Treat one generic CI job as sufficient, hand-author runner files, or create separate source, native-build, and manual-launch evidence layers.
- Decision: Keep source quality, generated-platform verification, native debug builds, and manual device launches as separate evidence layers. Automate the first three where possible and record all evidence in `PHASE0_EVIDENCE.md`.
- Reason: This prevents a passing source test from being mistaken for platform readiness and gives another developer or AI an exact, auditable continuation path.
- Consequences: CI can prove source quality and produce Android/iOS debug artifacts, but P00-T03 remains open until Android and iOS launch evidence is recorded. Generated evidence logs remain outside version control unless deliberately attached to a controlled record.


## DEC-010 - Allow an owner-directed visible UI prototype before native verification

- Date: 2026-08-06
- Context: The owner explicitly asked to stop extending infrastructure and begin visible ClearScan application code, while P00-T03 remains blocked by unavailable Flutter and native toolchains.
- Options considered: Keep all UI work blocked, falsely close Phase 0, or proceed with a clearly labelled source-only prototype while preserving the unresolved native gate.
- Decision: Proceed with P01-T00 as an owner-directed visible UI prototype using only Flutter SDK widgets and mock data. Do not mark Phase 0 or the formal Phase 1 acceptance gate complete until Flutter formatting, analysis, tests, native builds, and device review pass.
- Reason: Produces tangible product progress without misrepresenting camera, storage, OCR, or platform readiness.
- Consequences: The repository may contain Phase 1/2 presentation source before P00-T03 closes. Prototype actions that are not functional must remain visibly disclosed, and all final architecture/package decisions remain subject to P01-T01 and runtime validation.

## DEC-011 - Keep viewer and editor interaction explicitly temporary

- Date: 2026-08-06
- Context: The owner requested visible document viewing and multi-page editing before the local database, file storage, crop, filter, OCR, and export phases are implemented.
- Options considered: Leave all controls inert, simulate permanent saves, or provide local widget-state interactions with clear prototype disclosure.
- Decision: Allow page selection, temporary add, duplicate, rotate, delete, and favorite state inside the prototype screens, but display that no real file is opened and no change is saved to device storage.
- Reason: This makes the intended user flow reviewable without falsely presenting persistence or document processing as complete.
- Consequences: Prototype state must be replaced by tested editor-session and repository contracts in the ordered functional phases. Share, PDF, OCR, crop, filter, move, rename, and delete persistence remain planned actions only.

## DEC-012 - Keep crop and filter workspaces visual and non-destructive

- Date: 2026-08-06
- Context: The owner requested visible crop and filter flows before an image-processing engine, persisted document pages, or geometry contracts exist.
- Options considered: Keep the buttons inert, simulate saved image output, or create interactive mock workspaces that return temporary presentation state only.
- Decision: Implement draggable crop corners and selectable filter previews using Flutter SDK presentation code, then store only temporary per-page status in the editor widget state.
- Reason: This makes the intended workflow reviewable while clearly separating UI behaviour from perspective correction, file mutation, and final image processing.
- Consequences: Crop coordinates and filter selections are discarded when the editor closes. Functional Phases 5 and 6 must replace these prototypes with versioned processing settings, engine abstractions, quality tests, and non-destructive persistence.



## DEC-013 - Keep PDF and OCR workspaces temporary and dependency-free

- Date: 2026-08-06
- Context: The owner requested visible PDF export and OCR flows before package evaluation, persisted pages, file generation, OCR engines, and sharing integrations exist.
- Options considered: Keep viewer actions inert, add unreviewed PDF/OCR packages early, or build explicit presentation-only workspaces with temporary state.
- Decision: Implement PDF options and OCR ready/processing/editable-result prototypes using only Flutter SDK widgets. Do not generate files, recognise real images, persist text, or imply export completion.
- Reason: Makes the intended workflow reviewable while preserving the ordered package, privacy, storage, and engine decisions in Phases 8 and 9.
- Consequences: Every selection and text edit resets after navigation. Functional PDF generation, local OCR, saved text, size calculation, sharing, and failure recovery remain future work requiring package review and runtime tests.

## DEC-014 - Keep Search and folder management isolated and session-only

- Date: 2026-08-06
- Context: The owner requested visible Search and folder-management UI before the ordered database, OCR index, and repository decisions can be executed.
- Options considered: Add persistence/search dependencies early, delay all organisation UI, or build an isolated Flutter-SDK prototype over mock data.
- Decision: Use one shared Search workspace over immutable mock document data and keep create, rename, recolour, and remove folder actions inside the active Folders widget state only.
- Reason: This makes the intended retrieval and organisation experience reviewable without creating false persistence, OCR, indexing, or device-file claims.
- Consequences: Search history, OCR indexing, database queries, folder/document transactions, and safe persisted deletion remain Phase 3, Phase 9, and Phase 10 work. Every prototype screen must disclose that closing or restarting resets its changes.

## DEC-015 - Keep onboarding as a safe Settings-launched preview

- Date: 2026-08-06
- Context: The owner requested visible onboarding before first-run persistence, authentication, permission services, or a formal router decision exists.
- Options considered: Make onboarding the permanent startup route, add early persistence and permission plugins, leave onboarding unimplemented, or expose an explicit presentation-only preview.
- Decision: Launch onboarding only from Settings, keep page progress in widget state, return a boolean continuation result to the existing app shell, and model camera permission and sign-in as clearly labelled placeholders.
- Reason: This makes welcome, feature value, privacy, and permission education reviewable without creating false device permission, authentication, or first-run completion claims.
- Consequences: Restarting or closing the preview resets progress. Phase 2 must still define first-run persistence, denial/recovery states, optional account behaviour, and integration tests before onboarding becomes the startup route.


## DEC-016 - Keep Documents Library management session-only

- Date: 2026-08-06
- Context: The owner requested visible list/grid, sorting, favorites, multi-select, and Recently Deleted flows before the local database and file-storage layers exist.
- Options considered: Add persistence early, leave library controls static, or implement temporary widget-state interactions with explicit disclosures.
- Decision: Use `MockDocumentData` as the starting data, keep favorite/selection/deleted state inside `DocumentsScreen`, and expose restore/permanent-remove actions only as preview-state changes.
- Reason: Makes the library workflow reviewable without claiming that device files or database records are modified.
- Consequences: All changes reset when the widget/app session is recreated. Functional persistence, trash retention, atomic deletion, restore, and migrations remain Phase 3 work.


## DEC-017 - Keep Settings preferences, cleanup, and privacy controls session-only

- Date: 2026-08-07
- Context: The owner requested visible Settings interactions before persistence, storage, analytics, permission, and service decisions are complete.
- Options considered: Leave Settings static; add real persistence and platform services early; add isolated session-only preview controls.
- Decision: Implement preference selection, illustrative storage details, simulated cleanup, and privacy-control previews using local widget state and Flutter SDK modal sheets only.
- Reason: This provides reviewable product behaviour without introducing unordered dependencies or falsely changing device data, consent, analytics, files, or saved preferences.
- Consequences: Every Settings surface must disclose temporary behaviour. Values reset when the Settings widget/app session is recreated. Real settings repositories, storage inspection, cleanup transactions, consent records, and diagnostics services remain Phase 11 work.


## DEC-018 - Keep support and legal content as non-submitting, non-approved prototypes

- Date: 2026-08-07
- Context: The owner requested visible Help, Feedback, About, Privacy Policy, and Terms surfaces before support infrastructure, URL launching, submission APIs, release ownership, or legal review exists.
- Options considered: Leave support rows inert; connect unapproved external services early; publish realistic-looking legal text without warnings; or create explicit Flutter-SDK content prototypes with safe placeholders.
- Decision: Implement local Help/Feedback and static About/Privacy/Terms screens. Feedback stays in widget memory, external actions show placeholders, and every legal surface states that it is a draft requiring professional review.
- Reason: Makes the intended support and policy experience reviewable without transmitting personal data, opening unknown destinations, or misrepresenting draft text as approved legal documents.
- Consequences: No support request, email, URL, consent, licence page, policy acceptance, or legal record exists. Final support channels and legal documents remain Phase 11 and release-review work.

## DEC-019 - Keep scanner permission, import, and capture review as presentation-only state

- Date: 2026-08-07
- Context: The owner requested visible scanner recovery and review flows before camera, permission, image-picker, file-storage, and lifecycle packages are selected or native runners are available.
- Options considered: Leave scanner controls inert, add unverified platform packages, or model all scanner states and transitions with local Flutter widget state and explicit disclosures.
- Decision: Implement permission-needed, ready, denied, permanently-denied, unavailable, import-source, and capture-review prototypes using Flutter SDK widgets only. Reuse the existing crop and filter workspaces for review, but never request permission, open settings, read files, capture images, or save output.
- Reason: The complete UX can be reviewed now without coupling presentation to an unapproved plugin or misrepresenting device functionality.
- Consequences: All scanner state resets with the route. Functional permission recovery, camera lifecycle, gallery/file validation, high-resolution capture, processing, and persistence remain ordered Phase 4 work and require real-device evidence.

## DEC-020 - Keep auto capture and capture-session pages generated and session-only

- Date: 2026-08-07
- Context: The visible scanner needs to communicate auto-capture behaviour and multi-page capture flow before camera analysis, persistence, and document repositories exist.
- Options considered: Hide the flow, imply real frame analysis and saved pages, or model it with generated previews and explicit disclosures.
- Decision: Allow session-only auto-capture settings, generated thumbnails, page selection, review/update, add, and remove interactions. No frame is analysed, no automatic capture occurs, and no page or file is persisted.
- Reason: This validates information architecture and interaction sequencing without misrepresenting Phase 4 camera or Phase 3 storage readiness.
- Consequences: Scanner state disappears when its route closes. Functional auto capture requires approved camera/edge packages, lifecycle handling, duplicate prevention, and real-device evidence.

## DEC-021 - Keep scan-session completion and save preview non-persistent

- Date: 2026-08-07
- Context: The visible scanner needs a clear finish step before database, private-file storage, folder repositories, transactional document save, and PDF generation exist.
- Options considered: End the scanner after keeping pages, imply a real save, or build a completion workspace that edits only a copied session-page list and returns presentation state to the scanner.
- Decision: Allow temporary title editing, folder selection, drag or arrow-based page reorder, page summary, and a save-document preview. The preview must state that it creates no document, database record, folder assignment, image, or PDF.
- Reason: This completes the reviewable capture-to-save journey without bypassing the ordered Phase 3, Phase 7, and Phase 8 persistence and export decisions.
- Consequences: Details and ordering reset when the scanner route closes. Functional save requires approved repositories, private storage, atomic transactions, error recovery, duplicate handling, and Flutter/native evidence.

## DEC-022 - Close the visible UI prototype at source-review status

- Date: 2026-08-07
- Decision: Treat Slice 14 as the final owner-directed visible UI prototype slice and move `P01-T00` to REVIEW rather than DONE.
- Rationale: The source now covers the planned visible flows plus reusable adaptive, loading/empty/error, status, touch-target, and unsaved-exit patterns. Flutter compilation, rendering, accessibility services, and native evidence are still unavailable, so final approval would be unsupported.
- Consequence: No additional UI prototype slice is scheduled before P00-T03/native toolchain evidence. Runtime findings may reopen targeted UI fixes. No functional camera, storage, OCR, export, sharing, authentication, networking, or persistence dependency is authorised by this decision.

## DEC-023 - Cross-pin Dart and unify every Flutter installer path

- Date: 2026-08-07
- Context: The first production-gate execution attempt found that Flutter `3.44.8` was centrally pinned but its bundled Dart `3.12.2` was only implicit in the release manifest. It also found that `complete_phase0_host.sh` documented and passed offline installer arguments to `install_flutter_sdk.sh`, while that shell installer ignored positional arguments and implemented a separate download path.
- Decision: Pin Dart `3.12.2` in `tool/project.env`, require the official Flutter release manifest to match that Dart version, make the shell installer a thin argument-forwarding wrapper around `install_flutter_sdk.py`, and retain the Python installer as the single verification implementation.
- Reason: A production foundation needs one auditable toolchain resolution path. Silent argument loss or an implicit Dart version can make a documented offline build procedure non-reproducible.
- Consequences: Flutter/Dart mismatch, archive checksum mismatch, and missing offline archive paths fail before extraction. `scripts/probe_p00_t03.py` records blocked-host evidence without pretending that P00-T03 has passed.

## DEC-024 - Verify native CI artifacts as evidence bundles

- Date: 2026-08-07
- Context: P00-T03 depends on connected CI/hosts. A successful upload alone is not sufficient evidence because an artifact can be incomplete, built with the wrong toolchain, have mismatched identifiers, or be corrupted after staging. Failed CI runs also need durable logs instead of disappearing at the first error.
- Decision: Treat each Android/iOS CI upload as an evidence bundle. Capture Flutter/Dart/toolchain/build logs, generate a SHA-256 manifest, verify manifest completeness and hashes, verify the pinned Flutter/Dart versions and generated identifiers, inspect the expected APK/iOS archive structure, and upload partial evidence with `if: always()` when a native job fails.
- Reason: Makes P00-T03 evidence auditable and diagnostic without trusting a green job label or a filename.
- Consequences: A successful native CI job must pass `verify_phase0_evidence.py` before its bundle is accepted as build evidence. Partial failure bundles are diagnostic only and can never close P00-T03. Device/simulator launch evidence is still required separately.

## DEC-025 - Make hosted Phase 0 status explicit without closing the launch gate

- Date: 2026-08-07
- Context: Android and iOS CI jobs can independently upload verified native bundles, but an owner reviewing one hosted run needs one deterministic record that shows source quality, both native job results, verifier state, and artifact digests together. A green build-only summary must not be confused with real device/simulator launch evidence.
- Decision: Add `scripts/write_phase0_gate_summary.py` and a final `phase0-summary` CI job. Native jobs publish their verified artifact SHA-256 values and verifier flags as job outputs; the final job always writes and uploads `P00_T03_HOSTED_GATE_SUMMARY.md` and surfaces it through `GITHUB_STEP_SUMMARY`.
- Reason: A single summary makes hosted evidence easier to review and prevents partial success from being mistaken for gate completion.
- Consequences: The summary reports whether verified hosted build evidence is ready, but it always states that Android and iOS launch evidence is still required before P00-T03 can move to DONE.

## DEC-026 - Accept verified hosted emulator/simulator launches as P00-T03 launch evidence

- Date: 2026-08-07
- Context: P00-T03 requires the app to launch on Android and iOS targets. The hosted CI already creates verified native artifacts, but the previous gate still depended on separately performed launch evidence. That left a manual gap even when GitHub-hosted Android and macOS runners can provide real emulator/simulator execution.
- Decision: Extend the repository-owned CI path so the Android job boots a headless API 35 AVD and launches the generated debug APK, while the macOS job installs and launches the generated Runner.app on an available iPhone simulator. Capture platform metadata, runtime state, screenshots, artifact/screenshot SHA-256 values, and separate launch manifests. Accept those launches for P00-T03 only when `verify_phase0_launch_evidence.py` passes for both platforms and the final hosted summary reports `P00-T03 gate-closing evidence ready: YES`.
- Reason: P00-T03 is a foundation runner/build/launch gate, not final physical-device certification. Verified hosted emulator/simulator execution provides reproducible cross-platform launch evidence while preserving later real-device QA requirements.
- Consequences: A workflow definition alone does not close P00-T03; an actual successful hosted/connected execution record is still mandatory. Physical Android/iOS devices remain part of later functional, performance, permission, accessibility, and release QA. No new third-party emulator GitHub Action is introduced.

## DEC-017 - Downloaded hosted-run evidence must be re-verified locally

**Status:** Accepted - 2026-08-07

GitHub Actions job success is not sufficient by itself. The connected execution script must bind the run to a pushed commit, download artifacts by exact run ID, re-run repository-owned Android/iOS build and launch verifiers, recompute retained SHA-256 values, and confirm the hosted summary contains the full commit SHA/ref and the same digests. Recording the evidence does not automatically mark P00-T03 DONE.

## DEC-018 - Guarded GitHub bootstrap is allowed inside P00-T03

- Date: 2026-08-07
- Status: Accepted
- Decision: An extracted ClearScan source bundle may use `scripts/bootstrap_phase0_github_repo.sh` to initialise git when needed, create or attach a GitHub repository, push the exact tested source commit, and dispatch the existing hosted P00-T03 gate.
- Safety: The command is plan-only by default. Remote creation/push requires explicit `--execute`; repository visibility is always explicit; existing unexpected `origin` remotes are never rewritten automatically; git author identity is never invented; tokens are never accepted on the command line.
- Rationale: The ChatGPT artifact ZIP intentionally has no `.git` metadata, while P00-T03 requires commit-bound hosted evidence. This closes the packaging-to-hosted-run gap without weakening the gate.
- Consequence: Checked-in bootstrap automation is preparation only. P00-T03 stays BLOCKED until real hosted build+launch evidence is downloaded, independently verified, reviewed, and recorded.
