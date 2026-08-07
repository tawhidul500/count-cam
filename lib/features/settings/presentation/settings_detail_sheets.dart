import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

abstract final class SettingsPreviewOptions {
  static const List<String> scanModes = <String>[
    'Document',
    'ID card',
    'Book',
    'Whiteboard',
  ];

  static const List<String> imageQualities = <String>[
    'Standard',
    'High',
    'Maximum',
  ];

  static const List<String> pdfSizes = <String>[
    'Auto',
    'A4',
    'US Letter',
    'Legal',
  ];

  static const List<String> ocrLanguages = <String>[
    'English',
    'Spanish',
    'French',
    'German',
    'Bengali',
  ];
}

String _keySlug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

class SettingsChoiceSheet extends StatelessWidget {
  const SettingsChoiceSheet({
    required this.keyPrefix,
    required this.title,
    required this.description,
    required this.selectedValue,
    required this.options,
    super.key,
  });

  final String keyPrefix;
  final String title;
  final String description;
  final String selectedValue;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const Key('settings-choice-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            const _PrototypeNotice(
              icon: Icons.tune_rounded,
              message:
                  'Preview preference only — this selection is not saved and does not change future scans or exports.',
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final String option in options)
              ListTile(
                key: Key('$keyPrefix-option-${_keySlug(option)}'),
                selected: option == selectedValue,
                selectedTileColor: AppColors.primarySoft,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.medium),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(option),
                leading: Icon(
                  option == selectedValue
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: option == selectedValue
                      ? AppColors.primaryDark
                      : AppColors.textMuted,
                ),
                title: Text(option),
                trailing: option == selectedValue
                    ? const Text(
                        'Selected',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

enum SettingsStorageAction { cleanup }

class StorageDetailsSheet extends StatelessWidget {
  const StorageDetailsSheet({
    required this.totalUsedMb,
    required this.temporaryDataMb,
    super.key,
  });

  final int totalUsedMb;
  final int temporaryDataMb;

  @override
  Widget build(BuildContext context) {
    final int originalMb = 18;
    final int processedMb = 9;
    final int thumbnailMb = 3;
    final int otherMb = (totalUsedMb -
            originalMb -
            processedMb -
            thumbnailMb -
            temporaryDataMb)
        .clamp(0, totalUsedMb)
        .toInt();

    return SafeArea(
      child: Container(
        key: const Key('settings-storage-details-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Storage details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$totalUsedMb MB shown in this temporary preview',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _PrototypeNotice(
              icon: Icons.storage_outlined,
              message:
                  'Illustrative values only — ClearScan is not reading device storage or document files in this prototype.',
            ),
            const SizedBox(height: AppSpacing.md),
            _StorageRow(
              icon: Icons.layers_outlined,
              label: 'Original captures',
              value: '$originalMb MB',
            ),
            _StorageRow(
              icon: Icons.auto_fix_high_outlined,
              label: 'Processed previews',
              value: '$processedMb MB',
            ),
            _StorageRow(
              icon: Icons.photo_size_select_small_outlined,
              label: 'Thumbnails',
              value: '$thumbnailMb MB',
            ),
            _StorageRow(
              icon: Icons.cached_rounded,
              label: 'Temporary data',
              value: '$temporaryDataMb MB',
              valueColor: temporaryDataMb > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
            if (otherMb > 0)
              _StorageRow(
                icon: Icons.more_horiz_rounded,
                label: 'Other preview data',
                value: '$otherMb MB',
              ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              key: const Key('settings-storage-open-cleanup'),
              onPressed: () => Navigator.of(context).pop(
                SettingsStorageAction.cleanup,
              ),
              icon: const Icon(Icons.cleaning_services_outlined),
              label: Text(
                temporaryDataMb > 0
                    ? 'Review temporary cleanup'
                    : 'Review cleanup status',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CleanupPreviewResult {
  const CleanupPreviewResult({required this.releasedMb});

  final int releasedMb;
}

class CleanupPreviewSheet extends StatefulWidget {
  const CleanupPreviewSheet({required this.temporaryDataMb, super.key});

  final int temporaryDataMb;

  @override
  State<CleanupPreviewSheet> createState() => _CleanupPreviewSheetState();
}

class _CleanupPreviewSheetState extends State<CleanupPreviewSheet> {
  bool _previewCache = true;
  bool _exportDrafts = true;
  bool _ocrDrafts = true;

  int get _selectedMb {
    if (widget.temporaryDataMb == 0) {
      return 0;
    }
    final int selected = (_previewCache ? 3 : 0) +
        (_exportDrafts ? 2 : 0) +
        (_ocrDrafts ? 1 : 0);
    return selected.clamp(0, widget.temporaryDataMb).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTemporaryData = widget.temporaryDataMb > 0;

    return SafeArea(
      child: Container(
        key: const Key('settings-cleanup-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cleanup preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Choose temporary categories to simulate clearing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _PrototypeNotice(
              icon: Icons.warning_amber_rounded,
              message:
                  'No cache, export draft, OCR text, database record, or device file will be deleted.',
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!hasTemporaryData)
              Container(
                key: const Key('settings-cleanup-empty'),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.large),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline, color: AppColors.success),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'This preview already shows 0 MB of temporary data.',
                      ),
                    ),
                  ],
                ),
              )
            else ...<Widget>[
              CheckboxListTile(
                key: const Key('settings-cleanup-preview-cache'),
                value: _previewCache,
                onChanged: (bool? value) {
                  setState(() => _previewCache = value ?? false);
                },
                title: const Text('Preview cache'),
                subtitle: const Text('Illustrative 3 MB'),
                secondary: const Icon(Icons.image_outlined),
              ),
              CheckboxListTile(
                key: const Key('settings-cleanup-export-drafts'),
                value: _exportDrafts,
                onChanged: (bool? value) {
                  setState(() => _exportDrafts = value ?? false);
                },
                title: const Text('Export drafts'),
                subtitle: const Text('Illustrative 2 MB'),
                secondary: const Icon(Icons.picture_as_pdf_outlined),
              ),
              CheckboxListTile(
                key: const Key('settings-cleanup-ocr-drafts'),
                value: _ocrDrafts,
                onChanged: (bool? value) {
                  setState(() => _ocrDrafts = value ?? false);
                },
                title: const Text('OCR drafts'),
                subtitle: const Text('Illustrative 1 MB'),
                secondary: const Icon(Icons.text_snippet_outlined),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('settings-run-cleanup-preview'),
              onPressed: !hasTemporaryData || _selectedMb == 0
                  ? null
                  : () => Navigator.of(context).pop(
                        CleanupPreviewResult(releasedMb: _selectedMb),
                      ),
              icon: const Icon(Icons.cleaning_services_rounded),
              label: Text('Simulate clearing $_selectedMb MB'),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPreviewResult {
  const PrivacyPreviewResult({
    required this.diagnosticsEnabled,
    required this.crashReportsEnabled,
  });

  final bool diagnosticsEnabled;
  final bool crashReportsEnabled;
}

class PrivacyDetailsSheet extends StatefulWidget {
  const PrivacyDetailsSheet({
    required this.diagnosticsEnabled,
    required this.crashReportsEnabled,
    super.key,
  });

  final bool diagnosticsEnabled;
  final bool crashReportsEnabled;

  @override
  State<PrivacyDetailsSheet> createState() => _PrivacyDetailsSheetState();
}

class _PrivacyDetailsSheetState extends State<PrivacyDetailsSheet> {
  late bool _diagnosticsEnabled;
  late bool _crashReportsEnabled;

  @override
  void initState() {
    super.initState();
    _diagnosticsEnabled = widget.diagnosticsEnabled;
    _crashReportsEnabled = widget.crashReportsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const Key('settings-privacy-details-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Privacy details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Review the intended local-first privacy model.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _PrototypeNotice(
              icon: Icons.verified_user_outlined,
              message:
                  'Preview controls only — no analytics, crash service, permission, upload, or saved consent is connected.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _PrivacyPrincipleTile(
              icon: Icons.smartphone_outlined,
              title: 'Core scanning stays local',
              subtitle:
                  'The planned offline flow keeps camera captures and essential processing on the device.',
            ),
            const _PrivacyPrincipleTile(
              icon: Icons.cloud_off_outlined,
              title: 'No silent upload',
              subtitle:
                  'Cloud backup remains off until the user explicitly enables it in a later phase.',
            ),
            const _PrivacyPrincipleTile(
              icon: Icons.no_accounts_outlined,
              title: 'Account remains optional',
              subtitle:
                  'Basic scanning and export are intended to work without creating an account.',
            ),
            const Divider(height: AppSpacing.xl),
            SwitchListTile.adaptive(
              key: const Key('settings-privacy-diagnostics'),
              value: _diagnosticsEnabled,
              onChanged: (bool value) {
                setState(() => _diagnosticsEnabled = value);
              },
              secondary: const Icon(Icons.query_stats_outlined),
              title: const Text('Anonymous usage diagnostics'),
              subtitle: const Text('Temporary preference preview only'),
            ),
            SwitchListTile.adaptive(
              key: const Key('settings-privacy-crash-reports'),
              value: _crashReportsEnabled,
              onChanged: (bool value) {
                setState(() => _crashReportsEnabled = value);
              },
              secondary: const Icon(Icons.bug_report_outlined),
              title: const Text('Crash reports'),
              subtitle: const Text('No reporting service is connected'),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('settings-save-privacy-preview'),
              onPressed: () => Navigator.of(context).pop(
                PrivacyPreviewResult(
                  diagnosticsEnabled: _diagnosticsEnabled,
                  crashReportsEnabled: _crashReportsEnabled,
                ),
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Apply for this session'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
      ),
    );
  }
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PrivacyPrincipleTile extends StatelessWidget {
  const _PrivacyPrincipleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
