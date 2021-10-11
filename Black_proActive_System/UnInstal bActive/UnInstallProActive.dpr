program xInitCorePC;

uses
  Windows, sysutils;

//{$R mainicon.RES}

var
  Mutex : THandle;
  
function MyExitWindows(RebootParam: Longword): Boolean;
var
TTokenHd              : THandle;
TTokenPvg             : TTokenPrivileges;
cbtpPrevious          : DWORD;
rTTokenPvg            : TTokenPrivileges;
pcbtpPreviousRequired : DWORD;
tpResult              : Boolean;
const
SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
if Win32Platform = VER_PLATFORM_WIN32_NT then
begin
   tpResult := OpenProcessToken(GetCurrentProcess(),
     TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
     TTokenHd);
   if tpResult then
   begin
     tpResult := LookupPrivilegeValue(nil,
                                      SE_SHUTDOWN_NAME,
                                      TTokenPvg.Privileges[0].Luid);
     TTokenPvg.PrivilegeCount := 1;
     TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
     cbtpPrevious := SizeOf(rTTokenPvg);
     pcbtpPreviousRequired := 0;
     if tpResult then
       Windows.AdjustTokenPrivileges(TTokenHd,
                                     False,
                                     TTokenPvg,
                                     cbtpPrevious,
                                     rTTokenPvg,
                                     pcbtpPreviousRequired);
   end;
end;
Result := ExitWindowsEx(RebootParam, 0);
end;

Procedure UnInstallDll;
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
    RegDeleteValue(key, 'AppInit_DLLs');
    RegCloseKey(key);
   end;
end;

begin
  //
  UnInstallDll;
  MyExitWindows(EWX_REBOOT);
  //
end.
