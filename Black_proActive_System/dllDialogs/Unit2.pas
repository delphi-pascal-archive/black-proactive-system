unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    xLabel_3: TLabel;
    xLabel_2: TLabel;
    xLabel_4: TLabel;
    xLabel_5: TLabel;
    Image3: TImage;
    Image4: TImage;
    Image6: TImage;
    Image7: TImage;
    Panel3: TPanel;
    Button2: TButton;
    Button4: TButton;
    Panel2: TPanel;
    Image5: TImage;
    Image8: TImage;
    xLabel_Top: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormShow(Sender: TObject);
begin
  ModalResult := -1;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  ModalResult := 9;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  ModalResult := 6;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  ModalResult := 3;
end;

end.
 