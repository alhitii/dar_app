# 🚀 نشر Cloud Functions - الخطوات

## ✅ **تم إضافة deleteUserCompletely!**

---

## 📝 **الخطوات:**

### **1. افتح PowerShell في مجلد functions:**
```powershell
cd d:\test\madrasah\functions
```

### **2. تسجيل الدخول لـ Firebase (إذا لم تكن مسجلاً):**
```powershell
firebase login
```

### **3. نشر Cloud Functions:**
```powershell
firebase deploy --only functions
```

أو لنشر دالة واحدة فقط:
```powershell
firebase deploy --only functions:deleteUserCompletely
```

---

## 🎯 **الدوال المتاحة الآن:**

```
1. ✅ autoCreateUser
2. ✅ syncTeacherSubjects
3. ✅ notifyStudentsOnHomework
4. ✅ notifyOnAnnouncement
5. ✅ notifyOnAbsence
6. ✅ deleteUserCompletely (جديد!)
7. ✅ deleteUser
8. ✅ testAbsenceNotification
```

---

## 🔥 **deleteUserCompletely:**

### **الوظيفة:**
- حذف من Firestore
- حذف البيانات المرتبطة (مواد المعلم / واجبات الطالب)
- حذف من Authentication
- تسجيل في Logs

### **Parameters:**
```javascript
{
  uid: string,      // معرف المستخدم
  role: string,     // الدور (teacher/student/admin)
  email: string     // البريد الإلكتروني
}
```

### **Response:**
```javascript
{
  success: true,
  message: "تم حذف xxx@gmail.com بنجاح من جميع الأنظمة"
}
```

---

## ⚡ **أوامر سريعة:**

### **نشر جميع Functions:**
```powershell
cd d:\test\madrasah\functions
firebase deploy --only functions
```

### **نشر دالة واحدة:**
```powershell
firebase deploy --only functions:deleteUserCompletely
```

### **عرض Logs:**
```powershell
firebase functions:log
```

### **عرض قائمة Functions:**
```powershell
firebase functions:list
```

---

## 🎊 **جاهز للنشر!**

افتح PowerShell واكتب:
```powershell
cd d:\test\madrasah\functions
firebase deploy --only functions
```

انتظر حتى ينتهي النشر، ثم جرب التطبيق!
