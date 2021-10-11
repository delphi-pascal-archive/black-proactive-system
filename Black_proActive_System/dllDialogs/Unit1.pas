unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    xLabel_3: TLabel;
    xLabel_2: TLabel;
    xLabel_4: TLabel;
    Image3: TImage;
    Image4: TImage;
    Image6: TImage;
    Image7: TImage;
    Label2: TLabel;
    Panel3: TPanel;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Image5: TImage;
    Image8: TImage;
    xLabel_Top: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  ModalResult := 9;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ModalResult := 6;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ModalResult := -1;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ModalResult := 3;
end;

end.
