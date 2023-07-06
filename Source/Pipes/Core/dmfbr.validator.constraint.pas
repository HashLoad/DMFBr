unit dmfbr.validator.constraint;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validation.interfaces;

type
  TValidatorConstraint = class(TInterfacedObject, IValidatorConstraint)
  public
    function Validate(const Value: TValue; const Args: IValidationArguments): TResultValidation; virtual; abstract;
  end;

implementation

end.

