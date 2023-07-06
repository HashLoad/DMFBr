unit dmfbr.decorator.isnumber;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isnumber;

type
  IsNumberAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsNumberAttribute }

constructor IsNumberAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsNumber';
end;

function IsNumberAttribute.Validation: TValidation;
begin
  Result := TIsNumber;
end;

end.

