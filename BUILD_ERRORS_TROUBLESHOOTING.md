# 🔧 دليل حل مشاكل البناء (Build Errors)

## ❌ المشكلة الحالية

```
cmake -E tar: error: ZIP decompression failed (-5)
LINK : fatal error LNK1104: cannot open file 'madrasah.exe'
```

---

## 🎯 الأسباب الشائعة

### **1. ملف .exe مقفول**
```
السبب: التطبيق لا يزال قيد التشغيل
الحل: إغلاق التطبيق أو قتل العملية
```

### **2. مكافح الفيروسات**
```
السبب: Antivirus يمنع الوصول للملف
الحل: إضافة استثناء أو إيقاف مؤقت
```

### **3. ملفات Firebase SDK تالفة**
```
السبب: فشل تحميل أو استخراج SDK
الحل: حذف وإعادة التحميل
```

### **4. مجلد build تالف**
```
السبب: عملية بناء سابقة فشلت
الحل: حذف مجلد build كامل
```

---

## ✅ الحلول خطوة بخطوة

### **الحل 1: التنظيف الكامل** (الأكثر فعالية)

#### **PowerShell:**

```powershell
# 1. قتل أي عملية madrasah
taskkill /F /IM madrasah.exe
# (تجاهل إذا ظهر "not found")

# 2. حذف مجلد build
Remove-Item -Path build -Recurse -Force -ErrorAction SilentlyContinue

# 3. flutter clean
flutter clean

# 4. flutter pub get
flutter pub get

# 5. إعادة البناء
flutter run -d windows
```

#### **CMD:**

```cmd
taskkill /F /IM madrasah.exe
rmdir /S /Q build
flutter clean
flutter pub get
flutter run -d windows
```

---

### **الحل 2: حذف Firebase SDK المستخرج**

إذا استمرت مشكلة ZIP decompression:

```powershell
# حذف مجلد Firebase SDK المستخرج
Remove-Item -Path "build\windows\x64\extracted\firebase_cpp_sdk_windows" -Recurse -Force -ErrorAction SilentlyContinue

# إعادة البناء
flutter run -d windows
```

---

### **الحل 3: إيقاف مكافح الفيروسات مؤقتاً**

#### **Windows Defender:**

```
1. Settings → Update & Security → Windows Security
2. Virus & threat protection
3. Manage settings
4. Turn off Real-time protection (مؤقتاً)
5. أعد البناء
6. أعد تشغيل الحماية
```

#### **إضافة استثناء (أفضل):**

```
1. Windows Security → Virus & threat protection
2. Manage settings → Exclusions
3. Add or remove exclusions
4. Add an exclusion → Folder
5. أضف: D:\test\madrasah
```

---

### **الحل 4: تشغيل VS كمسؤول**

إذا كنت تستخدم Visual Studio:

```
1. أغلق VS Code
2. افتح VS Code as Administrator
3. أعد فتح المشروع
4. flutter run -d windows
```

---

### **الحل 5: حذف .dart_tool**

```powershell
Remove-Item -Path .dart_tool -Recurse -Force
Remove-Item -Path .flutter-plugins -Force -ErrorAction SilentlyContinue
Remove-Item -Path .flutter-plugins-dependencies -Force -ErrorAction SilentlyContinue

flutter pub get
flutter run -d windows
```

---

## 🔍 تشخيص المشكلة

### **تحقق من العمليات الجارية:**

```powershell
# البحث عن madrasah.exe
Get-Process | Where-Object {$_.Name -like "*madrasah*"}

# إذا وُجد، اقتله:
Stop-Process -Name madrasah -Force
```

### **تحقق من الملف المقفول:**

```powershell
# تحقق من وجود الملف
Test-Path "build\windows\x64\runner\Debug\madrasah.exe"

# إذا كان موجوداً، احذفه:
Remove-Item "build\windows\x64\runner\Debug\madrasah.exe" -Force
```

### **تحقق من مساحة القرص:**

```powershell
Get-PSDrive D | Select-Object Used,Free
```

