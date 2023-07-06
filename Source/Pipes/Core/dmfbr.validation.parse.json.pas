unit dmfbr.validation.parse.json;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  Classes,
  Variants,
  TypInfo,
  Types,
  Generics.Collections;

type
  TStringBuilderHelper = class helper for TStringBuilder
  public
    procedure ReplaceLastChar(const AChar: Char);
  end;

  TCallbackSetValue = reference to procedure(const AInstance: TObject;
                                             const AProperty: TRttiProperty;
                                             const AValue: Variant);
  EJsonBrException = class(Exception);
  TArrayStringMap = array of string;
  TArrayVariantMap = array of Variant;
  TJsonTypeKindMap = (jtkUndefined, jtkObject, jtkArray);
  TJsonValueKindMap = (jvkNone, jvkNull, jvkString, jvkInteger, jvkFloat,
                       jvkObject, jvkArray, jvkBoolean);
  PropWrap = packed record
    FillBytes: array [0..SizeOf(pointer)-2] of byte;
    Kind: byte;
  end;

  TJsonDataMap = record
  private
    FVType: TVarType;
    FVKind: TJsonTypeKindMap;
    FVCount: integer;
    FNames: TArrayStringMap;
    FValues: TArrayVariantMap;
    procedure SetKind(const Value: TJsonTypeKindMap); //inline;
    procedure SetValue(const AName: string; const AValue: Variant); //inline;
    procedure SetItem(AIndex: integer; const AItem: Variant); //inline;
    function GetKind: TJsonTypeKindMap; //inline;
    function GetCount: integer; //inline;
    function GetVarData(const AName: string; var ADest: TVarData): boolean; //inline;
    function GetValueCopy(const AName: string): Variant; //inline;
    function GetValue(const AName: string): Variant; //inline;
    function GetItem(AIndex: integer): Variant; //inline;
    function GetListType(LRttiType: TRttiType): TRttiType; //inline;
    function GetDataType: TJsonValueKindMap; //inline;
    type
      TJsonParserMap = record
      private
        FJson: string;
        FIndex: integer;
        FJsonLength: integer;
        procedure Init(const AJson: string; AIndex: integer = 1); //inline;
        procedure GetNextStringUnEscape(var AStr: string); //inline;
        function GetNextChar: Char; //inline;
        function GetNextNonWhiteChar: Char; //inline;
        function CheckNextNonWhiteChar(AChar: Char): boolean; //inline;
        function GetNextString(out AStr: string): boolean; //inline;
        function GetNextJson(out AValue: Variant): TJsonValueKindMap; //inline;
        function GetNextAlphaPropName(out AFieldName: string): boolean; //inline;
        function ParseJsonObject(out AData: TJsonDataMap): boolean; //inline;
        function ParseJsonArray(out AData: TJsonDataMap): boolean; //inline;
        function CopyIndex: integer; //inline;
      end;
  public
    function NameIndex(const AName: string): integer;
    function FromJson(const AJson: string): boolean;
    function ToJson: string;
    function ToObject(AObject: TObject): boolean;
    function Names: TArrayStringMap;
    function Values: TArrayVariantMap;
    procedure Init; overload;
    procedure Init(const AJson: string); overload;
    procedure InitFrom(const AValues: TArrayVariantMap); overload;
    procedure Clear;
    procedure AddValue(const AValue: Variant);
    procedure AddNameValue(const AName: string; const AValue: Variant);
    property Kind: TJsonTypeKindMap read GetKind write SetKind;
    property DataType: TJsonValueKindMap read GetDataType;
    property Count: integer read GetCount;
    property Value[const AName: string]: Variant read GetValue write SetValue; default;
    property ValueCopy[const AName: string]: Variant read GetValueCopy;
    property Item[AIndex: integer]: Variant read GetItem write SetItem;
  end;

  TJsonVariantMap = class(TInvokeableVariantType)
  public
    procedure Copy(var ADest: TVarData; const ASource: TVarData;
      const AIndirect: boolean); override;
    procedure Clear(var AVarData: TVarData); override;
    function GetProperty(var ADest: TVarData; const AVarData: TVarData;
      const AName: string): boolean; override;
    function SetProperty(const AVarData: TVarData; const AName: string;
      const AValue: TVarData): boolean; override;
    procedure Cast(var ADest: TVarData; const ASource: TVarData); override;
    procedure CastTo(var ADest: TVarData; const ASource: TVarData;
      const AVarType: TVarType); override;
  end;

  TJsonMap = class
  private
    class var FCallbackSetValue: TCallbackSetValue;
  private
    class procedure SetInstanceProp(const AInstance: TObject; const AProperty:
      TRttiProperty; const AValue: Variant);
    class function JsonVariantData(const AValue: Variant): TJsonDataMap;
    class procedure AppendChar(var AStr: string; AChr: char);
  public
    class var UseISO8601DateFormat: boolean;
    function JsonVariant(const AValues: TArrayVariantMap): Variant; overload;
    function JsonVariant(const AJson: string): Variant; overload;
    class function StringToJson(const AText: string): string;
    class function ValueToJson(const AValue: Variant): string;
    class procedure Map(const AJson: string; const AClass: TClass;
      const ACallbackSetValue: TCallbackSetValue); static;
  end;

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): string;
function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: Boolean): TDateTime;

