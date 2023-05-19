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

unit dmfbr.module.provider;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.tracker,
  dmfbr.route.param,
  dmfbr.module.abstract,
  dmfbr.route.abstract;

type
  TModuleProvider = class
  private
    FTracker: TTracker;
  public
    destructor Destroy; override;
    procedure IncludeTracker(const ATracker: TTracker);
    function Start(const AModule: TModuleAbstract;
      const AInitialRoutePath: String): TResultPair<string, boolean>;
    function DisposeModule(const APath: String): TResultPair<string, boolean>;
    procedure AddRoutes(const AModule: TModuleAbstract);
    procedure BindModule(const AModule: TModuleAbstract);
    procedure RemoveRoutes(const AModuleName: string);
    procedure ExtractInjector<T: class>(const ATag: string);
  end;

implementation

procedure TModuleProvider.AddRoutes(const AModule: TModuleAbstract);
begin
  FTracker.AddRoutes(AModule);
end;

procedure TModuleProvider.BindModule(const AModule: TModuleAbstract);
begin
  FTracker.BindModule(AModule);
end;

destructor TModuleProvider.Destroy;
begin
  FTracker := nil;
  inherited;
end;

procedure TModuleProvider.IncludeTracker(
  const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

procedure TModuleProvider.RemoveRoutes(const AModuleName: string);
begin
  FTracker.RemoveRoutes(AModuleName);
end;

function TModuleProvider.Start(const AModule: TModuleAbstract;
  const AInitialRoutePath: String): TResultPair<string, boolean>;
begin
  try
    FTracker.RunApp(AModule, AInitialRoutePath);
    Result.Success(True);
  except on E: Exception do
    Result.Failure(E.Message);
  end;
end;

function TModuleProvider.DisposeModule(
  const APath: String): TResultPair<string, boolean>;
var
  LRoute: TRouteAbstract;
  LError: string;
begin
  try
    LRoute := FTracker.FindRoute(TRouteParam.Create(APath));
    if LRoute = nil then
    begin
      LError := Format('Modular Route (%s) not found!', [APath]);
      Result.Failure(LError);
      Exit;
    end;
    // Destroy o modulo e as rotas filhas dele
    FreeAndNil(LRoute.ModuleInstance);
    Result.Success(True);
  except on E: Exception do
    Result.Failure(E.Message);
  end;
end;

procedure TModuleProvider.ExtractInjector<T>(const ATag: string);
begin
  FTracker.ExtractInjector<T>(ATag);
end;

end.






