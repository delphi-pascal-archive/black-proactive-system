library proControl;

uses
  Windows, pSender;
(* -------------------------------------------------------------------------- *)
const
  THREAD_ALL_ACCESS      = $001F03FF;
  THREAD_SUSPEND_RESUME  = $00000002;
  TH32CS_SNAPTHREAD      = $04;
  MutexName              = '_BLACKPROCESSCONTROLMUTEX';
  proCapt                = 'Black proActive System by BlackCash';
  
const
  faReadOnly  = $00000001 platform;
  faHidden    = $00000002 platform;
  faSysFile   = $00000004 platform;
  faVolumeID  = $00000008 platform;
  faDirectory = $00000010;
  faArchive   = $00000020 platform;
  faSymLink   = $00000040 platform;
  faAnyFile   = $0000003F;
  
type
  PFunctionRestoreData = ^ TFunctionRestoreData;
  TFunctionRestoreData = packed record
    Address:Pointer;
    val1:Byte;
    val2:DWORD;
   end;

  TTHREADENTRY32 = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ThreadID: DWORD;
    th32OwnerProcessID: DWORD;
    tpBasePri: Longint;
    tpDeltaPri: Longint;
    dwFlags: DWORD;
   end;

  TFileName = type string;
  TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle  platform;
    FindData: TWin32FindData  platform;
  end;

  LongRec = packed record
    case Integer of
      0: (Lo, Hi: Word);
      1: (Words: array [0..1] of Word);
      2: (Bytes: array [0..3] of Byte);
  end;

Function OpenThread(dwDesiredAccess: dword; bInheritHandle: bool;
                    dwThreadId: dword): dword; stdcall; external 'kernel32.dll';

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): dword;
         stdcall;external 'kernel32.dll';

function Thread32First(hSnapshot: THandle; var lpte: TThreadEntry32): BOOL;
         stdcall;external 'kernel32.dll';

function Thread32Next(hSnapshot: THandle; var lpte: TThreadENtry32): BOOL;
         stdcall;external 'kernel32.dll';

var
  SystemCreateProcW : TFunctionRestoreData;
  SystemCreateProcA : TFunctionRestoreData;
  SystemCreateFileA : TFunctionRestoreData;
  SystemCreateFileW : TFunctionRestoreData;
  SystemCopyFileA   : TFunctionRestoreData;
  SystemDeleteFileA : TFunctionRestoreData;
  {!}
  hDll          : integer;
  LastFile      : string;
  StrangeList   : string;
  CopyesList    : string;
  StrangeFiles  : integer = 0;
  CopyesNumber  : integer = 0;
  ShowDialog    : function(App,Path: PChar; dType: byte): integer; stdcall;
  ShowDialogPro : function (App,Problem: PChar; dType: byte): integer; stdcall;
  CurrentModule : array [0..MAX_PATH] of char;

(* -------------------------------------------------------------------------- *)
procedure InstallMutex;
var
  M:THandle;
begin
  m:=CreateMutex(0,false,MutexName);
  if m=0 then exit;
end;
(* -------------------------------------------------------------------------- *)
function ExpandFileName(const FileName: string): string;
var
  FName: PChar;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer, GetFullPathName(PChar(FileName), SizeOf(Buffer),
    Buffer, FName));
end;
(* -------------------------------------------------------------------------- *)
procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;

function FindMatchingFile(var F: TSearchRec): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
  end else
    Result := GetLastError;
end;
(* -------------------------------------------------------------------------- *)
function StrPas(const Str: PChar): string;
begin
  Result := Str;
end;

function LowCase(ACh:Char): Char;
begin
 Result := ACh;
 if (ACh >= 'A') and (ACh <= 'Z') then inc(Result, 32);
end;

function LowerCase(AStr:string): string;
var
 LI:Integer;
begin
 Result:=AStr;
 for LI := 1 to Length(Result) do Result[LI] := LowCase(Result[LI]);
end;

function FileAgeEx(const FileName: string): Integer;
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
        LongRec(Result).Lo) then Exit;
    end;
  end;
  Result := -1;
end;

function FileExistsEx(const FileName: string): Boolean;
begin
  Result := FileAgeEx(FileName) <> -1;
end;

