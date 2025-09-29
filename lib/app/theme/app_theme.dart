import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'palette.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppPalette.primary,
    secondary: AppPalette.secondary,
    tertiary: AppPalette.tertiary,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: _textTheme,
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
    centerTitle: false,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppPalette.primary,
    secondary: AppPalette.secondary,
    tertiary: AppPalette.tertiary,
    surface: AppPalette.surface,
  ),
  scaffoldBackgroundColor: AppPalette.background,
  textTheme:
      _textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    centerTitle: false,
  ),
);

const _textTheme = TextTheme(
  displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
  displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
  displaySmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
  headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
  headlineSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
  titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
  titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  titleSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
  bodyLarge: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
  bodyMedium: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
  bodySmall: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
  labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
  labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
);
