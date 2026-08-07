# ClearScan Design System

Updated: 2026-08-07
Status: Visible source prototype in review; source audit passed and runtime accessibility review remains required
Reference: `assets/reference/clearscan_ui_reference.png`

## Principles

- Original, not a clone of any competitor
- Clear and professional
- Privacy-forward
- Accessible by default
- Consistent across management and editing contexts
- Reusable components before screen-specific styling

## Colour tokens

Current source: `lib/app/theme/app_colors.dart`

| Token | Value | Intended use |
|---|---:|---|
| primary | `#16B8A6` | Main actions, selected states, scan guidance |
| primaryDark | `#0D8F82` | Pressed/strong primary states |
| primarySoft | `#E3F8F5` | Selected navigation and primary-tinted surfaces |
| primaryMuted | `#BEEDE7` | Soft scan guidance and supporting accents |
| navy | `#071826` | Camera and editing workspace background |
| navySurface | `#0C2233` | Workspace panels and controls |
| navyElevated | `#123047` | Raised dark-workspace controls |
| canvas | `#F5F8FA` | Light application background |
| surface | `#FFFFFF` | Cards and elevated content |
| surfaceMuted | `#EDF3F6` | Document previews and neutral wells |
| textPrimary | `#101820` | Main light-theme text |
| textSecondary | `#5E6B75` | Supporting text |
| border | `#D9E2E8` | Dividers and card outlines |
| info | `#3D8BFF` | Informational state |
| warning | `#F59E42` | Caution and recoverable warnings |
| destructive | `#E5484D` | Delete and destructive error state |
| success | `#1F9D6A` | Completed and healthy states |
| workspaceText | `#F7FAFC` | Main dark-workspace text |
| workspaceMuted | `#9DB0BE` | Secondary dark-workspace text |

Values are provisional until Phase 1 contrast and visual tests are completed.

## Theme behaviour

- Light theme: onboarding, home, documents, folders, search, settings, account
- Dark workspace theme: camera, crop, filters, editing, document preview
- Dark theme is not yet a user-selectable global appearance setting
- Transitions must preserve navigation context and unsaved work where practical

## Typography

Phase 0 uses platform typography. Phase 1 must select a commercially usable font or retain system fonts after accessibility and performance review.

Required named styles:

- Display heading
- Page title
- Section title
- Card title
- Body
- Secondary body
- Caption
- Button label
- Input label
- Error text

## Spacing

Current source: `lib/app/theme/app_spacing.dart`

- 4, 8, 12, 16, 20, 24, 32, 40, 48 logical pixels
- Additional values require a documented exception

## Radius

Current source: `lib/app/theme/app_radius.dart`

- Small: 8
- Medium: 12
- Large: 18
- Extra large: 24
- Pill: 999

## Shadows

To be finalised in Phase 1. Prefer subtle elevation and outlines over heavy shadows. Camera and editor surfaces should avoid decorative depth that competes with document content.

## Icons

- Use a consistent icon family
- Icons require semantic labels when their meaning is not already announced
- Do not copy proprietary competitor icons
- Branded third-party icons are only used where their service is explicitly integrated and permitted

## Required reusable components

- Primary, secondary, text, icon, and destructive buttons
- Search field
- Quick-action card
- Document card
- Folder card
- Page thumbnail
- Filter thumbnail
- Bottom navigation
- Editor toolbar
- Modal sheet
- Confirmation dialog
- Loading state
- Empty state
- Error state
- Live status announcement
- Adaptive max-width content frame
- Empty state
- Settings row
- Permission explanation
- Subscription card for later phase

## Accessibility

- Minimum practical touch target: 48 x 48 logical pixels
- Text and controls must meet applicable WCAG contrast targets
- Status cannot depend on colour alone
- Support screen readers and text scaling
- Camera guidance must have non-colour cues
- Motion must not be required to understand task status
- Destructive actions require clear labels and confirmation where data loss is possible

## Responsive behaviour

- Phone layouts are primary
- Tablet layouts may increase content width, columns, and preview area without stretching controls
- Use safe areas and keyboard-aware layouts
- Test portrait and relevant landscape workflows


## Implemented prototype components

The current source prototype includes:

