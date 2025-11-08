/// ثوابت النظام التعليمي العراقي
class EducationConstants {
  // المراحل الدراسية
  static const List<String> stages = [
    'ابتدائية',
    'متوسطة',
    'إعدادية',
  ];

  // الصفوف الدراسية
  static const Map<String, List<String>> gradesByStage = {
    'ابتدائية': ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'],
    'متوسطة': ['الأول', 'الثاني', 'الثالث'],
    'إعدادية': ['الرابع', 'الخامس', 'السادس'],
  };

  // الفروع (للإعدادية فقط)
  static const List<String> branches = [
    'علمي',
    'أدبي',
  ];

  // الشعب
  static const List<String> sections = [
    'أ',
    'ب',
    'ج',
    'د',
    'هـ',
    'و',
  ];

  // المواد للابتدائية
  static const List<Map<String, String>> primarySchoolSubjects = [
    {'name': 'التربية الإسلامية', 'code': 'isl', 'emoji': '☪️'},
    {'name': 'اللغة العربية', 'code': 'arb', 'emoji': '📖'},
    {'name': 'اللغة الإنكليزية', 'code': 'eng', 'emoji': '🇬🇧'},
    {'name': 'الرياضيات', 'code': 'math', 'emoji': '📐'},
    {'name': 'العلوم', 'code': 'sci', 'emoji': '🔬'},
    {'name': 'الرياضة', 'code': 'pe', 'emoji': '⚽'},
    {'name': 'الفنية', 'code': 'art', 'emoji': '🎨'},
    {'name': 'التربية الأخلاقية', 'code': 'eth', 'emoji': '💎'},
    {'name': 'الاجتماعيات', 'code': 'soc', 'emoji': '🌍'},
  ];

  // المواد للمتوسطة (المشتركة لجميع الصفوف)
  static const List<Map<String, String>> middleSchoolSubjects = [
    {'name': 'التربية الإسلامية', 'code': 'isl', 'emoji': '☪️'},
    {'name': 'اللغة العربية', 'code': 'arb', 'emoji': '📖'},
    {'name': 'اللغة الإنكليزية', 'code': 'eng', 'emoji': '🇬🇧'},
    {'name': 'الاجتماعيات', 'code': 'soc', 'emoji': '🌍'},
    {'name': 'الرياضيات', 'code': 'math', 'emoji': '📐'},
    {'name': 'الفيزياء', 'code': 'phy', 'emoji': '⚡'},
    {'name': 'الكيمياء', 'code': 'che', 'emoji': '🧪'},
    {'name': 'الأحياء', 'code': 'bio', 'emoji': '🧬'},
    {'name': 'التربية الفنية', 'code': 'art', 'emoji': '🎨'},
    {'name': 'التربية الرياضية', 'code': 'pe', 'emoji': '⚽'},
  ];

  // التربية الأخلاقية (للأول والثاني متوسط فقط)
  static const Map<String, String> ethicsSubject = {
    'name': 'التربية الأخلاقية',
    'code': 'eth',
    'emoji': '💎'
  };

  // الحاسوب للمتوسطة (للأول والثاني فقط)
  static const Map<String, String> computerMiddleSubject = {
    'name': 'الحاسوب',
    'code': 'com',
    'emoji': '💻'
  };

  // المواد المشتركة للإعدادية (جميع الفروع)
  static const List<Map<String, String>> preparatoryCommonSubjects = [
    {'name': 'التربية الإسلامية', 'code': 'isl', 'emoji': '☪️'},
    {'name': 'اللغة العربية', 'code': 'arb', 'emoji': '📖'},
    {'name': 'اللغة الإنكليزية', 'code': 'eng', 'emoji': '🇬🇧'},
    {'name': 'الرياضيات', 'code': 'math', 'emoji': '📐'},
    {'name': 'التربية الرياضية', 'code': 'pe', 'emoji': '⚽'},
    {'name': 'التربية الفنية', 'code': 'art', 'emoji': '🎨'},
  ];

  // المواد الدراسية - إعدادية علمي
  static const List<Map<String, String>> subjectsPreparatoryScience = [
    {'name': 'الفيزياء', 'code': 'phy', 'emoji': '⚡'},
    {'name': 'الكيمياء', 'code': 'che', 'emoji': '🧪'},
    {'name': 'الأحياء', 'code': 'bio', 'emoji': '🧬'},
  ];

  // جرائم حزب البعث (الرابع والخامس علمي فقط)
  static const Map<String, String> baathCrimesSubject = {
    'name': 'جرائم حزب البعث',
    'code': 'baa',
    'emoji': '⚖️'
  };

