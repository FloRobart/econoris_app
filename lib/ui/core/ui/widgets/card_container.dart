import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    required this.child,
    this.elevation = 1,
    this.padding,
    this.color,
    this.shape,
  });

  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
