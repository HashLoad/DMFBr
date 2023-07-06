unit dmfbr.decorator.isarray;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isarray;

type
  IsArrayAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsArrayAttribute }

constructor IsArrayAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsArray';
end;

function IsArrayAttribute.Validation: TValidation;
begin
  Result := TIsArray;
end;

end.

