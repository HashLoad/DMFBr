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

unit dmfbr.validation.arguments;

interface

uses
  Rtti,
  dmfbr.validation.interfaces;

type
  TValidationArguments = class(TInterfacedObject, IValidationArguments)
  private
    FValues: TArray<TValue>;
    FObjectType: TClass;
    FTagName: string;
    FFieldName: string;
    FMessage: string;
    FTypeName: string;
  public
    constructor Create(const AValues: TArray<TValue>;
      const ATagName: string; const AFieldName: string; const AMessage: string;
      const ATypeName: string; const AObjectType: TClass);
    function Values: TArray<TValue>;
    function TagName: string;
    function FieldName: string;
    function Message: string;
    function TypeName: string;
    function ObjectType: TClass;
  end;

implementation

{ TArgumentMetadata }

function TValidationArguments.ObjectType: TClass;
begin
  Result := FObjectType;
end;

constructor TValidationArguments.Create(const AValues: TArray<TValue>;
  const ATagName: string; const AFieldName: string;
  const AMessage: string; const ATypeName: string; const AObjectType: TClass);
begin
  FTagName := ATagName;
  FFieldName := AFieldName;
  FValues := AValues;
  FMessage := AMessage;
  FTypeName := ATypeName;
  FObjectType := AObjectType;
end;

function TValidationArguments.FieldName: string;
begin
  Result := FFieldName;
end;

function TValidationArguments.Message: string;
begin
  Result := FMessage;
end;

function TValidationArguments.TagName: string;
begin
  Result := FTagName;
end;

function TValidationArguments.TypeName: string;
begin
  Result := FTypeName;
end;

function TValidationArguments.Values: TArray<TValue>;
begin
  Result := FValues;
end;

end.
