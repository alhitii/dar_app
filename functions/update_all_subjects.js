// سكريبت لتحديث جميع المواد بأسماء المعلمين
// يقوم بتشغيل syncTeacherSubjects لكل معلم

import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

// تهيئة Firebase Admin
initializeApp();
const db = getFirestore();

async function updateAllSubjects() {
  console.log('🔧 بدء تحديث جميع المواد بأسماء المعلمين...\n');

  try {
    // 1. جلب جميع المعلمين
    console.log('👨‍🏫 جلب جميع المعلمين...');
    const teachersSnapshot = await db.collection('users')
      .where('role', '==', 'teacher')
      .get();
    
    console.log(`✅ تم العثور على ${teachersSnapshot.size} معلم\n`);

    let successCount = 0;
    let errorCount = 0;

    // 2. تحديث مواد كل معلم
    for (const teacherDoc of teachersSnapshot.docs) {
      const teacherData = teacherDoc.data();
      const teacherName = teacherData.name;
      const subjects = teacherData.subjects || [];

      console.log(`📖 المعلم: ${teacherName}`);
      console.log(`   - عدد المواد: ${subjects.length}`);

      if (subjects.length === 0) {
        console.log('   ⚠️ لا توجد مواد مخصصة\n');
        continue;
      }

      try {
        const batch = db.batch();

        // تحديث كل مادة
        for (const subjectId of subjects) {
          const subjectRef = db.collection('subjects').doc(subjectId);
          batch.update(subjectRef, {
            teacherId: teacherDoc.id,
            teacherName: teacherName,
            lastUpdated: FieldValue.serverTimestamp()
          });
        }

        await batch.commit();
        console.log(`   ✅ تم تحديث ${subjects.length} مادة\n`);
        successCount++;
      } catch (e) {
        console.log(`   ❌ خطأ: ${e.message}\n`);
        errorCount++;
      }
    }

    // 3. النتائج النهائية
    console.log('\n' + '='.repeat(50));
    console.log('📊 النتائج النهائية:');
    console.log('='.repeat(50));
    console.log(`✅ معلمون تم تحديث موادهم: ${successCount}`);
    console.log(`❌ أخطاء: ${errorCount}`);
    console.log(`📚 المجموع: ${teachersSnapshot.size} معلم`);
    console.log('='.repeat(50));

    if (successCount > 0) {
      console.log('\n🎉 تم تحديث جميع المواد بنجاح!');
      console.log('💡 الآن جميع المواد تحتوي على اسم المعلم');
    }

  } catch (e) {
    console.error('\n❌ خطأ عام:', e);
  }

  console.log('\n✅ انتهى السكريبت');
  process.exit(0);
}

// تشغيل السكريبت
updateAllSubjects();
