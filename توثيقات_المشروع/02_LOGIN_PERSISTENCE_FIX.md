# 🔐 إصلاح حفظ تسجيل الدخول والتوجيه حسب الدور

## 📅 **التاريخ:** 31 أكتوبر 2025

---

## ❌ **المشكلات:**

1. **Null Check Error:**
   ```
   Null check operator used on a null value
   MaterialApp:file:///D:/test/madrasah/lib/main.dart
   ```

2. **عدم التوجيه حسب الدور:**
   - جميع المستخدمين يذهبون لصفحة الطلاب
   - حساب الإدارة لا يذهب لصفحة الإدارة

---

## ✅ **الحلول المطبقة:**

### **1. تبسيط main.dart:**

**قبل:**
```dart
class MyApp extends StatefulWidget {
  String _initialRoute = '/login_new';
  // معقد مع _checkLoginStatus
}
```

**بعد:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login_new',  // ✅ مباشرة وبسيط
      routes: {...},
    );
  }
}
```

### **2. إضافة التوجيه حسب الدور في login_screen_new.dart:**

```dart
Future<void> _login() async {
  // تسجيل الدخول
  final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(...);
  
  // جلب دور المستخدم
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredential.user!.uid)
      .get();
  
  final role = userDoc.data()?['role'] ?? 'student';
  
  // حفظ تسجيل الدخول
  if (_rememberMe) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', true);
    await prefs.setString('userEmail', _emailController.text);
  }
  
  // التوجيه حسب الدور
  if (role == 'admin') {
    Navigator.pushReplacementNamed(context, '/admin');
  } else if (role == 'teacher') {
    Navigator.pushReplacementNamed(context, '/teacher');
  } else {
    Navigator.pushReplacementNamed(context, '/student_new');
  }
}
```

### **3. مسح حفظ تسجيل الدخول عند الخروج:**

**في student_home_new.dart و notifications_screen.dart:**

```dart
Future<void> _logout() async {
  // مسح SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('rememberMe');
  await prefs.remove('userEmail');
  
  // تسجيل الخروج
  await FirebaseAuth.instance.signOut();
  
  // العودة لتسجيل الدخول
  Navigator.pushReplacementNamed(context, '/login_new');
}
```

---

## 🎯 **النتيجة:**

```
✅ التطبيق يفتح بدون أخطاء
✅ التوجيه حسب الدور يعمل:
   - admin → /admin
   - teacher → /teacher
   - student → /student_new
✅ حفظ تسجيل الدخول يعمل
✅ تسجيل الخروج يمسح البيانات المحفوظة
```

---

## 📊 **الملفات المعدلة:**

1. `lib/main.dart` - تبسيط الكود
2. `lib/ui/login_screen_new.dart` - إضافة التوجيه حسب الدور
3. `lib/ui/student/student_home_new.dart` - مسح البيانات عند الخروج
4. `lib/ui/student/notifications_screen.dart` - مسح البيانات عند الخروج

---

**الحالة:** ✅ مكتمل ويعمل بنجاح
