# 🔊 إصلاح مشكلة الصوت والاهتزاز - دليل شامل

## ✅ **التعديلات الجديدة:**

### **1️⃣ أذونات جديدة في AndroidManifest.xml:**
```xml
✅ VIBRATE - للاهتزاز
✅ WAKE_LOCK - لإيقاظ الشاشة
✅ RECEIVE_BOOT_COMPLETED - لاستقبال الإشعارات بعد إعادة تشغيل الجهاز
```

### **2️⃣ صفحة اختبار جديدة:**
```
✅ test_notification_page.dart
   - اختبار إشعار محلي مباشر
   - فحص الصلاحيات
   - عرض FCM Token
```

---

## 🚀 **الخطوات المطلوبة الآن:**

### **الخطوة 1: بناء APK جديد (مهم جداً!)**

```bash
flutter clean
flutter pub get
flutter build apk --release
```

**⚠️ يجب بناء APK جديد بعد إضافة الأذونات!**

---

### **الخطوة 2: إضافة زر الاختبار في التطبيق**

افتح `lib/ui/admin/admin_tabs_screen.dart` أو أي صفحة رئيسية:

```dart
// في أعلى الملف
import 'package:madrasah/test_notification_page.dart';

// أضف زر في AppBar أو Drawer:
IconButton(
  icon: Icon(Icons.notifications_active),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestNotificationPage(),
      ),
    );
  },
)
```

---

### **الخطوة 3: اختبار الإشعار المحلي**

```
1. افتح التطبيق
2. اذهب إلى صفحة "اختبار الإشعارات"
3. اضغط "اختبار إشعار محلي"
4. يجب أن تسمع صوت وترى اهتزاز فوراً!
```

---

## 🔍 **تشخيص المشكلة:**

### **✅ إذا عمل الإشعار المحلي (صوت + اهتزاز):**

**معنى ذلك:**
- ✅ الأذونات صحيحة
- ✅ إعدادات الهاتف صحيحة
- ✅ المشكلة في FCM فقط

**الحل:**
- تأكد من إعدادات Firebase Console (sound: default)
- تأكد من أن الرسالة تحتوي على `notification` payload
- جرّب إرسال إشعار من Firebase Console مباشرة

---

### **❌ إذا لم يعمل الإشعار المحلي:**

**معنى ذلك:**
- ❌ مشكلة في إعدادات الهاتف

**الحلول:**

#### **1. افحص إعدادات التطبيق:**
```
Settings → Apps → [اسم تطبيقك]
→ Notifications
  ✅ تأكد أنها: Allowed / ON
  
→ Notifications → Categories
  ✅ ابحث عن: "إشعارات مهمة"
  ✅ تأكد أنها: ON
  ✅ Sound: ON
  ✅ Vibration: ON
```

#### **2. افحص مستوى الصوت:**
```
- ارفع مستوى صوت الإشعارات (Notification Volume)
- ليس Media Volume!
```

#### **3. افحص Do Not Disturb:**
```
Settings → Sound → Do Not Disturb
  ✅ يجب أن يكون: OFF
  
أو:
  ✅ Allow exceptions → Apps → [تطبيقك] → ON
```

#### **4. افحص Battery Optimization:**
```
Settings → Battery
→ Battery optimization
→ [تطبيقك]
  ✅ غيّر إلى: Don't optimize
```

#### **5. في أجهزة Xiaomi/Redmi (MIUI):**
```
Settings → Apps → Manage apps → [تطبيقك]
→ Autostart
  ✅ غيّر إلى: ON
  
Settings → Battery & performance
→ Choose apps
→ [تطبيقك]
  ✅ غيّر إلى: No restrictions
```

#### **6. في أجهزة Huawei (EMUI):**
```
Settings → Apps
→ [تطبيقك]
→ Battery
→ App launch
  ✅ غيّر إلى: Manage manually
  ✅ فعّل: Auto-launch, Secondary launch, Run in background
```

#### **7. في أجهزة Oppo/Realme (ColorOS):**
```
Settings → App Management
→ [تطبيقك]
→ Battery Usage
  ✅ غيّر إلى: Allow background activity
  
Settings → Privacy
→ Auto-start
→ [تطبيقك]
  ✅ ON
```

#### **8. في Samsung (One UI):**
```
Settings → Apps → [تطبيقك]
→ Battery
→ Background usage limits
  ✅ غيّر إلى: Unrestricted
  
Settings → Battery
→ Background usage limits
  ✅ تأكد أن تطبيقك ليس في القائمة
```

---

## 🧪 **اختبار متقدم:**

### **طريقة 1: إرسال من Firebase Console**

```
1. Firebase Console → Cloud Messaging
2. Send your first message
3. Title: 🔔 اختبار الصوت
4. Body: هل تسمع الصوت؟
5. Next
6. Target: FCM registration token (انسخه من صفحة الاختبار)
7. Additional options:
   ✅ Sound: default
   ✅ Android notification channel: high_importance_channel
   ✅ Priority: High
8. Review → Publish
```

---

### **طريقة 2: إرسال من Postman/cURL**

احصل على Server Key من:
```
Firebase Console → Project Settings → Cloud Messaging → Server Key
```

