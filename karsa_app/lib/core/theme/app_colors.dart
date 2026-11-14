import 'package:flutter/painting.dart';

class AppColors {
  final Color ink;
  final Color muted;
  final Color rose;
  final Color pink;
  final Color line;
  final Color bg;
  final Color card;
  final Color blue;
  final bool isDark;

  const AppColors({
    required this.ink,
    required this.muted,
    required this.rose,
    required this.pink,
    required this.line,
    required this.bg,
    required this.card,
    required this.blue,
    required this.isDark,
  });

  /// Palet terang 1:1 dari `lightColors` di App.js
  static const AppColors light = AppColors(
    ink: Color(0xFF203E5A),
    muted: Color(0xFF8294A3),
    rose: Color(0xFFB1445D),
    pink: Color(0xFFC8526D),
    line: Color(0xFFEFDFD9),
    bg: Color(0xFFFFFAF7),
    card: Color(0xFFFFFDFB),
    blue: Color(0xFF6E9CC3),
    isDark: false,
  );

  /// Palet gelap 1:1 dari `darkColors` di App.js
  static const AppColors dark = AppColors(
    ink: Color(0xFFF3EAF0),
    muted: Color(0xFFBBC0CA),
    rose: Color(0xFFF09AB0),
    pink: Color(0xFFD56B85),
    line: Color(0xFF4B4049),
    bg: Color(0xFF211D27),
    card: Color(0xFF302832),
    blue: Color(0xFF85B2D1),
    isDark: true,
  );

  // Warna aksen tetap dari App.js
  static const Color splashSky = Color(0xFFA2D7FB);
  static const Color splashSafeSky = Color(0xFFB4DEF8);
  static const Color outerCanvasLight = Color(0xFFF4EDE9);
  static const Color navInactive = Color(0xFFA8B6BF);
  static const Color purpleStat = Color(0xFFC47DA1);
  static const Color greenStat = Color(0xFF84B99C);

  // Warna grafik kehadiran wali kelas
  static const Color attendanceHadir = Color(0xFF78B995);
  static const Color attendanceIzin = Color(0xFF79A6CD);
  static const Color attendanceSakit = Color(0xFFC58AAD);
  static const Color attendanceAlpa = Color(0xFFCD6C7D);
}
