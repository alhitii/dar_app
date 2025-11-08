# 🪟 إعداد أيقونة Windows

## 📅 **التاريخ:** 3 نوفمبر 2025

---

## 🎯 **الهدف:**

```
تغيير أيقونة تطبيق Windows من أيقونة Flutter الافتراضية
إلى أيقونة مدرسة دار السلام
```

---

## 📁 **الملفات المطلوبة:**

### **1. الأيقونة الحالية:**
```
المسار: android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
الحجم: 192x192 px
النوع: PNG
```

### **2. الأيقونة المطلوبة:**
```
المسار: windows/runner/resources/app_icon.ico
النوع: ICO (Windows Icon)
الأحجام: 16, 32, 48, 64, 128, 256 px
```

---

## 🔧 **طريقة التحويل:**

### **الطريقة 1: استخدام موقع online (الأسهل)**

1. **افتح الموقع:**
   ```
   https://convertio.co/png-ico/
   أو
   https://www.icoconverter.com/
   ```

2. **ارفع الملف:**
   ```
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

3. **اختر الأحجام:**
   ```
   ✅ 16x16
   ✅ 32x32
   ✅ 48x48
   ✅ 64x64
   ✅ 128x128
   ✅ 256x256
   ```

4. **حمّل الملف:**
   ```
   احفظ باسم: app_icon.ico
   ```

5. **استبدل الملف:**
   ```
   انسخ app_icon.ico إلى:
   windows/runner/resources/app_icon.ico
   ```

---

### **الطريقة 2: استخدام ImageMagick**

```bash
# تثبيت ImageMagick أولاً
# ثم:
magick convert android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -define icon:auto-resize=256,128,64,48,32,16 windows/runner/resources/app_icon.ico
```

---

### **الطريقة 3: استخدام PowerShell (Windows)**

```powershell
# تشغيل السكريبت الموجود:
.\create_windows_icon.ps1
```

---

## ✅ **التحقق:**

### **1. تحقق من وجود الملف:**
```
windows/runner/resources/app_icon.ico
```

### **2. ابنِ تطبيق Windows:**
```bash
flutter build windows --release
```

### **3. تحقق من الأيقونة:**
```
build/windows/x64/runner/Release/madrasah.exe
```

---

## 📝 **ملاحظات:**

```
1. الأيقونة يجب أن تكون بصيغة .ico
2. يجب أن تحتوي على أحجام متعددة
3. الملف يجب أن يكون في:
   windows/runner/resources/app_icon.ico
4. بعد التغيير، قم ببناء التطبيق من جديد
```

---

## 🚀 **الخطوات السريعة:**

```
1. افتح: https://convertio.co/png-ico/
2. ارفع: android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
3. حوّل إلى ICO
4. حمّل الملف
5. استبدل: windows/runner/resources/app_icon.ico
6. ابنِ: flutter build windows --release
7. ✅ الأيقونة الجديدة جاهزة!
```

---

**استخدم الطريقة 1 (الموقع) - الأسهل والأسرع! 🚀**
