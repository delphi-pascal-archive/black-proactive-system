program Project1;

uses
  SysUtils,
  Classes,
  windows;

procedure CopySelfTo(Dest: String);
begin
  CopyFile(PChar(ParamStr(0)),PChar(Dest),true);
end;

var
  S: TStringList;
begin
  //
  S := TStringList.Create;
  S.Add('Dont PANIC! All right)))');
  S.Add('BlakcProActive "PARANOYA" test file for emulating folder worm with copy self');
  //
  CreateDir('C:\xCore(PARANOYA)\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER001\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER002\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER003\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER004\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER005\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER006\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER007\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER008\');
  //
  s.SaveToFile('C:\xCore(PARANOYA)\xCore(PARANOYA).txt');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER001\boom.scr');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER002\boom.txt');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER003\boom.exe');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER004\boom.scr');
  CopySelfTo('c:\xCore(PARANOYA)\FOLDER005\boom.scr');
  CopySelfTo('c:\xCore(PARANOYA)\FOLDER006\boom.bat');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER007\boom.cmd');
  CopySelfTo('C:\xCore(PARANOYA)\FOLDER008\boom.jpg');
  //
  S.Free;
end.
 