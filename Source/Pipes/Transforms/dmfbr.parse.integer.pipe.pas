unit dmfbr.parse.integer.pipe;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  Generics.Collections,
  dmfbr.transform.pipe,
  dmfbr.transform.interfaces;


type
  TParseIntegerPipe = class(TTransformPipe)
  public
    function Transform(const Value: TValue;
      const Metadata: ITransformArguments): TResultTransform; override;
  end;

implementation

function TParseIntegerPipe.Transform(const Value: TValue;
  const Metadata: ITransformArguments): TResultTransform;
var
  LValueInt: integer;
  LMessage: string;
begin
  if TryStrToInt(Value.ToString, LValueInt) then
    Result.Success(LValueInt)
  else
  begin
    LMessage := ifThen(Metadata.Message = '',
                       Format('[%s] %s-> [%s] Validation failed (numeric string is expected)', [Metadata.TagName,
                                                                                               Self.ClassName,
                                                                                               Metadata.FieldName]), Metadata.Message);
    Result.Failure(LMessage);
  end;
end;

end.
