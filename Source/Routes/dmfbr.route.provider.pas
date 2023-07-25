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

unit dmfbr.route.provider;

interface

uses
  Rtti,
  SysUtils,
  result.pair,
  dmfbr.exception,
  dmfbr.module.abstract,
  dmfbr.route.param,
  dmfbr.tracker,
  dmfbr.injector,
  dmfbr.route,
  dmfbr.route.abstract,
  eclbr.objectlib;

type
  TRouteProvider = class
  private
    FTracker: TTracker;
    FAppInjector: PAppInjector;
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
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
end;

destructor TRouteProvider.Destroy;
begin
  FAppInjector := nil;
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
  LMiddleware: TClass;
  LFor: integer;
  LAfter: TRttiMethod;
  LContext: TRttiContext;
  LParam: TValue;
begin
  Result := ARoute;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor];
    LAfter := LContext.GetType(LMiddleware).GetMethod('After');
    if Assigned(LAfter) then
    begin
      LParam := TValue.From(ARoute);
      LAfter.Invoke(LMiddleware, [LParam]);
    end;
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
    Result.ValueSuccess.ModuleInstance := FAppInjector^.Get<TObjectLib>
                                                       .Factory(Result.ValueSuccess.Module);
  end;
  // Vai aos eventos middlewares se existir
  _RouteMiddleware(Result.ValueSuccess);
end;

end.
