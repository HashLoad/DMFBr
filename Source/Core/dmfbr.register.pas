unit dmfbr.register;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  dmfbr.validation.interfaces,
  dmfbr.request,
  dmfbr.route.handler;

type
  TRegister = class
  strict private
    FRegisters: TDictionary<string, TRouteHandlerClass>;
    FRoutes: TDictionary<string, string>;
    FValidationPipe: IValidationPipe;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AClass: TRouteHandlerClass); overload;
    procedure Add(const AKey: string; const ARouteHandleName: string); overload;
    procedure UsePipes(const AValidationPipe: IValidationPipe);
    function ResgisterContainsKey(const AKey: string): boolean;
    function RouteContainsKey(const AKey: string): boolean;
    function FindRecord(const AKey: string): TRouteHandlerClass;
    function Pipe: IValidationPipe;
    function IsValidationPipe: boolean;
  end;

implementation

{ TRegister }

constructor TRegister.Create;
begin
  FRegisters := TDictionary<string, TRouteHandlerClass>.Create;
  FRoutes := TDictionary<string, string>.Create;
end;

destructor TRegister.Destroy;
begin
  FRoutes.Free;
  FRegisters.Free;
end;

function TRegister.FindRecord(const AKey: string): TRouteHandlerClass;
begin
  Result := nil;
  if not FRoutes.ContainsKey(AKey) then
    exit;
  if not FRegisters.ContainsKey(FRoutes[AKey]) then
    exit;
  Result := FRegisters[FRoutes[AKey]];
end;

function TRegister.IsValidationPipe: boolean;
begin
  Result := FValidationPipe <> nil;
end;

procedure TRegister.Add(const AClass: TRouteHandlerClass);
begin
  if not FRegisters.ContainsKey(AClass.ClassName) then
    FRegisters.Add(AClass.ClassName, AClass);
end;

procedure TRegister.Add(const AKey: string; const ARouteHandleName: string);
begin
  if not FRoutes.ContainsKey(AKey) then
    FRoutes.Add(AKey, ARouteHandleName);
end;

function TRegister.ResgisterContainsKey(const AKey: string): boolean;
begin
  Result := FRegisters.ContainsKey(AKey);
end;

function TRegister.RouteContainsKey(const AKey: string): boolean;
begin
  Result := FRoutes.ContainsKey(AKey);
end;

procedure TRegister.UsePipes(const AValidationPipe: IValidationPipe);
begin
  FValidationPipe := AValidationPipe;
end;

function TRegister.Pipe: IValidationPipe;
begin
  Result := FValidationPipe;
end;

end.
