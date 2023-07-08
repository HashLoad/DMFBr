program app_test;

uses
  Vcl.Forms,
  Uapp_test in 'Uapp_test.pas' {FormPing},
  app.module in 'src\app.module.pas',
  ping.controller in 'src\modules\ping\controllers\ping.controller.pas',
  ping.module in 'src\modules\ping\ping.module.pas',
  ping.route.handler in 'src\modules\ping\ping.route.handler.pas',
  ping.service in 'src\modules\ping\services\ping.service.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFormPing, FormPing);
  Application.Run;

end.