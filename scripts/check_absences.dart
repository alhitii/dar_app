import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script للتحقق من إشعارات الغياب في Firestore
void main() async {
  print('🔍 فحص إشعارات الغياب في Firestore...\n');
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم الاتصال بـ Firebase\n');
    
    final db = FirebaseFirestore.instance;
    
    // 1. التحقق من collection absences
    print('=' * 60);
    print('📚 Collection: absences');
    print('=' * 60);
    
    final absencesSnapshot = await db.collection('absences').get();
    
    if (absencesSnapshot.docs.isEmpty) {
      print('⚠️ Collection فارغ - لا توجد إشعارات غياب!');
      print('\n💡 يجب إرسال إشعار غياب من التطبيق أولاً');
    } else {
      print('عدد الإشعارات: ${absencesSnapshot.docs.length}\n');
      
      for (var doc in absencesSnapshot.docs) {
        final data = doc.data();
        print('📝 Document ID: ${doc.id}');
        print('   studentUid: ${data['studentUid']}');
        print('   studentName: ${data['studentName']}');
        print('   message: ${data['message']}');
        print('   createdAt: ${data['createdAt']}');
        
        // حساب العمر
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          try {
            final createdTime = (createdAt as Timestamp).toDate();
            final now = DateTime.now();
            final difference = now.difference(createdTime);
            final hours = difference.inHours;
            
            print('   العمر: $hours ساعة');
            
            if (hours < 24) {
              print('   ✅ حديث (سيظهر في البانر)');
            } else {
              print('   ⏰ قديم (لن يظهر في البانر)');
            }
          } catch (e) {
            print('   ⚠️ خطأ في حساب العمر: $e');
          }
        } else {
          print('   ⚠️ createdAt مفقود!');
        }
        
        print('');
      }
    }
    
    // 2. التحقق من collection users (للحصول على UIDs الطلاب)
    print('=' * 60);
    print('👥 الطلاب المتاحون:');
    print('=' * 60);
    
    final studentsSnapshot = await db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .limit(5)
        .get();
    
    if (studentsSnapshot.docs.isEmpty) {
      print('⚠️ لا يوجد طلاب في النظام!');
    } else {
      print('عرض أول ${studentsSnapshot.docs.length} طلاب:\n');
      
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        print('👤 ${data['name']}');
        print('   UID: ${doc.id}');
        print('   Email: ${data['email']}');
        print('   Stage: ${data['stage']}');
        print('   Grade: ${data['grade']}');
        print('');
      }
    }
    
    // 3. اقتراح إضافة إشعار تجريبي
    if (absencesSnapshot.docs.isEmpty && studentsSnapshot.docs.isNotEmpty) {
      print('=' * 60);
      print('💡 اقتراح: إضافة إشعار غياب تجريبي');
      print('=' * 60);
      
      final firstStudent = studentsSnapshot.docs.first;
      final studentData = firstStudent.data();
      
      print('\nلإضافة إشعار تجريبي للطالب: ${studentData['name']}');
      print('استخدم الكود التالي:\n');
      
      print('await FirebaseFirestore.instance.collection("absences").add({');
      print('  "studentUid": "${firstStudent.id}",');
      print('  "studentName": "${studentData['name']}",');
      print('  "message": "تم تسجيل غيابك اليوم - اختبار",');
      print('  "date": "${DateTime.now().toString().split(' ')[0]}",');
      print('  "stage": "${studentData['stage']}",');
      print('  "grade": "${studentData['grade']}",');
      print('  "section": "${studentData['section']}",');
      print('  "createdAt": FieldValue.serverTimestamp(),');
      print('  "type": "absence",');
      print('});');
      
      print('\nأو استخدم Script: add_test_absence.dart');
    }
    
    print('\n✅ انتهى الفحص!');
    
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace: $stackTrace');
  }
}
