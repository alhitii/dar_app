// سكريبت لإصلاح أسماء المعلمين في جميع المواد
// يقوم بتحديث جميع المواد التي لها teacherId لكن بدون teacherName

import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// تهيئة Firebase Admin
initializeApp();
const db = getFirestore();

async function fixTeacherNames() {
  console.log('🔧 بدء إصلاح أسماء المعلمين في المواد...\n');

  try {
    // 1. جلب جميع المواد
    console.log('📚 جلب جميع المواد...');
    const subjectsSnapshot = await db.collection('subjects').get();
    console.log(`✅ تم العثور على ${subjectsSnapshot.size} مادة\n`);

    let fixedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    // 2. فحص كل مادة
    for (const subjectDoc of subjectsSnapshot.docs) {
      const subjectData = subjectDoc.data();
      const subjectName = subjectData.name;
      const teacherId = subjectData.teacherId;
      const teacherName = subjectData.teacherName;

      console.log(`📖 المادة: ${subjectName}`);
      console.log(`   - teacherId: ${teacherId || "غير موجود"}`);
      console.log(`   - teacherName: ${teacherName || "غير موجود"}`);

      // إذا كان هناك teacherId لكن لا يوجد teacherName
      if (teacherId && (!teacherName || teacherName.trim() === '')) {
        try {
          // جلب اسم المعلم من users collection
          const teacherDoc = await db.collection('users').doc(teacherId).get();
          
          if (teacherDoc.exists) {
            const teacherData = teacherDoc.data();
            const actualTeacherName = teacherData.name;

            if (actualTeacherName && actualTeacherName.trim() !== '') {
              // تحديث المادة
              await db.collection('subjects').doc(subjectDoc.id).update({
                teacherName: actualTeacherName,
              });

              console.log(`   ✅ تم التحديث: ${actualTeacherName}\n`);
              fixedCount++;
            } else {
              console.log('   ⚠️ المعلم موجود لكن بدون اسم\n');
              skippedCount++;
            }
          } else {
            console.log('   ⚠️ المعلم غير موجود في users\n');
            skippedCount++;
          }
        } catch (e) {
          console.log(`   ❌ خطأ: ${e.message}\n`);
          errorCount++;
        }
      } else if (teacherName && teacherName.trim() !== '') {
        console.log('   ✓ اسم المعلم موجود بالفعل\n');
        skippedCount++;
      } else {
        console.log('   ⚠️ لا يوجد معلم مخصص لهذه المادة\n');
        skippedCount++;
      }
    }

    // 3. النتائج النهائية
    console.log('\n' + '='.repeat(50));
    console.log('📊 النتائج النهائية:');
    console.log('='.repeat(50));
    console.log(`✅ تم إصلاح: ${fixedCount} مادة`);
    console.log(`⚠️ تم تجاهل: ${skippedCount} مادة`);
    console.log(`❌ أخطاء: ${errorCount} مادة`);
    console.log(`📚 المجموع: ${subjectsSnapshot.size} مادة`);
    console.log('='.repeat(50));

    if (fixedCount > 0) {
      console.log('\n🎉 تم إصلاح أسماء المعلمين بنجاح!');
      console.log('💡 الآن جميع المواد تحتوي على اسم المعلم');
    } else {
      console.log('\n✓ جميع المواد محدثة بالفعل');
    }

  } catch (e) {
    console.error('\n❌ خطأ عام:', e);
  }

  console.log('\n✅ انتهى السكريبت');
  process.exit(0);
}

// تشغيل السكريبت
fixTeacherNames();
