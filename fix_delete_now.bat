@echo off
echo ============================================
echo   🔧 حل مشكلة الحذف من Authentication
echo ============================================
echo.

echo 📋 هذا السكريبت سيقوم بـ:
echo    1. إعادة بناء Cloud Function
echo    2. نشر Function
echo    3. تشغيل التشخيص
echo.

pause

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [1/4] التحقق من Firebase CLI...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Firebase CLI غير مثبت!
    echo.
    echo يرجى تثبيته:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)
echo ✅ Firebase CLI مثبت
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [2/4] إعادة بناء Cloud Function...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd functions

echo    🧹 حذف البناء القديم...
if exist lib rmdir /s /q lib
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json

echo    📦 تثبيت Dependencies...
call npm install
if errorlevel 1 (
    echo ❌ فشل التثبيت!
    pause
    exit /b 1
)

echo    🔨 بناء Function...
call npm run build
if errorlevel 1 (
    echo ❌ فشل البناء!
    pause
    exit /b 1
)

echo ✅ تم البناء بنجاح
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [3/4] نشر Cloud Function...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd ..
firebase deploy --only functions:deleteUserCompletely
if errorlevel 1 (
    echo ❌ فشل النشر!
    echo.
    echo 💡 الأسباب المحتملة:
    echo    1. لم تسجل دخول: firebase login
    echo    2. لم تفعّل Blaze Plan
    echo    3. مشكلة في الاتصال
    pause
    exit /b 1
)

echo ✅ تم النشر بنجاح
echo.
echo ⏳ انتظر 30 ثانية لتطبيق التغييرات...
timeout /t 30 /nobreak

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [4/4] تشغيل التشخيص...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 🔍 سيتم فتح نافذة جديدة لتشغيل التشخيص...
echo    يرجى متابعة النتائج في النافذة الجديدة
echo.

start cmd /k "flutter run diagnose_delete_issue.dart && echo. && echo ✅ اكتمل التشخيص! && echo. && pause"

echo.
echo ============================================
echo ✅ اكتمل!
echo ============================================
echo.
echo 📋 الخطوات التالية:
echo.
echo 1. راجع نتائج التشخيص في النافذة الجديدة
echo.
echo 2. إذا كانت النتائج إيجابية:
echo    - شغّل التطبيق: flutter run -d windows
echo    - سجل دخول كـ Admin
echo    - جرب حذف معلم
echo.
echo 3. إذا استمرت المشكلة:
echo    - راجع: TROUBLESHOOT_DELETE.md
echo    - تحقق من Firebase Console ^>^> Functions ^>^> Logs
echo.
echo 4. تأكد من:
echo    ✓ أنت مسجل دخول كـ Admin
echo    ✓ role = "admin" في Firestore
echo    ✓ Blaze Plan مفعل
echo.

pause
