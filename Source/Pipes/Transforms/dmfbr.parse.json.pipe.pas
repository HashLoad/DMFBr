unit dmfbr.parse.json.pipe;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  dmfbr.validation.parse.json,
  dmfbr.transform.pipe,
  dmfbr.transform.interfaces;


type
  TParseJsonPipe = class(TTransformPipe)
  private
    FJsonMap: TJsonMapped;
  public
    constructor Create;
    destructor Destroy; override;
    function Transform(const Value: TValue;
      const Metadata: ITransformArguments): TResultTransform; override;
  end;

implementation

{ TParseJsonPipe }

constructor TParseJsonPipe.Create;
begin
  FJsonMap := TJsonMapped.Create([doOwnsValues]);
end;

destructor TParseJsonPipe.Destroy;
begin
  FJsonMap.Free;
  inherited;
end;

function TParseJsonPipe.Transform(const Value: TValue;
  const Metadata: ITransformArguments): TResultTransform;
var
  LKey: string;
begin
  try
    TJsonMap.Map(Metadata.Value.AsString, Metadata.ObjectType,
      procedure (const AInstance: TObject; const AProperty: TRttiProperty;
                 const AValue: Variant)
      begin
        LKey := AInstance.ClassName + '->' + AProperty.Name;
        if not FJsonMap.ContainsKey(LKey) then
          FJsonMap.Add(LKey, TList<TValue>.Create);
        FJsonMap[LKey].Add(TValue.FromVariant(AValue))
      end);
    Result.Success(FJsonMap);
  except
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

end.
