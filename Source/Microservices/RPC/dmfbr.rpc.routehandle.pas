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

unit dmfbr.rpc.routehandle;

interface

uses
  Rtti,
  SysUtils,
  dmfbr.rpc.parse,
  dmfbr.rpc.publish,
  dmfbr.rpc.resource,
  dmfbr.rpc.interfaces;

type
  TRPCRouteHandle = class(TInterfacedObject, IRPCRouteHandle)
  private
    const
      RPCNOTFOUND = '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method %s not found"},"id":%s}';
      RPCRESPONSE = '{"jsonrpc":"2.0","result":%s,"id":%s}';
  private
    FParseRPC: TRPCParse;
    FPublishRPC: TRPCPublish;
  public
    constructor Create;
    destructor Destroy; override;
    procedure PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass);
    function ExecuteRPC(const ARequest: string): string;
  end;

implementation

uses
  dmfbr.rpc.exception;

{ TRouteHandleRPC }

constructor TRPCRouteHandle.Create;
begin
  FParseRPC := TRPCParse.Create;
  FPublishRPC := TRPCPublish.Create;
end;

destructor TRPCRouteHandle.Destroy;
begin
  FParseRPC.Free;
  FPublishRPC.Free;
  inherited;
end;

function TRPCRouteHandle.ExecuteRPC(const ARequest: string): string;
var
  LContext: TRttiContext;
  LMethod: TRttiMethod;
  LResource: TRPCResourceClass;
  LResult: TValue;
  LRPCID: string;
  LRPCName: string;
  LRPCParams: TArray<TValue>;
begin
  FParseRPC.RPCParseRequest(ARequest, LRPCID, LRPCName, LRPCParams);
  if not FPublishRPC.RPCs.ContainsKey(LRPCName) then
  begin
    Result := Format(RPCNOTFOUND, [LRPCName, LRPCID]);
    exit;
  end;
  LResource := FPublishRPC.RPCs[LRPCName];
  LContext := TRttiContext.Create;
  try
    LMethod := LContext.GetType(LResource).GetMethod(LRPCName);
    if not Assigned(LMethod) then
    begin
      Result := Format(RPCNOTFOUND, [LRPCName, LRPCID]);
      exit;
    end;
    LResult := LMethod.Invoke(LResource, LRPCParams);
    Result := Format(RPCRESPONSE, [LResult.ToString, LRPCID]);
  finally
    LContext.Free;
  end;
end;

procedure TRPCRouteHandle.PublishRPC(const ARPCName: string;
  const ARPCClass: TRPCResourceClass);
begin
  FPublishRPC.RPCs.AddOrSetValue(ARPCName, ARPCClass);
end;

end.
