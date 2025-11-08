# 🔔 دليل نظام الإشعارات

## ✅ **التحديثات المطبقة:**

### **1️⃣ Flutter (notification_service.dart):**

#### **أ) طلب الصلاحيات بشكل كامل:**
```dart
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  announcement: true,
  badge: true,
  sound: true,  // ✅ تفعيل صوت الإشعارات
);
```

#### **ب) إنشاء Notification Channel مع صوت:**
```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات مهمة',
  importance: Importance.high,
  playSound: true,        // ✅ تفعيل الصوت
  enableVibration: true,
  showBadge: true,
);
```

#### **ج) تفعيل الإشعارات في Foreground:**
```dart
await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,  // ✅ صوت حتى عند فتح التطبيق
);
```

#### **د) عرض الإشعار مع صوت:**
```dart
_fln.show(
  notification.hashCode,
  notification.title,
  notification.body,
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'high_importance_channel',
      'إشعارات مهمة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,  // ✅ صوت
      enableVibration: true,
    ),
  ),
);
```

---

### **2️⃣ Cloud Functions (index.js):**

#### **الرسالة الآن تحتوي على:**
```javascript
const message = {
  notification: {
    title: `📘 واجب جديد في مادة ${subjectData.name}`,
    body: data.title || "تمت إضافة واجب جديد",
  },
  android: {
    priority: "high",
    notification: {
      sound: "default",  // ✅ صوت افتراضي
      channelId: "high_importance_channel",
      priority: "high",
    },
  },
  apns: {
    payload: {
      aps: {
        sound: "default",  // ✅ صوت لـ iOS
        badge: 1,
      },
    },
  },
  tokens,
};
```

---

## 📊 **كيف يعمل النظام الآن:**

### **حالة 1: التطبيق مفتوح (Foreground)**

```
1. تصل رسالة FCM
   ↓
2. onMessage.listen() يلتقطها
   ↓
3. _onForegroundMessage() يعالجها
   ↓
4. _fln.show() يعرضها في شريط الإشعارات
   ↓
5. ✅ الصوت يُشغَّل
   ✅ الاهتزاز يعمل
   ✅ الإشعار يظهر
```

---

### **حالة 2: التطبيق في الخلفية (Background)**

```
1. تصل رسالة FCM
   ↓
2. FCM System يعالجها تلقائياً
   ↓
3. _firebaseMessagingBackgroundHandler() يطبع log فقط
   ↓
4. ✅ الصوت يُشغَّل تلقائياً (من payload)
   ✅ الاهتزاز يعمل
   ✅ الإشعار يظهر في شريط الإشعارات
```

---

### **حالة 3: التطبيق مغلق تماماً (Terminated)**

```
1. تصل رسالة FCM
   ↓
2. FCM System يعالجها تلقائياً
   ↓
3. ✅ الصوت يُشغَّل تلقائياً (من payload)
   ✅ الاهتزاز يعمل
   ✅ الإشعار يظهر في شريط الإشعارات
   ↓
4. عند الضغط على الإشعار:
   - التطبيق يُفتح
   - onMessageOpenedApp يُستدعى
```

---

## 🧪 **كيفية الاختبار:**

### **1️⃣ من Firebase Console:**

```
1. افتح Firebase Console
2. Cloud Messaging → Send your first message
3. املأ:
   - Notification title: "اختبار الصوت"
   - Notification text: "هل تسمع الصوت؟"
4. Next → Target: Topic → students
5. Additional options:
   ✅ Sound: default
   ✅ Android notification channel: high_importance_channel
6. Review → Publish
```

---

### **2️⃣ من الكود (إضافة واجب):**

```dart
// في صفحة إضافة واجب:
await FirebaseFirestore.instance.collection('homeworks').add({
  'title': 'واجب تجريبي',
  'subjectId': 'subject_id_here',
  'dueDate': Timestamp.now(),
  'createdAt': FieldValue.serverTimestamp(),
});

// Cloud Function ستُطلَق تلقائياً
// الطلاب سيتلقون إشعار بصوت ✅
```

