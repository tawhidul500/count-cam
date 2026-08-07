import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    required this.document,
    this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.isSelected = false,
    super.key,
  });

  final DocumentSummary document;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bool isPdf = document.fileType == DocumentFileType.pdf;

    return Semantics(
      button: true,
      selected: selectionMode ? isSelected : null,
      label:
          '${document.title}, ${document.pageCount} ${document.pageCount == 1 ? 'page' : 'pages'}, ${document.folderName}${document.isFavorite ? ', favorite' : ''}',
      child: Material(
        color: isSelected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.large),
            ),
            border: Border.fromBorderSide(
              BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              _DocumentPreview(isPdf: isPdf),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            document.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (document.isFavorite)
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 18,
                            semanticLabel: 'Favorite document',
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(document.subtitle),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: <Widget>[
                        _MetadataPill(
                          label: isPdf ? 'PDF' : 'JPG',
                          background: isPdf
                              ? AppColors.destructiveSoft
                              : AppColors.infoSoft,
                          foreground: isPdf
                              ? AppColors.destructive
                              : AppColors.info,
                        ),
                        _MetadataPill(
                          label:
                              '${document.pageCount} page${document.pageCount == 1 ? '' : 's'}',
                          background: AppColors.surfaceMuted,
                          foreground: AppColors.textSecondary,
                        ),
                        _MetadataPill(
                          label: document.folderName,
                          background: AppColors.primarySoft,
                          foreground: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap?.call(),
                  semanticLabel: isSelected
                      ? 'Deselect ${document.title}'
                      : 'Select ${document.title}',
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.isPdf});

  final bool isPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 72,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(
          isPdf ? Icons.description_outlined : Icons.badge_outlined,
          color: isPdf ? AppColors.destructive : AppColors.info,
          size: 25,
        ),
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
