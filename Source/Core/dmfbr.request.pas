unit dmfbr.request;

interface

uses
  SysUtils,
  Classes,
  EncdDecd;

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
    procedure SetHeader(const AHeader: string);
    procedure SetBody(const ABody: string);
    procedure SetParams(const AParams: TStrings);
    procedure SetQuerys(const AQueryFields: TStrings);
    procedure SetContentType(const AContentType: string);
    procedure SetHost(const AHost: string);
    procedure SetPathInfo(const APathInfo: string);
    function Header: string;
    function Body: string;
    function QueryFields: TStrings;
    function Params: TStrings;
    function Host: string;
    function ContentType: string;
    function PathInfo: string;
    function Username: string;
    function Password: string;
    function Token: string;
  end;

  TRouteRequest = class(TInterfacedObject, IRouteRequest)
  private
    class var FAuth: TAuth;
    FBearer: TBearer;
    FHeader: string;
    FParams: TStrings;
    FQueryFields: TStrings;
    FBody: string;
    FHost: string;
    FContentType: string;
    FPathInfo: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetHeader(const AHeader: string);
    procedure SetBody(const ABody: string);
    procedure SetParams(const AParams: TStrings);
    procedure SetQuerys(const AQueryFields: TStrings);
    procedure SetContentType(const AContentType: string);
    procedure SetHost(const AHost: string);
    procedure SetPathInfo(const APathInfo: string);
    function Header: string;
    function Body: string;
    function QueryFields: TStrings;
    function Params: TStrings;
    function Host: string;
    function ContentType: string;
    function PathInfo: string;
    function Username: string;
    function Password: string;
    function Token: string;
  end;

implementation

{ TDMFRequest }

function TRouteRequest.Body: string;
begin
  Result := FBody;
end;

function TRouteRequest.ContentType: string;
begin
  Result := FContentType;
end;

constructor TRouteRequest.Create;
begin
  FBearer := TBearer.Create;
end;

destructor TRouteRequest.Destroy;
begin
  FBearer.Free;
  inherited;
end;

function TRouteRequest.Header: string;
begin
  Result := FHeader;
end;

function TRouteRequest.Host: string;
begin
  Result := FHost;
end;

function TRouteRequest.Params: TStrings;
begin
  Result := FParams;
end;

function TRouteRequest.Password: string;
begin
  Result := FAuth.Password;
end;

function TRouteRequest.PathInfo: string;
begin
  Result := FPathInfo;
end;

function TRouteRequest.QueryFields: TStrings;
begin
  Result := FQueryFields;
end;

procedure TRouteRequest.SetParams(const AParams: TStrings);
begin
  FParams := AParams;
end;

procedure TRouteRequest.SetPathInfo(const APathInfo: string);
begin
  FPathInfo := APathInfo;
end;

procedure TRouteRequest.SetQuerys(const AQueryFields: TStrings);
begin
  FQueryFields := AQueryFields;
end;

function TRouteRequest.Token: string;
begin
  Result := FBearer.Token;
end;

function TRouteRequest.Username: string;
begin
  Result := FAuth.Username;
end;

procedure TRouteRequest.SetBody(const ABody: string);
begin
  FBody := ABody;
end;

procedure TRouteRequest.SetContentType(const AContentType: string);
begin
  FContentType := AContentType;
end;

procedure TRouteRequest.SetHeader(const AHeader: string);
var
  LBase64Auth: string;
  LDecodedAuth: string;
  LAuthBasic: string;
  LAuthBearer: string;
begin
  FHeader := AHeader;
  LAuthBasic := 'Basic';
  LAuthBearer := 'Bearer';
  if Pos(LAuthBasic, FHeader) > 0 then
  begin
    LBase64Auth := Copy(FHeader, Pos(LAuthBasic, FHeader) + 6, Length(FHeader));
    LDecodedAuth := DecodeString(LBase64Auth);
    FAuth.Username := Copy(LDecodedAuth, 1, Pos(':', LDecodedAuth) - 1);
    FAuth.Password := Copy(LDecodedAuth, Pos(':', LDecodedAuth) + 1, Length(LDecodedAuth));
  end
  else if Pos(LAuthBearer, FHeader) > 0 then
  begin
    LDecodedAuth := Copy(FHeader, Pos(LAuthBearer, FHeader) + Length(LAuthBearer) + 1, Length(FHeader));
    FBearer.Token := Trim(LDecodedAuth);
  end;
end;

procedure TRouteRequest.SetHost(const AHost: string);
begin
  FHost := AHost;
end;

initialization
    TRouteRequest.FAuth := TAuth.Create;

finalization
    TRouteRequest.FAuth.Free;

end.
