unit bMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, pSender, XPMan, ShellAPI;

type
  TbMain = class(TForm)
    MainPages: TPageControl;
    OptionsTab: TTabSheet;
    AboutTab: TTabSheet;
    BtnPanel: TPanel;
    Image2: TImage;
    Image4: TImage;
    Image6: TImage;
    Image7: TImage;
    TopPanel: TPanel;
    Image3: TImage;
    Image5: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Image8: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    CheckBox1: TCheckBox;
    Image9: TImage;
    Label6: TLabel;
    Label7: TLabel;
    CheckBox2: TCheckBox;
    Image10: TImage;
    Label9: TLabel;
    Button3: TButton;
    Panel1: TPanel;
    Image11: TImage;
    Image12: TImage;
    Label8: TLabel;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    XPManifest1: TXPManifest;
    Image18: TImage;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    procedure Label4Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label15Click(Sender: TObject);
  protected
    procedure SenderPs(var Msg: TMessage); message WM_COPYDATA;
  private
    { Private declarations }
  public
    procedure SaveOptions;
    procedure LoadOptions;
    { Public declarations }
  end;

var
  bMain: TbMain;

implementation

uses bPathForm, bActionForm, bReportForm;

procedure TbMain.SenderPs;
var
  pcd: PCopyDataStruct;
  tmp: string;
begin
  pcd := PCopyDataStruct(Msg.LParam);
  
  if Copy(PChar(pcd.lpData),0,6) = '#LOG1#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Приложение запущено] '+Tmp;
      ImageIndex := 0;
    end;
  end;

  if Copy(PChar(pcd.lpData),0,6) = '#LOG2#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Приложение в белом списке] '+Tmp;
      ImageIndex := 2;
    end;
  end;

  if Copy(PChar(pcd.lpData),0,6) = '#LOG3#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Запуск приложения отменен] '+Tmp;
      ImageIndex := 1;
    end;
  end;
  (* ! *)
  if Copy(PChar(pcd.lpData),0,6) = '#LOG4#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Возможно P2P.Worm] '+Tmp;
      ImageIndex := 4;
    end;
  end;

  if Copy(PChar(pcd.lpData),0,6) = '#LOG5#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Попытка копирования в систему] '+Tmp;
      ImageIndex := 4;
    end;
  end;

  if Copy(PChar(pcd.lpData),0,6) = '#LOG6#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Попытка удаления из системы] '+Tmp;
      ImageIndex := 4;
    end;
  end;

  if Copy(PChar(pcd.lpData),0,6) = '#LOG7#' then
  begin
    tmp := Copy(PChar(pcd.lpData),7,length(PChar(pcd.lpData)));
    with ReportForm.ListView1.Items.Add do begin
      Caption    := '[Создание подозрителного файла] '+Tmp;
      ImageIndex := 4;
    end;
  end;
end;

procedure TbMain.LoadOptions;
var
  OL : TStringList;
  i  : integer;
begin
  if Not FileExists(ExtractFilePath(ParamStr(0))+'proOptions.opt') then Exit;
  
  OL := TStringList.Create;
  OL.LoadFromFile(ExtractFilePath(ParamStr(0))+'proOptions.opt');
  {!}
    if Pos('ACTIVEPROCESSCONTROL',OL.Text) <> 0 then
      CheckBox1.Checked := true else
      CheckBox1.Checked := false;

    for i := 0 to OL.Count-1 do
      if (DirectoryExists(OL[i])) or (OL[i] = '{drive}') or (OL[i] = '{ns}') then
      with EditPathForm.ListView1.Items.Add do
        Caption := OL[i];
  {!}
    if Pos('ACTIVEACTIONCONTROL',OL.Text) <> 0 then
      CheckBox2.Checked := true else
      CheckBox2.Checked := false;

    if Pos('ACTIONCOPYSYS',OL.Text) <> 0 then
      EditActionForm.CheckListBox1.State[0] := cbChecked else
      EditActionForm.CheckListBox1.State[0] := cbUnchecked;

    if Pos('ACTIONDELETESYS',OL.Text) <> 0 then
      EditActionForm.CheckListBox1.State[1] := cbChecked else
      EditActionForm.CheckListBox1.State[1] := cbUnchecked;

    if Pos('ACTIONP2PWORM',OL.Text) <> 0 then
      EditActionForm.CheckListBox1.State[2] := cbChecked else
      EditActionForm.CheckListBox1.State[2] := cbUnchecked;

    if Pos('ACTIONCREATESTRANGE',OL.Text) <> 0 then
      EditActionForm.CheckListBox1.State[3] := cbChecked else
      EditActionForm.CheckListBox1.State[3] := cbUnchecked;
  {!}
  OL.Free;
end;

procedure TbMain.SaveOptions;
var
  OL : TStringList;
  i  : integer;
begin
  OL := TStringList.Create;
  {!}
    if CheckBox1.Checked then
      OL.Add('ACTIVEPROCESSCONTROL')
    else
      OL.Add('DISABLEPROCESSCONTROL');

    for i := 0 to EditPathForm.ListView1.Items.Count-1 do
      OL.Add(EditPathForm.ListView1.Items.Item[i].Caption);
  {!}
    if CheckBox2.Checked then
      OL.Add('ACTIVEACTIONCONTROL')
    else
      OL.Add('DISABLEACTIONCONTROL');

    if EditActionForm.CheckListBox1.State[0] = cbChecked then
      OL.Add('ACTIONCOPYSYS');
    if EditActionForm.CheckListBox1.State[1] = cbChecked then
      OL.Add('ACTIONDELETESYS');
    if EditActionForm.CheckListBox1.State[2] = cbChecked then
      OL.Add('ACTIONP2PWORM');
    if EditActionForm.CheckListBox1.State[3] = cbChecked then
      OL.Add('ACTIONCREATESTRANGE');
  {!}
  OL.SaveToFile(ExtractFilePath(ParamStr(0))+'proOptions.opt');
  OL.Free;
end;

{$R *.dfm}

procedure TbMain.Label4Click(Sender: TObject);
begin
  EditPathForm.Showmodal;
end;

procedure TbMain.Label6Click(Sender: TObject);
begin
  EditActionForm.ShowModal;
end;

procedure TbMain.Label9Click(Sender: TObject);
begin
  ReportForm.Showmodal;
end;

procedure TbMain.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TbMain.Button2Click(Sender: TObject);
begin
  SaveOptions;
end;

procedure TbMain.Button3Click(Sender: TObject);
begin
  if OptionsTab.Showing then
  begin
    AboutTab.Show;
    Button3.Caption := 'Настройки';
  end else begin
    OptionsTab.Show;
    Button3.Caption := 'О программе';
  end;
end;

procedure TbMain.FormCreate(Sender: TObject);
begin
  try
    WinExec(pChar(ExtractFilePath(paramstr(0))+'InstallProActive.exe'),0);
  except
  end;
end;

procedure TbMain.Label15Click(Sender: TObject);
begin
  shellexecute(handle,
  'Open',
  'mailto:BlackCash2006@Yandex.ru?subject=x-Core Process Spy',
  nil, nil, sw_restore);
end;

end.
