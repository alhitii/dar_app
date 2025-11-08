import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

/// سكريبت فوري لإضافة المواد مباشرة إلى Firestore
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 بدء إضافة المواد إلى Firestore...\n');

  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // حذف المواد القديمة أولاً
    print('🗑️  حذف المواد القديمة...');
    final oldSubjects = await firestore.collection('subjects').get();
    for (var doc in oldSubjects.docs) {
      await doc.reference.delete();
    }
    print('   ✅ تم حذف ${oldSubjects.docs.length} مادة قديمة\n');
    
    int created = 0;
    
    // ========================================
    // المرحلة المتوسطة (اختبار سريع)
    // ========================================
    final middleGrades = ['الأول', 'الثاني', 'الثالث'];
    final middleSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '🕌'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🇬🇧'},
      {'name': 'الاجتماعيات', 'emoji': '🌍'},
      {'name': 'الكيمياء', 'emoji': '⚗️'},
      {'name': 'الأحياء', 'emoji': '🌿'},
      {'name': 'الفيزياء', 'emoji': '🔬'},
      {'name': 'الحاسوب', 'emoji': '💻'},
      {'name': 'التربية الرياضية', 'emoji': '🏃‍♂️'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
    ];
    
    print('📚 إضافة مواد المتوسطة...');
    for (var grade in middleGrades) {
      for (var subject in middleSubjects) {
        await firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'متوسطة',
          'grade': grade,
          'branch': null,
          'section': null,
          'teacherUid': null,
          'teacherName': null,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        print('   ✅ ${subject['name']} (متوسطة - $grade)');
      }
      
      // الأخلاقية للأول والثاني فقط
      if (grade == 'الأول' || grade == 'الثاني') {
        await firestore.collection('subjects').add({
          'name': 'الأخلاقية',
          'emoji': '🤝',
          'stage': 'متوسطة',
          'grade': grade,
          'branch': null,
          'section': null,
          'teacherUid': null,
          'teacherName': null,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        print('   ✅ الأخلاقية (متوسطة - $grade)');
      }
    }
    
    // ========================================
    // المرحلة الإعدادية - علمي
    // ========================================
    final prepGrades = ['الرابع', 'الخامس', 'السادس'];
    final prepScienceSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '🕌'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🇬🇧'},
      {'name': 'الرياضيات', 'emoji': '➗'},
      {'name': 'الكيمياء', 'emoji': '⚗️'},
      {'name': 'الفيزياء', 'emoji': '🔬'},
      {'name': 'الأحياء', 'emoji': '🌿'},
      {'name': 'الحاسوب', 'emoji': '💻'},
      {'name': 'التربية الرياضية', 'emoji': '🏃‍♂️'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
    ];
    
    print('\n📚 إضافة مواد الإعدادية - علمي...');
    for (var grade in prepGrades) {
      for (var subject in prepScienceSubjects) {
        await firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'إعدادية',
          'grade': grade,
          'branch': 'علمي',
          'section': null,
          'teacherUid': null,
          'teacherName': null,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        print('   ✅ ${subject['name']} (إعدادية - $grade - علمي)');
      }
    }
    
    // ========================================
    // المرحلة الإعدادية - أدبي
    // ========================================
    final prepLiterarySubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '🕌'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🇬🇧'},
      {'name': 'التاريخ', 'emoji': '📜'},
      {'name': 'الجغرافيا', 'emoji': '🧭'},
      {'name': 'الفلسفة', 'emoji': '💭'},
      {'name': 'الاقتصاد', 'emoji': '💰'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
      {'name': 'التربية الرياضية', 'emoji': '🏃‍♂️'},
    ];
    
    print('\n📚 إضافة مواد الإعدادية - أدبي...');
    for (var grade in prepGrades) {
      for (var subject in prepLiterarySubjects) {
        await firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'إعدادية',
          'grade': grade,
          'branch': 'أدبي',
          'section': null,
          'teacherUid': null,
          'teacherName': null,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        print('   ✅ ${subject['name']} (إعدادية - $grade - أدبي)');
      }
    }
    
    // ========================================
    // المرحلة الابتدائية - مرتبة أبجدياً
    // ========================================
    final primaryGrades = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'];
    final primarySubjects = [
      {'name': 'الاجتماعيات', 'emoji': '🌍'},
      {'name': 'التربية الإسلامية', 'emoji': '🕌'},
      {'name': 'التربية الرياضية', 'emoji': '🏃‍♂️'},
      {'name': 'التربية الفنية', 'emoji': '🎨'},
      {'name': 'الرياضيات', 'emoji': '➗'},
      {'name': 'العلوم', 'emoji': '🔬'},
      {'name': 'اللغة الإنجليزية', 'emoji': '🇬🇧'},
      {'name': 'اللغة العربية', 'emoji': '📖'},
    ];
    
    print('\n📚 إضافة مواد الابتدائية...');
    for (var grade in primaryGrades) {
      for (var subject in primarySubjects) {
        await firestore.collection('subjects').add({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'ابتدائية',
          'grade': grade,
          'branch': null,
          'section': null,
          'teacherUid': null,
          'teacherName': null,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        print('   ✅ ${subject['name']} (ابتدائية - $grade)');
      }
    }
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ اكتمل! تم إضافة $created مادة إلى Firestore');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('\n📋 الخطوات التالية:');
    print('1. افتح التطبيق');
    print('2. سجل دخول كـ Admin');
    print('3. اذهب إلى "إنشاء حساب معلم"');
    print('4. اختر: متوسطة → الأول');
    print('5. يجب أن تظهر 11 مادة! ✅');
    
  } catch (e) {
    print('❌ خطأ: $e');
  }
}