---

## 🆘 إذا فشلت جميع الحلول

### **1. إعادة تثبيت Flutter**

```powershell
flutter doctor -v
flutter upgrade
flutter clean
```

### **2. حذف المشروع وإعادة Clone**

```powershell
cd D:\test
Remove-Item madrasah -Recurse -Force
git clone <repo-url> madrasah
cd madrasah
flutter pub get
flutter run -d windows
```

### **3. إعادة تشغيل الكمبيوتر**

أحياناً الملفات تبقى مقفلة في الذاكرة:

```
1. حفظ كل العمل
2. إعادة تشغيل Windows
3. flutter clean
4. flutter run -d windows
```

---

## 📊 رسائل الخطأ الشائعة

### **Error 1: ZIP decompression failed**

```
السبب:
- اتصال الإنترنت انقطع أثناء التحميل
- الملف المحمّل تالف
- مشكلة في cmake

الحل:
1. حذف: build/windows/x64/extracted/
2. إعادة البناء
```

### **Error 2: LNK1104: cannot open file**

```
السبب:
- الملف مفتوح في عملية أخرى
- مكافح الفيروسات يحجب الملف
- صلاحيات غير كافية

الحل:
1. taskkill /F /IM madrasah.exe
2. حذف build
3. إعادة البناء
```

### **Error 3: MSB3073**

```
السبب:
- فشل أمر CMake
- ملفات مفقودة

الحل:
1. flutter clean
2. حذف build
3. إعادة البناء
```

---

## ✅ الحل السريع (All-in-One)

```powershell
# سكربت واحد لحل معظم المشاكل

# 1. قتل العمليات
Get-Process | Where-Object {$_.Name -like "*madrasah*"} | Stop-Process -Force

# 2. حذف كل شيء
Remove-Item -Path build -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path .dart_tool -Recurse -Force -ErrorAction SilentlyContinue

# 3. تنظيف Flutter
flutter clean

# 4. إعادة التبعيات
flutter pub get

# 5. البناء
flutter run -d windows
```

**احفظ هذا السكربت في ملف `fix-build.ps1` واستخدمه عند الحاجة!**

---

## 🔄 الوقاية

### **نصائح لتجنب المشاكل:**

```
✅ أغلق التطبيق قبل flutter run جديد
✅ استخدم Hot Restart (R) بدلاً من إعادة التشغيل الكامل
✅ أضف مجلد المشروع لاستثناءات مكافح الفيروسات
✅ نظّف بـ flutter clean إذا غيّرت التبعيات
✅ لا تحذف ملفات من build يدوياً أثناء التشغيل
```

---

## 📝 ملاحظات مهمة

### **Windows Defender:**

```
غالباً ما يعتبر madrasah.exe ملف مشبوه لأنه:
- يُبنى محلياً
- يُعدّل باستمرار
- يتصل بالإنترنت (Firebase)

الحل: أضف استثناء دائم
```

### **Visual Studio Build Tools:**

```
تأكد من تثبيت:
- Visual Studio 2022 (أو 2019)
- Desktop development with C++
- Windows 10/11 SDK

تحقق بـ:
flutter doctor -v
```

### **CMake:**

```
إذا استمرت مشاكل CMake:

1. افتح Visual Studio Installer
2. Modify → Individual Components
3. ابحث عن "CMake"
4. تأكد من اختيار:
   - CMake tools for Windows
   - C++ CMake tools for Windows
```

---

## 🎯 Checklist استكشاف الأخطاء

```
☐ أغلقت التطبيق
☐ حذفت مجلد build
☐ شغّلت flutter clean
☐ شغّلت flutter pub get
☐ أعدت المحاولة
☐ أضفت استثناء لمكافح الفيروسات
☐ حذفت firebase_cpp_sdk_windows
☐ أعدت تشغيل الكمبيوتر
☐ تحققت من flutter doctor
```

---

**✅ في معظم الحالات، الحل السريع (All-in-One) يحل المشكلة!**
