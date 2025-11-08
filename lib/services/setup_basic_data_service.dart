import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/education_constants.dart';

class SetupBasicDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إعداد المواد الدراسية الأساسية
  Future<void> setupSubjects() async {
    // إعدادية علمي
    for (var subject in EducationConstants.subjectsPreparatoryScience) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'branch': 'علمي',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // إعدادية أدبي
    for (var subject in EducationConstants.subjectsPreparatoryLiterature) {
      await _firestore.collection('subjects').add({
        'name': subject['name'],
        'emoji': subject['emoji'],
        'stage': 'إعدادية',
        'branch': 'أدبي',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
