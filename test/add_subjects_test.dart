import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  test('إضافة المواد الأساسية', () async {
    // تهيئة Firebase (قد تحتاج تعديل هذا حسب إعداداتك)
    // await Firebase.initializeApp();
    
    final firestore = FirebaseFirestore.instance;
    
    // المواد للإعدادية - علمي
    final scientificSubjects = [
      {'name': 'التربية الإسلامية', 'emoji': '☪️', 'order': 1},
      {'name': 'اللغة العربية', 'emoji': '📖', 'order': 2},
      {'name': 'اللغة الإنجليزية', 'emoji': '🔤', 'order': 3},
      {'name': 'الرياضيات', 'emoji': '📐', 'order': 4},
      {'name': 'الفيزياء', 'emoji': '⚛️', 'order': 5},
      {'name': 'الكيمياء', 'emoji': '🧪', 'order': 6},
      {'name': 'الأحياء', 'emoji': '🧬', 'order': 7},
      {'name': 'الحاسوب', 'emoji': '💻', 'order': 8},
      {'name': 'اللغة الفرنسية', 'emoji': '🇫🇷', 'order': 9},
    ];
    
    // إضافة للصفوف الرابع والخامس والسادس
    for (final grade in ['الرابع', 'الخامس', 'السادس']) {
      for (final subject in scientificSubjects) {
        final docId = 'sec_${grade}_${subject['name']}_sci'
            .replaceAll(' ', '_')
            .replaceAll('ا', 'a')
            .replaceAll('ل', 'l');
            
        await firestore.collection('subjects').doc(docId).set({
          'name': subject['name'],
          'emoji': subject['emoji'],
          'stage': 'إعدادية',
          'grade': grade,
          'branch': 'علمي',
          'order': subject['order'],
          'isActive': true,
        });
        
        print('✅ ${subject['emoji']} ${subject['name']} - $grade');
      }
    }
    
    print('\n✅ تم إضافة 27 مادة للإعدادية - علمي');
  });
}
