import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 0),
    this.showDuration = const Duration(seconds: 10),
    this.backgroundColor,
    this.textStyle,
  });

  final String message;
  final Widget child;
  final Duration waitDuration;
  final Duration showDuration;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Tooltip(
      message: message,
      textStyle: textStyle ?? TextStyle(color: theme.colorScheme.onPrimary),
      waitDuration: waitDuration,
      showDuration: showDuration,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),

      child: child,
    );
  }
}
