unit dmfbr.decorator.include;

interface

uses
  dmfbr.decorator.param,
  dmfbr.decorator.body,
  dmfbr.decorator.query,
  dmfbr.decorator.isbase,
  dmfbr.decorator.isstring,
  dmfbr.decorator.isinteger,
  dmfbr.decorator.isnotempty,
  dmfbr.decorator.isboolean,
  dmfbr.decorator.isnumber,
  dmfbr.decorator.isobject,
  dmfbr.decorator.isarray,
  dmfbr.decorator.isdate,
  dmfbr.decorator.isenum,
  dmfbr.decorator.isempty,
  dmfbr.decorator.ismax,
  dmfbr.decorator.ismin,
  dmfbr.decorator.isminlength,
  dmfbr.decorator.ismaxlength,
  dmfbr.decorator.isalpha,
  dmfbr.decorator.isalphanumeric,
  dmfbr.decorator.contains,
  dmfbr.decorator.islength;

type
  ParamAttribute = dmfbr.decorator.param.ParamAttribute;
  QueryAttribute = dmfbr.decorator.query.QueryAttribute;
  BodyAttribute = dmfbr.decorator.body.BodyAttribute;
  IsAttribute = dmfbr.decorator.isbase.IsAttribute;
  IsEmptyAttribute = dmfbr.decorator.isempty.IsEmptyAttribute;
  IsNotEmptyAttribute = dmfbr.decorator.isnotempty.IsNotEmptyAttribute;
  IsStringAttribute = dmfbr.decorator.isstring.IsStringAttribute;
  IsIntegerAttribute = dmfbr.decorator.isinteger.IsIntegerAttribute;
  IsBooleanAttribute = dmfbr.decorator.isboolean.IsBooleanAttribute;
  IsNumberAttribute = dmfbr.decorator.isnumber.IsnumberAttribute;
  IsObjectAttribute = dmfbr.decorator.isobject.IsObjectAttribute;
  IsArrayAttribute = dmfbr.decorator.isarray.IsArrayAttribute;
  IsEnumAttribute = dmfbr.decorator.isenum.IsEnumAttribute;
  IsDateAttribute = dmfbr.decorator.isdate.IsDateAttribute;
  IsMinAttribute = dmfbr.decorator.ismin.IsMinAttribute;
  IsMaxAttribute = dmfbr.decorator.ismax.IsMaxAttribute;
  IsMinLengthAttribute = dmfbr.decorator.isminlength.IsMinLengthAttribute;
  IsMaxLengthAttribute = dmfbr.decorator.ismaxlength.IsMaxLengthAttribute;
  IsLengthAttribute = dmfbr.decorator.islength.IsLengthAttribute;
  IsAlphaAttribute = dmfbr.decorator.isalpha.IsAlphaAttribute;
  IsAlphaNumericAttribute = dmfbr.decorator.isalphanumeric.IsAlphaNumericAttribute;
  ContainsAttribute = dmfbr.decorator.contains.ContainsAttribute;

implementation

end.
