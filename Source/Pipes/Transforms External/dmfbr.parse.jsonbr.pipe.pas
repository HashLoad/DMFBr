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

unit dmfbr.parse.jsonbr.pipe;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  dmfbr.transform.pipe,
  dmfbr.transform.interfaces;


type
  TParseJsonBrPipe = class(TTransformPipe)
  public
    function Transform(const Value: TValue;
      const Metadata: ITransformArguments): TResultTransform; override;
  end;

implementation

uses
  jsonbr,
  jsonbr.builders;

{ TParseJsonBrPipe }

function TParseJsonBrPipe.Transform(const Value: TValue;
  const Metadata: ITransformArguments): TResultTransform;
var
  LObject: TObject;
  LObjects: TObjectList<TObject>;
  LIsArray: boolean;
begin
  LIsArray := Value.AsString[1] = '[';
  try
    if LIsArray then
    begin
      LObjects := TObjectList<TObject>.Create;
      LObjects := TJsonBr.JsonToObjectList(Value.AsString, Metadata.ObjectType);
      Result.Success(LObjects);
    end
    else
    begin
      LObject := Metadata.ObjectType.Create;
      TJsonBr.JsonToObject(Value.AsString, LObject);
      Result.Success(LObject);
    end;
  except
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

end.
