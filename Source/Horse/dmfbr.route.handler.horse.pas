unit dmfbr.route.handler.horse;

interface

uses
  Rtti,
  SysUtils,
  Horse,
  Horse.Callback,
  dmfbr.route.handler;

type
  TRouteHandlerHorse = class(TRouteHandler)
  public
    function RouteGet(const ARoute: string; const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse; reintroduce;
    function RoutePost(const ARoute: string; const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse; reintroduce;
    function RoutePut(const ARoute: string; const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse; reintroduce;
    function RoutePatch(const ARoute: string; const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse; reintroduce;
    function RouteDelete(const ARoute: string; const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse; reintroduce;
  end;

implementation

{ TNFeRouteHandlerHorse }

function TRouteHandlerHorse.RouteDelete(const ARoute: string;
  const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse;
begin
  inherited RouteDelete(ARoute);
  THorse.Delete(ARoute, ACallback);
  Result := Self;
end;

function TRouteHandlerHorse.RouteGet(const ARoute: string;
  const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse;
begin
  inherited RouteGet(ARoute);
  THorse.Get(ARoute, ACallback);
  Result := Self;
end;

function TRouteHandlerHorse.RoutePatch(const ARoute: string;
  const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse;
begin
  inherited RoutePatch(ARoute);
  THorse.Patch(ARoute, ACallback);
  Result := Self;
end;

function TRouteHandlerHorse.RoutePost(const ARoute: string;
  const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse;
begin
  inherited RoutePost(ARoute);
  THorse.Post(ARoute, ACallback);
  Result := Self;
end;

function TRouteHandlerHorse.RoutePut(const ARoute: string;
  const ACallback: THorseCallbackRequestResponse): TRouteHandlerHorse;
begin
  inherited RoutePut(ARoute);
  THorse.Put(ARoute, ACallback);
  Result := Self;
end;

end.
