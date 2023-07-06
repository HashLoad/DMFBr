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
  result.pair,
  dmfbr.injector,
  dmfbr.exception,
  dmfbr.route.abstract,
  dmfbr.route.param,
  dmfbr.route.service,
  dmfbr.route.manager,
  dmfbr.request;

type
  TReturnPair = TResultPair<Exception, TRouteAbstract>;
  TListener = TProc<string>;

  TRouteParse = class
  private
    FService: TRouteService;
    FRouteManager: TRouteManager;
    FListener: TListener;
    procedure _ResolveRoutes(const APath: string;
      const ACallback: TFunc<string, TReturnPair>);
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeRouteService(const AService: TRouteService);
    function SelectRoute(const APath: string;
      const AReq: IRouteRequest = nil; const AListener: TListener = nil): TReturnPair;
  end;

implementation

{ TRouteParse }

constructor TRouteParse.Create;
begin
  FRouteManager := AppInjector^.Get<TRouteManager>;
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
  const AReq: IRouteRequest; const AListener: TListener): TReturnPair;
var
  LArgs: TRouteParam;
  LPath: string;
  LRouteParts: string;
  LRouteResult: TReturnPair;
begin
  FListener := AListener;
  LPath := LowerCase(APath);
  if LPath = '' then
  begin
    Result.Failure(ERouteNotFoundException.CreateFmt('', [APath]));
    Exit;
  end;
  if FRouteManager.FindEndPoint(LPath) <> '' then
  begin
    LArgs := TRouteParam.Create(LPath, AReq);
    LRouteResult := FService.GetRoute(LArgs);
  end
  else
  begin
    LRouteParts := '';
    // Resolve routes
    _ResolveRoutes(APath,
                   function (Route: string): TReturnPair
                   begin
                     LRouteParts := LRouteParts + '/' + Route;
                     LArgs := TRouteParam.Create(LRouteParts, AReq);
                     if Assigned(FListener) then
                       FListener(LRouteParts);
                     // Se "LRouteResult.isFailure", quer dizer que a rota enterior
                     // não foi encontrada, então a VAR Exception deve ser liberada
                     // para que somente a última rota do loop, atribua valor a
                     // "LRouteResult".
                     if LRouteResult.isFailure then
                       LRouteResult.DestroyFailure;
                     LRouteResult := FService.GetRoute(LArgs);
                     Result := LRouteResult;
                   end);
  end;
  FListener := nil;
  Result := LRouteResult;
end;

procedure TRouteParse._ResolveRoutes(const APath: string;
  const ACallback: TFunc<string, TReturnPair>);
var
  LRoutes: TArray<string>;
  LRoute: string;
  LResult: TReturnPair;
begin
  LRoutes := SplitString(APath, '/');
  for LRoute in LRoutes do
  begin
    if (LRoute = '') or (LRoute = '/') then
      Continue;
    if LRoute = LRoutes[High(LRoutes)] then
      Break;
    LResult := ACallback(LRoute);
  end;
end;

end.

