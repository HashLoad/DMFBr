{
         DMFBr - Desenvolvimento Modular Framework for Delphi/Lazarus


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
  @abstract(DMFBr Framework)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @author(Site : https://www.isaquepinheiro.com.br)
}

unit dmfbr.exception;

interface

uses
  Windows,
  Classes,
  SysUtils;

type
  TRouteNotFound = class(Exception);
  TBindError = class(Exception);
  TRouteGuardianAuthorized = class(Exception);
  TBindNotFound = class(Exception);
  TModuleStartedException = class(Exception);
  TModularError = class(Exception);

function ModularError(const AMessage: string): TModularError;
procedure DebugPrint(const AMessage: string);

implementation

procedure DebugPrint(const AMessage: string);
begin
  TThread.Queue(nil,
          procedure
          begin
            OutputDebugstring(PWideChar(AMessage));
          end);
end;

function ModularError(const AMessage: string): TModularError;
begin
  Result := TModularError.Create(AMessage);
end;

end.




