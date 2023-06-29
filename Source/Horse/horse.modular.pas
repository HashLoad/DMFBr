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
  dmfbr.request,
  result.pair,
  Horse;

function HorseModular(const AppModule: TModule): THorseCallback; overload;
function HorseModular(const ACharset: string): THorseCallback; overload;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
function _ResolverRouteRequest(const Req: THorseRequest): IRouteRequest;

implementation

var
  Charset: string;

function HorseModular(const AppModule: TModule): THorseCallback;
begin
  Modular.Init(AppModule);
  Result := HorseModular('UTF-8');
end;

function HorseModular(const ACharset: string): THorseCallback;
begin
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
const
  CONTENT_TYPE = 'application/json; charset=UTF-8';
var
  LResult: TResultPair<Exception, TRouteAbstract>;
  LRequest: IRouteRequest;
begin
  // Tratamento para ignorar rotas de documentação swagger nesse middleware.
  if (Pos(LowerCase('swagger'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) or
     (Pos(LowerCase('favicon.ico'), LowerCase(Req.RawWebRequest.PathInfo)) > 0) then
    exit;
  // Inicia rota e binds
  if (Req.MethodType in [mtGet, mtPost, mtPut, mtPatch, mtDelete]) then
  begin
    LRequest := _ResolverRouteRequest(Req);
    LResult := Modular.LoadRouteModule(Req.RawWebRequest.PathInfo, LRequest);
    LResult.TryException(
      procedure (Error: Exception)
      begin
        if Error is EModularException then
        begin
          Res.Send(Error.Message).Status(EModularException(Error)
                                 .Status).ContentType(CONTENT_TYPE);
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
        // mas não precisamos de fazer nada com ela, o modular trata tudo.
      end);
  end;
  try
    try
      Next;
    except
      on E: EHorseCallbackInterrupted do
        raise;
      on E: EHorseException do
        Res.Send(Format('{ ' + sLineBreak +
                        '   "statusCode": %s,' + sLineBreak +
                        '   "message": "%s"' + sLineBreak +
                        '}', [IntToStr(E.Code), E.Message]))
           .Status(E.Status)
           .ContentType(CONTENT_TYPE);
      on E: Exception do
        Res.Send(Format('{ ' + sLineBreak +
                        '   "statusCode": "%s", ' + sLineBreak +
                        '   "scope": "%s", ' + sLineBreak +
                        '   "message": "%s"' + sLineBreak +
                        '}', ['400', E.UnitScope, E.Message]))
           .Status(THTTPStatus.BadRequest)
           .ContentType(CONTENT_TYPE);
    end;
  finally
    Modular.DisposeRouteModule(Req.RawWebRequest.PathInfo);
  end;
end;

function _ResolverRouteRequest(const Req: THorseRequest): IRouteRequest;
var
  LRequest: IRouteRequest;
begin
  Result := nil;
  try
    LRequest := TRouteRequest.Create;
    LRequest.SetHeader(Req.Headers['Authorization']);
    LRequest.SetBody(Req.Body);
    LRequest.SetParams(Req.Params.Content);
    LRequest.SetQuerys(Req.Query.Content);
    LRequest.SetHost(Req.RawWebRequest.Host);
    LRequest.SetContentType(Req.RawWebRequest.ContentType);
    LRequest.SetPathInfo(Req.RawWebRequest.PathInfo);
  except
    exit;
  end;
  Result := LRequest;
end;

end.
