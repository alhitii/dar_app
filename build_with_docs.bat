@echo off
if "%1"=="" (
  echo Usage: build_with_docs.bat ^<flutter_build_target^>
  echo Example: build_with_docs.bat apk
  exit /b 1
)

echo Building Flutter target: %1
flutter build %1

if %errorlevel% neq 0 (
  echo Flutter build failed. Skipping post-build update.
  exit /b %errorlevel%
)

echo Running post-build docs update...
dart .windsurf/post_build_update.dart
