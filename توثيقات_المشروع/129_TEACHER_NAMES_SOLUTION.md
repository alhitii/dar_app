# 🔧 حل مشكلة أسماء المعلمين

## 📅 **التاريخ:** 3 نوفمبر 2025

---

## ⚠️ **المشكلة المكتشفة:**

```
🔍 مادة: اللغة الإنجليزية, teacherName=null, teacherId=null, sections=null
⚠️ لا يوجد teacherName ولا teacherId لـ اللغة الإنجليزية
```

**السبب:**
```
❌ وثائق subjects في Firestore لا تحتوي على:
   - teacherName
   - teacherId
   - sections
```

---

## 🔍 **التحقق من Firestore:**

### **افتح Firebase Console:**
```
1. https://console.firebase.google.com/project/madrasa-570c9/firestore
2. افتح collection: subjects
3. افتح أي وثيقة
4. تحقق من الحقول الموجودة
```

### **الحقول المطلوبة:**
```json
{
  "name": "اللغة الإنجليزية",
  "emoji": "🇬🇧",
  "stage": "إعدادية",
  "grade": "الخامس",
  "branch": "علمي",
  "sections": ["أ", "ب"],
  "teacherId": "abc123",        // ← مفقود!
  "teacherName": "أحمد محمد"    // ← مفقود!
}
```

---

## ✅ **الحلول:**

### **الحل 1: تحديث يدوي (سريع)**

```
1. افتح Firebase Console
2. Firestore → subjects
3. لكل مادة:
   - أضف حقل: teacherName = "اسم المعلم"
   - أضف حقل: teacherId = "uid المعلم"
   - أضف حقل: sections = ["أ", "ب"]
```

---

### **الحل 2: من التطبيق (للمعلمين)**

```
1. كل معلم يسجل دخول
2. يذهب لصفحة المواد
3. يحدّث مواده
4. التطبيق يضيف teacherId و teacherName تلقائياً
```

**لكن:** هذا يتطلب تعديل كود التطبيق!

---

### **الحل 3: Firebase Function (تلقائي)**

```javascript
// دالة لتحديث جميع المواد
export const updateAllSubjectsWithTeachers = onCall(async (request) => {
  // جلب جميع المعلمين
  const teachersSnapshot = await db.collection('users')
    .where('role', '==', 'teacher')
    .get();
  
  // لكل معلم، تحديث مواده
  for (const teacherDoc of teachersSnapshot.docs) {
    const teacherData = teacherDoc.data();
    const teacherId = teacherDoc.id;
    const teacherName = teacherData.name;
    
    // تحديث المواد
    const subjectsSnapshot = await db.collection('subjects')
      .where('stage', '==', teacherData.stage)
      .where('grade', '==', teacherData.grade)
      .get();
    
    for (const subjectDoc of subjectsSnapshot.docs) {
      await subjectDoc.ref.update({
        teacherId: teacherId,
        teacherName: teacherName
      });
    }
  }
});
```

**لكن:** هذا معقد ويحتاج معرفة أي معلم يدرّس أي مادة!

---

## 🎯 **الحل الموصى به:**

### **تحديث يدوي من Firebase Console:**

```
1. افتح: https://console.firebase.google.com/project/madrasa-570c9/firestore
2. subjects collection
3. لكل مادة:
   
   اللغة الإنجليزية:
   + Add field: teacherName = "فاطمة علي"
   + Add field: teacherId = "xyz789"
   + Add field: sections = ["أ", "ب"]
   
   الرياضيات:
   + Add field: teacherName = "أحمد محمد"
   + Add field: teacherId = "abc123"
   + Add field: sections = ["أ"]
   
   ... وهكذا
```

---

## 📝 **بعد التحديث:**

### **اختبر التطبيق:**
```
1. أعد فتح التطبيق
2. سجل دخول كطالب
3. تحقق من Console:
   ✅ "✅ اسم المعلم من subjects: اللغة الإنجليزية → فاطمة علي"
   ✅ "✅ تم تحميل 10 اسم معلم من 10 مادة"
```

### **في التطبيق:**
```
✅ كل مادة تظهر "أ : [اسم المعلم]"
✅ لا يوجد "غير محدد"
```

---

## 🚀 **الخطوات التالية:**

```
1. حدّث subjects في Firestore يدوياً
2. أعد فتح التطبيق
3. تحقق من أسماء المعلمين
4. إذا ظهرت الأسماء ✅
5. ابنِ APK نهائي
```

---

**حدّث Firestore أولاً! 🔥**
