import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';
import 'package:clearscan/features/scanner/presentation/scanner_session_page.dart';
import 'package:flutter/material.dart';

class CaptureSessionPageStrip extends StatelessWidget {
  const CaptureSessionPageStrip({
    required this.pages,
    required this.selectedIndex,
    required this.onSelected,
    required this.onReview,
    required this.onAdd,
    required this.onRemove,
    required this.onFinish,
    super.key,
  });

  final List<ScannerSessionPage> pages;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onReview;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const SizedBox.shrink();
    }

    final String countLabel = pages.length == 1 ? '1 page' : '${pages.length} pages';

    return Container(
      key: const Key('scanner-session-page-strip'),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.collections_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Capture session',
                  style: TextStyle(
                    color: AppColors.workspaceText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                countLabel,
                key: const Key('scanner-session-page-count'),
                style: const TextStyle(color: AppColors.workspaceMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pages.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (BuildContext context, int index) {
                final ScannerSessionPage page = pages[index];
                return _SessionThumbnail(
                  key: Key('scanner-session-page-$index'),
                  pageNumber: index + 1,
                  page: page,
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Generated mock thumbnails only — no image or file exists.',
            key: Key('scanner-session-thumbnail-disclosure'),
            style: TextStyle(
              color: AppColors.workspaceMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              TextButton.icon(
                key: const Key('scanner-session-review-selected'),
                onPressed: onReview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review'),
              ),
              TextButton.icon(
                key: const Key('scanner-session-remove-selected'),
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                label: const Text('Remove'),
              ),
              TextButton.icon(
                key: const Key('scanner-session-add-page'),
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add page'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FilledButton.icon(
            key: const Key('scanner-session-finish'),
            onPressed: onFinish,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Finish session'),
          ),
        ],
      ),
    );
  }
}

class _SessionThumbnail extends StatelessWidget {
  const _SessionThumbnail({
    required this.pageNumber,
    required this.page,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int pageNumber;
  final ScannerSessionPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: 'Select mock page $pageNumber',
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.navyElevated,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
          child: Container(
            width: 82,
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.medium),
              ),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.navyElevated,
                width: 2,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 46,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.documentPaper,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.small),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(height: 4, color: AppColors.textPrimary),
                      const SizedBox(height: 4),
                      Container(height: 2, color: AppColors.border),
                      const SizedBox(height: 3),
                      Container(height: 2, color: AppColors.border),
                      const SizedBox(height: 3),
                      Container(height: 2, color: AppColors.border),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '$pageNumber',
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryDark
                              : AppColors.workspaceText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (page.cropAdjusted)
                        const Icon(Icons.crop_rounded, size: 13),
                      if (page.filter != PrototypeFilter.original)
                        Icon(page.filter.icon, size: 13),
                    ],
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
