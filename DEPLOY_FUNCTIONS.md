# 🚀 تفعيل Cloud Functions لحذف المستخدمين

## ✅ **الإعداد مكتمل في الكود!**

تم إضافة:
- ✅ `cloud_functions` في pubspec.yaml
- ✅ Cloud Function في `functions/index.js`
- ✅ استدعاء Function في `firebase_user_service.dart`

---

## 📦 **خطوات Deploy:**

### **1️⃣ تثبيت Firebase CLI (مرة واحدة فقط):**

افتح PowerShell كـ **Administrator** وشغّل:

```powershell
npm install -g firebase-tools
```

إذا لم يكن لديك Node.js:
1. حمّل من: https://nodejs.org/
2. ثبّت Node.js
3. ثم شغّل الأمر أعلاه

---

### **2️⃣ تسجيل الدخول:**

```powershell
firebase login
```

سيفتح متصفح - سجل دخول بحساب Firebase

---

### **3️⃣ Deploy Functions:**

```powershell
cd d:\test\madrasah
firebase deploy --only functions:deleteUser
```

انتظر 2-3 دقائق حتى يكتمل Deploy

---

### **4️⃣ اختبار:**

بعد Deploy:
1. شغّل التطبيق
2. احذف طالب
3. راقب Terminal - يجب أن ترى:

```
🗑️ محاولة حذف الطالب...
   1️⃣ حذف من students...
   ✅ تم الحذف من students
   2️⃣ حذف من users_emails...
   ✅ تم الحذف من users_emails
   3️⃣ حذف من users...
   ✅ تم الحذف من users
   4️⃣ محاولة حذف من Authentication...
   ✅ تم الحذف من Authentication: تم حذف المستخدم من Authentication بنجاح
✅✅ تم حذف الطالب نهائياً من Firebase
```

---

## 🔍 **التحقق من Firebase Console:**

1. افتح: https://console.firebase.google.com
2. اختر مشروعك
3. **Authentication → Users**
   - المستخدم المحذوف يجب ألا يظهر! ✅

4. **Functions**
   - يجب أن ترى: `deleteUser` ✅

---

## ❌ **إذا ظهرت أخطاء:**

### **خطأ: "firebase: command not found"**
```powershell
npm install -g firebase-tools
```

### **خطأ: "Permission denied"**
افتح PowerShell كـ Administrator

### **خطأ أثناء Deploy:**
تأكد من:
- ✅ أنت في مجلد المشروع: `d:\test\madrasah`
- ✅ لديك Firebase Blaze Plan (مدفوع)
- ✅ مسجل دخول: `firebase login`

---

## 💰 **التكلفة:**

Cloud Functions على Blaze Plan:
- **أول 2 مليون استدعاء/شهر: مجاني!** 🎉
- بعد ذلك: $0.40 لكل مليون استدعاء

**حذف 100 طالب/يوم = 3000/شهر = مجاني تماماً!**

---

## 📞 **الدعم:**

إذا واجهت مشاكل:
1. تأكد من تشغيل Terminal كـ Administrator
2. تأكد من اتصال الإنترنت
3. جرّب: `firebase --version` للتأكد من التثبيت

---

**بعد Deploy، الحذف سيعمل تلقائياً!** 🎉
