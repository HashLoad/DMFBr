unit dmfbr.validation.arguments;

interface

uses
  Rtti,
  dmfbr.validation.interfaces;

type
  TValidationArguments = class(TInterfacedObject, IValidationArguments)
  private
    FValues: TArray<TValue>;
    FObject: TObject;
    FTagName: string;
    FFieldName: string;
    FMessage: string;
    FTypeName: string;
  public
    constructor Create(const AValues: TArray<TValue>;
      const ATagName: string; const AFieldName: string; const AMessage: string;
      const ATypeName: string; const AObject: TObject);
    function Values: TArray<TValue>;
    function TagName: string;
    function FieldName: string;
    function Message: string;
    function TypeName: string;
    function AsObject: TObject;
  end;

implementation

{ TArgumentMetadata }

function TValidationArguments.AsObject: TObject;
begin
  Result := FObject;
end;

constructor TValidationArguments.Create(const AValues: TArray<TValue>;
  const ATagName: string; const AFieldName: string; const AMessage: string;
  const ATypeName: string; const AObject: TObject);
begin
  FTagName := ATagName;
  FFieldName := AFieldName;
  FValues := AValues;
  FMessage := AMessage;
  FTypeName := ATypeName;
  FObject := AObject;
end;

function TValidationArguments.FieldName: string;
begin
  Result := FFieldName;
end;

function TValidationArguments.Message: string;
begin
  Result := FMessage;
end;

function TValidationArguments.TagName: string;
begin
  Result := FTagName;
end;

function TValidationArguments.TypeName: string;
begin
  Result := FTypeName;
end;

function TValidationArguments.Values: TArray<TValue>;
begin
  Result := FValues;
end;

end.
