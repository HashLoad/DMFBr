unit dmfbr.request;

interface

uses
  SysUtils,
  Classes,
  EncdDecd,
  Generics.Collections,
  dmfbr.request.data;

type
  TAuth = class
  private
    FUsername: string;
    FPassword: string;
  public
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
  end;

  TBearer = class
  private
    FToken: string;
  public
    property Token: string read FToken write FToken;
  end;

  IRouteRequest = interface
    ['{F344E29D-8FF3-4F39-BC8C-53EE130E02D4}']
    procedure SetObject(const AObject: TObject);
    procedure SetBody(const ABody: string);
    function Header: TRequestData;
    function Querys: TRequestData;
    function Params: TRequestData;
    function Method: string;
    function Body: string;
    function URL: string;
    function Host: string;
    function Port: integer;
    function ContentType: string;
    function Username: string;
    function Password: string;
    function Token: string;
    function AsObject: TObject;
  end;

  TRouteRequest = class(TInterfacedObject, IRouteRequest)
  private
    class var FAuth: TAuth;
    class var FBearer: TBearer;
    FObject: TObject;
    FHeader: TRequestData;
    FParams: TRequestData;
    FQuerys: TRequestData;
    FMethod: string;
    FURL: string;
    FBody: string;
    FHost: string;
    FPort: integer;
    FContentType: string;
  public
    constructor Create(const AHeader: TStrings; const AParams: TStrings;
      const AQuerys: TStrings; const ABody: string; const AHost: string;
      const AContentType: string; const AMethod: string;
      const AURL: string; const APort: integer; const AUserName: string;
      const APassword: string; const AToken: string);
    destructor Destroy; override;
    procedure SetObject(const AObject: TObject);
    procedure SetBody(const ABody: string);
    function Header: TRequestData;
    function Params: TRequestData;
    function Querys: TRequestData;
    function Body: string;
    function Host: string;
    function ContentType: string;
    function Method: string;
    function URL: string;
    function Port: integer;
    function Username: string;
    function Password: string;
    function Token: string;
    function AsObject: TObject;
    class procedure SetUserData(const AUserName: string; const APassword: string;
      const AToken: string);
  end;

implementation

{ TRouteRequest }

function TRouteRequest.Body: string;
begin
  Result := FBody;
end;

function TRouteRequest.ContentType: string;
begin
  Result := FContentType;
end;

constructor TRouteRequest.Create(const AHeader: TStrings; const AParams: TStrings;
  const AQuerys: TStrings; const ABody: string; const AHost: string;
  const AContentType: string; const AMethod: string;
  const AURL: string; const APort: integer; const AUserName: string;
  const APassword: string; const AToken: string);
begin
  FHeader := TRequestData.Create;
  FParams := TRequestData.Create;
  FQuerys := TRequestData.Create;
  FHeader.Assign(AHeader);
  FParams.Assign(AParams);
  FQuerys.Assign(AQuerys);
  FBody := ABody;
  FHost := AHost;
  FContentType := AContentType;
  FMethod := AMethod;
  FURL := AURL;
  FPort := APort;
  FAuth.Username := AUserName;
  FAuth.Password := APassword;
  FBearer.Token := AToken;
end;

destructor TRouteRequest.Destroy;
begin
  FHeader.Free;
  FParams.Free;
  FQuerys.Free;
  if Assigned(FObject) then
    FObject.Free;
  inherited;
end;

function TRouteRequest.Header: TRequestData;
begin
  Result := FHeader;
end;

function TRouteRequest.Host: string;
begin
  Result := FHost;
end;

function TRouteRequest.Method: string;
begin
  Result := FMethod;
end;

function TRouteRequest.AsObject: TObject;
begin
  Result := FObject;
end;

function TRouteRequest.Params: TRequestData;
begin
  Result := FParams;
end;

function TRouteRequest.Password: string;
begin
  Result := FAuth.Password;
end;

function TRouteRequest.Port: integer;
begin
  Result := FPort;
end;

function TRouteRequest.Querys: TRequestData;
begin
  Result := FQuerys;
end;

procedure TRouteRequest.SetBody(const ABody: string);
begin
  FBody := ABody;
end;

procedure TRouteRequest.SetObject(const AObject: TObject);
begin
  FObject := AObject;
end;

class procedure TRouteRequest.SetUserData(const AUserName: string;
  const APassword: string; const AToken: string);
begin
  FAuth.Username := AUserName;
  FAuth.Password := APassword;
  FBearer.Token := AToken;
end;

function TRouteRequest.Token: string;
begin
  Result := FBearer.Token;
end;

function TRouteRequest.URL: string;
begin
  Result := FURL;
end;

function TRouteRequest.Username: string;
begin
  Result := FAuth.Username;
end;

initialization
    TRouteRequest.FAuth := TAuth.Create;
    TRouteRequest.FBearer := TBearer.Create;

finalization
    TRouteRequest.FAuth.Free;
    TRouteRequest.FBearer.Free;

end.
