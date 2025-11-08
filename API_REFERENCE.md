# 📚 مرجع الواجهات البرمجية (API Reference)

دليل شامل لجميع الدوال والفئات الرئيسية في المشروع.

---

## 🔧 الأدوات (Utils)

### `SetupSubjectsWithMetadata`

**الملف:** `lib/utils/setup_subjects_with_metadata.dart`

#### `setupAll()`

إضافة جميع المواد الدراسية (132 مادة) إلى Firestore.

**التوقيع:**
```dart
static Future<void> setupAll()
```

**الاستخدام:**
```dart
await SetupSubjectsWithMetadata.setupAll();
```

**النتيجة:**
```dart
{
  'success': true,
  'totalAdded': 132,
  'totalSkipped': 0
}
```

**المواد المضافة:**
- ابتدائية: 48 مادة (6 صفوف × 8 مواد)
- متوسطة: 27 مادة (3 صفوف × 9 مواد)
- إعدادية علمي: 27 مادة (3 صفوف × 9 مواد)
- إعدادية أدبي: 30 مادة (3 صفوف × 10 مواد)

---

### `AddSubjectsQuick`

**الملف:** `lib/utils/add_subjects_quick.dart`

#### `addSecondaryScientific()`

إضافة سريعة لمواد الإعدادية - علمي (27 مادة).

**التوقيع:**
```dart
static Future<void> addSecondaryScientific()
```

**الاستخدام:**
```dart
await AddSubjectsQuick.addSecondaryScientific();
```

**المواد:**
```dart
[
  'التربية الإسلامية', 'اللغة العربية', 'اللغة الإنجليزية',
  'الرياضيات', 'الفيزياء', 'الكيمياء', 'الأحياء',
  'الحاسوب', 'اللغة الفرنسية'
]
```

---

### `FixTeacherMissingData`

**الملف:** `lib/utils/fix_teacher_missing_data.dart`

#### `fix()`

إصلاح بيانات المعلمين القدامى (إضافة sections و subjects).

**التوقيع:**
```dart
static Future<Map<String, dynamic>> fix()
```

**الاستخدام:**
```dart
final result = await FixTeacherMissingData.fix();
print('تم إصلاح: ${result['fixedTeachers']} معلم');
```

**النتيجة:**
```dart
{
  'success': true,
  'totalTeachers': 15,
  'fixedTeachers': 12,
  'alreadyValid': 3,
  'errors': []
}
```

---

### `FixOldSubjects`

**الملف:** `lib/utils/fix_old_subjects.dart`

#### `fixAllTeachers()`

تحديث المواد لجميع المعلمين بناءً على صفوفهم الحالية.

**التوقيع:**
```dart
static Future<Map<String, dynamic>> fixAllTeachers()
```

**الاستخدام:**
```dart
final result = await FixOldSubjects.fixAllTeachers();
```

**ما يفعله:**
1. يقرأ المرحلة والصف لكل معلم
2. يجلب المواد الصحيحة من Firestore
3. يستبدل المواد القديمة (replace كامل)

---

#### `fixSingleTeacher(String email)`

تحديث المواد لمعلم واحد.

**التوقيع:**
```dart
static Future<Map<String, dynamic>> fixSingleTeacher(String email)
```

**الاستخدام:**
```dart
final result = await FixOldSubjects.fixSingleTeacher('teacher@example.com');
```

---

### `DiagnoseTeacher`

**الملف:** `lib/utils/diagnose_teacher.dart`

#### `check()`

تشخيص سريع لبيانات المعلم الحالي.

**التوقيع:**
```dart
static Future<void> check()
```

**الاستخدام:**
```dart
await DiagnoseTeacher.check();
// النتيجة تُطبع في Console
```

**المخرجات:**
```
👤 المستخدم الحالي:
   - UID: abc123
   - Email: teacher@example.com

📧 فحص users_emails collection...
✅ المستند موجود

📋 البيانات المحفوظة:
   - role: teacher
   - stage: إعدادية
   - grade: السادس

📚 المواد (subjects):
   ✅ موجود: 3 مادة
   📝 IDs: sec_6_physics_sci, sec_6_chemistry_sci, ...
```

---

## 🎨 الواجهات (UI)

### `EditTeacherDialog`

**الملف:** `lib/ui/admin/edit_teacher_dialog.dart`

#### Constructor

```dart
EditTeacherDialog({
  required Map<String, dynamic> teacher,
})
```

#### المعاملات
- `teacher`: بيانات المعلم الحالية

#### الميزات
- ✅ تحميل ديناميكي للمواد حسب الصف
- ✅ إعادة تحميل عند تغيير الصف/الفرع
- ✅ استبدال كامل للمواد (حذف القديمة)

#### الدوال الداخلية

