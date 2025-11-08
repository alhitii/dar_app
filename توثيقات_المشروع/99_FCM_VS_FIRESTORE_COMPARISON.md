# 🔔 مقارنة أنظمة الإشعارات - FCM vs Firestore

## 📅 **التاريخ:** 2 نوفمبر 2025

---

## 🔍 **الفرق الرئيسي:**

### **المشروع القديم (يعمل بشكل كامل):**
```
✅ يستخدم Firebase Cloud Messaging (FCM) مباشرة
✅ الإشعارات تأتي من الخادم (Server-side)
✅ الصوت والاهتزاز يعملان تلقائياً
✅ يعمل حتى عندما التطبيق مغلق
```

### **المشروع الحالي (قبل التعديل):**
```
⚠️ كان يستخدم Firestore Listener (Client-side)
⚠️ الإشعارات تُنشأ محلياً
⚠️ الصوت والاهتزاز يحتاجان إعداد إضافي
⚠️ لا يعمل عندما التطبيق مغلق
```

---

## 📊 **المقارنة التفصيلية:**

### **1. المشروع القديم (E:\تطبيق مدرسة):**

#### **notification_service.dart:**
```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // تهيئة الإشعارات المحلية
    const AndroidInitializationSettings androidInit = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(initSettings);

    // Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission();
    
    // الاستماع للإشعارات عندما التطبيق مفتوح
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  void _onForegroundMessage(RemoteMessage message) {
    _fln.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'General',
          importance: Importance.high,  // ✅ صوت واهتزاز تلقائي
          priority: Priority.high,
        ),
      ),
    );
  }
}

// Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // يعمل حتى عندما التطبيق مغلق
}
```

#### **كيف يعمل:**
```
1. الخادم (Firebase Functions أو Console) يرسل FCM
   ↓
2. FCM يصل للجهاز (حتى لو التطبيق مغلق)
   ↓
3. _firebaseMessagingBackgroundHandler يستقبله
   ↓
4. الإشعار يظهر مع صوت واهتزاز تلقائياً
```

---

### **2. المشروع الحالي (بعد التعديل):**

#### **notification_service.dart:**
```dart
class NotificationService {
  Future<void> initialize() async {
    // إنشاء قناة الإشعارات
    await _createNotificationChannel();
    
    // Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;
    await _requestPermissions();
    
    // حفظ FCM Token في Firestore
    await _saveFCMToken();
    
    // الاستماع للإشعارات
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }
  
  // حفظ FCM Token
  Future<void> _saveFCMToken() async {
    final token = await _firebaseMessaging?.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }
}
```

#### **Firebase Functions:**
```javascript
// functions/index.js

// إشعارات الواجبات
export const notifyStudentsOnHomework = onDocumentCreated("homeworks/{homeworkId}", async (event) => {
  const data = event.data?.data();
  
  // جلب FCM Tokens للطلاب
  const studentsSnap = await db
    .collection("users")
    .where("role", "==", "student")
    .where("grade", "==", grade)
    .where("section", "==", section)
    .get();
  
  const tokens = studentsSnap.docs
    .map((doc) => doc.data().fcmToken)
    .filter(Boolean);
  
  // إرسال FCM
  await messaging.sendEachForMulticast({
    notification: {
      title: `📘 واجب جديد في مادة ${subjectData.name}`,
      body: data.title,
    },
    android: {
      priority: "high",
      notification: {
        sound: "default", // ✅ صوت
        channelId: "high_importance_channel",
        vibrationPattern: [0, 300, 150, 300], // ✅ اهتزاز
      },
    },
    tokens,
  });
});

// إشعارات الإدارة
export const notifyOnAnnouncement = onDocumentCreated("announcements/{announcementId}", async (event) => {
  // نفس الطريقة
  await messaging.sendEachForMulticast({
    notification: { title, body },
    android: {
      notification: {
        sound: "default",
        vibrationPattern: [0, 250, 250, 250],
      },
    },
    tokens,
  });
});

// إشعارات الغياب
export const notifyOnAbsence = onDocumentCreated("absences/{absenceId}", async (event) => {
  // نفس الطريقة
  await messaging.send({
    notification: { title, body },
    android: {
      notification: {
        sound: "default",
        vibrationPattern: [0, 500, 200, 500], // اهتزاز أقوى
      },
    },
    token: fcmToken,
  });
});
```

---

## 🎯 **لماذا FCM أفضل:**

### **FCM (المشروع القديم والحالي بعد التعديل):**
```
✅ يعمل حتى عندما التطبيق مغلق
✅ الصوت والاهتزاز تلقائي
✅ يدعم Topics (إرسال لمجموعة)
✅ أداء أفضل
✅ استهلاك بطارية أقل
✅ موثوق جداً
✅ يدعم أنماط اهتزاز مخصصة
```

