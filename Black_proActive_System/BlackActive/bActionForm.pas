unit bActionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst;

type
  TEditActionForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckListBox1: TCheckListBox;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditActionForm: TEditActionForm;

implementation

uses bMainForm;

{$R *.dfm}

procedure TEditActionForm.Button2Click(Sender: TObject);
begin
  bMain.SaveOptions;
  Close;  
end;

procedure TEditActionForm.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
