import 'package:flutter/painting.dart';
import 'dark_color_mapper.dart';

/// Dekorasi claymorphism 1:1 dari objek `clay` di App.js:
/// - Clay soft: radius 23, border putih 88% 2px, shadow 0 6 20 rgba(185,157,163,.17)
/// - Clay raised: radius 20, border putih 55% 2px, shadow 0 7 18 rgba(167,126,136,.24)
/// - Clay inset: border #F1E5E2 2px, tanpa bayangan
class ClayStyles {
  ClayStyles._();

  static BoxDecoration soft({
    required Color color,
    required bool isDark,
    double radius = 23,
    Color? borderColor,
    double borderWidth = 2,
    BorderRadiusGeometry? customRadius,
  }) {
    final resolvedBg = DarkColorMapper.surface(color, isDark: isDark);
    final rawBorder = borderColor ?? const Color(0xE0FFFFFF); // putih 88%
    final resolvedBorder = DarkColorMapper.border(rawBorder, isDark: isDark);

    return BoxDecoration(
      color: resolvedBg,
      borderRadius: customRadius ?? BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: isDark
              ? const Color(0x4508070A)
              : const Color(0x2BB99DA3), // rgba(185,157,163,0.17)
          offset: const Offset(0, 6),
          blurRadius: 20,
        ),
      ],
    );
  }

  static BoxDecoration raised({
    required Color color,
    required bool isDark,
    double radius = 20,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    final rawBorder = borderColor ?? const Color(0x8CFFFFFF); // putih 55%
    final resolvedBorder = DarkColorMapper.border(rawBorder, isDark: isDark);

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: isDark
              ? const Color(0x5208070A)
              : const Color(0x3DA77E88), // rgba(167,126,136,0.24)
          offset: const Offset(0, 7),
          blurRadius: 18,
        ),
      ],
    );
  }

  static BoxDecoration inset({
    required Color color,
    required bool isDark,
    double radius = 14,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    final resolvedBg = DarkColorMapper.surface(color, isDark: isDark);
    final rawBorder = borderColor ?? const Color(0xFFF1E5E2);
    final resolvedBorder = DarkColorMapper.border(rawBorder, isDark: isDark);

    return BoxDecoration(
      color: resolvedBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
    );
  }
}
