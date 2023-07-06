unit dmfbr.transform.arguments;

interface

uses
  Rtti,
  dmfbr.transform.interfaces;

type
  TTransformArguments = class(TInterfacedObject, ITransformArguments)
  private
    FTagName: string;
    FFieldName: string;
    FValue: TValue;
    FObjectType: TClass;
    FMessage: string;
  public
    constructor Create(const AValue: TValue; const ATagName: string;
      const AFieldName: string; const AMessage: string;
      const AObjectType: TClass);
    function Value: TValue;
    function TagName: string;
    function FieldName: string;
    function Message: string;
    function ObjectType: TClass;
  end;

implementation

{ TConverterArguments }

constructor TTransformArguments.Create(const AValue: TValue;
  const ATagName: string; const AFieldName: string; const AMessage: string;
  const AObjectType: TClass);
begin
  FTagName := ATagName;
  FFieldName := AFieldName;
  FValue := AValue;
  FMessage := AMessage;
  FObjectType := AObjectType;
end;

function TTransformArguments.FieldName: string;
begin
  Result := FFieldName;
end;

function TTransformArguments.Message: string;
begin
  Result := FMessage;
end;

function TTransformArguments.ObjectType: TClass;
begin
  Result := FObjectType;
end;

function TTransformArguments.TagName: string;
begin
  Result := FTagName;
end;

function TTransformArguments.Value: TValue;
begin
  Result := FValue;
end;

end.
