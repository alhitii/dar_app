import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// إضافة إشعار غياب للطالب 002
void main() async {
  print('📤 إضافة إشعار غياب للطالب 002...\n');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final db = FirebaseFirestore.instance;
    
    // بيانات الطالب 002 من Console
    const studentUid = '9RkLTJB0y2OjH1i5tqe0nfVbFcp2';
    const studentName = '002';
    const studentEmail = '002@codeira.com';
    
    print('✅ الطالب المستهدف:');
    print('   الاسم: $studentName');
    print('   UID: $studentUid');
    print('   Email: $studentEmail');
    print('');
    
    // إضافة إشعار غياب
    print('📝 إنشاء إشعار الغياب...');
    
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    await db.collection('absences').add({
      'studentUid': studentUid,
      'studentName': studentName,
      'message': 'تم تسجيل غيابك اليوم. الرجاء مراجعة الإدارة.',
      'date': dateStr,
      'stage': 'متوسطة',
      'grade': 'الثاني',
      'section': 'أ',
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'absence',
    });
    
    print('✅ تم إضافة الإشعار بنجاح!');
    print('');
    
    // التحقق
    await Future.delayed(const Duration(seconds: 2));
    
    print('🔍 التحقق...');
    final verify = await db
        .collection('absences')
        .where('studentUid', isEqualTo: studentUid)
        .get();
    
    print('✅ عدد الإشعارات: ${verify.docs.length}');
    print('');
    print('=' * 60);
    print('🎉 تم! الآن سجل دخول بحساب الطالب:');
    print('=' * 60);
    print('Email: $studentEmail');
    print('Password: 123456 (أو كلمة المرور)');
    print('');
    print('🔴 يجب أن ترى البانر الأحمر الآن!');
    
  } catch (e) {
    print('❌ خطأ: $e');
  }
}
