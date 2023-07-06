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
unit dmfbr.route.handler;

interface

uses
  Rtti,
  SysUtils,
  dmfbr.injector;

type
  TRouteHandler = class abstract
  private
    FAppInjector: PAppInjector;
    procedure _RegisterRouteHandle(const ARoute: string);
  protected
    procedure RegisterRoutes; virtual; abstract;
  public
    constructor Create; overload; virtual;
    function RouteGet(const ARoute: string): TRouteHandler; virtual;
    function RoutePost(const ARoute: string): TRouteHandler; virtual;
    function RoutePut(const ARoute: string): TRouteHandler; virtual;
    function RouteDelete(const ARoute: string): TRouteHandler; virtual;
    function RoutePatch(const ARoute: string): TRouteHandler; virtual;
  end;

implementation

uses
  dmfbr.register,
  dmfbr.exception;

constructor TRouteHandler.Create;
begin
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  RegisterRoutes;
end;

function TRouteHandler.RouteDelete(const ARoute: string): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RouteGet(const ARoute: string): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePatch(const ARoute: string): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePost(const ARoute: string): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePut(const ARoute: string): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

procedure TRouteHandler._RegisterRouteHandle(const ARoute: string);
begin
  if not FAppInjector^.Get<TRegister>.ResgisterContainsKey(Self.ClassName) then
    exit;
  if FAppInjector^.Get<TRegister>.RouteContainsKey(ARoute) then
    exit;
  FAppInjector^.Get<TRegister>.Add(ARoute, Self.ClassName);
end;

end.
