@echo off
echo ============================================
echo  نشر Cloud Function للحذف التلقائي
echo ============================================
echo.

echo [1/5] التحقق من Firebase CLI...
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Firebase CLI غير مثبت!
    echo.
    echo يرجى تثبيته أولاً:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)
echo ✅ Firebase CLI مثبت

echo.
echo [2/5] الانتقال لمجلد functions...
cd functions
if errorlevel 1 (
    echo ❌ مجلد functions غير موجود!
    pause
    exit /b 1
)
echo ✅ تم الانتقال لمجلد functions

echo.
echo [3/5] تثبيت Dependencies...
call npm install
if errorlevel 1 (
    echo ❌ فشل في تثبيت Dependencies!
    pause
    exit /b 1
)
echo ✅ تم تثبيت Dependencies

echo.
echo [4/5] بناء المشروع...
call npm run build
if errorlevel 1 (
    echo ❌ فشل في البناء!
    pause
    exit /b 1
)
echo ✅ تم البناء بنجاح

echo.
echo [5/5] نشر Cloud Function...
cd ..
firebase deploy --only functions:deleteUserCompletely
if errorlevel 1 (
    echo ❌ فشل في النشر!
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ اكتمل النشر بنجاح!
echo ============================================
echo.
echo الخطوات التالية:
echo 1. شغّل التطبيق: flutter run -d windows
echo 2. سجل دخول كـ Admin
echo 3. احذف معلم تجريبي للاختبار
echo.
pause
