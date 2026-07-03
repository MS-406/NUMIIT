import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        color: color,
        fontWeight: weight ?? FontWeight.bold,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        color: color,
        fontWeight: weight ?? FontWeight.normal,
      );

  static TextStyle script(double size, {Color? color, bool useCustomFont = true}) {
    // Always use the custom font for ancient scripts unless explicitly opted out,
    // to ensure Brahmi unicode characters are rendered correctly across all platforms.
    if (useCustomFont) {
      return TextStyle(
        fontFamily: 'KshatrapaBrahmi',
        fontSize: size,
        color: color,
        letterSpacing: 2,
      );
    }
    return GoogleFonts.notoSans(
      fontSize: size,
      color: color,
      letterSpacing: 2,
    );
  }
}
