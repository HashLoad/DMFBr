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
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.exception;

interface

uses
  Windows,
  Classes,
  StrUtils,
  SysUtils;

type
  EModularException = class;
  EBadRequestException = class;
  EUnauthorizedException = class;
  ERouteNotFoundException = class;
  EBindException = class;
  EBindNotFoundException = class;
  EModuleStartedException = class;
  EModuleStartedInitException = class;

  EModularException = class abstract (Exception)
  public
    Status: integer;
    constructor Create(const Msg: string); overload; virtual;
    constructor CreateFmt(const Msg: string; const Args: array of const); virtual;
  end;

  EBadRequestException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Internal server error';
    const cMSG_DEFAULT_ARGS = 'Internal server error (%s)';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  ERouteNotFoundException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Modular route not found';
    const cMSG_DEFAULT_ARGS = 'Modular route (%s) not found';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EBindException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Class error occurred';
    const cMSG_DEFAULT_ARGS = 'Class [%s] error occurred';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EUnauthorizedException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Access to route unauthorized';
    const cMSG_DEFAULT_ARGS = 'Access to route (%s) unauthorized';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EBindNotFoundException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Class not found';
    const cMSG_DEFAULT_ARGS = 'Class [%s] not found';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EModuleStartedException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Module is already started';
    const cMSG_DEFAULT_ARGS = 'Module [%s] is already started';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EModuleStartedInitException = class(EModularException)
  public
    const cMSG_DEFAULT = 'Execute "Modular.Init(TAppModule.Create)" this is just an example';
    const cMSG_DEFAULT_ARGS = 'Execute "Modular.Init(%s)" this is just an example';
    constructor Create(const Msg: string); overload; override;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EAppInjector = class(Exception)
  public
    constructor Create;
  end;

{$IFDEF DEBUG}
procedure DebugPrint(const AMessage: string);
{$ENDIF}

implementation

{$IFDEF DEBUG}
procedure DebugPrint(const AMessage: string);
begin
  TThread.Queue(nil,
          procedure
          begin
            OutputDebugstring(PWideChar('[DMFBr] - ' + FormatDateTime('mm/dd/yyyy, hh:mm:ss am/pm', Now) + ' LOG ' + AMessage));
          end);
end;
{$ENDIF}

{ ERouteNotFound }

constructor ERouteNotFoundException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "404", "message": %s, "error": "Not Found"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 404;
end;

constructor ERouteNotFoundException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ EBindError }

constructor EBindException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "500", "message": %s, "error": "Internal Server Error"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 500;
end;

constructor EBindException.CreateFmt(const Msg: string; const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ ERouteGuardianAuthorized }

constructor EUnauthorizedException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "401", "message": %s, "error": "Unauthorized"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 401;
end;

constructor EUnauthorizedException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ EBindNotFound }

constructor EBindNotFoundException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "404", "message": %s, "error": "Not Found"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 404;
end;

constructor EBindNotFoundException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ EModuleStartedException }

constructor EModuleStartedException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "500", "message": %s, "error": "Internal Server Error"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 500;
end;

constructor EModuleStartedException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ EModularError }

constructor EModularException.Create(const Msg: string);
begin
  inherited Create(Msg);
  Status := 0;
end;

constructor EModularException.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
  Status := 0;
end;

{ EModuleStartedInit }

constructor EModuleStartedInitException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "500", "message": %s, "error": "Internal Server Error"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 500;
end;

constructor EModuleStartedInitException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

{ EAppInjector }

constructor EAppInjector.Create;
begin
  inherited Create('The AppInjector pointer is not assigned.')
end;

{ EBadRequestException }

constructor EBadRequestException.Create(const Msg: string);
var
  LMsg: string;
begin
  LMsg := Format('{"statusCode": "400", "message": %s, "error": "Bad Request"}', [cMSG_DEFAULT]);
  inherited Create(ifThen(Msg = '', LMsg, Msg));
  Status := 400;
end;

constructor EBadRequestException.CreateFmt(const Msg: string;
  const Args: array of const);
var
  LMsg: string;
begin
  LMsg := ifThen(Msg = '', cMSG_DEFAULT_ARGS, Msg);
  Create(Format(LMsg, Args));
end;

end.
