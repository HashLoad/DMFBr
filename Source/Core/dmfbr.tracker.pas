{
         DMFBr - Desenvolvimento Modular Framework for Delphi


                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
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
  dmfbr.injector;

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
    function GetBind<T: class, constructor>: T;
    function GetBindInterface<I: IInterface>: I;
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
begin
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    LCall := LContext.GetType(LMiddleware).GetMethod('Call');
    if not Assigned(LCall) then
      Continue;
    if not LCall.Invoke(LMiddleware, []).AsType<Boolean> then
      raise ERouteGuardianAuthorized.Create;
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
  // O Bind dos m�dulos s�o efetuados por rota, se v�rias rotas usarem o mesmo
  // m�dulo, deve gerar somente um injector para o m�dulo.
  LInjector := FAppInjector^.Get<TAppInjector>(AModule.ClassName);
  if LInjector <> nil then
    Exit;
  // Injector do Modulo
  LInjector := _CreateInjector;
  _AddModuleBind(AModule, LInjector);
  for LModule in AModule.Imports do
    _ResolverImports(LModule, LInjector);
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

function TTracker.GetBind<T>: T;
begin
  Result := FAppInjector^.Get<T>;
end;

function TTracker.GetBindInterface<I>: I;
begin
  Result := FAppInjector^.GetInterface<I>;
end;

function TTracker.GetModule: TModuleAbstract;
begin
  if not Assigned(FAppModule) then
    raise EModuleStartedInit.Create;
  Result := FAppModule;
end;

procedure TTracker._RemoveEndPoint(const APath: string);
begin
  FRouteManager.EndPoints.Remove(LowerCase(APath));
  FRouteManager.EndPoints.Sort;
  DebugPrint(Format('-- "%s" ENDIPOINT REMOVED', [APath]));
end;

procedure TTracker.RemoveRoutes(const AModuleName: string);
var
  LKey: TRouteKey;
begin
  for LKey in FRoutes.Keys do
  begin
    if LKey.Schema <> AModuleName then
      Continue;
    // Remove os endpoints desse m�dulo da lista.
    _RemoveEndPoint(LKey.Path);
    // Remove todas as rotas/sub-rotas do m�dulo que est� sendo destu�do.
    FRoutes.Remove(LKey);
    DebugPrint(Format('-- "%s" ROUTE REMOVED', [LKey.Path]));
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
