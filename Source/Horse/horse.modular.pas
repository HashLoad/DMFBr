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

function HorseModular(const AppModule: TModule): THorseCallback; overload;
function HorseModular(const ACharset: string): THorseCallback; overload;
function Modular: TModularBr;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

var
  Charset: string;

function Modular: TModularBr; overload;
begin
  Result := ModularApp;
end;

function HorseModular(const AppModule: TModule): THorseCallback;
begin
  ModularApp.Init(AppModule);
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
begin
  // Inicia rota e binds
  if (Req.MethodType in [mtGet, mtPost, mtPut, mtPatch, mtDelete]) then
  begin
    try
      ModularApp.LoadRouteModule(Req.RawWebRequest.PathInfo);
    except
      on E: ERouteNotFound do
      begin
        Res.Send(E.Message).ContentType(CONTENT_TYPE).Status(404);
        raise EHorseCallbackInterrupted.Create;
      end;
      on E: ERouteGuardianAuthorized do
      begin
        Res.Send(E.Message).ContentType(CONTENT_TYPE).Status(401);
        raise EHorseCallbackInterrupted.Create;
      end;
      on E: Exception do
      begin
        Res.Send(E.Message).ContentType(CONTENT_TYPE).Status(500);
        raise EHorseCallbackInterrupted.Create;
      end;
    end;
  end;
  try
    Next;
  finally
    Res.RawWebResponse.ContentType := CONTENT_TYPE;
    // Libera rotas e binds
    ModularApp.DisposeRouteModule(Req.RawWebRequest.PathInfo);
  end;
end;

end.
