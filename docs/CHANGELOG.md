# Changelog




## 2026-08-07 - P00-T03 extracted-bundle GitHub bootstrap

- Added a guarded plan-first script that can initialise git, create/attach an explicitly visible GitHub repository, push the exact commit, and hand off to the hosted P00-T03 gate.
- Added contract coverage proving plan-only mode does not create `.git`, invalid visibility is rejected, token arguments are prohibited, and create/push/commit-binding/gate handoff logic remains present.
- Added the bootstrap contract to offline checks, the P00-T03 probe, required-file validation, connected-host documentation, and continuity records.
- Hardened P00-T03 connectivity probing with a hard subprocess timeout so blocked DNS cannot hang readiness evidence collection.
- P00-T03 remains BLOCKED because this sandbox still has no GitHub authentication or native Flutter toolchain execution evidence.

## 2026-08-07 - P00-T03 connected execution bundle

- Added `run_phase0_github_gate.sh` for authenticated GitHub workflow dispatch/watch/download/verification without accepting tokens as arguments.
- Added `verify_phase0_downloaded_run.py` to independently re-verify all downloaded Android/iOS build and launch evidence and bind it to the hosted summary.
- Added idempotent `record_phase0_hosted_run.py` for verified evidence recording without automatic task closure.
- Added synthetic downloaded-run and GitHub execution-contract tests.
- Hosted summary now records full Git commit SHA and Git ref.
- P00-T03 remains BLOCKED until the workflow actually runs on a connected repository and the verified record is reviewed.

All notable ClearScan project changes are recorded here.

## Unreleased - 2026-08-07

### Added

