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

unit dmfbr.parse.json.pipe;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  dmfbr.validation.parse.json,
  dmfbr.transform.pipe,
  dmfbr.transform.interfaces;


type
  TParseJsonPipe = class(TTransformPipe)
  private
    FJsonMap: TJsonMapped;
  public
    constructor Create;
    destructor Destroy; override;
    function Transform(const Value: TValue;
      const Metadata: ITransformArguments): TResultTransform; override;
  end;

implementation

{ TParseJsonPipe }

constructor TParseJsonPipe.Create;
begin
  FJsonMap := TJsonMapped.Create([doOwnsValues]);
end;

destructor TParseJsonPipe.Destroy;
begin
  FJsonMap.Free;
  inherited;
end;

function TParseJsonPipe.Transform(const Value: TValue;
  const Metadata: ITransformArguments): TResultTransform;
var
  LKey: string;
begin
  try
    TJsonMap.Map(Value.AsString, Metadata.ObjectType,
      procedure (const AClassType: TClass; const AFieldName: string;
                 const AValue: TValue)
      begin
        LKey := AClassType.ClassName + '->' + AFieldName;
        if not FJsonMap.ContainsKey(LKey) then
          FJsonMap.Add(LKey, TList<TValue>.Create);
        FJsonMap[LKey].Add(AValue);
      end);
    Result.Success(FJsonMap);
  except
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

end.
