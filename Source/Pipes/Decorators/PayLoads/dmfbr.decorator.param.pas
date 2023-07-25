unit dmfbr.decorator.param;

interface

uses
  SysUtils,
  Variants,
  dmfbr.decorator.isbase,
  dmfbr.validation.types;

type
  ParamAttribute = class(IsAttribute)
  private
    FValue: Variant;
    FParamName: string;
    FTransform: TTransform;
    FValidation: TValidation;
  public
    constructor Create(const AParamName: string; const ATransform: TTransform;
      const AValue: Variant; const AValidation: TValidation = nil;
      const AMessage: string = ''); reintroduce; overload;
    constructor Create(const AParamName: string; const ATransform: TTransform;
      const AValidation: TValidation = nil;
      const AMessage: string = ''); reintroduce; overload;
    function ParamName: string;
    function TagName: string;
    function Transform: TTransform;
    function Value: Variant;
    function Validation: TValidation; override;
  end;

implementation

uses
  dmfbr.transform.pipe;

{ ParamAttribute }

function ParamAttribute.Transform: TTransform;
begin
  Result := FTransform;
end;

constructor ParamAttribute.Create(const AParamName: string;
  const ATransform: TTransform; const AValue: Variant;
  const AValidation: TValidation; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'param';
  FParamName := AParamName;
  FValue := AValue;
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

constructor ParamAttribute.Create(const AParamName: string;
  const ATransform: TTransform; const AValidation: TValidation;
  const AMessage: string);
begin
  Create(AParamName, ATransform, Null, AValidation, AMessage);
end;

function ParamAttribute.ParamName: string;
begin
  Result := FParamName;
end;

function ParamAttribute.TagName: string;
begin
  Result := FTagName;
end;

function ParamAttribute.Validation: TValidation;
begin
  Result := FValidation;
end;

function ParamAttribute.Value: Variant;
begin
  Result := FValue;
end;

end.
