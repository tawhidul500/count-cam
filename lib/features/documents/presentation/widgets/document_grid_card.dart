import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

class DocumentGridCard extends StatelessWidget {
  const DocumentGridCard({
    required this.document,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.isSelected = false,
    super.key,
  });

  final DocumentSummary document;
  final VoidCallback onTap;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.medium),
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadius.small),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.description_outlined
                              : Icons.badge_outlined,
                          color: isPdf
                              ? AppColors.destructive
                              : AppColors.info,
                          size: 42,
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: selectionMode
                          ? DecoratedBox(
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => onTap(),
                                semanticLabel: isSelected
                                    ? 'Deselect ${document.title}'
                                    : 'Select ${document.title}',
                              ),
                            )
                          : Icon(
                              document.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: document.isFavorite
                                  ? AppColors.warning
                                  : AppColors.textMuted,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                document.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${document.pageCount} page${document.pageCount == 1 ? '' : 's'} • ${document.folderName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                document.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
