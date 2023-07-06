unit dmfbr.validation.ismax;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsMax = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsMax }

function TIsMax.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if Value.IsType<Double> or
     Value.IsType<Single> or
     Value.IsType<Extended> or
     (Value.Kind in [tkInt64, tkInteger]) then
  begin
    if Args.Values[1].IsType<Double> or
       Args.Values[1].IsType<Single> or
       Args.Values[1].IsType<Extended> or
      (Args.Values[1].Kind in [tkInt64, tkInteger]) then
    begin
      if Value.AsExtended <= Args.Values[1].AsExtended then
        Result.Success(true);
    end;
  end;
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must not be greater than %s', [Args.TagName,
                                                                               Args.TypeName,
                                                                               Args.Values[Length(Args.Values) -1].ToString,
                                                                               Args.FieldName,
                                                                               Args.Values[1].ToString]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