function DirectoryExists( const Name: String): Boolean;
asm
   PUSH EBX
        PUSH     EAX
   PUSH SEM_NOOPENFILEERRORBOX or SEM_FAILCRITICALERRORS
   CALL SetErrorMode
   XCHG EBX, EAX
        CALL     GetFileAttributes
        INC      EAX
        JZ       @@exit
        DEC      EAX
        {$IFDEF PARANOIA} DB $24, FILE_ATTRIBUTE_DIRECTORY {$ELSE} AND AL, FILE_ATTRIBUTE_DIRECTORY {$ENDIF}
        SETNZ    AL
@@exit:
   XCHG EAX, EBX
   PUSH EAX
   CALL SetErrorMode
   XCHG EAX, EBX
   POP  EBX
end;
(* -------------------------------------------------------------------------- *)
function GetCurrentModulePath: String;
begin
  GetModuleFileName(Hinstance, CurrentModule, MAX_PATH);
  Result := CurrentModule;
end;
(* -------------------------------------------------------------------------- *)
function ExtractFileExt(AFile: String): String;
var
  I,J: integer;
begin
  if Length(AFile)<>0 then
  begin
    J := 0;
    for I := Length(AFile) downto 1 do
      if AFile[I] = '.' then
      begin
        J := I;
        break;
      end;
    Result:=Copy(AFile,J,MaxInt);
  end else Result:='';
end;

function ExtractFilePath(APath:string):string;
var
 LI,LJ:Integer;
begin
 if Length(APath)<>0 then
 begin
  LJ:=0;
  for LI:=Length(APath) downto 1 do
   if APath[LI]='\' then
   begin
    LJ:=LI;
    Break;
   end;
  Result:=Copy(APath,1,LJ);
 end else Result:='';
end;

function ExtractFileName(APath:string):string;
var
 LI,LJ:Integer;
begin
 if Length(APath)<>0 then
 begin
  LJ:=0;
  for LI:=Length(APath) downto 1 do
   if APath[LI]='\' then
   begin
    LJ:=LI;
    Break;
   end;
  Result:=Copy(APath,LJ+1,MaxInt);
 end else Result:='';
