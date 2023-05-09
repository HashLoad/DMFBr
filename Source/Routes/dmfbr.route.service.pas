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

unit dmfbr.route.service;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  dmfbr.route.provider,
  dmfbr.route.param,
  dmfbr.route.abstract,
  dmfbr.exception,
  result.pair;

type
  TRouteService = class
  private
    FProvider: TRouteProvider;
  public
    destructor Destroy; override;
    procedure IncludeProvider(const AProvider: TRouteProvider);
    procedure GetRoute(const AArgs: TRouteParam);
  end;

implementation

{ TRouteService }

destructor TRouteService.Destroy;
begin
  FProvider.Free;
  inherited;
end;

procedure TRouteService.GetRoute(const AArgs: TRouteParam);
var
  LResult: TResultPair<boolean, string>;
begin
  LResult := FProvider.GetRoute(AArgs);
  if (LResult.isSuccess) then
    Exit
  else
  if (LResult.isFailure) then
  begin
    if (LResult.ValueFailure = '404') then
      raise TRouteNotFound.CreateFmt('Modular route (%s) not found!', [AArgs.Path])
    else
    if (LResult.ValueFailure = '401') then
      raise TRouteGuardianAuthorized.CreateFmt('Access to route (%s) unauthorized.', [AArgs.Path])
    else
      raise Exception.Create(LResult.ValueFailure);
  end;
end;

procedure TRouteService.IncludeProvider(const AProvider: TRouteProvider);
begin
  FProvider := AProvider;
end;

end.



