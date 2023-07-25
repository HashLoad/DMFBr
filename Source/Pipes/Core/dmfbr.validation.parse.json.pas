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
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

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
  TCallbackSetValue = reference to procedure(const AClassType: TClass;
                                             const AFieldname: string;
                                             const AValue: TValue);
  EJsonBrException = class(Exception);
  TArrayKeyMap = array of string;
  TArrayValueMap = array of Variant;
  TTypeKindMap = (jtkUndefined, jtkObject, jtkArray, jtkBoolean);
  TValueKindMap = (jvkNone, jvkNull, jvkString, jvkInteger, jvkFloat,
                   jvkObject, jvkArray, jvkBoolean);

  TJsonDataMap = record
  private
    FVType: TVarType;
    FVKind: TTypeKindMap;
    FVCount: integer;
    FNames: TArrayKeyMap;
    FValues: TArrayValueMap;
    function GetCount: integer;
    type
      TJsonParserMap = record
      private
        FJson: string;
        FIndex: integer;
        FJsonLength: integer;
        procedure Init(const AJson: string; const AIndex: integer = 1);
        procedure GetNextStringUnEscape(var AStr: string);
        function GetNextChar: Char;
        function GetNextNonWhiteChar: Char;
        function CheckNextNonWhiteChar(AChar: Char): boolean;
        function GetNextString(out AStr: string): boolean;
        function GetNextJson(out AValue: Variant): TValueKindMap;
        function GetNextAlphaPropName(out AFieldName: string): boolean;
        function ParseJsonObject(out AData: TJsonDataMap): boolean;
        function ParseJsonArray(out AData: TJsonDataMap): boolean;
      end;
  private
    function FromJson(const AJson: string): boolean;
    function ToMap(AClassType: TClass): boolean;
    procedure Init; overload;
    procedure Init(const AJson: string); overload;
    procedure AddValue(const AIndex: string; const AValue: Variant);
    procedure AddNameValue(const AName: string; const AValue: Variant);
  end;

  TJsonVariantMap = class(TInvokeableVariantType)
  public
    procedure Copy(var ADest: TVarData; const ASource: TVarData;
      const AIndirect: boolean); override;
    procedure Clear(var AVarData: TVarData); override;
  end;

  TJsonMap = class
  private
    class var FCallbackSetValue: TCallbackSetValue;
  private
    class function JsonVariantData(const AValue: Variant): TJsonDataMap;
  public
    class procedure Map(const AJson: string; const AClass: TClass;
      const ACallbackSetValue: TCallbackSetValue); static;
  end;

var
  JsonVariantType: TInvokeableVariantType;

implementation

{ TJsonMap }

class function TJsonMap.JsonVariantData(const AValue: Variant): TJsonDataMap;
var
  LVarData: TVarData;
begin
  LVarData := TVarData(AValue);
  if LVarData.VType = JsonVariantType.VarType then
    Result := TJsonDataMap(AValue)
  else
  if LVarData.VType = varByRef or varVariant then
    Result := TJsonDataMap(PVariant(LVarData.VPointer)^)
  else
    raise EJsonBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [LVarData.VType]);
end;

class procedure TJsonMap.Map(const AJson: string; const AClass: TClass;
  const ACallbackSetValue: TCallbackSetValue);
var
  LDoc: TJsonDataMap;
  LFor: integer;
begin
  FCallbackSetValue := ACallbackSetValue;
  LDoc.Init(AJson);
  if LDoc.FVKind = jtkObject then
    LDoc.ToMap(AClass)
  else
  if LDoc.FVKind = jtkArray then
  begin
    for LFor := 0 to LDoc.GetCount - 1 do
      if not JsonVariantData(LDoc.FValues[LFor]).ToMap(AClass) then
        exit;
  end;
end;

{ TJsonDataMap }

