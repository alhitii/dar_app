import 'package:cloud_firestore/cloud_firestore.dart';

class SetupBasicSubjects {
  static Future<void> setupAllSubjects() async {
    print('\n╔════════════════════════════════════════╗');
    print('║  📚 إعداد المواد الأساسية             ║');
    print('╚════════════════════════════════════════╝\n');

    final firestore = FirebaseFirestore.instance;

    // إعداد المواد للمرحلة الابتدائية
    await _setupPrimarySubjects(firestore);

    // إعداد المواد للمرحلة المتوسطة
    await _setupMiddleSubjects(firestore);

    // إعداد المواد للمرحلة الإعدادية - علمي
    await _setupSecondaryScientific(firestore);

    // إعداد المواد للمرحلة الإعدادية - أدبي
    await _setupSecondaryLiterary(firestore);

    print('✅ انتهى إعداد جميع المواد!');
  }

  static Future<void> _setupPrimarySubjects(FirebaseFirestore firestore) async {
    print('📚 إعداد المرحلة الابتدائية...');

    final subjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️', 'key': 'islamic'},
      {'name': 'اللغة العربية', 'emoji': '📖', 'key': 'arabic'},
      {'name': 'الرياضيات', 'emoji': '📐', 'key': 'math'},
      {'name': 'العلوم', 'emoji': '🔬', 'key': 'science'},
      {'name': 'الدراسات الاجتماعية', 'emoji': '🌍', 'key': 'social'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🔤', 'key': 'english'},
      {'name': 'التربية الفنية', 'emoji': '🎨', 'key': 'art'},
      {'name': 'التربية الرياضية', 'emoji': '⚽', 'key': 'pe'},
    ];

    final grades = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'];

    for (final grade in grades) {
      for (final subject in subjects) {
        final docId = 'pri_${grade.replaceAll('ال', '')}_${subject['key']}';

        try {
          await firestore.collection('subjects').doc(docId).set({
            'name': subject['name'],
            'emoji': subject['emoji'],
            'stage': 'ابتدائية',
            'grade': grade,
            // بدون branch للمرحلة الابتدائية
            'order': subjects.indexOf(subject) + 1,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('   ✅ ${subject['emoji']} ${subject['name']} - $grade');
        } catch (e) {
          print('   ❌ خطأ في ${subject['name']}: $e');
        }
      }
    }
  }

  static Future<void> _setupMiddleSubjects(FirebaseFirestore firestore) async {
    print('\n📚 إعداد المرحلة المتوسطة...');

    final subjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️', 'key': 'islamic'},
      {'name': 'اللغة العربية', 'emoji': '📖', 'key': 'arabic'},
      {'name': 'الرياضيات', 'emoji': '📐', 'key': 'math'},
      {'name': 'العلوم', 'emoji': '🔬', 'key': 'science'},
      {'name': 'الدراسات الاجتماعية', 'emoji': '🌍', 'key': 'social'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🔤', 'key': 'english'},
      {'name': 'التاريخ', 'emoji': '📜', 'key': 'history'},
      {'name': 'الجغرافيا', 'emoji': '🗺️', 'key': 'geography'},
      {'name': 'الحاسوب', 'emoji': '💻', 'key': 'computer'},
    ];

    final grades = ['الأول', 'الثاني', 'الثالث'];

    for (final grade in grades) {
      for (final subject in subjects) {
        final docId = 'mid_${grade.replaceAll('ال', '')}_${subject['key']}';

        try {
          await firestore.collection('subjects').doc(docId).set({
            'name': subject['name'],
            'emoji': subject['emoji'],
            'stage': 'متوسطة',
            'grade': grade,
            // بدون branch للمرحلة المتوسطة
            'order': subjects.indexOf(subject) + 1,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('   ✅ ${subject['emoji']} ${subject['name']} - $grade');
        } catch (e) {
          print('   ❌ خطأ في ${subject['name']}: $e');
        }
      }
    }
  }

  static Future<void> _setupSecondaryScientific(FirebaseFirestore firestore) async {
    print('\n📚 إعداد المرحلة الإعدادية - علمي...');

    final subjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️', 'key': 'islamic'},
      {'name': 'اللغة العربية', 'emoji': '📖', 'key': 'arabic'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🔤', 'key': 'english'},
      {'name': 'الرياضيات', 'emoji': '📐', 'key': 'math'},
      {'name': 'الفيزياء', 'emoji': '⚛️', 'key': 'physics'},
      {'name': 'الكيمياء', 'emoji': '🧪', 'key': 'chemistry'},
      {'name': 'الأحياء', 'emoji': '🧬', 'key': 'biology'},
      {'name': 'الحاسوب', 'emoji': '💻', 'key': 'computer'},
    ];

    final grades = ['الرابع', 'الخامس', 'السادس'];

    for (final grade in grades) {
      for (final subject in subjects) {
        final docId = 'sec_${grade.replaceAll('ال', '')}_${subject['key']}_sci';

        try {
          await firestore.collection('subjects').doc(docId).set({
            'name': subject['name'],
            'emoji': subject['emoji'],
            'stage': 'إعدادية',
            'grade': grade,
            'branch': 'علمي',
            'order': subjects.indexOf(subject) + 1,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('   ✅ ${subject['emoji']} ${subject['name']} - $grade');
        } catch (e) {
          print('   ❌ خطأ في ${subject['name']}: $e');
        }
      }
    }
  }

  static Future<void> _setupSecondaryLiterary(FirebaseFirestore firestore) async {
    print('\n📚 إعداد المرحلة الإعدادية - أدبي...');

    final subjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️', 'key': 'islamic'},
      {'name': 'اللغة العربية', 'emoji': '📖', 'key': 'arabic'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🔤', 'key': 'english'},
      {'name': 'الرياضيات', 'emoji': '📐', 'key': 'math'},
      {'name': 'التاريخ', 'emoji': '📜', 'key': 'history'},
      {'name': 'الجغرافيا', 'emoji': '🗺️', 'key': 'geography'},
      {'name': 'الفلسفة', 'emoji': '🤔', 'key': 'philosophy'},
      {'name': 'علم النفس والاجتماع', 'emoji': '🧠', 'key': 'psychology'},
    ];

    final grades = ['الرابع', 'الخامس', 'السادس'];

    for (final grade in grades) {
      for (final subject in subjects) {
        final docId = 'sec_${grade.replaceAll('ال', '')}_${subject['key']}_lit';

        try {
          await firestore.collection('subjects').doc(docId).set({
            'name': subject['name'],
            'emoji': subject['emoji'],
            'stage': 'إعدادية',
            'grade': grade,
            'branch': 'أدبي',
            'order': subjects.indexOf(subject) + 1,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('   ✅ ${subject['emoji']} ${subject['name']} - $grade');
        } catch (e) {
          print('   ❌ خطأ في ${subject['name']}: $e');
        }
      }
    }
  }
}
