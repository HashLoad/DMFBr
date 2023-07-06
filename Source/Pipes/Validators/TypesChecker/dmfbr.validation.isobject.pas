unit dmfbr.validation.isobject;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsObject = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsObject }

function TIsObject.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if Value.IsObject then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be an object', [Args.TagName,
                                                                     Args.TypeName,
                                                                     Args.Values[Length(Args.Values) -1].ToString,
                                                                     Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

