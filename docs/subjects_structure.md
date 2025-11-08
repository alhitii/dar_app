# 📘 توثيق هيكل المواد الدراسية (Subjects Structure)

## 📍 الموقع في Firestore
```
subjects/ (Collection)
  ├── [subjectId] (Document)
```

---

## 🏗️ الهيكل الكامل للوثيقة

### الحقول الأساسية

```json
{
  "name": "الرياضيات",
  "emoji": "➕",
  "stage": "إعدادية",
  "grade": "الرابع",
  "branch": "علمي",
  "sections": ["أ", "ب", "ج"],
  "teacherUid": "abc123...",
  "teacherName": "محمد علي",
  "isActive": true,
  "updatedAt": Timestamp,
  "createdAt": Timestamp
}
```

### وصف الحقول

| الحقل | النوع | إلزامي | الوصف |
|------|------|--------|-------|
| `name` | String | ✅ | اسم المادة (مثل: الرياضيات، الفيزياء) |
| `emoji` | String | ✅ | رمز تعبيري للمادة (➕، 🔬، 📚) |
| `stage` | String | ✅ | المرحلة (ابتدائية، متوسطة، إعدادية) |
| `grade` | String | ✅ | الصف (الأول، الثاني، ... السادس) |
| `branch` | String | ⚠️ | الفرع (علمي، أدبي) - للإعدادية فقط |
| `sections` | Array | ✅ | قائمة الشعب ["أ", "ب", "ج", ...] |
| `teacherUid` | String | ⚠️ | معرّف المعلم (يُضاف عند الربط) |
| `teacherName` | String | ⚠️ | اسم المعلم (يُضاف عند الربط) |
| `isActive` | Boolean | ✅ | حالة المادة (نشطة/معطلة) |
| `updatedAt` | Timestamp | ✅ | تاريخ آخر تحديث |
| `createdAt` | Timestamp | ✅ | تاريخ الإنشاء |

---

## 📚 المراحل والصفوف

### 1. المرحلة الابتدائية
```json
{
  "stage": "ابتدائية",
  "grade": "الأول" | "الثاني" | "الثالث" | "الرابع" | "الخامس" | "السادس",
  "branch": null  // لا يوجد فرع
}
```

**المواد النموذجية:**
- القرآن الكريم 📖
- العربية ✍️
- الرياضيات ➕
- العلوم 🔬
- الإنجليزية 🇬🇧

### 2. المرحلة المتوسطة
```json
{
  "stage": "متوسطة",
  "grade": "الأول" | "الثاني" | "الثالث",
  "branch": null  // لا يوجد فرع
}
```

**المواد النموذجية:**
- القرآن الكريم 📖
- العربية ✍️
- الرياضيات ➕
- العلوم 🔬
- الإنجليزية 🇬🇧
- التاريخ 📜
- الجغرافيا 🌍

### 3. المرحلة الإعدادية - الفرع العلمي
```json
{
  "stage": "إعدادية",
  "grade": "الرابع" | "الخامس" | "السادس",
  "branch": "علمي"
}
```

**المواد النموذجية:**
- الرياضيات ➕
- الفيزياء ⚛️
- الكيمياء 🧪
- الأحياء 🦠
- الإنجليزية 🇬🇧
- العربية ✍️

### 4. المرحلة الإعدادية - الفرع الأدبي
```json
{
  "stage": "إعدادية",
  "grade": "الرابع" | "الخامس" | "السادس",
  "branch": "أدبي"
}
```

**المواد النموذجية:**
- العربية ✍️
- التاريخ 📜
- الجغرافيا 🌍
- الفلسفة 💭
- علم الاجتماع 👥
- الإنجليزية 🇬🇧

---

## 🔄 دورة حياة المادة

### 1. إنشاء المادة (Setup)
```dart
await FirebaseFirestore.instance.collection('subjects').add({
  'name': 'الرياضيات',
  'emoji': '➕',
  'stage': 'إعدادية',
  'grade': 'الرابع',
  'branch': 'علمي',
  'sections': ['أ', 'ب'],
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
});
```

### 2. ربط المادة بمعلم
```dart
await FirebaseFirestore.instance
    .collection('subjects')
    .doc(subjectId)
    .update({
      'teacherUid': 'teacher_uid_123',
      'teacherName': 'محمد علي',
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 3. تعطيل المادة
```dart
await FirebaseFirestore.instance
    .collection('subjects')
    .doc(subjectId)
    .update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 4. إزالة المعلم من المادة
```dart
await FirebaseFirestore.instance
    .collection('subjects')
    .doc(subjectId)
    .update({
      'teacherUid': FieldValue.delete(),
      'teacherName': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

---

## 🔍 استعلامات شائعة

### 1. جلب مواد مرحلة وصف محدد
```dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .where('stage', isEqualTo: 'إعدادية')
    .where('grade', isEqualTo: 'الرابع')
    .get();
```

### 2. جلب مواد فرع محدد (للإعدادية)
```dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .where('stage', isEqualTo: 'إعدادية')
    .where('grade', isEqualTo: 'الرابع')
    .where('branch', isEqualTo: 'علمي')
    .get();
```

### 3. جلب مواد شعبة محددة
```dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .where('stage', isEqualTo: 'إعدادية')
    .where('grade', isEqualTo: 'الرابع')
    .where('sections', arrayContains: 'أ')
    .get();
```

### 4. جلب مواد معلم محدد
```dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .where('teacherUid', isEqualTo: 'teacher_uid_123')
    .where('isActive', isEqualTo: true)
    .get();
