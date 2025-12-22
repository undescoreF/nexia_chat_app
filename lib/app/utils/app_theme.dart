import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'appcolors.dart';

class AppTheme {
  /// Thème clair
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.userMessage,

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryButton,
    ),

    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        fontSize: 16.sp, // responsive
        color: AppColors.textPrimary,
      ),

      bodyMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      ),

      titleLarge: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.iconNeutral),
  );

  /// Thème sombre
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,

      // Couleurs de base
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryButton,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryButton,
        secondary: AppColors.iconNonNeutral,
        background: AppColors.background,
        surface: AppColors.background,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.iconNonNeutral),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: Colors.white,
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        ),
      ),

      // Cartes
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.searchBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.primaryButton, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10.sp,
          color: AppColors.textSecondary,
        ),
      ),

      // Icons
      iconTheme: IconThemeData(color: AppColors.iconNeutral, size: 24.0),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1.0,
        space: 0,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        tileColor: Colors.transparent,
        iconColor: AppColors.iconNeutral,
        textColor: AppColors.textPrimary,
        dense: true,
      ),
    );
  }

  static ThemeData get currentTheme {
    return lightTheme;
  }
}
