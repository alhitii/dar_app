# 🔧 إصلاح أسماء Topics - الأحرف العربية

## 📅 **التاريخ:** 3 نوفمبر 2025

---

## ⚠️ **المشكلة المكتشفة:**

```
❌ g-الخامس-s-أ
Firebase لا يقبل أحرف عربية في أسماء Topics!

الخطأ:
Invalid topic name: g-الخامس-s-أ does not match 
the allowed format [a-zA-Z0-9-_.~%]{1,900}
```

---

## ✅ **الحل:**

### **تحويل الأحرف العربية إلى URL encoding:**

```dart
// ❌ القديم
final topic = 'g-$grade-s-$section';
// النتيجة: g-الخامس-s-أ (غير صالح)

// ✅ الجديد
final gradeEncoded = Uri.encodeComponent(grade);
final sectionEncoded = Uri.encodeComponent(section);
final topic = 'g_${gradeEncoded}_s_$sectionEncoded';
// النتيجة: g_%D8%A7%D9%84%D8%AE%D8%A7%D9%85%D8%B3_s_%D8%A3 (صالح)
```

---

## 🔧 **التغييرات:**

### **1. notification_service.dart:**
```dart
if (grade.isNotEmpty && section.isNotEmpty) {
  // ✅ تحويل الأحرف العربية إلى ASCII
  final gradeEncoded = Uri.encodeComponent(grade);
  final sectionEncoded = Uri.encodeComponent(section);
  final topic = 'g_${gradeEncoded}_s_$sectionEncoded';
  
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  print('✅ اشتراك في: $topic (الصف: $grade، الشعبة: $section)');
}

final uid = (data['uid'] ?? '').toString();
if (uid.isNotEmpty) {
  await FirebaseMessaging.instance.subscribeToTopic('student_$uid');
  print('✅ اشتراك في: student_$uid');
}
```

### **2. functions/index.js:**
```javascript
// notifyStudentsOnHomework
for (const section of sections) {
  const gradeEncoded = encodeURIComponent(grade);
  const sectionEncoded = encodeURIComponent(section);
  const topic = `g_${gradeEncoded}_s_${sectionEncoded}`;
  
  await messaging.send({topic});
}

// notifyOnAbsence & testAbsenceNotification
const topic = `student_${targetUid}`;
```

---

## 📊 **أسماء Topics الجديدة:**

### **قبل:**
```
❌ g-الخامس-s-أ
❌ student-xrox5eKTNBZP0z2kSIerZoEFjGB2
```

### **بعد:**
```
✅ g_%D8%A7%D9%84%D8%AE%D8%A7%D9%85%D8%B3_s_%D8%A3
✅ student_xrox5eKTNBZP0z2kSIerZoEFjGB2
```

---

## 📱 **APK الجديد:**

```
📂 build\app\outputs\flutter-apk\app-release.apk
📊 54.8 MB
✅ Topics بأسماء صالحة
✅ Functions محدثة
```

---

## 🧪 **الاختبار:**

### **1. التثبيت:**
```
⚠️ احذف التطبيق القديم
⚠️ أعد تشغيل الهاتف
✅ ثبّت app-release.apk
```

### **2. تسجيل الدخول:**
```
1. سجل دخول كطالب
2. راقب Console logs:
   ✅ "✅ اشتراك في: students"
   ✅ "✅ اشتراك في: g_%D8%A7%D9%84%D8%AE%D8%A7%D9%85%D8%B3_s_%D8%A3 (الصف: الخامس، الشعبة: أ)"
   ✅ "✅ اشتراك في: student_xrox5eKTNBZP0z2kSIerZoEFjGB2"
   ✅ "✅ تم الاشتراك في Topics بنجاح"
   ❌ لا يوجد خطأ "Invalid topic name"
```

### **3. اختبار الإشعار:**
```
1. اضغط على زر "🧪 اختبار"
2. ✅ يجب أن يصل الإشعار مع صوت واهتزاز
```

---

## 🎯 **النتيجة المتوقعة:**

```
✅ لا أخطاء في الاشتراك
✅ Topics صالحة
✅ الإشعارات تصل
✅ الصوت والاهتزاز يعملان
```

---

**APK جاهز! احذف التطبيق القديم، أعد تشغيل الهاتف، ثم ثبّت الجديد! 🚀**
