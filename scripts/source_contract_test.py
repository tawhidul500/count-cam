from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def main() -> int:
    errors: list[str] = []

    dart_files = sorted((ROOT / 'lib').rglob('*.dart'))
    if not dart_files:
        errors.append('No Dart source files were found under lib/.')

    forbidden_color_pattern = re.compile(r'Color\(0x[0-9A-Fa-f]{8}\)')
    for path in dart_files:
        relative = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding='utf-8')
        if relative != 'lib/app/theme/app_colors.dart' and forbidden_color_pattern.search(text):
            errors.append(f'Hard-coded ARGB colour found outside AppColors: {relative}')

    app_config = read('lib/app/configuration/app_config.dart')
    required_config_fragments = (
        "appName = 'ClearScan'",
        "tagline = 'Smart Scanner. Better Documents.'",
        'cloudSyncEnabled = false',
        'premiumEnabled = false',
    )
    for fragment in required_config_fragments:
        if fragment not in app_config:
            errors.append(f'AppConfig is missing required fragment: {fragment}')

    app_source = read('lib/app/app.dart')
    for fragment in (
        'title: AppConfig.appName',
        'debugShowCheckedModeBanner: false',
        'theme: AppTheme.light',
        'home: const AppShell()',
    ):
        if fragment not in app_source:
            errors.append(f'Application shell is missing required fragment: {fragment}')

    shell_source = read('lib/features/shell/presentation/app_shell.dart')
    for fragment in (
        'IndexedStack(',
        "Key('scan-fab')",
        "Key('home-tab')",
        "Key('documents-tab')",
        "Key('folders-tab')",
        "Key('settings-tab')",
        'ScannerScreen()',
        'SettingsScreen(onGoHome:',
    ):
        if fragment not in shell_source:
            errors.append(f'Navigation shell is missing required fragment: {fragment}')

    home_source = read('lib/features/home/presentation/home_screen.dart')
    for token in (
        'AppSpacing.',
        'AppRadius.',
        'AppColors.',
        'AppConfig.appName',
        'Quick actions',
        'Recent documents',
        "Key('home-open-search')",
        'SearchWorkspaceScreen()',
    ):
        if token not in home_source:
            errors.append(f'Home screen is missing required token or section: {token}')

    required_ui_files = (
        'lib/features/documents/presentation/documents_screen.dart',
        'lib/features/documents/presentation/document_viewer_screen.dart',
        'lib/features/documents/presentation/multi_page_editor_screen.dart',
        'lib/features/documents/presentation/widgets/mock_document_page.dart',
        'lib/features/documents/presentation/widgets/document_grid_card.dart',
        'lib/features/documents/presentation/recently_deleted_screen.dart',
        'lib/features/crop_editor/presentation/crop_adjustment_screen.dart',
        'lib/features/filters/presentation/filter_selection_screen.dart',
        'lib/features/export/presentation/pdf_export_options_screen.dart',
        'lib/features/ocr/presentation/ocr_text_workspace_screen.dart',
        'lib/features/share/presentation/share_options_screen.dart',
        'lib/features/search/presentation/search_workspace_screen.dart',
        'lib/features/documents/presentation/document_actions_sheet.dart',
        'lib/features/folders/presentation/folders_screen.dart',
        'lib/features/settings/presentation/settings_screen.dart',
        'lib/features/settings/presentation/settings_detail_sheets.dart',
        'lib/features/onboarding/presentation/onboarding_preview_screen.dart',
        'lib/features/scanner/presentation/scanner_screen.dart',
        'lib/features/scanner/presentation/scanner_import_source_sheet.dart',
        'lib/features/scanner/presentation/capture_review_screen.dart',
        'lib/features/scanner/presentation/auto_capture_settings_sheet.dart',
        'lib/features/scanner/presentation/scanner_session_page.dart',
        'lib/features/scanner/presentation/capture_session_page_strip.dart',
        'lib/features/scanner/presentation/scan_session_completion_screen.dart',
        'lib/core/widgets/adaptive_content_frame.dart',
        'lib/core/widgets/document_list_tile.dart',
        'lib/core/widgets/prototype_state_panel.dart',
        'lib/core/widgets/section_header.dart',
        'lib/core/widgets/status_announcement.dart',
    )
    for file_path in required_ui_files:
        if not (ROOT / file_path).is_file():
            errors.append(f'Missing visible UI source file: {file_path}')

    document_screen_source = read('lib/features/documents/presentation/documents_screen.dart')
    for fragment in (
        "Key('document-${document.id}')",
        "Key('document-grid-${document.id}')",
        'DocumentViewerScreen(document: document)',
        "Key('documents-open-search')",
        'SearchWorkspaceScreen()',
        "Key('documents-library-prototype-notice')",
        "Key('documents-view-list')",
        "Key('documents-view-grid')",
        "Key('documents-sort')",
        "Key('documents-sort-sheet')",
        "Key('documents-sort-title')",
        "Key('documents-filter-favorites')",
        "Key('documents-toggle-selection')",
        "Key('library-selection-toolbar')",
        "Key('favorite-selected-documents')",
        "Key('delete-selected-documents')",
        "Key('documents-open-recently-deleted')",
        "Key('documents-preview-states')",
        "Key('documents-state-preview-sheet')",
        "Key('documents-state-loading')",
        "Key('documents-state-error')",
        "Key('documents-loading-state')",
        "Key('documents-error-state')",
        'PrototypeStatePanel(',
        'No data request was made',
        'Database records and device files are unchanged',
    ):
        if fragment not in document_screen_source:
            errors.append(f'Documents screen is missing library prototype contract: {fragment}')

    recently_deleted_source = read(
        'lib/features/documents/presentation/recently_deleted_screen.dart'
    )
    for fragment in (
        "Key('recently-deleted-screen')",
        "Key('recently-deleted-prototype-notice')",
        "Key('deleted-document-${document.id}')",
        "Key('restore-deleted-${document.id}')",
        "Key('permanently-delete-${document.id}')",
        "Key('permanent-delete-dialog')",
        "Key('recently-deleted-empty')",
        'Device files and database records are unchanged',
    ):
        if fragment not in recently_deleted_source:
            errors.append(
                f'Recently Deleted is missing temporary-state contract: {fragment}'
            )

    viewer_source = read('lib/features/documents/presentation/document_viewer_screen.dart')
    for fragment in (
        "Key('document-viewer')",
        "Key('document-viewer-prototype-notice')",
        "Key('edit-document-pages')",
        'MultiPageEditorScreen(',
        'PdfExportOptionsScreen(',
        'OcrTextWorkspaceScreen(',
        'ShareOptionsScreen(',
        'DocumentActionsSheet(',
        "Key('open-share-options')",
        "Key('open-document-actions-appbar')",
        "Key('open-document-actions-more')",
        "Key('temporary-document-status')",
        "Key('open-pdf-export-options')",
        "Key('open-ocr-text-workspace')",
        'Viewer prototype — mock pages only',
    ):
        if fragment not in viewer_source:
            errors.append(f'Document viewer is missing required prototype contract: {fragment}')

    editor_source = read('lib/features/documents/presentation/multi_page_editor_screen.dart')
    for fragment in (
        "Key('multi-page-editor')",
        "Key('editor-prototype-notice')",
        "Key('add-editor-page')",
        "Key('open-crop-adjustment')",
        "Key('open-filter-selection')",
        'CropAdjustmentScreen(',
        'FilterSelectionScreen(',
        'changes are temporary and are not saved',
    ):
        if fragment not in editor_source:
            errors.append(f'Multi-page editor is missing required prototype contract: {fragment}')

    crop_source = read('lib/features/crop_editor/presentation/crop_adjustment_screen.dart')
    for fragment in (
        "Key('crop-adjustment-screen')",
        "Key('crop-prototype-notice')",
        "Key('crop-corner-$index')",
        "Key('apply-crop-prototype')",
        'no perspective correction or file changes are applied',
    ):
        if fragment not in crop_source:
            errors.append(f'Crop workspace is missing required prototype contract: {fragment}')

    filter_source = read('lib/features/filters/presentation/filter_selection_screen.dart')
    for fragment in (
        "Key('filter-selection-screen')",
        "Key('filter-prototype-notice')",
        "Key('apply-filter-prototype')",
        "Key('filter-option-${filter.keyName}')",
        'Original',
        'Auto',
        'Colour',
        'Grayscale',
        'B&W',
        'Clarity',
        'Low-light',
        'no real image processing or saved output exists yet',
    ):
        if fragment not in filter_source:
            errors.append(f'Filter workspace is missing required prototype contract: {fragment}')

    pdf_export_source = read(
        'lib/features/export/presentation/pdf_export_options_screen.dart'
    )
    for fragment in (
        "Key('pdf-export-options-screen')",
        "Key('pdf-export-prototype-notice')",
        "Key('pdf-pages-all')",
        "Key('pdf-pages-current')",
        "Key('pdf-page-size')",
        "Key('pdf-orientation-portrait')",
        "Key('pdf-orientation-landscape')",
        "Key('pdf-margin-slider')",
        "Key('pdf-quality-slider')",
        "Key('pdf-file-name')",
        "Key('pdf-estimated-output')",
        "Key('prepare-pdf-prototype')",
        'no PDF file is generated, saved, or shared',
    ):
        if fragment not in pdf_export_source:
            errors.append(f'PDF export workspace is missing required prototype contract: {fragment}')

    ocr_source = read('lib/features/ocr/presentation/ocr_text_workspace_screen.dart')
    for fragment in (
        "Key('ocr-text-workspace-screen')",
        "Key('ocr-prototype-notice')",
        "Key('ocr-language-selector')",
        "Key('ocr-ready-state')",
        "Key('run-mock-ocr')",
        "Key('ocr-processing-state')",
        "Key('ocr-result-state')",
        "Key('ocr-result-editor')",
        "Key('copy-ocr-text')",
        "Key('share-ocr-text-placeholder')",
        'no OCR engine reads a real page, and edited text is not saved',
    ):
        if fragment not in ocr_source:
            errors.append(f'OCR workspace is missing required prototype contract: {fragment}')

    share_source = read('lib/features/share/presentation/share_options_screen.dart')
    for fragment in (
        "Key('share-options-screen')",
        "Key('share-options-prototype-notice')",
        "Key('share-format-pdf')",
        "Key('share-format-images')",
        "Key('share-format-text')",
        "Key('share-pages-all')",
        "Key('share-pages-current')",
        "Key('share-selection-summary')",
        "Key('open-system-share-prototype')",
        'no exported file or platform share sheet is available',
    ):
        if fragment not in share_source:
            errors.append(f'Share workspace is missing required prototype contract: {fragment}')

    actions_source = read(
        'lib/features/documents/presentation/document_actions_sheet.dart'
    )
    for fragment in (
        "Key('document-actions-sheet')",
        "Key('document-actions-prototype-notice')",
        "Key('document-action-rename')",
        "Key('document-action-move')",
        "Key('document-action-favorite')",
        "Key('document-action-info')",
        "Key('document-action-delete')",
        'do not change device storage',
    ):
        if fragment not in actions_source:
            errors.append(
                f'Document action sheet is missing required prototype contract: {fragment}'
            )

    search_source = read('lib/features/search/presentation/search_workspace_screen.dart')
    for fragment in (
        "Key('search-workspace-screen')",
        "Key('search-prototype-notice')",
        "Key('search-query-field')",
        "Key('search-type-all')",
        "Key('search-type-pdf')",
        "Key('search-type-images')",
        "Key('search-favorites-filter')",
        "Key('search-folder-filter')",
        "Key('search-result-${document.id}')",
        "Key('search-empty-state')",
        'OCR indexing, recent-search history, and persisted search do not exist yet',
    ):
        if fragment not in search_source:
            errors.append(f'Search workspace is missing required prototype contract: {fragment}')

    folders_source = read('lib/features/folders/presentation/folders_screen.dart')
    for fragment in (
        "Key('folder-prototype-notice')",
        "Key('folder-search-field')",
        "Key('create-folder')",
        "Key('folder-card-${folder.id}')",
        "Key('folder-more-${folder.id}')",
        "Key('folder-actions-sheet')",
        "Key('folder-action-edit')",
        "Key('folder-action-delete')",
        "Key('folder-editor-sheet')",
        "Key('folder-name-field')",
        "Key('folder-color-$index')",
        "Key('save-folder-prototype')",
        "Key('delete-folder-dialog')",
        "Key('confirm-delete-folder-prototype')",
        'Removing a folder never deletes documents or changes device storage',
    ):
        if fragment not in folders_source:
            errors.append(f'Folders workspace is missing required prototype contract: {fragment}')

    settings_source = read('lib/features/settings/presentation/settings_screen.dart')
    for fragment in (
        "Key('settings-prototype-notice')",
        "Key('settings-session-status')",
        "Key('settings-auto-capture')",
        "Key('settings-default-scan-mode')",
        "Key('settings-image-quality')",
        "Key('settings-default-pdf-size')",
        "Key('settings-ocr-language')",
        "Key('settings-save-originals')",
        "Key('settings-storage-details')",
        "Key('settings-cleanup')",
        "Key('settings-privacy-details')",
        "Key('settings-cloud-backup')",
        "Key('settings-open-onboarding')",
        "Key('settings-open-help-feedback')",
        "Key('settings-open-privacy-policy')",
        "Key('settings-open-terms')",
        "Key('settings-open-about')",
        'HelpFeedbackScreen()',
        'LegalContentScreen.privacyPolicy()',
        'LegalContentScreen.terms()',
        'LegalContentScreen.about()',
        'SettingsChoiceSheet(',
        'StorageDetailsSheet(',
        'CleanupPreviewSheet(',
        'PrivacyDetailsSheet(',
        'OnboardingPreviewScreen()',
        'widget.onGoHome?.call()',
        'Nothing is saved and device data is unchanged',
    ):
        if fragment not in settings_source:
            errors.append(f'Settings screen is missing interactive prototype contract: {fragment}')

    settings_details_source = read(
        'lib/features/settings/presentation/settings_detail_sheets.dart'
    )
    for fragment in (
        "Key('settings-choice-sheet')",
        "Key('settings-storage-details-sheet')",
        "Key('settings-storage-open-cleanup')",
        "Key('settings-cleanup-sheet')",
        "Key('settings-cleanup-preview-cache')",
        "Key('settings-cleanup-export-drafts')",
        "Key('settings-cleanup-ocr-drafts')",
        "Key('settings-run-cleanup-preview')",
        "Key('settings-cleanup-empty')",
        "Key('settings-privacy-details-sheet')",
        "Key('settings-privacy-diagnostics')",
        "Key('settings-privacy-crash-reports')",
        "Key('settings-save-privacy-preview')",
        'Document',
        'ID card',
        'Book',
        'Whiteboard',
        'Standard',
        'High',
        'Maximum',
        'US Letter',
        'Bengali',
        'No cache, export draft, OCR text, database record, or device file will be deleted',
        'no analytics, crash service, permission, upload, or saved consent is connected',
    ):
        if fragment not in settings_details_source:
            errors.append(f'Settings detail sheets are missing prototype contract: {fragment}')

    help_source = read(
        'lib/features/settings/presentation/help_feedback_screen.dart'
    )
    for fragment in (
        "Key('help-feedback-screen')",
        "Key('help-feedback-prototype-notice')",
        "itemKey: 'help-faq-offline'",
        "Key('help-email-support')",
        "Key('help-open-help-centre')",
        "Key('help-report-bug')",
        "Key('help-feedback-category')",
        "Key('help-feedback-email')",
        "Key('help-feedback-message')",
        "Key('preview-feedback-submit')",
        "Key('help-feedback-status')",
        'No URL was opened and no message was sent',
        'Nothing was sent or saved',
    ):
        if fragment not in help_source:
            errors.append(f'Help and feedback screen is missing safe prototype contract: {fragment}')

    legal_source = read(
        'lib/features/settings/presentation/legal_content_screen.dart'
    )
    for fragment in (
        "screenKey: 'about-clearscan-screen'",
        "screenKey: 'privacy-policy-screen'",
        "screenKey: 'terms-screen'",
        'Legal-content prototype',
        'not a final or legally approved privacy policy',
        'do not form a contract',
        'No URL, email, licence page, or external document was opened',
        'Version ${AppConfig.versionName} • ${AppConfig.releaseLabel}',
    ):
        if fragment not in legal_source:
            errors.append(f'About/legal content is missing safe prototype contract: {fragment}')

    onboarding_source = read(
        'lib/features/onboarding/presentation/onboarding_preview_screen.dart'
    )
    for fragment in (
        "Key('onboarding-preview-screen')",
        "Key('onboarding-prototype-notice')",
        "Key('onboarding-page-view')",
        "Key('onboarding-welcome-page')",
        "Key('onboarding-features-page')",
        "Key('onboarding-privacy-page')",
        "Key('onboarding-permission-page')",
        "Key('onboarding-next')",
        "Key('onboarding-back')",
        "Key('onboarding-permission-preview')",
        "Key('onboarding-permission-preview-status')",
        "Key('onboarding-continue-without-account')",
        "Key('onboarding-sign-in-placeholder')",
        'no device permission is requested',
        'No real permission was requested',
        'Sign-in is not connected yet',
        'MediaQuery.textScalerOf(context).scale(1) > 1.5',
    ):
        if fragment not in onboarding_source:
            errors.append(f'Onboarding preview is missing required contract: {fragment}')

    scanner_source = read('lib/features/scanner/presentation/scanner_screen.dart')
    for fragment in (
        "Key('scanner-screen')",
        "Key('scanner-prototype-notice')",
        "Key('scanner-permission-needed')",
        "Key('scanner-preview-camera-access')",
        "Key('scanner-preview-permission-denied')",
        "Key('scanner-permission-denied')",
        "Key('scanner-preview-permanently-denied')",
        "Key('scanner-permission-permanently-denied')",
        "Key('scanner-preview-settings-guidance')",
        "Key('scanner-camera-unavailable')",
        "Key('scanner-open-state-preview')",
        "Key('scanner-state-preview-sheet')",
        "Key('scanner-camera-ready')",
        "Key('scanner-open-import-source')",
        "Key('scanner-import-fallback')",
        "Key('scanner-capture-button')",
        "Key('scanner-session-status')",
        "Key('scanner-auto-capture-preview')",
        "Key('scanner-auto-capture-workspace-status')",
        "Key('scanner-session-remove-dialog')",
        "Key('scanner-session-confirm-remove')",
        "Key('close-scanner')",
        "Key('scanner-unsaved-exit-dialog')",
        "Key('scanner-stay-in-session')",
        "Key('scanner-discard-session')",
        'WillPopScope(',
        'BoxConstraints(maxWidth: 960)',
        'CaptureSessionPageStrip(',
        'ScanSessionCompletionScreen(',
        'Nothing was saved or assigned',
        'No device file or saved document is deleted',
        'no camera, permission, gallery, or device file is accessed',
        'Device settings were not opened',
    ):
        if fragment not in scanner_source:
            errors.append(f'Scanner UI is missing permission-state contract: {fragment}')

    auto_capture_source = read(
        'lib/features/scanner/presentation/auto_capture_settings_sheet.dart'
    )
    for fragment in (
        "Key('scanner-auto-capture-sheet')",
        "Key('scanner-auto-capture-disclosure')",
        "Key('scanner-auto-capture-switch')",
        "Key('scanner-auto-capture-stability')",
        "Key('scanner-auto-capture-edge-guidance')",
        "Key('scanner-auto-capture-confirm')",
        'no camera frames are analysed and no capture is triggered',
        'Hold the device steady above the page',
        'Keep every document edge visible',
    ):
        if fragment not in auto_capture_source:
            errors.append(
                f'Auto-capture education is missing safe prototype contract: {fragment}'
            )

    session_page_source = read(
        'lib/features/scanner/presentation/scanner_session_page.dart'
    )
    for fragment in (
        'class ScannerSessionPage',
        'cropAdjusted',
        'PrototypeFilter filter',
        'ScannerSessionPage copyWith',
    ):
        if fragment not in session_page_source:
            errors.append(f'Scanner session page model is missing contract: {fragment}')

    page_strip_source = read(
        'lib/features/scanner/presentation/capture_session_page_strip.dart'
    )
    for fragment in (
        "Key('scanner-session-page-strip')",
        "Key('scanner-session-page-count')",
        "Key('scanner-session-page-$index')",
        "Key('scanner-session-thumbnail-disclosure')",
        "Key('scanner-session-review-selected')",
        "Key('scanner-session-remove-selected')",
        "Key('scanner-session-add-page')",
        "Key('scanner-session-finish')",
        'Generated mock thumbnails only — no image or file exists',
    ):
        if fragment not in page_strip_source:
            errors.append(f'Capture-session page strip is missing contract: {fragment}')

    completion_source = read(
        'lib/features/scanner/presentation/scan_session_completion_screen.dart'
    )
    for fragment in (
        'class ScanSessionCompletionResult',
        "Key('scan-session-completion-screen')",
        "Key('scan-completion-prototype-notice')",
        "Key('scan-completion-title')",
        "Key('scan-completion-folder')",
        "Key('scan-completion-folder-sheet')",
        "Key('scan-completion-reorder-disclosure')",
        "Key('scan-completion-reorder-list')",
        "Key('scan-completion-page-$index')",
        "Key('scan-completion-move-up-$index')",
        "Key('scan-completion-move-down-$index')",
        "Key('scan-completion-page-summary')",
        "Key('scan-completion-preview-save')",
        "Key('scan-completion-save-dialog')",
        "Key('scan-completion-confirm-save-preview')",
        "Key('scan-completion-save-preview-result')",
        "Key('scan-completion-return-scanner')",
        'ReorderableListView.builder(',
        'WillPopScope(',
        'BoxConstraints(maxWidth: 920)',
        'MediaQuery.viewInsetsOf(context).bottom',
        'final bool stackActions = constraints.maxWidth < 520',
        'does not create a document, database record, folder assignment, image, or PDF',
        'No document, database record, folder assignment, image, or PDF was created',
    ):
        if fragment not in completion_source:
            errors.append(
                f'Scan-session completion is missing safe prototype contract: {fragment}'
            )

    import_source = read(
        'lib/features/scanner/presentation/scanner_import_source_sheet.dart'
    )
    for fragment in (
        "Key('scanner-import-source-sheet')",
        "Key('scanner-import-disclosure')",
        "Key('scanner-import-${source.keyName}')",
        'Photo library',
        'Files',
        'Sample document',
        'no photo library, file picker, or device file is opened',
    ):
        if fragment not in import_source:
            errors.append(f'Scanner import sheet is missing safe prototype contract: {fragment}')

    review_source = read(
        'lib/features/scanner/presentation/capture_review_screen.dart'
    )
    for fragment in (
        "Key('capture-review-screen')",
        "Key('capture-review-prototype-notice')",
        "Key('capture-review-retake')",
        "Key('capture-review-keep-page')",
        "Key('capture-review-open-crop')",
        "Key('capture-review-open-filter')",
        "Key('capture-review-crop-status')",
        "Key('capture-review-filter-status')",
        'class CaptureReviewResult',
        'reviewingExistingPage',
        "Text('Review page ${widget.pageNumber}')",
        "widget.reviewingExistingPage ? 'Update page' : 'Keep page'",
        'CropAdjustmentScreen(',
        'FilterSelectionScreen(',
        'no image was captured, imported, processed, or saved',
    ):
        if fragment not in review_source:
            errors.append(f'Capture review is missing safe prototype contract: {fragment}')

    state_panel_source = read('lib/core/widgets/prototype_state_panel.dart')
    for fragment in (
        'enum PrototypeStateKind',
        'PrototypeStateKind.loading',
        'PrototypeStateKind.empty',
        'PrototypeStateKind.error',
        'liveRegion: true',
        'CircularProgressIndicator',
    ):
        if fragment not in state_panel_source:
            errors.append(f'Prototype state panel is missing accessibility contract: {fragment}')

    status_source = read('lib/core/widgets/status_announcement.dart')
    for fragment in (
        'enum StatusAnnouncementTone',
        'liveRegion: true',
        'label: message',
    ):
        if fragment not in status_source:
            errors.append(f'Status announcement is missing accessibility contract: {fragment}')

    adaptive_source = read('lib/core/widgets/adaptive_content_frame.dart')
    for fragment in (
        'LayoutBuilder(',
        'ConstrainedBox(',
        'maxWidth',
    ):
        if fragment not in adaptive_source:
            errors.append(f'Adaptive content frame is missing responsive contract: {fragment}')

    theme_source = read('lib/app/theme/app_theme.dart')
    for fragment in (
        'materialTapTargetSize: MaterialTapTargetSize.padded',
        'minimumSize: const Size(48, 48)',
        'visualDensity: VisualDensity.standard',
    ):
        if fragment not in theme_source:
            errors.append(f'App theme is missing touch-target contract: {fragment}')

    for path, fragment in (
        ('lib/features/search/presentation/search_workspace_screen.dart', 'AdaptiveContentFrame('),
        ('lib/features/settings/presentation/settings_screen.dart', 'AdaptiveContentFrame('),
        ('lib/features/settings/presentation/settings_screen.dart', 'StatusAnnouncement('),
        ('lib/features/settings/presentation/legal_content_screen.dart', 'AdaptiveContentFrame('),
        ('lib/features/documents/presentation/recently_deleted_screen.dart', 'PrototypeStatePanel('),
    ):
        if fragment not in read(path):
            errors.append(f'Final UI audit contract missing from {path}: {fragment}')

    pubspec = read('pubspec.yaml')
    dependency_block = re.search(
        r'^dependencies:\n(?P<body>.*?)(?=^dev_dependencies:)',
        pubspec,
        flags=re.MULTILINE | re.DOTALL,
    )
    if dependency_block is None:
        errors.append('pubspec.yaml dependencies block could not be parsed.')
    else:
        body = dependency_block.group('body')
        dependency_names = [
            match.group(1)
            for match in re.finditer(r'^  ([A-Za-z0-9_]+):', body, flags=re.MULTILINE)
        ]
        if dependency_names != ['flutter']:
            errors.append(
                'Current UI prototype allows only the Flutter SDK dependency; found: '
                + ', '.join(dependency_names)
            )

    pinned_version = read('.flutter-version').strip()
    project_env = read('tool/project.env')
    if f'CLEARSCAN_FLUTTER_VERSION={pinned_version}' not in project_env:
        errors.append('.flutter-version and tool/project.env are not aligned.')

    workflow = read('.github/workflows/flutter-ci.yml')
    for forbidden in ('actions/checkout@v', 'actions/upload-artifact@v', 'subosito/flutter-action'):
        if forbidden in workflow:
            errors.append(f'CI workflow contains mutable or unreviewed action reference: {forbidden}')

    for fragment in (
        'CLEARSCAN_FLUTTER_RELEASE_HASH=058e0af2c2b57e369d905a03ac9748b0ebf543c6',
        'CLEARSCAN_FLUTTER_ARCHIVE_SHA256_LINUX_X64=672089e001571a9fbb209a495c583580c0c6c73ef98999264ba07fa93ace332d',
    ):
        if fragment not in project_env:
            errors.append(f'Pinned Flutter provenance is missing: {fragment}')

    startup_test = read('test/app_startup_test.dart')
    for fragment in (
        'await tester.pumpWidget(const ClearScanApp())',
        'find.text(AppConfig.appName)',
        "find.text('Quick actions')",
        "find.text('Recent documents')",
        "Key('scan-fab')",
        "Key('documents-tab')",
        "Key('folders-tab')",
        "Key('settings-tab')",
        "Key('document-meeting-notes')",
        "Key('document-viewer')",
        "Key('edit-document-pages')",
        "Key('multi-page-editor')",
        "Key('add-editor-page')",
        "Key('open-crop-adjustment')",
        "Key('crop-adjustment-screen')",
        "Key('apply-crop-prototype')",
        "Key('open-filter-selection')",
        "Key('filter-selection-screen')",
        "Key('filter-option-grayscale')",
        "Key('apply-filter-prototype')",
        "Key('open-pdf-export-options')",
        "Key('pdf-export-options-screen')",
        "Key('pdf-export-prototype-notice')",
        "Key('pdf-estimated-output')",
        "Key('prepare-pdf-prototype')",
        "Key('open-ocr-text-workspace')",
        "Key('ocr-text-workspace-screen')",
        "Key('ocr-prototype-notice')",
        "Key('run-mock-ocr')",
        "Key('ocr-processing-state')",
        "Key('ocr-result-state')",
        "Key('ocr-result-editor')",
        "Key('open-share-options')",
        "Key('share-options-screen')",
        "Key('share-format-images')",
        "Key('open-system-share-prototype')",
        "Key('open-document-actions-appbar')",
        "Key('document-actions-sheet')",
        "Key('document-action-rename')",
        "Key('rename-document-dialog')",
        "Key('apply-rename-prototype')",
        "Key('move-document-sheet')",
        "Key('document-info-dialog')",
        "Key('delete-document-dialog')",
        "Key('confirm-delete-prototype')",
        "Key('home-open-search')",
        "Key('documents-open-search')",
        "Key('search-workspace-screen')",
        "Key('search-query-field')",
        "Key('search-type-images')",
        "Key('search-favorites-filter')",
        "Key('folder-search-field')",
        "Key('create-folder')",
        "Key('folder-editor-sheet')",
        "Key('folder-name-field')",
        "Key('folder-color-3')",
        "Key('save-folder-prototype')",
        "Key('folder-actions-sheet')",
        "Key('folder-action-edit')",
        "Key('folder-action-delete')",
        "Key('delete-folder-dialog')",
        "Key('confirm-delete-folder-prototype')",
        "Key('documents-library-prototype-notice')",
        "Key('documents-view-grid')",
        "Key('document-grid-meeting-notes')",
        "Key('documents-sort')",
        "Key('documents-sort-title')",
        "Key('documents-filter-favorites')",
        "Key('documents-toggle-selection')",
        "Key('library-selection-toolbar')",
        "Key('favorite-selected-documents')",
        "Key('delete-selected-documents')",
        "Key('documents-open-recently-deleted')",
        "Key('recently-deleted-screen')",
        "Key('restore-deleted-meeting-notes')",
        "Key('permanent-delete-dialog')",
        "Key('recently-deleted-empty')",
        "Key('scanner-permission-needed')",
        "Key('scanner-preview-permission-denied')",
        "Key('scanner-permission-denied')",
        "Key('scanner-preview-permanently-denied')",
        "Key('scanner-permission-permanently-denied')",
        "Key('scanner-import-from-permanent')",
        "Key('scanner-import-source-sheet')",
        "Key('scanner-import-sample-document')",
        "Key('capture-review-screen')",
        "Key('capture-review-prototype-notice')",
        "Key('capture-review-keep-page')",
        "Key('scanner-session-status')",
        "Key('scanner-auto-capture-preview')",
        "Key('scanner-auto-capture-sheet')",
        "Key('scanner-auto-capture-disclosure')",
        "Key('scanner-auto-capture-switch')",
        "Key('scanner-auto-capture-confirm')",
        "Key('scanner-auto-capture-workspace-status')",
        "Key('scanner-session-page-strip')",
        "Key('scanner-session-page-count')",
        "Key('scanner-session-thumbnail-disclosure')",
        "Key('scanner-session-add-page')",
        "Key('scanner-session-page-0')",
        "Key('scanner-session-review-selected')",
        "Key('scanner-session-remove-selected')",
        "Key('scanner-session-remove-dialog')",
        "Key('scanner-session-confirm-remove')",
        "Key('scanner-session-finish')",
        "Key('scan-session-completion-screen')",
        "Key('scan-completion-prototype-notice')",
        "Key('scan-completion-title')",
        "Key('scan-completion-folder')",
        "Key('scan-completion-folder-sheet')",
        "Key('scan-completion-folder-work')",
        "Key('scan-completion-page-summary')",
        "Key('scan-completion-move-down-0')",
        "Key('scan-completion-preview-save')",
        "Key('scan-completion-save-dialog')",
        "Key('scan-completion-confirm-save-preview')",
        "Key('scan-completion-save-preview-result')",
        "Key('scan-completion-return-scanner')",
        "Key('documents-preview-states')",
        "Key('documents-state-preview-sheet')",
        "Key('documents-state-loading')",
        "Key('documents-loading-state')",
        "Key('documents-state-error')",
        "Key('documents-error-state')",
        "Key('close-scanner')",
        "Key('scanner-unsaved-exit-dialog')",
        "Key('scanner-stay-in-session')",
        "Key('scanner-discard-session')",
        "Key('settings-open-onboarding')",
        "Key('onboarding-preview-screen')",
        "Key('onboarding-prototype-notice')",
        "Key('onboarding-welcome-page')",
        "Key('onboarding-features-page')",
        "Key('onboarding-privacy-page')",
        "Key('onboarding-permission-page')",
        "Key('onboarding-next')",
        "Key('onboarding-permission-preview')",
        "Key('onboarding-permission-preview-status')",
        "Key('onboarding-sign-in-placeholder')",
        "Key('onboarding-continue-without-account')",
        "Key('settings-prototype-notice')",
        "Key('settings-default-scan-mode')",
        "Key('settings-choice-sheet')",
        "Key('settings-scan-mode-option-book')",
        "Key('settings-image-quality-option-maximum')",
        "Key('settings-pdf-size-option-us-letter')",
        "Key('settings-ocr-language-option-bengali')",
        "Key('settings-storage-details')",
        "Key('settings-storage-details-sheet')",
        "Key('settings-storage-open-cleanup')",
        "Key('settings-cleanup-sheet')",
        "Key('settings-cleanup-preview-cache')",
        "Key('settings-run-cleanup-preview')",
        "Key('settings-privacy-details')",
        "Key('settings-privacy-details-sheet')",
        "Key('settings-privacy-diagnostics')",
        "Key('settings-privacy-crash-reports')",
        "Key('settings-save-privacy-preview')",
        "Key('settings-open-help-feedback')",
        "Key('help-feedback-screen')",
        "Key('help-feedback-prototype-notice')",
        "Key('help-email-support')",
        "Key('help-feedback-message')",
        "Key('preview-feedback-submit')",
        "Key('help-feedback-status')",
        "Key('settings-open-privacy-policy')",
        "Key('privacy-policy-screen')",
        "Key('privacy-policy-screen-prototype-notice')",
        "Key('privacy-policy-screen-external-placeholder')",
        "Key('settings-open-terms')",
        "Key('terms-screen')",
        "Key('settings-open-about')",
        "Key('about-clearscan-screen')",
    ):
        if fragment not in startup_test:
            errors.append(f'Startup test source is missing required fragment: {fragment}')

    if errors:
        for error in errors:
            print(error)
        return 1

    print(
        f'Validated {len(dart_files)} Dart source files, central design tokens, '
        'visible app-shell wiring, responsive/accessibility/state patterns, scanner/auto-capture/capture-session/completion/viewer/editor/crop/filter/PDF/OCR/share/document-action/search/folder/onboarding/library/recently-deleted/settings/help/legal disclosures, '
        'dependency boundaries, and startup/navigation test source.'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
