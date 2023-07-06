unit dmfbr.transform.interfaces;

interface

uses
  Rtti,
  Generics.Collections,
  dmfbr.request,
  result.pair;

type
  TResultTransform = TResultPair<string, TValue>;
  TJsonMapped = TObjectDictionary<string, TList<TValue>>;

  ITransformArguments = interface
    ['{C410FE53-25D6-42DD-8D61-AF04E97C1628}']
    function TagName: string;
    function FieldName: string;
    function Value: TValue;
    function Message: string;
    function ObjectType: TClass;
  end;

  ITransformPipe = interface
    ['{3E8A1756-3273-4FCA-87D8-242F92F588BD}']
    function Transform(const Value: TValue; const Metadata: ITransformArguments): TResultTransform;
  end;

  ITransformInfo = interface
    ['{8FCA8E1D-2244-46A2-9E7C-DB6F829EB6EE}']
    function GetTransform: ITransformPipe;
    function GetTransformArguments: ITransformArguments;
    procedure SetTransform(const Value: ITransformPipe);
    procedure SetTransformArguments(const Value: ITransformArguments);
    property Transform: ITransformPipe read GetTransform write SetTransform;
    property Metadata: ITransformArguments read GetTransformArguments write SetTransformArguments;
  end;

implementation

end.