end;
(* -------------------------------------------------------------------------- *)
function GetStrCn(Str: String; Count: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Count do
    Result := Result + Str[i];
end;
(* -------------------------------------------------------------------------- *)
function RestoreLongName(fn: string): string;
  function LookupLongName(const filename: string): string;
    var
    sr: TSearchRec;
  begin
    if FindFirst(filename, faAnyFile, sr) = 0 then
      Result := sr.Name
    else
      Result := ExtractFileName(filename);
    FindClose(sr);
  end;
  function GetNextFN: string;
    var
    i: integer;
  begin
    Result := '';
    if Pos('\\', fn) = 1 then
    begin
      Result := '\\';
      fn := Copy(fn, 3, length(fn) - 2);
      i := Pos('\', fn);
      if i <> 0 then
      begin
        Result := Result + Copy(fn, 1, i);
        fn := Copy(fn, i + 1, length(fn) - i);
      end;
    end;
    i := Pos('\', fn);
    if i <> 0 then
    begin
      Result := Result + Copy(fn, 1, i - 1);
      fn := Copy(fn, i + 1, length(fn) - i);
    end
    else begin
      Result := Result + fn;
      fn := '';
    end;
  end;
  var
  name: string;
begin
  fn := ExpandFileName(fn);
  Result := GetNextFN;
  repeat
    name := GetNextFN;
    Result := Result + '\' + LookupLongName(Result + '\' + name);
  until length(fn) = 0;
end;
(* -------------------------------------------------------------------------- *)
function TempDir: string;
var
	buf: packed array [0..4095] of Char;
begin
	GetTempPath(4096,buf);
	Result := StrPas(buf);
	Result := buf;
  Result := RestoreLongName(Result);
end;

function SysDir: string;
var
	buf: packed array [0..4095] of Char;
begin
	GetWindowsDirectory(buf,4096);
	Result:=StrPas(buf);
	Result:=buf+'\system32\';
end;

function WinDir: string;
var
	buf: packed array [0..4095] of Char;
begin
	GetWindowsDirectory(buf,4096);
	Result:=StrPas(buf)+'\';
end;
(* -------------------------------------------------------------------------- *)
Procedure StopThreads;
var
 h, CurrTh, ThrHandle, CurrPr: dword;
 Thread: TThreadEntry32;
begin
 CurrTh := GetCurrentThreadId;
 CurrPr := GetCurrentProcessId;
 h := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
 if h <> INVALID_HANDLE_VALUE then
   begin
    Thread.dwSize := SizeOf(TThreadEntry32);
    if Thread32First(h, Thread) then
    repeat
     if (Thread.th32ThreadID <> CurrTh) and (Thread.th32OwnerProcessID = CurrPr) then
      begin
       ThrHandle := OpenThread(THREAD_SUSPEND_RESUME, false, Thread.th32ThreadID);
       if ThrHandle>0 then
         begin
          SuspendThread(ThrHandle);
          CloseHandle(ThrHandle);
         end;
       end;
    until not Thread32Next(h, Thread);
   CloseHandle(h);
   end;
end;

Procedure RunThreads;
var
 h, CurrTh, ThrHandle, CurrPr: dword;
 Thread: TThreadEntry32;
begin
 CurrTh := GetCurrentThreadId;
 CurrPr := GetCurrentProcessId;
 h := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
 if h <> INVALID_HANDLE_VALUE then
   begin
    Thread.dwSize := SizeOf(TThreadEntry32);
    if Thread32First(h, Thread) then
    repeat
     if (Thread.th32ThreadID <> CurrTh) and (Thread.th32OwnerProcessID = CurrPr) then
      begin
       ThrHandle := OpenThread(THREAD_SUSPEND_RESUME, false, Thread.th32ThreadID);
       if ThrHandle>0 then
         begin
          ResumeThread(ThrHandle);
          CloseHandle(ThrHandle);
         end;
       end;
    until not Thread32Next(h, Thread);
   CloseHandle(h);
   end;
end;
(* -------------------------------------------------------------------------- *)
function SetCodeHook(ProcAddress, NewProcAddress: pointer; RestoreDATA:PFunctionRestoreData):boolean;
var
  OldProtect, JMPValue:DWORD;
begin
  Result:=False;
  if not VirtualProtect(ProcAddress,5,PAGE_EXECUTE_READWRITE,OldProtect) then exit;
  JMPValue := DWORD(NewProcAddress) - DWORD(ProcAddress) - 5;
  RestoreDATA^.val1:= Byte(ProcAddress^);
  RestoreDATA^.val2:= DWORD(Pointer(DWORD(ProcAddress)+1)^);
  RestoreDATA^.Address:=ProcAddress;
  byte(ProcAddress^):=$E9;
  DWORD(Pointer(DWORD(ProcAddress)+1)^):=JMPValue;
  Result:=VirtualProtect(ProcAddress,5,OldProtect,OldProtect);
end;
(* -------------------------------------------------------------------------- *)
function SetProcedureHook(ModuleHandle:HMODULE;ProcedureName:PChar;NewProcedureAddress:Pointer;
   RestoreDATA:PFunctionRestoreData):Boolean;
var
  ProcAddress:Pointer;
begin
  ProcAddress:=GetProcAddress(ModuleHandle,ProcedureName);
  Result:=SetCodeHook(ProcAddress,NewProcedureAddress,RestoreDATA);
end;
(* -------------------------------------------------------------------------- *)
function UnHookCodeHook(RestoreDATA:PFunctionRestoreData):Boolean;
var
  ProcAddress:Pointer;
  OldProtect,JMPValue:DWORD;
begin
  Result:=False;
  ProcAddress:=RestoreDATA^.Address;
  if not VirtualProtect(ProcAddress,5,PAGE_EXECUTE_READWRITE,OldProtect) then exit;
  Byte(ProcAddress^):=RestoreDATA^.val1;
  DWORD(Pointer(DWORD(ProcAddress)+1)^):=RestoreDATA^.val2;
  Result:=VirtualProtect(ProcAddress,5,OldProtect,OldProtect);
end;
(* -------------------------------------------------------------------------- *)
procedure TerminateProcessEx(PID: Integer);
var
 hProcess: integer;
begin
  hProcess := OpenProcess(PROCESS_TERMINATE, false, PID);
  if hProcess > 0 then
  begin
    TerminateProcess(hProcess, 0);
    CloseHandle(hProcess);
  end;
end;
(* -------------------------------------------------------------------------- *)
function ShowProDialog(Path: String; dType: byte) : integer;
var
  PID: dWord;
begin
  hDll := LoadLibrary(PChar(ExtractFilePath(GetCurrentModulePath)+'proDialog.dll'));
  if hDll <> 0 then begin
    try
      @ShowDialogPro:=GetProcAddress(hDll, 'ShowDialogPro');
      Result := ShowDialogPro(pChar(ExtractFileName(ParamStr(0))),PChar(Path),dType);
      case Result of
        3 : begin
              PID := GetCurrentProcessId;
              if PID <> 0 then begin
                TerminateProcessEx(PID);
              end;
            end;
        9 : sendstring(proCapt,PChar('#LOG2#'+ParamStr(0)));
      end;
    finally
      FreeLibrary(hDll);
    end;
  end;
end;

function ShowCanRunDialog(Path: String) : integer;
begin
  hDll := LoadLibrary(PChar(ExtractFilePath(GetCurrentModulePath)+'proDialog.dll'));
  if hDll <> 0 then begin
    try
      @ShowDialog:=GetProcAddress(hDll, 'ShowDialog');
      Result := ShowDialog(pChar(ExtractFileName(ParamStr(0))),PChar(Path),0);
    finally
      FreeLibrary(hDll);
    end;
  end;
end;
(* -------------------------------------------------------------------------- *)
function CanRun(FName, CmdLine: String): boolean;
  var
  i: integer;
  j: integer;
  S: string;
  cmd : String;
begin
  Result := True;
    case ShowCanRunDialog(FName) of
      -1 : Result := false;
       9 : begin
             Result := true;
             sendstring(proCapt,PChar('#LOG2#'+FName));
             exit;
           end;
       6 : begin
             Result := true;
             sendstring(proCapt,PChar('#LOG1#'+FName));
             exit;
           end;
       3 : begin
             Result := False;
             sendstring(proCapt,PChar('#LOG3#'+FName));
             exit;
           end;
    end;

end;
(* -------------------------------------------------------------------------- *)
function ExistsInList(Str: String; List: String) : Boolean;
begin
  Result := False;
  if pos(Str,List) <> 0 then Result := true;
end;

function DeleteInvalidInList(var List: String) : Boolean;
const
  Return = #13#10;
var
  i: integer;
  tmp,tmp1 : String;
begin
  Result := False;
  i    := 1;
  tmp1 := List+Return;
  List := '';
  while i <> 0 do begin
    i := pos(Return,tmp1);
    tmp := copy(tmp1,1,i-1);
    delete(tmp1,1,i+1);
    if FileExistsEx(tmp) then List := List + tmp + Return;
  end;
  Result := true;
end;

function CanDeleteFile(FileName: String) : boolean;
var
  ClearName: String;
  ext      : String;
  DirName  : String;
  S        : String;
begin
  Result := False;

  LastFile  := RestoreLongName(FileName);
  Result    := false;
  ClearName := LowerCase(ExtractFileName(FileName));
  Ext       := LowerCase(ExtractFileExt(FileName));
  DirName   := LowerCase(ExtractFilePath(FileName));
  ClearName := GetStrCn(ClearName,length(ClearName)-length(ext));
  delete(dirname,1,(length(DirName)-1)-Length(ClearName));

  if (LowerCase(ExtractFilePath(FileName)) = LowerCase(WinDir))  or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(TempDir)) or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(SysDir))  then begin
       sendstring(proCapt,PChar('#LOG6#'+FileName));
       ShowProDialog(FileName,5);
     end;
end;

function CanCreateFile(FileName: String) : boolean;
var
  ClearName: String;
  ext      : String;
  DirName  : String;
begin
  LastFile  := RestoreLongName(FileName);
  Result    := false;
  ClearName := LowerCase(ExtractFileName(FileName));
  Ext       := LowerCase(ExtractFileExt(FileName));
  DirName   := LowerCase(ExtractFilePath(FileName));
  ClearName := GetStrCn(ClearName,length(ClearName)-length(ext));
  delete(dirname,1,(length(DirName)-1)-Length(ClearName));
  if (ext = '.exe') or (ext = '.scr') or (ext = '.bat') or (ext = '.cmd') or (ext = '.com') then
  if (LowerCase(ExtractFilePath(FileName)) = LowerCase(WinDir))  or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(TempDir)) or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(SysDir))  then begin
       sendstring(proCapt,PChar('#LOG5#'+FileName));
       ShowProDialog(FileName,3);
     end;

  if (ext = '.exe') or (ext = '.scr') or (ext = '.bat') or (ext = '.cmd') or (ext = '.com') then
  if (DirName = ClearName+'\') or (DirectoryExists(ExtractFilePath(FileName)+ClearName)) then begin
    if not ExistsInList(FileName, StrangeList) then begin
      inc(StrangeFiles);
      StrangeList := StrangeList + #13#10 + FileName;
    end;
    if StrangeFiles > 5 then begin
      sendstring(proCapt,PChar('#LOG4#'+ParamStr(0)));
      ShowProDialog(StrangeList,4);
      Result := true;
      Exit;
    end;
  end;

  if Length(DirName) = 3 then
    if LowerCase( ExtractFileName(FileName)) = 'autorun.inf' then begin
      sendstring(proCapt,PChar('#LOG7#'+FileName));
      ShowProDialog(FileName,0);
    end else
    if LowerCase( ExtractFileName(FileName)) = 'explorer.exe' then begin
      sendstring(proCapt,PChar('#LOG7#'+FileName));
      ShowProDialog(FileName,6);
    end;
end;

function CanCopySelf(FileName: String) : boolean;
var
  ClearName: String;
  ext      : String;
  DirName  : String;
begin
  LastFile  := RestoreLongName(FileName);
  Result    := false;
  ClearName := LowerCase(ExtractFileName(FileName));
  Ext       := LowerCase(ExtractFileExt(FileName));
  DirName   := LowerCase(ExtractFilePath(FileName));
  ClearName := GetStrCn(ClearName,length(ClearName)-length(ext));
  delete(dirname,1,(length(DirName)-1)-Length(ClearName));

  DeleteInvalidInList(CopyesList);
  if not ExistsInList(FileName,CopyesList) then begin
    CopyesList := CopyesList + FileName + #13#10;
    Inc(CopyesNumber);
  end;
  if CopyesNumber > 7 then begin
    sendstring(proCapt,PChar('#LOG4#'+ParamStr(0)));
    ShowProDialog(CopyesList,1);
    Exit;
  end;

  if (DirName = ClearName+'\') or (DirectoryExists(ExtractFilePath(FileName)+ClearName)) then begin
    if not ExistsInList(FileName, StrangeList) then begin
      inc(StrangeFiles);
      StrangeList := StrangeList + FileName + #13#10;
    end;
    if StrangeFiles > 5 then begin
      sendstring(proCapt,PChar('#LOG4#'+ParamStr(0)));
      ShowProDialog(StrangeList,4);
      Result := true;
      Exit;
    end;
  end;
  
  if (LowerCase(ExtractFilePath(FileName)) = LowerCase(WinDir))  or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(TempDir)) or
     (LowerCase(ExtractFilePath(FileName)) = LowerCase(SysDir))  then begin
       sendstring(proCapt,PChar('#LOG5#'+FileName));
       ShowProDialog(FileName,2);
     end;
end;
(* -------------------------------------------------------------------------- *)
function CreateFileANext(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                         hTemplateFile: THandle): THandle; stdcall;
var
  isNewFile: Boolean;
begin

  if not FileExistsEx(lpFileName) then isNewFile := true else
  begin
    isNewFile := false;
  end;

  UnHookCodeHook(@SystemCreateFileA);

  try
    result := CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,
                          lpSecurityAttributes,dwCreationDisposition,
                          dwFlagsAndAttributes,hTemplateFile);

  except
  end;

  if FileExistsEx(lpFileName) and isNewFile then begin
    CanCreateFile(lpFileName);
    LastFile := RestoreLongName(lpFileName);
  end;

    SetCodeHook(SystemCreateFileA.Address,@CreateFileANext,@SystemCreateFileA);
