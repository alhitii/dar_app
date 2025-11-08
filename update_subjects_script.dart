import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// سكريبت لتحديث جميع المواد في Firestore لإضافة الحقول الناقصة
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة Firebase
    await Firebase.initializeApp();
    print('✅ تم تهيئة Firebase');

    // تحديث جميع المواد
    await updateAllSubjects();

  } catch (e) {
    print('❌ خطأ في تنفيذ السكريبت: $e');
  }
}

Future<void> updateAllSubjects() async {
  final firestore = FirebaseFirestore.instance;
  print('🔄 بدء تحديث جميع المواد في Firestore...');

  try {
    // جلب جميع المواد
    final snapshot = await firestore.collection('subjects').get();

    if (snapshot.docs.isEmpty) {
      print('⚠️ لا توجد مواد في Firestore');
      return;
    }

    print('📚 تم العثور على ${snapshot.docs.length} مادة');

    // جلب البيانات المرجعية من JSON
    final referenceSubjects = await _getReferenceSubjects();

    int updated = 0;
    int skipped = 0;
    int errors = 0;

    // تحديث كل مادة
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final docId = doc.id;

      try {
        print('🔍 فحص المادة: $docId');

        // البحث عن البيانات المرجعية لهذه المادة
        final referenceData = referenceSubjects.firstWhere(
          (ref) => ref['id'] == docId,
          orElse: () => <String, dynamic>{},
        );

        // إعداد البيانات المحدثة
        final updates = <String, dynamic>{};

        // إضافة الحقول الأساسية مع قيم افتراضية إذا لم تكن موجودة
        if (!data.containsKey('stage') || data['stage'] == null) {
          final stage = referenceData['stage'] ?? _getStageFromId(docId);
          updates['stage'] = stage;
          print('   ➕ إضافة stage: $stage');
        }

        if (!data.containsKey('grade') || data['grade'] == null) {
          final grade = referenceData['grade'] ?? _getGradeFromId(docId);
          updates['grade'] = grade;
          print('   ➕ إضافة grade: $grade');
        }

        if (!data.containsKey('section')) {
          // تحديد الشعبة الافتراضية (أول شعبة متاحة)
          final section = _getDefaultSection();
          updates['section'] = section;
          print('   ➕ إضافة section: $section');
        }

        if (!data.containsKey('branch')) {
          final branch = referenceData['branch'] ?? _getBranchFromId(docId);
          updates['branch'] = branch;
          print('   ➕ إضافة branch: $branch');
        }

        if (!data.containsKey('isActive')) {
          updates['isActive'] = true;
          print('   ➕ إضافة isActive: true');
        }

        if (!data.containsKey('name') || data['name'] == null || data['name'].toString().isEmpty) {
          final name = referenceData['name'] ?? _getNameFromId(docId);
          updates['name'] = name;
          print('   ➕ إضافة name: $name');
        }

        if (!data.containsKey('emoji') || data['emoji'] == null || data['emoji'].toString().isEmpty) {
          final emoji = referenceData['emoji'] ?? '📚';
          updates['emoji'] = emoji;
          print('   ➕ إضافة emoji: $emoji');
        }

        // تطبيق التحديثات إذا كان هناك تغييرات
        if (updates.isNotEmpty) {
          await firestore.collection('subjects').doc(docId).update(updates);
          updated++;
          print('   ✅ تم تحديث المادة: $docId');
        } else {
          skipped++;
          print('   ⏭️ المادة محدثة مسبقاً: $docId');
        }

      } catch (e) {
        errors++;
        print('   ❌ خطأ في تحديث المادة $docId: $e');
      }
    }

    print('\n📊 النتيجة النهائية:');
    print('   • إجمالي المواد: ${snapshot.docs.length}');
    print('   • تم التحديث: $updated');
    print('   • لم يحتج تحديث: $skipped');
    print('   • أخطاء: $errors');
    print('✅ تم الانتهاء من تحديث جميع المواد!');

  } catch (e) {
    print('❌ خطأ في تحديث المواد: $e');
    rethrow;
  }
}

