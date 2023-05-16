{
         DMFBr - Desenvolvimento Modular Framework for Delphi/Lazarus


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
  eclbr.objects,
  dmfbr.injector;

type
  TTrackerRoute = TObjectDictionary<TRouteKey, TRouteAbstract>;

  TTracker = class
  private
    FAppInjector: TAppInjector;
    FAppModule: TModuleAbstract;
    FRoutes: TTrackerRoute;
    FEndPoints: TList<string>;
    FAppIntialPath: string;
    FCurrentPath: String;
    procedure _AddModuleBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddExportedModuleBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddModuleImportsBind(const AModule: TModuleAbstract;
      const AInjector: TAppInjector);
    procedure _AddRoute(const ARoute: TRouteAbstract; const AParent: String);
    procedure _ResolverImports(const AModule: TClass;
      const AInjector: TAppInjector);
    function _MatchEndPoint(const ARoute: string): string;
    function _CreateInjector: TAppInjector;
    function _CreateModule(const AModule: TClass): TModuleAbstract;
    procedure _GuardianRoute(const ARoute: TRouteAbstract);
    function _RouteMiddlewares(const ARoute: TRouteAbstract): TRouteAbstract;
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
  FEndPoints := TList<string>.Create;
  FAppInjector := AppInjector;
end;

destructor TTracker.Destroy;
begin
  FRoutes.Free;
  FEndPoints.Free;
  FAppModule := nil;
  FAppInjector := nil;
  inherited;
end;

procedure TTracker.ExtractInjector<T>(const ATag: string);
begin
  FAppInjector.ExtractInjector<T>(ATag);
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
  LPath := LowerCase(ARoute.Path);
  // Lista de Rotas
  FRoutes.AddOrSetValue(TRouteKey.Create(LPath, AParent), ARoute);
  // Lista de EndPoints
  FEndPoints.Add(LPath);
  FEndPoints.Sort;
end;

function TTracker._CreateInjector: TAppInjector;
begin
  Result := TAppInjector.Create;
end;

function TTracker._CreateModule(const AModule: TClass): TModuleAbstract;
begin
  Result := FAppInjector.Get<TObjectFactory>
                                 .CreateInstance(AModule) as TModuleAbstract;
end;

procedure TTracker._GuardianRoute(const ARoute: TRouteAbstract);
begin
  if Assigned(ARoute.RouteGuard) then
    if not ARoute.RouteGuard() then
      raise ERouteGuardianAuthorized.Create;
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
  // Injector do Modulo
  LInjector := _CreateInjector;
  _AddModuleBind(AModule, LInjector);
  for LModule in AModule.Imports do
    _ResolverImports(LModule, LInjector);
  // Adiciona ao AppInjector
  FAppInjector.AddInjector(AModule.ClassName, LInjector);
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
  LEndPoint := _MatchEndpoint(AArgs.Path);
  if LEndPoint = '' then
    Exit;
  for LKey in FRoutes.Keys do
  begin
    if LKey.Path = LEndPoint then
    begin
      LRoute := FRoutes.Items[LKey];
      _GuardianRoute(LRoute);
      Result := _RouteMiddlewares(LRoute);
      Exit;
    end;
  end;
end;

function TTracker.GetBind<T>: T;
begin
  Result := FAppInjector.Get<T>;
end;

function TTracker.GetBindInterface<I>: I;
begin
  Result := FAppInjector.GetInterface<I>;
end;

function TTracker.GetModule: TModuleAbstract;
begin
  if not Assigned(FAppModule) then
    raise EModuleStartedInit.Create;
  Result := FAppModule;
end;

procedure TTracker.RemoveRoutes(const AModuleName: string);
var
  LKey: TRouteKey;
begin
  for LKey in FRoutes.Keys do
  begin
    if LKey.Schema = AModuleName then
    begin
      FEndPoints.Remove(LowerCase(LKey.Path));
      FEndPoints.Sort;
      FRoutes.Remove(LKey);
    end;
  end;
end;

procedure TTracker.RunApp(const AModule: TModuleAbstract;
  const AIntialRoutePath: string);
begin
  FAppIntialPath := AIntialRoutePath;
  FCurrentPath := AIntialRoutePath;
  FAppModule := AModule;
end;

function TTracker._MatchEndPoint(const ARoute: string): string;
var
  LEndpoint: string;
  LRegEx, LEndPointRegEx: TRegEx;
  LURI: String;
begin
  Result := '';
  LURI := LowerCase(ARoute);
  // Varre a lista de endpoints em busca de um match
  for LEndpoint in FEndpoints do
  begin
    // Substitui todos os parâmetros da URI por um curinga
    LRegEx := TRegEx.Create(':[^/]+');
    LEndPointRegEx := TRegEx.Create('^' + LRegEx.Replace(LEndpoint, '[^/]+') + '$');
    if LEndPointRegEx.IsMatch(LURI) then
    begin
      Result := LEndpoint;
      Exit;
    end;
  end;
end;

procedure TTracker._ResolverImports(const AModule: TClass;
  const AInjector: TAppInjector);
var
  LInstance: TModuleAbstract;
begin
  LInstance := _CreateModule(AModule);
  if LInstance <> nil then
  begin
    try
      _AddModuleImportsBind(LInstance, AInjector);
    finally
      LInstance.Free;
    end;
  end;
end;

function TTracker._RouteMiddlewares(
  const ARoute: TRouteAbstract): TRouteAbstract;
var
  LMiddleware: TRouteMiddleware;
  LFor: integer;
begin
  Result := ARoute;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    if Assigned(LMiddleware.BeforeCallback) then
      Result := LMiddleware.BeforeCallback(ARoute);
  end;
end;

end.

