import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة تحديث المواد في Firestore
class UpdateSubjectsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// تحديث جميع المواد في Firestore
  static Future<void> updateAllSubjects() async {
    print('🚀 بدء تحديث المواد في Firestore...\n');

    // حذف جميع المواد القديمة
    print('🗑️  حذف المواد القديمة...');
    final oldSubjects = await _firestore.collection('subjects').get();
    for (var doc in oldSubjects.docs) {
      await doc.reference.delete();
    }
    print('✅ تم حذف ${oldSubjects.docs.length} مادة قديمة\n');

    int count = 0;

    // ============ الابتدائية ============
    print('📚 إضافة مواد الابتدائية...');
    final primaryCommonSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
      {'name': 'الرياضيات', 'emoji': '📐'},
      {'name': 'العلوم', 'emoji': '🔬'},
      {'name': 'الرياضة', 'emoji': '⚽'},
      {'name': 'الفنية', 'emoji': '🎨'},
    ];

    // الأول والثاني (مع التربية الأخلاقية)
    for (var grade in ['الأول', 'الثاني']) {
      for (var subject in primaryCommonSubjects) {
        await _firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'ابتدائية',
          'grade': grade,
          'branch': null,
        });
        count++;
      }
      // التربية الأخلاقية
      await _firestore.collection('subjects').add({
        'name': 'التربية الأخلاقية',
        'emoji': '💎',
        'stage': 'ابتدائية',
        'grade': grade,
        'branch': null,
      });
      count++;
    }

    // الثالث (بدون التربية الأخلاقية والاجتماعيات)
    for (var subject in primaryCommonSubjects) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'ابتدائية',
        'grade': 'الثالث',
        'branch': null,
      });
      count++;
    }

    // الرابع والخامس والسادس (مع الاجتماعيات)
    for (var grade in ['الرابع', 'الخامس', 'السادس']) {
      for (var subject in primaryCommonSubjects) {
        await _firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'ابتدائية',
          'grade': grade,
          'branch': null,
        });
        count++;
      }
      // الاجتماعيات
      await _firestore.collection('subjects').add({
        'name': 'الاجتماعيات',
        'emoji': '🌍',
        'stage': 'ابتدائية',
        'grade': grade,
        'branch': null,
      });
      count++;
    }
    print('✅ تم إضافة مواد الابتدائية\n');

    // ============ المتوسطة ============
    print('📚 إضافة مواد المتوسطة...');
    final middleCommonSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
      {'name': 'الاجتماعيات', 'emoji': '🌍'},
      {'name': 'الرياضيات', 'emoji': '📐'},
      {'name': 'الفيزياء', 'emoji': '⚡'},
      {'name': 'الكيمياء', 'emoji': '🧪'},
      {'name': 'الأحياء', 'emoji': '🧬'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
      {'name': 'التربية الرياضية', 'emoji': '⚽'},
    ];

    // الأول والثاني متوسط (مع التربية الأخلاقية والحاسوب)
    for (var grade in ['الأول', 'الثاني']) {
      for (var subject in middleCommonSubjects) {
        await _firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'متوسطة',
          'grade': grade,
          'branch': null,
        });
        count++;
      }

      // التربية الأخلاقية
      await _firestore.collection('subjects').add({
        'name': 'التربية الأخلاقية',
        'emoji': '💎',
        'stage': 'متوسطة',
        'grade': grade,
        'branch': null,
      });
      count++;

      // الحاسوب
      await _firestore.collection('subjects').add({
        'name': 'الحاسوب',
        'emoji': '💻',
        'stage': 'متوسطة',
        'grade': grade,
        'branch': null,
      });
      count++;
    }

    // الثالث متوسط (بدون التربية الأخلاقية والحاسوب)
    for (var subject in middleCommonSubjects) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'متوسطة',
        'grade': 'الثالث',
        'branch': null,
      });
      count++;
    }
    print('✅ تم إضافة مواد المتوسطة\n');

    // ============ الإعدادية - علمي ============
    print('📚 إضافة مواد الإعدادية - علمي...');
    final prepCommonSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
      {'name': 'الرياضيات', 'emoji': '📐'},
      {'name': 'التربية الرياضية', 'emoji': '⚽'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
    ];

    final scienceSubjects = [
      {'name': 'الفيزياء', 'emoji': '⚡'},
      {'name': 'الكيمياء', 'emoji': '🧪'},
      {'name': 'الأحياء', 'emoji': '🧬'},
    ];

    // الرابع علمي
    for (var subject in [...prepCommonSubjects, ...scienceSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'الرابع',
        'branch': 'علمي',
      });
      count++;
    }
    await _firestore.collection('subjects').add({
      'name': 'جرائم حزب البعث',
      'emoji': '⚖️',
      'stage': 'إعدادية',
      'grade': 'الرابع',
      'branch': 'علمي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الحاسوب',
      'emoji': '💻',
      'stage': 'إعدادية',
      'grade': 'الرابع',
      'branch': 'علمي',
    });
    count += 2;

    // الخامس علمي
    for (var subject in [...prepCommonSubjects, ...scienceSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'الخامس',
        'branch': 'علمي',
      });
      count++;
    }
    await _firestore.collection('subjects').add({
      'name': 'جرائم حزب البعث',
      'emoji': '⚖️',
      'stage': 'إعدادية',
      'grade': 'الخامس',
      'branch': 'علمي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الحاسوب',
      'emoji': '💻',
      'stage': 'إعدادية',
      'grade': 'الخامس',
      'branch': 'علمي',
    });
    count += 2;

    // السادس علمي (بدون جرائم حزب البعث والحاسوب)
    for (var subject in [...prepCommonSubjects, ...scienceSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'السادس',
        'branch': 'علمي',
      });
      count++;
    }
    print('✅ تم إضافة مواد الإعدادية - علمي\n');

    // ============ الإعدادية - أدبي ============
    print('📚 إضافة مواد الإعدادية - أدبي...');
    final literatureSubjects = [
      {'name': 'التاريخ', 'emoji': '📜'},
      {'name': 'الجغرافية', 'emoji': '🗺️'},
    ];

    // الرابع أدبي
    for (var subject in [...prepCommonSubjects, ...literatureSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'الرابع',
        'branch': 'أدبي',
      });
      count++;
    }
    await _firestore.collection('subjects').add({
      'name': 'جرائم حزب البعث',
      'emoji': '⚖️',
      'stage': 'إعدادية',
      'grade': 'الرابع',
      'branch': 'أدبي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الاجتماع',
      'emoji': '👥',
      'stage': 'إعدادية',
      'grade': 'الرابع',
      'branch': 'أدبي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الحاسوب',
      'emoji': '💻',
      'stage': 'إعدادية',
      'grade': 'الرابع',
      'branch': 'أدبي',
    });
    count += 3;

    // الخامس أدبي
    for (var subject in [...prepCommonSubjects, ...literatureSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'الخامس',
        'branch': 'أدبي',
      });
      count++;
    }
    await _firestore.collection('subjects').add({
      'name': 'الاقتصاد',
      'emoji': '💰',
      'stage': 'إعدادية',
      'grade': 'الخامس',
      'branch': 'أدبي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الفلسفة وعلم النفس',
      'emoji': '🤔',
      'stage': 'إعدادية',
      'grade': 'الخامس',
      'branch': 'أدبي',
    });
    await _firestore.collection('subjects').add({
      'name': 'الحاسوب',
      'emoji': '💻',
      'stage': 'إعدادية',
      'grade': 'الخامس',
      'branch': 'أدبي',
    });
    count += 3;

    // السادس أدبي
    for (var subject in [...prepCommonSubjects, ...literatureSubjects]) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'grade': 'السادس',
        'branch': 'أدبي',
      });
      count++;
    }
    await _firestore.collection('subjects').add({
      'name': 'الاقتصاد',
      'emoji': '💰',
      'stage': 'إعدادية',
      'grade': 'السادس',
      'branch': 'أدبي',
    });
    count++;

    print('✅ تم إضافة مواد الإعدادية - أدبي\n');

    print('═══════════════════════════════════════');
    print('✅ اكتمل التحديث بنجاح!');
    print('📊 إجمالي المواد المضافة: $count مادة');
    print('═══════════════════════════════════════\n');
  }
}