/// جلب البيانات المرجعية من JSON ودالة _getAllStageSubjects
Future<List<Map<String, dynamic>>> _getReferenceSubjects() async {
  try {
    // قراءة ملف JSON
    final jsonString = await rootBundle.loadString('assets/subjects_data.json');
    final jsonData = json.decode(jsonString);
    final jsonSubjects = jsonData['subjects_for_secondary_scientific'] as List<dynamic>;

    // إضافة مواد المراحل الأخرى
    final allSubjects = [...jsonSubjects, ..._getAllStageSubjectsFromCode()];

    return allSubjects.map((s) => s as Map<String, dynamic>).toList();
  } catch (e) {
    print('⚠️ خطأ في قراءة البيانات المرجعية: $e');
    return _getAllStageSubjectsFromCode();
  }
}

/// استخراج المرحلة من ID المادة
String _getStageFromId(String id) {
  if (id.startsWith('pri_')) return 'ابتدائية';
  if (id.startsWith('mid_')) return 'متوسطة';
  if (id.startsWith('sec_') && id.contains('_10')) return 'ثانوية';
  if (id.startsWith('sec_')) return 'إعدادية';
  return 'ابتدائية'; // افتراضي
}

/// استخراج الصف من ID المادة
String _getGradeFromId(String id) {
  if (id.contains('_1')) return 'الأول';
  if (id.contains('_2')) return 'الثاني';
  if (id.contains('_3')) return 'الثالث';
  if (id.contains('_4')) return 'الرابع';
  if (id.contains('_5')) return 'الخامس';
  if (id.contains('_6')) return 'السادس';
  if (id.contains('_7')) return 'الأول متوسط';
  if (id.contains('_10')) return 'الأول ثانوي';
  return 'الأول'; // افتراضي
}

/// استخراج الفرع من ID المادة
String? _getBranchFromId(String id) {
  if (id.contains('_sci')) return 'علمي';
  if (id.contains('_lit')) return 'أدبي';
  return null; // عام
}

/// تحديد الشعبة الافتراضية
String _getDefaultSection() {
  return 'أ'; // أول شعبة افتراضية
}

/// استخراج الاسم من ID المادة (تبسيط)
String _getNameFromId(String id) {
  // يمكن تحسين هذا المنطق لاستخراج أسماء أفضل
  if (id.contains('islamic')) return 'التربية الإسلامية';
  if (id.contains('arabic')) return 'اللغة العربية';
  if (id.contains('english')) return 'اللغة الإنجليزية';
  if (id.contains('math')) return 'الرياضيات';
  if (id.contains('physics')) return 'الفيزياء';
  if (id.contains('chemistry')) return 'الكيمياء';
  if (id.contains('biology')) return 'الأحياء';
  if (id.contains('computer')) return 'الحاسوب';
  if (id.contains('french')) return 'اللغة الفرنسية';
  if (id.contains('science')) return 'العلوم';
  if (id.contains('social')) return 'الدراسات الاجتماعية';
  if (id.contains('art')) return 'التربية الفنية';
  if (id.contains('sport')) return 'التربية الرياضية';
  if (id.contains('history')) return 'التاريخ';
  if (id.contains('geography')) return 'الجغرافيا';
  if (id.contains('philosophy')) return 'الفلسفة';
  if (id.contains('economics')) return 'الاقتصاد';
  return 'مادة غير معروفة';
}

