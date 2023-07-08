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

unit dmfbr.route.abstract;

interface

uses
  Generics.Collections,
  SysUtils,
  dmfbr.request;

type
  TRouteAbstract = class;

  TRouteMiddleware = class
  public
    class function Before(ARoute: TRouteAbstract): TRouteAbstract; virtual;
    class function Call(const AReq: IRouteRequest): boolean; virtual;
    class procedure After(ARoute: TRouteAbstract); virtual;
  end;

  TMiddlewares = array of TClass;

  TRouteAbstract = class
  private
    FSchema: string;
    FPath: string;
    FParent: string;
    FModule: TClass;
    FModuleInstance: TObject;
    FRouteMiddlewares: TMiddlewares;
    procedure _SetSchema(const Value: string);
    procedure _SetPath(const Value: string);
    procedure _SetParent(const Value: string);
    procedure _SetModuleInstance(const Value: TObject);
  public
    constructor Create(const APath: string; const ASchema: string;
      const AModule: TClass; AMiddlewares: TMiddlewares); virtual;
    destructor Destroy; override;
    class function AddModule(const APath: string; const AModule: TClass;
      const AMiddlewares: TMiddlewares): TRouteAbstract; virtual; abstract;
    // Propertys
    property Schema: string read FSchema write _SetSchema;
    property Path: string read FPath write _SetPath;
    property Parent: string read FParent write _SetParent;
    property Module: TClass read FModule;
    property Middlewares: TMiddlewares read FRouteMiddlewares;
    property ModuleInstance: TObject read FModuleInstance write _SetModuleInstance;
  end;

implementation

{ TRoute }
constructor TRouteAbstract.Create(const APath: string; const ASchema: string;
  const AModule: TClass; AMiddlewares: TMiddlewares);
begin
  FPath := APath;
  FSchema := ASchema;
  FParent := ASchema;
  FModule := AModule;
  FRouteMiddlewares := AMiddlewares;
end;

destructor TRouteAbstract.Destroy;
begin
  if Assigned(FModuleInstance) then
    FModuleInstance.Free;
  inherited;
end;

procedure TRouteAbstract._SetModuleInstance(const Value: TObject);
begin
  FModuleInstance := Value;
end;

procedure TRouteAbstract._SetPath(const Value: string);
begin
  FPath := Value;
end;

procedure TRouteAbstract._SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TRouteAbstract._SetSchema(const Value: string);
begin
  FSchema := Value;
end;

{ TRouteMiddleware }

class procedure TRouteMiddleware.After(ARoute: TRouteAbstract);
begin

end;

class function TRouteMiddleware.Before(ARoute: TRouteAbstract): TRouteAbstract;
begin
  Result := ARoute;
end;

class function TRouteMiddleware.Call(const AReq: IRouteRequest): boolean;
begin
  Result := True;
end;

end.
