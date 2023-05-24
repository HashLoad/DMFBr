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
  TGuardMiddleware = reference to function(const AUserName: string;
                                           const APassword: string;
                                           const AToken: string;
                                           const APath: string): boolean;

function HorseModular(const AppModule: TModule;
                      const AGuardMiddleware: TGuardMiddleware = nil): THorseCallback; overload;
function HorseModular(const ACharset: string): THorseCallback; overload;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

var
  GuardMiddleware: TGuardMiddleware;
  Charset: string;

function HorseModular(const AppModule: TModule;
  const AGuardMiddleware: TGuardMiddleware): THorseCallback;
begin
  Modular.Init(AppModule);
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
  LAuthorization: string;
  LUserName: string;
  LPassword: string;
  LToken: string;
begin
  // Tratamento para ignorar rodas de documentação nesse middleware.
  if (Pos(LowerCase('swagger'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) or
     (Pos(LowerCase('favicon.ico'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) then
    Exit;
  // Inicia rota e binds
  if (Req.MethodType in [mtGet, mtPost, mtPut, mtPatch, mtDelete]) then
  begin
    // Guardião de rotas
    if Assigned(GuardMiddleware) then
    begin
      LAuthorization := Req.Headers['Authorization'];
      LUserName := Req.Params['username'];
      LPassword := Req.Params['password'];
      LToken := Req.Headers['Bearer'];
      { TODO -oIsaque -cParams-Token :
        preciso implementar o tratamento para todas essas informações e tentar deixar
        o mais generico possível. }
      if not GuardMiddleware(LUserName, LPassword, LToken, Req.RawWebRequest.PathInfo) then
        raise ERouteGuardianAuthorized.Create;
    end;
    LResult := Modular.LoadRouteModule(Req.RawWebRequest.PathInfo);
    LResult.TryException(
      procedure (Error: Exception)
      begin
        if Error is EModularError then
        begin
          Res.Send(Error.Message).Status(EModularError(Error).Status).ContentType(CONTENT_TYPE);
          Error.Free;
          raise EHorseCallbackInterrupted.Create;
        end
        else
        begin
          Res.Send(Error.Message).Status(500).ContentType(CONTENT_TYPE);
          Error.Free;
          raise EHorseCallbackInterrupted.Create;
        end;
      end,
      procedure (Route: TRouteAbstract)
      begin
        // A Rota se encontrada, veio até aqui,
        // mas não precisamos de fazer nada com nela, o modular trata tudo.
      end);
  end;
  try
    try
      Next;
    except
      on E: EHorseCallbackInterrupted do
        raise;

      on E: EHorseException do
        Res.Send(Format('{"error": "%s"}', [E.Message]))
           .Status(E.Status)
           .ContentType(CONTENT_TYPE);

      on E: Exception do
        Res.Send(Format('{"error": "%s", "description": "%s"}', [E.UnitScope, E.Message]))
           .Status(THTTPStatus.BadRequest)
           .ContentType(CONTENT_TYPE);
    end;
  finally
    Res.RawWebResponse.ContentType := CONTENT_TYPE;
    // Destroy modulos e sub-modulos usados na rotas.
    Modular.DisposeRouteModule(Req.RawWebRequest.PathInfo);
  end;
end;

end.
