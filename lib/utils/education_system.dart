/// نظام التعليم - المراحل والصفوف والمواد
/// ثانوية دار السلام للبنات

enum EducationLevel {
  primary,    // ابتدائية
  middle,     // متوسطة
  secondary,  // إعدادية
}

class EducationSystem {
  // أسماء المراحل
  static String getLevelName(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return 'ابتدائية';
      case EducationLevel.middle:
        return 'متوسطة';
      case EducationLevel.secondary:
        return 'إعدادية';
    }
  }

  // الصفوف حسب المرحلة
  static List<String> getGradesForLevel(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return [
          'الأول ابتدائي',
          'الثاني ابتدائي',
          'الثالث ابتدائي',
          'الرابع ابتدائي',
          'الخامس ابتدائي',
          'السادس ابتدائي',
        ];
      case EducationLevel.middle:
        return [
          'الأول متوسط',
          'الثاني متوسط',
          'الثالث متوسط',
        ];
      case EducationLevel.secondary:
        return [
          'الرابع إعدادي',
          'الخامس إعدادي',
          'السادس إعدادي',
        ];
    }
  }

  // المواد حسب الصف والفرع
  static List<String> getSubjectsForGrade(String grade, {String? branch}) {
    // المواد للمتوسطة
    if (grade.contains('متوسط')) {
      final subjects = [
        'التربية الإسلامية',
        'اللغة العربية',
        'اللغة الإنكليزية',
        'الاجتماعيات',
        'الرياضيات',
        'الفيزياء',
        'الكيمياء',
        'الأحياء',
        'التربية الفنية',
        'التربية الرياضية',
      ];

      // التربية الأخلاقية (الأول والثاني فقط)
      if (grade == 'الأول متوسط' || grade == 'الثاني متوسط') {
        subjects.add('التربية الأخلاقية');
      }
      
      // الحاسوب (الأول والثاني فقط - محذوف من الثالث)
      if (grade == 'الأول متوسط' || grade == 'الثاني متوسط') {
        subjects.add('الحاسوب');
      }

      return subjects;
    }

    // المواد للإعدادية - علمي
    if (grade.contains('إعدادي') && branch == 'علمي') {
      final subjects = [
        'التربية الإسلامية',
        'اللغة العربية',
        'اللغة الإنكليزية',
        'الرياضيات',
        'الفيزياء',
        'الكيمياء',
        'الأحياء',
        'التربية الرياضية',
        'التربية الفنية',
      ];
      
      // جرائم حزب البعث (الرابع والخامس فقط)
      if (grade == 'الرابع إعدادي' || grade == 'الخامس إعدادي') {
        subjects.add('جرائم حزب البعث');
      }
      
      // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
      if (grade == 'الرابع إعدادي' || grade == 'الخامس إعدادي') {
        subjects.add('الحاسوب');
      }
      
      return subjects;
    }

    // المواد للإعدادية - أدبي
    if (grade.contains('إعدادي') && branch == 'أدبي') {
      final subjects = [
        'التربية الإسلامية',
        'اللغة العربية',
        'اللغة الإنكليزية',
        'التاريخ',
        'الجغرافية',
        'الرياضيات',
        'التربية الرياضية',
        'التربية الفنية',
      ];
      
      // جرائم حزب البعث (الرابع فقط)
      if (grade == 'الرابع إعدادي') {
        subjects.add('جرائم حزب البعث');
      }
      
      // الاجتماع (الرابع فقط)
      if (grade == 'الرابع إعدادي') {
        subjects.add('الاجتماع');
      }
      
      // الاقتصاد (الخامس والسادس فقط)
      if (grade == 'الخامس إعدادي' || grade == 'السادس إعدادي') {
        subjects.add('الاقتصاد');
      }
      
      // الفلسفة وعلم النفس (الخامس فقط)
      if (grade == 'الخامس إعدادي') {
        subjects.add('الفلسفة وعلم النفس');
      }
      
      // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
      if (grade == 'الرابع إعدادي' || grade == 'الخامس إعدادي') {
        subjects.add('الحاسوب');
      }
      
      return subjects;
    }

    // المواد للابتدائية
    if (grade.contains('ابتدائي')) {
      return [
        'التربية الإسلامية',
        'اللغة العربية',
        'اللغة الإنكليزية',
        'الرياضيات',
        'العلوم',
        'الرياضة',
        'الفنية',
        'التربية الأخلاقية',
        'الاجتماعيات',
      ];
    }

    return [];
  }

  // تحديد المرحلة من اسم الصف
  static EducationLevel? getLevelFromGrade(String grade) {
    if (grade.contains('ابتدائي')) {
      return EducationLevel.primary;
    } else if (grade.contains('متوسط')) {
      return EducationLevel.middle;
    } else if (grade.contains('إعدادي') || grade.contains('علمي') || grade.contains('أدبي')) {
      return EducationLevel.secondary;
    }
    return null;
  }

  // تحديد الفرع من اسم الصف (للتوافق مع البيانات القديمة)
  static String? getBranchFromGrade(String grade) {
    if (grade.contains('علمي')) {
      return 'علمي';
    } else if (grade.contains('أدبي')) {
      return 'أدبي';
    }
    return null;
  }
}
