import 'dart:async';

import 'package:clearscan/app/configuration/app_config.dart';
import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/adaptive_content_frame.dart';
import 'package:clearscan/core/widgets/status_announcement.dart';
import 'package:clearscan/features/onboarding/presentation/onboarding_preview_screen.dart';
import 'package:clearscan/features/settings/presentation/help_feedback_screen.dart';
import 'package:clearscan/features/settings/presentation/legal_content_screen.dart';
import 'package:clearscan/features/settings/presentation/settings_detail_sheets.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.onGoHome, super.key});

  final VoidCallback? onGoHome;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCapture = true;
  bool _saveOriginals = true;
  bool _diagnosticsEnabled = false;
  bool _crashReportsEnabled = false;

  String _defaultScanMode = 'Document';
  String _imageQuality = 'High';
  String _defaultPdfSize = 'A4';
  String _ocrLanguage = 'English';

  int _storageUsedMb = 36;
  int _temporaryDataMb = 6;
  String? _statusMessage;

  Future<void> _openHelpFeedback() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HelpFeedbackScreen(),
      ),
    );
  }

  Future<void> _openLegalContent(LegalContentKind kind) async {
    final Widget screen = switch (kind) {
      LegalContentKind.about => const LegalContentScreen.about(),
      LegalContentKind.privacyPolicy =>
        const LegalContentScreen.privacyPolicy(),
      LegalContentKind.terms => const LegalContentScreen.terms(),
    };

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) => screen),
    );
  }

  Future<void> _openOnboardingPreview() async {
    final bool? continueToHome = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const OnboardingPreviewScreen(),
        fullscreenDialog: true,
      ),
    );

    if (!mounted || continueToHome != true) {
      return;
    }

    widget.onGoHome?.call();
  }

  Future<void> _choosePreference({
    required String keyPrefix,
    required String title,
    required String description,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => SettingsChoiceSheet(
        keyPrefix: keyPrefix,
        title: title,
        description: description,
        selectedValue: selectedValue,
        options: options,
      ),
    );

    if (!mounted || result == null || result == selectedValue) {
      return;
    }

    setState(() {
      onSelected(result);
      _statusMessage =
          '$title changed to $result for this session only. No saved setting was changed.';
    });
  }

  Future<void> _openStorageDetails() async {
    final SettingsStorageAction? action =
        await showModalBottomSheet<SettingsStorageAction>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => StorageDetailsSheet(
        totalUsedMb: _storageUsedMb,
        temporaryDataMb: _temporaryDataMb,
      ),
    );

    if (!mounted || action != SettingsStorageAction.cleanup) {
      return;
    }

    await _openCleanupPreview();
  }

  Future<void> _openCleanupPreview() async {
    final CleanupPreviewResult? result =
        await showModalBottomSheet<CleanupPreviewResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CleanupPreviewSheet(
        temporaryDataMb: _temporaryDataMb,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final int releasedMb =
        result.releasedMb.clamp(0, _temporaryDataMb).toInt();
    setState(() {
      _temporaryDataMb -= releasedMb;
      _storageUsedMb -= releasedMb;
      _statusMessage =
          'Simulated clearing $releasedMb MB. No cache, document, database record, or device file was deleted.';
    });
  }

  Future<void> _openPrivacyDetails() async {
    final PrivacyPreviewResult? result =
        await showModalBottomSheet<PrivacyPreviewResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => PrivacyDetailsSheet(
        diagnosticsEnabled: _diagnosticsEnabled,
        crashReportsEnabled: _crashReportsEnabled,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _diagnosticsEnabled = result.diagnosticsEnabled;
      _crashReportsEnabled = result.crashReportsEnabled;
      _statusMessage =
          'Privacy preview updated for this session. No consent, analytics, crash report, or account setting was saved.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AdaptiveContentFrame(
        padding: EdgeInsets.zero,
        maxWidth: 920,
        child: ListView(
        key: const PageStorageKey<String>('settings-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.display + AppSpacing.xl,
        ),
        children: <Widget>[
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose how ClearScan captures, exports, and protects documents.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            key: const Key('settings-prototype-notice'),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.all(
                Radius.circular(AppRadius.large),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.tune_rounded, color: AppColors.warning),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Settings prototype — every preference, privacy control, storage value, and cleanup action is temporary. Nothing is saved and device data is unchanged.',
                  ),
                ),
              ],
            ),
          ),
          if (_statusMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            StatusAnnouncement(
              key: const Key('settings-session-status'),
              message: _statusMessage!,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const _PrivacyCard(),
          const SizedBox(height: AppSpacing.xl),
          const _SettingsSectionLabel(label: 'Scanning'),
          _SettingsPanel(
            children: <Widget>[
              SwitchListTile.adaptive(
                key: const Key('settings-auto-capture'),
                value: _autoCapture,
                onChanged: (bool value) {
                  setState(() {
                    _autoCapture = value;
                    _statusMessage =
                        'Auto capture ${value ? 'enabled' : 'disabled'} for this session only.';
                  });
                },
                secondary: const Icon(Icons.center_focus_strong_outlined),
                title: const Text('Auto capture'),
                subtitle: const Text('Capture when the document is stable'),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-default-scan-mode'),
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text('Default scan mode'),
                subtitle: Text(_defaultScanMode),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _choosePreference(
                    keyPrefix: 'settings-scan-mode',
                    title: 'Default scan mode',
                    description:
                        'Choose the scan mode shown first in the future camera workspace.',
                    selectedValue: _defaultScanMode,
                    options: SettingsPreviewOptions.scanModes,
                    onSelected: (String value) => _defaultScanMode = value,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-image-quality'),
                leading: const Icon(Icons.high_quality_outlined),
                title: const Text('Image quality'),
                subtitle: Text(_imageQuality),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _choosePreference(
                    keyPrefix: 'settings-image-quality',
                    title: 'Image quality',
                    description:
                        'Preview the intended balance between clarity, storage, and processing time.',
                    selectedValue: _imageQuality,
                    options: SettingsPreviewOptions.imageQualities,
                    onSelected: (String value) => _imageQuality = value,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SettingsSectionLabel(label: 'Export and text'),
          _SettingsPanel(
            children: <Widget>[
              ListTile(
                key: const Key('settings-default-pdf-size'),
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Default PDF size'),
                subtitle: Text(_defaultPdfSize),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _choosePreference(
                    keyPrefix: 'settings-pdf-size',
                    title: 'Default PDF size',
                    description:
                        'Choose the page size preselected in the PDF export workspace.',
                    selectedValue: _defaultPdfSize,
                    options: SettingsPreviewOptions.pdfSizes,
                    onSelected: (String value) => _defaultPdfSize = value,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-ocr-language'),
                leading: const Icon(Icons.translate_rounded),
                title: const Text('OCR language'),
                subtitle: Text(_ocrLanguage),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _choosePreference(
                    keyPrefix: 'settings-ocr-language',
                    title: 'OCR language',
                    description:
                        'Choose the language preselected in the future OCR engine.',
                    selectedValue: _ocrLanguage,
                    options: SettingsPreviewOptions.ocrLanguages,
                    onSelected: (String value) => _ocrLanguage = value,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SettingsSectionLabel(label: 'Privacy and storage'),
          _SettingsPanel(
            children: <Widget>[
              SwitchListTile.adaptive(
                key: const Key('settings-save-originals'),
                value: _saveOriginals,
                onChanged: (bool value) {
                  setState(() {
                    _saveOriginals = value;
                    _statusMessage =
                        'Keep original captures ${value ? 'enabled' : 'disabled'} for this session only.';
                  });
                },
                secondary: const Icon(Icons.layers_outlined),
                title: const Text('Keep original captures'),
                subtitle: const Text('Preserve unedited images on this device'),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-storage-details'),
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Storage usage'),
                subtitle: Text(
                  '$_storageUsedMb MB used • $_temporaryDataMb MB temporary',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(_openStorageDetails()),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-cleanup'),
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Clean temporary data'),
                subtitle: Text(
                  _temporaryDataMb > 0
                      ? 'Preview up to $_temporaryDataMb MB of cleanup'
                      : 'No temporary data shown in this session',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(_openCleanupPreview()),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-privacy-details'),
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy details'),
                subtitle: Text(
                  'Diagnostics ${_diagnosticsEnabled ? 'on' : 'off'} • Crash reports ${_crashReportsEnabled ? 'on' : 'off'}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(_openPrivacyDetails()),
              ),
              const Divider(height: 1),
              const ListTile(
                key: Key('settings-cloud-backup'),
                leading: Icon(Icons.cloud_off_outlined),
                title: Text('Cloud backup'),
                subtitle: Text('Off — local only'),
                trailing: Icon(Icons.lock_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SettingsSectionLabel(label: 'Experience preview'),
          _SettingsPanel(
            children: <Widget>[
              ListTile(
                key: const Key('settings-open-onboarding'),
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Preview onboarding'),
                subtitle: const Text(
                  'Review welcome, privacy, and camera education',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openOnboardingPreview,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SettingsSectionLabel(label: 'Support and legal'),
          _SettingsPanel(
            children: <Widget>[
              ListTile(
                key: const Key('settings-open-help-feedback'),
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Help and feedback'),
                subtitle: const Text('FAQs and safe feedback preview'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openHelpFeedback,
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-open-privacy-policy'),
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Privacy policy'),
                subtitle: const Text('Draft content — legal review required'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _openLegalContent(LegalContentKind.privacyPolicy),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-open-terms'),
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Terms of use'),
                subtitle: const Text('Draft content — not a contract'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _openLegalContent(LegalContentKind.terms),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-open-about'),
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About ClearScan'),
                subtitle: const Text(
                  'Version ${AppConfig.versionName} • ${AppConfig.releaseLabel}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  _openLegalContent(LegalContentKind.about),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.success,
            size: 34,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Local-first by design',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${AppConfig.appName} will keep core scanning useful without an account.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ],
        ),
      );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
