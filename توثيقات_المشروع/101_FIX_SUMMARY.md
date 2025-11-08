# 🔧 ملخص الإصلاحات المطلوبة

## 📅 **التاريخ:** 2 نوفمبر 2025

---

## ⚠️ **المشاكل المكتشفة:**

### **1. الصوت والاهتزاز لا يعملان ❌**
```
السبب: Function تستمع لـ "homeworks" لكن الكود يكتب في "homework"
الحل: ✅ تم تغيير Function من "homeworks" إلى "homework"
```

### **2. شارة "واجب جديد" لا تظهر فوراً ❌**
```
السبب: _loadActiveHomeworks() تُحمّل مرة واحدة فقط
الحل: ✅ تم تحويلها إلى listener (snapshots) للتحديث الفوري
```

### **3. بعض المواد بدون اسم معلم ❌**
```
السبب: بعض المواد في subjects لا تحتوي على teacherName
الحل: ✅ تم تبسيط _loadTeacherNames() لجلب من subjects مباشرة
الحل الإضافي: يجب تشغيل syncTeacherSubjects Function
```

---

## ✅ **ما تم إصلاحه:**

### **1. functions/index.js:**
```javascript
// قبل:
export const notifyStudentsOnHomework = onDocumentCreated("homeworks/{homeworkId}", ...)

// بعد:
export const notifyStudentsOnHomework = onDocumentCreated("homework/{homeworkId}", ...)
```

### **2. lib/ui/student/student_home_complete.dart:**
```dart
// قبل:
Future<void> _loadActiveHomeworks() async {
  final homeworksSnapshot = await FirebaseFirestore.instance
      .collection('homework')
      .get(); // ❌ مرة واحدة فقط
}

// بعد:
Future<void> _loadActiveHomeworks() async {
  FirebaseFirestore.instance
      .collection('homework')
      .snapshots() // ✅ listener مستمر
      .listen((snapshot) {
        // تحديث فوري
      });
}
```

### **3. lib/ui/student/student_home_complete.dart:**
```dart
// قبل:
Future<void> _loadTeacherNames() async {
  // جلب من teachers → subjects (معقد)
  final teachersSnapshot = await FirebaseFirestore.instance
      .collection('teachers')
      .get();
  // ثم loop على subjects...
}

// بعد:
Future<void> _loadTeacherNames() async {
  // جلب من subjects مباشرة (بسيط)
  final subjectsSnapshot = await FirebaseFirestore.instance
      .collection('subjects')
      .get();
  
  for (var doc in subjectsSnapshot.docs) {
    final teacherName = doc.data()['teacherName'];
    // استخدام teacherName مباشرة
  }
}
```

### **4. lib/services/notification_service.dart:**
```dart
// تم إضافة:
- حفظ FCM Token في Firestore
- _saveFCMToken() method
- imports: FirebaseAuth, FirebaseFirestore
```

---

## 🚀 **الخطوات التالية:**

### **1. نشر Functions المحدثة:**
```bash
cd D:\test\madrasah
firebase deploy --only functions:notifyStudentsOnHomework
```

### **2. إصلاح أسماء المعلمين في Firestore:**

يمكن استخدام إحدى الطرق التالية:

#### **الطريقة 1: من Firebase Console (يدوياً)**
```
1. افتح Firebase Console
2. اذهب إلى Firestore Database
3. افتح collection "subjects"
4. لكل مادة بدون teacherName:
   - انسخ teacherId
   - ابحث عن المعلم في users
   - أضف teacherName يدوياً
```

#### **الطريقة 2: تشغيل Function موجودة**
```
Function "syncTeacherSubjects" موجودة بالفعل
تعمل تلقائياً عند تحديث معلم

لإعادة تشغيلها:
1. افتح Firebase Console → Firestore
2. افتح collection "users"
3. اختر أي معلم
4. عدّل أي field (مثل أضف مسافة في name)
5. احفظ
6. Function ستعمل تلقائياً وتحدث جميع مواده
```

#### **الطريقة 3: من Admin Panel**
```
1. سجل دخول كـ Admin
2. اذهب إلى قائمة المعلمين
3. اضغط "تعديل" على كل معلم
4. احفظ (بدون تغيير)
5. Function ستحدث مواده تلقائياً
```

### **3. بناء APK جديد:**
```bash
flutter clean
flutter build apk --release
```

### **4. الاختبار:**
```
1. ثبّت APK على جهازين
2. سجل دخول كمعلم → أرسل واجب
3. سجل دخول كطالب:
   ✅ الإشعار يصل فوراً
   ✅ الصوت يعمل
   ✅ الاهتزاز يعمل
   ✅ الشارة الحمراء تظهر فوراً
   ✅ اسم المعلم يظهر تحت كل مادة
```

---

## 📊 **التحقق من النتائج:**

### **1. التحقق من FCM Token:**
```
Firestore → users → {studentUid}
يجب أن يحتوي على: fcmToken: "..."
```

### **2. التحقق من teacherName:**
```
Firestore → subjects → {subjectId}
يجب أن يحتوي على:
- teacherId: "..."
- teacherName: "اسم المعلم"
```

### **3. التحقق من Function:**
```bash
firebase functions:log --only notifyStudentsOnHomework
```

---

## 🎯 **النتيجة المتوقعة:**

```
✅ عند إرسال واجب:
   - Function تكتشف الإضافة في "homework"
   - Function ترسل FCM للطلاب
   - الطلاب يستقبلون مع صوت واهتزاز
   - الشارة الحمراء تظهر فوراً

✅ في قائمة المواد:
   - كل مادة تعرض اسم المعلم
   - "أ : [اسم المعلم]"
   - لا يوجد "غير محدد"

✅ الشارة الحمراء:
   - تظهر فوراً عند إضافة واجب
   - تختفي عند فتح التبويب
   - تعمل بدون إعادة تشغيل
```

---

## ⚠️ **ملاحظات مهمة:**

### **1. Firebase Functions:**
```
✅ يجب نشرها قبل الاختبار
✅ تحقق من Logs في Firebase Console
⚠️ قد تحتاج Billing Plan (Blaze)
```

### **2. FCM Token:**
```
✅ يُحفظ عند تسجيل الدخول
✅ يُحدّث تلقائياً
⚠️ قد يتغير بعد إعادة تثبيت التطبيق
```

### **3. teacherName:**
```
✅ يُحدّث تلقائياً عند تعديل معلم
✅ Function "syncTeacherSubjects" تعمل تلقائياً
⚠️ المواد القديمة قد تحتاج تحديث يدوي
```

---

**جميع الإصلاحات جاهزة! 🎉**

**الآن يجب:**
1. نشر Functions
2. إصلاح teacherName (اختياري - سيُحدّث تلقائياً)
3. بناء APK
4. الاختبار
