import 'package:flutter/painting.dart';

/// Port 1:1 dari `makeDarkStyle` di App.js (baris 5482–5533).
/// Mengubah warna permukaan pastel, teks gelap, border terang, dan bayangan
/// saat mode gelap aktif tanpa merusak aksen rose/biru KARSA.
class DarkColorMapper {
  DarkColorMapper._();

  static const Color darkSurfaceRose = Color(0xFF493640);
  static const Color darkSurfaceBlue = Color(0xFF34414E);
  static const Color darkSurfaceNeutral = Color(0xFF332D36);
  static const Color darkTextRose = Color(0xFFF2A9BC);
  static const Color darkTextLight = Color(0xFFEEE7ED);
  static const Color darkBorder = Color(0xFF554A54);
  static const Color darkShadow = Color(0xFF08070A);

  static double luminance(Color c) {
    return (c.red * 0.299 + c.green * 0.587 + c.blue * 0.114) / 255.0;
  }

  static Color surface(Color lightColor, {required bool isDark}) {
    if (!isDark) return lightColor;
    final lum = luminance(lightColor);
    if (lum > 0.72) {
      if (lightColor.blue > lightColor.red + 4) {
        return darkSurfaceBlue;
      }
      if (lightColor.red > lightColor.green + 6) {
        return darkSurfaceRose;
      }
      return darkSurfaceNeutral;
    }
    return lightColor;
  }

  static Color text(Color lightColor, {required bool isDark}) {
    if (!isDark) return lightColor;
    final lum = luminance(lightColor);
    if (lum < 0.68) {
      if (lightColor.red > lightColor.green * 1.15) {
        return darkTextRose;
      }
      return darkTextLight;
    }
    return lightColor;
  }

  static Color border(Color lightColor, {required bool isDark}) {
    if (!isDark) return lightColor;
    if (lightColor.red == 255 &&
        lightColor.green == 255 &&
        lightColor.blue == 255 &&
        lightColor.opacity < 1.0) {
      return darkBorder;
    }
    if (luminance(lightColor) > 0.65) {
      return darkBorder;
    }
    return lightColor;
  }

  static Color shadow(Color lightColor, {required bool isDark}) {
    return isDark ? darkShadow : lightColor;
  }
}