##### `_loadAvailableSubjects()`
```dart
Future<void> _loadAvailableSubjects() async {
  Query query = FirebaseFirestore.instance.collection('subjects');
  query = query.where('stage', isEqualTo: _selectedStage);
  query = query.where('grade', isEqualTo: _selectedGrade);
  
  if (_selectedStage == 'إعدادية' && _selectedBranch != null) {
    query = query.where('branch', isEqualTo: _selectedBranch);
  }
  
  final snapshot = await query.get();
  // ...
}
```

##### `_updateTeacher()`
```dart
Future<void> _updateTeacher() async {
  final updatedData = {
    'name': _nameController.text,
    'email': _emailController.text.toLowerCase(),
    'stage': _selectedStage,
    'grade': _selectedGrade,
    'branch': _selectedBranch,
    'sections': _selectedSections,
    'subjects': _selectedSubjects,  // ✅ استبدال كامل
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email)
      .set(updatedData);  // بدون merge: true
}
```

---

### `_HomeworkForm`

**الملف:** `lib/ui/teacher/home_screen.dart`

#### الميزات
- إنشاء واجب جديد
- اختيار المادة من القائمة المنسدلة
- اختيار الشعب
- تحديد تاريخ التسليم

#### الدوال الرئيسية

##### `_loadTeacherSubjects()`
```dart
Future<List<SubjectModel>> _loadTeacherSubjects() async {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;
  
  if (email == null) return [];
  
  // جلب subjects من users_emails
  final emailDoc = await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email.toLowerCase())
      .get();
  
  final List<dynamic>? subjectIds = emailDoc.data()?['subjects'];
  
  if (subjectIds == null || subjectIds.isEmpty) return [];
  
  // جلب تفاصيل المواد
  final snaps = await FirebaseFirestore.instance
      .collection('subjects')
      .where(FieldPath.documentId, whereIn: subjectIds)
      .get();
  
  return snaps.docs.map((doc) => SubjectModel.fromFirestore(doc)).toList();
}
```

##### `_submitHomework()`
```dart
Future<void> _submitHomework() async {
  if (!_formKey.currentState!.validate()) return;
  
  final homeworkData = {
    'title': _titleController.text,
    'description': _descriptionController.text,
    'teacherId': user.uid,
    'teacherName': _teacherData['name'],
    'subjectId': _selectedSubject!.id,
    'subjectName': _selectedSubject!.name,
    'stage': _teacherData['stage'],
    'grade': _teacherData['grade'],
    'sections': _selectedSections,
    'dueDate': _selectedDate,
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'active',
  };
  
  await FirebaseFirestore.instance.collection('homeworks').add(homeworkData);
  
  // إرسال إشعارات للطلاب
  await _sendNotifications();
}
```

---

## 📊 النماذج (Models)

### `SubjectModel`

**الملف:** `lib/models/subject_model.dart`

#### البنية
```dart
class SubjectModel {
  final String id;
  final String name;
  final String emoji;
  final String stage;
  final String grade;
  final String? branch;
  final int order;
  
  SubjectModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.stage,
    required this.grade,
    this.branch,
    this.order = 0,
  });
  
  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      emoji: data['emoji'] ?? '📚',
      stage: data['stage'] ?? '',
      grade: data['grade'] ?? '',
      branch: data['branch'],
      order: data['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'stage': stage,
      'grade': grade,
      'branch': branch,
      'order': order,
    };
  }
}
```

---

### `TeacherModel`

**الملف:** `lib/models/teacher_model.dart`

#### البنية
```dart
class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String stage;
  final String grade;
  final String? branch;
  final List<String> sections;
  final List<String> subjects;
  final bool isActive;
  
  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.stage,
    required this.grade,
    this.branch,
    this.sections = const [],
    this.subjects = const [],
    this.isActive = true,
  });
  
  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      stage: data['stage'] ?? '',
      grade: data['grade'] ?? '',
      branch: data['branch'],
      sections: List<String>.from(data['sections'] ?? []),
      subjects: List<String>.from(data['subjects'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }
}
```

---

## 🔥 Firestore Queries

### جلب المواد حسب الصف

```dart
Query query = FirebaseFirestore.instance.collection('subjects');
query = query.where('stage', isEqualTo: 'إعدادية');
query = query.where('grade', isEqualTo: 'السادس');
query = query.where('branch', isEqualTo: 'علمي');

final snapshot = await query.get();
final subjects = snapshot.docs.map((doc) => SubjectModel.fromFirestore(doc)).toList();
```

---

### جلب المعلمين حسب المرحلة

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('teachers')
    .where('stage', isEqualTo: 'إعدادية')
    .where('isActive', isEqualTo: true)
    .orderBy('name')
    .get();