var
  JsonVariantType: TInvokeableVariantType;
  JsonBrFormatSettings: TFormatSettings;

implementation

{ TJsonBrObject }

function TJsonMap.JsonVariant(const AJson: String): Variant;
begin
  VarClear(Result);
  TJsonDataMap(Result).FromJson(AJson);
end;

function TJsonMap.JsonVariant(const AValues: TArrayVariantMap): Variant;
begin
  VarClear(Result);
  TJsonDataMap(Result).Init;
  TJsonDataMap(Result).FVKind := jtkArray;
  TJsonDataMap(Result).FVCount := Length(AValues);
  TJsonDataMap(Result).FValues := AValues;
end;

class function TJsonMap.JsonVariantData(const AValue: Variant): TJsonDataMap;
begin
  with TVarData(AValue) do
  begin
    if VType = JsonVariantType.VarType then
      Result := TJsonDataMap(AValue)
    else
    if VType = varByRef or varVariant then
      Result := TJsonDataMap(PVariant(VPointer)^)
    else
      raise EJsonBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [VType]);
  end;
end;

class procedure TJsonMap.AppendChar(var AStr: string; AChr: Char);
begin
  AStr := AStr + string(AChr);
end;

class function TJsonMap.StringToJson(const AText: string): String;
var
  LLen, LFor: integer;

  procedure DoEscape;
  var
    LChr: integer;
    LResultBuilder: TStringBuilder;
  begin
    LResultBuilder := TStringBuilder.Create;
    try
      LResultBuilder.Append('"' + Copy(AText, 1, LFor - 1));
      for LChr := LFor to LLen do
      begin
        case AText[LChr] of
          #8:  LResultBuilder.Append('\b');
          #9:  LResultBuilder.Append('\t');
          #10: LResultBuilder.Append('\n');
          #12: LResultBuilder.Append('\f');
          #13: LResultBuilder.Append('\r');
          '\': LResultBuilder.Append('\\');
          '"': LResultBuilder.Append('\"');
        else
          if AText[LChr] < ' ' then
            LResultBuilder.Append('\u00' + IntToHex(Ord(AText[LChr]), 2))
          else
            LResultBuilder.Append(AText[LChr]);
        end;
      end;
      LResultBuilder.Append('"');
      Result := LResultBuilder.ToString;
    finally
      LResultBuilder.Free;
    end;
  end;

begin
  LLen := Length(AText);
  for LFor := 1 to LLen do
//    case AText[Lfor] of
//     '[', ']': continue;
//    end;
    case AText[LFor] of
      #0 .. #31, '\', '"':
      begin
        DoEscape;
        exit;
      end;
    end;
  Result := '"' + AText + '"';
end;