end;
(* -------------------------------------------------------------------------- *)
function CreateFileWNext(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                         hTemplateFile: THandle): THandle; stdcall;
var
  isNewFile: Boolean;
begin
  if not FileExistsEx(lpFileName) then isNewFile := true else
  begin
    isNewFile := false;
  end;
  UnHookCodeHook(@SystemCreateFileW);

  try
    result := CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,
                          lpSecurityAttributes,dwCreationDisposition,
                          dwFlagsAndAttributes,hTemplateFile);

  except
  end;

  if FileExistsEx(lpFileName) and isNewFile then begin
    CanCreateFile(lpFileName);
    LastFile := RestoreLongName(lpFileName);
  end;

    SetCodeHook(SystemCreateFileW.Address,@CreateFileWNext,@SystemCreateFileW);

end;
(* -------------------------------------------------------------------------- *)
function DeleteFileCallBack(lpFileName: PChar): BOOL; stdcall;
begin
  UnHookCodeHook(@SystemDeleteFileA);
  CanDeleteFile(lpFileName);
  try
    result := Windows.DeleteFile(lpFileName);
  except
  end;
  SetCodeHook(SystemDeleteFileA.Address,@DeleteFileCallBack,@SystemDeleteFileA);
end;
(* -------------------------------------------------------------------------- *)
function CopyFileANext(lpExistingFileName, lpNewFileName: PChar; bFailIfExists: BOOL): BOOL; stdcall;
begin
  UnHookCodeHook(@SystemCopyFileA);
  try
    Result := CopyFile(lpExistingFileName,lpNewFileName,bFailIfExists);
  except
  end;

  if LowerCase(RestoreLongName(lpExistingFileName)) = LowerCase(ParamStr(0)) then
  begin
    CanCopySelf(RestoreLongName(lpNewFileName));
  end else CanCreateFile(RestoreLongName(lpNewFileName));

  SetCodeHook(SystemCopyFileA.Address,@CopyFileANext,@SystemCopyFileA);
