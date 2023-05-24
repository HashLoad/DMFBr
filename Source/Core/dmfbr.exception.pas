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

unit dmfbr.exception;

interface

uses
  Windows,
  Classes,
  SysUtils;

type
  EAppInjector = class(Exception)
  public
    constructor Create;
  end;

  EModularError = class abstract (Exception)
  public
    Status: integer;
    constructor Create(const Msg: string); overload; virtual;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); virtual;
  end;

  ERouteNotFound = class(EModularError)
  public
    const cMSG_DEFAULT = 'Modular route not found.';
    const cMSG_DEFAULT_ARGS = 'Modular route (%s) not found.';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EBindError = class(EModularError)
  public
    const cMSG_DEFAULT = 'Class error occurred.';
    const cMSG_DEFAULT_ARGS = 'Class [%s] error occurred.';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  ERouteGuardianAuthorized = class(EModularError)
  public
    const cMSG_DEFAULT = 'Access to route unauthorized.';
    const cMSG_DEFAULT_ARGS = 'Access to route (%s) unauthorized.';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EBindNotFound = class(EModularError)
  public
    const cMSG_DEFAULT = 'Class not found!';
    const cMSG_DEFAULT_ARGS = 'Class [%s] not found!';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EModuleStartedException = class(EModularError)
  public
    const cMSG_DEFAULT = 'Module is already started';
    const cMSG_DEFAULT_ARGS = 'Module [%s] is already started';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

  EModuleStartedInit = class(EModularError)
  public
    const cMSG_DEFAULT = 'Execute "Modular.Init(TAppModule.Create)" this is just an example';
    const cMSG_DEFAULT_ARGS = 'Execute "Modular.Init(%s)" this is just an example';
    constructor Create(const Msg: string); overload; override;
    constructor Create; overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); override;
  end;

procedure DebugPrint(const AMessage: string);

implementation

procedure DebugPrint(const AMessage: string);
begin
  TThread.Queue(nil,
          procedure
          begin
            OutputDebugstring(PWideChar(AMessage));
          end);
end;

{ ERouteNotFound }

constructor ERouteNotFound.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 404;
end;

constructor ERouteNotFound.Create;
begin
  Create('');
end;

constructor ERouteNotFound.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 404;
end;

{ EBindError }

constructor EBindError.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 500;
end;

constructor EBindError.Create;
begin
  Create('');
end;

constructor EBindError.CreateFmt(const Msg: string; const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 500;
end;

{ ERouteGuardianAuthorized }

constructor ERouteGuardianAuthorized.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 401;
end;

constructor ERouteGuardianAuthorized.Create;
begin
  Create('');
end;

constructor ERouteGuardianAuthorized.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 401;
end;

{ EBindNotFound }

constructor EBindNotFound.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 404;
end;

constructor EBindNotFound.Create;
begin
  Create('');
end;

constructor EBindNotFound.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 404;
end;

{ EModuleStartedException }

constructor EModuleStartedException.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 500;
end;

constructor EModuleStartedException.Create;
begin
  Create('');
end;

constructor EModuleStartedException.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 500;
end;

{ EModularError }

constructor EModularError.Create(const Msg: string);
begin
  inherited Create(Msg);
  Status := 0;
end;

constructor EModularError.Create;
begin
  Create('');
end;

constructor EModularError.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
  Status := 0;
end;

{ EModuleStartedInit }

constructor EModuleStartedInit.Create(const Msg: string);
begin
  if Msg = '' then
    inherited Create(cMSG_DEFAULT)
  else
    inherited;
  Status := 500;
end;

constructor EModuleStartedInit.Create;
begin
  Create('');
end;

constructor EModuleStartedInit.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  if Msg = '' then
    inherited CreateFmt(cMSG_DEFAULT_ARGS, Args)
  else
    inherited;
  Status := 500;
end;

{ EAppInjector }

constructor EAppInjector.Create;
begin
  inherited Create('The AppInjector pointer is not assigned.')
end;

end.
