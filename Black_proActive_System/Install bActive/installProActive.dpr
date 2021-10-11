program xInitCorePC;

uses
  Windows, sysutils;

//{$R mainicon.RES}

var
  Mutex : THandle;

Procedure InstallDll;
var
 key: hkey;
 DllName: PChar;
 SystemPath: array [0..MAX_PATH] of char;
begin
 GetSystemDirectory(SystemPath, MAX_PATH);
 DllName := PChar(ExtractFilePath(Paramstr(0))+'proControl.dll');
 if RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows\',
                 0, KEY_CREATE_SUB_KEY or KEY_SET_VALUE, key) = ERROR_SUCCESS then
   begin
    RegSetValueEx(key, 'AppInit_DLLs', 0, REG_SZ, DllName, Length(DllName) + 1);
    RegCloseKey(key);
   end;
end;

begin
  //
  InstallDll;
  //
end.
