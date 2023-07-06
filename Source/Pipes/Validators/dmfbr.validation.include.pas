unit dmfbr.validation.include;

interface

uses
  Rtti,
  Generics.Collections,
  dmfbr.validation.body,
  dmfbr.validation.param,
  dmfbr.validation.query,
  dmfbr.validation.isbase,
  dmfbr.validation.isstring,
  dmfbr.validation.isinteger,
  dmfbr.validation.isempty,
  dmfbr.validation.isnotempty,
  dmfbr.argument.metadata,
  dmfbr.validation.interfaces;

type
  TConverter = TClass;
  TValidation = TClass;
  TObjectType = TClass;
  IArgumentMetadata = dmfbr.validation.interfaces.IArgumentMetadata;
  TArgumentMetadata = dmfbr.argument.metadata.TArgumentMetadata;
  IValidatorConstraint = dmfbr.validation.interfaces.IValidatorConstraint;
  TResultPair = dmfbr.validation.interfaces.TResultPair;
  TValue = Rtti.TValue;
  TBody = dmfbr.validation.body.TBody;
  TParam = dmfbr.validation.param.TParam;
  TQuery = dmfbr.validation.query.TQuery;
  IsBase = dmfbr.validation.isbase.TIsBase;
  TIsEmpty = dmfbr.validation.isempty.TIsEmpty;
  TIsNotEmpty = dmfbr.validation.isnotempty.TIsNotEmpty;
  TIsString = dmfbr.validation.isstring.TIsString;
  TIsInteger = dmfbr.validation.isinteger.TIsInteger;

implementation

end.
