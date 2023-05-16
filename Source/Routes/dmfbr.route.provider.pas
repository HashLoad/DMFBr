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

unit dmfbr.route.provider;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.exception,
  dmfbr.module.abstract,
  dmfbr.route.param,
  dmfbr.tracker,
  dmfbr.injector,
  dmfbr.route,
  dmfbr.route.abstract,
  eclbr.objects;

type
  TRouteProvider = class
  private
    FTracker: TTracker;
    function _RouteMiddleware(const ARoute: TRouteAbstract): TRouteAbstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeTracker(const ATracker: TTracker);
    function GetRoute(const AArgs: TRouteParam): TResultPair<Exception, TRouteAbstract>;
  end;

implementation

constructor TRouteProvider.Create;
begin

end;

destructor TRouteProvider.Destroy;
begin
  if Assigned(FTracker) then
    FTracker := nil;
  inherited;
end;

procedure TRouteProvider.IncludeTracker(
  const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

function TRouteProvider._RouteMiddleware(
  const ARoute: TRouteAbstract): TRouteAbstract;
var
  LMiddleware: TRouteMiddleware;
  LFor: integer;
begin
  Result := ARoute;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    if Assigned(LMiddleware.AfterCallback) then
      LMiddleware.AfterCallback(ARoute);
  end;
end;

function TRouteProvider.GetRoute(
  const AArgs: TRouteParam): TResultPair<Exception, TRouteAbstract>;
begin
  Result.Success(FTracker.FindRoute(AArgs));
  if Result.ValueSuccess = nil then
    Exit;
  if not Assigned(Result.ValueSuccess.ModuleInstance) then
  begin
    Result.ValueSuccess.ModuleInstance := AppInjector.Get<TObjectFactory>
                                                     .CreateInstance(Result.ValueSuccess.Module);
    // Console delphi
    DebugPrint(Format('-- %s CREATED', [Result.ValueSuccess.Module.ClassName]));
  end;
  // Vai aos eventos middlewares se existir
  _RouteMiddleware(Result.ValueSuccess);
end;

end.

