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

unit dmfbr.bind.abstract;

interface

uses
  SysUtils,
  dmfbr.injector,
  app.injector.events;

type
  TBindAbstract<T: class, constructor> = class
  protected
    FOnCreate: TProc<T>;
    FOnDestroy: TProc<T>;
    FOnParams: TConstructorCallback;
    FAddInstance: TObject;
  public
    destructor Destroy; override;
    procedure IncludeInjector(const AAppInjector: TAppInjector); virtual; abstract;
  end;

implementation

destructor TBindAbstract<T>.Destroy;
begin
  FOnCreate := nil;
  FOnDestroy := nil;
  FOnParams := nil;
  FAddInstance := nil;
  inherited;
end;

end.
