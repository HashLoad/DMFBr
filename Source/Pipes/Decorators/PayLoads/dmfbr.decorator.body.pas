unit dmfbr.decorator.body;

interface

uses
  dmfbr.decorator.isbase,
  dmfbr.validation.types;

type
  BodyAttribute = class(IsAttribute)
  protected
    FObjectType: TObjectType;
    FTransform: TTransform;
  public
    constructor Create(const AObjectType: TObjectType; const ATransform: TTransform;
      const AMessage: string = ''; const AValidation: TValidation = nil); reintroduce; overload;
    function TagName: string;
    function ObjectType: TObjectType;
    function Transform: TTransform;
  end;

implementation

{ BodyAttribute }

constructor BodyAttribute.Create(const AObjectType: TObjectType;
  const ATransform: TTransform; const AMessage: string;
  const AValidation: TValidation);
begin
  inherited Create(AMessage);
  FTagName := 'body';
  FTransform := ATransform;
  FObjectType := AObjectType;
end;

function BodyAttribute.TagName: string;
begin
  Result := FTagName;
end;

function BodyAttribute.Transform: TTransform;
begin
  Result := FTransform;
end;

function BodyAttribute.ObjectType: TObjectType;
begin
  Result := FObjectType;
end;

end.

