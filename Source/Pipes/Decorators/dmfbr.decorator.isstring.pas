unit dmfbr.decorator.isstring;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.isstring;

type
  IsStringAttribute = class(IsAttribute)
  private
    FEach: boolean;
    FGroups: TArray<string>;
  public
    constructor Create(const AEach: boolean = false;
      const AMessage: string = ''; const AGroups: TArray<string> = nil); reintroduce;
    function Validation: TValidation; override;
  end;

implementation

{ IsStringAttribute }

constructor IsStringAttribute.Create(const AEach: boolean;
  const AMessage: string; const AGroups: TArray<string>);
begin
  inherited Create(AMessage);
  FTagName := 'IsString';
  FEach := AEach;
  FGroups := AGroups;
end;

function IsStringAttribute.Validation: TValidation;
begin
  Result := TIsString;
end;

end.

