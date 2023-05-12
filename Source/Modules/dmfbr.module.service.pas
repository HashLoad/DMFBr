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

unit dmfbr.module.service;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.route.abstract,
  dmfbr.module.abstract,
  dmfbr.module.provider;

type
  TModuleService = class
  private
    FProvider: TModuleProvider;
  public
    destructor Destroy; override;
    procedure IncludeProvider(const AProvider: TModuleProvider);
    procedure Start(const AModule: TModuleAbstract;
      const AInitialRoutePath: String);
    procedure DisposeModule(const APath: string);
    procedure AddRoutes(const AModule: TModuleAbstract);
    procedure BindModule(const AModule: TModuleAbstract);
    procedure RemoveRoutes(const AModuleName: string);
    procedure ExtractInjector<T: class>(const ATag: string);
  end;

implementation

{ TModuleService }

procedure TModuleService.DisposeModule(
  const APath: string);
var
  LResult: TResultPair<string, boolean>;
begin
  LResult := FProvider.DisposeModule(APath);
end;

procedure TModuleService.ExtractInjector<T>(const ATag: string);
begin
  FProvider.ExtractInjector<T>(ATag);
end;

procedure TModuleService.AddRoutes(const AModule: TModuleAbstract);
begin
  FProvider.AddRoutes(AModule);
end;

procedure TModuleService.BindModule(const AModule: TModuleAbstract);
begin
  FProvider.BindModule(AModule);
end;

destructor TModuleService.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Free;
  inherited;
end;

procedure TModuleService.IncludeProvider(const AProvider: TModuleProvider);
begin
  FProvider := AProvider;
end;

procedure TModuleService.RemoveRoutes(const AModuleName: string);
begin
  FProvider.RemoveRoutes(AModuleName);
end;

procedure TModuleService.Start(const AModule: TModuleAbstract;
  const AInitialRoutePath: String);
var
  LResult: TResultPair<string, boolean>;
begin
  LResult := FProvider.Start(AModule, AInitialRoutePath);
end;

end.
