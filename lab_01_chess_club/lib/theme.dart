import 'package:flutter/material.dart';

/// One theme builder for both brightnesses.
///
/// The seed is read from the default Material scheme, so lib/ contains no
/// hard-coded colour values: every colour comes from a ColorScheme.
ThemeData buildTheme(Brightness brightness) {
  final seed = ThemeData().colorScheme.primary;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
  );
}
