# ClearScan QA Checklist


## P00-T03 production-gate probe

- [x] Exact Flutter `3.44.8` release resolves from checked-in official-manifest fixture
- [x] Bundled Dart `3.12.2` matches the central Dart pin
- [x] Installer rejects a manifest with a mismatched Dart version
- [x] Shell installer forwards offline archive/manifest arguments to the verified Python installer
- [x] Blocked-host probe captures static checks, tools, runners, and connectivity without mutating the project
- [x] Current sandbox blocker is recorded in `docs/P00_T03_PROBE_2026-08-07.md`
- [x] Native CI evidence verifier validates manifest completeness, SHA-256 hashes, toolchain pins, identifiers, and APK/iOS archive structure
- [x] Android/iOS CI jobs retain partial evidence logs on failure and verify successful bundles before upload acceptance
- [x] Hosted CI publishes a single P00-T03 summary with source/native results, verifier flags, artifact names, and SHA-256 values
- [x] Hosted gate-summary contract rejects successful verified builds that omit required artifact digests
- [x] Android launch-capture script verifies real adb install/start/activity state, target metadata, screenshot, and artifact hash
- [x] iOS launch-capture script verifies real `simctl` install/start/app-container state, simulator metadata, screenshot, and artifact hash
- [x] Launch-evidence verifier synthetic Android/iOS contracts pass and reject tampered screenshots/wrong identifiers
- [x] Hosted gate summary distinguishes build readiness, launch readiness, and final P00-T03 gate-closing evidence readiness
- [ ] Run exact Flutter format/analyze/widget tests on a connected host
- [ ] Generate official Android and iOS runners
- [ ] Build and launch Android
- [ ] Build and launch iOS on macOS

Updated: 2026-08-07

Mark each item with `[x]` only after evidence is recorded.

## Foundation

- [x] Required repository files exist
- [x] Required documentation files exist
- [x] Central app configuration exists
- [x] Theme-token baseline exists
- [x] Startup test source exists
- [x] Generated-platform identifier verifier exists
- [x] Android and iOS CI build jobs exist
- [x] Phase 0 evidence-capture procedure exists
- [ ] Native Android runner generated
- [ ] Native iOS runner generated
- [ ] Generated Android application ID verified
- [ ] Generated iOS bundle ID verified
- [ ] `dart format` passes
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Android debug APK builds
- [ ] iOS simulator application builds
- [ ] Application launches on Android emulator/device
- [ ] Application launches on iOS simulator/device

## Visible UI source audit

- [x] Reusable loading, empty, and error state component exists
- [x] Reusable live status-announcement component exists
- [x] Adaptive max-width content pattern exists
- [x] Scanner temporary-page exit requires explicit confirmation
- [x] Library loading/error recovery states have safe disclosures
- [x] Theme defines padded Material touch targets
- [x] Large-text action stacking exists for onboarding and completion
- [x] Source-level UI audit report exists
- [ ] Runtime overflow audit completed
- [ ] 200% text-scale audit completed
- [ ] TalkBack audit completed
- [ ] VoiceOver audit completed

## Functional testing

- [ ] Onboarding
- [ ] Home and quick actions
- [ ] Capture and import
- [ ] Crop and perspective correction
- [ ] Filters and adjustments
- [ ] Multi-page editing
- [ ] Local persistence
- [ ] PDF export
- [ ] Image export
- [ ] Native sharing
- [ ] OCR
- [ ] Search
- [ ] Folder management
- [ ] Settings
- [ ] Backup and restore when implemented

## Permission testing

- [ ] Camera allowed
- [ ] Camera denied
- [ ] Camera permanently denied
- [ ] Photos/media allowed
- [ ] Photos/media limited where supported
- [ ] Photos/media denied
- [ ] Permission changed while app is backgrounded

## Device and layout testing

- [ ] Small Android phone
- [ ] Large Android phone
- [ ] iPhone compact size
- [ ] iPhone large size
- [ ] Android tablet
- [ ] iPad
- [ ] Text scaling
- [ ] Portrait
- [ ] Relevant landscape workflows
- [ ] Safe areas and display cutouts

## Accessibility

- [ ] Screen-reader labels
- [ ] Logical focus order
- [ ] Contrast
- [ ] Touch targets
- [ ] Colour-independent status
- [ ] Reduced-motion behaviour where applicable
- [ ] Keyboard support on tablet where applicable

## Performance

- [ ] Camera startup
- [ ] Capture latency
- [ ] Edge-overlay stability
- [ ] Large-image processing
- [ ] Ten-page document
- [ ] Fifty-page document
- [ ] Thumbnail loading
- [ ] Memory pressure
- [ ] Background/foreground recovery

## Storage and offline

- [ ] App-private storage
- [ ] Low-storage warning
- [ ] Interrupted save recovery
- [ ] Trash and permanent deletion
- [ ] Orphan-file cleanup
- [ ] Full offline workflow
- [ ] Migration from previous schema

