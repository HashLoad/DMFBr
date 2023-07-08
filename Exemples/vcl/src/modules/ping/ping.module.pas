unit ping.module;

interface

uses
  ping.controller,
  ping.service,
  dmfbr.module;

type
  TPingModule = class(TModule)
  public
    function Imports: TImports; override;
    function Binds: TBinds; override;
    function Routes: TRoutes; override;
    function RouteHandlers: TRouteHandlers; override;
    function ExportedBinds: TExportedBinds; override;
  end;

implementation

{ TPingModule }

function TPingModule.Binds: TBinds;
begin
  Result := [Bind<TPingService>.Factory,
             Bind<TPingController>.Singleton];
end;
function TPingModule.ExportedBinds: TExportedBinds;
begin
  Result := [];
end;

function TPingModule.Imports: TImports;
begin
  Result := [];
end;

function TPingModule.RouteHandlers: TRouteHandlers;
begin
  Result := [];
end;

function TPingModule.Routes: TRoutes;
begin
  Result := [];
end;

end.