import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class TeacherSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إنشاء حساب معلم جديد
  Future<Map<String, dynamic>> createTeacher({
    required String email,
    required String password,
    required String name,
    required String stage,
    required String grade,
    String? branch,
    List<String>? sections,
    List<String>? subjects,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // ✅ إنشاء Firebase App ثانوي لإنشاء حساب بدون تسجيل خروج الإدارة
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // إنشاء الحساب باستخدام Auth الثانوي
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // استخراج username من البريد
      final username = email.split('@')[0];

      // إضافة البيانات في users collection
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'name': name,
        'role': 'teacher',
        'stage': stage,
        'grade': grade,
        'branch': branch,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إضافة البيانات في teachers collection
      await _firestore.collection('teachers').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'name': name,
        'stage': stage,
        'grade': grade,
        'branch': branch,
        'sections': sections ?? [],
        'subjects': subjects ?? [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'uid': uid,
        'message': 'تم إنشاء حساب المعلم بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'فشل إنشاء الحساب: ${e.toString()}',
      };
    } finally {
      // ✅ حذف التطبيق الثانوي بعد الانتهاء
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  /// إنشاء حساب معلم جديد (مبسط - بدون مرحلة/صف/فرع)
  Future<Map<String, dynamic>> createTeacherSimple({
    required String email,
    required String password,
    required String name,
    required List<String> subjects,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // ✅ إنشاء Firebase App ثانوي لإنشاء حساب بدون تسجيل خروج الإدارة
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // إنشاء الحساب باستخدام Auth الثانوي
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // استخراج username من البريد
      final username = email.split('@')[0];

      // إضافة البيانات في users collection
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'name': name,
        'role': 'teacher',
        'subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إضافة البيانات في teachers collection
      await _firestore.collection('teachers').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'name': name,
        'subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إنشاء معلم: $name مع ${subjects.length} مادة');

      return {
        'success': true,
        'uid': uid,
        'message': 'تم إنشاء حساب المعلم بنجاح',
      };
    } catch (e) {
      print('❌ خطأ في إنشاء المعلم: $e');
      
      return {
        'success': false,
        'message': 'فشل إنشاء الحساب: ${e.toString()}',
      };
    } finally {
      // ✅ حذف التطبيق الثانوي بعد الانتهاء
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  /// إنشاء حساب معلم جديد (مع اختيارات متعددة)
  Future<Map<String, dynamic>> createTeacherMulti({
    required String email,
    required String password,
    required String name,
    required List<String> stages,
    required List<String> grades,
    required List<String> branches,
    required List<String> sections,
    required List<String> subjects,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // ✅ إنشاء Firebase App ثانوي لإنشاء حساب بدون تسجيل خروج الإدارة
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // إنشاء الحساب باستخدام Auth الثانوي
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // استخراج username من البريد
      final username = email.split('@')[0];

      // إضافة البيانات في users collection
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'name': name,
        'role': 'teacher',
        'stages': stages,
        'grades': grades,
        'branches': branches,
        'sections': sections,
        'subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إضافة البيانات في teachers collection
      await _firestore.collection('teachers').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'name': name,
        'stages': stages,
        'grades': grades,
        'branches': branches,
        'sections': sections,
        'subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إنشاء معلم: $name');
      print('   المراحل: ${stages.join(", ")}');
      print('   الصفوف: ${grades.join(", ")}');
      print('   الشعب: ${sections.join(", ")}');
      print('   المواد: ${subjects.join(", ")}');

      // تحديث مجموعة subjects في Firestore
      await _updateSubjectsCollection(
        teacherId: uid,
        teacherName: name,
        stages: stages,
        grades: grades,
        branches: branches,
        sections: sections,
        subjects: subjects,
      );

      return {
        'success': true,
        'uid': uid,
        'message': 'تم إنشاء حساب المعلم بنجاح',
      };
    } catch (e) {
      print('❌ خطأ في إنشاء المعلم: $e');
      return {
        'success': false,
        'message': 'فشل إنشاء الحساب: ${e.toString()}',
      };
    } finally {
      // ✅ حذف التطبيق الثانوي بعد الانتهاء
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  /// تحديث بيانات معلم
  Future<void> updateTeacher(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('teachers').doc(uid).update(data);
  }

  /// تحديث مجموعة subjects في Firestore
  Future<void> _updateSubjectsCollection({
    required String teacherId,
    required String teacherName,
    required List<String> stages,
    required List<String> grades,
    required List<String> branches,
    required List<String> sections,
    required List<String> subjects,
  }) async {
    try {
      print('🔄 تحديث مجموعة subjects...');
      
      // لكل مرحلة
      for (final stage in stages) {
        // لكل صف
        for (final grade in grades) {
          // لكل مادة
          for (final subjectName in subjects) {
            // إذا كانت المرحلة إعدادية ولديها فروع
            if (stage == 'إعدادية' && branches.isNotEmpty) {
              for (final branch in branches) {
                await _updateSubjectDocument(
                  stage: stage,
                  grade: grade,
                  branch: branch,
                  subjectName: subjectName,
                  teacherId: teacherId,
                  teacherName: teacherName,
                  sections: sections,
                );
              }
            } else {
              // للابتدائية والمتوسطة (بدون فرع)
              await _updateSubjectDocument(
                stage: stage,
                grade: grade,
                branch: null,
                subjectName: subjectName,
                teacherId: teacherId,
                teacherName: teacherName,
                sections: sections,
              );
            }
          }
        }
      }
      
      print('✅ تم تحديث مجموعة subjects بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث مجموعة subjects: $e');
    }
  }

  /// تحديث وثيقة مادة واحدة
  Future<void> _updateSubjectDocument({
    required String stage,
    required String grade,
    String? branch,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required List<String> sections,
  }) async {
    try {
      // البحث عن الوثيقة الموجودة
      Query query = _firestore
          .collection('subjects')
          .where('stage', isEqualTo: stage)
          .where('grade', isEqualTo: grade)
          .where('name', isEqualTo: subjectName);
      
      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        // تحديث الوثيقة الموجودة
        for (var doc in snapshot.docs) {
          await doc.reference.update({
            'teacherId': teacherId,
            'teacherName': teacherName,
            'sections': sections,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ تم تحديث: $stage - $grade - $subjectName');
        }
      } else {
        // إنشاء وثيقة جديدة
        await _firestore.collection('subjects').add({
          'stage': stage,
          'grade': grade,
          'branch': branch,
          'name': subjectName,
          'teacherId': teacherId,
          'teacherName': teacherName,
          'sections': sections,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ تم إنشاء: $stage - $grade - $subjectName');
      }
    } catch (e) {
      print('❌ خطأ في تحديث $subjectName: $e');
    }
  }
}
