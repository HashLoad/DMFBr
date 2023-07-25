unit dmfbr.decorator.query;

interface

uses
  SysUtils,
  Variants,
  dmfbr.decorator.isbase,
  dmfbr.validation.types;

type
  QueryAttribute = class(IsAttribute)
  private
    FValue: Variant;
    FQueryName: string;
    FTransform: TTransform;
    FValidation: TValidation;
  public
    constructor Create(const AQueryName: string; const ATransform: TTransform;
      const AValue: Variant; const AValidation: TValidation = nil;
      const AMessage: string = ''); reintroduce; overload;
    constructor Create(const AQueryName: string; const ATransform: TTransform;
      const AValidation: TValidation = nil; const AMessage: string = ''); reintroduce; overload;
    function QueryName: string;
    function TagName: string;
    function Transform: TTransform;
    function Value: Variant;
    function Validation: TValidation; override;
  end;

implementation

uses
  dmfbr.transform.pipe;

{ ParamAttribute }

function QueryAttribute.Transform: TTransform;
begin
  Result := FTransform;
end;

constructor QueryAttribute.Create(const AQueryName: string;
  const ATransform: TTransform; const AValidation: TValidation;
  const AMessage: string);
begin
  Create(AQueryName, ATransform, Null, AValidation, AMessage);
end;

constructor QueryAttribute.Create(const AQueryName: string;
  const ATransform: TTransform; const AValue: Variant;
  const AValidation: TValidation; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'query';
  FValue := AValue;
  FQueryName := AQueryName;
  if (ATransform <> nil) and (AValidation <> nil) then
  begin
    FTransform := ATransform;
    FValidation := AValidation;
  end
  else
  begin
    if ATransform.InheritsFrom(TTransformPipe) then
      FTransform := ATransform
    else
      FValidation := ATransform;
  end;
end;

function QueryAttribute.QueryName: string;
begin
  Result := FQueryName;
end;

function QueryAttribute.TagName: string;
begin
  Result := FTagName;
end;

function QueryAttribute.Validation: TValidation;
begin
  Result := FValidation;
end;

function QueryAttribute.Value: Variant;
begin

end;

end.
