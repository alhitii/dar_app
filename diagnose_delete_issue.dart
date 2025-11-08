import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

/// سكريبت لتشخيص مشكلة عدم حذف الحساب من Authentication
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 بدء تشخيص مشكلة الحذف من Authentication...\n');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      print('❌ لا يوجد مستخدم مسجل دخول!');
      print('💡 يرجى تسجيل الدخول كـ Admin أولاً\n');
      return;
    }
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('👤 معلومات المستخدم الحالي:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('   Email: ${currentUser.email}');
    print('   UID: ${currentUser.uid}');
    print('');
    
    // 1. التحقق من دور المستخدم في Firestore
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📄 [1/4] التحقق من دور المستخدم في Firestore...');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) {
      print('❌ المستخدم غير موجود في collection users!');
      print('💡 يجب إضافة المستخدم إلى Firestore أولاً\n');
      return;
    }
    
    final userData = userDoc.data()!;
    final role = userData['role'];
    
    print('   ✅ المستخدم موجود في Firestore');
    print('   📋 الدور: $role');
    
    if (role != 'admin') {
      print('   ❌ المستخدم ليس admin!');
      print('   💡 Cloud Function تقبل فقط طلبات من admin\n');
      return;
    }
    
    print('   ✅ المستخدم هو admin\n');
    
    // 2. التحقق من وجود Cloud Function
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('☁️  [2/4] التحقق من Cloud Function...');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      // إنشاء مستخدم وهمي للاختبار (لن يتم حذفه فعلياً)
      print('   🧪 محاولة استدعاء Cloud Function...');
      
      final callable = FirebaseFunctions.instance.httpsCallable('deleteUserCompletely');
      
      // استدعاء تجريبي بدون UID (سيفشل لكن يؤكد أن Function موجودة)
      try {
        await callable.call({'test': true});
      } catch (e) {
        if (e.toString().contains('invalid-argument') || 
            e.toString().contains('يجب تحديد UID')) {
          print('   ✅ Cloud Function موجودة ومنشورة!');
          print('   📡 الاتصال ناجح\n');
        } else if (e.toString().contains('NOT_FOUND') || 
                   e.toString().contains('not found')) {
          print('   ❌ Cloud Function غير موجودة!');
          print('');
          print('   💡 الحل:');
          print('   1. تأكد من نشر Function:');
          print('      firebase deploy --only functions:deleteUserCompletely');
          print('   2. انتظر 1-2 دقيقة بعد النشر');
          print('   3. أعد تشغيل هذا السكريبت\n');
          return;
        } else {
          print('   ⚠️  خطأ غير متوقع: $e\n');
        }
      }
      
    } catch (e) {
      print('   ❌ فشل الاتصال بـ Cloud Function!');
      print('   📄 الخطأ: $e');
      print('');
      print('   💡 الأسباب المحتملة:');
      print('   1. Cloud Function غير منشورة');
      print('   2. مشكلة في الاتصال بالإنترنت');
      print('   3. خطأ في إعدادات Firebase\n');
      return;
    }
    
    // 3. اختبار حذف فعلي (اختياري)
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🧪 [3/4] اختبار حذف فعلي (اختياري)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('   ⚠️  تنبيه: هذا سيحذف حساب تجريبي إن وُجد');
    print('   💡 يمكنك تخطي هذا الاختبار\n');
    
    // البحث عن حساب تجريبي
    final testUsersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: 'test_delete@codeira.com')
        .limit(1)
        .get();
    
    if (testUsersQuery.docs.isEmpty) {
      print('   ℹ️  لا يوجد حساب تجريبي للاختبار');
      print('   💡 يمكنك إنشاء حساب بالبريد: test_delete@codeira.com');
      print('      ثم تشغيل هذا السكريبت مرة أخرى\n');
    } else {
      print('   ✅ تم العثور على حساب تجريبي');
      final testUid = testUsersQuery.docs.first.id;
      print('   📋 UID: $testUid');
      print('   📧 Email: test_delete@codeira.com\n');
      
      print('   🗑️  محاولة حذف الحساب التجريبي...');
      
      try {
        final callable = FirebaseFunctions.instance.httpsCallable('deleteUserCompletely');
        final result = await callable.call({
          'uid': testUid,
          'role': 'teacher',
          'email': 'test_delete@codeira.com',
        });
        
        final data = result.data as Map<String, dynamic>;
        
        if (data['success'] == true) {
          print('   ✅ نجح الحذف!');
          print('   📊 تم الحذف من: ${data['deletedFrom']}');
          print('');
          print('   🎉 الحل يعمل بشكل صحيح!\n');
        } else {
          print('   ❌ فشل الحذف: ${data['error']}');
          print('   💡 راجع logs في Firebase Console\n');
        }
        
      } catch (e) {
        print('   ❌ خطأ في الحذف: $e');
        print('   💡 راجع السبب أدناه\n');
      }
    }
    
    // 4. خلاصة التشخيص
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 [4/4] خلاصة التشخيص');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');
    print('✅ العناصر التي تعمل:');
    print('   • الاتصال بـ Firebase');
    print('   • تسجيل دخول Admin');
    print('   • قراءة Firestore');
    if (role == 'admin') print('   • صلاحيات Admin');
    print('');
    
    print('📝 الخطوات التالية:');
    print('   1. تأكد من نشر Cloud Function:');
    print('      cd functions && npm install && npm run build');
    print('      cd .. && firebase deploy --only functions:deleteUserCompletely');
    print('');
    print('   2. تحقق من Firebase Console > Functions > Logs');
    print('      للاطلاع على أي أخطاء');
    print('');
    print('   3. جرب حذف معلم من التطبيق وراقب Console');
    print('');
    print('   4. إذا استمرت المشكلة، راجع:');
    print('      TROUBLESHOOT_DELETE.md\n');
    
  } catch (e, stackTrace) {
    print('❌ خطأ في التشخيص: $e');
    print('📄 Stack trace: $stackTrace');
  }
}
