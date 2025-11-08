import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script لإضافة إشعار غياب تجريبي
void main() async {
  print('🔧 إضافة إشعار غياب تجريبي...\n');
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم الاتصال بـ Firebase\n');
    
    final db = FirebaseFirestore.instance;
    
    // 1. البحث عن أول طالب
    print('🔍 البحث عن طالب...');
    final studentsSnapshot = await db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .limit(1)
        .get();
    
    if (studentsSnapshot.docs.isEmpty) {
      print('❌ لا يوجد طلاب في النظام!');
      print('   يجب إنشاء طالب أولاً من التطبيق');
      return;
    }
    
    final studentDoc = studentsSnapshot.docs.first;
    final studentData = studentDoc.data();
    final studentUid = studentDoc.id;
    final studentName = studentData['name'] ?? 'طالب';
    
    print('✅ تم العثور على الطالب:');
    print('   الاسم: $studentName');
    print('   UID: $studentUid');
    print('   Email: ${studentData['email']}');
    print('');
    
    // 2. إضافة إشعار غياب
    print('📤 إضافة إشعار غياب...');
    
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    final absenceData = {
      'studentUid': studentUid,
      'studentName': studentName,
      'message': 'تم تسجيل غيابك اليوم. الرجاء مراجعة الإدارة - (إشعار تجريبي)',
      'date': dateStr,
      'stage': studentData['stage'] ?? '',
      'grade': studentData['grade'] ?? '',
      'section': studentData['section'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'absence',
    };
    
    await db.collection('absences').add(absenceData);
    
    print('✅ تم إضافة إشعار الغياب بنجاح!');
    print('');
    print('=' * 60);
    print('📋 البيانات المضافة:');
    print('=' * 60);
    print('studentUid: $studentUid');
    print('studentName: $studentName');
    print('message: ${absenceData['message']}');
    print('date: $dateStr');
    print('createdAt: الآن (server timestamp)');
    print('');
    
    // 3. التحقق من الإضافة
    print('🔍 التحقق من الإضافة...');
    await Future.delayed(const Duration(seconds: 2));
    
    final verifySnapshot = await db
        .collection('absences')
        .where('studentUid', isEqualTo: studentUid)
        .get();
    
    if (verifySnapshot.docs.isNotEmpty) {
      print('✅✅ تأكيد: تم العثور على ${verifySnapshot.docs.length} إشعار للطالب');
      print('');
      print('🎉 الآن سجل دخول بحساب الطالب:');
      print('   Email: ${studentData['email']}');
      print('   Password: [كلمة المرور]');
      print('');
      print('📱 يجب أن ترى بانر الغياب الأحمر في الأعلى!');
    } else {
      print('⚠️ لم يتم العثور على الإشعار - قد يكون هناك تأخير');
    }
    
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace: $stackTrace');
  }
}