final teachers = snapshot.docs.map((doc) => TeacherModel.fromFirestore(doc)).toList();
```

---

### جلب الواجبات للمعلم

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('homeworks')
    .where('teacherId', isEqualTo: teacherId)
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();
```

---

### جلب الواجبات للطالب

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('homeworks')
    .where('stage', isEqualTo: studentStage)
    .where('grade', isEqualTo: studentGrade)
    .where('sections', arrayContains: studentSection)
    .where('status', isEqualTo: 'active')
    .orderBy('dueDate')
    .get();
```

---

## 🔐 Security Rules

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users emails
    match /users_emails/{email} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      (request.auth.token.email == resource.data.email ||
                       get(/databases/$(database)/documents/users_emails/$(request.auth.token.email)).data.role == 'admin');
    }
    
    // Subjects
    match /subjects/{subjectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users_emails/$(request.auth.token.email)).data.role == 'admin';
    }
    
    // Teachers
    match /teachers/{teacherId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users_emails/$(request.auth.token.email)).data.role == 'admin';
    }
    
    // Homeworks
    match /homeworks/{homeworkId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/users_emails/$(request.auth.token.email)).data.role == 'teacher';
      allow update, delete: if request.auth != null && 
                               resource.data.teacherId == request.auth.uid;
    }
  }
}
```

---

## 🎯 أمثلة الاستخدام

### مثال 1: إنشاء معلم جديد

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createTeacher({
  required String name,
  required String email,
  required String stage,
  required String grade,
  String? branch,
  required List<String> sections,
  required List<String> subjects,
}) async {
  final teacherData = {
    'name': name,
    'email': email.toLowerCase(),
    'stage': stage,
    'grade': grade,
    'branch': branch,
    'sections': sections,
    'subjects': subjects,
    'role': 'teacher',
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
  };
  
  // إضافة في teachers
  final teacherDoc = await FirebaseFirestore.instance
      .collection('teachers')
      .add(teacherData);
  
  // إضافة في users_emails
  await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email.toLowerCase())
      .set({
    ...teacherData,
    'teacherId': teacherDoc.id,
    'uid': teacherDoc.id,
  });
}
```

---

### مثال 2: جلب مواد معلم

```dart
Future<List<SubjectModel>> getTeacherSubjects(String email) async {
  // جلب IDs المواد
  final emailDoc = await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email.toLowerCase())
      .get();
  
  final List<dynamic> subjectIds = emailDoc.data()?['subjects'] ?? [];
  
  if (subjectIds.isEmpty) return [];
  
  // جلب تفاصيل المواد
  final snapshot = await FirebaseFirestore.instance
      .collection('subjects')
      .where(FieldPath.documentId, whereIn: subjectIds)
      .get();
  
  return snapshot.docs
      .map((doc) => SubjectModel.fromFirestore(doc))
      .toList();
}
```

---

### مثال 3: إنشاء واجب

```dart
Future<String> createHomework({
  required String title,
  required String description,
  required String teacherId,
  required String teacherName,
  required String subjectId,
  required String subjectName,
  required String stage,
  required String grade,
  required List<String> sections,
  required DateTime dueDate,
}) async {
  final homework = {
    'title': title,
    'description': description,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'stage': stage,
    'grade': grade,
    'sections': sections,
    'dueDate': Timestamp.fromDate(dueDate),
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'active',
  };
  
  final doc = await FirebaseFirestore.instance
      .collection('homeworks')
      .add(homework);
  
  return doc.id;
}
```

---

## 🛠️ Utilities Functions

### تحويل تاريخ Firestore

```dart
DateTime? timestampToDateTime(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  }
  return null;
}
```

---

### التحقق من الصلاحيات

```dart
Future<bool> isAdmin(String email) async {
  final doc = await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email.toLowerCase())
      .get();
  
  return doc.data()?['role'] == 'admin';
}

Future<bool> isTeacher(String email) async {
  final doc = await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(email.toLowerCase())
      .get();
  
  return doc.data()?['role'] == 'teacher';
}
```

---

## 📝 ملاحظات مهمة

### 1. حساسية الأحرف
```dart
// ✅ صحيح
email.toLowerCase()

// ❌ خطأ
email  // بدون toLowerCase
```

### 2. Firestore Queries
```dart
// ✅ صحيح - المطابقة التامة
.where('stage', isEqualTo: 'إعدادية')

// ❌ خطأ - المطابقة الجزئية غير مدعومة
.where('stage', isEqualTo: 'اعدادية')  // بدون همزة
```

### 3. استبدال vs دمج
```dart
// ✅ صحيح - استبدال كامل
.set(data)

// ❌ خطأ للمواد - يحفظ القديمة
.set(data, SetOptions(merge: true))
```

---

**آخر تحديث:** 2025-10-26  
**الإصدار:** 1.0.0