```

### 5. جلب جميع المواد النشطة
```dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .where('isActive', isEqualTo: true)
    .get();
```

---

## 📊 أمثلة واقعية

### مثال 1: مادة في المرحلة الابتدائية
```json
{
  "name": "الرياضيات",
  "emoji": "➕",
  "stage": "ابتدائية",
  "grade": "الثالث",
  "branch": null,
  "sections": ["أ", "ب"],
  "teacherUid": "teacher_001",
  "teacherName": "فاطمة أحمد",
  "isActive": true,
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-10-29T23:00:00Z"
}
```

### مثال 2: مادة في الإعدادية - علمي
```json
{
  "name": "الفيزياء",
  "emoji": "⚛️",
  "stage": "إعدادية",
  "grade": "الرابع",
  "branch": "علمي",
  "sections": ["أ"],
  "teacherUid": "teacher_002",
  "teacherName": "محمد علي",
  "isActive": true,
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-10-29T23:00:00Z"
}
```

### مثال 3: مادة في الإعدادية - أدبي
```json
{
  "name": "التاريخ",
  "emoji": "📜",
  "stage": "إعدادية",
  "grade": "الخامس",
  "branch": "أدبي",
  "sections": ["ب", "ج"],
  "teacherUid": "teacher_003",
  "teacherName": "أحمد حسن",
  "isActive": true,
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-10-29T23:00:00Z"
}
```

### مثال 4: مادة بدون معلم (غير مرتبطة)
```json
{
  "name": "الكيمياء",
  "emoji": "🧪",
  "stage": "إعدادية",
  "grade": "السادس",
  "branch": "علمي",
  "sections": ["أ", "ب"],
  "isActive": true,
  "createdAt": "2025-10-01T10:00:00Z"
}
```
> ⚠️ ملاحظة: `teacherUid` و `teacherName` غير موجودين - المادة لم تُربط بعد

---

## ⚠️ القواعد والقيود

### 1. التسميات الموحدة
يجب استخدام التسميات التالية بالضبط:

**المراحل:**
- `"ابتدائية"` (وليس "ابتدائي")
- `"متوسطة"` (وليس "متوسط")
- `"إعدادية"` (وليس "إعدادي")

**الفروع:**
- `"علمي"` (وليس "علمى")
- `"أدبي"` (وليس "أدبى")

**الصفوف:**
- `"الأول"`, `"الثاني"`, `"الثالث"`, `"الرابع"`, `"الخامس"`, `"السادس"`

### 2. الفرع للإعدادية فقط
```dart
// ✅ صحيح
if (stage == 'إعدادية') {
  query = query.where('branch', isEqualTo: branch);
}

// ❌ خطأ - لا تضع شرط branch للابتدائية والمتوسطة
```

### 3. المواد يجب أن تحتوي على شعبة واحدة على الأقل
```dart
// ✅ صحيح
'sections': ['أ']

// ❌ خطأ
'sections': []
```

---

## 🔧 صيانة البيانات

### سكريبت إصلاح التسميات
```dart
// fix_subjects_structure.dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .get();

for (var doc in subjects.docs) {
  final data = doc.data();
  Map<String, dynamic> updates = {};

  // توحيد المرحلة
  if (data['stage'] == 'إعدادي') {
    updates['stage'] = 'إعدادية';
  }
  
  // توحيد الفرع
  if (data['branch'] == 'علمى') {
    updates['branch'] = 'علمي';
  }

  // التأكد من sections كـ Array
  if (data['sections'] is String) {
    updates['sections'] = [data['sections']];
  }

  if (updates.isNotEmpty) {
    await doc.reference.update(updates);
  }
}
```

### سكريبت فحص البيانات
```dart
// check_subjects_structure.dart
final subjects = await FirebaseFirestore.instance
    .collection('subjects')
    .get();

for (var doc in subjects.docs) {
  final data = doc.data();
  
  // التحقق من الحقول المطلوبة
  if (!data.containsKey('name') || !data.containsKey('stage')) {
    print('❌ مادة غير مكتملة: ${doc.id}');
  }
  
  // التحقق من التسميات الصحيحة
  if (data['stage'] == 'إعدادي') {
    print('⚠️ تسمية خاطئة في ${doc.id}');
  }
}
```

---

## 📈 الإحصائيات

### عدد المواد لكل مرحلة
```dart
final count = await FirebaseFirestore.instance
    .collection('subjects')
    .where('stage', isEqualTo: 'إعدادية')
    .count()
    .get();

print('عدد مواد الإعدادية: ${count.count}');
```

### عدد المواد المرتبطة بمعلمين
```dart
final withTeacher = await FirebaseFirestore.instance
    .collection('subjects')
    .where('teacherUid', isNotEqualTo: null)
    .count()
    .get();

print('مواد مرتبطة: ${withTeacher.count}');
```

---

## 🎯 الخلاصة

هيكل المواد في Firestore:
- ✅ موحد عبر جميع المراحل
- ✅ يدعم الربط التلقائي بالمعلمين
- ✅ مرن ويسمح بالتوسع المستقبلي
- ✅ يتضمن جميع البيانات اللازمة للاستعلامات

**إجمالي المواد في النظام:** 65+ مادة
**المراحل:** 3 (ابتدائية، متوسطة، إعدادية)
**الفروع:** 2 (علمي، أدبي - للإعدادية فقط)
**الصفوف:** 6 (من الأول إلى السادس)

**التحديث الأخير:** 29 أكتوبر 2025
