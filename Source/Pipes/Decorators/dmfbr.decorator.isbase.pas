unit dmfbr.decorator.isbase;

interface

uses
  SysUtils,
  dmfbr.validation.types;

type
  IsAttribute = class(TCustomAttribute)
  protected
    FTagName: string;
    FMessage: string;
  public
    constructor Create(const AMessage: string = ''); virtual;
    function TagName: string;
    function Message: string;
    function Validation: TValidation; virtual; abstract;
    function Params: TArray<TValue>; virtual;
  end;

implementation

{ IsAttribute }

constructor IsAttribute.Create(const AMessage: string);
begin
  FTagName := '';
  FMessage := AMessage;
end;

function IsAttribute.Message: string;
begin
  Result := FMessage;
end;

function IsAttribute.Params: TArray<TValue>;
begin
  Result := [];
end;

function IsAttribute.TagName: string;
begin
  Result := FTagName;
end;

end.
