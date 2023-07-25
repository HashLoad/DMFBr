unit dmfbr.decorator.isallow;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types;
//  dmfbr.validation.isarray;

type
  IsAllowAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsArrayAttribute }

constructor IsAllowAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsAllow';
end;

function IsAllowAttribute.Validation: TValidation;
begin
//  Result := TIsArray;
end;

end.

