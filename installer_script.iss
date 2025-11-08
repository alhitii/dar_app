[Setup]
AppName=مدرسة دار السلام للبنات
AppVersion=1.0.0
DefaultDirName={autopf}\Madrasah
DefaultGroupName=مدرسة دار السلام
OutputDir=installer_output
OutputBaseFilename=madrasah_setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\madrasah.exe

[Languages]
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "إنشاء اختصار على سطح المكتب"; GroupDescription: "اختصارات إضافية:"
Name: "quicklaunchicon"; Description: "إنشاء اختصار في شريط المهام"; GroupDescription: "اختصارات إضافية:"

[Files]
Source: "build\windows\x64\runner\Release\madrasah.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\مدرسة دار السلام"; Filename: "{app}\madrasah.exe"
Name: "{autodesktop}\مدرسة دار السلام"; Filename: "{app}\madrasah.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\مدرسة دار السلام"; Filename: "{app}\madrasah.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\madrasah.exe"; Description: "تشغيل التطبيق"; Flags: nowait postinstall skipifsilent
