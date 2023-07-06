unit dmfbr.validation.isdate;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsDate = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsDate }

function TIsDate.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if (Value.TypeInfo = TypeInfo(TDate)) or (Value.TypeInfo = TypeInfo(TDateTime)) then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be a Date instance', [Args.TagName,
                                                                           Args.TypeName,
                                                                           Args.Values[Length(Args.Values) -1].ToString,
                                                                           Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

