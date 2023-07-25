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

unit dmfbr.transform.arguments;

interface

uses
  Rtti,
  dmfbr.transform.interfaces;

type
  TTransformArguments = class(TInterfacedObject, ITransformArguments)
  private
    FValues: TArray<TValue>;
    FTagName: string;
    FFieldName: string;
    FObjectType: TClass;
    FMessage: string;
  public
    constructor Create(const AValues: TArray<TValue>;
      const ATagName: string; const AFieldName: string;
      const AMessage: string; const AObjectType: TClass);
    function TagName: string;
    function FieldName: string;
    function Values: TArray<TValue>;
    function Message: string;
    function ObjectType: TClass;
  end;

implementation

{ TConverterArguments }

constructor TTransformArguments.Create(const AValues: TArray<TValue>;
  const ATagName: string; const AFieldName: string;
  const AMessage: string; const AObjectType: TClass);
begin
  FTagName := ATagName;
  FFieldName := AFieldName;
  FValues := AValues;
  FMessage := AMessage;
  FObjectType := AObjectType;
end;

function TTransformArguments.FieldName: string;
begin
  Result := FFieldName;
end;

function TTransformArguments.Message: string;
begin
  Result := FMessage;
end;

function TTransformArguments.ObjectType: TClass;
begin
  Result := FObjectType;
end;

function TTransformArguments.TagName: string;
begin
  Result := FTagName;
end;

function TTransformArguments.Values: TArray<TValue>;
begin
  Result := FValues;
end;

end.
