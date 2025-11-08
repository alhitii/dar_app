# سكريبت لإعادة بناء Cloud Functions بشكل صحيح

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  🔨 إعادة بناء Cloud Functions" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# الانتقال لمجلد functions
Set-Location functions

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "[1/5] 🧹 حذف الملفات القديمة..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

# حذف index.js القديم
if (Test-Path "index.js") {
    Remove-Item "index.js" -Force
    Write-Host "   ✅ تم حذف index.js القديم" -ForegroundColor Green
}

# حذف مجلد lib إذا كان موجوداً
if (Test-Path "lib") {
    Remove-Item "lib" -Recurse -Force
    Write-Host "   ✅ تم حذف مجلد lib القديم" -ForegroundColor Green
}

Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "[2/5] 📦 تثبيت Dependencies..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ فشل التثبيت!" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ تم التثبيت بنجاح" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "[3/5] 🔨 بناء TypeScript..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ فشل البناء!" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ تم البناء بنجاح" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "[4/5] 🔍 التحقق من النتيجة..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

if (Test-Path "lib/index.js") {
    Write-Host "   ✅ lib/index.js موجود" -ForegroundColor Green
} else {
    Write-Host "   ❌ lib/index.js غير موجود!" -ForegroundColor Red
    exit 1
}

if (Test-Path "lib/deleteUserCompletely.js") {
    Write-Host "   ✅ lib/deleteUserCompletely.js موجود" -ForegroundColor Green
} else {
    Write-Host "   ❌ lib/deleteUserCompletely.js غير موجود!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# العودة للمجلد الرئيسي
Set-Location ..

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "[5/5] 🚀 نشر Cloud Function..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

firebase deploy --only functions:deleteUserCompletely
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ فشل النشر!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ اكتمل النشر بنجاح!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 الخطوات التالية:" -ForegroundColor Cyan
Write-Host "   1. شغّل التطبيق: flutter run -d windows" -ForegroundColor White
Write-Host "   2. سجل دخول كـ Admin" -ForegroundColor White
Write-Host "   3. جرب حذف معلم" -ForegroundColor White
Write-Host ""
Write-Host "   يجب أن ترى: ✅ تم حذف المعلم نهائياً من جميع الأماكن" -ForegroundColor Green
Write-Host ""
