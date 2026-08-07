import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AutoCapturePrototypeSettings {
  const AutoCapturePrototypeSettings({
    this.enabled = false,
    this.stabilityGuidance = true,
    this.edgeGuidance = true,
  });

  final bool enabled;
  final bool stabilityGuidance;
  final bool edgeGuidance;
}

class AutoCaptureSettingsSheet extends StatefulWidget {
  const AutoCaptureSettingsSheet({
    required this.initialSettings,
    super.key,
  });

  final AutoCapturePrototypeSettings initialSettings;

  static Future<AutoCapturePrototypeSettings?> show(
    BuildContext context, {
    required AutoCapturePrototypeSettings initialSettings,
  }) {
    return showModalBottomSheet<AutoCapturePrototypeSettings>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navySurface,
      builder: (BuildContext context) => AutoCaptureSettingsSheet(
        initialSettings: initialSettings,
      ),
    );
  }

  @override
  State<AutoCaptureSettingsSheet> createState() =>
      _AutoCaptureSettingsSheetState();
}

class _AutoCaptureSettingsSheetState extends State<AutoCaptureSettingsSheet> {
  late bool _enabled;
  late bool _stabilityGuidance;
  late bool _edgeGuidance;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialSettings.enabled;
    _stabilityGuidance = widget.initialSettings.stabilityGuidance;
    _edgeGuidance = widget.initialSettings.edgeGuidance;
  }

  void _apply() {
    Navigator.of(context).pop(
      AutoCapturePrototypeSettings(
        enabled: _enabled,
        stabilityGuidance: _stabilityGuidance,
        edgeGuidance: _edgeGuidance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: SafeArea(
        child: SingleChildScrollView(
          key: const Key('scanner-auto-capture-sheet'),
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Auto-capture preview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.workspaceText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close auto-capture settings',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                key: const Key('scanner-auto-capture-disclosure'),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.navyElevated,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.medium),
                  ),
                ),
                child: const Text(
                  'Education prototype only — no camera frames are analysed and no capture is triggered.',
                  style: TextStyle(color: AppColors.workspaceMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                key: const Key('scanner-auto-capture-switch'),
                value: _enabled,
                onChanged: (bool value) => setState(() => _enabled = value),
                title: const Text('Auto capture'),
                subtitle: Text(
                  _enabled
                      ? 'Preview is on for this scanner session.'
                      : 'Manual capture remains the visible default.',
                ),
                secondary: const Icon(Icons.auto_awesome_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(color: AppColors.navyElevated),
              SwitchListTile.adaptive(
                key: const Key('scanner-auto-capture-stability'),
                value: _stabilityGuidance,
                onChanged: (bool value) =>
                    setState(() => _stabilityGuidance = value),
                title: const Text('Stability guidance'),
                subtitle: const Text(
                  'A future camera flow can wait until the phone and page appear steady.',
                ),
                secondary: const Icon(Icons.motion_photos_paused_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile.adaptive(
                key: const Key('scanner-auto-capture-edge-guidance'),
                value: _edgeGuidance,
                onChanged: (bool value) =>
                    setState(() => _edgeGuidance = value),
                title: const Text('Edge guidance'),
                subtitle: const Text(
                  'A future detector can ask for all four page edges before capture.',
                ),
                secondary: const Icon(Icons.crop_free_rounded),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.navyElevated,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.large),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _EducationRow(
                      icon: Icons.pan_tool_alt_outlined,
                      text: 'Hold the device steady above the page.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _EducationRow(
                      icon: Icons.document_scanner_outlined,
                      text: 'Keep every document edge visible and avoid glare.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _EducationRow(
                      icon: Icons.check_circle_outline_rounded,
                      text: 'Review every captured page before keeping it.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('scanner-auto-capture-confirm'),
                onPressed: _apply,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Apply preview settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EducationRow extends StatelessWidget {
  const _EducationRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.workspaceText),
          ),
        ),
      ],
    );
  }
}
