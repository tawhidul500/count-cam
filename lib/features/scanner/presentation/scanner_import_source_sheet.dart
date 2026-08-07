import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum ScannerImportSource {
  photoLibrary,
  files,
  sampleDocument,
}

extension ScannerImportSourceDetails on ScannerImportSource {
  String get label => switch (this) {
        ScannerImportSource.photoLibrary => 'Photo library',
        ScannerImportSource.files => 'Files',
        ScannerImportSource.sampleDocument => 'Sample document',
      };

  String get description => switch (this) {
        ScannerImportSource.photoLibrary =>
          'Preview a gallery-selection flow without reading photos.',
        ScannerImportSource.files =>
          'Preview a file-import flow without opening device storage.',
        ScannerImportSource.sampleDocument =>
          'Use the built-in mock page to review the next step safely.',
      };

  IconData get icon => switch (this) {
        ScannerImportSource.photoLibrary => Icons.photo_library_outlined,
        ScannerImportSource.files => Icons.folder_open_outlined,
        ScannerImportSource.sampleDocument => Icons.description_outlined,
      };

  String get keyName => switch (this) {
        ScannerImportSource.photoLibrary => 'photo-library',
        ScannerImportSource.files => 'files',
        ScannerImportSource.sampleDocument => 'sample-document',
      };
}

class ScannerImportSourceSheet extends StatelessWidget {
  const ScannerImportSourceSheet({super.key});

  static Future<ScannerImportSource?> show(BuildContext context) {
    return showModalBottomSheet<ScannerImportSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navySurface,
      builder: (BuildContext context) => const ScannerImportSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('scanner-import-source-sheet'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.navyElevated,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Choose a source',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.workspaceText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Prototype only — no photo library, file picker, or device file is opened.',
              key: const Key('scanner-import-disclosure'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.workspaceMuted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...ScannerImportSource.values.map(
              (ScannerImportSource source) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SourceTile(source: source),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final ScannerImportSource source;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navyElevated,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
      child: InkWell(
        key: Key('scanner-import-${source.keyName}'),
        onTap: () => Navigator.of(context).pop(source),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
                ),
                child: Icon(source.icon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      source.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.workspaceText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      source.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.workspaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.workspaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}
