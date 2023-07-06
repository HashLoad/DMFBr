unit dmfbr.decorator.isobject;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isobject;

type
  IsObjectAttribute = class(IsAttribute)
  public
    constructor Create(const AValue: Extended; const AMessage: string = ''); reintroduce;
    function Validation: TValidation; override;
  end;

implementation

{ IsMaxAttribute }

constructor IsObjectAttribute.Create(const AValue: Extended; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsObject';
end;

function IsObjectAttribute.Validation: TValidation;
begin
  Result := TIsObject;
end;

end.

