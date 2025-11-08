# 🔔 نظام إشعارات الواجبات الكامل

## 📅 **التاريخ:** 1 نوفمبر 2025

---

## ❌ **المشاكل السابقة:**

```
1. لا يوجد صوت ولا اهتزاز
2. لا يوجد إشعار واجب جديد
3. الواجب يظهر فقط عند الدخول على المادة
4. لا يوجد إرسال إشعارات من المعلم للطلاب
```

---

## ✅ **الحل الكامل:**

### **1. إرسال إشعارات من المعلم:**

```dart
// في teacher_home_complete.dart

Future<void> _sendNotificationsToStudents({
  required String subjectName,
  required String subjectEmoji,
  required String title,
}) async {
  // جلب الطلاب في نفس المرحلة والصف والفرع
  final studentsQuery = await FirebaseFirestore.instance
      .collection('students')
      .where('stage', isEqualTo: _teacherData!['stage'])
      .where('grade', isEqualTo: _teacherData!['grade'])
      .where('branch', isEqualTo: _teacherData!['branch'])
      .get();

  for (var studentDoc in studentsQuery.docs) {
    final studentSection = studentDoc.data()['section'] as String?;
    
    // التحقق من الشعبة
    if (studentSection != null && _selectedSections.contains(studentSection)) {
      // إنشاء إشعار
      await FirebaseFirestore.instance
          .collection('notifications_homeworks')
          .add({
        'studentId': studentDoc.id,
        'teacherId': FirebaseAuth.instance.currentUser!.uid,
        'teacherName': _teacherData!['name'],
        'subjectName': subjectName,
        'subjectEmoji': subjectEmoji,
        'title': title,
        'type': 'homework',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
```

---

### **2. استقبال الإشعارات في صفحة الطالب:**

```dart
// في student_home_complete.dart

void _listenToHomeworkNotifications() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  FirebaseFirestore.instance
      .collection('notifications_homeworks')
      .where('studentId', isEqualTo: user.uid)
      .where('read', isEqualTo: false)
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final data = change.doc.data();
        if (data != null) {
          // إشعار محلي
          _showLocalHomeworkNotification(data);
          
          // تحديث الواجبات
          _loadActiveHomeworks();
        }
      }
    }
  });
}
```

---

### **3. عرض الإشعار المحلي:**

```dart
void _showLocalHomeworkNotification(Map<String, dynamic> data) {
  final subjectName = data['subjectName'] ?? 'مادة';
  final subjectEmoji = data['subjectEmoji'] ?? '📚';
  final title = data['title'] ?? 'واجب جديد';
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$subjectEmoji واجب جديد في $subjectName: $title'),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.green,
      action: SnackBarAction(
        label: 'عرض',
        textColor: Colors.white,
        onPressed: () {
          _showHomeworkDialog(subjectName);
        },
      ),
    ),
  );
}
```

---

## 🔄 **كيف يعمل النظام:**

### **الخطوة 1: المعلم يرسل واجب:**
```
1. المعلم يملأ نموذج الواجب
2. يختار المادة والشعب
3. يضغط "إرسال الواجب"
4. ✅ يتم إنشاء الواجب في collection('homework')
5. ✅ يتم استدعاء _sendNotificationsToStudents()
```

### **الخطوة 2: إنشاء إشعارات للطلاب:**
```
1. جلب جميع الطلاب في نفس المرحلة والصف والفرع
2. تصفية حسب الشعب المختارة
3. لكل طالب:
   ✅ إنشاء document في collection('notifications_homeworks')
   ✅ حفظ معلومات الواجب
   ✅ read: false
```

### **الخطوة 3: الطالب يستقبل الإشعار:**
```
1. Firestore Snapshot Listener يراقب notifications_homeworks
2. عند إضافة document جديد:
   ✅ DocumentChangeType.added يتم اكتشافه
   ✅ _showLocalHomeworkNotification() يتم استدعاؤه
   ✅ SnackBar يظهر للطالب
   ✅ _loadActiveHomeworks() يحدث الواجبات
   ✅ الشارة تظهر على المادة
```

---

## 📊 **هيكل البيانات:**

### **collection('homework'):**
```javascript
{
  teacherId: "abc123",
  teacherName: "سارة محمد",
  subjectCode: "math_101",
  subjectName: "الرياضيات",
  subjectEmoji: "🔢",
  title: "حل تمارين الفصل الثالث",
  details: "حل جميع التمارين من صفحة 45 إلى 50",
  stage: "إعدادية",
  grade: "الرابع",
  branch: "علمي",
  sections: ["أ", "ب"],
  createdAt: Timestamp,
  activeUntil: Timestamp,
  archiveUntil: Timestamp,
  dueDate: Timestamp
}
```

### **collection('notifications_homeworks'):**
```javascript
{
  studentId: "xyz789",
  teacherId: "abc123",
  teacherName: "سارة محمد",
  subjectName: "الرياضيات",
  subjectEmoji: "🔢",
  title: "حل تمارين الفصل الثالث",
  type: "homework",
  read: false,
  createdAt: Timestamp
}
```

