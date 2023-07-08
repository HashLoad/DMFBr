unit app.module;

interface

uses
  ping.module,
  ping.route.handler,
  dmfbr.module;

type
  TAppModule = class(TModule)
  public
    function Imports: TImports; override;
    function Binds: TBinds; override;
    function Routes: TRoutes; override;
    function RouteHandlers: TRouteHandlers; override;
    function ExportedBinds: TExportedBinds; override;
  end;

implementation

{ TAppModule }

function TAppModule.Binds: TBinds;
begin
  Result := [];
end;
function TAppModule.ExportedBinds: TExportedBinds;
begin
  Result := [];
end;

function TAppModule.Imports: TImports;
begin
  Result := [];
end;

function TAppModule.RouteHandlers: TRouteHandlers;
begin
  Result := [TPingRouteHandler];
end;

function TAppModule.Routes: TRoutes;
begin
  Result := [RouteModule('/ping', TPingModule)];
end;

end.