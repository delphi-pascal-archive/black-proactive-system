library proDialog;

uses
  windows,
  SysUtils,
  Classes,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

var
  DirectoryList : TStringList;
  WhiteList     : TStringList;
  UseProCtrl    : Boolean;
  UseActCtrl    : Boolean;

  UseCopySys    : Boolean;
  UseDelSys     : Boolean;
  UseP2PWorm    : Boolean;
  UseStrange    : Boolean;
  CurrentModule : array [0..MAX_PATH] of char; 
(* -------------------------------------------------------------------------- *)
function GetCurrentModulePath: String;
begin
  GetModuleFileName(Hinstance, CurrentModule, MAX_PATH);
  Result := CurrentModule;
end;
(* -------------------------------------------------------------------------- *)
procedure LoadOptions;
var
  OL : TStringList;
  i  : integer;
begin
  if Not FileExists(ExtractFilePath(GetCurrentModulePath)+'proOptions.opt') then Exit;

  if FileExists(ExtractFilePath(GetCurrentModulePath)+'proWhite.opt') then begin
    try
      WhiteList.LoadFromFile(ExtractFilePath(GetCurrentModulePath)+'proWhite.opt');
    except
    end;
  end;

  OL := TStringList.Create;
  OL.LoadFromFile(ExtractFilePath(GetCurrentModulePath)+'proOptions.opt');
  {!}
    if Pos('ACTIVEPROCESSCONTROL',OL.Text) <> 0 then
      UseProCtrl := true else
      UseProCtrl := false;

    for i := 0 to OL.Count-1 do
      if DirectoryExists(OL[i]) or (OL[i]='{ns}') or (OL[i]='{drive}') then
      DirectoryList.Add(OL[i]);
  {!}
    if Pos('ACTIVEACTIONCONTROL',OL.Text) <> 0 then
      UseActCtrl := true else
      UseActCtrl := false;

    if Pos('ACTIONCOPYSYS',OL.Text) <> 0 then
      UseCopySys := true else
      UseCopySys := false;

    if Pos('ACTIONDELETESYS',OL.Text) <> 0 then
      UseDelSys := true else
      UseDelSys := false;

    if Pos('ACTIONP2PWORM',OL.Text) <> 0 then
      UseP2PWorm := true else
      UseP2PWorm := false;

    if Pos('ACTIONCREATESTRANGE',OL.Text) <> 0 then
      UseStrange := true else
      UseStrange := false;
  {!}
  OL.Free;
end;
(* -------------------------------------------------------------------------- *)
function ShowDialog (App,Path: PChar; dType: byte): integer; stdcall;
var
  Form : TForm1;
  i    : integer;
  Ask  : boolean;
begin
  Result := 6;
  if Not FileExists(ExtractFilePath(GetCurrentModulePath)+'proOptions.opt') then Exit;
  LoadOptions;
  if not UseProCtrl then Exit;

  for i := 0 to WhiteList.Count-1 do
    if lowercase(WhiteList[i]) = LowerCase(Path) then begin
      Exit;
    end;
  {!}
  Ask := False;
  for i := 0 to DirectoryList.Count-1 do
    if LowerCase(DirectoryList[i]) = '{ns}' then begin
      if pos('\\',ExtractFilePath(Path)) <> 0 then begin
        Ask := True;
        Break;
      end;
    end else
    if LowerCase(DirectoryList[i]) = '{drive}' then begin
      if Length(ExtractFilePath(Path)) = 3 then begin
        Ask := True;
        Break;
      end;
    end else
    if LowerCase(ExtractFilePath(Path)) = LowerCase(DirectoryList[i]) then begin
      Ask := True;
      Break;
    end;
    if not Ask then Exit;
  {!}
  Form   := TForm1.Create(nil);
  //
  form.Memo1.text       := Path;
  Form.xLabel_2.Caption := App;
  //
  Result := Form.ShowModal;
  //
  if Result = 9 then begin
    WhiteList.Add(Path);
    WhiteList.SaveToFile(ExtractFilePath(GetCurrentModulePath)+'proWhite.opt');
  end;
  //
  Form.Free;
end;
(* -------------------------------------------------------------------------- *)
function ShowDialogPro (App,Problem: PChar; dType: byte): integer; stdcall;
var
  Form : TForm2;
  Text : String;
  i    : integer;
begin
  Result := -1;
  if Not FileExists(ExtractFilePath(GetCurrentModulePath)+'proOptions.opt') then Exit;
  LoadOptions;
  if not UseActCtrl then Exit;
  
  for i := 0 to WhiteList.Count-1 do
    if lowercase(WhiteList[i]) = LowerCase(ParamStr(0)) then begin
      Exit;
    end;
  {!}
  if (dType = 0) and (not UseStrange) then Exit;
  if (dType = 1) and (not UseP2PWorm) then Exit;
  if (dType = 2) and (not UseCopySys) then Exit;
  if (dType = 3) and (not UseCopySys) then Exit;
  if (dType = 4) and (not UseP2PWorm) then Exit;
  if (dType = 5) and (not UseDelSys)  then Exit;
  if (dType = 6) and (not UseStrange) then Exit;

  Form   := TForm2.Create(nil);
  //
  case dType of
    0   : Text := 'Данное приложение создало файл "'+Problem+'" который может быть загрузчиком вредоносного объекта через автозапуск.';
    1   : Text := 'Данное приложение создало больше 7 копий. Будьте бдительны!'+#13#10+Problem;
    2   : Text := 'Данное приложение создало свою копию в системной директории, будьте осторожны.'+#13#10+Problem;
    3   : Text := 'Данное приложение пытается создать подозрительный файл в системной директории, будьте осторожны.'+#13#10+Problem;
    4   : Text := 'Данное приложение создало больше 5 файлов схожих с вирусом, будьте осторожны.'+#13#10+Problem;
    5   : Text := 'Данное приложение пытается удалить файл "'+Problem+'" из системной директории, будьте осторожны.';
    6   : Text := 'Данное приложение пытется создать файл "'+Problem+'" который может быть вредоносной программой';
  end;
  form.Memo1.text       := Text;
  Form.xLabel_2.Caption := App;
  //
  if Result = 9 then begin
    WhiteList.Add(ParamStr(0));
    WhiteList.SaveToFile(ExtractFilePath(GetCurrentModulePath)+'proWhite.opt');
  end;
  //
  Result := Form.ShowModal;
  Form.Free;
end;
(* -------------------------------------------------------------------------- *)
exports ShowDialog, ShowDialogPro;
(* -------------------------------------------------------------------------- *)
begin
  DirectoryList := TStringList.Create;
  WhiteList     := TStringList.Create;
end.
 