unit dmfbr.validation.isenum;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsEnum = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsEnum }

function TIsEnum.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if (Value.IsOrdinal) and (Value.TypeInfo^.Kind = tkEnumeration) then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be one of the following values', [Args.TagName,
                                                                                       Args.TypeName,
                                                                                       Args.Values[Length(Args.Values) -1].ToString,
                                                                                       Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

