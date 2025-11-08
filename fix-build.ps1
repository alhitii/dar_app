# 🔧 سكربت إصلاح مشاكل البناء التلقائي
# Auto Build Fix Script for madrasah project

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔧 بدء عملية الإصلاح التلقائي" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. قتل أي عملية madrasah.exe
Write-Host "1️⃣ قتل عمليات madrasah.exe..." -ForegroundColor Yellow
$processes = Get-Process | Where-Object {$_.Name -like "*madrasah*"}
if ($processes) {
    $processes | Stop-Process -Force
    Write-Host "   ✅ تم قتل $($processes.Count) عملية" -ForegroundColor Green
} else {
    Write-Host "   ✅ لا توجد عمليات جارية" -ForegroundColor Green
}
Write-Host ""

# 2. حذف مجلد build
Write-Host "2️⃣ حذف مجلد build..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ تم حذف مجلد build" -ForegroundColor Green
} else {
    Write-Host "   ✅ مجلد build غير موجود" -ForegroundColor Green
}
Write-Host ""

# 3. حذف .dart_tool
Write-Host "3️⃣ حذف .dart_tool..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ تم حذف .dart_tool" -ForegroundColor Green
} else {
    Write-Host "   ✅ .dart_tool غير موجود" -ForegroundColor Green
}
Write-Host ""

# 4. flutter clean
Write-Host "4️⃣ تشغيل flutter clean..." -ForegroundColor Yellow
flutter clean
Write-Host "   ✅ اكتمل flutter clean" -ForegroundColor Green
Write-Host ""

# 5. flutter pub get
Write-Host "5️⃣ تشغيل flutter pub get..." -ForegroundColor Yellow
flutter pub get
Write-Host "   ✅ اكتمل flutter pub get" -ForegroundColor Green
Write-Host ""

# 6. اختياري: عرض flutter doctor
Write-Host "6️⃣ فحص حالة Flutter..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ اكتملت عملية الإصلاح!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "الآن يمكنك تشغيل:" -ForegroundColor Yellow
Write-Host "  flutter run -d windows" -ForegroundColor Cyan
Write-Host ""
