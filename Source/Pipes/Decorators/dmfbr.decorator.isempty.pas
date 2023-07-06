unit dmfbr.decorator.isempty;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isempty;

type
  IsEmptyAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: string = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsEmptyAttribute }

constructor IsEmptyAttribute.Create(const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsEmpty';
end;

function IsEmptyAttribute.Validation: TValidation;
begin
  Result := TIsEmpty;
end;

end.

