# 🔧 إصلاح خطأ تعديل المعلم

## ❌ الخطأ الأصلي

```
No document to update: 
Projects/madrasa-570c9/databases/(default)/documents/users/1761284440212 
[cloud_firestore/not-found]
```

---

## 🔍 السبب الجذري

### **المشكلة:**
المعلمون يتم حفظهم في `teachers` collection، لكن كود التعديل كان يحاول التحديث في `users` collection!

### **التفاصيل:**

#### **عند إنشاء معلم** (`firebase_user_service.dart`):
```dart
// يتم الحفظ في teachers collection
await _firestore.collection('teachers').doc(teacherId).set({
  ...teacherData,
  'teacherId': teacherId,
});

// وأيضاً في users_emails للبحث
await _firestore.collection('users_emails').doc(email).set(teacherData);
```

#### **عند التعديل** (الكود القديم):
```dart
// ❌ خطأ: يحاول التحديث في users (غير موجود!)
await FirebaseFirestore.instance.collection('users').doc(teacherId).update({
  ...
});
```

---

## ✅ الإصلاح المُنفذ

### **الملف:** `lib/ui/admin/edit_teacher_dialog.dart`

### **التغييرات:**

#### **1. استخدام `teachers` collection بدلاً من `users`:**

```dart
// ✅ صحيح
await FirebaseFirestore.instance
    .collection('teachers')  // ← تم التغيير
    .doc(teacherId)
    .update(updatedData);
```

#### **2. إضافة دعم تغيير البريد الإلكتروني:**

```dart
// إذا تغير البريد، حذف السجل القديم
final oldEmail = widget.teacher['email']?.toString().toLowerCase() ?? '';

if (oldEmail != email && oldEmail.isNotEmpty) {
  await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(oldEmail)
      .delete();
}

// إنشاء/تحديث السجل الجديد
await FirebaseFirestore.instance
    .collection('users_emails')
    .doc(email)
    .set({
  ...updatedData,
  'uid': teacherId,
  'teacherId': teacherId,
  'role': 'teacher',
  'isActive': true,
}, SetOptions(merge: true));
```

#### **3. التحقق من وجود `teacherId`:**

```dart
final teacherId = widget.teacher['teacherId'] ?? widget.teacher['id'];
if (teacherId == null) {
  throw Exception('معرف المعلم غير موجود');
}
```

---

## 📊 Collections المستخدمة

| Collection | الاستخدام | Document ID |
|-----------|-----------|-------------|
| `teachers` | **البيانات الرئيسية** | timestamp (مثل: 1761284440212) |
| `users_emails` | **البحث بالبريد** | email@example.com |
| ~~`users`~~ | ❌ غير مستخدم للمعلمين | - |

---

## 🧪 الاختبار

### **قبل الإصلاح:**
```
❌ خطأ: No document to update
❌ التعديل فاشل
```

### **بعد الإصلاح:**
```
✅ تم تحديث في teachers collection
✅ تم تحديث في users_emails collection
✅ رسالة نجاح: "تم تحديث بيانات المعلم بنجاح"
```

---

## 🎯 الخلاصة

### ✅ **ما تم إصلاحه:**
- [x] تغيير collection من `users` إلى `teachers`
- [x] دعم تغيير البريد الإلكتروني
- [x] التحقق من وجود teacherId
- [x] تحديث في كلا collections

### 📝 **ملاحظات مهمة:**

1. **المعلمون يُحفظون في `teachers` وليس `users`**
2. **`users_emails` للبحث والتسجيل فقط**
3. **teacherId هو timestamp (milliseconds)**

---

## 🚀 الاستخدام الآن

1. افتح لوحة الإدارة
2. تبويب "المعلمين"
3. اضغط ⋮ → "تعديل"
4. عدّل البيانات
5. اضغط "حفظ التغييرات"
6. ✅ **يعمل بنجاح!**

---

**الحالة:** ✅ **تم الإصلاح**
**التاريخ:** 2025-01-25
