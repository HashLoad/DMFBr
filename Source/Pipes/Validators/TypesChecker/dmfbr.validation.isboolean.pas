unit dmfbr.validation.isboolean;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsBoolean = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsBoolean }

function TIsBoolean.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if (Value.Kind = tkEnumeration) and (Value.TypeInfo = TypeInfo(Boolean)) then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be a boolean value', [Args.TagName,
                                                                           Args.TypeName,
                                                                           Args.Values[Length(Args.Values) -1].ToString,
                                                                           Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

