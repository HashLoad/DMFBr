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

unit dmfbr.injector;

interface

uses
  Rtti,
  SysUtils,
  app.injector,
  app.injector.service,
  Generics.Collections;

type
  PAppInjector = ^TAppInjector;
  TAppInjector = class(TInjectorBr)
  public
    procedure CreateModularInjector;
    procedure ExtractInjector<T: class>(const ATag: string = '');
  end;

  TCoreInjector = class(TAppInjector)
  private
    procedure _TrackeInjector; // Singleton
    procedure _ObjectFactoryInjector; // SingletonLazy
    procedure _BindServiceInjector; // Factory
    procedure _RouteServiceInjector; // Factory
    procedure _ModuleServiceInjector; // Factory
    procedure _ModuleProviderInjector; // Factory
    procedure _BindProviderInjector; // Factory
    procedure _RouteProviderInjector; // Factory
    procedure _RouteParseInjector; // Factory
    procedure _ModularBrInjector; // SingletonLazy
  public
    constructor Create; override;
  end;

var
  AppInjector: PAppInjector = nil;

implementation

uses
  eclbr.objects,
  dmfbr.tracker,
  dmfbr.bind.provider,
  dmfbr.bind.service,
  dmfbr.module.provider,
  dmfbr.module.service,
  dmfbr.route.provider,
  dmfbr.route.parse,
  dmfbr.route.service,
  dmfbr.route.manager,
  dmfbr.modular,
  dmfbr.register;

{ TCoreInjector }

constructor TCoreInjector.Create;
begin
  inherited;
  // Datasource
  _TrackeInjector;
  _ObjectFactoryInjector;
  // Infra
  _BindServiceInjector;
  _RouteServiceInjector;
  _ModuleServiceInjector;
  // Domain
  _ModuleProviderInjector;
  _BindProviderInjector;
  _RouteProviderInjector;
  _RouteParseInjector;
  _ModularBrInjector;
end;

procedure TCoreInjector._BindProviderInjector;
begin
  Self.Factory<TBindProvider>(nil, nil,
    function: TConstructorParams
    begin
      Result := [TValue.From<TTracker>(Self.Get<TTracker>)];
    end);
end;

procedure TCoreInjector._BindServiceInjector;
begin
  Self.Factory<TBindService>(
    procedure(Value: TBindService)
    begin
      Value.IncludeBindProvider(Self.Get<TBindProvider>);
    end);
end;

procedure TCoreInjector._ModularBrInjector;
begin
  Self.SingletonLazy<TModularBr>(
    procedure(Value: TModularBr)
    begin
      Value.IncludeModuleService(Self.Get<TModuleService>);
      Value.IncludeBindService(Self.Get<TBindService>);
      Value.IncludeRouteParser(Self.Get<TRouteParse>);
    end);
end;

procedure TCoreInjector._ModuleProviderInjector;
begin
  Self.Factory<TModuleProvider>(
    procedure(Value: TModuleProvider)
    begin
      Value.IncludeTracker(Self.Get<TTracker>);
    end);
end;

procedure TCoreInjector._ModuleServiceInjector;
begin
  Self.Factory<TModuleService>(
    procedure(Value: TModuleService)
    begin
      Value.IncludeProvider(Self.Get<TModuleProvider>);
    end);
end;

procedure TCoreInjector._RouteParseInjector;
begin
  Self.Factory<TRouteParse>(
    procedure(Value: TRouteParse)
    begin
      Value.IncludeRouteService(Self.Get<TRouteService>);
    end);
end;

procedure TCoreInjector._RouteProviderInjector;
begin
  Self.Factory<TRouteProvider>(
    procedure(Value: TRouteProvider)
    begin
      Value.IncludeTracker(Self.Get<TTracker>);
    end);
end;

procedure TCoreInjector._RouteServiceInjector;
begin
  Self.Factory<TRouteService>(
    procedure(Value: TRouteService)
    begin
      Value.IncludeProvider(Self.Get<TRouteProvider>);
    end);
end;

procedure TCoreInjector._TrackeInjector;
begin
  Self.SingletonLazy<TTracker>;
  Self.SingletonLazy<TRouteManager>;
end;

procedure TCoreInjector._ObjectFactoryInjector;
begin
  Self.Singleton<TObjectFactory>;
end;

procedure TAppInjector.CreateModularInjector;
var
  LInjector: TCoreInjector;
  LRegister: TRegister;
begin
  LInjector := TCoreInjector.Create;
  AppInjector^.AddInjector('ModularBr', LInjector);

  LRegister := TRegister.Create;
  AppInjector^.AddInstance<TRegister>(LRegister);
end;

procedure TAppInjector.ExtractInjector<T>(const ATag: string);
var
  LKey: string;
begin
  LKey := ATag;
  if LKey = '' then
    LKey := T.ClassName;
  Self.Remove<T>(LKey);
end;

initialization
  New(AppInjector);
  AppInjector^ := TAppInjector.Create;
  AppInjector^.CreateModularInjector;

finalization
  if Assigned(AppInjector) then
  begin
    Modular.Finalize;
    AppInjector^.Free;
    Dispose(AppInjector);
  end;

end.
