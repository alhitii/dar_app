# 🔧 إصلاح مشكلة تسجيل الدخول

## 📅 **التاريخ:** 31 أكتوبر 2025

---

## ❌ **المشكلة:**

```
عند تسجيل دخول أي طالب:
- يتم فتح حساب واحد فقط: gg@codeira.com
- هذا الحساب غير موجود في النظام
- جميع الطلاب يدخلون لنفس الحساب
```

---

## 🔍 **السبب المحتمل:**

### **1. حساب وهمي في Firebase Auth:**
```
قد يكون هناك حساب gg@codeira.com محفوظ في:
- Firebase Authentication
- يتم استخدامه تلقائياً عند تسجيل الدخول
```

### **2. مشكلة في SharedPreferences:**
```
قد يكون البريد محفوظ في SharedPreferences
ويتم استخدامه تلقائياً
```

### **3. مشكلة في الكود:**
```
قد يكون هناك hardcoded email في مكان ما
```

---

## ✅ **الحلول:**

### **الحل 1: حذف الحساب من Firebase Console**

#### **الخطوات:**
```
1. افتح Firebase Console
2. اذهب إلى Authentication
3. ابحث عن gg@codeira.com
4. احذف الحساب نهائياً
```

#### **الرابط:**
```
https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication/users
```

---

### **الحل 2: مسح SharedPreferences**

#### **إضافة زر مسح البيانات:**
```dart
// في login_screen_new.dart
Future<void> _clearSavedData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('تم مسح البيانات المحفوظة')),
  );
}
```

---

### **الحل 3: تسجيل خروج شامل**

#### **إضافة دالة تسجيل خروج كامل:**
```dart
Future<void> _fullLogout() async {
  // 1. تسجيل خروج من Firebase
  await FirebaseAuth.instance.signOut();
  
  // 2. مسح SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // 3. العودة لصفحة تسجيل الدخول
  Navigator.pushReplacementNamed(context, '/login_new');
}
```

---

## 🔧 **التعديلات المطلوبة:**

### **1. إضافة زر "مسح البيانات" في شاشة تسجيل الدخول:**

```dart
// في login_screen_new.dart
TextButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم مسح جميع البيانات المحفوظة'),
        backgroundColor: Colors.green,
      ),
    );
  },
  child: const Text('مسح البيانات المحفوظة'),
)
```

---

### **2. التحقق من عدم وجود hardcoded email:**

```bash
# ابحث في جميع الملفات
grep -r "gg@codeira.com" lib/
grep -r "gg@" lib/
```

---

## 🧪 **خطوات التشخيص:**

### **1. فحص Firebase Auth:**
```
1. افتح Firebase Console
2. Authentication → Users
3. ابحث عن gg@codeira.com
4. إذا وجدته → احذفه
```

### **2. فحص Firestore:**
```
1. افتح Firebase Console
2. Firestore Database
3. Collection: users
4. ابحث عن email: gg@codeira.com
5. إذا وجدته → احذفه
```

### **3. فحص الكود:**
```dart
// ابحث في الكود عن:
- "gg@codeira.com"
- "gg@"
- hardcoded emails
```

### **4. مسح البيانات المحلية:**
```dart
// في التطبيق
final prefs = await SharedPreferences.getInstance();
print('Saved email: ${prefs.getString('userEmail')}');
await prefs.clear();
```

---

## 📊 **الفحص الشامل:**

### **الخطوة 1: فحص Firebase Auth**
```
Firebase Console → Authentication → Users

إذا وجدت gg@codeira.com:
✅ احذفه
✅ تأكد من عدم وجود حسابات مكررة
```

### **الخطوة 2: فحص Firestore**
```
Firebase Console → Firestore → users

إذا وجدت document بـ email: gg@codeira.com:
✅ احذفه
✅ تأكد من صحة بيانات الطلاب الآخرين
```

### **الخطوة 3: مسح البيانات المحلية**
```
في التطبيق:
1. افتح شاشة تسجيل الدخول
2. اضغط على زر "مسح البيانات المحفوظة"
3. أعد تشغيل التطبيق
```

### **الخطوة 4: اختبار تسجيل الدخول**
```
1. أنشئ حساب طالب جديد
2. سجل دخول بالحساب الجديد
3. تحقق من فتح الحساب الصحيح
4. تحقق من عرض البيانات الصحيحة
```

---

## 🔐 **التحقق من صحة تسجيل الدخول:**

### **إضافة Logging:**
```dart
Future<void> _login() async {
  // ...
  
  print('=== Login Debug ===');
  print('Email entered: ${_emailController.text}');
  print('Email used: $email');
  print('User UID: ${userCredential.user!.uid}');
  print('User role: ${userDoc.data()?['role']}');
  print('==================');
  
  // ...
}
```

---

## 📁 **الملفات للفحص:**

```
✅ lib/ui/login_screen_new.dart
   - تحقق من عدم وجود hardcoded email
   - تحقق من منطق تسجيل الدخول

✅ lib/main.dart
   - تحقق من _checkAuthState
   - تحقق من التوجيه الصحيح

✅ Firebase Console
   - Authentication: احذف gg@codeira.com
   - Firestore: احذف أي document بهذا البريد
```

---

## 🚨 **الحل السريع:**

### **1. حذف من Firebase Console:**
```
1. https://console.firebase.google.com
2. اختر المشروع
3. Authentication → Users
4. ابحث عن gg@codeira.com
5. اضغط على القائمة (⋮)
6. Delete account
7. تأكيد الحذف
```

### **2. مسح البيانات المحلية:**
```dart
// في أي مكان في التطبيق
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
await FirebaseAuth.instance.signOut();
```

### **3. إعادة تشغيل التطبيق:**
```bash
flutter clean
flutter run
```

---

## ✅ **التحقق من الإصلاح:**

```
1. احذف gg@codeira.com من Firebase
2. امسح SharedPreferences
3. أعد تشغيل التطبيق
4. أنشئ حساب طالب جديد
5. سجل دخول
6. ✅ يجب أن يفتح الحساب الصحيح
```

---

## 📊 **الوقاية من المشكلة:**

### **1. التحقق من البريد:**
```dart
// قبل تسجيل الدخول
if (email == 'gg@codeira.com') {
  throw Exception('حساب غير صالح');
}
```

### **2. Logging شامل:**
```dart
// في كل عملية تسجيل دخول
print('Login attempt: $email');
print('User UID: ${user.uid}');
print('User role: $role');
```

### **3. التحقق من Firestore:**
```dart
// بعد تسجيل الدخول
if (!userDoc.exists) {
  await FirebaseAuth.instance.signOut();
  throw Exception('الحساب غير موجود في النظام');
}
```

---

**الحالة:** ⚠️ يحتاج إصلاح يدوي  
**الحل:** حذف gg@codeira.com من Firebase Console  
**الأولوية:** عالية جداً
