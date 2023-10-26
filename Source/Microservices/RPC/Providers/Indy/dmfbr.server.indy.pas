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

unit dmfbr.server.indy;

interface

uses
  SysUtils,
  Classes,
  IdContext,
  IdTCPConnection,
  IdCustomTCPServer,
  dmfbr.rpc.server;

type
  TIdCustomTCPServerHacker = class(IdCustomTCPServer.TIdCustomTCPServer);

  TRPCProviderServerIndy = class(TRPCProviderServer)
  private
    FTCPServer: TIdCustomTCPServer;
    procedure OnExecute(AContext: TIdContext);
  public
    constructor Create(const AHost: string; const APort: integer = 8080); override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

{ TTCPRPCProviderIndy }

constructor TRPCProviderServerIndy.Create(const AHost: string; const APort: integer);
begin
  inherited Create(AHost, APort);
  FTCPServer := TIdCustomTCPServer.Create(nil);
  FTCPServer.Bindings.Add.IP := FHost;
  FTCPServer.Bindings.Add.Port := FPort;
  TIdCustomTCPServerHacker(FTCPServer).FOnExecute := OnExecute;
end;

destructor TRPCProviderServerIndy.Destroy;
begin
  FTCPServer.Free;
  inherited;
end;

procedure TRPCProviderServerIndy.OnExecute(AContext: TIdContext);
var
  LResponseData: string;
begin
  LResponseData := ExecuteRPC(AContext.Connection.IOHandler.ReadLn);
  AContext.Connection.IOHandler.WriteLn(LResponseData);
  AContext.Connection.Disconnect;
end;

procedure TRPCProviderServerIndy.Start;
begin
  FTCPServer.Active := true;
end;

procedure TRPCProviderServerIndy.Stop;
begin
  FTCPServer.Active := false;
end;

end.