- Hosted Android API 35 emulator launch evidence after the real debug APK build, including adb activity state, target metadata, screenshot, separate manifest, and verified screenshot/artifact hashes
- Hosted iPhone simulator launch evidence after the real iOS simulator build, including `simctl` install/launch, app-container proof, target metadata, screenshot, separate manifest, and verified screenshot/artifact hashes
- Cross-platform Phase 0 launch-report writer and launch-evidence verifier with positive, tamper, and wrong-identifier contract tests
- Local Android/iOS launch-capture scripts reusable outside CI on connected targets
- Final hosted summary state `P00-T03 gate-closing evidence ready` that requires both verified builds and both verified launches
- Single hosted P00-T03 gate-summary artifact and GitHub Actions step summary that combine source-quality, Android, iOS, verifier, and SHA-256 results without pretending device-launch evidence is complete
- Contract tests for hosted gate summaries, including incomplete-build and missing-digest rejection paths
- Completed Phase 0 native-evidence bundle verifier for Android APK and iOS simulator artifacts, including manifest completeness, SHA-256, pinned Flutter/Dart, generated identifiers, and archive-structure checks
- Contract tests that prove valid Android/iOS evidence passes and tampered evidence is rejected
- CI toolchain/build log retention so failed native jobs still upload partial evidence for diagnosis
- P00-T03 non-destructive environment probe with JSON/Markdown evidence for source checks, tool availability, native runners, and official-release connectivity
- Central Dart `3.12.2` pin cross-checked against the official Flutter `3.44.8` release manifest
- Final visible-UI source audit with reusable adaptive content frame, loading/empty/error panel, and live status-announcement components
- Scanner unsaved-exit confirmation for temporary captured pages with explicit Stay and Discard choices
- Documents Library loading, empty, error, and content-state previews with safe retry education
- Responsive completion/onboarding action stacking, keyboard-safe scanner/completion sheets, and theme-level padded touch targets
- `docs/UI_AUDIT.md` with cross-screen source findings and mandatory Flutter runtime evidence
- Scan-session completion workspace with temporary title, folder choice, page summary, drag handles, explicit move controls, return-to-scanner, and safe save preview
- Typed completion result that returns reordered mock pages and preview metadata to the active scanner session without persistence
- Scanner widget-test source covering two-page completion, title/folder changes, reorder, save preview, and safe return
- Auto-capture education sheet with session-only on/off, stability guidance, edge guidance, and explicit no-frame-analysis disclosure
- Temporary capture-session page model and generated thumbnail strip with page count, selection, review/update, add-page, and safe removal actions
- Capture review support for numbered new pages and existing session-page updates
- Scanner widget-test source covering auto-capture settings and two-page session interactions
- Scanner permission-state prototype covering permission-needed, camera-ready, denied, permanently-denied/settings guidance, and camera-unavailable states
- Safe import-source sheet for Photo library, Files, and Sample document without reading device storage
- Mock capture-review workspace with source/mode metadata, crop/filter navigation, retake, and keep-page session feedback
- Scanner state-preview sheet and widget-test source for denied, permanent denial, import, review, and camera-ready transitions
- Interactive Settings preference sheets for default scan mode, image quality, default PDF size, and OCR language
- Session-only storage details with illustrative category breakdown and visible temporary-data total
- Cleanup preview with selectable preview cache, export draft, and OCR draft categories plus explicit no-deletion disclosure
- Privacy details sheet with local-first principles and temporary diagnostics/crash-report controls
- Settings widget-test source covering preference selection, storage review, cleanup simulation, and privacy preview state
- Settings-launched onboarding preview with Welcome, feature value, privacy explanation, and camera-permission education pages
- Continue-without-account flow that returns to the existing Home tab without adding first-run persistence
- Explicit camera-permission and sign-in placeholders that never request permission or authenticate
- Onboarding widget-test source covering Settings entry, page progression, permission education, sign-in placeholder, and return to Home
- Shared Search workspace connected from Home and Documents, with title/folder/type/favorite filtering over isolated mock data and an explicit no-OCR-index disclosure
- Temporary folder-management flow with local search, create, rename, recolour, session-only status feedback, and safe removal that never claims to delete documents
- Mock folder metadata on document list tiles so Search results explain their folder match
- Search and folder-management widget-test source covering shared entry points, filters, create/edit/colour, and safe removal
- Dark PDF export-options workspace with temporary page scope, page size, orientation, margin, quality, filename, and illustrative size estimate controls
- OCR text workspace with language selection, ready/processing/result states, editable mock text, clipboard copy, share placeholder, and reset action
- Document Viewer navigation into PDF and OCR workspaces
- PDF/OCR widget-test source covering open, temporary interaction, processing, result, and return-to-viewer flows
- Dark crop-adjustment workspace with four draggable corners, reset/apply controls, alignment grid, and explicit no-processing disclosure
- Dark filter-selection workspace with Original, Auto, Colour, Grayscale, B&W, Clarity, and Low-light choices plus intensity preview
- Temporary per-page crop and filter status inside the multi-page editor
- Crop/filter widget-test source covering open, interaction, apply, status, and return-to-editor flow
- Responsive dark document viewer with mock page preview and horizontal/tablet page navigation
- Document viewer action bar for Share, PDF, OCR, Edit pages, and More with honest planned-feature messages
- Multi-page editor prototype with temporary page selection, add, duplicate, rotate, and delete state
- Reusable mock document-page preview component
- Documents and Home recent-document navigation into the viewer
- Viewer/editor widget-test source covering open, edit, add-page, and close flows
- Real four-destination application shell with a prominent central scan action
- Original Home screen with search, privacy banner, quick actions, recent documents, and storage summary
- Documents, Folders, and Settings screens backed by isolated mock data
- Dark scanner workspace prototype with scan modes, document guide, and explicit camera-integration disclosure
- Reusable section header and document-list tile components
- Startup, navigation, and scanner-opening widget test source
- Initial ClearScan source repository structure
- Central app name, tagline, environment, and feature flags
- Foundation light and dark workspace themes
- Colour, spacing, and radius tokens
- Minimal Flutter application shell
- Foundation startup widget test
- Feature-first module directories
- Complete project documentation and continuity system
- Local validation and Flutter bootstrap scripts
- Approved UI direction image in project assets
- Central platform-generation settings in `tool/project.env`
- Environment-doctor script for toolchain readiness
- Reproducible Android/iOS bootstrap procedure
- GitHub Actions format, analysis, and test workflow
- Detailed development-environment and continuation guide
- Stronger repository, task, handoff, and identifier validation
- Exact Flutter `3.44.8` version pin shared by local tooling and CI
- Resumable Linux Flutter SDK installer under `scripts/install_flutter_sdk.sh`
- Offline Phase 0 source-contract validation
- Generated Android/iOS runner identifier verifier
- Timestamped Phase 0 evidence-capture script
- Permanent Phase 0 evidence record and gate checklist
- Separate CI jobs for source quality, Android debug builds, and iOS simulator builds

