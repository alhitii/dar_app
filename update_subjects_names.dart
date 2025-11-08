import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

/// سكريبت لتحديث أسماء المواد في Firestore
/// - تغيير "الدراسات الاجتماعية" إلى "الاجتماعيات" في المرحلة الابتدائية
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔧 بدء تحديث أسماء المواد في Firestore...\n');

  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    int updated = 0;
    
    // ========================================
    // تحديث: الدراسات الاجتماعية → الاجتماعيات
    // ========================================
    print('📝 تحديث مادة "الدراسات الاجتماعية" إلى "الاجتماعيات" في المرحلة الابتدائية...\n');
    
    final socialStudiesDocs = await firestore
        .collection('subjects')
        .where('name', isEqualTo: 'الدراسات الاجتماعية')
        .where('stage', isEqualTo: 'ابتدائية')
        .get();
    
    for (var doc in socialStudiesDocs.docs) {
      await doc.reference.update({
        'name': 'الاجتماعيات',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      updated++;
      final data = doc.data();
      print('   ✅ تم التحديث: الدراسات الاجتماعية → الاجتماعيات (${data['stage']} - ${data['grade']})');
    }
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ اكتمل! تم تحديث $updated مادة');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (updated > 0) {
      print('\n📋 الخطوات التالية:');
      print('1. شغّل Hot Reload في التطبيق (r)');
      print('2. افتح "إنشاء حساب معلم"');
      print('3. اختر: ابتدائية → الأول');
      print('4. يجب أن ترى "الاجتماعيات" بدلاً من "الدراسات الاجتماعية" ✅');
      print('5. المواد الآن مرتبة أبجدياً ✅');
    } else {
      print('\n💡 لا توجد مواد تحتاج للتحديث (ربما تم تحديثها مسبقاً)');
    }
    
  } catch (e) {
    print('❌ خطأ: $e');
  }
}