## Export

- [ ] PDF page sizes
- [ ] Orientation
- [ ] Margins
- [ ] Image quality
- [ ] Selected pages
- [ ] All pages
- [ ] Filename sanitisation
- [ ] Standard viewer compatibility
- [ ] Share-sheet cancellation
- [ ] Export interruption

## OCR

- [ ] Supported language quality
- [ ] Low-confidence state
- [ ] Rerun OCR
- [ ] Edit extracted text
- [ ] Search edited text
- [ ] No OCR content in production logs

## Security and privacy

- [ ] No silent upload
- [ ] Secure token storage
- [ ] Private backup objects
- [ ] Account deletion
- [ ] Data export
- [ ] Sensitive log review
- [ ] Imported file validation
- [ ] Dependency vulnerability review

## Release

- [ ] Versioning
- [ ] Signing
- [ ] Store metadata
- [ ] Screenshots
- [ ] Privacy policy
- [ ] Terms
- [ ] Support contact
- [ ] Crash reporting consent and configuration
- [ ] Release notes
- [ ] Rollback plan


## Owner-directed visible UI prototype

- [x] Home, Documents, Folders, Settings, and scanner workspace source created
- [x] Navigation and scanner-opening widget test source created
- [x] Non-functional live camera state is clearly disclosed in the UI
- [x] Static source contracts and central colour-token policy pass
- [x] Document viewer and multi-page editor source created
- [x] Mock document open/edit/add-page/close widget test source created
- [x] Viewer and editor explicitly disclose mock and non-persistent behaviour
- [x] Crop-adjustment and filter-selection workspace source created
- [x] Four crop handles, seven filter options, intensity preview, and temporary editor status are statically validated
- [x] Crop/filter open, interact, apply, and return widget-test source created
- [x] Crop and filter screens explicitly disclose that real image processing and persistence are unavailable
- [x] PDF export-options and OCR text-workspace source created and connected from the Document Viewer
- [x] PDF controls cover page scope, size, orientation, margin, quality, filename, and illustrative estimate
- [x] OCR source covers language, ready, processing, editable result, copy, share placeholder, and reset states
- [x] PDF and OCR screens explicitly disclose that no real file, OCR engine, or saved text exists
- [x] PDF/OCR open, interact, process, result, and return widget-test source created
- [x] Shared Search workspace source connected from Home and Documents
- [x] Search source covers title/folder/type/favorite filtering, result count, reset, and no-result state
- [x] Search explicitly discloses that OCR indexing, recent history, and persisted search are unavailable
- [x] Temporary folder search, create, rename, recolour, and safe-remove source created
- [x] Folder removal explicitly states that documents and device storage remain unchanged
- [x] Search and folder-management widget-test source created
- [x] Settings-launched onboarding preview source created
- [x] Welcome, feature value, privacy, and camera-permission education pages are statically validated
- [x] Permission and sign-in actions explicitly disclose that no real permission or authentication occurs
- [x] Continue-without-account returns to the existing Home tab without first-run persistence
- [x] Onboarding open, progress, permission-preview, sign-in-placeholder, and return-to-Home widget-test source created
- [ ] Run `dart format`
- [ ] Run `flutter analyze`
- [ ] Run widget tests
- [ ] Review phone and tablet layouts
- [ ] Review 200% text scaling and screen-reader semantics
- [ ] Capture Android and iOS screenshots


## Documents Library prototype

- [x] Static contract covers list/grid switching, sorting, favorites, multi-select, bulk delete, Recently Deleted, restore, and permanent-remove disclosures.
- [x] Widget-test source covers grid/list, title sort, favorites filter, two-item selection, bulk favorite, temporary deletion, restore, and preview removal.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review grid breakpoints, toolbar wrapping, sort sheet, and Recently Deleted at 200% text scale.
- [ ] Verify semantics and focus order for selection checkboxes and destructive actions.
- [ ] Verify persisted trash and restore behavior after Phase 3 repositories exist.


## Settings prototype

- [x] Static contract covers default scan mode, image quality, PDF size, OCR language, storage details, cleanup, privacy details, and session-status feedback.
- [x] Widget-test source covers selecting Book, Maximum quality, US Letter, Bengali OCR, reviewing storage, simulating 6 MB cleanup, and enabling privacy preview choices.
- [x] Cleanup disclosure states that cache, documents, OCR text, database records, and device files are unchanged.
- [x] Privacy disclosure states that no analytics, crash service, permission, upload, or saved consent is connected.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review choice, storage, cleanup, and privacy sheets at 200% text scale and on short-height devices.
- [ ] Verify switch, list-tile, selected-state, and status-message semantics with a screen reader.
- [ ] Verify actual persistence, cleanup transactions, storage accounting, and consent behaviour after Phase 11 repositories/services exist.


