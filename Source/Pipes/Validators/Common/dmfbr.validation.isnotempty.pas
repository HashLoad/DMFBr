unit dmfbr.validation.isnotempty;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsNotEmpty = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsNotEmpty }

function TIsNotEmpty.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(Value.ToString <> '');
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] should not be empty', [Args.TagName,
                                                                       Args.TypeName,
                                                                       Args.Values[Length(Args.Values) -1].ToString,
                                                                       Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.
