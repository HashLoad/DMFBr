unit dmfbr.transform.pipe;

interface

uses
  Rtti,
  SysUtils,
  dmfbr.transform.interfaces;

type
  TTransformPipe = class(TInterfacedObject, ITransformPipe)
  public
    function Transform(const Value: TValue; const Metadata: ITransformArguments): TResultTransform; virtual; abstract;
  end;

implementation

end.

