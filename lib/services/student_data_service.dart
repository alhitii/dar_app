import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// الحصول على بيانات طالب
  Future<DocumentSnapshot> getStudent(String uid) async {
    return await _firestore.collection('students').doc(uid).get();
  }

  /// الحصول على جميع الطلاب
  Stream<QuerySnapshot> getAllStudents() {
    return _firestore.collection('students').orderBy('name').snapshots();
  }

  /// الحصول على طلاب حسب الصف والشعبة
  Stream<QuerySnapshot> getStudentsByGradeAndSection({
    required String stage,
    required String grade,
    required String section,
  }) {
    return _firestore
        .collection('students')
        .where('stage', isEqualTo: stage)
        .where('grade', isEqualTo: grade)
        .where('section', isEqualTo: section)
        .orderBy('name')
        .snapshots();
  }
}
