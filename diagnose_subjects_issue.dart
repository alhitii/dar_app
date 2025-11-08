import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

/// سكريبت تشخيص شامل لمشكلة عدم ظهور المواد
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 بدء التشخيص الشامل لمشكلة المواد...\n');

  try {
    // تهيئة Firebase
    print('⏳ جاري تهيئة Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم تهيئة Firebase بنجاح\n');
    
    final firestore = FirebaseFirestore.instance;

    // 1. عد جميع المواد
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 الخطوة 1: عد جميع المواد');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    final allSubjects = await firestore.collection('subjects').get();
    print('✅ إجمالي المواد في Firestore: ${allSubjects.docs.length}');
    
    if (allSubjects.docs.isEmpty) {
      print('❌ لا توجد أي مواد في قاعدة البيانات!');
      print('🔧 الحل: شغّل سكريبت إضافة المواد أولاً');
      return;
    }

    // 2. تحليل المراحل
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 الخطوة 2: تحليل المراحل الموجودة');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    Map<String, int> stageCount = {};
    Map<String, int> gradeCount = {};
    Map<String, int> branchCount = {};
    
    for (var doc in allSubjects.docs) {
      final data = doc.data();
      
      final stage = data['stage']?.toString() ?? 'غير محدد';
      final grade = data['grade']?.toString() ?? 'غير محدد';
      final branch = data['branch']?.toString() ?? 'null';
      
      stageCount[stage] = (stageCount[stage] ?? 0) + 1;
      gradeCount[grade] = (gradeCount[grade] ?? 0) + 1;
      branchCount[branch] = (branchCount[branch] ?? 0) + 1;
    }
    
    print('\n🏫 المراحل الموجودة:');
    stageCount.forEach((stage, count) {
      print('   $stage: $count مادة');
    });
    
    print('\n📖 الصفوف الموجودة:');
    gradeCount.forEach((grade, count) {
      print('   $grade: $count مادة');
    });
    
    print('\n🔀 الفروع الموجودة:');
    branchCount.forEach((branch, count) {
      print('   $branch: $count مادة');
    });

    // 3. اختبار الاستعلامات
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 الخطوة 3: اختبار الاستعلامات');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // اختبار 1: ابتدائية - الأول
    print('\n🧪 اختبار 1: ابتدائية - الأول');
    var query1 = await firestore
        .collection('subjects')
        .where('stage', isEqualTo: 'ابتدائية')
        .where('grade', isEqualTo: 'الأول')
        .get();
    print('   النتيجة: ${query1.docs.length} مادة');
    if (query1.docs.isNotEmpty) {
      print('   المواد: ${query1.docs.map((d) => d.data()['name']).join(', ')}');
    }
    
    // اختبار 2: متوسطة - الأول
    print('\n🧪 اختبار 2: متوسطة - الأول');
    var query2 = await firestore
        .collection('subjects')
        .where('stage', isEqualTo: 'متوسطة')
        .where('grade', isEqualTo: 'الأول')
        .get();
    print('   النتيجة: ${query2.docs.length} مادة');
    if (query2.docs.isNotEmpty) {
      print('   المواد: ${query2.docs.map((d) => d.data()['name']).join(', ')}');
    }
    
    // اختبار 3: إعدادية - الرابع - علمي
    print('\n🧪 اختبار 3: إعدادية - الرابع - علمي');
    var query3 = await firestore
        .collection('subjects')
        .where('stage', isEqualTo: 'إعدادية')
        .where('grade', isEqualTo: 'الرابع')
        .where('branch', isEqualTo: 'علمي')
        .get();
    print('   النتيجة: ${query3.docs.length} مادة');
    if (query3.docs.isNotEmpty) {
      print('   المواد: ${query3.docs.map((d) => d.data()['name']).join(', ')}');
    }
    
    // اختبار 4: إعدادية - الرابع - أدبي
    print('\n🧪 اختبار 4: إعدادية - الرابع - أدبي');
    var query4 = await firestore
        .collection('subjects')
        .where('stage', isEqualTo: 'إعدادية')
        .where('grade', isEqualTo: 'الرابع')
        .where('branch', isEqualTo: 'أدبي')
        .get();
    print('   النتيجة: ${query4.docs.length} مادة');
    if (query4.docs.isNotEmpty) {
      print('   المواد: ${query4.docs.map((d) => d.data()['name']).join(', ')}');
    }

    // 4. فحص التسميات الخاطئة
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 الخطوة 4: فحص التسميات الخاطئة');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    int wrongNamingCount = 0;
    List<String> issues = [];
    
    for (var doc in allSubjects.docs) {
      final data = doc.data();
      final stage = data['stage']?.toString();
      final branch = data['branch']?.toString();
      
      // فحص المراحل
      if (stage == 'إعدادي' || stage == 'متوسط' || stage == 'ابتدائي') {
        issues.add('❌ ${doc.id}: stage = "$stage" (يجب أن تكون بالتاء المربوطة)');
        wrongNamingCount++;
      }
      
      // فحص الفروع
      if (branch == 'علمى' || branch == 'أدبى') {
        issues.add('❌ ${doc.id}: branch = "$branch" (يجب أن تكون بالياء العادية)');
        wrongNamingCount++;
      }
      
      // فحص الحقول المفقودة
      if (!data.containsKey('name') || data['name'] == null || data['name'].toString().isEmpty) {
        issues.add('❌ ${doc.id}: حقل name مفقود أو فارغ');
        wrongNamingCount++;
      }
      
      if (!data.containsKey('stage')) {
        issues.add('❌ ${doc.id}: حقل stage مفقود');
        wrongNamingCount++;
      }
      
      if (!data.containsKey('grade')) {
        issues.add('❌ ${doc.id}: حقل grade مفقود');
        wrongNamingCount++;
      }
    }
    
    if (wrongNamingCount > 0) {
      print('\n⚠️  تم العثور على $wrongNamingCount مشكلة:');
      for (var issue in issues.take(10)) {  // عرض أول 10 مشاكل فقط
        print('   $issue');
      }
      if (issues.length > 10) {
        print('   ... و ${issues.length - 10} مشكلة أخرى');
      }
      print('\n🔧 الحل: شغّل fix_subjects_structure.dart لإصلاح التسميات');
    } else {
      print('✅ جميع التسميات صحيحة!');
    }

    // 5. فحص المواد المرتبطة بمعلمين
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 الخطوة 5: فحص المواد المرتبطة بمعلمين');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    int withTeacher = 0;
    int withoutTeacher = 0;
    
    for (var doc in allSubjects.docs) {
      final data = doc.data();
      if (data.containsKey('teacherName') && data['teacherName'] != null && data['teacherName'].toString().isNotEmpty) {
        withTeacher++;
      } else {
        withoutTeacher++;
      }
    }
    
    print('✅ مواد مرتبطة بمعلمين: $withTeacher');
    print('⚠️  مواد غير مرتبطة: $withoutTeacher');

    // 6. التوصيات
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('💡 التوصيات والحلول');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (allSubjects.docs.isEmpty) {
      print('🔧 1. أضف المواد إلى Firestore أولاً');
    } else if (wrongNamingCount > 0) {
      print('🔧 1. شغّل: flutter run fix_subjects_structure.dart');
      print('   لإصلاح التسميات الخاطئة');
    } else if (query1.docs.isEmpty && query2.docs.isEmpty && query3.docs.isEmpty) {
      print('🔧 1. تأكد من أن الحقول stage و grade موجودة ومكتوبة بشكل صحيح');
      print('   المراحل الصحيحة: ابتدائية، متوسطة، إعدادية');
      print('   الصفوف الصحيحة: الأول، الثاني، الثالث، الرابع، الخامس، السادس');
    } else {
      print('✅ البيانات تبدو صحيحة!');
      print('🔧 إذا كانت المواد لا تزال لا تظهر، تحقق من:');
      print('   1. الاتصال بـ Firestore');
      print('   2. console logs في التطبيق');
      print('   3. صلاحيات Firestore rules');
    }

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ انتهى التشخيص');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  } catch (e) {
    print('❌ خطأ في التشخيص: $e');
    print('\n🔧 تأكد من أن Firebase معد بشكل صحيح');
  }
}
