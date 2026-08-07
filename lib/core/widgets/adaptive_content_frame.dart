import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AdaptiveContentFrame extends StatelessWidget {
  const AdaptiveContentFrame({
    required this.child,
    this.maxWidth = 960,
    this.padding,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontal = constraints.maxWidth >= 720
            ? AppSpacing.xl
            : AppSpacing.md;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
