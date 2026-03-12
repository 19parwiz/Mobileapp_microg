import 'package:flutter/material.dart';

/// Centers content and constrains max width on large screens.
///
/// On phones this keeps full width. On tablets/desktop it prevents
/// stretched layouts and improves readability.
class ResponsiveConstrained extends StatelessWidget {
  final Widget child;
  final double tabletMaxWidth;
  final double desktopMaxWidth;

  const ResponsiveConstrained({
    super.key,
    required this.child,
    this.tabletMaxWidth = 900,
    this.desktopMaxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxWidth = width >= 1200
            ? desktopMaxWidth
            : width >= 900
                ? tabletMaxWidth
                : double.infinity;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
