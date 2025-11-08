# 🎨 دليل استخدام Material 3 Theme

## 🚀 البدء السريع

### استخدام الألوان:
```dart
// ✅ الطريقة الصحيحة
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'مرحباً',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)

// ❌ تجنب الألوان الثابتة
Container(
  color: Color(0xFF4A8FA9),  // لا تفعل هذا
)
```

### استخدام الأزرار:
```dart
// Filled Button (الأساسي)
FilledButton(
  onPressed: () {},
  child: Text('تسجيل الدخول'),
)

// Elevated Button
ElevatedButton(
  onPressed: () {},
  child: Text('إرسال'),
)

// Text Button
TextButton(
  onPressed: () {},
  child: Text('إلغاء'),
)

// Outlined Button
OutlinedButton(
  onPressed: () {},
  child: Text('تعديل'),
)
```

### استخدام البطاقات:
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          'العنوان',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'المحتوى',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  ),
)
```

### استخدام حقول الإدخال:
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'الاسم',
    hintText: 'أدخل اسمك',
    prefixIcon: Icon(Icons.person),
  ),
)
```

### استخدام التدرجات اللونية:
```dart
// تدرج Codeira
Container(
  decoration: BoxDecoration(
    gradient: Material3Theme.codeiraGradient,
    borderRadius: BorderRadius.circular(16),
  ),
)

// تدرج البطاقات
Container(
  decoration: BoxDecoration(
    gradient: Material3Theme.cardGradient,
    borderRadius: BorderRadius.circular(16),
  ),
)
```

## 🎨 ColorScheme

### الألوان المتاحة:
```dart
Theme.of(context).colorScheme.primary          // اللون الأساسي
Theme.of(context).colorScheme.secondary        // اللون الثانوي
Theme.of(context).colorScheme.surface          // خلفية البطاقات
Theme.of(context).colorScheme.error            // لون الأخطاء
Theme.of(context).colorScheme.onPrimary        // نص على الأساسي
Theme.of(context).colorScheme.onSurface        // نص على السطح
```

### Material 3 Surface Colors:
```dart
Theme.of(context).colorScheme.surfaceContainerLowest
Theme.of(context).colorScheme.surfaceContainerLow
Theme.of(context).colorScheme.surfaceContainer
Theme.of(context).colorScheme.surfaceContainerHigh
Theme.of(context).colorScheme.surfaceContainerHighest
```

## 📝 TextTheme

### أحجام النصوص:
```dart
Theme.of(context).textTheme.displayLarge      // 32sp
Theme.of(context).textTheme.displayMedium     // 28sp
Theme.of(context).textTheme.displaySmall      // 24sp
Theme.of(context).textTheme.headlineLarge     // 20sp
Theme.of(context).textTheme.headlineMedium    // 18sp
Theme.of(context).textTheme.titleLarge        // 16sp
Theme.of(context).textTheme.bodyLarge         // 16sp
Theme.of(context).textTheme.bodyMedium        // 14sp
Theme.of(context).textTheme.bodySmall         // 12sp
```

## 🎯 أمثلة عملية

### صفحة تسجيل الدخول:
```dart
Scaffold(
  body: Container(
    decoration: BoxDecoration(
      gradient: Material3Theme.codeiraGradient,
    ),
    child: Center(
      child: Card(
        margin: EdgeInsets.all(24),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تسجيل الدخول',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),
              FilledButton(
                onPressed: () {},
                child: Text('دخول'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
)
```

### قائمة بطاقات:
```dart
ListView.builder(
  padding: EdgeInsets.all(16),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          items[index].title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          items[index].subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
    );
  },
)
```

## 🌙 الوضع الداكن

### التبديل بين الأوضاع:
```dart
// في main.dart
MaterialApp(
  theme: Material3Theme.lightTheme,
  darkTheme: Material3Theme.darkTheme,
  themeMode: ThemeMode.system,  // تلقائي حسب النظام
  // أو
  themeMode: ThemeMode.light,   // فاتح دائماً
  // أو
  themeMode: ThemeMode.dark,    // داكن دائماً
)
```

## 💡 نصائح

### ✅ افعل:
- استخدم `Theme.of(context)` دائماً
- استخدم Material 3 widgets
- اتبع Material Design guidelines
- اختبر الثيم الداكن

### ❌ لا تفعل:
- لا تستخدم ألوان ثابتة
- لا تخلط بين Material 2 و Material 3
- لا تتجاهل accessibility
- لا تنسى RTL support

## 📚 مراجع

- [Material 3 Design](https://m3.material.io/)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [Google Fonts](https://fonts.google.com/)
- [Dynamic Color](https://pub.dev/packages/dynamic_color)