end;
(* -------------------------------------------------------------------------- *)
function CreateProcessWCallback(appName, cmdLine: pwidechar;
                                processAttr, threadAttr: PSecurityAttributes;
                                inheritHandles: bool; creationFlags: dword;
                                environment: pointer; currentDir: pwidechar;
                                const startupInfo: TStartupInfo;
                                var processInfo: TProcessInformation) : bool; stdcall;
var appNameA,cmdLineA: string;
begin
    appNameA:=appName;
    cmdLineA:=cmdLine;
    //
    if not CanRun(appName, cmdLine) then begin
      Result := true;
      Exit;
    end;
    //
    UnHookCodeHook(@SystemCreateProcW);
    //
    try
      result := CreateProcessW(appName, cmdLine, processAttr, threadAttr,
                               inheritHandles, creationFlags,
                               environment, currentDir,
                               startupInfo, processInfo);
    except
    end;
    //
    SetCodeHook(SystemCreateProcW.Address,@CreateProcessWCallback,@SystemCreateProcW);
end;
(* -------------------------------------------------------------------------- *)
function CreateProcessACallback(appName, cmdLine: pchar;
                                processAttr, threadAttr: PSecurityAttributes;
                                inheritHandles: bool; creationFlags: dword;
                                environment: pointer; currentDir: pchar;
                                const startupInfo: TStartupInfo;
                                var processInfo: TProcessInformation) : bool; stdcall;
