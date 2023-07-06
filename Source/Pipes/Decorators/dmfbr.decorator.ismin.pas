unit dmfbr.decorator.ismin;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.ismin;

type
  IsMinAttribute = class(IsAttribute)
  private
    FValueMin: TValue;
  public
    constructor Create(const AValueMin: Extended; const AMessage: string = ''); reintroduce;
    function ValueMin: TValue;
    function Validation: TValidation; override;
  end;

implementation

{ IsMinAttribute }

constructor IsMinAttribute.Create(const AValueMin: Extended; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsMin';
  FValueMin := AValueMin;
end;

function IsMinAttribute.Validation: TValidation;
begin
  Result := TIsMin;
end;

function IsMinAttribute.ValueMin: TValue;
begin
  Result := FValueMin;
end;

end.

