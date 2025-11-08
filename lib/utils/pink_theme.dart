import 'package:flutter/material.dart';

/// نظام الألوان الجديد - تدرجات وردية وبنفسجية
class PinkTheme {
  // الألوان الأساسية من الصورة
  static const Color blue1 = Color(0xFF90C3F2); // #90C3F2
  static const Color teal1 = Color(0xFF90D0D8); // #90D0D8
  static const Color pink1 = Color(0xFFFADCC4); // #FADCC4
  static const Color pink2 = Color(0xFFFF95CC); // #FF95CC
  static const Color purple1 = Color(0xFFF2BFD8); // #F2BFD8

  // ألوان إضافية للتنوع
  static const Color lightPink = Color(0xFFFFE5F0);
  static const Color softPurple = Color(0xFFE8D5F2);
  static const Color peach = Color(0xFFFFD4C4);

  // التدرج الرئيسي للخلفيات
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFADCC4), // وردي فاتح
      Color(0xFFFFB5CC), // وردي متوسط
      Color(0xFFE289DB), // بنفسجي فاتح
    ],
  );

  // تدرج بديل للبطاقات
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE5F0),
      Color(0xFFF2BFD8),
    ],
  );

  // تدرج للأزرار
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFFFF95CC),
      Color(0xFFE289DB),
    ],
  );

  // تأثير زجاجي (Glass Effect)
  static BoxDecoration glassEffect({
    double opacity = 0.75,
    double blur = 10,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // تأثير زجاجي للأيقونات
  static BoxDecoration glassIconEffect({
    double opacity = 0.75,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.4),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ألوان النصوص
  static const Color textDark = Color(0xFF2D3E50);
  static const Color textLight = Color(0xFF6B7280);
  static const Color textWhite = Colors.white;

  // ألوان المواد (للأيقونات)
  static const List<Color> subjectColors = [
    Color(0xFFFF95CC), // وردي
    Color(0xFFE289DB), // بنفسجي
    Color(0xFFFADCC4), // خوخي
    Color(0xFFF2BFD8), // وردي فاتح
    Color(0xFFFFB5CC), // وردي متوسط
    Color(0xFFE8D5F2), // بنفسجي فاتح
  ];

  // الحصول على لون عشوائي للمواد
  static Color getSubjectColor(int index) {
    return subjectColors[index % subjectColors.length];
  }
}
