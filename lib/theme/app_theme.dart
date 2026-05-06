import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color secondaryDark = Color(0xFF16213E);
  static const Color accentBlue = Color(0xFF0F3460);
  static const Color accentPurple = Color(0xFF533483);
  static const Color accentPink = Color(0xFFE94560);
  static const Color accentTeal = Color(0xFF00D9C0);
  static const Color accentGold = Color(0xFFF5A623);
  static const Color surfaceLight = Color(0xFF22274A);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF9DA3C2);
  static const Color cardBg = Color(0xFF1E2240);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentPink,
        secondary: accentTeal,
        surface: cardBg,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPink,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: accentPink.withOpacity(0.3),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryDark,
        selectedItemColor: accentPink,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration get gradientCard => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [cardBg, surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  static BoxDecoration get glassCard => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardBg.withOpacity(0.7),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      );

  // File type icons and colors
  static IconData getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
      case 'document':
        return Icons.description_rounded;
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_rounded;
      case 'video':
      case 'mp4':
        return Icons.video_file_rounded;
      case 'code':
      case 'dart':
      case 'py':
      case 'js':
        return Icons.code_rounded;
      case 'spreadsheet':
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'presentation':
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'text':
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'zip':
      case 'rar':
      case 'archive':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE74C3C);
      case 'doc':
      case 'docx':
      case 'document':
        return const Color(0xFF2980B9);
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const Color(0xFF9B59B6);
      case 'video':
      case 'mp4':
        return const Color(0xFFE67E22);
      case 'code':
      case 'dart':
      case 'py':
      case 'js':
        return const Color(0xFF2ECC71);
      case 'spreadsheet':
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const Color(0xFF27AE60);
      case 'presentation':
      case 'ppt':
      case 'pptx':
        return const Color(0xFFD35400);
      case 'text':
      case 'txt':
        return const Color(0xFF7F8C8D);
      default:
        return accentBlue;
    }
  }
}
