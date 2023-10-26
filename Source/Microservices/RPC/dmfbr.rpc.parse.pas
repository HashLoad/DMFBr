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

unit dmfbr.rpc.parse;

interface

uses
  Rtti,
  JSON,
  SysUtils,
  Generics.Collections;

type
  TRPCParse = class
  public
    procedure RPCParseRequest(const ARequest: string;
      var ARPCID: string; var ARPCName: string; var ARPCParams: TArray<TValue>);
  end;

implementation

uses
  dmfbr.rpc.exception;

procedure TRPCParse.RPCParseRequest(const ARequest: string;
  var ARPCID: string; var ARPCName: string; var ARPCParams: TArray<TValue>);
var
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LJSONParam: TJSONValue;
  LParams: TJSONArray;
  LParamValue: TValue;
  LFor: integer;
begin
  SetLength(ARPCParams, 0);
  LJSONValue := TJSONObject.ParseJSONValue(ARequest);
  try
    if not Assigned(LJSONValue) then
      raise ERPCJSONException.Create('JSON-RPC request is not valid. Missing "params" field.')
    else if not (LJSONValue is TJSONObject) then
      raise ERPCJSONException.Create('JSON-RPC request is not valid. "params" field is not an object.');

    LJSONObject := TJSONObject(LJSONValue);
    try
      ARPCID := LJSONObject.GetValue('id').Value;
      ARPCName := LJSONObject.GetValue('method').Value;
      LParams := TJSONArray(LJSONObject.GetValue('params'));
      if (not Assigned(LParams)) and (not (LParams is TJSONArray)) then
        raise ERPCJSONParamsException.Create('JSON-RPC request is not valid. "params" field is not an array.');

      SetLength(ARPCParams, LParams.Count);
      for LFor := 0 to LParams.Count - 1 do
      begin
        LJSONParam := LParams.Items[LFor];
        if LJSONParam.TryGetValue<TValue>(LParamValue) then
          ARPCParams[LFor] := LParamValue
        else
          ARPCParams[LFor] := TValue.Empty;
      end;
    finally
      LJSONObject.Free;
    end;
  finally
    LJSONValue.Free;
  end;
end;

end.
