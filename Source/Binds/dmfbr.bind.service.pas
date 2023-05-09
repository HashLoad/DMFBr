{
         DMFBr - Desenvolvimento Modular Framework for Delphi/Lazarus


                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
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
    function GetBind<T: class, constructor>: T;
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

function TBindService.GetBind<T>: T;
var
  LResult: TResultPair<T, string>;
begin
  LResult := FProvider.GetBind<T>;
  if LResult.isSuccess then
  begin
    if LResult.ValueSuccess = nil then
      raise TBindNotFound.CreateFmt('Class [%s] not found!', [T.ClassName]);
    Result := LResult.ValueSuccess;
  end
  else
  if LResult.isFailure then
    raise TBindError.Create(LResult.ValueFailure);
end;

procedure TBindService.IncludeBindProvider(const AProvider: TBindProvider);
begin
  FProvider := AProvider;
end;

end.





