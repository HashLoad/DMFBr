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

unit dmfbr.route.parse;

interface

uses
  Rtti,
  Windows,
  Classes,
  SysUtils,
  dmfbr.exception,
  dmfbr.route.param,
  dmfbr.route.service;

type
  TRouteParse = class
  private
    FService: TRouteService;
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeRouteService(const AService: TRouteService);
    procedure SelectRoute(const APath: string;
      const AArgs: TArray<TValue> = nil);
  end;

implementation

{ TRouteParse }

constructor TRouteParse.Create;
begin

end;

destructor TRouteParse.Destroy;
begin
  FService.Free;
  inherited;
end;

procedure TRouteParse.IncludeRouteService(const AService: TRouteService);
begin
  FService := AService;
end;

procedure TRouteParse.SelectRoute(const APath: string;
  const AArgs: TArray<TValue>);
var
  LArgs: TRouteParam;
  LPath: string;
begin
  LPath := LowerCase(APath);
  if LPath = '' then
    raise TRouteNotFound.CreateFmt('Modular route (%s) not found!', [APath]);

  LArgs := TRouteParam.Create(LPath, AArgs);
  FService.GetRoute(LArgs);
end;

end.

