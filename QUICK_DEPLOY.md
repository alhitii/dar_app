# ⚡ نشر سريع - Cloud Function

**3 خطوات فقط!**

---

## 🚀 **الطريقة 1: سكريبت تلقائي (الأسهل)**

```bash
# شغّل السكريبت
deploy_delete_function.bat

# انتظر حتى ترى:
✅ اكتمل النشر بنجاح!
```

---

## 🔧 **الطريقة 2: يدوياً**

```bash
# 1. اذهب لمجلد functions
cd functions

# 2. ثبت وابني
npm install && npm run build

# 3. ارجع ونشر
cd ..
firebase deploy --only functions:deleteUserCompletely
```

---

## ✅ **التحقق من النجاح:**

```
يجب أن ترى في Console:

✔  functions[deleteUserCompletely(us-central1)]
✔  Deploy complete!

Function URL: https://us-central1-...
```

---

## 🧪 **اختبر الآن:**

```bash
# شغّل التطبيق
flutter run -d windows

# احذف معلم تجريبي
# يجب أن ترى:
✅ تم حذف المعلم نهائياً من جميع الأماكن
   • Authentication
   • Firestore
   • البيانات المرتبطة
```

---

## 💡 **حل المشاكل:**

### **"Firebase CLI غير مثبت"**
```bash
npm install -g firebase-tools
firebase login
```

### **"Permission Denied"**
```bash
firebase login
# أعد تسجيل الدخول
```

### **"Build Failed"**
```bash
cd functions
rm -rf node_modules
npm install
npm run build
```

---

## 📖 **للتفاصيل الكاملة:**

اقرأ: **DEPLOY_CLOUD_FUNCTION.md**

---

**✅ جاهز للنشر! شغّل السكريبت الآن** 🚀
