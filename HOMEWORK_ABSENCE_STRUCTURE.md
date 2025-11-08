# 📊 هيكلية البيانات الجديدة

## 🎯 **المتطلبات:**

### **إشعارات الغياب:**
```
1. يظهر في البانر (أعلى الصفحة) لمدة 24 ساعة
2. يبقى في تبويب "التنبيهات" لمدة عام كامل
```

### **الواجبات:**
```
1. تظهر في تبويب المادة لمدة 24 ساعة
2. تبقى في تبويب "الواجبات السابقة" لمدة عام كامل
```

---

## 📦 **هيكلية Firestore:**

### **1. إشعارات الغياب:**

```javascript
notifications_absences/{docId}
{
  studentUid: "abc123",
  studentName: "فاطمة أحمد",
  message: "غاب الطالب يوم الأحد",
  date: Timestamp,              // تاريخ الغياب
  createdAt: Timestamp,         // وقت الإنشاء
  bannerExpiresAt: Timestamp,   // ينتهي من البانر بعد 24 ساعة
  archiveUntil: Timestamp,      // يُحذف بعد سنة
  read: false,
  type: 'absence'
}
```

**الاستعلامات:**

```dart
// للبانر (24 ساعة)
.where('studentUid', isEqualTo: uid)
.where('bannerExpiresAt', isGreaterThan: now)

// لتبويب التنبيهات (سنة)
.where('studentUid', isEqualTo: uid)
.where('archiveUntil', isGreaterThan: now)
.orderBy('archiveUntil', descending: true)
.orderBy('createdAt', descending: true)
```

---

### **2. الواجبات:**

```javascript
homework/{docId}
{
  teacherId: "xyz789",
  teacherName: "أ : سارة محمد",
  subjectCode: "math_101",
  subjectName: "الرياضيات",
  subjectEmoji: "🔢",
  title: "حل التمارين",
  details: "صفحة 45-50",
  stage: "متوسطة",
  grade: "الأول",
  branch: null,
  sections: ["أ", "ب"],
  createdAt: Timestamp,         // وقت الإنشاء
  activeUntil: Timestamp,       // يظهر في تبويب المادة لمدة 24 ساعة
  archiveUntil: Timestamp,      // يُحذف بعد سنة
  dueDate: Timestamp            // الموعد النهائي للتسليم
}
```

**الاستعلامات:**

```dart
// لتبويب المادة (24 ساعة)
.where('stage', isEqualTo: stage)
.where('grade', isEqualTo: grade)
.where('sections', arrayContains: section)
.where('activeUntil', isGreaterThan: now)
.where('subjectName', isEqualTo: subjectName)

// للواجبات السابقة (سنة)
.where('stage', isEqualTo: stage)
.where('grade', isEqualTo: grade)
.where('sections', arrayContains: section)
.where('archiveUntil', isGreaterThan: now)
.orderBy('archiveUntil', descending: true)
.orderBy('createdAt', descending: true)
```

---

## 🔄 **التعديلات المطلوبة:**

### **1. إرسال إشعار غياب:**

```dart
// في send_absence_screen.dart
await FirebaseFirestore.instance
    .collection('notifications_absences')
    .add({
  'studentUid': widget.studentUid,
  'studentName': widget.studentName,
  'message': _messageController.text.trim(),
  'date': _selectedDate,
  'createdAt': now,
  'bannerExpiresAt': now.add(Duration(hours: 24)),  // ✅ جديد
  'archiveUntil': now.add(Duration(days: 365)),     // ✅ جديد
  'read': false,
  'type': 'absence',
});
```

---

### **2. إرسال واجب:**

```dart
// في teacher_home_complete.dart
await FirebaseFirestore.instance.collection('homework').add({
  'teacherId': user.uid,
  'teacherName': _teacherData!['name'],
  'subjectCode': _selectedSubject,
  'subjectName': subjectName,
  'subjectEmoji': subjectEmoji,
  'title': _titleController.text,
  'details': _detailsController.text,
  'stage': _teacherData!['stage'],
  'grade': _teacherData!['grade'],
  'branch': _teacherData!['branch'],
  'sections': _selectedSections,
  'createdAt': FieldValue.serverTimestamp(),
  'activeUntil': Timestamp.fromDate(              // ✅ جديد
    DateTime.now().add(Duration(hours: 24))
  ),
  'archiveUntil': Timestamp.fromDate(             // ✅ جديد
    DateTime.now().add(Duration(days: 365))
  ),
  'dueDate': Timestamp.fromDate(
    DateTime.now().add(Duration(days: 7))
  ),
});
```

---

### **3. عرض في حساب الطالب:**

#### **البانر (إشعارات الغياب):**
```dart
// تحميل للبانر فقط
Future<void> _loadBannerAbsences() async {
  final now = DateTime.now();
  
  final snapshot = await FirebaseFirestore.instance
      .collection('notifications_absences')
      .where('studentUid', isEqualTo: user.uid)
      .where('bannerExpiresAt', isGreaterThan: Timestamp.fromDate(now))
      .get();
  
  // عرض في أعلى الصفحة
}
```

#### **تبويب التنبيهات:**
```dart
// تحميل جميع الإشعارات (سنة)
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('notifications_absences')
      .where('studentUid', isEqualTo: user.uid)
      .where('archiveUntil', isGreaterThan: Timestamp.fromDate(now))
      .orderBy('archiveUntil', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots(),
  // ...
)
```

#### **تبويب المادة (واجبات نشطة):**
```dart
// واجبات المادة (24 ساعة)
Future<void> _loadActiveHomeworks(String subjectName) async {
  final now = DateTime.now();
  
  final snapshot = await FirebaseFirestore.instance
      .collection('homework')
      .where('stage', isEqualTo: _studentData!['stage'])
      .where('grade', isEqualTo: _studentData!['grade'])
      .where('sections', arrayContains: _studentData!['section'])
      .where('activeUntil', isGreaterThan: Timestamp.fromDate(now))
      .where('subjectName', isEqualTo: subjectName)
      .get();
  
  // عرض في تبويب المادة
}
```

#### **تبويب الواجبات السابقة:**
```dart
// جميع الواجبات (سنة)
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('homework')
      .where('stage', isEqualTo: _studentData!['stage'])
      .where('grade', isEqualTo: _studentData!['grade'])
      .where('sections', arrayContains: _studentData!['section'])
      .where('archiveUntil', isGreaterThan: Timestamp.fromDate(now))
      .orderBy('archiveUntil', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots(),
  // ...
)
```

---

## 📱 **واجهة المستخدم:**

### **حساب الطالب:**

```
┌─────────────────────────────────────┐
│ 🚨 إشعار غياب (البانر - 24 ساعة)  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ الملف الشخصي                        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ المواد الدراسية                    │
│                                     │
│ [الرياضيات] 📝 (واجب جديد)         │
│ [العربية]                          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ تبويبات:                            │
│ • التنبيهات (جميع إشعارات الغياب)  │
│ • الواجبات السابقة (جميع الواجبات) │
└─────────────────────────────────────┘
```

---

## ⏰ **الجدول الزمني:**

| النوع | البانر/المادة | الأرشيف | الحذف |
|-------|---------------|---------|-------|
| إشعار غياب | 24 ساعة | سنة | بعد سنة |
| واجب | 24 ساعة | سنة | بعد سنة |

---

**التالي:** تطبيق هذه التعديلات
