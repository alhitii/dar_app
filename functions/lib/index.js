"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserCompletely = void 0;
const admin = require("firebase-admin");
// تهيئة Firebase Admin
admin.initializeApp();
// تصدير Cloud Functions
var deleteUserCompletely_1 = require("./deleteUserCompletely");
Object.defineProperty(exports, "deleteUserCompletely", { enumerable: true, get: function () { return deleteUserCompletely_1.deleteUserCompletely; } });
// يمكن إضافة المزيد من Cloud Functions هنا
// export { anotherFunction } from './anotherFunction';
//# sourceMappingURL=index.js.map