- Four-destination bottom application navigation
- Prominent central scan action
- Home header, search field, privacy banner, quick-action cards, recent document list, and storage card
- Reusable document list tile and section header
- Documents filtering shell
- Responsive folder grid
- Settings panels and adaptive switches
- Dark scanner workspace, scan mode chips, document frame, capture control, and prototype disclosure
- Dark document viewer with responsive phone/tablet page rails, centered paper preview, and bottom action bar
- Dark multi-page editor with selected-page emphasis, temporary page operations, editor toolbar, and persistent prototype disclosure
- Reusable mock document-page visual used by viewer and editor prototypes
- Dark crop-adjustment workspace with four draggable corners, reset/apply actions, alignment grid, and non-processing disclosure
- Dark filter-selection workspace with Original, Auto, Colour, Grayscale, B&W, Clarity, and Low-light options plus temporary intensity preview
- Per-page temporary crop/filter status chips inside the multi-page editor
- Dark PDF export-options workspace using grouped setting cards, radio choices, chips, sliders, filename input, and an illustrative estimate card
- Dark OCR text workspace using a clear ready → processing → editable result progression with language selection and action controls
- Light Search workspace with a prominent disclosure, query field, file-type choices, favorite filter, folder selector, result count, document cards, and no-result state
- Folder-management pattern with a visible temporary-state disclosure, responsive cards, search, reusable create/edit sheet, four token-based colour choices, action sheet, safe-remove confirmation, and persistent-on-screen status feedback
- Light onboarding preview with a reusable page frame, value cards, privacy points, camera-permission education, progress indicators, and continue-without-account controls
- Documents Library controls with token-based list/grid presentation, sorting sheet, filter chips, selection toolbar, status feedback, empty state, and a safe Recently Deleted workspace
- Settings-detail pattern with grouped preference rows, reusable choice sheet, illustrative storage breakdown, selectable cleanup preview, privacy principles, adaptive toggles, and persistent session-status feedback

These components are source-complete only. Flutter runtime, text scaling, semantics, contrast, and representative device review remain required.


## Settings prototype pattern

- Preference rows use one reusable light modal sheet and token-based selected states.
- Storage values are labelled illustrative and never imply real device inspection.
- Cleanup requires explicit category selection and repeatedly states that no cache, document, database record, OCR text, or device file is deleted.
- Privacy details separate product principles from temporary diagnostics and crash-report choices.
- Every applied change produces a visible status message explaining that the state is session-only and unsaved.
- Runtime review must verify bottom-sheet height, keyboard/text-scale behaviour, focus order, switch semantics, and destructive-language clarity.


## Support and legal content pattern

- Help pages use the light management theme, a visible prototype notice, bordered FAQ cards, and one clearly labelled feedback-draft form.
- Support destinations that do not exist must use an external-action icon plus explicit placeholder feedback; they must not silently fail or imply a message was sent.
- About, Privacy Policy, and Terms use one reusable content-page pattern with a coloured header card, metadata, readable bordered sections, and a persistent legal-review warning.
- Draft policy/terms content must never look approved: the warning, draft date, and external-action placeholder remain visible in source and tests.
- Long content must use a scrollable layout and central spacing, colour, radius, and typography tokens only.

## Scanner permission and capture-review prototype pattern

- Permission education uses one centered dark state card with icon, plain-language explanation, one primary action, and optional recovery/import actions.
- Camera-ready, permission-needed, denied, permanently-denied, and unavailable states must be distinguishable by text and icon rather than colour alone.
- A persistent scanner notice states that no camera, permission, gallery, settings page, or device file is accessed.
- Import choices use a dark bottom sheet with Photo library, Files, and Sample document options; every option remains a local preview.
- Capture review reuses the dark workspace and mock document page, displays source and scan-mode metadata, and exposes crop/filter review without saving output.
- Keep/retake actions must produce explicit session feedback and must not imply an image was created.
- Runtime review must cover short-height layouts, large text, bottom-sheet overflow, state transitions, camera-safe-area handling, semantics, and focus order.

## Scanner capture-session prototype

- Auto-capture education uses a modal sheet rather than implying an operating-system or camera setting.
- Auto-capture state must include text stating that no frames are analysed and no capture is triggered.
- Captured-page thumbnails are generated visual placeholders, show an explicit page number, and use border plus semantics for selection rather than colour alone.
- The page strip exposes count, select, review, remove, and add-page actions without claiming persistence.
- Removing a page requires confirmation and states that no device file or saved document is deleted.
- Existing permission, import, crop, filter, and mode controls remain available around the temporary session flow.

## Scanner session-completion prototype

- Finish Session appears only when at least one temporary page exists.
- Completion uses the dark workspace theme and groups document details, page order, page summary, and save-preview feedback into separate raised sections.
- Page reorder provides both drag handles and labelled move-up/move-down controls; order must not rely on drag gestures alone.
- Title and folder choices remain local presentation state, and folder selection always states that no library assignment occurs.
- Save preview requires an explicit confirmation and a persistent result card stating that no document, database record, folder assignment, image, or PDF was created.
- Returning to Scanner may return reordered mock page objects and status text, but it must not close the scanner as though a document were saved.
- Runtime review must cover keyboard insets, long titles, large page counts, reorder semantics, 200% text scale, short-height layouts, and back-navigation expectations.

## Slice 14 accessibility and responsive baseline

- Material controls use padded tap targets with a 48 logical-pixel minimum where theme APIs allow.
- Status changes must use text and icon cues, not colour alone, and should be exposed as semantic live regions.
- Loading, empty, and error states use the shared `PrototypeStatePanel`.
- Read-heavy screens use `AdaptiveContentFrame` to avoid excessively wide tablet layouts.
- Narrow widths and enlarged text may stack primary/secondary actions vertically.
- Temporary scanner pages require explicit discard confirmation before leaving the scanner route.
- These are source-level safeguards only; TalkBack, VoiceOver, keyboard, contrast, overflow, and 200% text behaviour remain runtime acceptance tests.
