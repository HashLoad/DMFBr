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

unit dmfbr.bind.service;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.bind.provider,
  dmfbr.injector;

type
  TBindService = class
  private
    FProvider: TBindProvider;
  public
    destructor Destroy; override;
    procedure IncludeBindProvider(const AProvider: TBindProvider);
    function GetBind<T: class, constructor>: TResultPair<Exception, T>;
  end;

implementation

uses
  dmfbr.exception;

{ TBindService }

destructor TBindService.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Free;
  inherited;
end;

function TBindService.GetBind<T>: TResultPair<Exception, T>;
begin
  try
    Result := FProvider.GetBind<T>;
    if Result.ValueSuccess = nil then
      Result.Failure(EBindNotFound.Create(''));
  except
    on E: Exception do
      Result.Failure(EBindError.Create(E.Message));
  end;
end;

procedure TBindService.IncludeBindProvider(const AProvider: TBindProvider);
begin
  FProvider := AProvider;
end;

end.





