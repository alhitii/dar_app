# 🚀 كيفية نشر Cloud Functions لحذف المستخدم من Authentication

## ⚠️ المشكلة الحالية:

الحساب يُحذف من **Firestore** فقط ولا يُحذف من **Firebase Authentication**.

---

## ✅ الحل:

نشر Cloud Function التي تحذف من Authentication.

---

## 📋 الخطوات:

### **1️⃣ تثبيت Firebase CLI (إذا لم يكن مثبتاً):**

```bash
npm install -g firebase-tools
```

---

### **2️⃣ تسجيل الدخول لـ Firebase:**

```bash
firebase login
```

---

### **3️⃣ الانتقال لمجلد Functions:**

```bash
cd functions
```

---

### **4️⃣ تثبيت المكتبات:**

```bash
npm install
```

---

### **5️⃣ نشر الدالة:**

**خيار 1: نشر دالة واحدة فقط (أسرع):**
```bash
firebase deploy --only functions:deleteUserCompletely
```

**خيار 2: نشر جميع Functions:**
```bash
firebase deploy --only functions
```

---

## 🔍 التحقق من النشر:

بعد النشر، ستظهر رسالة مثل:

```
✔  functions[deleteUserCompletely(us-central1)] Successful create operation.
Function URL: https://us-central1-[project-id].cloudfunctions.net/deleteUserCompletely
```

---

## 🧪 اختبار الحذف:

1. افتح التطبيق
2. اذهب لصفحة الإدارة
3. حاول حذف حساب طالب
4. يجب أن يُحذف من:
   - ✅ Firestore
   - ✅ Authentication

---

## 📝 ملاحظات:

### **إذا لم تستطع نشر Functions:**

الحل البديل الحالي يعمل:
- ✅ يحذف من Firestore
- ⚠️ يجب حذف من Authentication يدوياً من Firebase Console

### **للحذف اليدوي من Authentication:**

1. افتح [Firebase Console](https://console.firebase.google.com)
2. اختر المشروع
3. اذهب إلى **Authentication** > **Users**
4. ابحث عن البريد الإلكتروني
5. احذف الحساب يدوياً

---

## 🔧 استكشاف الأخطاء:

### **خطأ: firebase command not found**

```bash
# تثبيت Firebase CLI
npm install -g firebase-tools
```

### **خطأ: Permission denied**

```bash
# تسجيل الدخول مرة أخرى
firebase login --reauth
```

### **خطأ: Functions region mismatch**

تأكد أن المنطقة في `index.js` هي `us-central1`.

---

## 💡 الخلاصة:

**الحالة الحالية:**
- ✅ الكود جاهز
- ✅ Cloud Function موجودة في `functions/index.js`
- ⚠️ لم يتم نشرها بعد

**بعد النشر:**
- ✅ حذف تلقائي من Authentication
- ✅ حذف تلقائي من Firestore
- ✅ لا حاجة لحذف يدوي

---

**لنشر Functions، استخدم الأوامر أعلاه! 🚀**
