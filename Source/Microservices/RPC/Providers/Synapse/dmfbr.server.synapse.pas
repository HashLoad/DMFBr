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

unit dmfbr.server.synapse;

interface

uses
  SysUtils,
  Classes,
  blcksock,
  synsock,
  synautil,
  dmfbr.rpc.server;

type
  TRPCProviderServerSynapse = class(TRPCProviderServer)
  private
    FTCPServer: TTCPBlockSocket;
    FTerminated: Boolean;
    procedure HandleClientConnection(AClientSocket: TTCPBlockSocket);
  public
    constructor Create(const AHost: string; const APort: integer = 8080); override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

  TTCPServerThread = class(TThread)
  private
    FServer: TRPCProviderServerSynapse;
  public
    constructor Create(const AServer: TRPCProviderServerSynapse);
    procedure Execute; override;
  end;

implementation

{ TRPCProviderServerSynapse }

constructor TRPCProviderServerSynapse.Create(const AHost: string; const APort: integer);
begin
  inherited Create(AHost, APort);
  FTCPServer := TTCPBlockSocket.Create;
  FTerminated := False;
end;

destructor TRPCProviderServerSynapse.Destroy;
begin
  FTCPServer.Free;
  inherited;
end;

procedure TRPCProviderServerSynapse.HandleClientConnection(AClientSocket: TTCPBlockSocket);
var
  LRequestData: string;
  LResponseData: string;
begin
  LRequestData := String(AClientSocket.RecvTerminated(5000, #10));
  LResponseData := ExecuteRPC(LRequestData);
  AClientSocket.SendString(AnsiString(LResponseData + CRLF));
  AClientSocket.CloseSocket;
end;

procedure TRPCProviderServerSynapse.Start;
begin
  TTCPServerThread.Create(Self).Start;
end;

procedure TRPCProviderServerSynapse.Stop;
begin
  FTerminated := true;
end;

{ TServerThread }

constructor TTCPServerThread.Create(const AServer: TRPCProviderServerSynapse);
begin
  inherited Create(true);
  FServer := AServer;
end;

procedure TTCPServerThread.Execute;
var
  LClientSocket: TTCPBlockSocket;
begin
  FServer.FTCPServer.Bind(FServer.FHost, IntToStr(FServer.FPort));
  FServer.FTCPServer.Listen;
  while not FServer.FTerminated do
  begin
    if FServer.FTCPServer.CanRead(100) then
    begin
      LClientSocket := TTCPBlockSocket.Create;
      try
        LClientSocket.Socket := FServer.FTCPServer.Accept;
        FServer.HandleClientConnection(LClientSocket);
      except
        LClientSocket.Free;
      end;
    end;
  end;
end;

end.