procedure TJsonDataMap.TJsonParserMap.Init(const AJson: String; const AIndex: integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJsonDataMap.TJsonParserMap.GetNextChar: Char;
begin
  Result := #0;
  if FIndex > FJsonLength then
    exit;
  Result := Char(FJson[FIndex]);
  Inc(FIndex);
end;

function TJsonDataMap.TJsonParserMap.GetNextNonWhiteChar: Char;
begin
  Result := #0;
  if FIndex > FJsonLength then
    exit;
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

function TJsonDataMap.TJsonParserMap.CheckNextNonWhiteChar(AChar: Char): boolean;
begin
  Result := false;
  if FIndex > FJsonLength then
    exit;
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

procedure TJsonDataMap.TJsonParserMap.GetNextStringUnEscape(var AStr: String);
var
  LChar: Char;
  LCopy: String;
  LUnicode, LErr: integer;
  LStringBuilder: TStringBuilder;
begin
  LStringBuilder := TStringBuilder.Create;
  try
    LStringBuilder.Append(AStr);
    repeat
      LChar := GetNextChar;
      case LChar of
        #0:  exit;
        '"': break;
        '\': begin
             LChar := GetNextChar;
             case LChar of
               #0 : exit;
               'b': LStringBuilder.Append(#08);
               't': LStringBuilder.Append(#09);
               'n': LStringBuilder.Append(#$0a);
               'f': LStringBuilder.Append(#$0c);
               'r': LStringBuilder.Append(#$0d);
               'u':
               begin
                 LCopy := Copy(FJson, FIndex, 4);
                 if Length(LCopy) <> 4 then
                   exit;
                 Inc(FIndex, 4);
                 Val('$' + LCopy, LUnicode, LErr);
                 if LErr <> 0 then
                   exit;
                 LStringBuilder.Append(Char(LUnicode));
               end;
             else
               LStringBuilder.Append(LChar);
             end;
           end;
      else
        LStringBuilder.Append(LChar);
      end;
    until false;
    AStr := LStringBuilder.ToString;
  finally
    LStringBuilder.Free;
  end;
end;

function TJsonDataMap.TJsonParserMap.GetNextString(out AStr: String): boolean;
var
  LFor: integer;
begin
  Result := false;
  for LFor := FIndex to FJsonLength do
  begin
    case FJson[LFor] of
      '"': begin
             AStr := Copy(FJson, FIndex, LFor - FIndex);
             FIndex := LFor + 1;
             Result := True;
             break;
           end;
      '\': begin
             AStr := Copy(FJson, FIndex, LFor - FIndex);
             FIndex := LFor;
             GetNextStringUnEscape(AStr);
             Result := True;
             break;
           end;
    end;
  end;
end;

function TJsonDataMap.TJsonParserMap.GetNextAlphaPropName(out AFieldName: String): boolean;
var
  LFor: integer;
begin
  Result := false;
  if (FIndex >= FJsonLength) or not (Ord(FJson[FIndex]) in [Ord('A')..Ord('Z'),
                                                            Ord('a')..Ord('z'),
                                                            Ord('_'),
                                                            Ord('$')]) then
    exit;
  for LFor := FIndex + 1 to FJsonLength do
  begin
    case Ord(FJson[LFor]) of
         Ord('0')..Ord('9'),
         Ord('A')..Ord('Z'),
         Ord('a')..Ord('z'),
         Ord('_'):;
         Ord(':'),
         Ord('='):
      begin
        AFieldName := Copy(FJson, FIndex, LFor - FIndex);
        FIndex := LFor + 1;
        Result := True;
        break;
      end;
    else
      break;
    end;
  end;
end;

function TJsonDataMap.TJsonParserMap.GetNextJson(out AValue: Variant): TValueKindMap;
var
  LStr: String;
  LInt64: int64;
  LValue: double;
  LStart, LErr: integer;
begin
  Result := jvkNone;
  case GetNextNonWhiteChar of
    'n': if Copy(FJson, FIndex, 3) = 'ull' then
         begin
           Inc(FIndex, 3);
           AValue := Null;
           Result := jvkNull;
         end;
    'f': if Copy(FJson, FIndex, 4) = 'alse' then
         begin
           Inc(FIndex, 4);
           AValue := false;
           Result := jvkBoolean;
         end;
    't': if Copy(FJson, FIndex, 3) = 'rue' then
         begin
           Inc(FIndex, 3);
           AValue := true;
           Result := jvkBoolean;
         end;
    '"': if GetNextString(LStr) then
         begin
           AValue := LStr;
           Result := jvkString;
         end;
    '{': if ParseJsonObject(TJsonDataMap(AValue)) then
           Result := jvkObject;
    '[': if ParseJsonArray(TJsonDataMap(AValue)) then
           Result := jvkArray;
    '-', '0'..'9':
         begin
           LStart := FIndex - 1;
           while true do
             case FJson[FIndex] of
               '-', '+', '0'..'9', '.', 'E', 'e': Inc(FIndex);
             else
               break;
             end;
           LStr := Copy(FJson, LStart, FIndex - LStart);
           Val(LStr, LInt64, LErr);
           if LErr = 0 then
           begin
             AValue := LInt64;
             Result := jvkInteger;
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
  LIndex: integer;
begin
  Result := false;
  AData.Init;
  if not CheckNextNonWhiteChar(']') then
  begin
    LIndex := 0;
    repeat
      if GetNextJson(LItem) = jvkNone then
        exit;
      AData.AddValue('[' + IntToStr(LIndex) + ']', LItem);
      case GetNextNonWhiteChar of
        ',': begin
               inc(LIndex);
               continue;
             end;
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

{ TJsonDataMap }

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

procedure TJsonDataMap.AddNameValue(const AName: string;
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
  FNames[FVCount] := AName;
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

procedure TJsonDataMap.AddValue(const AIndex: string; const AValue: Variant);
begin
  if FVKind = jtkUndefined then
    FVKind := jtkArray
  else
  if FVKind <> jtkArray then
    raise EJsonBrException.Create('AddValue() over object');
  if FVCount <= Length(FValues) then
  begin
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
    SetLength(FNames, FVCount + FVCount shr 3 + 32);
  end;
  FNames[FVCount] := AIndex;
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

function TJsonDataMap.FromJson(const AJson: String): boolean;
var
  LParser: TJsonParserMap;
begin
  LParser.Init(AJson, {$IFDEF NEXTGEN}2{$ELSE}1{$ENDIF});
  Result := LParser.GetNextJson(Variant(Self)) in [jvkObject, jvkArray, jvkBoolean];
end;

function TJsonDataMap.GetCount: integer;
begin
  if (@Self = nil) or (FVType <> JsonVariantType.VarType) then
    Result := 0
  else
    Result := FVCount;
end;

function TJsonDataMap.ToMap(AClassType: TClass): boolean;
var
  LFor: integer;
begin
  Result := false;
  if AClassType = nil then
    exit;
  case FVKind of
    jtkObject:
      begin
        for LFor := 0 to GetCount - 1 do
        begin
          if Assigned(TJsonMap.FCallbackSetValue) then
            TJsonMap.FCallbackSetValue(AClassType, FNames[LFor], TValue.FromVariant(FValues[LFor]));
        end;
      end;
    jtkArray:
      if AClassType.InheritsFrom(TCollection) then
      begin
        TCollection(AClassType).Clear;
        for LFor := 0 to GetCount - 1 do
        begin
          if not TJsonMap.JsonVariantData(FValues[LFor]).ToMap(AClassType) then
            exit;
        end;
      end
      else
      if AClassType.InheritsFrom(TStrings) then
        try
          TStrings(AClassType).BeginUpdate;
          TStrings(AClassType).Clear;
          for LFor := 0 to GetCount - 1 do
            TStrings(AClassType).Add(FValues[LFor]);
        finally
          TStrings(AClassType).EndUpdate;
        end
      else
      if (Pos('TObjectList<', AClassType.ClassName) > 0) or
         (Pos('TList<', AClassType.ClassName) > 0) then
      begin
        for LFor := 0 to GetCount - 1 do
        begin
          if not TJsonMap.JsonVariantData(FValues[LFor]).ToMap(AClassType) then
            exit;
        end;
      end
      else
        exit;
  else
    exit;
  end;
  Result := true;
end;

{ TJsonVariantMap }

procedure TJsonVariantMap.Clear(var AVarData: TVarData);
begin
  AVarData.VType := varEmpty;
  Finalize(TJsonDataMap(AVarData).FNames);
  Finalize(TJsonDataMap(AVarData).FValues);
end;

procedure TJsonVariantMap.Copy(var ADest: TVarData; const ASource: TVarData;
  const AIndirect: boolean);
begin
  inherited;
end;

initialization
  JsonVariantType := TJsonVariantMap.Create;

end.

