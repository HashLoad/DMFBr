unit ping.route.handler;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.modular,
  ping.controller,
  dmfbr.route.handler;

type
  TPingRouteHandler = class(TRouteHandler)
  protected
    procedure RegisterRoutes; override;
  public
    function Ping: string;
  end;

implementation

uses
  dmfbr.route.abstract;

{ TPingRouteHandler }

procedure TPingRouteHandler.RegisterRoutes;
begin

end;

function TPingRouteHandler.Ping: string;
var
  LResultPing: string;
  LResultRoute: TResultPair<Exception, TRouteAbstract>;
begin
  LResultPing := '';
  LResultRoute := Modular.LoadRouteModule('/ping');
  try
    LResultRoute.TryException(
      procedure (Error: Exception)
      begin
        // Failure
        LResultPing := Error.Message;
        Error.Free;
      end,
      procedure (Route: TRouteAbstract)
      begin
        // Success
        LResultPing := Modular.Get<TPingController>.Ping;
      end);
   finally
     Modular.DisposeRouteModule('/ping');
   end;
  Result := LResultPing;
end;

end.