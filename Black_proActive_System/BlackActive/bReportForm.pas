unit bReportForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList;

type
  TReportForm = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    ImageList1: TImageList;
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportForm: TReportForm;

implementation

{$R *.dfm}

procedure TReportForm.FormResize(Sender: TObject);
begin
  ListView1.Columns.Items[0].Width  := ListView1.Width - 25;
end;

procedure TReportForm.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
