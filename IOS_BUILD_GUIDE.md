# 📱 دليل بناء التطبيق لـ iOS

## 🎯 الوضع الحالي

**البيئة:** Windows ✅
**المطلوب:** بناء iOS 🍎
**المشكلة:** iOS يتطلب macOS ❌

---

## ⚡ الحل السريع (بدون Mac)

### **الخيار 1: Codemagic (موصى به)**

#### **الخطوات:**

1. **التسجيل:**
   - اذهب إلى [codemagic.io](https://codemagic.io)
   - سجّل بحساب GitHub/GitLab

2. **رفع المشروع:**
   ```bash
   # إنشاء repository
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/username/madrasah.git
   git push -u origin main
   ```

3. **إعداد Workflow:**
   - اختر "Flutter App"
   - حدد iOS
   - اختر "Release" build
   - شغّل البناء

4. **تحميل IPA:**
   - بعد اكتمال البناء
   - حمّل ملف `.ipa`

**المميزات:**
- ✅ مجاني (500 دقيقة/شهر)
- ✅ سهل الاستخدام
- ✅ دعم Flutter مدمج

---

### **الخيار 2: GitHub Actions (مجاني)**

**تم إنشاء الملف:** `.github/workflows/ios-build.yml`

#### **الخطوات:**

1. **رفع المشروع لـ GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Add iOS build workflow"
   git remote add origin https://github.com/username/madrasah.git
   git push -u origin main
   ```

2. **تفعيل Actions:**
   - اذهب إلى GitHub → Actions
   - سيبدأ البناء تلقائياً

3. **تحميل الناتج:**
   - بعد اكتمال البناء
   - تبويب "Artifacts"
   - حمّل `ios-build`

**المميزات:**
- ✅ مجاني تماماً (2000 دقيقة/شهر)
- ✅ يعمل مع كل push
- ✅ سهل الإعداد

---

### **الخيار 3: Flutter Web (للتجربة)**

#### **البناء:**
```bash
flutter build web --release
```

#### **النشر:**
```bash
# على Firebase Hosting (مجاني)
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy

# أو على GitHub Pages
# أو على Netlify
```

**الوصول:**
- يعمل على Safari (iOS)
- يعمل على أي متصفح
- رابط واحد لجميع المنصات

---

## 📋 متطلبات App Store (للنشر)

### **1. Apple Developer Account**
- التكلفة: **$99/سنة**
- التسجيل: [developer.apple.com](https://developer.apple.com)

### **2. شهادات التوقيع**
```
يتطلب macOS لإنشاء:
- Development Certificate
- Distribution Certificate
- Provisioning Profile
```

### **3. App Store Connect**
- رفع IPA
- ملء معلومات التطبيق
- لقطات الشاشة
- الوصف والكلمات المفتاحية

---

## 🔧 إعداد iOS في المشروع (جاهز)

### **ملفات iOS موجودة:**
```
ios/
├── Runner/
│   ├── Info.plist          ✅
│   ├── Assets.xcassets/    ✅
│   └── ...
├── Runner.xcodeproj/       ✅
└── Podfile                 ✅
```

### **التعديلات المطلوبة (عند التوفر Mac):**

#### **أ. Bundle Identifier:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourcompany.madrasah</string>
```

#### **ب. اسم التطبيق:**
```xml
<key>CFBundleName</key>
<string>ثانوية دار السلام</string>

<key>CFBundleDisplayName</key>
<string>دار السلام</string>
```

#### **ج. الأيقونة:**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
- يجب إضافة صور بأحجام مختلفة
- استخدم أداة: appicon.co
```

#### **د. صلاحيات:**
```xml
<key>NSCameraUsageDescription</key>
<string>لتصوير الواجبات</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>لإرفاق الصور</string>
```

---

## 🎯 خطة العمل الموصى بها

### **المرحلة 1: الاختبار (الآن - بدون Mac)**
```
1. ✅ بناء Web version
   flutter build web
   
2. ✅ استخدام Codemagic لبناء iOS
   - تسجيل
   - ربط GitHub
   - بناء
   
3. ✅ اختبار على أجهزة iOS
   - عبر Web version
   - أو تثبيت IPA من Codemagic
```

### **المرحلة 2: النشر (عند توفر Mac)**
```
1. ⏳ شراء Apple Developer ($99)
2. ⏳ إعداد Certificates على Mac
3. ⏳ بناء Release IPA
4. ⏳ رفع على App Store Connect
5. ⏳ مراجعة Apple
6. ⏳ النشر
```

---

## 🆘 الدعم والمساعدة

### **للاختبار الآن:**
```bash
# 1. بناء Web
flutter build web

# 2. تشغيل محلي
cd build/web
python -m http.server 8000

# 3. فتح على iPhone/iPad
# افتح Safari واذهب إلى:
# http://[your-computer-ip]:8000
```

### **للبناء عبر Cloud:**
1. **Codemagic:**
   - [codemagic.io](https://codemagic.io)
   - دليل: [docs.codemagic.io/flutter](https://docs.codemagic.io/flutter)

2. **GitHub Actions:**
   - الملف موجود: `.github/workflows/ios-build.yml`
   - ارفع على GitHub وسيعمل تلقائياً

---

## ✅ الخلاصة

### **ما يمكنك فعله الآن (بدون Mac):**
- ✅ بناء Web version
- ✅ استخدام Codemagic/GitHub Actions
- ✅ اختبار على أجهزة iOS عبر الويب
- ✅ بناء IPA بدون توقيع (للتجربة)

### **ما يحتاج Mac:**
- ❌ بناء IPA موقّع
- ❌ رفع على App Store
- ❌ اختبار محلي على iOS Simulator

### **الحل الأمثل:**
```
1. استخدم Codemagic الآن (مجاناً)
2. عند الجدية بالنشر، احصل على:
   - Mac (أو استئجر)
   - Apple Developer Account
```

---

## 📚 موارد مفيدة

- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos)
- [Codemagic Docs](https://docs.codemagic.io)
- [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)

---

**آخر تحديث:** 2025-01-25
**الحالة:** ✅ جاهز للبناء عبر Cloud
