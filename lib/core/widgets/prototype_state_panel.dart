import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum PrototypeStateKind { loading, empty, error }

class PrototypeStatePanel extends StatelessWidget {
  const PrototypeStatePanel({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final PrototypeStateKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  IconData get _icon => switch (kind) {
        PrototypeStateKind.loading => Icons.hourglass_top_rounded,
        PrototypeStateKind.empty => Icons.inbox_outlined,
        PrototypeStateKind.error => Icons.error_outline_rounded,
      };

  Color get _foreground => switch (kind) {
        PrototypeStateKind.loading => AppColors.info,
        PrototypeStateKind.empty => AppColors.textMuted,
        PrototypeStateKind.error => AppColors.destructive,
      };

  Color get _background => switch (kind) {
        PrototypeStateKind.loading => AppColors.infoSoft,
        PrototypeStateKind.empty => AppColors.surface,
        PrototypeStateKind.error => AppColors.destructiveSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.extraLarge),
          ),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (kind == PrototypeStateKind.loading)
              const SizedBox.square(
                dimension: 42,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(_icon, size: compact ? 36 : 46, color: _foreground),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
