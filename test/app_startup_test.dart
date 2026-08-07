import 'package:clearscan/app/app.dart';
import 'package:clearscan/app/configuration/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ClearScan starts on the real Home interface', (WidgetTester tester) async {
    await tester.pumpWidget(const ClearScanApp());

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Recent documents'), findsOneWidget);
    expect(find.byKey(const Key('scan-fab')), findsOneWidget);
  });

  testWidgets('bottom navigation opens main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Documents'), findsWidgets);

    await tester.tap(find.byKey(const Key('folders-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Folders'), findsWidgets);

    await tester.tap(find.byKey(const Key('settings-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('scan action opens scanner workspace', (WidgetTester tester) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('scan-fab')));
    await tester.pumpAndSettle();

    expect(find.text('Scan'), findsOneWidget);
    expect(find.byKey(const Key('scanner-prototype-notice')), findsOneWidget);
  });

  testWidgets('mock document opens viewer and multi-page editor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();

    final Finder document = find.byKey(const Key('document-meeting-notes'));
    await tester.ensureVisible(document);
    await tester.tap(document);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('document-viewer')), findsOneWidget);
    expect(find.byKey(const Key('document-viewer-prototype-notice')), findsOneWidget);
    expect(find.text('Meeting Notes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-document-pages')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('multi-page-editor')), findsOneWidget);
    expect(find.byKey(const Key('editor-prototype-notice')), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-editor-page')));
    await tester.pump();
    expect(find.byKey(const Key('editor-page-4')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-crop-adjustment')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('crop-adjustment-screen')), findsOneWidget);
    expect(find.byKey(const Key('crop-prototype-notice')), findsOneWidget);
    expect(find.byKey(const Key('crop-corner-0')), findsOneWidget);

    await tester.drag(find.byKey(const Key('crop-corner-0')), const Offset(8, 8));
    await tester.pump();
    await tester.tap(find.byKey(const Key('apply-crop-prototype')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('crop-adjusted-status')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-filter-selection')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('filter-selection-screen')), findsOneWidget);
    expect(find.byKey(const Key('filter-prototype-notice')), findsOneWidget);

    final Finder grayscale = find.byKey(const Key('filter-option-grayscale'));
    await tester.ensureVisible(grayscale);
    await tester.tap(grayscale);
    await tester.pump();
    expect(find.text('Grayscale preview'), findsOneWidget);

    await tester.tap(find.byKey(const Key('apply-filter-prototype')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('selected-filter-status')), findsOneWidget);
    expect(find.text('Grayscale'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-multi-page-editor')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-viewer')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-document-viewer')));
    await tester.pumpAndSettle();
    expect(find.text('Documents'), findsWidgets);
  });

  testWidgets('document viewer opens PDF and OCR prototype workspaces', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();

    final Finder document = find.byKey(const Key('document-meeting-notes'));
    await tester.ensureVisible(document);
    await tester.tap(document);
    await tester.pumpAndSettle();

    final Finder pdfAction = find.byKey(const Key('open-pdf-export-options'));
    await tester.ensureVisible(pdfAction);
    await tester.tap(pdfAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pdf-export-options-screen')), findsOneWidget);
    expect(find.byKey(const Key('pdf-export-prototype-notice')), findsOneWidget);
    expect(find.byKey(const Key('pdf-estimated-output')), findsOneWidget);

    await tester.tap(find.byKey(const Key('pdf-pages-current')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pdf-orientation-landscape')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('prepare-pdf-prototype')));
    await tester.tap(find.byKey(const Key('prepare-pdf-prototype')));
    await tester.pump();
    expect(find.textContaining('PDF generation is not connected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-pdf-export-options')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-viewer')), findsOneWidget);

    final Finder ocrAction = find.byKey(const Key('open-ocr-text-workspace'));
    await tester.ensureVisible(ocrAction);
    await tester.tap(ocrAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ocr-text-workspace-screen')), findsOneWidget);
    expect(find.byKey(const Key('ocr-prototype-notice')), findsOneWidget);
    expect(find.byKey(const Key('ocr-ready-state')), findsOneWidget);

    await tester.tap(find.byKey(const Key('run-mock-ocr')));
    await tester.pump();
    expect(find.byKey(const Key('ocr-processing-state')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('ocr-result-state')), findsOneWidget);
    expect(find.byKey(const Key('ocr-result-editor')), findsOneWidget);
    expect(find.byKey(const Key('copy-ocr-text')), findsOneWidget);
    expect(find.byKey(const Key('share-ocr-text-placeholder')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-ocr-text-workspace')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-viewer')), findsOneWidget);
  });

  testWidgets('document viewer opens share and management prototypes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();

    final Finder document = find.byKey(const Key('document-meeting-notes'));
    await tester.ensureVisible(document);
    await tester.tap(document);
    await tester.pumpAndSettle();

    final Finder shareAction = find.byKey(const Key('open-share-options'));
    await tester.ensureVisible(shareAction);
    await tester.tap(shareAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('share-options-screen')), findsOneWidget);
    expect(
      find.byKey(const Key('share-options-prototype-notice')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('share-format-images')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share-pages-current')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('open-system-share-prototype')),
    );
    await tester.tap(find.byKey(const Key('open-system-share-prototype')));
    await tester.pump();
    expect(find.textContaining('System sharing is not connected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-share-options')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-viewer')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-document-actions-appbar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-actions-sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('document-action-rename')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rename-document-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('rename-document-title')),
      'Team Meeting Notes',
    );
    await tester.tap(find.byKey(const Key('apply-rename-prototype')));
    await tester.pumpAndSettle();
    expect(find.text('Team Meeting Notes'), findsWidgets);
    expect(find.byKey(const Key('temporary-document-status')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-document-actions-appbar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-action-move')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('move-document-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('move-folder-work')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Folder: Work'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-document-actions-appbar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-action-info')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-info-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-document-info')));
    await tester.pumpAndSettle();

    final Finder moreAction =
        find.byKey(const Key('open-document-actions-more'));
    await tester.ensureVisible(moreAction);
    await tester.tap(moreAction);
    await tester.pumpAndSettle();
    final Finder deleteAction = find.byKey(const Key('document-action-delete'));
    await tester.ensureVisible(deleteAction);
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-document-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-delete-prototype')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Marked deleted'), findsOneWidget);
  });

  testWidgets('home and documents open the shared search workspace', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('home-open-search')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-workspace-screen')), findsOneWidget);
    expect(find.byKey(const Key('search-prototype-notice')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('search-query-field')),
      'Invoice',
    );
    await tester.pump();
    expect(find.byKey(const Key('search-result-invoice-0423')), findsOneWidget);
    expect(find.byKey(const Key('search-result-meeting-notes')), findsNothing);

    await tester.tap(find.byKey(const Key('clear-search-filters')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('search-type-images')));
    await tester.pump();
    expect(find.byKey(const Key('search-result-identity-card')), findsOneWidget);
    expect(find.byKey(const Key('search-result-meeting-notes')), findsNothing);

    await tester.tap(find.byKey(const Key('clear-search-filters')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('search-favorites-filter')));
    await tester.pump();
    expect(find.byKey(const Key('search-result-meeting-notes')), findsOneWidget);
    expect(find.byKey(const Key('search-result-invoice-0423')), findsNothing);

    await tester.tap(find.byKey(const Key('close-search-workspace')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('documents-open-search')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-workspace-screen')), findsOneWidget);
  });

  testWidgets('folder prototypes create edit search and safely remove cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('folders-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('folder-prototype-notice')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('folder-search-field')),
      'Work',
    );
    await tester.pump();
    expect(find.byKey(const Key('folder-card-work')), findsOneWidget);
    expect(find.byKey(const Key('folder-card-receipts')), findsNothing);
    await tester.tap(find.byKey(const Key('clear-folder-search')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('create-folder')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('folder-editor-sheet')), findsOneWidget);
    expect(
      find.byKey(const Key('folder-editor-prototype-notice')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('folder-name-field')),
      'Legal',
    );
    await tester.tap(find.byKey(const Key('folder-color-3')));
    await tester.tap(find.byKey(const Key('save-folder-prototype')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('folder-card-temporary-folder-1')),
      findsOneWidget,
    );
    expect(find.text('Legal'), findsOneWidget);

    final Finder more =
        find.byKey(const Key('folder-more-temporary-folder-1'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('folder-actions-sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('folder-action-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('folder-name-field')),
      'Legal Files',
    );
    await tester.tap(find.byKey(const Key('folder-color-1')));
    await tester.tap(find.byKey(const Key('save-folder-prototype')));
    await tester.pumpAndSettle();
    expect(find.text('Legal Files'), findsOneWidget);
    expect(find.byKey(const Key('temporary-folder-status')), findsOneWidget);

    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('folder-action-delete')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-folder-dialog')), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('confirm-delete-folder-prototype')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('folder-card-temporary-folder-1')),
      findsNothing,
    );
    expect(find.textContaining('Documents and device storage were not changed'),
        findsOneWidget);
  });


  testWidgets('settings previews onboarding and returns to Home without account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('settings-tab')));
    await tester.pumpAndSettle();

    final Finder onboardingEntry =
        find.byKey(const Key('settings-open-onboarding'));
    await tester.ensureVisible(onboardingEntry);
    await tester.tap(onboardingEntry);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding-preview-screen')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-prototype-notice')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-welcome-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-features-page')), findsOneWidget);
    expect(find.text('Scan, refine, and organise'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-privacy-page')), findsOneWidget);
    expect(find.text('Private by default'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-permission-page')), findsOneWidget);
    expect(find.text('Camera access, explained first'), findsOneWidget);

    final Finder permissionPreview =
        find.byKey(const Key('onboarding-permission-preview'));
    await tester.ensureVisible(permissionPreview);
    await tester.tap(permissionPreview);
    await tester.pump();
    expect(
      find.byKey(const Key('onboarding-permission-preview-status')),
      findsOneWidget,
    );

    final Finder signIn =
        find.byKey(const Key('onboarding-sign-in-placeholder'));
    await tester.ensureVisible(signIn);
    await tester.tap(signIn);
    await tester.pump();
    expect(find.textContaining('Sign-in is not connected yet'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));

    final Finder continueWithoutAccount =
        find.byKey(const Key('onboarding-continue-without-account'));
    await tester.ensureVisible(continueWithoutAccount);
    await tester.tap(continueWithoutAccount);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding-preview-screen')), findsNothing);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.byKey(const Key('home-tab')), findsOneWidget);
  });


  testWidgets('documents library changes view sorts selects favorites and deletes temporarily', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('documents-library-prototype-notice')), findsOneWidget);

    await tester.tap(find.byKey(const Key('documents-view-grid')));
    await tester.pump();
    expect(find.byKey(const Key('document-grid-meeting-notes')), findsOneWidget);

    await tester.tap(find.byKey(const Key('documents-view-list')));
    await tester.tap(find.byKey(const Key('documents-sort')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('documents-sort-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('documents-sort-title')));
    await tester.pumpAndSettle();
    expect(find.text('Title A–Z'), findsOneWidget);

    await tester.tap(find.byKey(const Key('documents-filter-favorites')));
    await tester.pump();
    expect(find.byKey(const Key('document-meeting-notes')), findsOneWidget);
    expect(find.byKey(const Key('document-invoice-0423')), findsNothing);

    await tester.tap(find.byKey(const Key('documents-filter-all')));
    await tester.tap(find.byKey(const Key('documents-toggle-selection')));
    await tester.pump();
    expect(find.byKey(const Key('library-selection-toolbar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('document-meeting-notes')));
    await tester.tap(find.byKey(const Key('document-invoice-0423')));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('favorite-selected-documents')));
    await tester.pump();
    expect(find.byKey(const Key('documents-library-status')), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-selected-documents')));
    await tester.pump();
    expect(find.byKey(const Key('document-meeting-notes')), findsNothing);
    expect(find.textContaining('Deleted (2)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('documents-open-recently-deleted')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recently-deleted-screen')), findsOneWidget);
    expect(find.byKey(const Key('deleted-document-meeting-notes')), findsOneWidget);

    await tester.tap(find.byKey(const Key('restore-deleted-meeting-notes')));
    await tester.pump();
    expect(find.byKey(const Key('deleted-document-meeting-notes')), findsNothing);

    await tester.tap(find.byKey(const Key('permanently-delete-invoice-0423')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('permanent-delete-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-permanent-delete-invoice-0423')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recently-deleted-empty')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-recently-deleted')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-meeting-notes')), findsOneWidget);
  });


  testWidgets('settings preferences cleanup and privacy stay session only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('settings-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-prototype-notice')), findsOneWidget);

    final Finder scanMode =
        find.byKey(const Key('settings-default-scan-mode'));
    await tester.ensureVisible(scanMode);
    await tester.tap(scanMode);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-choice-sheet')), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('settings-scan-mode-option-book')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Book'), findsOneWidget);
    expect(find.byKey(const Key('settings-session-status')), findsOneWidget);

    final Finder imageQuality =
        find.byKey(const Key('settings-image-quality'));
    await tester.ensureVisible(imageQuality);
    await tester.tap(imageQuality);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('settings-image-quality-option-maximum')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Maximum'), findsOneWidget);

    final Finder pdfSize =
        find.byKey(const Key('settings-default-pdf-size'));
    await tester.ensureVisible(pdfSize);
    await tester.tap(pdfSize);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('settings-pdf-size-option-us-letter')),
    );
    await tester.pumpAndSettle();
    expect(find.text('US Letter'), findsOneWidget);

    final Finder ocrLanguage =
        find.byKey(const Key('settings-ocr-language'));
    await tester.ensureVisible(ocrLanguage);
    await tester.tap(ocrLanguage);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('settings-ocr-language-option-bengali')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bengali'), findsOneWidget);

    final Finder storageDetails =
        find.byKey(const Key('settings-storage-details'));
    await tester.ensureVisible(storageDetails);
    await tester.tap(storageDetails);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('settings-storage-details-sheet')),
      findsOneWidget,
    );
    expect(find.textContaining('36 MB shown'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('settings-storage-open-cleanup')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-cleanup-sheet')), findsOneWidget);
    expect(
      find.byKey(const Key('settings-cleanup-preview-cache')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('settings-run-cleanup-preview')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('30 MB used • 0 MB temporary'), findsOneWidget);
    expect(find.textContaining('No cache, document'), findsOneWidget);

    final Finder privacyDetails =
        find.byKey(const Key('settings-privacy-details'));
    await tester.ensureVisible(privacyDetails);
    await tester.tap(privacyDetails);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('settings-privacy-details-sheet')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('settings-privacy-diagnostics')),
    );
    await tester.tap(
      find.byKey(const Key('settings-privacy-crash-reports')),
    );
    await tester.tap(
      find.byKey(const Key('settings-save-privacy-preview')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Diagnostics on'), findsOneWidget);
    expect(find.textContaining('No consent, analytics'), findsOneWidget);
  });


  testWidgets('support and legal content remain safe prototypes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('settings-tab')));
    await tester.pumpAndSettle();

    final Finder helpEntry =
        find.byKey(const Key('settings-open-help-feedback'));
    await tester.ensureVisible(helpEntry);
    await tester.tap(helpEntry);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help-feedback-screen')), findsOneWidget);
    expect(
      find.byKey(const Key('help-feedback-prototype-notice')),
      findsOneWidget,
    );

    final Finder emailSupport = find.byKey(const Key('help-email-support'));
    await tester.ensureVisible(emailSupport);
    await tester.tap(emailSupport);
    await tester.pump();
    expect(find.byKey(const Key('help-feedback-status')), findsOneWidget);
    expect(find.textContaining('No URL was opened'), findsOneWidget);

    final Finder feedbackMessage =
        find.byKey(const Key('help-feedback-message'));
    await tester.ensureVisible(feedbackMessage);
    await tester.enterText(
      feedbackMessage,
      'Please improve document naming.',
    );
    final Finder previewSubmit =
        find.byKey(const Key('preview-feedback-submit'));
    await tester.ensureVisible(previewSubmit);
    await tester.tap(previewSubmit);
    await tester.pump();
    expect(find.textContaining('Nothing was sent or saved'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-help-feedback')));
    await tester.pumpAndSettle();

    final Finder privacyEntry =
        find.byKey(const Key('settings-open-privacy-policy'));
    await tester.ensureVisible(privacyEntry);
    await tester.tap(privacyEntry);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('privacy-policy-screen')), findsOneWidget);
    expect(
      find.byKey(const Key('privacy-policy-screen-prototype-notice')),
      findsOneWidget,
    );
    expect(find.textContaining('not a final or legally approved'), findsOneWidget);
    final Finder privacyExternal = find.byKey(
      const Key('privacy-policy-screen-external-placeholder'),
    );
    await tester.ensureVisible(privacyExternal);
    await tester.tap(privacyExternal);
    await tester.pump();
    expect(find.textContaining('No URL, email'), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-privacy-policy-screen')));
    await tester.pumpAndSettle();

    final Finder termsEntry = find.byKey(const Key('settings-open-terms'));
    await tester.ensureVisible(termsEntry);
    await tester.tap(termsEntry);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('terms-screen')), findsOneWidget);
    expect(find.textContaining('do not form a contract'), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-terms-screen')));
    await tester.pumpAndSettle();

    final Finder aboutEntry = find.byKey(const Key('settings-open-about'));
    await tester.ensureVisible(aboutEntry);
    await tester.tap(aboutEntry);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-clearscan-screen')), findsOneWidget);
    expect(find.textContaining('Version 0.1.0'), findsOneWidget);
    expect(
      find.byKey(const Key('about-clearscan-screen-prototype-notice')),
      findsOneWidget,
    );
  });


  testWidgets('scanner permission, import, and capture review remain safe prototypes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('scan-fab')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scanner-permission-needed')), findsOneWidget);
    expect(
      find.textContaining('no camera, permission, gallery'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('scanner-preview-permission-denied')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-permission-denied')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('scanner-preview-permanently-denied')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scanner-permission-permanently-denied')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('scanner-import-from-permanent')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-import-source-sheet')), findsOneWidget);
    expect(find.byKey(const Key('scanner-import-disclosure')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('scanner-import-sample-document')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('capture-review-screen')), findsOneWidget);
    expect(
      find.byKey(const Key('capture-review-prototype-notice')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-session-status')), findsOneWidget);
    expect(find.textContaining('No image or file was saved'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-open-state-preview')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-state-preview-sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-state-ready')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-camera-ready')), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-capture-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('capture-review-screen')), findsOneWidget);
  });


  testWidgets('scanner auto capture and page strip remain session-only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('scan-fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-preview-camera-access')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('scanner-auto-capture-preview')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-auto-capture-sheet')), findsOneWidget);
    expect(
      find.byKey(const Key('scanner-auto-capture-disclosure')),
      findsOneWidget,
    );
    expect(
      find.textContaining('no camera frames are analysed'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('scanner-auto-capture-switch')));
    final Finder applyAutoCapture =
        find.byKey(const Key('scanner-auto-capture-confirm'));
    await tester.ensureVisible(applyAutoCapture);
    await tester.tap(applyAutoCapture);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scanner-auto-capture-workspace-status')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('scanner-capture-button')));
    await tester.pumpAndSettle();
    expect(find.text('Review page 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scanner-session-page-strip')), findsOneWidget);
    expect(find.byKey(const Key('scanner-session-page-count')), findsOneWidget);
    expect(find.text('1 page'), findsOneWidget);
    expect(
      find.byKey(const Key('scanner-session-thumbnail-disclosure')),
      findsOneWidget,
    );

    final Finder addPage = find.byKey(const Key('scanner-session-add-page'));
    await tester.ensureVisible(addPage);
    await tester.tap(addPage);
    await tester.pumpAndSettle();
    expect(find.text('Review page 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();
    expect(find.text('2 pages'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-session-page-0')));
    final Finder reviewPage =
        find.byKey(const Key('scanner-session-review-selected'));
    await tester.ensureVisible(reviewPage);
    await tester.tap(reviewPage);
    await tester.pumpAndSettle();
    expect(find.text('Review page 1'), findsOneWidget);
    expect(find.text('Update page'), findsOneWidget);
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();

    final Finder removePage =
        find.byKey(const Key('scanner-session-remove-selected'));
    await tester.ensureVisible(removePage);
    await tester.tap(removePage);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scanner-session-remove-dialog')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('scanner-session-confirm-remove')));
    await tester.pumpAndSettle();
    expect(find.text('1 page'), findsOneWidget);
    expect(find.textContaining('No device file was deleted'), findsOneWidget);
  });


  testWidgets('scanner completion reorders and previews save without persistence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('scan-fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-preview-camera-access')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('scanner-capture-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();

    final Finder addPage = find.byKey(const Key('scanner-session-add-page'));
    await tester.ensureVisible(addPage);
    await tester.tap(addPage);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();

    final Finder finishSession =
        find.byKey(const Key('scanner-session-finish'));
    await tester.ensureVisible(finishSession);
    await tester.tap(finishSession);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('scan-session-completion-screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('scan-completion-prototype-notice')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('scan-completion-page-summary')),
      findsOneWidget,
    );

    final Finder titleField = find.byKey(const Key('scan-completion-title'));
    await tester.ensureVisible(titleField);
    await tester.enterText(titleField, 'Client contract');

    final Finder folderButton = find.byKey(const Key('scan-completion-folder'));
    await tester.ensureVisible(folderButton);
    await tester.tap(folderButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scan-completion-folder-sheet')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('scan-completion-folder-work')));
    await tester.pumpAndSettle();
    expect(find.text('Folder: Work'), findsOneWidget);

    final Finder moveDown =
        find.byKey(const Key('scan-completion-move-down-0'));
    await tester.ensureVisible(moveDown);
    await tester.tap(moveDown);
    await tester.pump();
    expect(find.textContaining('position 2'), findsOneWidget);

    final Finder previewSave =
        find.byKey(const Key('scan-completion-preview-save'));
    await tester.ensureVisible(previewSave);
    await tester.tap(previewSave);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scan-completion-save-dialog')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('scan-completion-confirm-save-preview')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scan-completion-save-preview-result')),
      findsOneWidget,
    );
    expect(
      find.textContaining('No document, database record'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('scan-completion-return-scanner')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-screen')), findsOneWidget);
    expect(
      find.textContaining('Save preview completed for "Client contract"'),
      findsOneWidget,
    );
    expect(find.textContaining('Nothing was saved or assigned'), findsOneWidget);
  });


  testWidgets('library preview states expose safe loading and error recovery', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('documents-tab')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('documents-preview-states')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('documents-state-preview-sheet')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('documents-state-loading')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('documents-loading-state')), findsOneWidget);
    expect(find.textContaining('No database, storage'), findsOneWidget);

    await tester.tap(find.byKey(const Key('documents-preview-states')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('documents-state-error')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('documents-error-state')), findsOneWidget);

    await tester.tap(find.text('Retry preview'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-meeting-notes')), findsOneWidget);
    expect(find.textContaining('No repository request was made'), findsOneWidget);
  });

  testWidgets('scanner protects temporary pages on exit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ClearScanApp());

    await tester.tap(find.byKey(const Key('scan-fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-preview-camera-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-capture-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('capture-review-keep-page')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('close-scanner')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('scanner-unsaved-exit-dialog')),
      findsOneWidget,
    );
    expect(find.textContaining('temporary page'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-stay-in-session')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-scanner')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-discard-session')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner-screen')), findsNothing);
    expect(find.text(AppConfig.appName), findsOneWidget);
  });

}