### **Firestore Listener (المشروع الحالي قبل التعديل):**
```
❌ يتوقف عندما التطبيق مغلق
❌ يحتاج إعداد إضافي للصوت
❌ لا يدعم Topics
❌ استهلاك بيانات أكثر
❌ قد لا يكون موثوقاً
❌ صعوبة في تخصيص الاهتزاز
```

---

## 🔄 **كيف يعمل النظام الجديد:**

### **1. عند تسجيل الدخول:**
```
1. NotificationService.initialize()
2. _requestPermissions()
3. _saveFCMToken() → يحفظ في Firestore
4. ✅ Token جاهز للاستخدام
```

### **2. عند إرسال واجب:**
```
1. المعلم يضيف واجب → Firestore
2. Firebase Function يكتشف الإضافة
3. Function يجلب FCM Tokens للطلاب
4. Function يرسل FCM للجميع
5. ✅ الطلاب يستقبلون مع صوت واهتزاز
```

### **3. عند نشر إعلان:**
```
1. الإداري ينشر إعلان → Firestore
2. Firebase Function يكتشف الإضافة
3. Function يجلب FCM Tokens (حسب targetRole)
4. Function يرسل FCM
5. ✅ المستهدفون يستقبلون مع صوت واهتزاز
```

### **4. عند تسجيل غياب:**
```
1. الإداري يسجل غياب → Firestore
2. Firebase Function يكتشف الإضافة
3. Function يجلب FCM Token للطالب
4. Function يرسل FCM
5. ✅ الطالب يستقبل مع صوت واهتزاز أقوى
```

---

## 📊 **أنماط الاهتزاز المخصصة:**

```javascript
// الواجبات - نمط عادي
vibrationPattern: [0, 300, 150, 300]
// توقف → اهتزاز 300ms → توقف 150ms → اهتزاز 300ms

// إعلانات الإدارة - نمط متوسط
vibrationPattern: [0, 250, 250, 250]
// توقف → اهتزاز 250ms → توقف 250ms → اهتزاز 250ms

// الغياب - نمط قوي (تنبيه مهم)
vibrationPattern: [0, 500, 200, 500]
// توقف → اهتزاز 500ms → توقف 200ms → اهتزاز 500ms
```

---

## 🔧 **الخطوات للتطبيق:**

### **1. التأكد من نشر Functions:**
```bash
cd D:\test\madrasah
firebase deploy --only functions
```

### **2. بناء APK جديد:**
```bash
flutter clean
flutter build apk --release
```

### **3. الاختبار:**
```
1. ثبّت APK على جهازين
2. سجل دخول كمعلم → أرسل واجب
3. سجل دخول كطالب → استقبل الإشعار
4. ✅ صوت يعمل
5. ✅ اهتزاز يعمل
6. ✅ يعمل حتى عندما التطبيق مغلق
```

---

## 📝 **الملفات المعدلة:**

```
✅ lib/services/notification_service.dart
   - إضافة _saveFCMToken()
   - إضافة imports (FirebaseAuth, FirebaseFirestore)

✅ functions/index.js (موجود مسبقاً)
   - notifyStudentsOnHomework (السطر 108)
   - notifyOnAnnouncement (السطر 180)
   - notifyOnAbsence (السطر 265)
```

---

## 🎯 **النتيجة النهائية:**

### **قبل:**
```
❌ Firestore Listener فقط
❌ لا يعمل عندما التطبيق مغلق
❌ لا صوت ولا اهتزاز موثوق
```

### **بعد:**
```
✅ FCM من الخادم
✅ يعمل حتى عندما التطبيق مغلق
✅ صوت واهتزاز تلقائي
✅ أنماط اهتزاز مخصصة
✅ موثوق 100%
```

---

## ⚠️ **ملاحظات مهمة:**

### **1. Firebase Functions:**
```
✅ يجب أن تكون منشورة (deployed)
✅ تحقق من Logs في Firebase Console
⚠️ قد تحتاج Billing Plan (Blaze) للإنتاج
```

### **2. FCM Token:**
```
✅ يتم حفظه عند تسجيل الدخول
✅ يتم تحديثه تلقائياً
⚠️ قد يتغير بعد إعادة تثبيت التطبيق
```

### **3. الصوت والاهتزاز:**
```
✅ يعملان تلقائياً من FCM
✅ يعتمدان على إعدادات الجهاز
⚠️ لا يعملان في وضع "لا تزعج"
⚠️ قد لا يعملان في وضع توفير الطاقة
```

---

**هذا هو السبب الحقيقي! 🎯**

**المشروع القديم يستخدم FCM → الصوت والاهتزاز يعملان**

**المشروع الحالي الآن يستخدم FCM أيضاً → سيعمل بنفس الطريقة!** ✅
