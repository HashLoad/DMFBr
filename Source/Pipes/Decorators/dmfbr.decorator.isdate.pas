unit dmfbr.decorator.isdate;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isdate;

type
  IsDateAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsBooleanAttribute }

constructor IsDateAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsDate';
end;

function IsDateAttribute.Validation: TValidation;
begin
  Result := TIsDate;
end;

end.

