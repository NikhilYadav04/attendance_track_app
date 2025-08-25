// App Colors
import 'dart:ui';

import 'package:attendance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
}

// Text Styles
class AppTextStyles {
  static TextStyle regular(BuildContext context, double size, Color color) =>
      GoogleFonts.poppins(
        fontSize: ResponsiveHelper.getFontSize(context, size),
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle medium(BuildContext context, double size, Color color) =>
      GoogleFonts.poppins(
        fontSize: ResponsiveHelper.getFontSize(context, size),
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bold(BuildContext context, double size, Color color) =>
      GoogleFonts.poppins(
        fontSize: ResponsiveHelper.getFontSize(context, size),
        fontWeight: FontWeight.w700,
        color: color,
      );
}
