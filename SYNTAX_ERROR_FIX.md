# 🔧 إصلاح أخطاء الأقواس في admin_tabs_screen.dart

## ❌ **المشكلة:**
خطأ في الأقواس في السطر 649: `Can't find ')' to match '('`

## 🔍 **السبب:**
عند إضافة Container للتبويبات، لم يتم إغلاق جميع الأقواس بشكل صحيح

## ✅ **الحل:**
يجب إصلاح جميع التبويبات لتتبع هذا النمط:

```dart
class _SomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEFBFF),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // المحتوى
          ],
        ), // إغلاق ListView
      ), // إغلاق Padding
    ); // إغلاق Container
  }
}
```

## 🚨 **التبويبات التي تحتاج إصلاح:**
1. _CreateAbsenceTab - نقص قوس إغلاق ListView
2. _AdminAlertTab - نقص قوس إغلاق ListView

## 🔧 **الإصلاح المطلوب:**
إضافة الأقواس المفقودة لجميع التبويبات
