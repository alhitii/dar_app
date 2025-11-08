# 🔧 إصلاح Cloud Functions على Windows

## ❌ **الخطأ:**
```
Unable to establish connection on channel: 
"dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call"
```

---

## ✅ **الإصلاحات المطبقة:**

### **1. تحديد المنطقة (Region):**
```dart
UserManagementService() {
  _functions = FirebaseFunctions.instance;
  
  // إذا كنا على Windows Desktop، استخدم المنطقة الصحيحة
  if (!kIsWeb && Platform.isWindows) {
    _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  }
}
```

### **2. إضافة Timeout:**
```dart
final callable = _functions.httpsCallable(
  'deleteUserCompletely',
  options: HttpsCallableOptions(
    timeout: const Duration(seconds: 60),
  ),
);

final result = await callable.call({...}).timeout(
  const Duration(seconds: 60),
  onTimeout: () {
    throw Exception('انتهت مهلة الاتصال بـ Cloud Function');
  },
);
```

### **3. تحسين معالجة الأخطاء:**
```dart
if (e.code == 'unavailable' || e.code == 'unknown') {
  print('💡 تلميح: تأكد من:');
  print('   1. Cloud Functions منشورة على Firebase');
  print('   2. المنطقة صحيحة (us-central1)');
  print('   3. الاتصال بالإنترنت يعمل');
}
```

---

## 🔍 **التحقق من Cloud Functions:**

### **1. تحقق من نشر الـ Function:**
```bash
# في مجلد functions
firebase deploy --only functions
```

### **2. تحقق من وجود الـ Function:**
```bash
firebase functions:list
```

يجب أن تظهر:
```
✔ deleteUserCompletely(us-central1)
```

### **3. تحقق من المنطقة:**
في ملف `functions/index.js`:
```javascript
exports.deleteUserCompletely = functions
  .region('us-central1')  // ✅ تأكد من هذا
  .https.onCall(async (data, context) => {
    // ...
  });
```

---

## 🔥 **إعدادات Firebase:**

### **Project ID:**
```
madrasa-570c9
```

### **المنطقة الافتراضية:**
```
us-central1
```

### **Cloud Functions URL:**
```
https://us-central1-madrasa-570c9.cloudfunctions.net/deleteUserCompletely
```

---

## 🛠️ **خطوات الإصلاح:**

### **الخطوة 1: تحديث الكود (✅ تم)**
```dart
// تم تحديث user_management_service.dart
```

### **الخطوة 2: التحقق من نشر Functions**
```bash
cd functions
firebase deploy --only functions:deleteUserCompletely
```

### **الخطوة 3: التحقق من الصلاحيات**
في Firebase Console:
1. اذهب إلى **Functions**
2. تأكد من وجود `deleteUserCompletely`
3. تحقق من الـ Logs

### **الخطوة 4: اختبار من Flutter**
```bash
flutter run
# جرب حذف مستخدم
```

---

## 📝 **ملف functions/index.js الصحيح:**

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.deleteUserCompletely = functions
  .region('us-central1')  // ✅ مهم!
  .https.onCall(async (data, context) => {
    // التحقق من المصادقة
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'يجب تسجيل الدخول لحذف المستخدمين'
      );
    }

    const { uid, role, email } = data;

    try {
      // حذف من Authentication
      await admin.auth().deleteUser(uid);
      
      // حذف من Firestore
      await admin.firestore().collection('users').doc(uid).delete();
      
      // حذف البيانات المرتبطة حسب الدور
      if (role === 'teacher') {
        // حذف مواد المعلم
        const subjectsSnapshot = await admin.firestore()
          .collection('subjects')
          .where('teacherId', '==', uid)
          .get();
        
        const batch = admin.firestore().batch();
        subjectsSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
      } else if (role === 'student') {
        // حذف واجبات الطالب
        const homeworkSnapshot = await admin.firestore()
          .collection('homework')
          .where('studentId', '==', uid)
          .get();
        
        const batch = admin.firestore().batch();
        homeworkSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
      }

      return {
        success: true,
        message: `تم حذف ${email} بنجاح`,
      };
    } catch (error) {
      console.error('خطأ في حذف المستخدم:', error);
      throw new functions.https.HttpsError(
        'internal',
        `فشل حذف المستخدم: ${error.message}`
      );
    }
  });
```

---

## 🔒 **الصلاحيات المطلوبة:**

في `functions/package.json`:
```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  }
}
```

---

## 🧪 **اختبار Cloud Function:**

### **من Firebase Console:**
1. اذهب إلى **Functions**
2. اختر `deleteUserCompletely`
3. اضغط **Test**
4. أدخل:
```json
{
  "uid": "test-uid",
  "role": "student",
  "email": "test@test.com"
}
```

### **من Flutter:**
```dart
final result = await UserManagementService().deleteUserCompletely(
  uid: 'test-uid',
  role: 'student',
  email: 'test@test.com',
);

print(result);
```

---

## 📊 **الأخطاء الشائعة:**

### **1. "unavailable":**
```
السبب: Cloud Function غير منشورة أو المنطقة خاطئة
الحل: firebase deploy --only functions
```

### **2. "unauthenticated":**
```
السبب: المستخدم غير مسجل دخول
الحل: تسجيل الدخول أولاً
```

### **3. "permission-denied":**
```
السبب: المستخدم ليس لديه صلاحيات
الحل: التحقق من الدور (admin فقط)
```

### **4. "timeout":**
```
السبب: Function تأخذ وقت طويل
الحل: زيادة timeout أو تحسين الكود
```

---

## ✅ **التحقق من النجاح:**

عند نجاح الحذف، يجب أن ترى:
```
📞 استدعاء Cloud Function: deleteUserCompletely
   UID: xxx
   Role: teacher
   Email: xxx@gmail.com
✅ نتيجة Cloud Function:
   {success: true, message: تم حذف xxx@gmail.com بنجاح}
```

---

## 🚀 **الخطوات التالية:**

1. ✅ **تحديث الكود** (تم)
2. ⚠️ **نشر Cloud Functions**
   ```bash
   cd functions
   firebase deploy --only functions
   ```
3. ⚠️ **اختبار من التطبيق**
4. ⚠️ **التحقق من Logs**

---

**التاريخ:** 31 أكتوبر 2025  
**المشروع:** madrasa-570c9  
**المنطقة:** us-central1  

🎊 **تم تحديث الكود! الآن انشر Cloud Functions!** 🎊
