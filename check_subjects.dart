import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  final firestore = FirebaseFirestore.instance;

  print('🔍 فحص المواد في Firestore...\n');

  // فحص الابتدائية
  print('📚 المرحلة الابتدائية:');
  final primary = await firestore.collection('subjects')
      .where('stage', isEqualTo: 'ابتدائية')
      .get();

  primary.docs.forEach((doc) {
    final data = doc.data();
    print('  ${data['name']} - branch: ${data['branch'] ?? 'null'}');
  });

  // فحص المتوسطة
  print('\n📚 المرحلة المتوسطة:');
  final middle = await firestore.collection('subjects')
      .where('stage', isEqualTo: 'متوسطة')
      .get();

  middle.docs.forEach((doc) {
    final data = doc.data();
    print('  ${data['name']} - branch: ${data['branch'] ?? 'null'}');
  });

  // فحص الإعدادية
  print('\n📚 المرحلة الإعدادية:');
  final secondary = await firestore.collection('subjects')
      .where('stage', isEqualTo: 'إعدادية')
      .get();

  secondary.docs.forEach((doc) {
    final data = doc.data();
    print('  ${data['name']} - branch: ${data['branch'] ?? 'null'}');
  });

  print('\n✅ انتهى الفحص');
}