/// مواد جميع المراحل (مستخرجة من الكود الأصلي)
List<Map<String, dynamic>> _getAllStageSubjectsFromCode() {
  return [
    // المرحلة الابتدائية
    {
      'id': 'pri_1_islamic',
      'name': 'التربية الإسلامية',
      'emoji': '☪️',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null,
      'section': null
    },
    {
      'id': 'pri_1_arabic',
      'name': 'اللغة العربية',
      'emoji': '📖',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_math',
      'name': 'الرياضيات',
      'emoji': '📐',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_science',
      'name': 'العلوم',
      'emoji': '🔬',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_english',
      'name': 'اللغة الإنجليزية',
      'emoji': '🔤',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_social',
      'name': 'الدراسات الاجتماعية',
      'emoji': '🌍',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_art',
      'name': 'التربية الفنية',
      'emoji': '🎨',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },
    {
      'id': 'pri_1_sport',
      'name': 'التربية الرياضية',
      'emoji': '⚽',
      'stage': 'ابتدائية',
      'grade': 'الأول',
      'branch': null
    },

    // الصف الثاني ابتدائي
    {
      'id': 'pri_2_islamic',
      'name': 'التربية الإسلامية',
      'emoji': '☪️',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_arabic',
      'name': 'اللغة العربية',
      'emoji': '📖',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_math',
      'name': 'الرياضيات',
      'emoji': '📐',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_science',
      'name': 'العلوم',
      'emoji': '🔬',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_english',
      'name': 'اللغة الإنجليزية',
      'emoji': '🔤',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_social',
      'name': 'الدراسات الاجتماعية',
      'emoji': '🌍',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_art',
      'name': 'التربية الفنية',
      'emoji': '🎨',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },
    {
      'id': 'pri_2_sport',
      'name': 'التربية الرياضية',
      'emoji': '⚽',
      'stage': 'ابتدائية',
      'grade': 'الثاني',
      'branch': null
    },

    // المرحلة المتوسطة
    {
      'id': 'mid_7_islamic',
      'name': 'التربية الإسلامية',
      'emoji': '☪️',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_arabic',
      'name': 'اللغة العربية',
      'emoji': '📖',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_english',
      'name': 'اللغة الإنجليزية',
      'emoji': '🔤',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_math',
      'name': 'الرياضيات',
      'emoji': '📐',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_science',
      'name': 'العلوم',
      'emoji': '🔬',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_social',
      'name': 'الدراسات الاجتماعية',
      'emoji': '🌍',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_computer',
      'name': 'الحاسوب',
      'emoji': '💻',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },
    {
      'id': 'mid_7_french',
      'name': 'اللغة الفرنسية',
      'emoji': '🇫🇷',
      'stage': 'متوسطة',
      'grade': 'الأول متوسط',
      'branch': null
    },

    // المرحلة الثانوية - علمي
    {
      'id': 'sec_10_islamic_sci',
      'name': 'التربية الإسلامية',
      'emoji': '☪️',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_arabic_sci',
      'name': 'اللغة العربية',
      'emoji': '📖',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_english_sci',
      'name': 'اللغة الإنجليزية',
      'emoji': '🔤',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_math_sci',
      'name': 'الرياضيات',
      'emoji': '📐',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_physics_sci',
      'name': 'الفيزياء',
      'emoji': '⚛️',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_chemistry_sci',
      'name': 'الكيمياء',
      'emoji': '🧪',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },
    {
      'id': 'sec_10_biology_sci',
      'name': 'الأحياء',
      'emoji': '🧬',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'علمي'
    },

    // المرحلة الثانوية - أدبي
    {
      'id': 'sec_10_islamic_lit',
      'name': 'التربية الإسلامية',
      'emoji': '☪️',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_arabic_lit',
      'name': 'اللغة العربية',
      'emoji': '📖',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_english_lit',
      'name': 'اللغة الإنجليزية',
      'emoji': '🔤',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_history_lit',
      'name': 'التاريخ',
      'emoji': '📜',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_geography_lit',
      'name': 'الجغرافيا',
      'emoji': '🌍',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_philosophy_lit',
      'name': 'الفلسفة',
      'emoji': '🤔',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
    {
      'id': 'sec_10_economics_lit',
      'name': 'الاقتصاد',
      'emoji': '💰',
      'stage': 'ثانوية',
      'grade': 'الأول ثانوي',
      'branch': 'أدبي'
    },
  ];
}
