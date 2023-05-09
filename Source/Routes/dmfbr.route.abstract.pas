{
         DMFBr - Desenvolvimento Modular Framework for Delphi/Lazarus


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

unit dmfbr.route.abstract;

interface

uses
  Generics.Collections,
  SysUtils;

type
  TRouteAbstract = class;
  TRouteGuardCallback = TFunc<Boolean>;
  TBeforeCallback = TFunc<TRouteAbstract, TRouteAbstract>;
  TAfterCallback = TProc<TRouteAbstract>;

  TRouteMiddleware = record
  public
    BeforeCallback: TBeforeCallback;
    AfterCallback: TAfterCallback;
    constructor Create(const ABeforeCallback: TBeforeCallback;
                       const AAfterCallback: TAfterCallback);
  end;

  TMiddlewares = array of TRouteMiddleware;

  TRouteAbstract = class
  private
    FSchema: string;
    FPath: string;
    FParent: string;
    FModule: TClass;
    FModuleInstance: TObject;
    FRouteGurdCallback: TRouteGuardCallback;
    FRouteMiddlewares: TMiddlewares;
    procedure _SetSchema(const Value: string);
    procedure _SetPath(const Value: string);
    procedure _SetParent(const Value: string);
    procedure _SetModuleInstance(const Value: TObject);
  public
    constructor Create(const APath: string;
      const ASchema: string;
      const AModule: TClass;
      const ARouteGuardCallback: TRouteGuardCallback;
      const AMiddlewares: TMiddlewares); virtual;
    destructor Destroy; override;
    class function AddModule(const APath: string;
      const AModule: TClass;
      const ARouteGuardCallback: TRouteGuardCallback;
      const AMiddlewares: TMiddlewares): TRouteAbstract; virtual; abstract;
    // Propertys
    property Schema: string read FSchema write _SetSchema;
    property Path: string read FPath write _SetPath;
    property Parent: string read FParent write _SetParent;
    property Module: TClass read FModule;
    property RouteGuard: TRouteGuardCallback read FRouteGurdCallback;
    property Middlewares: TMiddlewares read FRouteMiddlewares;
    property ModuleInstance: TObject read FModuleInstance write _SetModuleInstance;
  end;

implementation

{ TRoute }

constructor TRouteAbstract.Create(const APath: string;
  const ASchema: string;
  const AModule: TClass;
  const ARouteGuardCallback: TRouteGuardCallback;
  const AMiddlewares: TMiddlewares);
begin
  FPath := APath;
  FSchema := ASchema;
  FParent := ASchema;
  FModule := AModule;
  FRouteGurdCallback := ARouteGuardCallback;
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

{ TRouteMiddleware<T> }

constructor TRouteMiddleware.Create(const ABeforeCallback: TBeforeCallback;
  const AAfterCallback: TAfterCallback);
begin
  BeforeCallback := ABeforeCallback;
  AfterCallback := AAfterCallback;
end;

end.
