unit dmfbr.decorator.isenum;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isenum;

type
  IsEnumAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsBooleanAttribute }

constructor IsEnumAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsEnum';
end;

function IsEnumAttribute.Validation: TValidation;
begin
  Result := TIsEnum;
end;

end.

