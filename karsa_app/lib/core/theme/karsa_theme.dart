import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class KarsaThemeScope extends InheritedWidget {
  final AppColors colors;
  final AppTypography text;

  const KarsaThemeScope({
    super.key,
    required this.colors,
    required this.text,
    required super.child,
  });

  static KarsaThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KarsaThemeScope>();
    assert(scope != null, 'KarsaThemeScope tidak ditemukan pada widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(KarsaThemeScope oldWidget) {
    return oldWidget.colors.isDark != colors.isDark;
  }
}

class KarsaTheme {
  KarsaTheme._();

  static ThemeData buildMaterialTheme(AppColors c) {
    final brightness = c.isDark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: c.rose,
      brightness: brightness,
      primary: c.rose,
      secondary: c.blue,
      surface: c.card,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return c.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.rose;
          return c.line;
        }),
      ),
    );
  }
}
