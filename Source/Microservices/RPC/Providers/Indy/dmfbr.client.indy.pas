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

unit dmfbr.client.indy;

interface

uses
  SysUtils,
  Classes,
  IdTCPClient,
  dmfbr.rpc.client;

type
  TIdCustomTCPClientHacker = class(IdTCPClient.TIdTCPClientCustom);

  TRPCProviderClientIndy = class(TRPCProviderClient)
  private
    FTCPClient: TIdTCPClientCustom;
  public
    constructor Create(const AHost: string; const APort: integer = 8080); override;
    destructor Destroy; override;
    function ExecuteRPC(const ARequest: string): string; override;
  end;

implementation

{ TRPCProviderClientIndy }

constructor TRPCProviderClientIndy.Create(const AHost: string; const APort: integer);
begin
  inherited Create(AHost, APort);
  FTCPClient := TIdTCPClientCustom.Create(nil);
  TIdCustomTCPClientHacker(FTCPClient).Host := AHost;
  TIdCustomTCPClientHacker(FTCPClient).Port := APort;
end;

destructor TRPCProviderClientIndy.Destroy;
begin
  FTCPClient.Free;
  inherited;
end;

function TRPCProviderClientIndy.ExecuteRPC(const ARequest: string): string;
begin
  try
    FTCPClient.Connect;
    FTCPClient.IOHandler.WriteLn(ARequest);
    Result := FTCPClient.IOHandler.ReadLn;
  finally
    FTCPClient.Disconnect;
  end;
end;

end.
