# إضافة حوار تأكيد تسجيل الخروج

**التاريخ:** 6 نوفمبر 2025  
**الحالة:** ✅ مكتمل  
**الإصدار:** v1.0.0+1

---

## 🎯 الهدف

إضافة حوار تأكيد عند الضغط على زر تسجيل الخروج في جميع صفحات التطبيق (معلم، إدارة، طالب) لتجنب تسجيل الخروج بالخطأ.

---

## 📋 التغييرات

### 1. صفحة المعلم

**الملف:** `lib/ui/teacher/teacher_home_complete.dart`

#### قبل التعديل:
```dart
IconButton(
  icon: const Icon(Icons.logout, color: Colors.red),
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login_new');
    }
  },
  tooltip: 'تسجيل الخروج',
),
```

#### بعد التعديل:
```dart
IconButton(
  icon: const Icon(Icons.logout, color: Colors.red),
  onPressed: () => _confirmLogout(context),
  tooltip: 'تسجيل الخروج',
),
```

#### دالة التأكيد الجديدة:
```dart
Future<void> _confirmLogout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'تسجيل الخروج',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login_new');
    }
  } catch (e) {
    print('خطأ في تسجيل الخروج: $e');
  }
}
```

---

### 2. صفحة الطالب

**الملف:** `lib/ui/student/student_home_complete.dart`

#### تم تحديث دالة `_logout()`:
```dart
Future<void> _logout() async {
  // عرض حوار التأكيد
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'تسجيل الخروج',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login_new',
        (route) => false,
      );
    }
  } catch (e) {
    print('خطأ في تسجيل الخروج: $e');
  }
}
```

---

### 3. صفحة الإدارة

**الملف:** `lib/ui/admin/admin_tabs_screen.dart`

✅ **كانت تحتوي بالفعل على حوار تأكيد** - لا تحتاج تعديل

---

### 4. صفحات الطالب الأخرى

**الملفات التالية تحتوي بالفعل على حوار تأكيد:**
- ✅ `lib/ui/student/student_home_new.dart`
- ✅ `lib/ui/student/notifications_screen.dart`

---

## 🎨 تصميم حوار التأكيد

### الخصائص:
- **العنوان:** "تسجيل الخروج" - خط عريض، محاذاة وسط
- **المحتوى:** "هل أنت متأكد من رغبتك في تسجيل الخروج؟" - محاذاة وسط
- **الشكل:** حواف دائرية (12px)
- **الأزرار:**
  - **إلغاء** - TextButton (رمادي)
  - **تسجيل الخروج** - ElevatedButton (أحمر مع نص أبيض)

---

## 📊 جدول الحالة

| الصفحة | الملف | الحالة قبل | الحالة بعد |
|-------|------|-----------|-----------|
| **المعلم** | `teacher_home_complete.dart` | ❌ بدون تأكيد | ✅ مع تأكيد |
| **الطالب** | `student_home_complete.dart` | ❌ بدون تأكيد | ✅ مع تأكيد |
| **الطالب** | `student_home_new.dart` | ✅ مع تأكيد | ✅ مع تأكيد |
| **الطالب** | `notifications_screen.dart` | ✅ مع تأكيد | ✅ مع تأكيد |
| **الإدارة** | `admin_tabs_screen.dart` | ✅ مع تأكيد | ✅ مع تأكيد |

---

## ✅ النتيجة

الآن **جميع صفحات** المعلم والإدارة والطالب تطلب تأكيد قبل تسجيل الخروج!

### الفوائد:
1. 🛡️ **حماية من الخروج بالخطأ**
2. 👤 **تجربة مستخدم أفضل**
3. ⚠️ **تحذير واضح قبل الخروج**
4. 🎨 **تصميم موحد عبر التطبيق**

---

## 🔄 الخطوات للاختبار

1. **تسجيل الدخول** كمعلم/إدارة/طالب
2. **اضغط على زر تسجيل الخروج** (أيقونة الخروج الحمراء)
3. ✅ **يظهر حوار التأكيد**
4. **اختر "إلغاء"** → يبقى في الصفحة
5. **اختر "تسجيل الخروج"** → يعود لصفحة تسجيل الدخول

---

## 📝 ملاحظات

- الحوار يمنع تسجيل الخروج العرضي
- التصميم موحد في جميع الصفحات
- الكود سهل الصيانة والتعديل
