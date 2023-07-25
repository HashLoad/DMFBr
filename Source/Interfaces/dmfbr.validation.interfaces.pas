unit dmfbr.validation.interfaces;

interface

uses
  Rtti,
  Generics.Collections,
  dmfbr.request,
  result.pair;

type
  TResultValidation = TResultPair<string, boolean>;

  IValidationArguments = interface
    ['{008AE8DA-AA34-4881-9477-617A0CD9B158}']
    function TagName: string;
    function FieldName: string;
    function Values: TArray<TValue>;
    function Message: string;
    function TypeName: string;
    function ObjectType: TClass;
  end;

  IValidatorConstraint = interface
    ['{56130D3B-C251-4F85-9215-937B08B17A43}']
    function Validate(const Value: TValue; const Args: IValidationArguments): TResultValidation;
  end;

  IValidationInfo = interface
    ['{8FCA8E1D-2244-46A2-9E7C-DB6F829EB6EE}']
    function GetValidator: IValidatorConstraint;
    function GetValidationArguments: IValidationArguments;
    function GetValue: TValue;
    procedure SetValidator(const Value: IValidatorConstraint);
    procedure SetValidationArguments(const Value: IValidationArguments);
    procedure SetValue(const Value: TValue);
    property Validator: IValidatorConstraint read GetValidator write SetValidator;
    property Args: IValidationArguments read GetValidationArguments write SetValidationArguments;
    property Value: TValue read GetValue write SetValue;
  end;

  IValidationPipe = interface
    ['{9795C9EF-4FE3-422E-A237-C238E3935FD6}']
    function IsMessages: boolean;
    function BuildMessages: string;
    procedure Validate(const AClass: TClass; const ARequest: IRouteRequest);
  end;

//  IValidatorOptions = interface
//    ['{6E078A2B-4E6A-4B27-B80A-18EB9C0EF27F}']
//    procedure SetOption(const APair: TPair<string, TValue>);
//    function GetOption(const AKey: string): TValue;
//  end;

implementation

end.


