# 📚 إصلاح نظام الواجبات

## 📅 **التاريخ:** 1 نوفمبر 2025

---

## ❌ **المشاكل:**

### **1. الواجبات لا تصل لحساب الطالب:**
```
السبب: بيانات ناقصة عند إنشاء الواجب
- لا يوجد subjectName
- لا يوجد dueDate
```

### **2. اسم المعلم لا يظهر:**
```
السبب: خطأ في تحميل أسماء المعلمين
- الكود يبحث عن subjects كـ List<Map>
- لكن في قاعدة البيانات subjects هو List<String> (IDs)
```

### **3. الواجبات لا تظهر في حساب الطالب:**
```
السبب: _hasActiveHomework يرجع false دائماً
- لا يتم تحميل الواجبات من Firestore
```

---

## ✅ **الحلول:**

### **1️⃣ إصلاح إنشاء الواجب:**

#### **قبل:**
```dart
await FirebaseFirestore.instance.collection('homework').add({
  'teacherId': user.uid,
  'teacherName': _teacherData!['name'],
  'subjectCode': _selectedSubject,  // ❌ فقط ID
  'title': _titleController.text,
  // ❌ لا يوجد subjectName
  // ❌ لا يوجد dueDate
});
```

#### **بعد:**
```dart
// الحصول على اسم المادة
final subjectDoc = await FirebaseFirestore.instance
    .collection('subjects')
    .doc(_selectedSubject)
    .get();

final subjectName = subjectDoc.data()?['name'] ?? 'غير معروف';
final subjectEmoji = subjectDoc.data()?['emoji'] ?? '📚';

await FirebaseFirestore.instance.collection('homework').add({
  'teacherId': user.uid,
  'teacherName': _teacherData!['name'],
  'subjectCode': _selectedSubject,
  'subjectName': subjectName,           // ✅ اسم المادة
  'subjectEmoji': subjectEmoji,         // ✅ إيموجي المادة
  'title': _titleController.text,
  'dueDate': Timestamp.fromDate(        // ✅ موعد نهائي
    DateTime.now().add(Duration(days: 7))
  ),
  'createdAt': FieldValue.serverTimestamp(),
});
```

---

### **2️⃣ إصلاح تحميل أسماء المعلمين:**

#### **قبل:**
```dart
final subjects = data['subjects'] as List<dynamic>?;

for (var subject in subjects) {
  if (subject is Map) {  // ❌ subjects ليس Map
    final subjectName = subject['name'];
    names[subjectName] = teacherName;
  }
}
```

#### **بعد:**
```dart
final subjectIds = data['subjects'] as List<dynamic>?;

for (var subjectId in subjectIds) {
  if (subjectId is String) {
    // تحميل اسم المادة من ID
    final subjectDoc = await FirebaseFirestore.instance
        .collection('subjects')
        .doc(subjectId)
        .get();
    
    if (subjectDoc.exists) {
      final subjectName = subjectDoc.data()?['name'];
      if (subjectName != null) {
        names[subjectName] = teacherName;  // ✅
      }
    }
  }
}
```

---

### **3️⃣ إصلاح عرض الواجبات للطالب:**

#### **قبل:**
```dart
bool _hasActiveHomework(String subjectName) {
  // TODO: سيتم ربطه مع Firestore
  return false;  // ❌ دائماً false
}
```

#### **بعد:**
```dart
// إضافة Map لتخزين الواجبات
Map<String, List<Map<String, dynamic>>> _activeHomeworks = {};

// تحميل الواجبات من Firestore
Future<void> _loadActiveHomeworks() async {
  final homeworksSnapshot = await FirebaseFirestore.instance
      .collection('homework')
      .where('stage', isEqualTo: _studentData!['stage'])
      .where('grade', isEqualTo: _studentData!['grade'])
      .where('sections', arrayContains: _studentData!['section'])
      .get();

  final Map<String, List<Map<String, dynamic>>> homeworks = {};
  
  for (var doc in homeworksSnapshot.docs) {
    final data = doc.data();
    final subjectName = data['subjectName'];
    
    if (subjectName != null) {
      if (!homeworks.containsKey(subjectName)) {
        homeworks[subjectName] = [];
      }
      homeworks[subjectName]!.add({
        'id': doc.id,
        ...data,
      });
    }
  }
  
  setState(() {
    _activeHomeworks = homeworks;
  });
}

// التحقق من وجود واجب
bool _hasActiveHomework(String subjectName) {
  return _activeHomeworks.containsKey(subjectName) && 
         _activeHomeworks[subjectName]!.isNotEmpty;  // ✅
}
```

---

## 📊 **النتيجة:**

### **عند إرسال واجب:**
```
✅ يتم حفظ subjectName
✅ يتم حفظ subjectEmoji
✅ يتم حفظ teacherName
✅ يتم حفظ dueDate
✅ يتم حفظ جميع البيانات المطلوبة
```

### **في حساب الطالب:**
```
✅ تظهر المواد مع أسماء المعلمين
✅ تظهر علامة الواجب على المواد التي لها واجبات
✅ يمكن فتح الواجب والاطلاع عليه
```

---

## 📝 **الملفات المعدلة:**

```
✅ lib/ui/teacher/teacher_home_complete.dart
   - إضافة تحميل subjectName و subjectEmoji
   - إضافة dueDate

✅ lib/ui/student/student_home_complete.dart
   - إصلاح تحميل أسماء المعلمين
   - إضافة تحميل الواجبات النشطة
   - تحديث _hasActiveHomework
```

---

## 🧪 **للاختبار:**

### **1. إرسال واجب:**
```
1. سجل دخول كمعلم
2. اختر مادة
3. أرسل واجب جديد
4. تحقق من Firestore أن البيانات كاملة
```

### **2. استقبال واجب:**
```
1. سجل دخول كطالب
2. يجب أن ترى علامة على المادة
3. اضغط على المادة
4. يجب أن يظهر الواجب
5. يجب أن يظهر اسم المعلم تحت اسم المادة
```

---

## 🎯 **الخطوة التالية:**

### **إضافة إشعارات:**

عند إرسال واجب، يجب إرسال إشعار للطلاب:

```dart
// في teacher_home_complete.dart بعد إنشاء الواجب
// TODO: إرسال إشعار عبر Cloud Function
```

---

**الحالة:** ✅ تم الإصلاح  
**يحتاج:** اختبار + إضافة إشعارات
