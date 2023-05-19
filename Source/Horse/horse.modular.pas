{
         DMFBr - Desenvolvimento Modular Framework for Delphi


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

unit horse.modular;

interface

uses
  SysUtils,
  StrUtils,
  Web.HTTPApp,
  dmfbr.module,
  dmfbr.modular,
  dmfbr.exception,
  result.pair,
  Horse;

type
  TRouteMiddleware = reference to function(const AUserName: string;
                                              const APassword: string;
                                              const AToken: string;
                                              const APath: string): boolean;

function HorseModular(const AppModule: TModule;
                      const AGuardMiddleware: TRouteMiddleware = nil): THorseCallback; overload;
function HorseModular(const ACharset: string): THorseCallback; overload;
function Modular: TModularBr;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

var
  GuardMiddleware: TRouteMiddleware;
  Charset: string;

function Modular: TModularBr; overload;
begin
  Result := ModularApp;
end;

function HorseModular(const AppModule: TModule;
  const AGuardMiddleware: TRouteMiddleware): THorseCallback;
begin
  ModularApp.Init(AppModule);
  GuardMiddleware := AGuardMiddleware;
  Result := HorseModular('UTF-8');
end;

function HorseModular(const ACharset: string): THorseCallback;
begin
  Charset := ACharset;
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
const
  CONTENT_TYPE = 'application/json; charset=UTF-8';
var
  LResult: TResultPair<Exception, TRouteAbstract>;
  LUserName: string;
  LPassword: string;
  LToken: string;
begin
  // Tratamento para ignorar rodas de documenta��o nesse middleware.
  if (Pos(LowerCase('swagger'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) or
     (Pos(LowerCase('favicon.ico'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) then
    Exit;
  // Inicia rota e binds
  if (Req.MethodType in [mtGet, mtPost, mtPut, mtPatch, mtDelete]) then
  begin
    // Guardi�o de rotas
    if Assigned(GuardMiddleware) then
    begin
      LUserName := Req.Params['username'];
      LPassword := Req.Params['password'];
      LToken := Req.Headers['authorization'];
      if not GuardMiddleware(LUserName, LPassword, LToken, Req.RawWebRequest.PathInfo) then
        raise ERouteGuardianAuthorized.Create;
    end;
    LResult := ModularApp.LoadRouteModule(Req.RawWebRequest.PathInfo);
    LResult.TryException(
      procedure (AValue: Exception)
      begin
        if AValue is EModularError then
        begin
          Res.Send(AValue.Message).ContentType(CONTENT_TYPE).Status(EModularError(AValue).Status);
          AValue.Free;
          raise EHorseCallbackInterrupted.Create;
        end
        else
        begin
          Res.Send(AValue.Message).ContentType(CONTENT_TYPE).Status(500);
          AValue.Free;
          raise EHorseCallbackInterrupted.Create;
        end;
      end,
      procedure (AValue: TRouteAbstract)
      begin
        // A Rota se encontrada, veio at� aqui,
        // mas n�o precisamos de fazer nada com nela.
      end);
  end;
  try
    Next;
  finally
    Res.RawWebResponse.ContentType := CONTENT_TYPE;
    // Destroy modulos e sub-modulos usados na rotas.
    Modular.DisposeRouteModule(Req.RawWebRequest.PathInfo);
  end;
end;

end.
