{
             DMFBr - Development Modular Framework for Delphi


                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.validation.pipe;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  Generics.Collections,
  dmfbr.route.handler,
  dmfbr.decorator.include,
  dmfbr.validation.include,
  dmfbr.request;

type
  TValidations = class(TList<IValidationInfo>);
  TTransforms = class(TList<ITransformInfo>);

  TValidationInfo = class(TInterfacedObject, IValidationInfo)
  private
    FValue: TValue;
    FValidationPipe: IValidatorConstraint;
    FValidationArguments: IValidationArguments;
    function GetValidator: IValidatorConstraint;
    function GetValidationArguments: IValidationArguments;
    function GetValue: TValue;
    procedure SetValidator(const Value: IValidatorConstraint);
    procedure SetValidationArguments(const Value: IValidationArguments);
    procedure SetValue(const Value: TValue);
  public
    property Validator: IValidatorConstraint read GetValidator write SetValidator;
    property ValidationArguments: IValidationArguments read GetValidationArguments write SetValidationArguments;
    property Value: TValue read GetValue write SetValue;
  end;

  TTransformInfo = class(TInterfacedObject, ITransformInfo)
  private
    FValue: TValue;
    FConvertPipe: ITransformPipe;
    FConvertArguments: ITransformArguments;
    function GetTransform: ITransformPipe;
    function GetTransformArguments: ITransformArguments;
    function GetValue: TValue;
    procedure SetTransform(const Value: ITransformPipe);
    procedure SetTransformArguments(const Value: ITransformArguments);
    procedure SetValue(const Value: TValue);
  public
    property Transform: ITransformPipe read GetTransform write SetTransform;
    property TransformArguments: ITransformArguments read GetTransformArguments write SetTransformArguments;
    property Value: TValue read GetValue write SetValue;
  end;

  TValidationPipe = class(TInterfacedObject, IValidationPipe)
  private
    FContext: TRttiContext;
    FValidations: TValidations;
    FTransforms: TTransforms;
    FMessages: TList<string>;
    FJsonMapped: TJsonMapped;
    procedure _MapPipes(const AClass: TClass; const ARequest: IRouteRequest); inline;
    procedure _MapValidation(const AClass: TClass; const ARequest: IRouteRequest); inline;
    procedure _ResolveParams(const ADecorator: TCustomAttribute; const ARequest: IRouteRequest); inline;
    procedure _ResolveQuerys(const ADecorator: TCustomAttribute; const ARequest: IRouteRequest); inline;
    procedure _ResolvePipes(const AClass: TClass; const ARttiType: TRttiType;
      const ARequest: IRouteRequest); inline;
    procedure _ResolvePayLoads(const ARttiType: TRttiType;
      const ARequest: IRouteRequest); inline;
    procedure _ResolveBody(const ADecorator: TCustomAttribute; const ARequest: IRouteRequest);
  public
    constructor Create;
    destructor Destroy; override;
    function IsMessages: boolean; inline;
    function BuildMessages: string; inline;
    procedure Validate(const AClass: TClass; const ARequest: IRouteRequest);
  end;

implementation

uses
  eclbr.interfaces,
  eclbr.objectlib,
  eclbr.sysutils;

{ TValidationPipe }

constructor TValidationPipe.Create;
begin
  FContext := TRttiContext.Create;
  FMessages := TList<string>.Create;
end;

destructor TValidationPipe.Destroy;
begin
  FContext.Free;
  FMessages.Free;
  inherited;
end;

function TValidationPipe.IsMessages: boolean;
begin
  Result := false;
  if FMessages = nil then
    exit;
  Result := FMessages.Count > 0;
end;

procedure TValidationPipe.Validate(const AClass: TClass;
  const ARequest: IRouteRequest);
var
  LValidator: IValidationInfo;
  LInfo: ITransformInfo;
  LResultTransform: TResultTransform;
  LResultValidation: TResultValidation;
begin
  FMessages.Clear;
  FJsonMapped := TJsonMapped.Create([doOwnsValues]);
  FValidations := TValidations.Create;
  FTransforms := TTransforms.Create;
  try
    _MapValidation(AClass, ARequest);
    // Transforms
    for LInfo in FTransforms do
    begin
      LResultTransform := LInfo.Transform.Transform(LInfo.Value,
                                                    LInfo.Metadata);
      LResultTransform.TryException(
        procedure (Msg: string)
        begin
          FMessages.Add(Msg);
        end,
        procedure (Value: TValue)
        begin
          if LInfo.Metadata.TagName = 'body' then
          begin
            if Value.IsObject then
              ARequest.SetObject(Value.AsType<TObject>)
            else
              ARequest.SetBody(Value.AsType<string>);
          end
          else
          if LInfo.Metadata.TagName = 'param' then
            ARequest.Params.AddOrSetValue(LInfo.Metadata.FieldName, Value)
          else
          if LInfo.Metadata.TagName = 'query' then
            ARequest.Querys.AddOrSetValue(LInfo.Metadata.FieldName, Value);
        end);
    end;
    // Validations
    for LValidator in FValidations do
    begin
      LResultValidation := LValidator.Validator.Validate(LValidator.Value,
                                                         LValidator.Args);
      LResultValidation.TryException(
        procedure (Msg: string)
        begin
          FMessages.Add(Msg);
        end,
        procedure (Value: boolean)
        begin

        end);
    end;
  finally
    FJsonMapped.Free;
    FValidations.Free;
    FTransforms.Free;
  end;
end;

procedure TValidationPipe._ResolveBody(const ADecorator: TCustomAttribute;
  const ARequest: IRouteRequest);
var
  LBody: BodyAttribute;
  LTransform: ITransformInfo;
  LValue: TValue;
  LResultBody: TResultTransform;
  LFactory: IEclLib;
begin
  LBody := BodyAttribute(ADecorator);
  LValue := ARequest.Body;
  if LBody.Transform <> nil then
  begin
    if LBody.Transform.InheritsFrom(TParseJsonPipe) then
    begin
      LFactory := TObjectLib.New;
      // Transform
      LTransform := TTransformInfo.Create;
      LTransform.Transform := LFactory.Factory(LBody.Transform) as TParseJsonPipe;
      LTransform.Value := LValue;
      LTransform.Metadata := TTransformArguments.Create([TValue.FromVariant(LBody.Value)],
                                                        LBody.TagName,
                                                        'body',
                                                        LBody.Message,
                                                        LBody.ObjectType);
      LResultBody := LTransform.Transform
                               .Transform(LValue, LTransform.Metadata);
      LResultBody.TryException(
        procedure (Msg: string)
        begin
          FMessages.Add(Msg);
          exit;
        end,
        procedure (Value: TValue)
        var
          LItem: TPair<string, TList<TValue>>;
        begin
          for LItem in Value.AsType<TJsonMapped> do
            FJsonMapped.AddOrSetValue(LItem.Key, TList<TValue>.Create(LItem.Value));
        end);
    end
    else
    begin
      if LBody.Transform <> nil then
      begin
        LTransform := TTransformInfo.Create;
        LTransform.Transform := LBody.Transform.Create as TTransformPipe;
        LTransform.Value := LValue;
        LTransform.Metadata := TTransformArguments.Create([TValue.FromVariant(LBody.Value)],
                                                          LBody.TagName,
                                                          'body',
                                                          LBody.Message,
                                                          LBody.ObjectType);
        FTransforms.Add(LTransform);
      end;
    end;
  end;
  _MapPipes(LBody.ObjectType, ARequest);
end;

procedure TValidationPipe._ResolveParams(const ADecorator: TCustomAttribute;
  const ARequest: IRouteRequest);
var
  LValue: TValue;
  LParam: ParamAttribute;
  LTransform: ITransformInfo;
  LValidation: IValidationInfo;
begin
  LParam := ParamAttribute(ADecorator);
  LValue := IfThen(ARequest.Params.ContainsKey(LParam.ParamName), ARequest.Params.Value<string>(LParam.ParamName), '');
  // Transform
  if LParam.Transform <> nil then
  begin
    LTransform := TTransformInfo.Create;
    LTransform.Transform := LParam.Transform.Create as TTransformPipe;
    LTransform.Value := LValue;
    LTransform.Metadata := TTransformArguments.Create([TValue.FromVariant(LParam.Value)],
                                                      LParam.TagName,
                                                      LParam.ParamName,
                                                      LParam.Message,
                                                      nil);
    FTransforms.Add(LTransform);
  end;
  // Validation
  if LParam.Validation <> nil then
  begin
    LValidation := TValidationInfo.Create;
    LValidation.Value := TValue.Empty;
    LValidation.Validator := LParam.Validation.Create as TValidatorConstraint;
    LValidation.Args := TValidationArguments.Create([''],
                                                    LParam.TagName,
                                                    LParam.ParamName,
                                                    LParam.Message, 'param', nil);
    FValidations.Add(LValidation);
  end;
end;

procedure TValidationPipe._MapValidation(const AClass: TClass;
  const ARequest: IRouteRequest);
var
  LRttiType: TRttiType;
begin
  LRttiType := FContext.GetType(AClass);
  _ResolvePayLoads(LRttiType, ARequest);
end;

procedure TValidationPipe._MapPipes(const AClass: TClass;
  const ARequest: IRouteRequest);
var
  LRttiType: TRttiType;
begin
  LRttiType := FContext.GetType(AClass);
  _ResolvePipes(AClass, LRttiType, ARequest);
end;

procedure TValidationPipe._ResolvePayLoads(const ARttiType: TRttiType;
  const ARequest: IRouteRequest);
var
  LMethod: TRttiMethod;
  LDecorator: TCustomAttribute;
begin
  for LMethod in ARttiType.GetMethods do
  begin
    for LDecorator in LMethod.GetAttributes do
    begin
      if LDecorator is BodyAttribute then
        _ResolveBody(LDecorator, ARequest)
      else
      if LDecorator is ParamAttribute then
        _ResolveParams(LDecorator, ARequest)
      else
      if LDecorator is QueryAttribute then
        _ResolveQuerys(LDecorator, ARequest);
    end;
  end;
end;

procedure TValidationPipe._ResolvePipes(const AClass: TClass;
  const ARttiType: TRttiType; const ARequest: IRouteRequest);
var
  LProperty: TRttiProperty;
  LDecorator: TCustomAttribute;
  LValidation: IValidationInfo;
  LIsAttribute: IsAttribute;
  LClassType: TClass;
  LKey: string;
  LFor: integer;
  LValues: TList<TValue>;
  LParams_0: TArray<TValue>;
  LParams_X: TArray<TValue>;
begin
  LClassType := nil;
  for LProperty in ARttiType.GetProperties do
  begin
    if LProperty.PropertyType.TypeKind = tkClass then
    begin
      LClassType := LProperty.GetValue(AClass).AsClass;
      // Map Object
      _MapPipes(LClassType, ARequest);
    end;
    for LDecorator in LProperty.GetAttributes do
    begin
      LIsAttribute := IsAttribute(LDecorator);
      LKey := AClass.ClassName + '->' + LProperty.Name;
      LParams_0 := IsAttribute(LDecorator).Params;
      if FJsonMapped.TryGetValue(LKey, LValues) then
      begin
        for LFor := 0 to LValues.Count -1 do
        begin
          LParams_X := TUtils.ArrayMerge<TValue>(LParams_0, [LFor]);
          LValidation := TValidationInfo.Create;
          LValidation.Value := LValues[LFor];
          LValidation.Validator := LIsAttribute.Validation.Create as TValidatorConstraint;
          LValidation.Args := TValidationArguments.Create(LParams_X,
                                                          LIsAttribute.TagName,
                                                          LProperty.Name,
                                                          LIsAttribute.Message,
                                                          AClass.ClassName,
                                                          LClassType);
          FValidations.Add(LValidation);
        end;
      end;
    end;
  end;
end;

procedure TValidationPipe._ResolveQuerys(const ADecorator: TCustomAttribute;
  const ARequest: IRouteRequest);
var
  LValue: TValue;
  LQuery: QueryAttribute;
  LTransform: ITransformInfo;
  LValidation: IValidationInfo;
begin
  LQuery := QueryAttribute(ADecorator);
  LValue := IfThen(ARequest.Querys.ContainsKey(LQuery.QueryName), ARequest.Querys.Value<string>(LQuery.QueryName), '');
  // Transform
  if LQuery.Transform <> nil then
  begin
    LTransform := TTransformInfo.Create;
    LTransform.Transform := LQuery.Transform.Create as TTransformPipe;
    LTransform.Value := LValue;
    LTransform.Metadata := TTransformArguments.Create([TValue.FromVariant(LQuery.Value)],
                                                      LQuery.TagName,
                                                      LQuery.QueryName,
                                                      LQuery.Message,
                                                      nil);
    FTransforms.Add(LTransform);
  end;
  // Validation
  if LQuery.Validation <> nil then
  begin
    LValidation := TValidationInfo.Create;
    LValidation.Value := LValue;
    LValidation.Validator := LQuery.Validation.Create as TValidatorConstraint;
    LValidation.Args := TValidationArguments.Create([''],
                                                    LQuery.TagName,
                                                    LQuery.QueryName,
                                                    LQuery.Message, 'query', nil);
    FValidations.Add(LValidation);
  end;
end;

function TValidationPipe.BuildMessages: string;
var
  LJsonArray: string;
  LJsonItem: string;
  IFor: Integer;
begin
  LJsonArray := '[';
  for IFor := 0 to FMessages.Count - 1 do
  begin
    LJsonItem := Format('"%s"', [FMessages[IFor]]);
    if IFor < FMessages.Count - 1 then
      LJsonItem := LJsonItem + ',';
    LJsonArray := LJsonArray + LJsonItem;
  end;
  LJsonArray := LJsonArray + ']';
  Result := Format('{"statusCode": "400", "message": %s, "error": "Bad Request"}', [LJsonArray]);
end;

{ TValidation }

function TValidationInfo.GetValidator: IValidatorConstraint;
begin
  Result := FValidationPipe;
end;

function TValidationInfo.GetValue: TValue;
begin
  Result := FValue;
end;

function TValidationInfo.GetValidationArguments: IValidationArguments;
begin
  Result := FValidationArguments;
end;

procedure TValidationInfo.SetValidator(const Value: IValidatorConstraint);
begin
  FValidationPipe := Value;
end;

procedure TValidationInfo.SetValue(const Value: TValue);
begin
  FValue := Value;
end;

procedure TValidationInfo.SetValidationArguments(const Value: IValidationArguments);
begin
  FValidationArguments := Value;
end;

{ TTransformInfo }

function TTransformInfo.GetTransformArguments: ITransformArguments;
begin
  Result := FConvertArguments;
end;

function TTransformInfo.GetValue: TValue;
begin
  Result := FValue;
end;

function TTransformInfo.GetTransform: ITransformPipe;
begin
  Result := FConvertPipe;
end;

procedure TTransformInfo.SetTransformArguments(const Value: ITransformArguments);
begin
  FConvertArguments := Value;
end;

procedure TTransformInfo.SetValue(const Value: TValue);
begin
  FValue := Value;
end;

procedure TTransformInfo.SetTransform(const Value: ITransformPipe);
begin
  FConvertPipe := Value;
end;

end.
