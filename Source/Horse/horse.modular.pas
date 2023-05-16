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

unit horse.modular;

interface

uses
  SysUtils,
  Web.HTTPApp,
  dmfbr.module,
  dmfbr.modular,
  dmfbr.exception,
  result.pair,
  Horse;

type
  TRouteGuardCallback = reference to function(const AUserName: string;
                                              const APassword: string;
                                              const AToken: string;
                                              const APath: string): boolean;

function HorseModular(const AppModule: TModule;
                      const ARouteGuardCallback: TRouteGuardCallback = nil): THorseCallback; overload;
function HorseModular(const ACharset: string): THorseCallback; overload;
function Modular: TModularBr;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

var
  RouteGuardCallback: TRouteGuardCallback;
  Charset: string;

function Modular: TModularBr; overload;
begin
  Result := ModularApp;
end;

function HorseModular(const AppModule: TModule;
  const ARouteGuardCallback: TRouteGuardCallback): THorseCallback;
begin
  ModularApp.Init(AppModule);
  RouteGuardCallback := ARouteGuardCallback;
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
  // Inicia rota e binds
  if (Req.MethodType in [mtGet, mtPost, mtPut, mtPatch, mtDelete]) then
  begin
    // Guardião de rotas
    if Assigned(RouteGuardCallback) then
    begin
      LUserName := Req.Params['username'];
      LPassword := Req.Params['password'];
      LToken := Req.Headers['authorization'];
      if not RouteGuardCallback(LUserName, LPassword, LToken, Req.RawWebRequest.PathInfo) then
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
        // A Rota se encontrada, veio até aqui,
        // mas não precisamos de fazer nada com nela.
      end);
  end;
  try
    Next;
  finally
    Res.RawWebResponse.ContentType := CONTENT_TYPE;
    ModularApp.DisposeRouteModule(Req.RawWebRequest.PathInfo);
  end;
end;

end.
