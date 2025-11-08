import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script لإضافة حقل branch لجميع طلاب الإعدادية
void main() async {
  print('🔧 بدء إضافة الفرع لطلاب الإعدادية...\n');
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ تم الاتصال بـ Firebase\n');
    
    final db = FirebaseFirestore.instance;
    
    // 1. تحديث في students collection
    print('📚 تحديث students collection:');
    print('=' * 60);
    
    final studentsSnapshot = await db
        .collection('students')
        .where('stage', isEqualTo: 'إعدادية')
        .get();
    
    if (studentsSnapshot.docs.isEmpty) {
      print('⚠️ لا يوجد طلاب إعدادية في students collection');
    } else {
      print('عدد الطلاب الإعداديين: ${studentsSnapshot.docs.length}\n');
      
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'N/A';
        final currentBranch = data['branch'];
        
        if (currentBranch == null || currentBranch.toString().isEmpty) {
          // إضافة branch افتراضي "علمي"
          await doc.reference.update({
            'branch': 'علمي',
          });
          print('✅ تم تحديث: $name → branch: علمي');
          
          // تحديث في users collection أيضاً
          final uid = data['uid'];
          if (uid != null) {
            try {
              await db.collection('users').doc(uid).update({
                'branch': 'علمي',
              });
              print('   ✅ تم تحديث في users أيضاً');
            } catch (e) {
              print('   ⚠️ خطأ في تحديث users: $e');
            }
          }
        } else {
          print('⏭️ تخطي: $name (branch موجود: $currentBranch)');
        }
      }
    }
    
    print('\n' + '=' * 60);
    print('📚 تحديث users collection:');
    print('=' * 60);
    
    // 2. تحديث في users collection
    final usersSnapshot = await db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('stage', isEqualTo: 'إعدادية')
        .get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('⚠️ لا يوجد طلاب إعدادية في users collection');
    } else {
      print('عدد الطلاب: ${usersSnapshot.docs.length}\n');
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'N/A';
        final currentBranch = data['branch'];
        
        if (currentBranch == null || currentBranch.toString().isEmpty) {
          await doc.reference.update({
            'branch': 'علمي',
          });
          print('✅ تم تحديث: $name → branch: علمي');
        } else {
          print('⏭️ تخطي: $name (branch موجود: $currentBranch)');
        }
      }
    }
    
    print('\n✅ تم التحديث بنجاح!');
    print('\n📝 ملاحظة: جميع الطلاب تم تعيينهم كـ "علمي" افتراضياً');
    print('   يمكنك تغييرهم إلى "أدبي" من لوحة الإدارة إذا لزم الأمر');
    
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace: $stackTrace');
  }
}
