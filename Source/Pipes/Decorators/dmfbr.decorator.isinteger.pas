unit dmfbr.decorator.isinteger;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isinteger;

type
  IsIntegerAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsStringAttribute }

constructor IsIntegerAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsInteger';
end;

function IsIntegerAttribute.Validation: TValidation;
begin
  Result := TIsInteger;
end;

end.

