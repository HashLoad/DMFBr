unit dmfbr.route.manager;

interface

uses
  SysUtils,
  Generics.Collections,
  RegularExpressions;

type
  TRouteManager = class
  private
    FEndPoints: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    function FindEndPoint(const ARoute: string): string;
    function RemoveSuffix(const ARoute: string): string;
    function EndPoints: TList<string>;
  end;

implementation

{ TDMFBrUtils }

constructor TRouteManager.Create;
begin
  FEndPoints := TList<string>.Create;
end;

destructor TRouteManager.Destroy;
begin
  FEndPoints.Free;
  inherited;
end;

function TRouteManager.EndPoints: TList<string>;
begin
  Result := FEndPoints;
end;

function TRouteManager.FindEndPoint(const ARoute: string): string;
var
  LURI: string;
  LIndex: integer;
begin
  Result := '';
  LURI := LowerCase(ARoute);
  LIndex := FEndpoints.IndexOf(LURI);
  if LIndex > -1 then
    Result := FEndpoints.Items[LIndex];
end;

function TRouteManager.RemoveSuffix(const ARoute: string): string;
const
  LPattern = '(/{[^/]*})|(/:[^/]+)$';
begin
  Result := TRegEx.Replace(ARoute, LPattern, '');
end;

end.
