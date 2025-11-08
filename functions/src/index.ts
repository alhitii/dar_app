import * as admin from 'firebase-admin';

// تهيئة Firebase Admin
admin.initializeApp();

// تصدير Cloud Functions
export { deleteUserCompletely } from './deleteUserCompletely';

// يمكن إضافة المزيد من Cloud Functions هنا
// export { anotherFunction } from './anotherFunction';
