import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Skala tipografi 1:1 dari App.js:
/// brand 16/900 ls2, name 20/800, pageTitle 24/800, section 18/800,
/// itemTitle 14/700, muted 13, small 11, link 12/700, overline 10/800 ls1,
/// badge 10/700, statNumber 23/800, button 14/800 putih, resultNumber 52/900.
class AppTypography {
  final AppColors colors;

  const AppTypography(this.colors);

  TextStyle get brand => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: colors.rose,
      );

  TextStyle get name => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: colors.ink,
      );

  TextStyle get pageTitle => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: colors.ink,
      );

  TextStyle get section => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: colors.ink,
      );

  TextStyle get itemTitle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
        color: colors.ink,
      );

  TextStyle get label => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: colors.ink,
      );

  TextStyle get muted => TextStyle(
        fontSize: 13,
        height: 19 / 13,
        color: colors.muted,
      );

  TextStyle get smallMuted => TextStyle(
        fontSize: 11,
        height: 16 / 11,
        color: colors.muted,
      );

  TextStyle get link => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colors.rose,
      );

  TextStyle get overline => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: colors.rose,
      );

  TextStyle get badge => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: colors.rose,
      );

  TextStyle get statNumber => TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w800,
        color: colors.ink,
      );

  TextStyle get button => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  TextStyle get resultNumber => TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: colors.rose,
      );

  TextStyle get question => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 32 / 22,
        color: colors.ink,
      );
}
