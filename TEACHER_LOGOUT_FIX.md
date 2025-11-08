# ✅ إصلاح أيقونة تسجيل الخروج للمعلم

## 📋 المشكلة الأصلية

**قبل الإصلاح:**
- ❌ أيقونة تسجيل الخروج كانت مباشرة في AppBar
- ❌ لا يوجد تأكيد قبل تسجيل الخروج
- ❌ لا توجد معلومات حساب

## ✅ الحل المُنفذ

### **1. تغيير الأيقونة**

**قبل:**
```dart
IconButton(
  tooltip: 'تسجيل الخروج',
  icon: Subject3DIcons.getSettingsIcon(size: 28),
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.login);
  },
)
```

**بعد:**
```dart
IconButton(
  tooltip: 'معلومات الحساب',
  icon: Icon(
    Icons.account_circle,
    size: 32,
    color: Color(0xFF4682B4),
  ),
  onPressed: () => _showAccountInfo(context),
)
```

---

### **2. إضافة Dialog معلومات الحساب**

**المحتوى:**
- ✅ الاسم
- ✅ البريد الإلكتروني
- ✅ المرحلة
- ✅ الصف
- ✅ الشعب

**الأزرار:**
- 🔘 إغلاق
- 🔴 تسجيل الخروج

**الكود:**
```dart
static void _showAccountInfo(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  
  // جلب بيانات المعلم من Firestore
  final emailDoc = await FirebaseFirestore.instance
      .collection('users_emails')
      .doc(user?.email?.toLowerCase())
      .get();
  
  // عرض معلومات الحساب
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row([
        Icon(Icons.account_circle),
        Text('معلومات الحساب'),
      ]),
      content: Column([
        _buildInfoRow(icon: Icons.person, label: 'الاسم', value: ...),
        _buildInfoRow(icon: Icons.email, label: 'البريد', value: ...),
        ...
      ]),
      actions: [
        TextButton('إغلاق'),
        ElevatedButton.icon('تسجيل الخروج'),
      ],
    ),
  );
}
```

---

### **3. إضافة تأكيد تسجيل الخروج**

**Dialog التأكيد:**
```dart
static void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row([
        Icon(Icons.warning_amber_rounded, color: Colors.orange),
        Text('تأكيد تسجيل الخروج'),
      ]),
      content: Text('هل أنت متأكد من تسجيل الخروج من حسابك؟'),
      actions: [
        TextButton('إلغاء'),
        ElevatedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(Routes.login);
          },
          icon: Icon(Icons.logout),
          label: Text('تسجيل الخروج'),
        ),
      ],
    ),
  );
}
```

---

## 🎯 سير العمل الجديد

### **الخطوة 1: ضغط أيقونة الحساب**
```
👤 Icons.account_circle (في AppBar)
    ↓
📋 Dialog معلومات الحساب
```

### **الخطوة 2: عرض المعلومات**
```
┌─────────────────────────────────┐
│ 👤 معلومات الحساب             │
├─────────────────────────────────┤
│ 👤 الاسم: أحمد محمد            │
│ 📧 البريد: teacher@school.com  │
│ 🏫 المرحلة: إعدادية            │
│ 📚 الصف: الصف الثالث           │
│ 👥 الشعب: أ, ب                │
├─────────────────────────────────┤
│      [إغلاق]  [🔴 تسجيل الخروج] │
└─────────────────────────────────┘
```

### **الخطوة 3: التأكيد**
```
ضغط "تسجيل الخروج"
    ↓
┌─────────────────────────────────┐
│ ⚠️  تأكيد تسجيل الخروج         │
├─────────────────────────────────┤
│ هل أنت متأكد من تسجيل          │
│ الخروج من حسابك؟               │
├─────────────────────────────────┤
│      [إلغاء]  [🔴 تسجيل الخروج] │
└─────────────────────────────────┘
```

---

## 🎨 التصميم

### **الألوان المستخدمة:**
```dart
Primary Color:   Color(0xFF4682B4)  // Steel Blue
Background:      Color(0xFFF0F8FF)  // Alice Blue
Text Dark:       Color(0xFF2F4F4F)  // Dark Slate Gray
Logout Button:   Colors.red
Warning Icon:    Colors.orange
```

### **الأيقونات:**
```dart
Account:         Icons.account_circle
Person:          Icons.person
Email:           Icons.email
School:          Icons.school
Class:           Icons.class_
Group:           Icons.group
Logout:          Icons.logout
Warning:         Icons.warning_amber_rounded
```

---

## 📱 معاينة الواجهة

