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

unit dmfbr.module;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Generics.Collections,
  app.injector.events,
  dmfbr.injector,
  dmfbr.module.abstract,
  dmfbr.route.abstract,
  dmfbr.module.service,
  dmfbr.route.manager,
  dmfbr.route,
  dmfbr.request,
  dmfbr.route.handler,
  dmfbr.bind;

type
  TValue = Rtti.TValue;
  TRouteMiddleware = dmfbr.route.abstract.TRouteMiddleware;
  TRoute = dmfbr.route.TRoute;
  TRouteAbstract = dmfbr.route.abstract.TRouteAbstract;
  TRoutes = dmfbr.module.abstract.TRoutes;
  TBinds = dmfbr.module.abstract.TBinds;
  TImports = dmfbr.module.abstract.TImports;
  TExportedBinds = dmfbr.module.abstract.TExportedBinds;
  TConstructorParams = app.injector.events.TConstructorParams;
  TRouteHandlers = dmfbr.module.abstract.TRouteHandlers;
  TRouteManager = dmfbr.route.manager.TRouteManager;
  IRouteRequest = dmfbr.request.IRouteRequest;

  TModule = class(TModuleAbstract)
  private
    FAppInjector: PAppInjector;
    FRouteHandlers: TObjectList<TRouteHandler>;
    FService: TModuleService;
    procedure _DestroyRoutes;
    procedure _DestroyInjector;
    procedure _AddRoutes;
    procedure _BindModule;
    procedure _RouteHandlers;
  public
    constructor Create; override;
    destructor Destroy; override;
    function Routes: TRoutes; override;
    function Binds: TBinds; override;
    function Imports: TImports; override;
    function ExportedBinds: TExportedBinds; override;
    function RouteHandlers: TRouteHandlers; override;
  end;

  // Só para facilitar a sintaxe nos módulos
  Bind<T: class, constructor> = class(TBind<T>)
  end;

// RouteModule
function RouteModule(const APath: string;
  const AModule: TModuleClass): TRouteModule; overload;
function RouteModule(const APath: string; const AModule: TModuleClass;
  const AMiddlewares: TMiddlewares): TRouteModule; overload;

// RouteChild
function RouteChild(const APath: string; const AModule: TModuleClass;
  const AMiddlewares: TMiddlewares = []): TRouteChild;

implementation

uses
  eclbr.objectlib,
  dmfbr.exception;

function RouteModule(const APath: string; const AModule: TModuleClass): TRouteModule;
begin
  Result := nil;
  if Assigned(AModule) then
    Result := TRouteModule.AddModule(APath, AModule, nil{, []}) as TRouteModule;
end;

function RouteModule(const APath: string; const AModule: TModuleClass;
  const AMiddlewares: TMiddlewares): TRouteModule;
begin
  Result := nil;
  if Assigned(AModule) then
    Result := TRouteModule.AddModule(APath,
                                     AModule,
                                     AMiddlewares) as TRouteModule;
end;

function RouteChild(const APath: string; const AModule: TModuleClass;
  const AMiddlewares: TMiddlewares): TRouteChild;
begin
  Result := TRouteChild.AddModule(APath,
                                  AModule,
                                  AMiddlewares) as TRouteChild;
end;

{ TModuleAbstract }

constructor TModule.Create;
begin
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  FService := FAppInjector^.Get<TModuleService>;
  FRouteHandlers := TObjectList<TRouteHandler>.Create;
  _BindModule;
  _AddRoutes;
  _RouteHandlers;
end;

destructor TModule.Destroy;
begin
  FAppInjector := nil;
  // Destroy as rotas do modulo
  _DestroyRoutes;
  // Destroy o injector do modulo
  _DestroyInjector;
  // Libera o serviço
  FService.Free;
  // Libera os routehendlers
  FRouteHandlers.Free;
  // Console delphi
  {$IFDEF DEBUG}
  DebugPrint(Format('[InstanceLoad] %s dependencies destroyed', [Self.ClassName]));
  {$ENDIF}
  inherited;
end;

function TModule.Binds: TBinds;
begin
  Result := [];
end;

function TModule.ExportedBinds: TExportedBinds;
begin
  Result := [];
end;

function TModule.Imports: TImports;
begin
  Result := [];
end;

function TModule.RouteHandlers: TRouteHandlers;
begin
  Result := [];
end;

function TModule.Routes: TRoutes;
begin
  Result := [];
end;

procedure TModule._BindModule;
begin
  FService.BindModule(Self)
end;

procedure TModule._AddRoutes;
begin
  FService.AddRoutes(Self);
end;

procedure TModule._DestroyInjector;
begin
  FService.ExtractInjector<TAppInjector>(Self.ClassName);
end;

procedure TModule._DestroyRoutes;
begin
  FService.RemoveRoutes(Self.ClassName);
end;

procedure TModule._RouteHandlers;
var
  LHandler: TClass;
begin
  for LHandler in RouteHandlers do
  begin
    FRouteHandlers.Add(TRouteHandler(AppInjector^.Get<TObjectLib>
                                                 .Factory(LHandler)));
  end;
end;

end.