begin
    //
    if not CanRun(appName, cmdLine) then begin
      Result := true;
      Exit;
    end;
    //
    UnHookCodeHook(@SystemCreateProcA);
    //
    try
      result := CreateProcessA(appName, cmdLine, processAttr, threadAttr,
                               inheritHandles, creationFlags,
                               environment, currentDir,
                               startupInfo, processInfo);
    except
    end;
    //
    SetCodeHook(SystemCreateProcA.Address,@CreateProcessACallback,@SystemCreateProcA);
end;
(* -------------------------------------------------------------------------- *)
(* -------------------------------------------------------------------------- *)
{$R *.res}
(* -------------------------------------------------------------------------- *)
begin
  StopThreads();
  InstallMutex;
    SetProcedureHook(GetModuleHandle('kernel32.dll'),'CreateProcessW',@CreateProcessWCallback,@SystemCreateProcW);
    SetProcedureHook(GetModuleHandle('kernel32.dll'),'CreateProcessA',@CreateProcessACallback,@SystemCreateProcA);

    SetProcedureHook(GetModuleHandle('kernel32.dll'),'CreateFileA',@CreateFileANext,@SystemCreateFileA);
    SetProcedureHook(GetModuleHandle('kernel32.dll'),'CreateFileW',@CreateFileWNext,@SystemCreateFileW);

    SetProcedureHook(GetModuleHandle('kernel32.dll'),'CopyFileA',@CopyFileANext,@SystemCopyFileA);
    SetProcedureHook(GetModuleHandle('kernel32.dll'),'DeleteFileA',@DeleteFileCallBack,@SystemDeleteFileA);
  RunThreads();
end.
 