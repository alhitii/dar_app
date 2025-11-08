import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 نظام الثيم Material 3 الحديث
/// مستوحى من تصميم Google الرسمي (Material You)
/// يدعم الألوان الديناميكية والثيم الفاتح والداكن
class Material3Theme {
  // 🎨 ألوان Codeira الأساسية
  static const Color codeiraBlue = Color(0xFF4A8FA9);
  static const Color codeiraPink = Color(0xFFFFB6C1);
  static const Color codeiraLightBlue = Color(0xFF87CEEB);
  
  /// 🌈 إنشاء ColorScheme ديناميكي من لون أساسي
  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: codeiraBlue,
    brightness: Brightness.light,
  );
  
  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: codeiraBlue,
    brightness: Brightness.dark,
  );
  
  /// ✨ الثيم الفاتح - Material 3
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      
      // 🔤 الخطوط - Google Fonts
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),
      
      // 📱 AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
      ),
      
      // 🎴 Cards
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: lightColorScheme.surfaceContainerLow,
      ),
      
      // 🔘 Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // 🔘 Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // 📝 Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: lightColorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.cairo(),
        hintStyle: GoogleFonts.cairo(
          color: lightColorScheme.onSurfaceVariant,
        ),
      ),
      
      // 📊 Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return GoogleFonts.cairo(fontSize: 12);
        }),
      ),
      
      // 🎯 Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 📋 List Tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      
      // 💬 Dialog
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          color: lightColorScheme.onSurfaceVariant,
        ),
      ),
      
      // 🎨 Chip
      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // 📱 Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        backgroundColor: lightColorScheme.surface,
      ),
    );
  }
  
  /// 🌙 الثيم الداكن - Material 3
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      
      // 🔤 الخطوط - Google Fonts
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),
      
      // 📱 AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
      ),
      
      // 🎴 Cards
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkColorScheme.surfaceContainerLow,
      ),
      
      // 🔘 Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // 🔘 Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // 📝 Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: darkColorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.cairo(),
        hintStyle: GoogleFonts.cairo(
          color: darkColorScheme.onSurfaceVariant,
        ),
      ),
      
      // 📊 Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return GoogleFonts.cairo(fontSize: 12);
        }),
      ),
      
      // 🎯 Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 📋 List Tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      
      // 💬 Dialog
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          color: darkColorScheme.onSurfaceVariant,
        ),
      ),
      
      // 🎨 Chip
      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // 📱 Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        backgroundColor: darkColorScheme.surface,
      ),
    );
  }
  
  /// 🎨 تدرج لوني مخصص لـ Codeira
  static LinearGradient get codeiraGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      codeiraLightBlue,
      codeiraPink,
    ],
  );
  
  /// 🎨 تدرج لوني للبطاقات
  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      codeiraBlue.withOpacity(0.1),
      codeiraPink.withOpacity(0.1),
    ],
  );
}
