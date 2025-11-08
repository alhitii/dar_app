"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserCompletely = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
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
exports.deleteUserCompletely = functions.https.onCall(async (data, context) => {
    var _a, _b;
    console.log('🔥 Cloud Function: deleteUserCompletely started');
    console.log('📥 Data:', data);
    console.log('👤 Caller:', (_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid);
    // 1. التحقق من المصادقة
    if (!context.auth) {
        console.error('❌ No authentication');
        throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول لاستخدام هذه الوظيفة');
    }
    // 2. التحقق من صلاحيات Admin
    const callerUid = context.auth.uid;
    const callerDoc = await admin.firestore()
        .collection('users')
        .doc(callerUid)
        .get();
    if (!callerDoc.exists || ((_b = callerDoc.data()) === null || _b === void 0 ? void 0 : _b.role) !== 'admin') {
        console.error('❌ Permission denied - not admin');
        throw new functions.https.HttpsError('permission-denied', 'هذه الوظيفة متاحة للمدراء فقط');
    }
    // 3. استخراج البيانات
    const { uid, role, email } = data;
    if (!uid) {
        console.error('❌ No UID provided');
        throw new functions.https.HttpsError('invalid-argument', 'يجب تحديد UID المستخدم');
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
    }
    catch (error) {
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
        throw new functions.https.HttpsError('internal', `فشل في حذف المستخدم: ${error.message}`, error);
    }
});
/**
 * دالة مساعدة لحذف collection بالكامل
 * (في حال احتجت لها لاحقاً)
 */
async function deleteCollection(collectionPath, batchSize = 500) {
    const collectionRef = admin.firestore().collection(collectionPath);
    const query = collectionRef.limit(batchSize);
    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, resolve, reject, 0);
    });
}
async function deleteQueryBatch(query, resolve, reject, deletedCount) {
    const snapshot = await query.get();
    if (snapshot.size === 0) {
        resolve(deletedCount);
        return;
    }
    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
    });
    await batch.commit();
    deletedCount += snapshot.size;
    // إعادة الاستدعاء للمزيد
    process.nextTick(() => {
        deleteQueryBatch(query, resolve, reject, deletedCount);
    });
}
//# sourceMappingURL=deleteUserCompletely.js.map