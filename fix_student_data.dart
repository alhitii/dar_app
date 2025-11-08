import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// سكريبت لنسخ بيانات الطالب من users إلى students
/// 
/// الاستخدام:
/// dart fix_student_data.dart

void main() async {
  // تهيئة Firebase
  await Firebase.initializeApp();
  
  final uid = 'bwsnflnliggjM75U5EBIuvoBTwU2';
  
  print('=== نسخ بيانات الطالب ===');
  print('UID: $uid');
  
  try {
    // قراءة البيانات من users
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    
    if (!userDoc.exists) {
      print('❌ البيانات غير موجودة في users collection');
      return;
    }
    
    final data = userDoc.data();
    print('✅ تم العثور على البيانات في users:');
    print(data);
    
    // نسخ البيانات إلى students
    await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .set(data!);
    
    print('✅ تم نسخ البيانات إلى students collection');
    
    // التحقق
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();
    
    if (studentDoc.exists) {
      print('✅ تم التحقق: البيانات موجودة الآن في students');
      print(studentDoc.data());
    }
    
    print('\n✅ تم الإصلاح بنجاح!');
    print('الآن يمكنك تسجيل الدخول وسيعمل كل شيء.');
    
  } catch (e) {
    print('❌ حدث خطأ: $e');
  }
}
