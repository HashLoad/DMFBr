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
  Classes,
  SysUtils,
  StrUtils,
  dmfbr.exception,
  dmfbr.route.abstract,
  dmfbr.route.param,
  dmfbr.route.service,
  result.pair;

type
  TRouteParse = class
  private
    FService: TRouteService;
    procedure _ResolveRoutes(const APath: string;
      const ACallback: TProc<string>);
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeRouteService(const AService: TRouteService);
    function SelectRoute(const APath: string;
      const AArgs: TArray<TValue> = nil): TResultPair<Exception, TRouteAbstract>;
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

function TRouteParse.SelectRoute(const APath: string;
  const AArgs: TArray<TValue>): TResultPair<Exception, TRouteAbstract>;
var
  LArgs: TRouteParam;
  LPath: string;
  LRouteParse: string;
  LRouteResult: TResultPair<Exception, TRouteAbstract>;
begin
  LPath := LowerCase(APath);
  if LPath = '' then
  begin
    Result.Failure(ERouteNotFound.CreateFmt('', [APath]));
    Exit;
  end;
  LRouteParse := '';
  // Resolve routes
  _ResolveRoutes(APath,
                 procedure (ARoute: string)
                 begin
                   LRouteParse := LRouteParse + '/' + ARoute;
                   LArgs := TRouteParam.Create(LRouteParse, AArgs);
                   // Se "LRouteResult.isFailure", quer dizer que a rota enterior
                   // não foi encontrada, então a VAR Exception deve ser liberada
                   // para que somente a última rota do loop, atribua valor a
                   // "LRouteResult".
                   if LRouteResult.isFailure then
                     LRouteResult.DestroyFailure;
                   LRouteResult := FService.GetRoute(LArgs);
                 end);
  Result := LRouteResult;
end;

procedure TRouteParse._ResolveRoutes(const APath: string;
  const ACallback: TProc<string>);
var
  LRoutes: TArray<string>;
  LRoute: string;
begin
  LRoutes := SplitString(APath, '/');
  for LRoute in LRoutes do
  begin
    if LRoute = '' then
      Continue;
    ACallback(LRoute);
  end;
end;

end.