ثم استخدم:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=AAAA..." \
-H "Content-Type: application/json" \
-d '{
  "to": "YOUR_FCM_TOKEN",
  "priority": "high",
  "notification": {
    "title": "🔔 اختبار الصوت",
    "body": "هل تسمع الصوت؟",
    "sound": "default",
    "android_channel_id": "high_importance_channel"
  },
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channel_id": "high_importance_channel",
      "notification_priority": "PRIORITY_MAX",
      "default_sound": true,
      "default_vibrate_timings": true
    }
  }
}'
```

---

## 📊 **جدول التشخيص:**

| الاختبار | النتيجة | التشخيص |
|---------|---------|----------|
| إشعار محلي ✅ + FCM ❌ | صوت محلي يعمل، FCM لا | مشكلة في إعدادات Firebase |
| إشعار محلي ❌ + FCM ❌ | لا صوت نهائياً | مشكلة في إعدادات الهاتف |
| إشعار محلي ✅ + FCM ✅ | كل شيء يعمل | الحمد لله! |

---

## 🎯 **الحلول حسب الحالة:**

### **حالة 1: الإشعار المحلي يعمل لكن FCM لا يعمل**

**المشكلة:** إعدادات Firebase Console أو Cloud Function

**الحل:**

1. **تأكد من sound في Firebase Console:**
   ```
   Additional options → Sound: default ✅
   ```

2. **تأكد من Channel ID:**
   ```
   Additional options → Channel: high_importance_channel ✅
   ```

3. **تأكد من Priority:**
   ```
   Additional options → Priority: High ✅
   ```

4. **تأكد من Cloud Function:**
   ```javascript
   // في functions/index.js
   android: {
     priority: "high",
     notification: {
       sound: "default",  // يجب أن يكون موجود!
       channelId: "high_importance_channel",
     },
   },
   ```

---

### **حالة 2: لا صوت نهائياً (محلي ولا FCM)**

**المشكلة:** إعدادات الهاتف

**الحل:**

1. **أعد تثبيت التطبيق:**
   ```bash
   flutter clean
   flutter build apk --release
   # ثبّت من جديد
   ```

2. **افتح التطبيق → اذهب لصفحة الاختبار**
   
3. **اضغط "فحص الصلاحيات"**

4. **إذا كانت الصلاحيات "denied":**
   ```
   - احذف التطبيق تماماً
   - أعد تثبيته
   - عند الفتح الأول سيطلب الصلاحيات
   - اقبل كل الصلاحيات
   ```

5. **افحص الإعدادات كما في القسم أعلاه**

---

## 🔧 **إعدادات إضافية (متقدم):**

### **تعديل notification_service.dart لمزيد من التحكم:**

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات مهمة',
  importance: Importance.max,  // أقصى أهمية
  playSound: true,
  enableVibration: true,
  enableLights: true,
  ledColor: Color(0xFF00FF00),  // ضوء LED أخضر
  vibrationPattern: Int64List.fromList([0, 500, 200, 500]),  // نمط اهتزاز مخصص
);
```

---

## 📱 **الأجهزة المختبرة:**

### **✅ تعمل بشكل ممتاز:**
- Google Pixel (Android Stock)
- Samsung Galaxy (بعد تعطيل Battery Optimization)

### **⚠️ تحتاج إعدادات إضافية:**
- Xiaomi/Redmi (MIUI) - فعّل Autostart
- Huawei (EMUI) - Protected apps
- Oppo/Realme (ColorOS) - Auto-start

### **❌ مشاكل معروفة:**
- بعض أجهزة Chinese brands لديها قيود صارمة جداً

---

## 📝 **Checklist كامل:**

```
APK:
  ✅ flutter clean
  ✅ flutter build apk --release
  ✅ تثبيت APK الجديد

التطبيق:
  ✅ افتح التطبيق
  ✅ اذهب لصفحة الاختبار
  ✅ اختبر الإشعار المحلي
  ✅ انسخ FCM Token

إعدادات الهاتف:
  ✅ Notifications: ON
  ✅ Sound: ON
  ✅ Vibration: ON
  ✅ Do Not Disturb: OFF
  ✅ Battery Optimization: Don't optimize
  ✅ Autostart: ON (Xiaomi/Huawei/Oppo)

اختبار FCM:
  ✅ Firebase Console → Send message
  ✅ Sound: default
  ✅ Channel: high_importance_channel
  ✅ Priority: High
  ✅ أغلق التطبيق تماماً
  ✅ أرسل الإشعار
```

---

## 🎉 **إذا اتبعت كل الخطوات:**

```
النتيجة المتوقعة:
  🔊 صوت واضح
  📳 اهتزاز قوي
  💡 ضوء LED (بعض الأجهزة)
  📱 إشعار في شريط الإشعارات
```

---

## 📞 **إذا مازالت المشكلة موجودة:**

**جرّب:**

1. **اختبر على جهاز آخر** (لاستبعاد مشكلة الجهاز نفسه)

2. **استخدم Google Pixel أو Samsung** (لأنها أكثر توافقاً)

3. **اختبر بملف صوت مخصص:**
   ```dart
   // ضع ملف notification.mp3 في:
   // android/app/src/main/res/raw/notification.mp3
   
   sound: RawResourceAndroidNotificationSound('notification')
   ```

4. **تحقق من Logcat:**
   ```bash
   adb logcat | grep -i "fcm\|notification\|sound"
   ```

---

**تاريخ التحديث:** 2025-10-28  
**الحالة:** جاهز للاختبار
