unit dmfbr.decorator.isboolean;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isboolean;

type
  IsBooleanAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsBooleanAttribute }

constructor IsBooleanAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsBoolean';
end;

function IsBooleanAttribute.Validation: TValidation;
begin
  Result := TIsBoolean;
end;

end.

