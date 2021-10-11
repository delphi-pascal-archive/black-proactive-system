program bActive;

uses
  Forms,
  bMainForm in 'bMainForm.pas' {bMain},
  bPathForm in 'bPathForm.pas' {EditPathForm},
  bActionForm in 'bActionForm.pas' {EditActionForm},
  bReportForm in 'bReportForm.pas' {ReportForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Black proActive System by BlackCash';
  Application.CreateForm(TbMain, bMain);
  Application.CreateForm(TEditPathForm, EditPathForm);
  Application.CreateForm(TEditActionForm, EditActionForm);
  Application.CreateForm(TReportForm, ReportForm);

  bMain.LoadOptions;

  Application.Run;
end.
