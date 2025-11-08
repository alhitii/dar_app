import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// سكريبت لإصلاح أسماء المعلمين في جميع المواد
/// يقوم بتحديث جميع المواد التي لها teacherId لكن بدون teacherName

Future<void> main() async {
  print('🔧 بدء إصلاح أسماء المعلمين في المواد...\n');

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  try {
    // 1. جلب جميع المواد
    print('📚 جلب جميع المواد...');
    final subjectsSnapshot = await firestore.collection('subjects').get();
    print('✅ تم العثور على ${subjectsSnapshot.docs.length} مادة\n');

    int fixedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    // 2. فحص كل مادة
    for (var subjectDoc in subjectsSnapshot.docs) {
      final subjectData = subjectDoc.data();
      final subjectName = subjectData['name'] as String?;
      final teacherId = subjectData['teacherId'] as String?;
      final teacherName = subjectData['teacherName'] as String?;

      print('📖 المادة: $subjectName');
      print('   - teacherId: ${teacherId ?? "غير موجود"}');
      print('   - teacherName: ${teacherName ?? "غير موجود"}');

      // إذا كان هناك teacherId لكن لا يوجد teacherName
      if (teacherId != null && teacherId.isNotEmpty && (teacherName == null || teacherName.isEmpty)) {
        try {
          // جلب اسم المعلم من users collection
          final teacherDoc = await firestore.collection('users').doc(teacherId).get();
          
          if (teacherDoc.exists) {
            final teacherData = teacherDoc.data();
            final actualTeacherName = teacherData?['name'] as String?;

            if (actualTeacherName != null && actualTeacherName.isNotEmpty) {
              // تحديث المادة
              await firestore.collection('subjects').doc(subjectDoc.id).update({
                'teacherName': actualTeacherName,
              });

              print('   ✅ تم التحديث: $actualTeacherName\n');
              fixedCount++;
            } else {
              print('   ⚠️ المعلم موجود لكن بدون اسم\n');
              skippedCount++;
            }
          } else {
            print('   ⚠️ المعلم غير موجود في users\n');
            skippedCount++;
          }
        } catch (e) {
          print('   ❌ خطأ: $e\n');
          errorCount++;
        }
      } else if (teacherName != null && teacherName.isNotEmpty) {
        print('   ✓ اسم المعلم موجود بالفعل\n');
        skippedCount++;
      } else {
        print('   ⚠️ لا يوجد معلم مخصص لهذه المادة\n');
        skippedCount++;
      }
    }

    // 3. النتائج النهائية
    print('\n' + '=' * 50);
    print('📊 النتائج النهائية:');
    print('=' * 50);
    print('✅ تم إصلاح: $fixedCount مادة');
    print('⚠️ تم تجاهل: $skippedCount مادة');
    print('❌ أخطاء: $errorCount مادة');
    print('📚 المجموع: ${subjectsSnapshot.docs.length} مادة');
    print('=' * 50);

    if (fixedCount > 0) {
      print('\n🎉 تم إصلاح أسماء المعلمين بنجاح!');
      print('💡 الآن جميع المواد تحتوي على اسم المعلم');
    } else {
      print('\n✓ جميع المواد محدثة بالفعل');
    }

  } catch (e) {
    print('\n❌ خطأ عام: $e');
  }

  print('\n✅ انتهى السكريبت');
}
