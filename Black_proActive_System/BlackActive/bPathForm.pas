unit bPathForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, FileCtrl, ShlObj, ImgList;

type
  TEditPathForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListView1: TListView;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ImageList1: TImageList;
    procedure FormResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditPathForm: TEditPathForm;

implementation

uses bMainForm;

{$R *.dfm}

procedure TEditPathForm.FormResize(Sender: TObject);
begin
  ListView1.Columns.Items[0].Width  := ListView1.Width - 25;
end;

procedure TEditPathForm.Button2Click(Sender: TObject);
begin
  bMain.SaveOptions;
  Close;
end;

procedure TEditPathForm.Button1Click(Sender: TObject);
begin
  Close;
end;

function SpecialFolder(Folder: Integer): String;
var
  SFolder : pItemIDList;
  SpecialPath : Array[0..MAX_PATH] Of Char;
  Handle:THandle;
begin
  SHGetSpecialFolderLocation(Handle, Folder, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := StrPas(SpecialPath);
end;

procedure TEditPathForm.Label1Click(Sender: TObject);
var
  F: String;
begin
  if SelectDirectory('Веберите директорию запуск приложений из которой будет контролироваться.',SpecialFolder(CSIDL_DRIVES),F) then
  with ListView1.Items.Add do
    Caption := F + '\';
end;

procedure TEditPathForm.Label2Click(Sender: TObject);
begin
  ListView1.DeleteSelected;
end;

procedure TEditPathForm.Label3Click(Sender: TObject);
begin
  with ListView1.Items.Add do
    Caption := '{drive}';
end;

procedure TEditPathForm.Label4Click(Sender: TObject);
begin
  with ListView1.Items.Add do
    Caption := '{ns}';
end;

end.
