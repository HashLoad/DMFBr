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
  @abstract(DMFBr Framework)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @author(Site : https://www.isaquepinheiro.com.br)
}

unit dmfbr.tracker;

interface

uses
  Rtti,
  SysUtils,
  Types,
  RegularExpressions,
  Generics.Collections,
  dmfbr.module.abstract,
  dmfbr.exception,
  dmfbr.bind,
  dmfbr.route.param,
  dmfbr.route.key,
  dmfbr.route.abstract,
  dmfbr.route.manager,
  eclbr.objects,
  dmfbr.injector,
  dmfbr.request;

type
  TTrackerRoute = TObjectDictionary<TRouteKey, TRouteAbstract>;

  TTracker = class
  private
    FAppInjector: PAppInjector;
    FAppModule: TModuleAbstract;
    FRoutes: TTrackerRoute;
    FAppIntialPath: string;
    FCurrentPath: String;
    FRouteManager: TRouteManager;
    FRequest: IRouteRequest;
    procedure _AddModuleBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddExportedModuleBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddModuleImportsBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddRoute(const ARoute: TRouteAbstract; const AParent: String);
    procedure _ResolverImports(const AModule: TClass;
      const AInjector: TAppInjector);
    function _CreateInjector: TAppInjector;
    function _CreateModule(const AModule: TClass): TModuleAbstract;
    procedure _GuardianRoute(const ARoute: TRouteAbstract);
    function _RouteMiddlewares(const ARoute: TRouteAbstract): TRouteAbstract;
    procedure _RemoveEndPoint(const APath: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RunApp(const AModule: TModuleAbstract; const AIntialRoutePath: string);
    procedure BindModule(const AModule: TModuleAbstract);
    procedure RemoveRoutes(const AModuleName: string);
    procedure AddRoutes(const AModule: TModuleAbstract);
    procedure ExtractInjector<T: class>(const ATag: string);
    function GetBind<T: class, constructor>(const ATag: string): T;
    function GetBindInterface<I: IInterface>(const ATag: string): I;
    function FindRoute(const AArgs: TRouteParam): TRouteAbstract;
    function GetModule: TModuleAbstract;
    function CurrentPath: string;
  end;

implementation

{ TTracker }

constructor TTracker.Create;
begin
  FRoutes := TTrackerRoute.Create([doOwnsValues]);
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  FRouteManager := FAppInjector^.Get<TRouteManager>;
end;

destructor TTracker.Destroy;
begin
  FRoutes.Free;
  FAppModule := nil;
  FAppInjector := nil;
  inherited;
end;

procedure TTracker.ExtractInjector<T>(const ATag: string);
begin
  FAppInjector^.ExtractInjector<T>(ATag);
end;

procedure TTracker._AddModuleBind(const AModule: TModuleAbstract;
  const AInjector: TAppInjector);
var
  LBind: TBind<TObject>;
begin
  for LBind in AModule.Binds do
  begin
    LBind.IncludeInjector(AInjector);
    LBind.Free;
  end;
end;

procedure TTracker._AddExportedModuleBind(const AModule: TModuleAbstract;
  const AInjector: TAppInjector);
var
  LBind: TBind<TObject>;
begin
  if Length(AModule.ExportedBinds) = 0 then
    exit;
  for LBind in AModule.ExportedBinds do
  begin
    LBind.IncludeInjector(AInjector);
    LBind.Free;
  end;
end;

procedure TTracker._AddModuleImportsBind(const AModule: TModuleAbstract;
  const AInjector: TAppInjector);
var
  LModule: TClass;
begin
  _AddExportedModuleBind(AModule, AInjector);
  if Length(AModule.Imports) = 0 then
    exit;
  for LModule in AModule.Imports do
    _ResolverImports(LModule, AInjector);
end;

procedure TTracker._AddRoute(const ARoute: TRouteAbstract; const AParent: String);
var
  LPath: String;
begin
  LPath := FRouteManager.RemoveSuffix(LowerCase(ARoute.Path));
  // Lista de Rotas
  FRoutes.AddOrSetValue(TRouteKey.Create(LPath, AParent), ARoute);
  // Lista de EndPoints
  FRouteManager.EndPoints.Add(LPath);
  FRouteManager.EndPoints.Sort;
end;

function TTracker._CreateInjector: TAppInjector;
begin
  Result := TAppInjector.Create;
end;

function TTracker._CreateModule(const AModule: TClass): TModuleAbstract;
begin
  Result := FAppInjector^.Get<TObjectFactory>
                         .CreateInstance(AModule) as TModuleAbstract;
end;

procedure TTracker._GuardianRoute(const ARoute: TRouteAbstract);
var
  LMiddleware: TClass;
  LCall: TRttiMethod;
  LFor: integer;
  LContext: TRttiContext;
  LParamRequest: TValue;
begin
  if Length(ARoute.Middlewares) = 0 then
    exit;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    LCall := LContext.GetType(LMiddleware).GetMethod('Call');
    if not Assigned(LCall) then
      continue;
    LParamRequest := TValue.From<IRouteRequest>(FRequest);
    if LParamRequest.AsInterface = nil then
      continue;
    if not LCall.Invoke(LMiddleware, [LParamRequest]).AsType<boolean> then
      raise EUnauthorizedException.Create('');
  end;
end;

procedure TTracker.AddRoutes(const AModule: TModuleAbstract);
var
  LFor: integer;
  LRoutes: TRoutes;
begin
  LRoutes := AModule.Routes;
  for LFor := 0 to High(LRoutes) do
    _AddRoute(LRoutes[LFor] as TRouteAbstract, AModule.ClassName);
end;

procedure TTracker.BindModule(const AModule: TModuleAbstract);
var
  LInjector: TAppInjector;
  LModule: TClass;
begin
  // O Bind dos módulos são efetuados por rota, se várias rotas usarem o mesmo
  // módulo, deve gerar somente um injector para o módulo.
  LInjector := FAppInjector^.Get<TAppInjector>(AModule.ClassName);
  if LInjector <> nil then
    Exit;
  // Injector do Modulo
  LInjector := _CreateInjector;
  _AddModuleBind(AModule, LInjector);
  {$IFDEF DEBUG}
  DebugPrint(Format('[InstanceLoad] %s dependencies initialized', [AModule.ClassName]));
  {$ENDIF}
  if Length(AModule.Imports) > 0 then
  begin
    for LModule in AModule.Imports do
      _ResolverImports(LModule, LInjector);
  end;
  // Adiciona ao AppInjector
  FAppInjector^.AddInjector(AModule.ClassName, LInjector);
end;

function TTracker.CurrentPath: string;
begin
  Result := FCurrentPath;
end;

function TTracker.FindRoute(const AArgs: TRouteParam): TRouteAbstract;
var
  LKey: TRouteKey;
  LEndPoint: string;
  LRoute: TRouteAbstract;
begin
  // Request atualizada a cada requisição, para ser usada internamente
  FRequest := AArgs.Request;
  //
  Result := nil;
  LEndPoint := FRouteManager.FindEndpoint(AArgs.Path);
  if LEndPoint = '' then
    Exit;
  for LKey in FRoutes.Keys do
  begin
    if LKey.Path <> LEndPoint then
      Continue;
    LRoute := FRoutes.Items[LKey];
    _GuardianRoute(LRoute);
    Result := _RouteMiddlewares(LRoute);
    Break;
  end;
end;

function TTracker.GetBind<T>(const ATag: string): T;
begin
  Result := FAppInjector^.Get<T>(ATag);
end;

function TTracker.GetBindInterface<I>(const ATag: string): I;
begin
  Result := FAppInjector^.GetInterface<I>(ATag);
end;

function TTracker.GetModule: TModuleAbstract;
begin
  if not Assigned(FAppModule) then
    raise EModuleStartedInitException.Create('');
  Result := FAppModule;
end;

procedure TTracker._RemoveEndPoint(const APath: string);
begin
  FRouteManager.EndPoints.Remove(LowerCase(APath));
  FRouteManager.EndPoints.Sort;
end;

procedure TTracker.RemoveRoutes(const AModuleName: string);
var
  LKey: TRouteKey;
begin
  for LKey in FRoutes.Keys do
  begin
    if LKey.Schema <> AModuleName then
      Continue;
    // Remove os endpoints desse módulo da lista.
    _RemoveEndPoint(LKey.Path);
    // Remove todas as rotas/sub-rotas do módulo que está sendo destuído.
    FRoutes.Remove(LKey);
  end;
end;

procedure TTracker.RunApp(const AModule: TModuleAbstract;
  const AIntialRoutePath: string);
begin
  FAppIntialPath := AIntialRoutePath;
  FCurrentPath := AIntialRoutePath;
  FAppModule := AModule;
end;

procedure TTracker._ResolverImports(const AModule: TClass;
  const AInjector: TAppInjector);
var
  LInstance: TModuleAbstract;
begin
  LInstance := _CreateModule(AModule);
  if LInstance = nil then
    Exit;
  try
    _AddModuleImportsBind(LInstance, AInjector);
    {$IFDEF DEBUG}
    DebugPrint(Format('[InstanceImported] %s dependencies imported', [AModule.ClassName]));
    {$ENDIF}
  finally
    LInstance.Free;
  end;
end;

function TTracker._RouteMiddlewares(
  const ARoute: TRouteAbstract): TRouteAbstract;
var
  LMiddleware: TClass;
  LBefore: TRttiMethod;
  LFor: integer;
  LContext: TRttiContext;
  LParam: TValue;
begin
  Result := ARoute;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    LBefore := LContext.GetType(LMiddleware).GetMethod('Before');
    if not Assigned(LBefore) then
      Continue;
    LParam := TValue.From(ARoute);
    Result := LBefore.Invoke(LMiddleware, [LParam]).AsType<TRouteAbstract>;
  end;
end;

end.
