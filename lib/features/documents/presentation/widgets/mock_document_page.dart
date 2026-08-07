import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

class MockDocumentPage extends StatelessWidget {
  const MockDocumentPage({
    required this.pageNumber,
    required this.documentTitle,
    required this.fileType,
    required this.semanticLabel,
    this.compact = false,
    super.key,
  });

  final int pageNumber;
  final String documentTitle;
  final DocumentFileType fileType;
  final String semanticLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = compact ? 280 : 520;

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: 0.72,
          child: Container(
            margin: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
            decoration: const BoxDecoration(
              color: AppColors.documentPaper,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: _PageContent(
              pageNumber: pageNumber,
              documentTitle: documentTitle,
              fileType: fileType,
              compact: compact,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.pageNumber,
    required this.documentTitle,
    required this.fileType,
    required this.compact,
  });

  final int pageNumber;
  final String documentTitle;
  final DocumentFileType fileType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: compact ? 30 : 42,
              height: compact ? 30 : 42,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
              ),
              child: Icon(
                fileType == DocumentFileType.pdf
                    ? Icons.description_outlined
                    : Icons.badge_outlined,
                color: AppColors.primaryDark,
                size: compact ? 18 : 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    documentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'ClearScan preview • Page $pageNumber',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
        Container(
          height: compact ? 8 : 12,
          decoration: const BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          ),
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        ...List<Widget>.generate(
          compact ? 7 : 10,
          (int index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: index % 3 == 2 ? 0.72 : 1,
              child: Container(
                height: compact ? 4 : 6,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: compact ? 34 : 54,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: compact ? 34 : 54,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
