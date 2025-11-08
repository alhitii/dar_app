import 'package:flutter/material.dart';

class AppColors {
  // الألوان الرئيسية (من الصورة)
  static const Color primaryBlue = Color(0xFF4A8FA9); // اللون الأزرق الرئيسي
  static const Color darkBlue = Color(0xFF2E5C73); // للشعار
  static const Color lightBlue = Color(0xFFB8D4E6); // الخلفية العلوية
  static const Color midBlue = Color(0xFF6BA8C4); // الخلفية السفلية
  
  // الخلفية (تدرج أزرق فاتح من الصورة)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFB8D4E6), // أزرق فاتح جداً في الأعلى
      Color(0xFF8BBFD9), // أزرق متوسط
      Color(0xFF6BA8C4), // أزرق أغمق في الأسفل
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Card (أبيض نقي)
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x26000000); // ظل أقوى قليلاً
  
  // النصوص
  static const Color textPrimary = Color(0xFF1C1B1F); // أسود داكن
  static const Color textSecondary = Color(0xFF5F6368); // رمادي
  static const Color textHint = Color(0xFF9AA0A6);
  
  // حقول الإدخال (فاتح جداً من الصورة)
  static const Color inputFill = Color(0xFFEFF7FB); // أزرق فاتح جداً
  static const Color inputBorder = Color(0xFFD6E9F3);
  static const Color inputFocusBorder = Color(0xFF4A8FA9);
  
  // الأزرار
  static const Color buttonPrimary = Color(0xFF4A8FA9); // أزرق الزر
  static const Color buttonText = Color(0xFFFFFFFF);
  
  // الأيقونات
  static const Color iconPrimary = Color(0xFF4A8FA9); // أزرق
  static const Color iconSecondary = Color(0xFF9AA0A6); // رمادي
  
  // الشعار
  static const Color logoBg = Color(0xFF2E5C73); // أزرق داكن للدائرة
  static const Color logoIcon = Color(0xFFFFFFFF);
}
