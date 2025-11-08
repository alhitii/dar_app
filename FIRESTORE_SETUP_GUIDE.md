# 🔧 إعداد Firestore للاختبار المؤقت

## 1️⃣ إنشاء Feature Flag يدوياً

### في Firebase Console:

```
1. افتح Firestore Database
2. اضغط "Start collection"
3. Collection ID: settings
4. Document ID: features
5. أضف Field:
   - Field: autoTestAllScopes
   - Type: boolean
   - Value: false (سيتم تفعيله من التطبيق)
6. اضغط Save
```

---

## 2️⃣ التحقق من Collections الأساسية

تأكد من وجود هذه Collections:

### ✅ subjects
```
Collection: subjects
Documents: يجب أن يحتوي على المواد
مثال:
  - math
  - arabic
  - science
  - english
```

### ✅ classes
```
Collection: classes
Documents: يجب أن يحتوي على الصفوف
مثال:
  - grade1
  - grade2
  - grade3
```

### ✅ sections
```
Collection: sections
Documents: يجب أن يحتوي على الشعب
مثال:
  - A
  - B
  - C
```

### ✅ users
```
Collection: users
Documents: المعلمون والإدارة
كل معلم يجب أن يحتوي على:
  - role: "teacher"
  - subjects: [array]
  - classes: [array]
  - sections: [array]
  - email: "..."
  - name: "..."
```

---

## 3️⃣ Security Rules (مهم جداً!)

### افتح Firebase Console → Firestore → Rules

الصق هذه القواعد:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // السماح للقراءة والكتابة للمستخدمين المصادقين
    match /settings/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /subjects/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /classes/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /sections/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /users_emails/{email} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    match /backups_users/{userId} {
      allow read: if request.auth != null && isAdmin();
      allow write: if request.auth != null && isAdmin();
    }
    
    match /logs/{logId} {
      allow read: if request.auth != null && isAdmin();
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
    
    // دالة التحقق من الإدارة
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

**ثم اضغط "Publish"**

---

## 4️⃣ اختبار الاتصال

### من التطبيق:

```dart
// في main.dart أو أي ملف
void testFirestoreConnection() async {
  try {
    // اختبار القراءة
    final subjects = await FirebaseFirestore.instance.collection('subjects').get();
    print('✅ عدد المواد: ${subjects.docs.length}');
    
    final classes = await FirebaseFirestore.instance.collection('classes').get();
    print('✅ عدد الصفوف: ${classes.docs.length}');
    
    final sections = await FirebaseFirestore.instance.collection('sections').get();
    print('✅ عدد الشعب: ${sections.docs.length}');
    
    final teachers = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .get();
    print('✅ عدد المعلمين: ${teachers.docs.length}');
    
    print('🎉 الاتصال ناجح!');
  } catch (e) {
    print('❌ خطأ: $e');
  }
}
```

---

## 5️⃣ مثال على بيانات التجربة

### إضافة معلم تجريبي:

```
Collection: users
Document ID: teacher1

{
  "role": "teacher",
  "name": "محمد أحمد",
  "email": "teacher@school.com",
  "subjects": ["math"],
  "classes": ["grade3"],
  "sections": ["A"],
  "stage": "ثانوي",
  "grade": "الثالث",
  "branch": "علمي",
  "createdAt": timestamp
}
```

### إضافة مواد:

```
Collection: subjects
Documents:
  - math (رياضيات)
  - arabic (عربي)
  - science (علوم)
  - english (إنجليزي)
```

### إضافة صفوف:

```
Collection: classes
Documents:
  - grade1 (الأول)
  - grade2 (الثاني)
  - grade3 (الثالث)
```

### إضافة شعب:

```
Collection: sections
Documents:
  - A
  - B
  - C
  - D
```

---

## 6️⃣ التحقق النهائي

### Checklist قبل التشغيل:

- [ ] ✅ Collection: settings/features موجودة
- [ ] ✅ Collection: subjects فيها بيانات
- [ ] ✅ Collection: classes فيها بيانات
- [ ] ✅ Collection: sections فيها بيانات
- [ ] ✅ Collection: users فيها معلمون
- [ ] ✅ Security Rules منشورة
- [ ] ✅ تم تسجيل الدخول كإدارة في التطبيق

---

## 🆘 حل المشاكل الشائعة

### المشكلة: "Permission Denied"
```
الحل: راجع Security Rules وتأكد من نشرها
```

### المشكلة: "Collection not found"
```
الحل: أنشئ الـ Collections يدوياً في Firebase Console
```

### المشكلة: "لا يوجد معلمون"
```
الحل: أضف معلم واحد على الأقل بـ role: "teacher"
```

### المشكلة: "autoTestAllScopes not found"
```
الحل: أنشئ settings/features يدوياً
```

---

**📌 بعد إكمال هذه الخطوات، جرّب التوسيع مرة أخرى!**
