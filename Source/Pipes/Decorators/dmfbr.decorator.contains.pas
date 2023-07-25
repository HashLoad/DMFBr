{
             DMFBr - Development Modular Framework for Delphi

                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.decorator.contains;

interface

uses
  SysUtils,
  dmfbr.decorator.isbase,
  dmfbr.validation.types,
  dmfbr.validation.contains;

type
  ContainsAttribute = class(IsAttribute)
  private
    FValue: string;
  public
    constructor Create(const AValue: string; const AMessage: string = ''); reintroduce;
    function Validation: TValidation; override;
    function Params: TArray<TValue>; override;
  end;

implementation

{ IsArrayAttribute }

constructor ContainsAttribute.Create(const AValue: string; const AMessage: string);
begin
  inherited Create(AMessage);
  FTagName := 'Contains';
  FValue := AValue;
end;

function ContainsAttribute.Params: TArray<TValue>;
begin
  Result := [FValue];
end;

function ContainsAttribute.Validation: TValidation;
begin
  Result := TContains;
end;

end.