## Support and legal content prototype

- [x] Settings exposes Help, Privacy Policy, Terms, and About entries.
- [x] Help source contains FAQs, category, optional email preview, message draft, and explicit non-submission feedback.
- [x] Email, help-centre, bug-report, policy-contact, terms-contact, and licence actions are safe placeholders.
- [x] Privacy Policy states that it is not final or legally approved.
- [x] Terms state that they do not form a contract.
- [x] App version and release label are centralised in `AppConfig`.
- [x] Widget-test source covers Help draft, support placeholder, Privacy Policy, Terms, and About navigation.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review FAQ expansion, long policy sections, form keyboard insets, and external placeholder feedback at 200% text scale.
- [ ] Review legal content with qualified counsel before release.
- [ ] Approve real support contact, privacy contact, terms contact, licences, retention, and submission handling.

## Scanner permission/import/capture-review prototype

- [x] Static contract covers permission-needed, camera-ready, denied, permanently-denied, and unavailable states.
- [x] Static contract covers safe Photo library, Files, and Sample document import choices.
- [x] Capture review explicitly states that no image is captured, imported, processed, or saved.
- [x] Capture review connects to the existing crop and filter prototypes without persistence.
- [x] Widget-test source covers denial, permanent denial, import sheet, mock review, keep-page feedback, state selector, and camera-ready capture transition.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review all permission and fallback states at 200% text scale and on short-height devices.
- [ ] Verify screen-reader labels, focus order, bottom-sheet dismissal, disabled flash state, and status announcements.
- [ ] Verify real permission denial, permanent denial, settings return, camera unavailable, import validation, and capture lifecycle after Phase 4 services exist.

## Scanner auto-capture and capture-session prototype

- [x] Static contract covers auto-capture sheet, on/off, stability, edge guidance, apply action, and no-frame-analysis disclosure.
- [x] Static contract covers session page model, count, generated thumbnails, selection, review, add, remove, and no-file disclosure.
- [x] Widget-test source covers enabling auto-capture preview, adding two mock pages, reviewing page one, and removing it with confirmation.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review strip height, horizontal scrolling, bottom controls, and modal sheets on short-height and landscape devices.
- [ ] Review 200% text scale, page-selection semantics, non-colour cues, focus order, status announcements, and destructive confirmation.
- [ ] Verify real stability/edge thresholds, capture latency, duplicate prevention, lifecycle interruption, and persisted page recovery after Phase 4 services exist.

## Scanner session-completion prototype

- [x] Static contract covers Finish Session entry, temporary title, folder sheet, page summary, drag reorder, move-up/down controls, save confirmation, result card, and return-to-scanner.
- [x] Save-preview disclosure states that no document, database record, folder assignment, image, or PDF is created.
- [x] Widget-test source covers two mock pages, title editing, Work folder selection, moving page one down, save preview, and scanner return feedback.
- [ ] Run Flutter widget tests on the pinned SDK.
- [ ] Review keyboard-open, long-title, many-page, short-height, landscape, and 200% text-scale layouts.
- [ ] Verify reorder semantics, drag-handle focus, arrow-button labels, status announcements, and back-navigation with a screen reader.
- [ ] Verify real title validation, duplicate naming, folder existence, low storage, atomic save, rollback, interruption recovery, and persisted page order after Phase 3/7 repositories exist.

## P00-T03 downloaded hosted-run QA

- [ ] Dispatch/watch uses the exact pushed commit SHA.
- [ ] Downloaded Android build evidence verifier passes.
- [ ] Downloaded Android launch evidence verifier passes.
- [ ] Downloaded iOS build evidence verifier passes.
- [ ] Downloaded iOS launch evidence verifier passes.
- [ ] Hosted summary commit SHA/ref match the run.
- [ ] Recomputed four SHA-256 values match the hosted summary.
- [ ] `P00_T03_VERIFIED_HOSTED_RUN.json` reports `evidence_ready: true`.
- [ ] `docs/PHASE0_EVIDENCE.md` is recorded only after manual warning/runtime review.

## P00-T03 GitHub bootstrap QA

- [x] Plan-only mode makes no `.git` or GitHub mutation.
- [x] Repository visibility must be explicitly private, public, or internal.
- [x] Invalid repository visibility is rejected.
- [x] No GitHub token argument or embedded token variable is accepted.
- [x] Existing unexpected `origin` remote is refused rather than rewritten.
- [x] New first commit requires user-configured git author identity.
- [x] Repository-owned offline checks run before publication.
- [x] Pushed commit is verified through GitHub before hosted gate handoff.
- [ ] Execute the bootstrap on an authenticated connected host.
- [ ] Review GitHub repository visibility and branch before the first hosted run.
- [ ] Confirm the hosted run returns gate-closing build+launch evidence.
