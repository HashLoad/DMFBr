unit dmfbr.decorator.isnotempty;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isnotempty;

type
  IsNotEmptyAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsNotEmptyAttribute }

constructor IsNotEmptyAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsNotEmpty';
end;

function IsNotEmptyAttribute.Validation: TValidation;
begin
  Result := TIsNotEmpty;
end;

end.

