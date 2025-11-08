# 🔥 إعداد ونشر Cloud Functions

## 📅 **التاريخ:** 31 أكتوبر 2025

---

## ❌ **المشكلة الأولية:**

```
Unable to establish connection on channel: 
"dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call"
```

---

## ✅ **الحلول المطبقة:**

### **1. تحديث Flutter Code:**

**الملف:** `lib/services/user_management_service.dart`

```dart
class UserManagementService {
  late final FirebaseFunctions _functions;

  UserManagementService() {
    // إذا كنا على Windows Desktop، استخدم المنطقة الصحيحة
    if (!kIsWeb && Platform.isWindows) {
      _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    } else {
      _functions = FirebaseFunctions.instance;
    }
  }
  
  // إضافة timeout
  final callable = _functions.httpsCallable(
    'deleteUserCompletely',
    options: HttpsCallableOptions(
      timeout: const Duration(seconds: 60),
    ),
  );
}
```

### **2. إضافة Function جديدة:**

**الملف:** `functions/index.js`

```javascript
export const deleteUserCompletely = onCall(async (request) => {
  // التحقق من المصادقة
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول");
  }

  const { uid, role, email } = request.data;

  try {
    // حذف من Firestore
    await db.collection("users").doc(uid).delete();
    
    // حذف البيانات المرتبطة
    if (role === 'teacher') {
      // حذف مواد المعلم
    } else if (role === 'student') {
      // حذف واجبات الطالب
    }
    
    // حذف من Authentication
    await auth.deleteUser(uid);
    
    return {
      success: true,
      message: `تم حذف ${email} بنجاح`
    };
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});
```

### **3. تحديث package.json:**

```json
{
  "type": "module",
  "engines": {
    "node": "22"
  },
  "main": "index.js"
}
```

### **4. تثبيت Firebase CLI:**

```powershell
npm install -g firebase-tools
```

### **5. نشر Functions:**

```powershell
cd functions
firebase deploy --only functions
```

---

## 🎯 **النتيجة:**

```
✅ deleteUserCompletely (us-central1) - نُشر بنجاح
✅ deleteUser (us-central1)
✅ autoCreateUser (us-central1)
✅ syncTeacherSubjects (us-central1)
✅ notifyStudentsOnHomework (us-central1)
✅ notifyOnAnnouncement (us-central1)
✅ notifyOnAbsence (us-central1)
✅ testAbsenceNotification (us-central1)
```

---

## 📊 **معلومات المشروع:**

- **Project ID:** madrasa-570c9
- **المنطقة:** us-central1
- **Node Version:** 22

---

**الحالة:** ✅ مكتمل ويعمل بنجاح
