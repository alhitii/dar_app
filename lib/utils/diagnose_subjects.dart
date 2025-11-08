import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnoseSubjects {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// تشخيص المواد في Firestore
  Future<void> diagnose() async {
    print('🔍 بدء تشخيص المواد...\n');

    final subjects = await _firestore.collection('subjects').get();

    if (subjects.docs.isEmpty) {
      print('❌ لا توجد مواد في Firestore');
      return;
    }

    print('✅ عدد المواد: ${subjects.docs.length}\n');

    // تجميع حسب المرحلة والفرع
    final Map<String, List<String>> subjectsByStage = {};

    for (var doc in subjects.docs) {
      final data = doc.data();
      final stage = data['stage'] ?? 'غير محدد';
      final branch = data['branch'] ?? '';
      final name = data['name'] ?? 'بدون اسم';

      final key = branch.isEmpty ? stage : '$stage - $branch';

      if (!subjectsByStage.containsKey(key)) {
        subjectsByStage[key] = [];
      }
      subjectsByStage[key]!.add(name);
    }

    // طباعة النتائج
    for (var entry in subjectsByStage.entries) {
      print('📚 ${entry.key}: ${entry.value.length} مادة');
      for (var subject in entry.value) {
        print('   - $subject');
      }
      print('');
    }
  }
}
