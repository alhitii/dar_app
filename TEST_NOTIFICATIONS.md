# 🔔 دليل اختبار الإشعارات - التطبيق المغلق

## ✅ **التعديلات المطبقة:**

### **1️⃣ AndroidManifest.xml (الآن!):**
```xml
✅ FCM Default Channel: high_importance_channel
✅ FCM Default Icon: ic_launcher
✅ FCM Default Color: white
✅ FCM Service: مسجل بشكل صحيح
```

### **2️⃣ Cloud Function:**
```javascript
✅ notification payload موجود
✅ sound: "default"
✅ channelId: "high_importance_channel"
✅ priority: "high"
```

### **3️⃣ notification_service.dart:**
```dart
✅ Channel مع playSound: true
✅ requestPermission مع sound: true
✅ setForegroundNotificationPresentationOptions
```

---

## 🚀 **الخطوات الآن:**

### **الخطوة 1: بناء التطبيق مجدداً**

```bash
flutter clean
flutter build apk --release
```

**مهم:** يجب بناء APK جديد بعد تعديل AndroidManifest.xml!

---

### **الخطوة 2: تثبيت على الهاتف**

```bash
# ثبّت الـ APK على هاتف Android حقيقي
# (ليس محاكي!)
```

---

### **الخطوة 3: الحصول على FCM Token**

**افتح التطبيق مرة واحدة وانظر في Terminal/Logcat:**

```
FCM Token: dA7xB...xyz123
```

**انسخ هذا Token!** 📋

---

### **الخطوة 4: اختبار من Firebase Console**

#### **أ) افتح Firebase Console:**
```
https://console.firebase.google.com/project/madrasa-570c9/messaging
```

#### **ب) اضغط "Send your first message"**

#### **ج) املأ النموذج:**

```
1. Notification title (required):
   اختبار الصوت 🔔

2. Notification text (required):
   هل تسمع الصوت؟ هذا إشعار اختبار

3. Notification image (optional):
   [اتركه فارغاً]
```

اضغط **Next**

#### **د) Target (الهدف):**

**خيار 1: باستخدام Token (مباشر!):**
```
1. اختر: "FCM registration token"
2. الصق الـ Token الذي نسخته
3. اضغط "Test" أو "Next"
```

**خيار 2: باستخدام Topic:**
```
1. اختر: "Topic"
2. اكتب: students
3. Next
```

#### **هـ) Additional options:**

```
✅ اضغط "Additional options"

Android notification options:
  ✅ Sound: default
  ✅ Notification channel: high_importance_channel
  ⚠️ Priority: High
```

#### **و) Schedule:**
```
اختر: "Now"
```

#### **ز) Conversion events:**
```
[اتركه فارغاً]
```

اضغط **Review** ثم **Publish**

---

### **الخطوة 5: اختبار الحالات الثلاث**

#### **🟢 حالة 1: التطبيق مفتوح (Foreground)**

```
1. افتح التطبيق
2. أرسل الإشعار من Firebase Console
3. النتيجة المتوقعة:
   ✅ صوت فوراً
   ✅ إشعار يظهر في الأعلى
   ✅ في Terminal:
      📩 إشعار جديد في Foreground:
         العنوان: اختبار الصوت 🔔
```

#### **🟡 حالة 2: التطبيق في الخلفية (Background)**

```
1. افتح التطبيق ثم اضغط Home (يبقى في الخلفية)
2. أرسل الإشعار
3. النتيجة المتوقعة:
   ✅ صوت فوراً 🔊
   ✅ إشعار في شريط الإشعارات
   ✅ اهتزاز
```

#### **🔴 حالة 3: التطبيق مغلق (Terminated) ⭐ الأهم**

```
1. أغلق التطبيق تماماً:
   - Recent Apps → Swipe up
   - أو Settings → Force Stop
   
2. انتظر 5 ثوانٍ

3. أرسل الإشعار من Firebase Console

4. النتيجة المتوقعة:
   ✅ صوت فوراً 🔊🔊🔊
   ✅ إشعار في شريط الإشعارات
   ✅ اهتزاز
   ✅ بدون فتح التطبيق!
```

---

## 🔍 **إذا لم يصل الصوت (التطبيق مغلق):**

### **✅ تحقق من:**

#### **1. الصلاحيات على الهاتف:**
```
Settings → Apps → [تطبيقك]
→ Notifications
  ✅ Allow notifications: ON
  ✅ Sound: ON
  ✅ Vibration: ON
  ✅ On lock screen: Show
```

