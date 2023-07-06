unit dmfbr.validation.isnumber;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsNumber = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsNumber }

function TIsNumber.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if Value.IsType<Double> or Value.IsType<Single> or Value.IsType<Extended> then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be a number conforming to the specified constraints', [Args.TagName,
                                                                                                            Args.TypeName,
                                                                                                            Args.Values[Length(Args.Values) -1].ToString,
                                                                                                            Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

