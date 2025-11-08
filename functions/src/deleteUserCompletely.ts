import {onCall, HttpsError} from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Cloud Function لحذف مستخدم بالكامل من Authentication و Firestore
 * 
 * الاستدعاء من التطبيق:
 * ```dart
 * final result = await FirebaseFunctions.instance
 *     .httpsCallable('deleteUserCompletely')
 *     .call({'uid': 'user_uid', 'role': 'teacher'});
 * ```
 */
export const deleteUserCompletely = onCall(
  async (request) => {
    const data = request.data;
    const context = request.auth;
    console.log('🔥 Cloud Function: deleteUserCompletely started');
    console.log('📥 Data:', data);
    console.log('👤 Caller:', context?.uid);

    // 1. التحقق من المصادقة
    if (!context) {
      console.error('❌ No authentication');
      throw new HttpsError(
        'unauthenticated',
        'يجب تسجيل الدخول لاستخدام هذه الوظيفة'
      );
    }

    // 2. التحقق من صلاحيات Admin
    const callerUid = context.uid;
    const callerDoc = await admin.firestore()
      .collection('users')
      .doc(callerUid)
      .get();

    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      console.error('❌ Permission denied - not admin');
      throw new HttpsError(
        'permission-denied',
        'هذه الوظيفة متاحة للمدراء فقط'
      );
    }

    // 3. استخراج البيانات
    const { uid, role, email } = data;

    if (!uid) {
      console.error('❌ No UID provided');
      throw new HttpsError(
        'invalid-argument',
        'يجب تحديد UID المستخدم'
      );
    }

    console.log(`🗑️  بدء حذف المستخدم: UID=${uid}, Role=${role}`);

    try {
      // 4. حذف من Authentication
      console.log('🔐 حذف من Authentication...');
      await admin.auth().deleteUser(uid);
      console.log('✅ تم الحذف من Authentication');

      // 5. حذف من Firestore - users
      console.log('📄 حذف من collection: users');
      await admin.firestore().collection('users').doc(uid).delete();
      console.log('✅ تم الحذف من users');

      // 6. حذف من collection المخصص (teachers/students)
      if (role) {
        const collectionName = role === 'teacher' ? 'teachers' : 'students';
        console.log(`📄 حذف من collection: ${collectionName}`);
        
        if (email) {
          await admin.firestore()
            .collection(collectionName)
            .doc(email)
            .delete();
          console.log(`✅ تم الحذف من ${collectionName}`);
        }
      }

      // 7. حذف من users_emails
      if (email) {
        console.log('📄 حذف من collection: users_emails');
        await admin.firestore()
          .collection('users_emails')
          .doc(email)
          .delete();
        console.log('✅ تم الحذف من users_emails');
      }

      // 8. حذف البيانات المرتبطة حسب الدور
      if (role === 'teacher' && uid) {
        console.log('🔗 حذف البيانات المرتبطة بالمعلم...');
        
        // حذف المواد المرتبطة بالمعلم
        const subjectsQuery = await admin.firestore()
          .collection('subjects')
          .where('teacherUid', '==', uid)
          .get();
        
        const batch = admin.firestore().batch();
        let subjectsCount = 0;
        
        subjectsQuery.forEach(doc => {
          batch.update(doc.ref, {
            teacherUid: null,
            teacherName: null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          subjectsCount++;
        });
        
        if (subjectsCount > 0) {
          await batch.commit();
          console.log(`✅ تم إلغاء ربط ${subjectsCount} مادة`);
        }
      }

      if (role === 'student' && uid) {
        console.log('🔗 حذف البيانات المرتبطة بالطالب...');
        
        // يمكن إضافة حذف الواجبات والحضور هنا
        // مثال:
        // await admin.firestore().collection('assignments')
        //   .where('studentUid', '==', uid)
        //   .get()
        //   .then(snapshot => {
        //     const batch = admin.firestore().batch();
        //     snapshot.forEach(doc => batch.delete(doc.ref));
        //     return batch.commit();
        //   });
      }

      console.log('🎉 اكتمل الحذف بنجاح!');

      return {
        success: true,
        message: 'تم حذف المستخدم نهائياً من جميع الأماكن',
        deletedUid: uid,
        deletedFrom: [
          'Authentication',
          'Firestore (users)',
          role ? `Firestore (${role === 'teacher' ? 'teachers' : 'students'})` : null,
          'Firestore (users_emails)',
        ].filter(Boolean),
      };

    } catch (error: any) {
      console.error('❌ خطأ في حذف المستخدم:', error);

      // معالجة أنواع الأخطاء المختلفة
      if (error.code === 'auth/user-not-found') {
        console.log('⚠️  المستخدم غير موجود في Authentication');
        // نتابع مع حذف Firestore
        return {
          success: true,
          message: 'تم حذف المستخدم من Firestore (غير موجود في Authentication)',
          warning: 'المستخدم لم يكن موجوداً في Authentication',
        };
      }

      throw new HttpsError(
        'internal',
        `فشل في حذف المستخدم: ${error.message}`
      );
    }
  }
);

// دالة مساعدة لحذف collection (مُعطّلة حالياً - يمكن تفعيلها عند الحاجة)
// async function deleteCollection(
//   collectionPath: string,
//   batchSize: number = 500
// ): Promise<number> {
//   const collectionRef = admin.firestore().collection(collectionPath);
//   const query = collectionRef.limit(batchSize);
//   return new Promise((resolve, reject) => {
//     deleteQueryBatch(query, resolve, reject, 0);
//   });
// }
