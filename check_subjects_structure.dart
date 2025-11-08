import 'package:cloud_firestore/cloud_firestore.dart';

/// سكريبت للتحقق من هيكل بيانات المواد في Firestore
void main() async {
  print('🔍 بدء التحقق من بيانات المواد في Firestore...\n');

  try {
    // الحصول على جميع المواد
    final snapshot = await FirebaseFirestore.instance.collection('subjects').get();

    print('📊 إجمالي المواد الموجودة: ${snapshot.docs.length}\n');

    int validCount = 0;
    int invalidCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final subjectId = doc.id;

      print('📝 فحص المادة: $subjectId');

      // التحقق من الحقول المطلوبة
      final requiredFields = ['name', 'stage', 'grade'];
      final optionalFields = ['branch', 'sections', 'teacherName', 'teacherUid', 'emoji', 'isActive'];

      bool isValid = true;
      List<String> missingFields = [];
      List<String> invalidTypes = [];

      // التحقق من الحقول المطلوبة
      for (var field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null || data[field].toString().isEmpty) {
          missingFields.add(field);
          isValid = false;
        }
      }

      // التحقق من أنواع البيانات
      if (data.containsKey('name') && data['name'] is! String) {
        invalidTypes.add('name يجب أن يكون String');
        isValid = false;
      }
      if (data.containsKey('stage') && data['stage'] is! String) {
        invalidTypes.add('stage يجب أن يكون String');
        isValid = false;
      }
      if (data.containsKey('grade') && data['grade'] is! String) {
        invalidTypes.add('grade يجب أن يكون String');
        isValid = false;
      }
      if (data.containsKey('branch') && data['branch'] != null && data['branch'] is! String) {
        invalidTypes.add('branch يجب أن يكون String');
        isValid = false;
      }
      if (data.containsKey('sections') && data['sections'] != null && data['sections'] is! List) {
        invalidTypes.add('sections يجب أن يكون List');
        isValid = false;
      }
      if (data.containsKey('teacherName') && data['teacherName'] != null && data['teacherName'] is! String) {
        invalidTypes.add('teacherName يجب أن يكون String');
        isValid = false;
      }
      if (data.containsKey('teacherUid') && data['teacherUid'] != null && data['teacherUid'] is! String) {
        invalidTypes.add('teacherUid يجب أن يكون String');
        isValid = false;
      }

      if (isValid) {
        validCount++;
        print('✅ صحيحة');

        // عرض المعلومات الأساسية
        print('   📚 الاسم: ${data['name']}');
        print('   🏫 المرحلة: ${data['stage']}');
        print('   📖 الصف: ${data['grade']}');
        if (data.containsKey('branch') && data['branch'] != null) {
          print('   🔀 الفرع: ${data['branch']}');
        }
        if (data.containsKey('teacherName') && data['teacherName'] != null) {
          print('   👨‍🏫 المعلم: ${data['teacherName']}');
        }
        if (data.containsKey('sections') && data['sections'] != null) {
          print('   👥 الشعب: ${data['sections']}');
        }
      } else {
        invalidCount++;
        print('❌ غير صحيحة');

        if (missingFields.isNotEmpty) {
          print('   ❌ الحقول المفقودة: ${missingFields.join(', ')}');
        }
        if (invalidTypes.isNotEmpty) {
          print('   ❌ أخطاء الأنواع: ${invalidTypes.join(', ')}');
        }
      }

      print(''); // سطر فارغ
    }

    print('📈 ملخص النتائج:');
    print('✅ مواد صحيحة: $validCount');
    print('❌ مواد غير صحيحة: $invalidCount');
    print('📊 المجموع: ${validCount + invalidCount}');

    if (invalidCount > 0) {
      print('\n⚠️  يوجد $invalidCount مادة تحتاج إصلاح!');
      print('🔧 يرجى التحقق من البيانات وإصلاح الأخطاء.');
    } else {
      print('\n🎉 جميع المواد صحيحة! النظام جاهز للاستخدام.');
    }

  } catch (e) {
    print('❌ خطأ في الاتصال بـ Firestore: $e');
    print('🔧 تأكد من أن Firebase معد بشكل صحيح.');
  }
}
