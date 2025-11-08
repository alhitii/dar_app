# تحويل أيقونة PNG إلى ICO لـ Windows

Add-Type -AssemblyName System.Drawing

$pngPath = "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
$icoPath = "windows\runner\resources\app_icon.ico"

# قراءة الصورة
$image = [System.Drawing.Image]::FromFile((Resolve-Path $pngPath))

# إنشاء أيقونة بأحجام متعددة
$sizes = @(16, 32, 48, 64, 128, 256)
$icon = New-Object System.Drawing.Icon -ArgumentList $image, 256, 256

# حفظ الأيقونة
$stream = [System.IO.File]::Create((Resolve-Path $icoPath -ErrorAction SilentlyContinue).Path)
if (-not $stream) {
    $stream = [System.IO.File]::Create($icoPath)
}
$icon.Save($stream)
$stream.Close()

Write-Host "✅ تم إنشاء app_icon.ico بنجاح!"
