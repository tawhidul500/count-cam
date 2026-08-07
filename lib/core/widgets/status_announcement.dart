import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum StatusAnnouncementTone { success, info, warning, error, workspace }

class StatusAnnouncement extends StatelessWidget {
  const StatusAnnouncement({
    required this.message,
    this.tone = StatusAnnouncementTone.success,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String message;
  final StatusAnnouncementTone tone;
  final TextAlign textAlign;

  Color get _background => switch (tone) {
        StatusAnnouncementTone.success => AppColors.successSoft,
        StatusAnnouncementTone.info => AppColors.infoSoft,
        StatusAnnouncementTone.warning => AppColors.warningSoft,
        StatusAnnouncementTone.error => AppColors.destructiveSoft,
        StatusAnnouncementTone.workspace => AppColors.navyElevated,
      };

  Color get _foreground => switch (tone) {
        StatusAnnouncementTone.success => AppColors.success,
        StatusAnnouncementTone.info => AppColors.info,
        StatusAnnouncementTone.warning => AppColors.warning,
        StatusAnnouncementTone.error => AppColors.destructive,
        StatusAnnouncementTone.workspace => AppColors.workspaceText,
      };

  IconData get _icon => switch (tone) {
        StatusAnnouncementTone.success => Icons.check_circle_outline_rounded,
        StatusAnnouncementTone.info => Icons.info_outline_rounded,
        StatusAnnouncementTone.warning => Icons.warning_amber_rounded,
        StatusAnnouncementTone.error => Icons.error_outline_rounded,
        StatusAnnouncementTone.workspace => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.medium),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(_icon, color: _foreground, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                textAlign: textAlign,
                style: TextStyle(
                  color: _foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
