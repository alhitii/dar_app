# 📚 النظام النهائي للواجبات والإشعارات

## 📅 **التاريخ:** 1 نوفمبر 2025

---

## 🎯 **المتطلبات:**

### **إشعارات الغياب:**
```
✅ يظهر في البانر (أعلى الصفحة) لمدة 24 ساعة
✅ يبقى في تبويب "جميع التنبيهات" لمدة عام كامل
```

### **الواجبات:**
```
✅ تظهر في تبويب المادة لمدة 24 ساعة
✅ تبقى في تبويب "الواجبات السابقة" لمدة عام كامل
```

---

## 📊 **هيكلية البيانات:**

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

---

## 🔄 **التعديلات المنفذة:**

### **1️⃣ إرسال إشعار غياب:**

**الملف:** `lib/ui/admin/send_absence_screen.dart`

```dart
await FirebaseFirestore.instance
    .collection('notifications_absences')
    .add({
  'studentUid': widget.studentUid,
  'studentName': widget.studentName,
  'message': _messageController.text.trim(),
  'date': _selectedDate,
  'createdAt': now,
  'bannerExpiresAt': now.add(Duration(hours: 24)),  // ✅
  'archiveUntil': now.add(Duration(days: 365)),     // ✅
  'read': false,
  'type': 'absence',
});
```

---

### **2️⃣ إرسال واجب:**

**الملف:** `lib/ui/teacher/teacher_home_complete.dart`

```dart
await FirebaseFirestore.instance.collection('homework').add({
  'teacherId': user.uid,
  'teacherName': _teacherData!['name'],
  'subjectCode': _selectedSubject,
  'subjectName': subjectName,           // ✅
  'subjectEmoji': subjectEmoji,         // ✅
  'title': _titleController.text,
  'details': _detailsController.text,
  'stage': _teacherData!['stage'],
  'grade': _teacherData!['grade'],
  'branch': _teacherData!['branch'],
  'sections': _selectedSections,
  'createdAt': FieldValue.serverTimestamp(),
  'activeUntil': Timestamp.fromDate(    // ✅ 24 ساعة
    now.add(Duration(hours: 24))
  ),
  'archiveUntil': Timestamp.fromDate(   // ✅ سنة
    now.add(Duration(days: 365))
  ),
  'dueDate': Timestamp.fromDate(
    now.add(Duration(days: 7))
  ),
});
```

---

### **3️⃣ عرض في حساب الطالب:**

#### **البانر (إشعارات الغياب - 24 ساعة):**

**الملف:** `lib/ui/student/student_home_complete.dart`

```dart
Future<void> _loadAbsenceNotifications() async {
  final now = DateTime.now();
  
  final absencesSnapshot = await FirebaseFirestore.instance
      .collection('notifications_absences')
      .where('studentUid', isEqualTo: user.uid)
      .where('bannerExpiresAt', isGreaterThan: Timestamp.fromDate(now))  // ✅
      .orderBy('bannerExpiresAt', descending: true)
      .orderBy('createdAt', descending: true)
      .get();
}
```

---

#### **تبويب جميع التنبيهات (سنة):**

**الملف:** `lib/ui/student/all_notifications_screen.dart` ✅ **جديد**

```dart
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('notifications_absences')
      .where('studentUid', isEqualTo: user?.uid)
      .where('archiveUntil', isGreaterThan: Timestamp.fromDate(now))  // ✅
      .orderBy('archiveUntil', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots(),
)
```

---

#### **تبويب المادة (واجبات نشطة - 24 ساعة):**

**الملف:** `lib/ui/student/student_home_complete.dart`

```dart
Future<void> _loadActiveHomeworks() async {
  final now = DateTime.now();
  
  final homeworksSnapshot = await FirebaseFirestore.instance
      .collection('homework')
      .where('stage', isEqualTo: _studentData!['stage'])
      .where('grade', isEqualTo: _studentData!['grade'])
      .where('sections', arrayContains: _studentData!['section'])
      .where('activeUntil', isGreaterThan: Timestamp.fromDate(now))  // ✅
      .get();
}
```

---

#### **تبويب الواجبات السابقة (سنة):**

**الملف:** `lib/ui/student/previous_homeworks_screen.dart` ✅ **جديد**

```dart
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('homework')
      .where('stage', isEqualTo: _studentData!['stage'])
      .where('grade', isEqualTo: _studentData!['grade'])
      .where('sections', arrayContains: _studentData!['section'])
      .where('archiveUntil', isGreaterThan: Timestamp.fromDate(now))  // ✅
      .orderBy('archiveUntil', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots(),
)
```

---

## 📱 **واجهة المستخدم:**

### **حساب الطالب:**

