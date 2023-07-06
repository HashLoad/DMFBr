unit dmfbr.decorator.query;

interface

uses
  dmfbr.decorator.isbase,
  dmfbr.validation.types;

type
  QueryAttribute = class(IsAttribute)
  private
    FQueryName: string;
    FTransform: TTransform;
    FValidation: TValidation;
  public
    constructor Create(const AQueryName: string; const ATransform: TClass;
      const AValidation: TValidation); reintroduce; overload;
    constructor Create(const AQueryName: string; const AValidation: TValidation); reintroduce; overload;
    function QueryName: string;
    function TagName: string;
    function Transform: TTransform;
    function Validation: TValidation; override;
  end;

implementation

{ ParamAttribute }

function QueryAttribute.Transform: TTransform;
begin
  Result := FTransform;
end;

constructor QueryAttribute.Create(const AQueryName: string;
  const ATransform: TTransform; const AValidation: TValidation);
begin
  inherited Create('');
  FTagName := 'query';
  FValidation := AValidation;
  FTransform := ATransform;
  FQueryName := AQueryName;
end;

constructor QueryAttribute.Create(const AQueryName: string;
  const AValidation: TValidation);
begin
  Create(AQueryName, nil, AValidation);
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

end.
