import 'package:cloud_firestore/cloud_firestore.dart';

class StudentTeacherSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// مزامنة بيانات المعلم مع الطلاب
  Future<void> syncTeacherData({
    required String teacherUid,
    required String stage,
    required String grade,
    required String section,
  }) async {
    // جلب الطلاب المطابقين
    final students = await _firestore
        .collection('students')
        .where('stage', isEqualTo: stage)
        .where('grade', isEqualTo: grade)
        .where('section', isEqualTo: section)
        .get();

    // تحديث كل طالب
    final batch = _firestore.batch();
    for (var student in students.docs) {
      batch.update(student.reference, {
        'teacherUid': teacherUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
