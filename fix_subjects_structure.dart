import 'package:cloud_firestore/cloud_firestore.dart';

/// سكريبت لإصلاح هيكل بيانات المواد في Firestore
/// يوحد التسميات ويضيف الحقول المفقودة
void main() async {
  print('🔧 بدء إصلاح هيكل بيانات المواد...\n');

  try {
    final firestore = FirebaseFirestore.instance;
    final subjectsRef = firestore.collection('subjects');

    // الحصول على جميع المواد
    final snapshot = await subjectsRef.get();

    print('📊 إجمالي المواد الموجودة: ${snapshot.docs.length}\n');

    int updatedCount = 0;
    int skippedCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final subjectId = doc.id;

      print('🔄 فحص المادة: $subjectId (${data['name'] ?? 'بدون اسم'})');

      Map<String, dynamic> updates = {};

      // توحيد تسمية المرحلة
      if (data.containsKey('stage')) {
        String stage = data['stage'].toString();
        if (stage == 'إعدادي') {
          updates['stage'] = 'إعدادية';
          print('   ✅ تم توحيد المرحلة: إعدادي → إعدادية');
        } else if (stage == 'متوسط') {
          updates['stage'] = 'متوسطة';
          print('   ✅ تم توحيد المرحلة: متوسط → متوسطة');
        } else if (stage == 'ابتدائي') {
          updates['stage'] = 'ابتدائية';
          print('   ✅ تم توحيد المرحلة: ابتدائي → ابتدائية');
        }
      }

      // توحيد تسمية الفرع
      if (data.containsKey('branch')) {
        String branch = data['branch'].toString();
        if (branch == 'علمى') {
          updates['branch'] = 'علمي';
          print('   ✅ تم توحيد الفرع: علمى → علمي');
        } else if (branch == 'أدبى') {
          updates['branch'] = 'أدبي';
          print('   ✅ تم توحيد الفرع: أدبى → أدبي');
        }
      }

      // التأكد من وجود حقل emoji
      if (!data.containsKey('emoji') || data['emoji'] == null) {
        updates['emoji'] = '📚';
        print('   ✅ تم إضافة رمز تعبيري افتراضي');
      }

      // التأكد من وجود حقل isActive
      if (!data.containsKey('isActive')) {
        updates['isActive'] = true;
        print('   ✅ تم إضافة حقل isActive');
      }

      // التأكد من صحة نوع sections
      if (data.containsKey('sections') && data['sections'] != null) {
        if (data['sections'] is String) {
          // تحويل String إلى List
          updates['sections'] = [data['sections']];
          print('   ✅ تم تحويل sections من String إلى List');
        } else if (data['sections'] is! List) {
          updates['sections'] = ['أ'];
          print('   ✅ تم إصلاح نوع sections');
        }
      } else if (!data.containsKey('sections')) {
        updates['sections'] = ['أ'];
        print('   ✅ تم إضافة حقل sections الافتراضي');
      }

      // إضافة حقل updatedAt
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // تطبيق التحديثات إذا كان هناك تغييرات
      if (updates.isNotEmpty) {
        await subjectsRef.doc(subjectId).update(updates);
        updatedCount++;
        print('   ✅ تم تحديث المادة');
      } else {
        skippedCount++;
        print('   ⏭️  لا تحتاج تحديث');
      }

      print(''); // سطر فارغ
    }

    print('📈 ملخص الإصلاحات:');
    print('🔄 مواد محدثة: $updatedCount');
    print('⏭️  مواد تم تخطيها: $skippedCount');
    print('📊 المجموع: ${updatedCount + skippedCount}');

    if (updatedCount > 0) {
      print('\n🎉 تم إصلاح البيانات بنجاح!');
      print('🔄 أعد تشغيل التطبيق لترى التحسينات.');
    } else {
      print('\n✅ جميع البيانات صحيحة بالفعل!');
    }

  } catch (e) {
    print('❌ خطأ في إصلاح البيانات: $e');
    print('🔧 تأكد من أن Firebase معد بشكل صحيح.');
  }
}
