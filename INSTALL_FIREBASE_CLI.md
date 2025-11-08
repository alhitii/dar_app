# 🔥 تثبيت Firebase CLI

## ❌ **المشكلة:**
```
firebase : The term 'firebase' is not recognized
```

---

## ✅ **الحل: تثبيت Firebase CLI**

### **الطريقة 1: باستخدام npm (الأسرع):**

#### **1. تحقق من وجود Node.js:**
```powershell
node --version
npm --version
```

إذا ظهرت الأرقام، انتقل للخطوة 2.
إذا لم تظهر، حمّل Node.js من: https://nodejs.org/

#### **2. ثبّت Firebase CLI:**
```powershell
npm install -g firebase-tools
```

#### **3. تحقق من التثبيت:**
```powershell
firebase --version
```

#### **4. سجل دخول:**
```powershell
firebase login
```

---

### **الطريقة 2: باستخدام Standalone Binary:**

#### **1. حمّل Firebase CLI:**
```powershell
# افتح PowerShell كـ Administrator
iwr -useb https://firebase.tools/bin/win/instant/latest -outfile firebase.exe
```

#### **2. انقل الملف لمجلد في PATH:**
```powershell
# مثلاً:
Move-Item firebase.exe C:\Windows\System32\
```

#### **3. تحقق:**
```powershell
firebase --version
```

---

## 🚀 **بعد التثبيت:**

### **1. سجل دخول:**
```powershell
firebase login
```

### **2. اذهب لمجلد functions:**
```powershell
cd d:\test\madrasah\functions
```

### **3. انشر Functions:**
```powershell
firebase deploy --only functions
```

---

## 🔍 **إذا كان Firebase مثبتاً بالفعل:**

### **قد يكون في مجلد npm global:**
```powershell
# ابحث عن مسار npm global
npm config get prefix
```

### **أضف المسار للـ PATH:**
1. ابحث عن "Environment Variables" في Windows
2. أضف مسار npm global للـ PATH
3. أعد فتح PowerShell

---

## 📝 **الأوامر الكاملة (بالترتيب):**

```powershell
# 1. تثبيت Firebase CLI
npm install -g firebase-tools

# 2. تسجيل الدخول
firebase login

# 3. الذهاب لمجلد functions
cd d:\test\madrasah\functions

# 4. نشر Functions
firebase deploy --only functions
```

---

## ⚠️ **ملاحظات:**

### **إذا واجهت خطأ في npm:**
```powershell
# جرب كـ Administrator
# انقر بيمين على PowerShell → Run as Administrator
npm install -g firebase-tools
```

### **إذا كان npm بطيء:**
```powershell
# استخدم yarn بدلاً من npm
npm install -g yarn
yarn global add firebase-tools
```

---

## 🎯 **التحقق من النجاح:**

بعد التثبيت، يجب أن تعمل هذه الأوامر:
```powershell
firebase --version
# يجب أن يظهر: 13.x.x أو أحدث

firebase login
# يجب أن يفتح المتصفح للتسجيل

firebase projects:list
# يجب أن يظهر: madrasa-570c9
```

---

## 🚀 **جاهز؟**

بعد تثبيت Firebase CLI:
```powershell
cd d:\test\madrasah\functions
firebase deploy --only functions
```

🎊 **ابدأ بتثبيت Firebase CLI الآن!** 🎊