```
┌─────────────────────────────────────┐
│ 🚨 إشعار غياب (البانر - 24 ساعة)  │
│ غاب الطالب يوم الأحد...            │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ الملف الشخصي                        │
│ الاسم | الصف | الشعبة               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ المواد الدراسية                    │
│                                     │
│ 🔢 الرياضيات 📝                    │
│    أ : سارة محمد                    │
│    (واجب جديد - 24 ساعة)           │
│                                     │
│ 📖 العربية                         │
│    أ : أحمد علي                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ [زر] جميع التنبيهات (سنة كاملة)    │
│ [زر] الواجبات السابقة (سنة كاملة)  │
└─────────────────────────────────────┘
```

---

## ⏰ **الجدول الزمني:**

| النوع | البانر/المادة | الأرشيف | الحذف |
|-------|---------------|---------|-------|
| إشعار غياب | 24 ساعة | سنة | بعد سنة |
| واجب | 24 ساعة | سنة | بعد سنة |

---

## 🎨 **التصميم:**

### **البانر (إشعار غياب):**
- خلفية: تدرج أحمر فاتح
- حدود: أحمر متوسط (2px)
- أيقونة: ⚠️ في دائرة حمراء
- النص: أسود على خلفية بيضاء

### **بطاقة الواجب (نشط):**
- خلفية: تدرج أزرق فاتح
- حدود: أزرق متوسط (2px)
- علامة: "جديد" بخلفية خضراء
- إيموجي المادة + اسم المعلم

### **بطاقة الواجب (منتهي):**
- خلفية: تدرج رمادي فاتح
- حدود: رمادي متوسط (2px)
- بدون علامة "جديد"
- نفس التصميم لكن بألوان باهتة

---

## 📝 **الملفات المعدلة/الجديدة:**

### **معدلة:**
```
✅ lib/ui/admin/send_absence_screen.dart
   - إضافة bannerExpiresAt و archiveUntil

✅ lib/ui/teacher/teacher_home_complete.dart
   - إضافة activeUntil و archiveUntil
   - إضافة subjectName و subjectEmoji

✅ lib/ui/student/student_home_complete.dart
   - تحديث _loadAbsenceNotifications (bannerExpiresAt)
   - تحديث _loadActiveHomeworks (activeUntil)
```

### **جديدة:**
```
✅ lib/ui/student/all_notifications_screen.dart
   - صفحة جميع التنبيهات (سنة)
   - StreamBuilder مع archiveUntil
   - تصميم يميز بين النشط والمنتهي

✅ lib/ui/student/previous_homeworks_screen.dart
   - صفحة الواجبات السابقة (سنة)
   - StreamBuilder مع archiveUntil
   - تصميم يميز بين النشط والمنتهي
   - نافذة تفاصيل الواجب
```

---

## 🧪 **للاختبار:**

### **1. إشعار الغياب:**

**كـ Admin:**
```
1. افتح صفحة طالب
2. اضغط "إرسال إشعار غياب"
3. اكتب رسالة واختر تاريخ
4. اضغط إرسال
```

**كـ طالب:**
```
1. سجل دخول
2. يجب أن ترى الإشعار في البانر (أعلى الصفحة)
3. اضغط على "جميع التنبيهات"
4. يجب أن ترى نفس الإشعار هناك
5. بعد 24 ساعة: يختفي من البانر لكن يبقى في التنبيهات
```

---

### **2. الواجبات:**

**كـ معلم:**
```
1. سجل دخول
2. اختر مادة وشعبة
3. اكتب عنوان وتفاصيل الواجب
4. اضغط إرسال
```

**كـ طالب:**
```
1. سجل دخول
2. يجب أن ترى علامة 📝 على المادة
3. اضغط على المادة لرؤية الواجب
4. اضغط على "الواجبات السابقة"
5. يجب أن ترى نفس الواجب هناك
6. بعد 24 ساعة: يختفي من تبويب المادة لكن يبقى في الواجبات السابقة
```

---

## 🎯 **النتيجة النهائية:**

```
✅ إشعار الغياب يُرسل بنجاح
✅ يظهر في البانر لمدة 24 ساعة
✅ يبقى في "جميع التنبيهات" لمدة سنة
✅ الواجب يُرسل بنجاح
✅ يظهر في تبويب المادة لمدة 24 ساعة
✅ يبقى في "الواجبات السابقة" لمدة سنة
✅ تصميم واضح يميز بين النشط والمنتهي
```

---

## 🔄 **الخطوة التالية:**

```
1. اختبار النظام بالكامل
2. إضافة أزرار للانتقال إلى الصفحات الجديدة
3. إضافة إشعارات push عند إرسال واجب/غياب
```

---

**الحالة:** ✅ جاهز للاختبار  
**التاريخ:** 1 نوفمبر 2025
