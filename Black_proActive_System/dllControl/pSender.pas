Unit pSender;

{*******************************************************************************
 Process sender unit:
 Client Process ->> Server Process
 Send           ->>  Return answer with wait
********************************************************************************
 Autor : BlackCash
********************************************************************************
Include this code to server aplication for geting input message:
  ...
  protected
    procedure SenderPs(var Msg: TMessage); message WM_COPYDATA;
  ...
  procedure TFormX.SenderPs;
  var
    pcd: PCopyDataStruct;
  begin
    pcd := PCopyDataStruct(Msg.LParam);
    // PChar(pcd.lpData) - Sender string
    // This may be action procedure/function for process message
    // and this answer metod:
    // StrPCopy(lpBaseAddress,'ANSWER');
  end;
********************************************************************************}
interface

Uses Windows, messages;

var
  hFileMapObj   : THandle;
  lpBaseAddress : PChar;
  cd            : TCopyDataStruct;
  
  function  CreateSenderObject(SenderName: PAnsiChar): boolean;
  function  SendToObject(SenderSt: String): boolean;
  function  sendstring(ServerCapt: String; str: pchar): boolean;
  function  GetObjectResult(SenderName: PAnsiChar): string;
  Procedure CloseSenderObject;
implementation
{ **************************************************************************** }
function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrPCopy(Dest: PChar; const Source: string): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), Length(Source));
end;
{ **************************************************************************** }
// Warning!!! Do not use this metod in client App
function CreateSenderObject(SenderName: PAnsiChar): boolean;
begin
  Result := true;
  hFileMapObj:=CreateFileMapping(MAXDWORD,nil,PAGE_READWRITE,0,4,SenderName);
  if (hFileMapObj=0) then
    Result := false
  else
    lpBaseAddress:=MapViewOfFile(hFileMapObj,FILE_MAP_WRITE,0,0,0);
  if lpBaseAddress = nil then
    Result := false;
end;

function SendToObject(SenderSt: String): boolean;
begin
    Result := true;
  try
    StrPCopy(lpBaseAddress,SenderSt);
  except
    Result := false;
  end;
end;

Procedure CloseSenderObject;
begin
  UnMapViewOfFile(lpBaseAddress);
  CloseHandle(hFileMapObj);
end;
{ **************************************************************************** }
// Warning!!! Do not use this metod in server App
function GetObjectResult(SenderName: PAnsiChar): string;
begin
  hFileMapObj:=CreateFileMapping(MAXDWORD,Nil,PAGE_READWRITE,0,4,SenderName);
  if (hFileMapObj=0) then
    Result := ''
  else
    lpBaseAddress:=MapViewOfFile(hFileMapObj,FILE_MAP_WRITE,0,0,0);
  if lpBaseAddress = nil then
    Result := '';
//
  Result := PChar(lpBaseAddress);
  UnMapViewOfFile(lpBaseAddress);
  CloseHandle(hFileMapObj);
end;

function sendstring(ServerCapt: String; str: pchar): boolean;
begin
  // Send to process handle
  if FindWindow(nil, PChar(ServerCapt)) = 0 then
  begin
    result := false;
    Exit;
  end;

  cd.cbData := Length(str) + 1;
  cd.lpData := PChar(str);
  SendMessage(FindWindow(nil, PChar(ServerCapt)), WM_COPYDATA, 0, LParam(@cd));
  result := true;
end;
{ **************************************************************************** }
end.