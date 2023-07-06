unit dmfbr.validation.isinteger;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsInteger = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsInteger }

function TIsInteger.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if Value.Kind in [tkInt64, tkInteger] then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be an integer number', [Args.TagName,
                                                                             Args.TypeName,
                                                                             Args.Values[Length(Args.Values) -1].ToString,
                                                                             Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

