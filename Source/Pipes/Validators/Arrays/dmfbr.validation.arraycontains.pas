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

unit dmfbr.validation.arraycontains;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  dmfbr.validator.constraint,
  dmfbr.validation.interfaces;

type
  TArrayContains = class(TValidatorConstraint)
  private
    function _ArrayToString(const AValues: TArray<TValue>): string;
    function _ArrayContainsAllElements(const ASource, AValues: TArray<TValue>): boolean;
  public
    function Validate(const Value: TValue;
      const Args: IValidationArguments): TResultValidation; override;
  end;

implementation

{ TArrayContains }

function TArrayContains.Validate(const Value: TValue;
  const Args: IValidationArguments): TResultValidation;
var
  LMessage: string;
begin
  Result.Success(false);
  if Value.Kind in [tkArray, tkDynArray] then
  begin
    if _ArrayContainsAllElements(Value.AsType<TArray<TValue>>, Args.Values) then
      Result.Success(true);
  end;
  if not Result.ValueSuccess then
  begin
    LMessage := IfThen(Args.Message = '',
                       Format('[%s] %s->%s [%s] must contain a %s values',
                       [Args.TagName,
                        Args.TypeName,
                        Args.Values[Length(Args.Values) -1].ToString,
                        Args.FieldName,
                        _ArrayToString(Args.Values)]), Args.Message);
    Result.Failure(LMessage);
  end;
end;

function TArrayContains._ArrayToString(const AValues: TArray<TValue>): string;
var
  LItem: TValue;
begin
  Result := '';
  for LItem in AValues do
    Result := Result + LItem.ToString + ', ';
end;

function TArrayContains._ArrayContainsAllElements(const ASource, AValues: TArray<TValue>): boolean;
var
  LFor, LFind: integer;
  LFound: boolean;
begin
  Result := true;
  for LFor := Low(AValues) to High(AValues) do
  begin
    LFound := False;
    for LFind := Low(ASource) to High(ASource) do
    begin
      if AValues[LFor].ToString = ASource[LFind].ToString then
      begin
        LFound := true;
        break;
      end;
    end;
    if not LFound then
    begin
      Result := False;
      exit;
    end;
  end;
end;

end.
