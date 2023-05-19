{
         DMFBr - Desenvolvimento Modular Framework for Delphi


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
    function GetRoute(const AArgs: TRouteParam): TResultPair<Exception, TRouteAbstract>;
  end;

implementation

{ TRouteService }

destructor TRouteService.Destroy;
begin
  FProvider.Free;
  inherited;
end;

function TRouteService.GetRoute(const AArgs: TRouteParam): TResultPair<Exception, TRouteAbstract>;
begin
  try
    Result := FProvider.GetRoute(AArgs);
    if Result.ValueSuccess = nil then
      Result.Failure(ERouteNotFound.CreateFmt('', [AArgs.Path]));
  except
    on E: ERouteGuardianAuthorized do
      Result.Failure(ERouteGuardianAuthorized.Create);
    on E: Exception do
      Result.Failure(Exception.Create(E.Message));
  end;
end;

procedure TRouteService.IncludeProvider(const AProvider: TRouteProvider);
begin
  FProvider := AProvider;
end;

end.



