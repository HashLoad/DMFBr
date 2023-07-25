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

unit dmfbr.rpc.server;

interface

uses
  dmfbr.rpc.routehandle,
  dmfbr.rpc.interfaces,
  dmfbr.rpc.resource;

type
  TRPCProviderServer = class(TInterfacedObject, IRPCProviderServer)
  private
    FRPCRouteHandle: IRPCRouteHandle;
  protected
    FHost: string;
    FPort: integer;
  public
    constructor Create(const AHost: string; const APort: integer = 8080); virtual;
    destructor Destroy; override;
    procedure Start; virtual;
    procedure Stop; virtual;
    procedure PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass);
    function ExecuteRPC(const ARequest: string): string;
  end;

implementation

{ TTCPRPCProvider }

constructor TRPCProviderServer.Create(const AHost: string; const APort: integer);
begin
  FHost := AHost;
  FPort := APort;
  FRPCRouteHandle := TRPCRouteHandle.Create;
end;

destructor TRPCProviderServer.Destroy;
begin
  inherited;
end;

function TRPCProviderServer.ExecuteRPC(const ARequest: string): string;
begin
  Result := FRPCRouteHandle.ExecuteRPC(ARequest);
end;

procedure TRPCProviderServer.PublishRPC(const ARPCName: string;
  const ARPCClass: TRPCResourceClass);
begin
  FRPCRouteHandle.PublishRPC(ARPCName, ARPCClass);
end;

procedure TRPCProviderServer.Start;
begin

end;

procedure TRPCProviderServer.Stop;
begin

end;

end.