#### **2. إعدادات Do Not Disturb:**
```
Settings → Sound → Do Not Disturb
  ✅ OFF (أو السماح للتطبيق)
```

#### **3. Battery Optimization:**
```
Settings → Battery → Battery optimization
→ [تطبيقك] → Don't optimize ✅
```

#### **4. AutoStart (في Xiaomi/Huawei/Oppo):**
```
Settings → Apps → Autostart
→ [تطبيقك] → ON ✅
```

#### **5. Background restrictions:**
```
Settings → Apps → [تطبيقك]
→ Battery → Background restriction: Unrestricted ✅
```

---

## 📊 **استكشاف الأخطاء:**

### **المشكلة: لا يصل الإشعار نهائياً**

**الحلول:**

**1. تحقق من FCM Token:**
```dart
// في main.dart أو أي مكان
final token = await FirebaseMessaging.instance.getToken();
print('🔑 FCM Token: $token');
```

**2. تحقق من Firebase Console Logs:**
```
Firebase Console → Cloud Messaging → Reports
- انظر إلى Sent vs Delivered
```

**3. اختبر بـ Topic بدلاً من Token:**
```
في التطبيق:
await FirebaseMessaging.instance.subscribeToTopic('test');

في Firebase Console:
Target → Topic → test
```

---

### **المشكلة: يصل الإشعار بدون صوت**

**الحلول:**

**1. تحقق من Channel ID:**
```
في Firebase Console:
Additional options → Channel: high_importance_channel
```

**2. تحقق من Sound:**
```
في Firebase Console:
Additional options → Sound: default
```

**3. تحقق من Priority:**
```
في Firebase Console:
Additional options → Priority: High
```

**4. اختبر صوت الهاتف:**
```
- ارفع مستوى الصوت
- جرّب notification sound من الإعدادات
- تأكد أن الهاتف ليس في Silent mode
```

---

### **المشكلة: يعمل في Foreground فقط**

**السبب:** AndroidManifest.xml لم يتم تحديثه بشكل صحيح

**الحل:**
```bash
1. تأكد من حفظ AndroidManifest.xml
2. flutter clean
3. flutter build apk --release
4. ثبّت APK الجديد
```

---

## 🧪 **طريقة اختبار سريعة:**

### **باستخدام cURL (متقدم):**

```bash
# احصل على Server Key من:
# Firebase Console → Project Settings → Cloud Messaging → Server Key

curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "YOUR_FCM_TOKEN",
  "notification": {
    "title": "اختبار الصوت",
    "body": "هل تسمع الصوت؟",
    "sound": "default"
  },
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channel_id": "high_importance_channel"
    }
  }
}'
```

---

## 📱 **الأجهزة الموصى بها للاختبار:**

### **✅ جيدة:**
- Google Pixel (Android Stock)
- Samsung Galaxy (One UI)
- OnePlus (OxygenOS)

### **⚠️ تحتاج إعدادات إضافية:**
- Xiaomi (MIUI) - فعّل Autostart
- Huawei (EMUI) - فعّل Protected apps
- Oppo/Realme (ColorOS) - فعّل Autostart

### **❌ تجنب:**
- المحاكيات (Emulators) - لا تدعم FCM بشكل كامل
- أجهزة قديمة (Android < 5.0)

---

## 🎯 **الخلاصة:**

| الخطوة | الحالة |
|--------|--------|
| ✅ AndroidManifest.xml | محدّث |
| ✅ Cloud Function | جاهز |
| ✅ notification_service.dart | جاهز |
| 🏗️ بناء APK جديد | **افعل الآن!** |
| 🧪 اختبار من Firebase Console | **جرّب!** |

---

## 🚀 **ابدأ الآن:**

```bash
# 1. بناء
flutter clean
flutter build apk --release

# 2. تثبيت على هاتف حقيقي

# 3. افتح التطبيق → انسخ FCM Token

# 4. أغلق التطبيق تماماً

# 5. أرسل إشعار من Firebase Console

# 6. يجب أن تسمع الصوت! 🔊
```

---

**ملاحظة مهمة:**
- ✅ يجب بناء APK **جديد** بعد تعديل AndroidManifest.xml
- ✅ اختبر على هاتف **Android حقيقي** (ليس محاكي)
- ✅ تأكد من **إعدادات البطارية والصلاحيات**

**إذا اتبعت الخطوات بالضبط، سيعمل الصوت 100%!** 🎉
