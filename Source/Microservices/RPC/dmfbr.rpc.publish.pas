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

unit dmfbr.rpc.publish;

interface

uses
  Generics.Collections,
  dmfbr.rpc.resource;

type
  TRPCPublish = class
  private
    FRegisteredRPCs: TDictionary<string, TRPCResourceClass>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass);
    procedure UnPublishRPC(const ARPCName: string);
    function RPCs: TDictionary<string, TRPCResourceClass>;
  end;

implementation

{ TRegisterRPC }

constructor TRPCPublish.Create;
begin
  FRegisteredRPCs := TDictionary<string, TRPCResourceClass>.Create;
end;

destructor TRPCPublish.Destroy;
begin
  FRegisteredRPCs.Free;
  inherited;
end;

procedure TRPCPublish.PublishRPC(const ARPCName: string;
  const ARPCClass: TRPCResourceClass);
begin
  FRegisteredRPCs.AddOrSetValue(ARPCName, ARPCClass);
end;

function TRPCPublish.RPCs: TDictionary<string, TRPCResourceClass>;
begin
  Result := FRegisteredRPCs;
end;

procedure TRPCPublish.UnPublishRPC(const ARPCName: string);
begin
  FRegisteredRPCs.Remove(ARPCName);
end;

end.

