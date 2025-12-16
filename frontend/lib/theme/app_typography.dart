import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTypography {
  // Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Base Style using Inter
  static TextStyle get _baseStyle => GoogleFonts.inter(
        color: AppColors.textPrimary,
      );

  // ==================== DISPLAY ====================

  // Display 1 — 52px / 60px / -0.80px
  static TextStyle get display1 => _baseStyle.copyWith(
        fontSize: 52,
        height: 60 / 52,
        letterSpacing: -0.80,
      );

  static TextStyle get display1Regular =>
      display1.copyWith(fontWeight: regular);
  static TextStyle get display1Medium => display1.copyWith(fontWeight: medium);
  static TextStyle get display1Semibold =>
      display1.copyWith(fontWeight: semibold);
  static TextStyle get display1Bold => display1.copyWith(fontWeight: bold);

  // Display 2 — 40px / 60px / -0.80px
  static TextStyle get display2 => _baseStyle.copyWith(
        fontSize: 40,
        height: 60 / 40,
        letterSpacing: -0.80,
      );

  static TextStyle get display2Regular =>
      display2.copyWith(fontWeight: regular);
  static TextStyle get display2Medium => display2.copyWith(fontWeight: medium);
  static TextStyle get display2Semibold =>
      display2.copyWith(fontWeight: semibold);
  static TextStyle get display2Bold => display2.copyWith(fontWeight: bold);

  // Display 3 — 32px / 48px / -0.64px
  static TextStyle get display3 => _baseStyle.copyWith(
        fontSize: 32,
        height: 48 / 32,
        letterSpacing: -0.64,
      );

  static TextStyle get display3Regular =>
      display3.copyWith(fontWeight: regular);
  static TextStyle get display3Medium => display3.copyWith(fontWeight: medium);
  static TextStyle get display3Semibold =>
      display3.copyWith(fontWeight: semibold);
  static TextStyle get display3Bold => display3.copyWith(fontWeight: bold);

  // ==================== HEADING ====================

  // Heading 1 — 28px / 42px / -0.56px
  static TextStyle get heading1 => _baseStyle.copyWith(
        fontSize: 28,
        height: 42 / 28,
        letterSpacing: -0.56,
      );

  static TextStyle get heading1Regular =>
      heading1.copyWith(fontWeight: regular);
  static TextStyle get heading1Medium => heading1.copyWith(fontWeight: medium);
  static TextStyle get heading1Semibold =>
      heading1.copyWith(fontWeight: semibold);
  static TextStyle get heading1Bold => heading1.copyWith(fontWeight: bold);

  // Heading 2 — 24px / 36px / -0.48px
  static TextStyle get heading2 => _baseStyle.copyWith(
        fontSize: 24,
        height: 36 / 24,
        letterSpacing: -0.48,
      );

  static TextStyle get heading2Regular =>
      heading2.copyWith(fontWeight: regular);
  static TextStyle get heading2Medium => heading2.copyWith(fontWeight: medium);
  static TextStyle get heading2Semibold =>
      heading2.copyWith(fontWeight: semibold);
  static TextStyle get heading2Bold => heading2.copyWith(fontWeight: bold);

  // Heading 3 — 20px / 30px / -0.40px
  static TextStyle get heading3 => _baseStyle.copyWith(
        fontSize: 20,
        height: 30 / 20,
        letterSpacing: -0.40,
      );

  static TextStyle get heading3Regular =>
      heading3.copyWith(fontWeight: regular);
  static TextStyle get heading3Medium => heading3.copyWith(fontWeight: medium);
  static TextStyle get heading3Semibold =>
      heading3.copyWith(fontWeight: semibold);
  static TextStyle get heading3Bold => heading3.copyWith(fontWeight: bold);

  // ==================== BODY ====================

  // Body Large — 18px / 28px / -0.36px
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 18,
        height: 28 / 18,
        letterSpacing: -0.36,
      );

  static TextStyle get bodyLargeRegular =>
      bodyLarge.copyWith(fontWeight: regular);
  static TextStyle get bodyLargeMedium =>
      bodyLarge.copyWith(fontWeight: medium);
  static TextStyle get bodyLargeSemibold =>
      bodyLarge.copyWith(fontWeight: semibold);
  static TextStyle get bodyLargeBold => bodyLarge.copyWith(fontWeight: bold);

  // Body Medium — 16px / 24px / -0.32px
  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: -0.32,
      );

  static TextStyle get bodyMediumRegular =>
      bodyMedium.copyWith(fontWeight: regular);
  static TextStyle get bodyMediumMedium =>
      bodyMedium.copyWith(fontWeight: medium);
  static TextStyle get bodyMediumSemibold =>
      bodyMedium.copyWith(fontWeight: semibold);
  static TextStyle get bodyMediumBold => bodyMedium.copyWith(fontWeight: bold);

  // Body Small — 14px / 20px / -0.28px
  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get bodySmallRegular =>
      bodySmall.copyWith(fontWeight: regular);
  static TextStyle get bodySmallMedium =>
      bodySmall.copyWith(fontWeight: medium);
  static TextStyle get bodySmallSemibold =>
      bodySmall.copyWith(fontWeight: semibold);
  static TextStyle get bodySmallBold => bodySmall.copyWith(fontWeight: bold);

  // ==================== CAPTION ====================

  // Caption Large — 12px / 18px / -0.24px
  static TextStyle get captionLarge => _baseStyle.copyWith(
        fontSize: 12,
        height: 18 / 12,
        letterSpacing: -0.24,
      );

  static TextStyle get captionLargeRegular =>
      captionLarge.copyWith(fontWeight: regular);
  static TextStyle get captionLargeMedium =>
      captionLarge.copyWith(fontWeight: medium);
  static TextStyle get captionLargeSemibold =>
      captionLarge.copyWith(fontWeight: semibold);
  static TextStyle get captionLargeBold =>
      captionLarge.copyWith(fontWeight: bold);

  // Caption Small — 10px / 15px / -0.20px
  static TextStyle get captionSmall => _baseStyle.copyWith(
        fontSize: 10,
        height: 15 / 10,
        letterSpacing: -0.20,
      );

  static TextStyle get captionSmallRegular =>
      captionSmall.copyWith(fontWeight: regular);
  static TextStyle get captionSmallMedium =>
      captionSmall.copyWith(fontWeight: medium);
  static TextStyle get captionSmallSemibold =>
      captionSmall.copyWith(fontWeight: semibold);
  static TextStyle get captionSmallBold =>
      captionSmall.copyWith(fontWeight: bold);
}
