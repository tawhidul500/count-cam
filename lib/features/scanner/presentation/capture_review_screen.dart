import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/crop_editor/presentation/crop_adjustment_screen.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/widgets/mock_document_page.dart';
import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';
import 'package:flutter/material.dart';

class CaptureReviewResult {
  const CaptureReviewResult({
    required this.kept,
    required this.cropAdjusted,
    required this.filter,
  });

  final bool kept;
  final bool cropAdjusted;
  final PrototypeFilter filter;
}

class CaptureReviewScreen extends StatefulWidget {
  const CaptureReviewScreen({
    required this.sourceLabel,
    required this.scanMode,
    this.pageNumber = 1,
    this.reviewingExistingPage = false,
    this.initialCropAdjusted = false,
    this.initialFilter = PrototypeFilter.original,
    super.key,
  });

  final String sourceLabel;
  final String scanMode;
  final int pageNumber;
  final bool reviewingExistingPage;
  final bool initialCropAdjusted;
  final PrototypeFilter initialFilter;

  @override
  State<CaptureReviewScreen> createState() => _CaptureReviewScreenState();
}

class _CaptureReviewScreenState extends State<CaptureReviewScreen> {
  late bool _cropAdjusted;
  late PrototypeFilter _filter;

  @override
  void initState() {
    super.initState();
    _cropAdjusted = widget.initialCropAdjusted;
    _filter = widget.initialFilter;
  }

  DocumentSummary get _previewDocument => DocumentSummary(
        id: 'scanner-review-preview-${widget.pageNumber}',
        title: '${widget.scanMode} preview',
        subtitle: 'Temporary scanner review',
        pageCount: 1,
        fileType: DocumentFileType.image,
      );

  void _close({required bool kept}) {
    Navigator.of(context).pop(
      CaptureReviewResult(
        kept: kept,
        cropAdjusted: _cropAdjusted,
        filter: _filter,
      ),
    );
  }

  Future<void> _openCrop() async {
    final CropPrototypeResult? result =
        await Navigator.of(context).push<CropPrototypeResult>(
      MaterialPageRoute<CropPrototypeResult>(
        builder: (BuildContext context) => CropAdjustmentScreen(
          document: _previewDocument,
          pageNumber: widget.pageNumber,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }
    setState(() => _cropAdjusted = true);
  }

  Future<void> _openFilter() async {
    final FilterPrototypeResult? result =
        await Navigator.of(context).push<FilterPrototypeResult>(
      MaterialPageRoute<FilterPrototypeResult>(
        builder: (BuildContext context) => FilterSelectionScreen(
          document: _previewDocument,
          pageNumber: widget.pageNumber,
          initialFilter: _filter,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }
    setState(() => _filter = result.filter);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('capture-review-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('capture-review-retake'),
            onPressed: () => _close(kept: false),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: widget.reviewingExistingPage
                ? 'Return without updating'
                : 'Return to scanner',
          ),
          title: Text('Review page ${widget.pageNumber}'),
          actions: <Widget>[
            TextButton.icon(
              key: const Key('capture-review-keep-page'),
              onPressed: () => _close(kept: true),
              icon: const Icon(Icons.check_rounded),
              label: Text(
                widget.reviewingExistingPage ? 'Update page' : 'Keep page',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _ReviewNotice(reviewingExistingPage: widget.reviewingExistingPage),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    _MetadataChip(
                      icon: Icons.filter_none_rounded,
                      label: 'Page ${widget.pageNumber}',
                    ),
                    _MetadataChip(
                      icon: Icons.input_rounded,
                      label: widget.sourceLabel,
                    ),
                    _MetadataChip(
                      icon: Icons.document_scanner_outlined,
                      label: widget.scanMode,
                    ),
                    if (_cropAdjusted)
                      const _MetadataChip(
                        key: Key('capture-review-crop-status'),
                        icon: Icons.crop_rounded,
                        label: 'Crop adjusted',
                      ),
                    if (_filter != PrototypeFilter.original)
                      _MetadataChip(
                        key: const Key('capture-review-filter-status'),
                        icon: _filter.icon,
                        label: _filter.label,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.navySurface,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.extraLarge),
                    ),
                  ),
                  child: Center(
                    child: MockDocumentPage(
                      pageNumber: widget.pageNumber,
                      documentTitle: _previewDocument.title,
                      fileType: DocumentFileType.image,
                      semanticLabel:
                          'Temporary scanner capture review page ${widget.pageNumber}',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('capture-review-open-crop'),
                        onPressed: _openCrop,
                        icon: const Icon(Icons.crop_rounded),
                        label: const Text('Adjust crop'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('capture-review-open-filter'),
                        onPressed: _openFilter,
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('Choose filter'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice({required this.reviewingExistingPage});

  final bool reviewingExistingPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('capture-review-prototype-notice'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
      ),
      child: Text(
        reviewingExistingPage
            ? 'Mock page review — changes remain in this temporary scanner session and are not saved.'
            : 'Mock capture review — no image was captured, imported, processed, or saved.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.workspaceMuted),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: const TextStyle(color: AppColors.workspaceText)),
        ],
      ),
    );
  }
}
