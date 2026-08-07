import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/widgets/mock_document_page.dart';
import 'package:flutter/material.dart';

final class CropPrototypeResult {
  const CropPrototypeResult({required this.corners});

  final List<Offset> corners;
}

class CropAdjustmentScreen extends StatefulWidget {
  const CropAdjustmentScreen({
    required this.document,
    required this.pageNumber,
    super.key,
  });

  final DocumentSummary document;
  final int pageNumber;

  @override
  State<CropAdjustmentScreen> createState() => _CropAdjustmentScreenState();
}

class _CropAdjustmentScreenState extends State<CropAdjustmentScreen> {
  static const List<Offset> _defaultCorners = <Offset>[
    Offset(0.14, 0.12),
    Offset(0.86, 0.12),
    Offset(0.88, 0.88),
    Offset(0.12, 0.88),
  ];

  late List<Offset> _corners;

  @override
  void initState() {
    super.initState();
    _corners = List<Offset>.of(_defaultCorners);
  }

  void _resetCorners() {
    setState(() => _corners = List<Offset>.of(_defaultCorners));
  }

  void _moveCorner(int index, Offset delta, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return;
    }

    final Offset current = _corners[index];
    final Offset next = Offset(
      (current.dx + delta.dx / canvasSize.width).clamp(0.04, 0.96).toDouble(),
      (current.dy + delta.dy / canvasSize.height).clamp(0.04, 0.96).toDouble(),
    );

    final List<Offset> updatedCorners = List<Offset>.of(_corners);
    updatedCorners[index] = next;
    setState(() => _corners = updatedCorners);
  }

  void _applyPrototype() {
    Navigator.of(context).pop(
      CropPrototypeResult(corners: List<Offset>.unmodifiable(_corners)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('crop-adjustment-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-crop-adjustment'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close crop adjustment',
          ),
          title: const Text('Adjust crop'),
          actions: <Widget>[
            TextButton.icon(
              key: const Key('apply-crop-prototype'),
              onPressed: _applyPrototype,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Apply'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              const _CropPrototypeNotice(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Page ${widget.pageNumber}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Drag each corner to outline the mock document.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.workspaceMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      key: const Key('reset-crop-corners'),
                      onPressed: _resetCorners,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: AspectRatio(
                        aspectRatio: 0.72,
                        child: _CropCanvas(
                          document: widget.document,
                          pageNumber: widget.pageNumber,
                          corners: _corners,
                          onMoveCorner: _moveCorner,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const _CropGuidanceBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropPrototypeNotice extends StatelessWidget {
  const _CropPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('crop-prototype-notice'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.crop_free_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Crop prototype — no perspective correction or file changes are applied',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCanvas extends StatelessWidget {
  const _CropCanvas({
    required this.document,
    required this.pageNumber,
    required this.corners,
    required this.onMoveCorner,
  });

  final DocumentSummary document;
  final int pageNumber;
  final List<Offset> corners;
  final void Function(int index, Offset delta, Size canvasSize) onMoveCorner;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final List<Offset> pixelCorners = corners
            .map(
              (Offset corner) => Offset(
                corner.dx * canvasSize.width,
                corner.dy * canvasSize.height,
              ),
            )
            .toList(growable: false);

        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
          child: ColoredBox(
            color: AppColors.navySurface,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.9,
                  child: MockDocumentPage(
                    pageNumber: pageNumber,
                    documentTitle: document.title,
                    fileType: document.fileType,
                    semanticLabel: 'Mock page behind crop handles',
                    compact: true,
                  ),
                ),
                CustomPaint(
                  painter: _CropOverlayPainter(corners: pixelCorners),
                ),
                for (int index = 0; index < pixelCorners.length; index++)
                  Positioned(
                    left: pixelCorners[index].dx - 22,
                    top: pixelCorners[index].dy - 22,
                    child: _CropHandle(
                      key: Key('crop-corner-$index'),
                      index: index,
                      onDrag: (Offset delta) => onMoveCorner(index, delta, canvasSize),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CropHandle extends StatelessWidget {
  const _CropHandle({
    required this.index,
    required this.onDrag,
    super.key,
  });

  final int index;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Crop corner ${index + 1}. Drag to adjust.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (DragUpdateDetails details) => onDrag(details.delta),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.workspaceText, width: 3),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({required this.corners});

  final List<Offset> corners;

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) {
      return;
    }

    final Path borderPath = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(borderPath, borderPaint);

    final Paint gridPaint = Paint()
      ..color = AppColors.primaryMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int step = 1; step <= 2; step++) {
      final double t = step / 3;
      final Offset top = Offset.lerp(corners[0], corners[1], t)!;
      final Offset bottom = Offset.lerp(corners[3], corners[2], t)!;
      final Offset left = Offset.lerp(corners[0], corners[3], t)!;
      final Offset right = Offset.lerp(corners[1], corners[2], t)!;
      canvas.drawLine(top, bottom, gridPaint);
      canvas.drawLine(left, right, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.corners != corners;
  }
}

class _CropGuidanceBar extends StatelessWidget {
  const _CropGuidanceBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: _GuidanceItem(
              icon: Icons.open_with_rounded,
              label: 'Drag corners',
            ),
          ),
          Expanded(
            child: _GuidanceItem(
              icon: Icons.grid_3x3_rounded,
              label: 'Align edges',
            ),
          ),
          Expanded(
            child: _GuidanceItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Apply preview',
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceItem extends StatelessWidget {
  const _GuidanceItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.workspaceMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
