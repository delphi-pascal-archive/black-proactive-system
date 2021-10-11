program Project1;

uses
  SysUtils, classes;

var
  S: TStringList;
begin
  S := TStringList.Create;
  S.Add('Dont PANIC! All right)))');
  S.Add('BlakcProActive "PARANOYA" Autorun.inf test file');
  S.SaveToFile('C:\Autorun.inf');
  S.Free;
  DeleteFile('C:\Autorun.inf')
end.
 