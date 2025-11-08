import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الألوان المستوحى من شعار المدرسة
class SchoolTheme {
  // ألوان التدرج الرئيسية (مستوحاة من الشعار)
  static const Color primaryLight = Color(0xFF5DADE2); // أزرق سماوي
  static const Color primaryMedium = Color(0xFF3498DB); // أزرق متوسط
  static const Color primaryDark = Color(0xFF2874A6); // أزرق داكن
  static const Color accentPink = Color(0xFFEC7063); // وردي من الشعار
  static const Color accentPinkLight = Color(0xFFF1948A); // وردي فاتح

  // ألوان إضافية
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF1a1a2e);
  static final Color textGrey = Colors.grey.shade600;
  static final Color backgroundLight = Colors.grey.shade50;
  static final Color cardBackground = Colors.grey.shade100;

  // التدرج الموحد من شاشة تسجيل الدخول (مستخرج من الصورة)
  static const LinearGradient unifiedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5B9FCA), // أزرق متوسط (من أعلى الصورة)
      Color(0xFFD9E8F5), // أزرق فاتح مائل للأبيض (من أسفل الصورة)
    ],
  );

  // تدرجات الخلفية (جميعها تستخدم نفس التدرج الموحد)
  static const LinearGradient backgroundGradient = unifiedGradient;
  static const LinearGradient primaryGradient = unifiedGradient;

  // أنماط النصوص
  static TextStyle get headingLarge => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      );

  static TextStyle get headingMedium => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      );

  static TextStyle get headingSmall => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textDark,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDark,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textGrey,
      );

  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textGrey,
      );

  // تزيين البطاقات
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
      );

  // تزيين الأيقونات
  static BoxDecoration iconDecoration(Color color) => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // تزيين الأزرار
  static BoxDecoration get buttonDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get accentButtonDecoration => BoxDecoration(
        gradient: unifiedGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // تزيين التبويبات
  static BoxDecoration get tabBarDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration get selectedTabDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ألوان حسب الدور (جميعها تستخدم التدرج الموحد)
  static const LinearGradient adminGradient = unifiedGradient;
  static const LinearGradient teacherGradient = unifiedGradient;
  static const LinearGradient studentGradient = unifiedGradient;
}
