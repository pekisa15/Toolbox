import 'package:flutter/material.dart';

Color? getDefaultInputColor(BuildContext context, ColorScheme colorScheme) {
  return Theme.of(context).brightness == Brightness.dark
      ? colorScheme.inverseSurface
      : colorScheme.onInverseSurface;
}