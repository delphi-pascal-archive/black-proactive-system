program Project1;

uses
  windows, classes;
  
procedure CopySelfTo(Dest: String);
begin
  CopyFile(PChar(ParamStr(0)),PChar(Dest),true);
end;

begin
  //
  CopySelfTo('C:\windows\paranoya.exe');
  DeleteFile('C:\windows\paranoya.exe');
  //
end.
 