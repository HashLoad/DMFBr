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

unit dmfbr.validation.isboolean;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TIsBoolean = class(TValidatorConstraint)
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TIsBoolean }

function TIsBoolean.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
//  LValue: boolean;
begin
  Result.Success(false);
//  if TryStrToBool(Value.ToString, LValue) then
//    Result.Success(true);
  if (Value.Kind = tkEnumeration) and (Value.TypeInfo = TypeInfo(Boolean)) then
    Result.Success(true);
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must be a boolean value',
                       [Args.TagName,
                        Args.TypeName,
                        Args.Values[Length(Args.Values) -1].ToString,
                        Args.FieldName]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

end.

