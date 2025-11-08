import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// إضافة إشعار غياب سريع للطالب حسين علي
void main() async {
  print('🚀 بدء إضافة إشعار غياب تجريبي...\n');
  
  try {
    print('⏳ تهيئة Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم تهيئة Firebase\n');
    
    final db = FirebaseFirestore.instance;
    
    // بيانات الطالب من Console (آخر طالب سجل دخول)
    const studentUid = 'irBrpPFsRCUt3hpgTsTENEE5vQF3';
    const studentName = 'حسين علي';
    const studentEmail = 'hs@codeira.com';
    
    print('📤 إضافة إشعار غياب لـ:');
    print('   الطالب: $studentName');
    print('   UID: $studentUid');
    print('   Email: $studentEmail');
    print('');
    
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    // إضافة في absences (للبانر - 24 ساعة)
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
    
    print('✅ تم إضافة في absences');
    
    // إضافة في notifications_admin (للوحة الإشعارات - سنة)
    final expiresAt = now.add(const Duration(days: 365));
    await db.collection('notifications_admin').add({
      'studentUid': studentUid,
      'studentName': studentName,
      'title': '⚠️ تنبيه غياب',
      'body': 'تم تسجيل غيابك اليوم. الرجاء مراجعة الإدارة.',
      'date': dateStr,
      'type': 'absence',
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ تم إضافة في notifications_admin');
    print('');
    
    // التحقق
    await Future.delayed(const Duration(seconds: 2));
    
    final verify = await db
        .collection('absences')
        .where('studentUid', isEqualTo: studentUid)
        .get();
    
    print('🔍 التحقق: ${verify.docs.length} إشعار');
    print('');
    print('=' * 60);
    print('✅ تم بنجاح! الآن في التطبيق:');
    print('=' * 60);
    print('1. اضغط "r" للـ Hot Reload');
    print('   أو');
    print('2. Logout ثم Login بـ: $studentEmail');
    print('');
    print('🔴 يجب أن ترى البانر الأحمر الآن!');
    print('');
    
    exit(0);
    
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace:');
    print(stackTrace);
    exit(1);
  }
}