### Changed

- Hardened Android/iOS CI jobs to capture exact toolchain evidence, verify successful native evidence bundles, and upload partial logs even when a build step fails
- Unified `install_flutter_sdk.sh` with the verified Python installer so offline `--archive-file` and `--manifest-file` arguments are no longer ignored
- Strengthened repository validation for installer argument forwarding and host-runner options
- Connected the Home and Documents search fields to one Flutter SDK Search workspace
- Converted the Folders screen from static mock cards to an isolated session-only management prototype
- Began the owner-directed visible UI prototype while preserving the unresolved Phase 0 native verification gate
- Closed P00-T02 after its source-level acceptance criteria passed
- Expanded native bootstrap and local checks to verify generated platform identifiers

### Fixed

- None

### Removed

- None

### Security

- Added secret and signing-file ignore rules
- Documented no-content logging and app-private storage requirements


## 2026-08-06 - UI Slice 8

### Added

- Scanner permission-state prototype covering permission-needed, camera-ready, denied, permanently-denied/settings guidance, and camera-unavailable states
- Safe import-source sheet for Photo library, Files, and Sample document without reading device storage
- Mock capture-review workspace with source/mode metadata, crop/filter navigation, retake, and keep-page session feedback
- Scanner state-preview sheet and widget-test source for denied, permanent denial, import, review, and camera-ready transitions
- Documents Library list/grid view switching and three temporary sort modes
- Session-only favorites, multi-select, select-all, and bulk actions
- Recently Deleted preview with restore and preview-only permanent removal
- Responsive document grid cards and library empty/status states
- Widget-test source and static contracts for the complete temporary library flow

### Changed

- Document summaries now support immutable `copyWith` updates for presentation state
- Document list tiles now expose selection and long-press states


## 2026-08-07 - UI Slice 9

### Added

- Scanner permission-state prototype covering permission-needed, camera-ready, denied, permanently-denied/settings guidance, and camera-unavailable states
- Safe import-source sheet for Photo library, Files, and Sample document without reading device storage
- Mock capture-review workspace with source/mode metadata, crop/filter navigation, retake, and keep-page session feedback
- Scanner state-preview sheet and widget-test source for denied, permanent denial, import, review, and camera-ready transitions
- Session-only Settings choices for scan mode, image quality, PDF size, and OCR language
- Storage details and cleanup preview sheets with illustrative values and no device-data mutation
- Privacy details sheet with temporary diagnostics and crash-report controls
- Persistent-on-screen session status explaining every temporary change
- Widget-test source and static contracts for the full Settings interaction flow

### Changed

- Settings now separates Scanning, Export and text, Privacy and storage, Experience preview, and Support groups
- Storage summary updates only inside the active Settings session after simulated cleanup


## 2026-08-07 - UI Slice 10

### Added

- Scanner permission-state prototype covering permission-needed, camera-ready, denied, permanently-denied/settings guidance, and camera-unavailable states
- Safe import-source sheet for Photo library, Files, and Sample document without reading device storage
- Mock capture-review workspace with source/mode metadata, crop/filter navigation, retake, and keep-page session feedback
- Scanner state-preview sheet and widget-test source for denied, permanent denial, import, review, and camera-ready transitions
- Help and Feedback workspace with sample FAQs, support-action placeholders, category selection, optional reply-email preview, message draft, and non-submitting feedback preview
- About ClearScan screen with centrally configured version label, product direction, prototype status, and principles
- Draft Privacy Policy and Terms content screens with visible legal-review warnings and safe external-action placeholders
- Settings navigation for Help, Privacy Policy, Terms, and About
- Widget-test source and static contracts covering support drafts, placeholder actions, and legal-content warnings

### Changed

- Settings Support group is now interactive and renamed Support and legal
- App version and release label are stored centrally in `AppConfig`
