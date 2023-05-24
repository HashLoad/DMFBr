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

unit dmfbr.modular;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  StrUtils,
  Generics.Collections,
  dmfbr.module,
  dmfbr.route.parse,
  dmfbr.module.service,
  dmfbr.bind.service,
  dmfbr.injector,
  dmfbr.exception,
  result.pair,
  app.injector.service;

type
  TListener = TProc<string>;

  TModularBr = class sealed
  private
    FAppInjector: PAppInjector;
    FInitialRoutePath: string;
    FAppModule: TModule;
    FRouteParse: TRouteParse;
    FModuleService: TModuleService;
    FBindService: TBindService;
    FModuleStarted: boolean;
    FListener: TListener;
    procedure SetListener(const Value: TListener);
    procedure _ResolveDisposeRouteModule(const APath: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeModuleService(const AService: TModuleService);
    procedure IncludeBindService(const AService: TBindService);
    procedure IncludeRouteParser(const ARouteParse: TRouteParse);
    procedure Init(const AModule: TModule;
      const AInitialRoutePath: String = '/');
    procedure Finalize;
    function LoadRouteModule(const APath: string;
      const AArgs: TArray<TValue> = nil): TResultPair<Exception, TRouteAbstract>;
    procedure DisposeRouteModule(const APath: String);
    //
    function &Get<T: class, constructor>(AName: string = ''): T;
    function &GetInterface<I: IInterface>(AName: string = ''): I;
    //
    property Listener: TListener read FListener write SetListener;
  end;

function Modular: TModularBr;

implementation

{ TModularBr }
function Modular: TModularBr;
begin
  Result := AppInjector^.Get<TModularBr>;
end;

constructor TModularBr.Create;
begin
  FAppInjector := AppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  FModuleStarted := false;
end;

destructor TModularBr.Destroy;
begin
  if Assigned(FBindService) then
    FBindService.Free;
  if Assigned(FModuleService) then
    FModuleService.Free;
  if Assigned(FRouteParse) then
    FRouteParse.Free;
  if Assigned(FListener) then
    FListener := nil;
  FModuleStarted := false;
  inherited;
end;

function TModularBr.GetInterface<I>(AName: string = ''): I;
var
  LResult: TResultPair<Exception, I>;
begin
  LResult := FBindService.GetBindInterface<I>;
  LResult.TryException(
    procedure (AValue: Exception)
    begin
      raise AValue;
    end,
    procedure (AValue: I)
    begin

    end);
  Result := LResult.ValueSuccess;
end;

function TModularBr.Get<T>(AName: string): T;
var
  LResult: TResultPair<Exception, T>;
begin
  LResult := FBindService.GetBind<T>;
  LResult.TryException(
    procedure (AValue: Exception)
    begin
      raise AValue;
    end,
    procedure (AValue: T)
    begin

    end);
  Result := LResult.ValueSuccess;
end;

procedure TModularBr.IncludeBindService(const AService: TBindService);
begin
  FBindService := AService;
end;

procedure TModularBr.IncludeModuleService(const AService: TModuleService);
begin
  FModuleService := AService;
end;

procedure TModularBr.IncludeRouteParser(const ARouteParse: TRouteParse);
begin
  FRouteParse := ARouteParse;
end;

procedure TModularBr.Init(const AModule: TModule;
  const AInitialRoutePath: String);
begin
  if FModuleStarted then
    raise EModuleStartedException.CreateFmt('', [AModule.ClassName]);
  FInitialRoutePath := AInitialRoutePath;
  FAppModule := AModule;
  FModuleService.Start(AModule, AInitialRoutePath);
  FModuleStarted := true;
  DebugPrint(Format('%s started!', [AModule.ClassName]));
end;

function TModularBr.LoadRouteModule(const APath: string;
  const AArgs: TArray<TValue>): TResultPair<exception, TRouteAbstract>;
begin
  Result := FRouteParse.SelectRoute(APath, AArgs);
  if Assigned(FListener) then
    FListener(APath);
end;

procedure TModularBr.SetListener(const Value: TListener);
begin
  FListener := Value;
end;

procedure TModularBr.DisposeRouteModule(const APath: String);
begin
  _ResolveDisposeRouteModule(APath);
end;

procedure TModularBr.Finalize;
begin
  // Nessa ordem deve ser.
  FAppModule.Free;
  FAppInjector^.ExtractInjector<TAppInjector>('ModularBr');
end;


procedure TModularBr._ResolveDisposeRouteModule(const APath: string);
var
  LRoutes: TArray<string>;
  LRoute: string;
  LRouteParts: string;
begin
  LRouteParts := '';
  LRoutes := SplitString(APath, '/');
  for LRoute in LRoutes do
  begin
    if (LRoute = '') or (LRoute = '/') then
      Continue;
    LRouteParts := LRouteParts + '/' + LRoute;
    FModuleService.DisposeModule(LRouteParts);
  end;
end;

end.

