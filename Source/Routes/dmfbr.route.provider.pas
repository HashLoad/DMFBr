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
  dmfbr.route.abstract,
  eclbr.rtti.objects;

type
  TRouteProvider = class
  private
    FTracker: TTracker;
    function _RouteMiddleware(const ARoute: TRouteAbstract): TRouteAbstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeTracker(const ATracker: TTracker);
    function GetRoute(const AArgs: TRouteParam): TResultPair<boolean, string>;
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
  const AArgs: TRouteParam): TResultPair<boolean, string>;
var
  LRoute: TRouteAbstract;
begin
  try
    LRoute := FTracker.FindRoute(AArgs);
    if LRoute = nil then
    begin
      Result.Failure('404');
      Exit;
    end;
    if not Assigned(LRoute.ModuleInstance) then
    begin
      LRoute.ModuleInstance := AppInjector.Get<TObjectFactory>
                                          .CreateInstance(LRoute.Module);
      // Console delphi
      DebugPrint(Format('-- %s CREATED', [LRoute.Module.ClassName]));
    end;
    LRoute := _RouteMiddleware(LRoute);
    Result.Success(True);
  except
    on E: TRouteGuardianAuthorized do
      Result.Failure(E.Message);
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

end.

