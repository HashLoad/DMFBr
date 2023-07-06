unit dmfbr.decorator.param;

interface

uses
  dmfbr.decorator.isbase,
  dmfbr.validation.types;

type
  ParamAttribute = class(IsAttribute)
  private
    FParamName: string;
    FTransform: TTransform;
    FValidation: TValidation;
  public
    constructor Create(const AParamName: string; const ATransform: TTransform;
      const AValidation: TValidation); reintroduce; overload;
    constructor Create(const AParamName: string; const AValidation: TValidation); reintroduce; overload;
    function ParamName: string;
    function TagName: string;
    function Transform: TTransform;
    function Validation: TValidation; override;
  end;

implementation

{ ParamAttribute }

function ParamAttribute.Transform: TTransform;
begin
  Result := FTransform;
end;

constructor ParamAttribute.Create(const AParamName: string;
  const ATransform: TTransform; const AValidation: TValidation);
begin
  inherited Create('');
  FTagName := 'param';
  FValidation := AValidation;
  FTransform := ATransform;
  FParamName := AParamName;
end;

constructor ParamAttribute.Create(const AParamName: string;
  const AValidation: TValidation);
begin
  Create(AParamName, nil, AValidation);
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

end.
