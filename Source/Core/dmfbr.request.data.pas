unit dmfbr.request.data;

interface

uses
  Rtti,
  SysUtils,
  Classes,
  DateUtils,
  Generics.Collections;

type
  TKeyValue = TDictionary<string, TValue>;
  TFiles = TDictionary<string, TStream>;

  TRequestData = class
  private
    FKeyValue: TKeyValue;
    FFiles: TFiles;
    FContent: TStrings;
    FRequired: boolean;
    function GetItem(const AKey: string): TValue;
    function GetDictionary: TKeyValue;
    function GetCount: integer;
    function GetContent: TStrings;
    function AsString(const AKey: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(const AContent: TStrings);
    procedure AddOrSetValue(const AKey: string; const AValue: TValue);
    function Required(const AValue: boolean): TRequestData;
    function ContainsKey(const AKey: string): boolean;
    function ContainsValue(const AValue: string): boolean;
    function ToArray: TArray<TPair<string, string>>;
    function TryGetValue(const AKey: string; var AValue: string): boolean;
    function AddStream(const AKey: string; const AContent: TStream): TRequestData;
    function Value<T>(const AKey: string): T;
    property Content: TStrings read GetContent;
    property Count: integer read GetCount;
    property Items[const AKey: string]: TValue read GetItem; default;
    property Dictionary: TKeyValue read GetDictionary;
  end;

implementation

function TRequestData.ContainsKey(const AKey: string): boolean;
begin
  Result := FKeyValue.ContainsKey(AKey);
end;

function TRequestData.ContainsValue(const AValue: string): boolean;
begin
  Result := FKeyValue.ContainsValue(AValue);
end;

constructor TRequestData.Create;
begin
  FKeyValue := TKeyValue.Create;
  FContent := TStringList.Create;
  FRequired := False;
end;

destructor TRequestData.Destroy;
begin
  FKeyValue.Free;
  FContent.Free;
  if Assigned(FFiles) then
    FFiles.Free;
  inherited;
end;

procedure TRequestData.AddOrSetValue(const AKey: string; const AValue: TValue);
begin
  FKeyValue.AddOrSetValue(Akey, AValue);
end;

function TRequestData.AddStream(const AKey: string; const AContent: TStream): TRequestData;
begin
  Result := Self;
  if not Assigned(FFiles) then
    FFiles := TFiles.Create;
  FFiles.AddOrSetValue(AKey, AContent);
end;

function TRequestData.AsString(const AKey: string): string;
var
  LKey: string;
begin
  Result := EmptyStr;
  for LKey in FKeyValue.Keys do
  begin
    if AnsiCompareText(LKey, AKey) = 0 then
      exit(FKeyValue.Items[LKey].AsString);
  end;
end;

function TRequestData.GetContent: TStrings;
var
  LKey: string;
begin
  for LKey in FKeyValue.Keys do
    FContent.Add(Format('%s=%s', [LKey, FKeyValue[LKey].AsString]));
  Result := FContent;
end;

procedure TRequestData.Assign(const AContent: TStrings);
var
  LFor: integer;
  LKey, LValue: string;
  LSeparatorPos: integer;
begin
  FContent.Assign(AContent);
  FKeyValue.Clear;
  for LFor := 0 to FContent.Count - 1 do
  begin
    LSeparatorPos := Pos('=', FContent[LFor]);
    if LSeparatorPos = 0 then
      continue;
    LKey := Trim(Copy(FContent[LFor], 1, LSeparatorPos - 1));
    LValue := Trim(Copy(FContent[LFor], LSeparatorPos + 1, Length(FContent[LFor])));
    FKeyValue.AddOrSetValue(LKey, LValue);
  end;
end;

function TRequestData.GetCount: integer;
begin
  Result := FKeyValue.Count;
end;

function TRequestData.GetItem(const AKey: string): TValue;
var
  LKey: string;
begin
  for LKey in FKeyValue.Keys do
  begin
    if AnsiCompareText(LKey, AKey) = 0 then
      exit(FKeyValue[LKey]);
  end;
  Result := EmptyStr;
end;

function TRequestData.Required(const AValue: boolean): TRequestData;
begin
  Result := Self;
  FRequired := AValue;
end;

function TRequestData.GetDictionary: TKeyValue;
begin
  Result := FKeyValue;
end;

function TRequestData.ToArray: TArray<TPair<string, string>>;
var
  LPairArray: TArray<TPair<string, string>>;
  LPair: TPair<string, TValue>;
  LIndex: Integer;
begin
  SetLength(LPairArray, FKeyValue.Count);
  LIndex := 0;
  for LPair in FKeyValue do
  begin
    LPairArray[LIndex].Key := LPair.Key;
    LPairArray[LIndex].Value := LPair.Value.AsString;
    Inc(LIndex);
  end;
  Result := LPairArray;
end;

function TRequestData.TryGetValue(const AKey: string; var AValue: string): boolean;
begin
  Result := ContainsKey(AKey);
  if Result then
    AValue := AsString(AKey);
end;

function TRequestData.Value<T>(const AKey: string): T;
begin
  Result := Default(T);
  if not FKeyValue.ContainsKey(AKey) then
    exit;
  Result := FKeyValue.Items[Akey].AsType<T>;
end;

end.
