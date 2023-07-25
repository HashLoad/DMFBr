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

unit dmfbr.rpc.interfaces;

interface

uses
  dmfbr.rpc.resource;

type
  IRPCProviderServer = interface
    ['{B6ABE323-4FD8-49DF-9D1F-208FF424A872}']
    procedure Start;
    procedure Stop;
    procedure PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass);
    function ExecuteRPC(const AContext: string): string;
  end;

  IRPCProviderClient = interface
    ['{53B122DB-B9DB-434F-A0DA-4A8EE44EA842}']
    function ExecuteRPC(const AContext: string): string;
  end;

  IRPCRouteHandle = interface
    ['{7C0BFB60-92F3-430B-A119-479A07F58EC4}']
    procedure PublishRPC(const ARPCName: string; const ARPCClass: TRPCResourceClass);
    function ExecuteRPC(const AContext: string): string;
  end;

implementation

end.