  // الحاسوب للإعدادية (الرابع والخامس فقط)
  static const Map<String, String> computerPrepSubject = {
    'name': 'الحاسوب',
    'code': 'com',
    'emoji': '💻'
  };

  // المواد الدراسية - إعدادية أدبي
  static const List<Map<String, String>> subjectsPreparatoryLiterature = [
    {'name': 'التاريخ', 'code': 'his', 'emoji': '📜'},
    {'name': 'الجغرافية', 'code': 'geo', 'emoji': '🗺️'},
  ];

  // الاجتماع (الرابع أدبي فقط)
  static const Map<String, String> sociologySubject = {
    'name': 'الاجتماع',
    'code': 'soc',
    'emoji': '👥'
  };

  // الاقتصاد (الخامس والسادس أدبي فقط)
  static const Map<String, String> economicsSubject = {
    'name': 'الاقتصاد',
    'code': 'eco',
    'emoji': '💰'
  };

  // الفلسفة وعلم النفس (الخامس أدبي فقط)
  static const Map<String, String> philosophySubject = {
    'name': 'الفلسفة وعلم النفس',
    'code': 'phi',
    'emoji': '🤔'
  };

  // دالة للحصول على المواد حسب المرحلة والصف والفرع
  static List<Map<String, dynamic>> getSubjects({
    required String stage,
    required String grade,
    String? branch,
  }) {
    List<Map<String, String>> subjects = [];
    
    if (stage == 'ابتدائية') {
      // المواد المشتركة لجميع الصفوف
      subjects = [
        {'name': 'التربية الإسلامية', 'code': 'isl', 'emoji': '☪️'},
        {'name': 'اللغة العربية', 'code': 'arb', 'emoji': '📖'},
        {'name': 'اللغة الإنكليزية', 'code': 'eng', 'emoji': '🇬🇧'},
        {'name': 'الرياضيات', 'code': 'math', 'emoji': '📐'},
        {'name': 'العلوم', 'code': 'sci', 'emoji': '🔬'},
        {'name': 'الرياضة', 'code': 'pe', 'emoji': '⚽'},
        {'name': 'الفنية', 'code': 'art', 'emoji': '🎨'},
      ];
      
      // التربية الأخلاقية (الأول والثاني فقط)
      if (grade == 'الأول' || grade == 'الثاني') {
        subjects.add({'name': 'التربية الأخلاقية', 'code': 'eth', 'emoji': '💎'});
      }
      
      // الاجتماعيات (من الرابع إلى السادس)
      if (grade == 'الرابع' || grade == 'الخامس' || grade == 'السادس') {
        subjects.add({'name': 'الاجتماعيات', 'code': 'soc', 'emoji': '🌍'});
      }
      
      return subjects;
    } else if (stage == 'متوسطة') {
      // المواد المشتركة
      subjects = List.from(middleSchoolSubjects);
      
      // التربية الأخلاقية (الأول والثاني فقط)
      if (grade == 'الأول' || grade == 'الثاني') {
        subjects.add(ethicsSubject);
      }
      
      // الحاسوب (الأول والثاني فقط - محذوف من الثالث)
      if (grade == 'الأول' || grade == 'الثاني') {
        subjects.add(computerMiddleSubject);
      }
      
      return subjects;
    } else if (stage == 'إعدادية') {
      // المواد المشتركة
      subjects = List.from(preparatoryCommonSubjects);
      
      if (branch == 'علمي') {
        // مواد الفرع العلمي
        subjects.addAll(subjectsPreparatoryScience);
        
        // جرائم حزب البعث (الرابع والخامس فقط)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add(baathCrimesSubject);
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add(computerPrepSubject);
        }
      } else if (branch == 'أدبي') {
        // مواد الفرع الأدبي
        subjects.addAll(subjectsPreparatoryLiterature);
        
        // جرائم حزب البعث (الرابع فقط)
        if (grade == 'الرابع') {
          subjects.add(baathCrimesSubject);
        }
        
        // الاجتماع (الرابع فقط)
        if (grade == 'الرابع') {
          subjects.add(sociologySubject);
        }
        
        // الاقتصاد (الخامس والسادس فقط)
        if (grade == 'الخامس' || grade == 'السادس') {
          subjects.add(economicsSubject);
        }
        
        // الفلسفة وعلم النفس (الخامس فقط)
        if (grade == 'الخامس') {
          subjects.add(philosophySubject);
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add(computerPrepSubject);
        }
      }
      
      return subjects;
    }
    
    return [];
  }

  // التحقق من صلاحية الفرع
  static bool requiresBranch(String stage) {
    return stage == 'إعدادية';
  }

  // التحقق من صلاحية الصف للمرحلة
  static bool isValidGrade(String stage, String grade) {
    return gradesByStage[stage]?.contains(grade) ?? false;
  }
}
