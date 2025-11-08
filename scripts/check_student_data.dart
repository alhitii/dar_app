import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script للتحقق من بيانات الطلاب في Firestore
/// يعرض جميع الحقول لكل طالب
void main() async {
  print('🔍 فحص بيانات الطلاب في Firestore...\n');
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم الاتصال بـ Firebase\n');
    
    final db = FirebaseFirestore.instance;
    
    // قراءة من students collection
    print('📚 قراءة من students collection:');
    print('=' * 60);
    
    final studentsSnapshot = await db.collection('students').get();
    
    if (studentsSnapshot.docs.isEmpty) {
      print('⚠️ لا يوجد طلاب في students collection');
    } else {
      print('عدد الطلاب: ${studentsSnapshot.docs.length}\n');
      
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        print('📝 طالب: ${doc.id}');
        print('   - Name: ${data['name'] ?? 'N/A'}');
        print('   - Email: ${data['email'] ?? 'N/A'}');
        print('   - Stage: ${data['stage'] ?? 'N/A'}');
        print('   - Grade: ${data['grade'] ?? 'N/A'}');
        print('   - Branch: ${data['branch'] ?? 'N/A'} ${data['branch'] == null ? '❌' : '✅'}');
        print('   - Section: ${data['section'] ?? 'N/A'}');
        print('   - UID: ${data['uid'] ?? 'N/A'}');
        print('');
      }
    }
    
    print('\n' + '=' * 60);
    print('📚 قراءة من users collection:');
    print('=' * 60);
    
    // قراءة من users collection
    final usersSnapshot = await db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('⚠️ لا يوجد طلاب في users collection');
    } else {
      print('عدد الطلاب: ${usersSnapshot.docs.length}\n');
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        print('📝 طالب: ${doc.id}');
        print('   - Name: ${data['name'] ?? 'N/A'}');
        print('   - Email: ${data['email'] ?? 'N/A'}');
        print('   - Stage: ${data['stage'] ?? 'N/A'}');
        print('   - Grade: ${data['grade'] ?? 'N/A'}');
        print('   - Branch: ${data['branch'] ?? 'N/A'} ${data['branch'] == null ? '❌' : '✅'}');
        print('   - Section: ${data['section'] ?? 'N/A'}');
        print('   - Role: ${data['role'] ?? 'N/A'}');
        
        // تحقق من جميع الحقول
        print('   - All fields: ${data.keys.join(', ')}');
        print('');
      }
    }
    
    print('\n✅ تم الفحص بنجاح!');
    
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace: $stackTrace');
  }
}
