# 🎓 نظام إدارة حسابات الطلاب - ثانوية دار السلام للبنات

## ✅ **تم الإنجاز**

### **الصفحات المنشأة:**

```
1. ✅ lib/ui/admin/students_list_screen.dart
2. ✅ lib/ui/admin/student_details_screen.dart
3. ✅ lib/ui/admin/send_absence_screen.dart
4. ✅ lib/ui/admin/absence_history_screen.dart
```

---

## 📱 **1. صفحة قائمة الطلاب** (`students_list_screen.dart`)

### **الميزات:**

#### **شريط البحث:**
```dart
✅ البحث بالاسم
✅ البحث بالبريد الإلكتروني
✅ تحديث فوري (real-time)
✅ أيقونة بحث
✅ تصميم Material 3
```

#### **قائمة الطلاب:**
```dart
✅ تحميل من Firestore
✅ ترتيب أبجدي
✅ StreamBuilder (تحديث مباشر)
✅ عرض:
   - الاسم
   - البريد الإلكتروني
   - الصف
   - الشعبة
✅ أيقونة دائرية بأول حرف من الاسم
✅ تدرج أزرق للأيقونة
```

#### **بطاقة الطالب:**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [...],
  ),
  child: Row(
    children: [
      // أيقونة دائرية بتدرج
      Container(gradient: [...]),
      
      // معلومات الطالب
      Column(
        children: [
          Text(name),
          Text(email),
          Row([
            Chip(الصف),
            Chip(الشعبة),
          ]),
        ],
      ),
      
      // سهم
      Icon(arrow_back_ios),
    ],
  ),
)
```

#### **الحالات الفارغة:**
```dart
✅ لا يوجد طلاب: أيقونة + رسالة
✅ لا توجد نتائج بحث: رسالة واضحة
✅ خطأ في التحميل: رسالة خطأ
```

---

## 📋 **2. صفحة معلومات الطالب** (`student_details_screen.dart`)

### **الميزات:**

#### **بطاقة الطالب:**
```dart
Container(
  gradient: LinearGradient([
    Color(0xFF4DD0E1),
    Color(0xFF26C6DA),
  ]),
  child: Column([
    // أيقونة دائرية بيضاء
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(firstLetter),
    ),
    
    // الاسم
    Text(name, fontSize: 24, bold),
    
    // البريد
    Text(email),
    
    // الصف والشعبة
    Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
      ),
      child: Row([
        Icon(school),
        Text('$grade - $section'),
      ]),
    ),
  ]),
)
```

#### **الأزرار:**

**1. إرسال إشعار غياب (أحمر):**
```dart
✅ لون أحمر
✅ أيقونة notifications_active
✅ ظل أحمر
✅ ارتفاع 60
✅ ينتقل لصفحة إرسال الغياب
```

**2. سجل الغيابات (أزرق):**
```dart
✅ لون أزرق (#2E5C8A)
✅ أيقونة history
✅ ظل أزرق
✅ ارتفاع 60
✅ ينتقل لصفحة سجل الغيابات
```

---

## 📨 **3. صفحة إرسال إشعار الغياب** (`send_absence_screen.dart`)

### **الميزات:**

#### **بطاقة معلومات الطالب:**
```dart
Container(
  color: Color(0xFFFFF0F0),  // وردي فاتح
  border: Border.all(color: Colors.red[200]),
  child: Column([
    Text('إرسال إشعار غياب إلى:'),
    Text(studentName, fontSize: 20, bold, red),
    Text('$grade - $section'),
  ]),
)
```

#### **اختيار تاريخ الغياب:**
```dart
✅ DatePicker عربي
✅ تنسيق: dd/MM/yyyy
✅ أيقونة تقويم
✅ خلفية بيضاء
✅ حدود زرقاء فاتحة
```

#### **حقل رسالة الغياب:**
```dart
TextFormField(
  maxLines: 5,
  textAlign: TextAlign.right,
  decoration: InputDecoration(
    hintText: 'اكتب رسالة الغياب هنا...',
    filled: true,
    fillColor: Color(0xFFF8F9FF),
  ),
  validator: (value) {
    if (value.isEmpty) return 'الرجاء كتابة رسالة الغياب';
  },
)
```

#### **ملاحظة:**
```dart
Container(
  color: Colors.orange[50],
  border: Border.all(color: Colors.orange[200]),
  child: Row([
    Icon(info_outline, orange),
    Text('💡 سيظهر الإشعار في الصفحة الرئيسية للطالب لمدة 24 ساعة...'),
  ]),
)
```

#### **زر الإرسال:**
```dart
Container(
  height: 56,
  gradient: LinearGradient([Colors.red, Color(0xFFE53935)]),
  child: Row([
    Text('إرسال إشعار الغياب'),
    Icon(send),
  ]),
)
```

#### **Firestore Integration:**

**1. إرسال للإشعارات (24 ساعة):**
```dart
await FirebaseFirestore.instance
    .collection('notifications_absences')
    .add({
  'studentUid': studentUid,
  'studentName': studentName,
  'message': message,
  'date': selectedDate,
  'createdAt': now,
  'expiresAt': now + 24 hours,
  'read': false,
  'type': 'absence',
});
```

**2. حفظ في السجل (سنة كاملة):**
```dart
await FirebaseFirestore.instance
    .collection('absences')
    .add({
  'studentUid': studentUid,
  'studentName': studentName,
  'studentGrade': grade,
  'studentSection': section,
  'message': message,
  'absenceDate': selectedDate,
  'createdAt': now,
  'archiveUntil': now + 365 days,
});
```

---

## 📜 **4. صفحة سجل الغيابات** (`absence_history_screen.dart`)

### **الميزات:**

#### **Header:**
```dart
Container(
  color: Colors.white,
  child: Column([
    Text(studentName, fontSize: 18, bold),
    Text('سجل الغيابات', gray),
  ]),
)
```

#### **قائمة الغيابات:**
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('absences')
      .where('studentUid', isEqualTo: studentUid)
      .orderBy('absenceDate', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    // عرض البطاقات
  },
)
```

#### **بطاقة الغياب:**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.red[100], width: 2),
  ),
  child: Column([
    // تاريخ الغياب
    Container(
      color: Colors.red[50],
      child: Row([
        Text(date, red, bold),
        Icon(calendar, red),
      ]),
    ),
    
    // الرسالة
    Container(
      color: Color(0xFFF8F9FF),
      child: Text(message),
    ),
    
    // تاريخ الإرسال
    Row([
      Text(createdAt, gray, small),
      Icon(access_time, gray),
    ]),
  ]),
)
```

#### **حالة فارغة (لا توجد غيابات):**
```dart
Column([
  Container(
    decoration: BoxDecoration(
      color: Colors.green[50],
      shape: BoxShape.circle,
    ),
    child: Icon(check_circle, green, size: 60),
  ),
  Text('لا توجد غيابات مسجلة', bold),
  Text('الطالب ملتزم بالحضور', gray),
])
```

---

## 🎨 **التصميم الموحد**

### **الألوان:**
```dart
الأزرق الداكن:     #2E5C8A
الأزرق المتوسط:    #4A7BA7
الأزرق الفاتح:     #4DD0E1 → #26C6DA
الأحمر:            #FF0000 → #E53935
البرتقالي:         #FF9800
الأخضر:           #4CAF50
الخلفية:           #F5F5F5
الأبيض:            #FFFFFF
```

### **الخطوط:**
```dart
جميع النصوص: GoogleFonts.cairo()
الأرقام: GoogleFonts.cairo() (مع دعم العربية)
```

### **Border Radius:**
```dart
البطاقات الكبيرة:  20px
البطاقات المتوسطة: 16px
البطاقات الصغيرة:  12px
الأزرار:           16px
الـ Chips:         8px
```

### **Shadows:**
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

---

## 🔥 **Firestore Collections**

### **1. students:**
```firestore
{
  uid: string (document ID)
  name: string
  email: string
  class: string (e.g., "الأول")
  section: string (e.g., "أ")
  role: "student"
  createdAt: timestamp
}
```

### **2. notifications_absences:**
```firestore
{
  id: auto-generated
  studentUid: string
  studentName: string
  message: string
  date: timestamp (تاريخ الغياب)
  createdAt: timestamp
  expiresAt: timestamp (createdAt + 24 hours)
  read: boolean
  type: "absence"
}
```

### **3. absences:**
```firestore
{
  id: auto-generated
  studentUid: string
  studentName: string
  studentGrade: string
  studentSection: string
  message: string
  absenceDate: timestamp
  createdAt: timestamp
  archiveUntil: timestamp (createdAt + 365 days)
}
```

---

## 🔄 **سير العمل (Workflow)**

### **1. الإدارة تفتح قائمة الطلاب:**
```
Admin → حسابات الطلاب → StudentsListScreen
```

### **2. البحث عن طالب:**
```
كتابة في شريط البحث → تصفية فورية
```

### **3. اختيار طالب:**
```
الضغط على بطاقة الطالب → StudentDetailsScreen
```

### **4. إرسال إشعار غياب:**
```
الضغط على "إرسال إشعار غياب" → SendAbsenceScreen
→ اختيار التاريخ
→ كتابة الرسالة
→ الضغط على "إرسال"
→ حفظ في notifications_absences (24h)
→ حفظ في absences (1 year)
→ SnackBar نجاح
→ العودة للصفحة السابقة
```

### **5. عرض سجل الغيابات:**
```
الضغط على "سجل الغيابات" → AbsenceHistoryScreen
→ عرض جميع الغيابات
→ ترتيب من الأحدث للأقدم
```

---

## 📊 **الإحصائيات**

```
عدد الصفحات:      4 صفحات
عدد الأسطر:       ~800 سطر
Firestore Queries: 3 queries
Collections:       3 collections
الميزات:          15+ ميزة
```

---

## 🚀 **الاستخدام**

### **إضافة إلى Admin Screen:**
```dart
// في admin_tabs_screen.dart أو admin_home.dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentsListScreen(),
      ),
    );
  },
  child: Text('حسابات الطلاب'),
)
```

---

## ✅ **الميزات المطبقة**

```
✅ قائمة شاملة للطلاب
✅ البحث السريع (اسم + بريد)
✅ معلومات الطالب الكاملة
✅ إرسال إشعار غياب
✅ اختيار تاريخ الغياب
✅ رسالة مخصصة
✅ حفظ في Firestore (24h + 1 year)
✅ سجل الغيابات
✅ ترتيب زمني
✅ حالات فارغة جميلة
✅ تصميم Material 3
✅ RTL Support
✅ Loading States
✅ Error Handling
✅ SnackBar Notifications
```

---

## 🎯 **النتيجة**

**نظام إدارة حسابات طلاب متكامل مع:**
- ✅ واجهة احترافية
- ✅ تجربة مستخدم ممتازة
- ✅ ربط كامل مع Firestore
- ✅ إشعارات ذكية (24h + 1 year)
- ✅ سجل غيابات شامل
- ✅ بحث سريع
- ✅ تصميم متناسق

---

**التاريخ:** 31 أكتوبر 2025  
**الحالة:** ✅ مكتمل 100%  
**المطور:** Codeira Team  
**المشروع:** ثانوية دار السلام للبنات

🎊 **جاهز للاستخدام!** 🎊
