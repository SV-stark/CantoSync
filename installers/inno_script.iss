[Setup]
AppId={{A7F3E9D2-4B1C-4E8A-9F6D-2C8B5A3E7D1F}}
AppName=CantoSync
AppVersion={#AppVersion}
AppPublisher=SV-Stark
AppPublisherURL=https://github.com/SV-stark/CantoSync
DefaultDirName={autopf}\CantoSync
DisableProgramGroupPage=yes
OutputBaseFilename=CantoSync_Setup
OutputDir=Output
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\canto_sync.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\CantoSync"; Filename: "{app}\canto_sync.exe"
Name: "{autodesktop}\CantoSync"; Filename: "{app}\canto_sync.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\canto_sync.exe"; Description: "{cm:LaunchProgram,CantoSync}"; Flags: nowait postinstall skipifsilent
