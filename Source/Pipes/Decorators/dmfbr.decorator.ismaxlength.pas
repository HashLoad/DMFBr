unit dmfbr.decorator.ismaxlength;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.ismaxlength;

type
  IsMaxLengthAttribute = class(IsAttribute)
  private
    FValueMax: TValue;
  public
    constructor Create(const AValueMax: Extended; const AMessage: string = ''); reintroduce;
    function Validation: TValidation; override;
    function Params: TArray<TValue>; override;
  end;

implementation

{ IsMaxAttribute }

constructor IsMaxLengthAttribute.Create(const AValueMax: Extended; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsMaxLength';
  FValueMax := AValueMax;
end;

function IsMaxLengthAttribute.Params: TArray<TValue>;
begin
  Result := [FValueMax];
end;

function IsMaxLengthAttribute.Validation: TValidation;
begin
  Result := TIsMaxLength;
end;

end.

