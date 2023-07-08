unit dmfbr.decorator.ismax;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.ismax;

type
  IsMaxAttribute = class(IsAttribute)
  private
    FValueMax: TValue;
  public
    constructor Create(const AValueMax: Extended; const AMessage: string = ''); reintroduce;
    function ValueMax: TValue;
    function Validation: TValidation; override;
    function Params: TArray<TValue>; override;
  end;

implementation

{ IsMaxAttribute }

constructor IsMaxAttribute.Create(const AValueMax: Extended; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'IsMax';
  FValueMax := AValueMax;
end;

function IsMaxAttribute.ValueMax: TValue;
begin
  Result := FValueMax;
end;

function IsMaxAttribute.Params: TArray<TValue>;
begin
  Result := [FValueMax];
end;

function IsMaxAttribute.Validation: TValidation;
begin
  Result := TIsMax;
end;

end.