class function TJsonMap.ValueToJson(const AValue: Variant): string;
var
  LInt64: int64;
  LDouble: double;
begin
  if TVarData(AValue).VType = JsonVariantType.VarType then
    Result := TJsonDataMap(AValue).ToJson
  else
  begin
    case TVarData(AValue).VType of
      varByRef, varVariant:
        Result := ValueToJson(PVariant(TVarData(AValue).VPointer)^);
      varNull:
        Result := 'null';
      varBoolean:
        begin
          if TVarData(AValue).VBoolean then
            Result := 'true'
          else
            Result := 'false';
        end;
      varDate:
        Result := '"' + DateTimeToIso8601(TVarData(AValue).VDouble, UseISO8601DateFormat) + '"';
    else
      if VarIsOrdinal(AValue) then
      begin
        LInt64 := AValue;
        Result := IntToStr(LInt64);
      end
      else
      if VarIsFloat(AValue) then
      begin
        LDouble := AValue;
        Result := FloatToStr(LDouble, JsonBrFormatSettings)
      end
      else
      if VarIsStr(AValue) then
        Result :=  StringToJson(VarToStr(AValue))
      else
        Result := VarToStr(AValue);
    end;
  end;
end;

class procedure TJsonMap.SetInstanceProp(const AInstance: TObject;
  const AProperty: TRttiProperty; const AValue: Variant);
begin
  if (AProperty = nil) and (AInstance = nil) then
    exit;
  if Assigned(FCallbackSetValue) then
    FCallbackSetValue(AInstance, AProperty, AValue);
end;

class procedure TJsonMap.Map(const AJson: string; const AClass: TClass;
  const ACallbackSetValue: TCallbackSetValue);
var
  LDoc: TJsonDataMap;
  LObject: TObject;
  LObjectList: TObjectList<TObject>;
  LFor: integer;
begin
  FCallbackSetValue := ACallbackSetValue;
  LDoc.Init(AJson);
  if LDoc.FVKind = jtkObject then
  begin
    LObject := AClass.Create;
    try
      LDoc.ToObject(LObject);
    finally
      LObject.Free;
    end;
  end
  else
  if LDoc.FVKind = jtkArray then
  begin
    LObjectList := TObjectList<TObject>.Create;
    LObjectList.OwnsObjects := True;
    try
      for LFor := 0 to LDoc.Count - 1 do
      begin
        LObject := AClass.Create;
        if not JsonVariantData(LDoc.FValues[LFor]).ToObject(LObject) then
        begin
          LObjectList.Free;
          exit;
        end;
        LObjectList.Add(LObject);
      end;
    finally
      LObjectList.Free;
    end;
  end;
end;

{ TJSONBrParser }