---

### **3️⃣ اختبار الحالات الثلاث:**

#### **أ) التطبيق مفتوح:**
```
1. افتح التطبيق
2. أرسل إشعار
3. ✅ يجب أن تسمع صوت فوراً
4. ✅ إشعار يظهر في الأعلى
```

#### **ب) التطبيق في الخلفية:**
```
1. افتح التطبيق ثم اضغط Home
2. أرسل إشعار
3. ✅ يجب أن تسمع صوت فوراً
4. ✅ إشعار في شريط الإشعارات
```

#### **ج) التطبيق مغلق:**
```
1. أغلق التطبيق تماماً (Swipe من Recent Apps)
2. أرسل إشعار
3. ✅ يجب أن تسمع صوت فوراً
4. ✅ إشعار في شريط الإشعارات
```

---

## 🔧 **استكشاف الأخطاء:**

### **❌ المشكلة: لا يوجد صوت**

#### **الحلول:**

**1. تحقق من صلاحيات Android:**
```xml
<!-- في android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

**2. تحقق من إعدادات الهاتف:**
```
Settings → Apps → [تطبيقك]
→ Notifications → Allow notifications ✅
→ Sound ✅
→ Vibration ✅
```

**3. تحقق من Channel ID:**
```dart
// يجب أن يتطابق في جميع الأماكن:
'high_importance_channel'
```

**4. تحقق من console logs:**
```
📩 إشعار جديد في Foreground:
   العنوان: ...
   المحتوى: ...
```

---

### **❌ المشكلة: الإشعار لا يظهر في Background**

**السبب:** الرسالة يجب أن تحتوي على `notification` payload وليس فقط `data`

**الحل:**
```javascript
// ✅ صحيح
const message = {
  notification: {  // يجب أن يكون موجود!
    title: "...",
    body: "...",
  },
  android: {
    notification: {
      sound: "default",
    },
  },
  tokens,
};

// ❌ خطأ
const message = {
  data: {  // فقط data - لن يظهر في background
    title: "...",
    body: "...",
  },
  tokens,
};
```

---

### **❌ المشكلة: الصوت لا يعمل على بعض الأجهزة**

**الحل:**
```dart
// استخدام صوت مخصص:
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات مهمة',
  importance: Importance.high,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification'), // ملف notification.mp3 في res/raw/
);
```

---

## 📂 **الملفات المعدّلة:**

```
✅ lib/services/notification_service.dart
   - requestPermission() مع sound: true
   - AndroidNotificationChannel مع playSound: true
   - setForegroundNotificationPresentationOptions() مع sound: true
   - AndroidNotificationDetails مع playSound: true

✅ functions/index.js
   - notifyStudentsOnHomework() مع:
     * android.notification.sound: "default"
     * apns.payload.aps.sound: "default"
```

---

## 🎯 **النتيجة النهائية:**

| الحالة | الصوت | الاهتزاز | الظهور |
|--------|-------|----------|--------|
| **التطبيق مفتوح** | ✅ | ✅ | ✅ في شريط الإشعارات |
| **في الخلفية** | ✅ | ✅ | ✅ في شريط الإشعارات |
| **مغلق تماماً** | ✅ | ✅ | ✅ في شريط الإشعارات |

---

## 📞 **ملاحظات إضافية:**

### **1. أصوات مخصصة:**
```
ضع ملف صوت في:
android/app/src/main/res/raw/notification.mp3

ثم استخدم:
sound: RawResourceAndroidNotificationSound('notification')
```

### **2. Badge على الأيقونة:**
```dart
// يتم تلقائياً على Android 8+
// يحتاج إعدادات إضافية لـ iOS
```

### **3. تجميع الإشعارات:**
```dart
AndroidNotificationDetails(
  'high_importance_channel',
  'إشعارات مهمة',
  groupKey: 'homework_notifications',  // تجميع حسب نوع
)
```

---

**تاريخ التحديث:** 2025-10-28  
**الإصدار:** 2.0.0  
**الحالة:** ✅ جاهز للاستخدام