### **AppBar:**
```
┌─────────────────────────────────────────┐
│  ثانوية دار السلام للبنات              │
│                    🔔  👤               │
└─────────────────────────────────────────┘
         (إشعارات)  (حساب)
```

### **Dialog معلومات الحساب:**
```
┌─────────────────────────────────────────┐
│ 👤 معلومات الحساب                      │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 👤  الاسم                           │ │
│ │     أحمد محمد                       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📧  البريد الإلكتروني              │ │
│ │     teacher@school.com              │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🏫  المرحلة                         │ │
│ │     إعدادية                         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📚  الصف                            │ │
│ │     الصف الثالث                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 👥  الشعب                           │ │
│ │     أ, ب                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
├─────────────────────────────────────────┤
│               [إغلاق]  [🔴 تسجيل الخروج]│
└─────────────────────────────────────────┘
```

### **Dialog تأكيد الخروج:**
```
┌─────────────────────────────────────────┐
│ ⚠️  تأكيد تسجيل الخروج                 │
├─────────────────────────────────────────┤
│                                         │
│ هل أنت متأكد من تسجيل الخروج           │
│ من حسابك؟                               │
│                                         │
├─────────────────────────────────────────┤
│               [إلغاء]  [🔴 تسجيل الخروج]│
└─────────────────────────────────────────┘
```

---

## 🧪 الاختبار

### **السيناريو 1: عرض معلومات الحساب**
1. ✅ سجّل دخول كمعلم
2. ✅ اضغط أيقونة 👤 في AppBar
3. ✅ تحقق من ظهور Dialog
4. ✅ تحقق من عرض جميع المعلومات
5. ✅ اضغط "إغلاق" → يُغلق Dialog

### **السيناريو 2: تسجيل الخروج مع تأكيد**
1. ✅ افتح معلومات الحساب
2. ✅ اضغط "تسجيل الخروج"
3. ✅ تحقق من ظهور dialog التأكيد
4. ✅ اضغط "إلغاء" → العودة لمعلومات الحساب
5. ✅ اضغط "تسجيل الخروج" مرة أخرى
6. ✅ اضغط "تسجيل الخروج" في التأكيد
7. ✅ تحقق من الانتقال لصفحة تسجيل الدخول

### **السيناريو 3: معلومات ناقصة**
1. ✅ معلم بدون مرحلة/صف
2. ✅ تحقق من عدم ظهور الحقول الفارغة
3. ✅ تحقق من ظهور "غير متوفر" للبيانات الأساسية

---

## 📝 ملاحظات تقنية

### **1. جلب البيانات:**
```dart
// من users_emails collection
final emailDoc = await FirebaseFirestore.instance
    .collection('users_emails')
    .doc(teacherEmail?.toLowerCase())
    .get();
```

### **2. معالجة الحقول الاختيارية:**
```dart
if (teacherStage != null) {
  _buildInfoRow(label: 'المرحلة', value: teacherStage);
}
```

### **3. معالجة القوائم:**
```dart
if (teacherSections != null && teacherSections.isNotEmpty) {
  value: teacherSections.join(', ')
}
```

---

## ✅ قائمة التحقق

- [x] تغيير الأيقونة من Settings إلى Account Circle
- [x] إضافة Dialog معلومات الحساب
- [x] عرض جميع معلومات المعلم
- [x] زر تسجيل الخروج داخل Dialog
- [x] Dialog تأكيد تسجيل الخروج
- [x] تصميم جميل ومتناسق
- [x] معالجة البيانات الناقصة
- [x] ألوان موحدة
- [x] أيقونات واضحة

---

## 🎨 الملف المُعدّل

**الملف:** `lib/ui/teacher/home_screen.dart`

**الدوال المُضافة:**
1. `_showAccountInfo()` - عرض معلومات الحساب
2. `_buildInfoRow()` - بناء صف معلومات
3. `_showLogoutConfirmation()` - تأكيد تسجيل الخروج

**التعديلات:**
- تغيير IconButton في AppBar (السطر 64-76)
- إضافة 3 دوال جديدة (السطر 1078-1330)

---

## 🎉 النتيجة النهائية

### **قبل:**
```
AppBar: [🔔] [⚙️ تسجيل الخروج مباشر]
              ↓
        تسجيل خروج فوري بدون تأكيد
```

### **بعد:**
```
AppBar: [🔔] [👤 معلومات الحساب]
              ↓
        Dialog معلومات
              ↓
        زر تسجيل الخروج
              ↓
        Dialog تأكيد
              ↓
        تسجيل الخروج
```

---

**الحالة:** ✅ **مُكتمل وجاهز للاستخدام**

**آخر تحديث:** 2025-01-25
