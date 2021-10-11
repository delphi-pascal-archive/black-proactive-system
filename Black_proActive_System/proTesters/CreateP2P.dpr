program Project1;

uses
  SysUtils,
  Classes;

var
  S: TStringList;
begin
  //
  S := TStringList.Create;
  S.Add('Dont PANIC! All right)))');
  S.Add('BlakcProActive "PARANOYA" test file for emulating folder worm');
  //
  CreateDir('C:\xCore(PARANOYA)\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER001\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER002\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER003\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER004\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER005\');
  CreateDir('C:\xCore(PARANOYA)\FOLDER006\');
  //
  S.SaveToFile('C:\xCore(PARANOYA)\xCore(PARANOYA).exe');
  S.SaveToFile('C:\xCore(PARANOYA)\FOLDER001\FOLDER001.exe');
  S.SaveToFile('C:\xCore(PARANOYA)\FOLDER002\FOLDER002.exe');
  S.SaveToFile('C:\xCore(PARANOYA)\FOLDER003\FOLDER003.exe');
  S.SaveToFile('c:\xCore(PARANOYA)\FOLDER004\FOLDER004.exe');
  S.SaveToFile('C:\xCore(PARANOYA)\FOLDER005\FOLDER005.exe');
  S.SaveToFile('C:\xCore(PARANOYA)\FOLDER006\FOLDER006.exe');
  //
  S.Free;
end.
 