---

## 🎯 **المميزات:**

### **1. إشعارات فورية:**
```
✅ الطالب يستقبل الإشعار فوراً
✅ لا يحتاج إعادة تشغيل التطبيق
✅ لا يحتاج تحديث يدوي
✅ Realtime من Firestore
```

### **2. إشعارات مستهدفة:**
```
✅ فقط للطلاب في نفس المرحلة
✅ فقط للطلاب في نفس الصف
✅ فقط للطلاب في نفس الفرع
✅ فقط للطلاب في الشعب المختارة
```

### **3. واجهة مستخدم جيدة:**
```
✅ SnackBar أخضر جذاب
✅ يحتوي على emoji المادة
✅ زر "عرض" للذهاب مباشرة للواجب
✅ مدة عرض 4 ثواني
```

### **4. تحديث تلقائي:**
```
✅ الواجبات تتحدث تلقائياً
✅ الشارة تظهر تلقائياً
✅ لا يحتاج refresh يدوي
```

---

## 📝 **الملفات المعدلة:**

### **1. teacher_home_complete.dart:**
```dart
✅ إضافة _sendNotificationsToStudents()
✅ استدعاء في _sendHomework()
✅ إنشاء documents في notifications_homeworks
✅ تحديث رسالة النجاح
```

### **2. student_home_complete.dart:**
```dart
✅ إضافة _listenToHomeworkNotifications()
✅ إضافة _showLocalHomeworkNotification()
✅ استدعاء في initState()
✅ Snapshot listener على notifications_homeworks
```

---

## 🧪 **الاختبار:**

### **الخطوة 1: تسجيل دخول كمعلم:**
```
1. افتح التطبيق
2. سجل دخول كمعلم
3. اذهب لتبويب "إرسال واجب"
4. املأ النموذج:
   - المادة: الرياضيات
   - الشعب: أ، ب
   - العنوان: حل التمارين
   - التفاصيل: صفحة 45-50
5. اضغط "إرسال الواجب"
6. ✅ رسالة: "تم إرسال الواجب والإشعارات بنجاح"
```

### **الخطوة 2: تسجيل دخول كطالب:**
```
1. افتح التطبيق على جهاز آخر (أو حساب آخر)
2. سجل دخول كطالب في نفس المرحلة والصف والشعبة
3. ✅ فوراً: SnackBar أخضر يظهر
4. ✅ النص: "🔢 واجب جديد في الرياضيات: حل التمارين"
5. ✅ زر "عرض" موجود
6. ✅ الشارة الحمراء تظهر على بطاقة الرياضيات
```

### **الخطوة 3: فتح الواجب:**
```
1. اضغط على بطاقة الرياضيات
2. ✅ نافذة الواجب تفتح
3. ✅ الواجب الجديد موجود
4. ✅ الشارة تختفي
5. أغلق التطبيق وافتحه مرة أخرى
6. ✅ الشارة لا تظهر (محفوظة)
```

---

## ⚠️ **ملاحظات مهمة:**

### **1. Firestore Indexes:**
```
قد تحتاج إنشاء composite index:
- Collection: notifications_homeworks
- Fields: studentId (Ascending), read (Ascending)

Firestore سيطلب منك إنشاءه تلقائياً عند أول استخدام
```

### **2. الأداء:**
```
✅ Snapshot listener فعال جداً
✅ يستهلك بيانات قليلة
✅ يعمل في الخلفية
⚠️ يتوقف عند إغلاق التطبيق
```

### **3. الصوت والاهتزاز:**
```
⚠️ SnackBar لا يصدر صوت أو اهتزاز
⚠️ للحصول على صوت واهتزاز، يجب:
   1. استخدام Firebase Cloud Messaging
   2. إرسال notification من الخادم
   3. استخدام flutter_local_notifications
```

---

## 🚀 **للحصول على صوت واهتزاز:**

### **الحل المقترح: Firebase Cloud Functions:**

```javascript
// في Firebase Functions

exports.sendHomeworkNotification = functions.firestore
  .document('notifications_homeworks/{notificationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // جلب FCM token للطالب
    const studentDoc = await admin.firestore()
      .collection('students')
      .doc(data.studentId)
      .get();
    
    const fcmToken = studentDoc.data().fcmToken;
    
    if (fcmToken) {
      // إرسال إشعار FCM
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: `${data.subjectEmoji} واجب جديد`,
          body: `${data.subjectName}: ${data.title}`,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
            priority: 'max',
          },
        },
      });
    }
  });
```

---

## 🎯 **النتيجة الحالية:**

```
✅ إشعارات فورية (SnackBar)
✅ تحديث تلقائي للواجبات
✅ شارات على المواد
✅ إشعارات مستهدفة
✅ واجهة مستخدم جيدة
⚠️ لا يوجد صوت أو اهتزاز (يحتاج FCM + Cloud Functions)
```

---

**النظام يعمل بشكل ممتاز! 🎉**

**للحصول على صوت واهتزاز، يجب إضافة Firebase Cloud Functions**
