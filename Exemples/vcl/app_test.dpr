program app_test;

uses
  Vcl.Forms,
  Uapp_test in 'Uapp_test.pas' {FormPing},
  app.module in 'src\app.module.pas',
  ping.controller in 'src\modules\ping\controllers\ping.controller.pas',
  ping.module in 'src\modules\ping\ping.module.pas',
  ping.route.handler in 'src\modules\ping\ping.route.handler.pas',
  ping.service in 'src\modules\ping\services\ping.service.pas',
  dmfbr.modular in '..\..\Source\dmfbr.modular.pas',
  dmfbr.bind.abstract in '..\..\Source\Binds\dmfbr.bind.abstract.pas',
  dmfbr.bind in '..\..\Source\Binds\dmfbr.bind.pas',
  dmfbr.bind.provider in '..\..\Source\Binds\dmfbr.bind.provider.pas',
  dmfbr.bind.service in '..\..\Source\Binds\dmfbr.bind.service.pas',
  dmfbr.exception in '..\..\Source\Core\dmfbr.exception.pas',
  dmfbr.injector in '..\..\Source\Core\dmfbr.injector.pas',
  dmfbr.register in '..\..\Source\Core\dmfbr.register.pas',
  dmfbr.request.data in '..\..\Source\Core\dmfbr.request.data.pas',
  dmfbr.request in '..\..\Source\Core\dmfbr.request.pas',
  dmfbr.tracker in '..\..\Source\Core\dmfbr.tracker.pas',
  dmfbr.module.abstract in '..\..\Source\Modules\dmfbr.module.abstract.pas',
  dmfbr.module in '..\..\Source\Modules\dmfbr.module.pas',
  dmfbr.module.provider in '..\..\Source\Modules\dmfbr.module.provider.pas',
  dmfbr.module.service in '..\..\Source\Modules\dmfbr.module.service.pas',
  dmfbr.route.abstract in '..\..\Source\Routes\dmfbr.route.abstract.pas',
  dmfbr.route.handler in '..\..\Source\Routes\dmfbr.route.handler.pas',
  dmfbr.route.key in '..\..\Source\Routes\dmfbr.route.key.pas',
  dmfbr.route.manager in '..\..\Source\Routes\dmfbr.route.manager.pas',
  dmfbr.route.param in '..\..\Source\Routes\dmfbr.route.param.pas',
  dmfbr.route.parse in '..\..\Source\Routes\dmfbr.route.parse.pas',
  dmfbr.route in '..\..\Source\Routes\dmfbr.route.pas',
  dmfbr.route.provider in '..\..\Source\Routes\dmfbr.route.provider.pas',
  dmfbr.route.service in '..\..\Source\Routes\dmfbr.route.service.pas',
  result.pair.exception in '..\..\..\ResultPairBr\Source\Core\result.pair.exception.pas',
  result.pair.value in '..\..\..\ResultPairBr\Source\Core\result.pair.value.pas',
  result.pair in '..\..\..\ResultPairBr\Source\result.pair.pas',
  app.injector.abstract in '..\..\..\APPInjectoBr\Source\Core\app.injector.abstract.pas',
  app.injector.container in '..\..\..\APPInjectoBr\Source\Core\app.injector.container.pas',
  app.injector.events in '..\..\..\APPInjectoBr\Source\Core\app.injector.events.pas',
  app.injector.factory in '..\..\..\APPInjectoBr\Source\Core\app.injector.factory.pas',
  app.injector.service.abstract in '..\..\..\APPInjectoBr\Source\Core\app.injector.service.abstract.pas',
  app.injector.service in '..\..\..\APPInjectoBr\Source\Core\app.injector.service.pas',
  app.injector in '..\..\..\APPInjectoBr\Source\app.injector.pas',
  eclbr.arrow.fun in '..\..\..\ECLBr\Source\eclbr.arrow.fun.pas',
  eclbr.core in '..\..\..\ECLBr\Source\eclbr.core.pas',
  eclbr.dictionary in '..\..\..\ECLBr\Source\eclbr.dictionary.pas',
  eclbr.directory in '..\..\..\ECLBr\Source\eclbr.directory.pas',
  eclbr.list in '..\..\..\ECLBr\Source\eclbr.list.pas',
  eclbr.map in '..\..\..\ECLBr\Source\eclbr.map.pas',
  eclbr.match in '..\..\..\ECLBr\Source\eclbr.match.pas',
  eclbr.objects in '..\..\..\ECLBr\Source\eclbr.objects.pas',
  eclbr.regexlib in '..\..\..\ECLBr\Source\eclbr.regexlib.pas',
  eclbr.result.pair in '..\..\..\ECLBr\Source\eclbr.result.pair.pas',
  eclbr.stream in '..\..\..\ECLBr\Source\eclbr.stream.pas',
  eclbr.threading in '..\..\..\ECLBr\Source\eclbr.threading.pas',
  eclbr.tuple in '..\..\..\ECLBr\Source\eclbr.tuple.pas',
  eclbr.utils in '..\..\..\ECLBr\Source\eclbr.utils.pas',
  eclbr.vector in '..\..\..\ECLBr\Source\eclbr.vector.pas',
  dmfbr.transform.interfaces in '..\..\Source\Interfaces\dmfbr.transform.interfaces.pas',
  dmfbr.validation.interfaces in '..\..\Source\Interfaces\dmfbr.validation.interfaces.pas',
  dmfbr.rpc.interfaces in '..\..\Source\Microservices\RPC\Providers\dmfbr.rpc.interfaces.pas',
  dmfbr.rpc.resource in '..\..\Source\Microservices\RPC\dmfbr.rpc.resource.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFormPing, FormPing);
  Application.Run;

end.