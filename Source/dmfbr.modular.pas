{
             DMFBr - Development Modular Framework for Delphi

                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.modular;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  StrUtils,
  Generics.Collections,
  result.pair,
  app.injector.service,
  dmfbr.module,
  dmfbr.route.parse,
  dmfbr.module.service,
  dmfbr.bind.service,
  dmfbr.injector,
  dmfbr.exception,
  dmfbr.register,
  dmfbr.request,
  dmfbr.validation.interfaces,
  dmfbr.route.handler,
  dmfbr.rpc.interfaces,
  dmfbr.rpc.resource;

type
  TModularBr = class sealed
  private
    FAppInjector: PAppInjector;
    FInitialRoutePath: string;
    FAppModule: TModule;
    FRouteParse: TRouteParse;
    FModuleService: TModuleService;
    FBindService: TBindService;
    FModuleStarted: boolean;
    FListener: TListener;
    FRequest: IRouteRequest;
    FGuardCallback: TGuardCallback;
    FRegister: TRegister;
    FRPCProviderServer: IRPCProviderServer;
    procedure _ResolveDisposeRouteModule(const APath: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeModuleService(const AService: TModuleService);
    procedure IncludeBindService(const AService: TBindService);
    procedure IncludeRouteParser(const ARouteParse: TRouteParse);
    function Start(const AModule: TModule; const AListener: TListener = nil;
      const AInitialRoutePath: string = '/'): TModularBr;
    procedure Finalize;
    procedure DisposeRouteModule(const APath: String);
    procedure RegisterRouteHandler(const ARouteHandler: TRouteHandlerClass);
    function UseGuard(const AGuardCallback: TGuardCallback): TModularBr;
    function UsePipes(const AValidationPipe: IValidationPipe): TModularBr;
    function UseRPC(const ARPCProviderServer: IRPCProviderServer): TModularBr;
    function PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass): TModularBr;
    function LoadRouteModule(const APath: string;
      const AReq: IRouteRequest = nil): TResultPair<Exception, TRouteAbstract>;
    function Get<T: class, constructor>(ATag: string = ''): T;
    function GetInterface<I: IInterface>(ATag: string = ''): I;
    function Request: IRouteRequest;
  end;

function Modular: TModularBr;

implementation

{ TModularBr }

function Modular: TModularBr;
begin
  Result := AppInjector^.Get<TModularBr>;
end;

constructor TModularBr.Create;
begin
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  FModuleStarted := false;
  FRegister := FAppInjector^.Get<TRegister>;
end;

destructor TModularBr.Destroy;
begin
  if Assigned(FBindService) then
    FBindService.Free;
  if Assigned(FModuleService) then
    FModuleService.Free;
  if Assigned(FRouteParse) then
    FRouteParse.Free;
  if Assigned(FListener) then
    FListener := nil;
  FModuleStarted := false;
  if Assigned(FRPCProviderServer) then
    FRPCProviderServer.Stop;
  FRegister := nil;
  inherited;
end;

function TModularBr.GetInterface<I>(ATag: string = ''): I;
var
  LResult: TResultPair<Exception, I>;
begin
  LResult := FBindService.GetBindInterface<I>(ATag);
  LResult.TryException(
    procedure (AValue: Exception)
    begin
      raise AValue;
    end,
    procedure (AValue: I)
    begin

    end);
  Result := LResult.ValueSuccess;
end;

function TModularBr.Get<T>(ATag: string): T;
var
  LResult: TResultPair<Exception, T>;
begin
  LResult := FBindService.GetBind<T>(ATag);
  LResult.TryException(
    procedure (AValue: Exception)
    begin
      raise AValue;
    end,
    procedure (AValue: T)
    begin

    end);
  Result := LResult.ValueSuccess;
end;

procedure TModularBr.IncludeBindService(const AService: TBindService);
begin
  FBindService := AService;
end;

procedure TModularBr.IncludeModuleService(const AService: TModuleService);
begin
  FModuleService := AService;
end;

procedure TModularBr.IncludeRouteParser(const ARouteParse: TRouteParse);
begin
  FRouteParse := ARouteParse;
end;

function TModularBr.Start(const AModule: TModule;
  const AListener: TListener; const AInitialRoutePath: String): TModularBr;
begin
  if FModuleStarted then
    raise EModuleStartedException.CreateFmt('', [AModule.ClassName]);
  FInitialRoutePath := AInitialRoutePath;
  FListener := AListener;
  FAppModule := AModule;
  FModuleService.Start(AModule, AInitialRoutePath);
  FModuleStarted := true;
  Result := Self;
  {$IFDEF DEBUG}
  DebugPrint(Format('[%s] Starting DMFBr application', ['ModularInit']));
  {$ENDIF}
end;

function TModularBr.UseGuard(const AGuardCallback: TGuardCallback): TModularBr;
begin
  FGuardCallback := AGuardCallback;
  Result := Self;
end;

function TModularBr.UsePipes(const AValidationPipe: IValidationPipe): TModularBr;
begin
  FRegister.UsePipes(AValidationPipe);
  Result := Self;
end;

function TModularBr.UseRPC(const ARPCProviderServer: IRPCProviderServer): TModularBr;
begin
  FRPCProviderServer := ARPCProviderServer;
  FRPCProviderServer.Start;
  Result := Self;
end;

function TModularBr.LoadRouteModule(const APath: string;
  const AReq: IRouteRequest): TResultPair<Exception, TRouteAbstract>;
var
  LRouteHandle: TClass;
  LIsAccessGranted: boolean;
begin
  FRequest := AReq;
  if Assigned(FGuardCallback) then
  begin
    LIsAccessGranted := FGuardCallback;
    if not LIsAccessGranted then
      raise EUnauthorizedException.Create('');
  end;
  if FRegister.IsValidationPipe then
  begin
    LRouteHandle := FRegister.FindRecord(APath);
    if LRouteHandle <> nil then
    begin
      FRegister.Pipe.Validate(LRouteHandle, FRequest);
      if FRegister.Pipe.IsMessages then
      begin
        Result.Failure(EBadRequestException.Create(FRegister.Pipe.BuildMessages));
        exit;
      end;
//      Result.Failure(EBadRequestException.Create('Use the "UsePipes" command followed by "TValidationPipe.Create" to enable global validation pipes.'));
//      exit;
    end;
  end;
  Result := FRouteParse.SelectRoute(APath, AReq, FListener);
end;

function TModularBr.PublishRPC(const ARPCName: string;
  const ARPCClass: TRPCResourceClass): TModularBr;
begin
  if not Assigned(FRPCProviderServer) then
    raise ERPCProviderNotSetException.Create;
  FRPCProviderServer.PublishRPC(ARPCName, ARPCClass);
  Result := Self;
end;

procedure TModularBr.RegisterRouteHandler(const ARouteHandler: TRouteHandlerClass);
begin
  FRegister.Add(ARouteHandler);
end;

function TModularBr.Request: IRouteRequest;
begin
  Result := FRequest;
end;

procedure TModularBr.DisposeRouteModule(const APath: String);
begin
  _ResolveDisposeRouteModule(APath);
end;

procedure TModularBr.Finalize;
begin
  // Do not change the order.
  FAppModule.Free;
  FAppInjector^.ExtractInjector<TAppInjector>('ModularBr');
end;


procedure TModularBr._ResolveDisposeRouteModule(const APath: string);
var
  LRoutes: TArray<string>;
  LRoute: string;
  LRouteParts: string;
begin
  LRouteParts := '';
  LRoutes := SplitString(APath, '/');
  for LRoute in LRoutes do
  begin
    if (LRoute = '') or (LRoute = '/') then
      Continue;
    LRouteParts := LRouteParts + '/' + LRoute;
    FModuleService.DisposeModule(LRouteParts);
  end;
end;

end.


