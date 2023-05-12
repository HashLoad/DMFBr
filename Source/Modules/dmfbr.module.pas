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

unit dmfbr.module;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Generics.Collections,
  dmfbr.module.abstract,
  dmfbr.route.abstract,
  dmfbr.module.service,
  dmfbr.route,
  dmfbr.bind;

type
  TRouteMiddleware = dmfbr.route.abstract.TRouteMiddleware;
  TRoute = dmfbr.route.TRoute;
  TRouteAbstract = dmfbr.route.abstract.TRouteAbstract;
  TRoutes = dmfbr.module.abstract.TRoutes;
  TBinds = dmfbr.module.abstract.TBinds;
  TImports = dmfbr.module.abstract.TImports;
  TExportedBinds = dmfbr.module.abstract.TExportedBinds;

  TModule = class(TModuleAbstract)
  private
    FService: TModuleService;
    procedure _DestroyRoutes;
    procedure _DestroyInjector;
    procedure _AddRoutes;
    procedure _BindModule;
  public
    constructor Create; override;
    destructor Destroy; override;
    function Routes: TRoutes; override;
    function Binds: TBinds; override;
    function Imports: TImports; override;
    function ExportedBinds: TExportedBinds; override;
  end;

  // Só para facilitar a sintaxe nos módulos
  Bind<T: class, constructor> = class(TBind<T>)
  end;

// RouteModule
function RouteModule(const APath: string; const AModule: TClass;
  const ARouteGuardCallback: TRouteGuardCallback = nil;
  const AMiddlewares: TMiddlewares = []): TRouteModule; overload;

function RouteModule(const APath: string; const AModule: TClass;
  const AMiddlewares: TMiddlewares): TRouteModule; overload;

// RouteChild
function RouteChild(const APath: string; const AModule: TClass;
  const ARouteGuardCallback: TRouteGuardCallback = nil;
  const AMiddlewares: TMiddlewares = []): TRouteChild;

implementation

uses
  dmfbr.injector,
  dmfbr.exception;

function RouteModule(const APath: string; const AModule: TClass;
  const ARouteGuardCallback: TRouteGuardCallback;
  const AMiddlewares: TMiddlewares): TRouteModule;
begin
  Result := nil;
  if Assigned(AModule) then
    Result := TRouteModule.AddModule(APath,
                                     AModule,
                                     ARouteGuardCallback,
                                     AMiddlewares) as TRouteModule;
end;

function RouteModule(const APath: string; const AModule: TClass;
  const AMiddlewares: TMiddlewares): TRouteModule;
begin
  Result := nil;
  if Assigned(AModule) then
    Result := TRouteModule.AddModule(APath,
                                     AModule,
                                     nil,
                                     AMiddlewares) as TRouteModule;
end;

function RouteChild(const APath: string; const AModule: TClass;
  const ARouteGuardCallback: TRouteGuardCallback;
  const AMiddlewares: TMiddlewares): TRouteChild;
begin
  Result := TRouteChild.AddModule(APath,
                                  AModule,
                                  ARouteGuardCallback,
                                  AMiddlewares) as TRouteChild;
end;

{ TModuleAbstract }

constructor TModule.Create;
begin
  FService := AppInjector.Get<TModuleService>;
  _BindModule;
  _AddRoutes;
end;

destructor TModule.Destroy;
begin
  // Destroy as rotas do modulo
  _DestroyRoutes;
  // Destroy o injector do modulo
  _DestroyInjector;
  // Libera o serviço
  FService.Free;
  // Console delphi
  DebugPrint(Format('-- %s DESTROYED', [Self.ClassName]));
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

end.

