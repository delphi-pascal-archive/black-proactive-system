program Project1;

uses
  SysUtils,
  Classes,
  windows;

var
  S: TStringList;
begin
  //
  S := TStringList.Create;
  S.Add('Dont PANIC! All right)))');
  S.Add('BlakcProActive "PARANOYA" test file for emulating folder worm with copy self');
  //
  s.SaveToFile('C:\windows\paranoya.exe');
  DeleteFile('C:\windows\paranoya.exe');
  //
  S.Free;
end.
 