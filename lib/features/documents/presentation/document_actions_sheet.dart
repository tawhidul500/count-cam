import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

enum DocumentManagementAction {
  rename,
  move,
  toggleFavorite,
  info,
  delete,
}

class DocumentActionsSheet extends StatelessWidget {
  const DocumentActionsSheet({
    required this.document,
    required this.currentTitle,
    required this.currentFolder,
    required this.isFavorite,
    required this.isMarkedDeleted,
    super.key,
  });

  final DocumentSummary document;
  final String currentTitle;
  final String currentFolder;
  final bool isFavorite;
  final bool isMarkedDeleted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const Key('document-actions-sheet'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.navySurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.workspaceMuted,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              currentTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${document.pageCount} page${document.pageCount == 1 ? '' : 's'} • $currentFolder',
              style: const TextStyle(color: AppColors.workspaceMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('document-actions-prototype-notice'),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.navyElevated,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.medium),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline_rounded, color: AppColors.warning),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Prototype actions only — rename, move, favorite, and delete do not change device storage.',
                      style: TextStyle(color: AppColors.workspaceMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionTile(
              key: const Key('document-action-rename'),
              icon: Icons.drive_file_rename_outline_rounded,
              title: 'Rename',
              subtitle: 'Change the title temporarily',
              onTap: () => Navigator.of(context).pop(
                DocumentManagementAction.rename,
              ),
            ),
            _ActionTile(
              key: const Key('document-action-move'),
              icon: Icons.drive_file_move_outline,
              title: 'Move to folder',
              subtitle: 'Current temporary folder: $currentFolder',
              onTap: () => Navigator.of(context).pop(
                DocumentManagementAction.move,
              ),
            ),
            _ActionTile(
              key: const Key('document-action-favorite'),
              icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              iconColor: isFavorite ? AppColors.warning : null,
              title: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              subtitle: 'This preference resets when the viewer closes',
              onTap: () => Navigator.of(context).pop(
                DocumentManagementAction.toggleFavorite,
              ),
            ),
            _ActionTile(
              key: const Key('document-action-info'),
              icon: Icons.info_outline_rounded,
              title: 'Document info',
              subtitle: 'Review mock metadata',
              onTap: () => Navigator.of(context).pop(
                DocumentManagementAction.info,
              ),
            ),
            _ActionTile(
              key: const Key('document-action-delete'),
              icon: isMarkedDeleted
                  ? Icons.restore_from_trash_outlined
                  : Icons.delete_outline_rounded,
              iconColor: AppColors.destructive,
              title: isMarkedDeleted ? 'Clear deletion mark' : 'Delete document',
              subtitle: isMarkedDeleted
                  ? 'Undo the temporary deletion state'
                  : 'Mark this preview for deletion only',
              onTap: () => Navigator.of(context).pop(
                DocumentManagementAction.delete,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      leading: Icon(icon, color: iconColor ?? AppColors.workspaceText),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.workspaceMuted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.workspaceMuted,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
      ),
    );
  }
}