procedure TJsonDataMap.TJsonParserMap.Init(const AJson: String; AIndex: integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJsonDataMap.TJsonParserMap.GetNextChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    Result := Char(FJson[FIndex]);
    Inc(FIndex);
  end;
end;

function TJsonDataMap.TJsonParserMap.GetNextNonWhiteChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    repeat
      if FJson[FIndex] > ' ' then
      begin
        Result := Char(FJson[FIndex]);
        Inc(FIndex);
        exit;
      end;
      Inc(FIndex);
    until FIndex > FJsonLength;
  end;
end;

function TJsonDataMap.TJsonParserMap.CheckNextNonWhiteChar(AChar: Char): boolean;
begin
  Result := false;
  if FIndex <= FJsonLength then
  begin
    repeat
      if FJson[FIndex] > ' ' then
      begin
        Result := FJson[FIndex] = AChar;
        if Result then
          Inc(FIndex);
        exit;
      end;
      Inc(FIndex);
    until FIndex > FJsonLength;
  end;
end;

function TJsonDataMap.TJsonParserMap.CopyIndex: integer;
begin
  Result := {$IFDEF NEXTGEN}FIndex +1{$ELSE}FIndex{$ENDIF};
end;

procedure TJsonDataMap.TJsonParserMap.GetNextStringUnEscape(var AStr: String);
var
  LChar: Char;
  LCopy: String;
  LUnicode, LErr: integer;
begin
  repeat
    LChar := GetNextChar;
    case LChar of
      #0:  exit;
      '"': break;
      '\': begin
           LChar := GetNextChar;
           case LChar of
             #0 : exit;
             'b': TJsonMap.AppendChar(AStr, #08);
             't': TJsonMap.AppendChar(AStr, #09);
             'n': TJsonMap.AppendChar(AStr, #$0a);
             'f': TJsonMap.AppendChar(AStr, #$0c);
             'r': TJsonMap.AppendChar(AStr, #$0d);
             'u':
             begin
               LCopy := Copy(FJson, CopyIndex, 4);
               if Length(LCopy) <> 4 then
                 exit;
               Inc(FIndex, 4);
               Val('$' + LCopy, LUnicode, LErr);
               if LErr <> 0 then
                 exit;
               TJsonMap.AppendChar(AStr, Char(LUnicode));
             end;
           else
             TJsonMap.AppendChar(AStr, LChar);
           end;
         end;
    else
      TJsonMap.AppendChar(AStr, LChar);
    end;
  until false;
end;

function TJsonDataMap.TJsonParserMap.GetNextString(out AStr: String): boolean;
var
  LFor: integer;
begin
  Result := false;
  for LFor := FIndex to FJsonLength do
  begin
    case FJson[LFor] of
      '"': begin // end of String without escape -> direct copy
             AStr := Copy(FJson, CopyIndex, LFor - FIndex);
             FIndex := LFor + 1;
             Result := True;
             exit;
           end;
      '\': begin // need unescaping
             AStr := Copy(FJson, CopyIndex, LFor - FIndex);
             FIndex := LFor;
             GetNextStringUnEscape(AStr);
             Result := True;
             exit;
           end;
    end;
  end;
end;

function TJsonDataMap.TJsonParserMap.GetNextAlphaPropName(out AFieldName: String): boolean;
var
  LFor: integer;
begin
  Result := false;
  if (FIndex >= FJsonLength) or not (Ord(FJson[FIndex]) in [Ord('A') ..
                                                            Ord('Z'),
                                                            Ord('a') ..
                                                            Ord('z'),
                                                            Ord('_'),
                                                            Ord('$')]) then
    exit;
  for LFor := FIndex + 1 to FJsonLength do
    case Ord(FJson[LFor]) of
         Ord('0') ..
         Ord('9'),
         Ord('A') ..
         Ord('Z'),
         Ord('a') ..
         Ord('z'),
         Ord('_'):;
         Ord(':'),
         Ord('='):
      begin
        AFieldName := Copy(FJson, CopyIndex, LFor - FIndex);
        FIndex := LFor + 1;
        Result := True;
        exit;
      end;
    else
      exit;
    end;
end;

function TJsonDataMap.TJsonParserMap.GetNextJson(out AValue: Variant): TJsonValueKindMap;
var
  LStr: String;
  LInt64: int64;
  LValue: double;
  LStart, LErr: integer;
begin
  Result := jvkNone;
  case GetNextNonWhiteChar of
    'n': if Copy(FJson, CopyIndex, 3) = 'ull' then
         begin
           Inc(FIndex, 3);
           Result := jvkNull;
           AValue := Null;
         end;
    'f': if Copy(FJson, CopyIndex, 4) = 'alse' then
         begin
           Inc(FIndex, 4);
           Result := jvkBoolean;
           AValue := false;
         end;
    't': if Copy(FJson, CopyIndex, 3) = 'rue' then
         begin
           Inc(FIndex, 3);
           Result := jvkBoolean;
           AValue := true;
         end;
    '"': if GetNextString(LStr) then
         begin
           Result := jvkString;
           AValue := LStr;
         end;
    '{': if ParseJsonObject(TJsonDataMap(AValue)) then
           Result := jvkObject;
    '[': if ParseJsonArray(TJsonDataMap(AValue)) then
           Result := jvkArray;
    '-', '0' .. '9':
         begin
           LStart := CopyIndex - 1;
           while true do
             case FJson[FIndex] of
               '-', '+', '0' .. '9', '.', 'E', 'e':
                 Inc(FIndex);
             else
               break;
             end;
           LStr := Copy(FJson, LStart, CopyIndex - LStart);
           Val(LStr, LInt64, LErr);
           if LErr = 0 then
           begin
             Result := jvkInteger;
             AValue := LInt64;
           end
           else
           begin
             Val(LStr, LValue, LErr);
             if LErr <> 0 then
               exit;
             AValue := LValue;
             Result := jvkFloat;
           end;
         end;
  end;
end;

function TJsonDataMap.TJsonParserMap.ParseJsonArray(out AData: TJsonDataMap): boolean;
var
  LItem: Variant;
begin
  Result := false;
  AData.Init;
  if not CheckNextNonWhiteChar(']') then
  begin
    repeat
      if GetNextJson(LItem) = jvkNone then
        exit;
      AData.AddValue(LItem);
      case GetNextNonWhiteChar of
        ',': continue;
        ']': break;
      else
        exit;
      end;
    until false;
    SetLength(AData.FValues, AData.FVCount);
  end;
  AData.FVKind := jtkArray;
  Result := True;
end;

function TJsonDataMap.TJsonParserMap.ParseJsonObject(out AData: TJsonDataMap): boolean;
var
  LKey: string;
  LItem: Variant;
begin
  Result := false;
  AData.Init;
  if not CheckNextNonWhiteChar('}') then
  begin
    repeat
      if CheckNextNonWhiteChar('"') then
      begin
        if (not GetNextString(LKey)) or (GetNextNonWhiteChar <> ':') then
          exit;
      end
      else
      if not GetNextAlphaPropName(LKey) then
        exit;
      if GetNextJson(LItem) = jvkNone then
        exit;
      AData.AddNameValue(LKey, LItem);
      case GetNextNonWhiteChar of
        ',': continue;
        '}': break;
      else
        exit;
      end;
    until false;
    SetLength(AData.FNames, AData.FVCount);
  end;
  SetLength(AData.FValues, AData.FVCount);
  AData.FVKind := jtkObject;
  Result := True;
end;

{ TJSONBrVariantData }

procedure TJsonDataMap.Init;
begin
  FVType := JsonVariantType.VarType;
  FVKind := jtkUndefined;
  FVCount := 0;
  pointer(FNames) := nil;
  pointer(FValues) := nil;
end;

procedure TJsonDataMap.Init(const AJson: String);
begin
  Init;
  FromJson(AJson);
  if FVType = varNull then
    FVKind := jtkObject
  else
  if FVType <> JsonVariantType.VarType then
    Init;
end;

procedure TJsonDataMap.InitFrom(const AValues: TArrayVariantMap);
begin
  Init;
  FVKind := jtkArray;
  FValues := AValues;
  FVCount := Length(AValues);
end;

procedure TJsonDataMap.Clear;
begin
  FNames := nil;
  FValues := nil;
  Init;
end;

procedure TJsonDataMap.AddNameValue(const AName: String;
  const AValue: Variant);
begin
  if FVKind = jtkUndefined then
    FVKind := jtkObject
  else
  if FVKind <> jtkObject then
    raise EJsonBrException.CreateFmt('AddNameValue(%s) over array', [AName]);
  if FVCount <= Length(FValues) then
  begin
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
    SetLength(FNames, FVCount + FVCount shr 3 + 32);
  end;
  FValues[FVCount] := AValue;
  FNames[FVCount] := AName;
  Inc(FVCount);
end;

procedure TJsonDataMap.AddValue(const AValue: Variant);
begin
  if FVKind = jtkUndefined then
    FVKind := jtkArray
  else
  if FVKind <> jtkArray then
    raise EJsonBrException.Create('AddValue() over object');
  if FVCount <= Length(FValues) then
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

function TJsonDataMap.FromJson(const AJson: String): boolean;
var
  LParser: TJsonParserMap;
begin
  LParser.Init(AJson, 1);
  Result := LParser.GetNextJson(Variant(Self)) in [jvkObject, jvkArray];
end;

function TJsonDataMap.GetKind: TJsonTypeKindMap;
begin
  if (@Self = nil) or (FVType <> JsonVariantType.VarType) then
    Result := jtkUndefined
  else
    Result := FVKind;
end;

function TJsonDataMap.GetCount: integer;
begin
  if (@Self = nil) or (FVType <> JsonVariantType.VarType) then
    Result := 0
  else
    Result := FVCount;
end;

function TJsonDataMap.GetDataType: TJsonValueKindMap;
begin
  case VarType(FVType) of
    varEmpty, varNull: Result := jvkNull;
    varBoolean: Result := jvkBoolean;
    varString, varUString, varOleStr: Result := jvkString;
    varInteger, varSmallint, varShortint, varByte, varWord, varLongWord, varInt64: Result := jvkInteger;
    varSingle, varDouble, varCurrency, varDate: Result := jvkFloat;
    varDispatch: Result := jvkObject;
    varUnknown, varError: Result := jvkNone;
    varVariant: Result := jvkNone;
    varArray: Result := jvkArray;
  else
    Result := jvkNone;
  end;
end;

function TJsonDataMap.GetValue(const AName: String): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkObject) then
    GetVarData(AName, TVarData(Result));
end;

function TJsonDataMap.GetValueCopy(const AName: String): Variant;
var
  LFor: Cardinal;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkObject) then
  begin
    LFor := Cardinal(NameIndex(AName));
    if LFor < Cardinal(Length(FValues)) then
      Result := FValues[LFor];
  end;
end;

function TJsonDataMap.GetItem(AIndex: integer): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      Result := FValues[AIndex];
end;

procedure TJsonDataMap.SetItem(AIndex: integer; const AItem: Variant);
begin
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      FValues[AIndex] := AItem;
end;

procedure TJsonDataMap.SetKind(const Value: TJsonTypeKindMap);
begin
  FVKind := Value;
end;

function TJsonDataMap.GetVarData(const AName: String; var ADest: TVarData): boolean;
var
  LFor: Cardinal;
begin
  LFor := Cardinal(NameIndex(AName));
  if LFor < Cardinal(Length(FValues)) then
  begin
    ADest.VType := varVariant or varByRef;
    ADest.VPointer := @FValues[LFor];
    Result := True;
  end
  else
    Result := false;
end;

function TJsonDataMap.NameIndex(const AName: String): integer;
begin
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FNames <> nil) then
    for Result := 0 to FVCount - 1 do
      if FNames[Result] = AName then
        exit;
  Result := -1;
end;

function TJsonDataMap.Names: TArrayStringMap;
begin
  Result := FNames;
end;

procedure TJsonDataMap.SetValue(const AName: String; const AValue: Variant);
var
  LFor: integer;
begin
  if @Self = nil then
    raise EJsonBrException.Create('Unexpected Value[] access');
  if AName = '' then
    raise EJsonBrException.Create('Unexpected Value['''']');
  LFor := NameIndex(AName);
  if LFor < 0 then
    AddNameValue(AName, AValue)
  else
    FValues[LFor] := String(AValue);
end;

function TJsonDataMap.ToJson: String;
var
  LFor: integer;
  LResultBuilder: TStringBuilder;
begin
  case FVKind of
    jtkObject:
      if FVCount = 0 then
        Result := '{}'
      else
      begin
        LResultBuilder := TStringBuilder.Create;
        try
          LResultBuilder.Append('{');
          for LFor := 0 to FVCount - 1 do
            LResultBuilder.Append(TJsonMap.StringToJson(FNames[LFor]))
                          .Append(':')
                          .Append(TJsonMap.ValueToJson(FValues[LFor]))
                          .Append(',');
          LResultBuilder.ReplaceLastChar('}');
          Result := LResultBuilder.ToString;
        finally
          LResultBuilder.Free;
        end;
      end;
    jtkArray:
      if FVCount = 0 then
        Result := '[]'
      else
      begin
        LResultBuilder := TStringBuilder.Create;
        try
          LResultBuilder.Append('[');
          for LFor := 0 to FVCount - 1 do
            LResultBuilder.Append(TJsonMap.ValueToJson(FValues[LFor]))
                          .Append(',');
          LResultBuilder.ReplaceLastChar(']');
          Result := LResultBuilder.ToString;
        finally
          LResultBuilder.Free;
        end;
      end;
  else
    Result := 'null';
  end;
end;

function TJsonDataMap.ToObject(AObject: TObject): boolean;
var
  LFor: integer;
  FContext: TRttiContext;
  LItem: TCollectionItem;
  LListType: TRttiType;
  LProperty: TRttiProperty;
  LObjectType: TObject;

  function MethodCall(const AObject: TObject; const AMethodName: string;
    const AParameters: array of TValue): TValue;
  var
    LRttiType: TRttiType;
    LMethod: TRttiMethod;
  begin
    LRttiType := FContext.GetType(AObject.ClassType);
    LMethod   := LRttiType.GetMethod(AMethodName);
    if Assigned(LMethod) then
       Result := LMethod.Invoke(AObject, AParameters)
    else
       raise Exception.CreateFmt('Cannot find method "%s" in the object', [AMethodName]);
  end;

begin
  Result := false;
  if AObject = nil then
    exit;
  case FVKind of
    jtkObject:
      begin
        LListType := FContext.GetType(AObject.ClassType);
        if LListType <> nil then
        begin
          for LFor := 0 to Count - 1 do
          begin
            LProperty := LListType.GetProperty(FNames[LFor]);
            if LProperty <> nil then
              TJsonMap.SetInstanceProp(AObject, LProperty, FValues[LFor]);
          end;
        end;
      end;
    jtkArray:
      if AObject.InheritsFrom(TCollection) then
      begin
        TCollection(AObject).Clear;
        for LFor := 0 to Count - 1 do
        begin
          LItem := TCollection(AObject).Add;
          if not TJsonMap.JsonVariantData(FValues[LFor]).ToObject(LItem) then
            exit;
        end;
      end
      else
      if AObject.InheritsFrom(TStrings) then
        try
          TStrings(AObject).BeginUpdate;
          TStrings(AObject).Clear;
          for LFor := 0 to Count - 1 do
            TStrings(AObject).Add(FValues[LFor]);
        finally
          TStrings(AObject).EndUpdate;
        end
      else
      if (Pos('TObjectList<', AObject.ClassName) > 0) or
         (Pos('TList<', AObject.ClassName) > 0) then
      begin
        LListType := FContext.GetType(AObject.ClassType);
        LListType := GetListType(LListType);
        if LListType.IsInstance then
        begin
          for LFor := 0 to Count - 1 do
          begin
            LObjectType := LListType.AsInstance.MetaclassType.Create;
            MethodCall(LObjectType, 'Create', []);
            if not TJsonMap.JsonVariantData(FValues[LFor]).ToObject(LObjectType) then
              exit;
            MethodCall(AObject, 'Add', [LObjectType]);
          end;
        end;
      end
      else
        exit;
  else
    exit;
  end;
  Result := True;
end;

function TJsonDataMap.Values: TArrayVariantMap;
begin
  Result := FValues;
end;

function TJsonDataMap.GetListType(LRttiType: TRttiType): TRttiType;
var
  LTypeName: String;
  LContext: TRttiContext;
begin
   LContext := TRttiContext.Create;
   try
     LTypeName := LRttiType.ToString;
     LTypeName := StringReplace(LTypeName,'TObjectList<','',[]);
     LTypeName := StringReplace(LTypeName,'TList<','',[]);
     LTypeName := StringReplace(LTypeName,'>','',[]);
     //
     Result := LContext.FindType(LTypeName);
   finally
     LContext.Free;
   end;
end;

{ TJsonVariant }

procedure TJsonVariantMap.Cast(var ADest: TVarData; const ASource: TVarData);
begin
  CastTo(ADest, ASource, VarType);
end;

procedure TJsonVariantMap.CastTo(var ADest: TVarData; const ASource: TVarData;
  const AVarType: TVarType);
begin
  if ASource.VType <> VarType then
    RaiseCastError;
  Variant(ADest) := TJsonDataMap(ASource).ToJson;
end;

procedure TJsonVariantMap.Clear(var AVarData: TVarData);
begin
  AVarData.VType := varEmpty;
  Finalize(TJsonDataMap(AVarData).FNames);
  Finalize(TJsonDataMap(AVarData).FValues);
end;

procedure TJsonVariantMap.Copy(var ADest: TVarData; const ASource: TVarData;
  const AIndirect: boolean);
begin
  if AIndirect then
    SimplisticCopy(ADest, ASource, True)
  else
  begin
    VarClear(Variant(ADest));
    TJsonDataMap(ADest).Init;
    TJsonDataMap(ADest) := TJsonDataMap(ASource);
  end;
end;

function TJsonVariantMap.GetProperty(var ADest: TVarData; const AVarData: TVarData;
  const AName: String): boolean;
begin
  if not TJsonDataMap(AVarData).GetVarData(AName, ADest) then
    ADest.VType := varNull;
  Result := True;
end;

function TJsonVariantMap.SetProperty(const AVarData: TVarData; const AName: String;
  const AValue: TVarData): boolean;
begin
  TJsonDataMap(AVarData).SetValue(AName, Variant(AValue));
  Result := True;
end;

procedure TStringBuilderHelper.ReplaceLastChar(const AChar: Char);
begin
  if Self.Length > 1 then
  begin
    if Self.Chars[Self.Length - 1] = ' ' then
      Self.Remove(Self.Length - 1, 1);
    Self.Chars[Self.Length - 1] := AChar;
  end;
end;

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: boolean): string;
var
  LDatePart, LTimePart: string;
begin
  Result := '';
  if AValue = 0 then
    exit;
  if AUseISO8601DateFormat then
    LDatePart := FormatDateTime('yyyy-mm-dd', AValue)
  else
    LDatePart := DateToStr(AValue, JsonBrFormatSettings);
  if Frac(AValue) = 0 then
    Result := ifThen(AUseISO8601DateFormat, LDatePart, TimeToStr(AValue, JsonBrFormatSettings))
  else
  begin
    LTimePart := FormatDateTime('hh:nn:ss', AValue);
    Result := ifThen(AUseISO8601DateFormat, LDatePart + 'T' + LTimePart, LDatePart + ' ' + LTimePart);
  end;
end;

function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: boolean): TDateTime;
var
  LYYYY, LMM, LDD, LHH, LMI, LSS: Cardinal;
begin
  if AUseISO8601DateFormat then
    Result := StrToDateTimeDef(AValue, 0)
  else
    Result := StrToDateTimeDef(AValue, 0, JsonBrFormatSettings);

  if Length(AValue) = 19 then
  begin
    LYYYY := StrToIntDef(Copy(AValue, 1, 4), 0);
    LMM := StrToIntDef(Copy(AValue, 6, 2), 0);
    LDD := StrToIntDef(Copy(AValue, 9, 2), 0);
    LHH := StrToIntDef(Copy(AValue, 12, 2), 0);
    LMI := StrToIntDef(Copy(AValue, 15, 2), 0);
    LSS := StrToIntDef(Copy(AValue, 18, 2), 0);
    if (LYYYY <= 9999) and (LMM <= 12) and (LDD <= 31) and
       (LHH < 24) and (LMI < 60) and (LSS < 60) then
      Result := EncodeDate(LYYYY, LMM, LDD) + EncodeTime(LHH, LMI, LSS, 0);
  end;
end;

initialization
  JsonBrFormatSettings := TFormatSettings.Create('en_US');
  JsonVariantType := TJsonVariantMap.Create;
  TJsonMap.UseISO8601DateFormat := True;

end.

