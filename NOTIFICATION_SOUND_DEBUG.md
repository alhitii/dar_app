# 🔊 حل مشكلة صوت الإشعار

## ❌ **المشكلة:**
```
جربت flutter clean وإعادة تثبيت
لكن صوت الإشعار لم يصل
```

---

## 🔍 **التشخيص المطلوب:**

### **الخطوة 1: تحقق من FCM Token**

**افتح التطبيق وسجّل دخول:**
```bash
flutter run
```

**ابحث في Terminal عن:**
```
🔑 FCM Token: eFv9k3tn...
✅ تم حفظ البيانات في users (مع FCM Token)
```

**إذا لم تظهر هذه الرسائل:**
```
❌ FCM Token لم يُحفظ
الحل في الخطوة 2 ↓
```

---

### **الخطوة 2: تحقق من Firestore**

**Firebase Console:**
```
1. افتح Firebase Console
2. Firestore Database
3. collection: users
4. افتح document الطالب (UID)
5. ابحث عن field: fcmToken
```

**النتيجة:**
```
✅ إذا كان موجود:
   fcmToken: "eFv9k3tn..."
   → انتقل للخطوة 3

❌ إذا كان null أو غير موجود:
   → المشكلة هنا! انتقل للحل A
```

---

### **الخطوة 3: اختبر من Firebase Console**

**أرسل إشعار يدوياً:**
```
1. Firebase Console → Cloud Messaging
2. Create notification
3. Title: اختبار صوت
4. Body: هل يصل؟
5. Target: FCM registration token
6. الصق FCM Token من users
7. Additional options:
   ✅ Sound: Enabled
   ✅ Channel: high_importance_channel
8. Send test message
```

**النتيجة:**
```
✅ وصل مع صوت؟
   → المشكلة في Cloud Function (الخطوة 4)

❌ وصل بدون صوت؟
   → المشكلة في إعدادات الهاتف (الحل B)

❌ لم يصل نهائياً؟
   → المشكلة في FCM Token (الحل A)
```

---

### **الخطوة 4: تحقق من Cloud Function Logs**

**Firebase Console:**
```
1. Functions → Logs
2. ابحث عن: "notifyStudentsOnHomework"
3. تحقق من الرسائل
```

**النتائج المحتملة:**
```
✅ "Homework notifications: 1 success, 0 failed"
   → Cloud Function تعمل، المشكلة في الهاتف

❌ "No FCM tokens found"
   → FCM Token غير موجود (الحل A)

❌ خطأ آخر
   → انسخ الخطأ وأرسله لي
```

---

## ✅ **الحلول:**

### **الحل A: إصلاح FCM Token**

#### **السبب:**
```
FCM Token لم يُحفظ في Firestore
أو
auth_service.dart لم يتم تحديثه
```

#### **الحل:**

**1. تحقق من auth_service.dart:**
<function_calls>
<invoke name="grep_search">
<parameter name="SearchPath">d:/test/madrasah/lib/services/auth_service.dart
