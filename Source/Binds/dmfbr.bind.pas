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

unit dmfbr.bind;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  dmfbr.injector,
  dmfbr.bind.abstract,
  app.injector.events;

type
  TBind<T: class, constructor> = class(TBindAbstract<T>)
  public
    constructor Create(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback); overload;
    class function Singleton(const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil): TBind<TObject>;
    class function SingletonLazy(const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil): TBind<TObject>;
    class function Factory(const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil): TBind<TObject>;
    class function SingletonInterface<I: IInterface>(const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil): TBind<TObject>;
    class function AddInstance(const AInstance: TObject): TBind<TObject>;
  end;

  TSingletonBind<T: class, constructor> = class(TBind<T>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TSingletonLazyBind<T: class, constructor> = class(TBind<T>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TFactoryBind<T: class, constructor> = class(TBind<T>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TSingletonInterfaceBind<I: IInterface; T: class, constructor> = class(TBind<T>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TAddInstanceBind<T: class, constructor> = class(TBind<T>)
  public
    constructor Create(const AInstance: TObject); overload;
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

implementation

{ TBind<T> }

constructor TBind<T>.Create(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback);
begin
  FOnCreate := AOnCreate;
  FOnDestroy := AOnDestroy;
  FOnParams := AOnConstructorParams;
end;

class function TBind<T>.Factory(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback): TBind<TObject>;
begin
  Result := TBind<TObject>(TFactoryBind<T>.Create(AOnCreate,
                                                  AOnDestroy,
                                                  AOnConstructorParams));
end;

class function TBind<T>.Singleton(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback): TBind<TObject>;
begin
  Result := TBind<TObject>(TSingletonBind<T>.Create(AOnCreate,
                                                    AOnDestroy,
                                                    AOnConstructorParams));
end;

class function TBind<T>.SingletonInterface<I>(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback): TBind<TObject>;
begin
  Result := TBind<TObject>(TSingletonInterfaceBind<I, T>.Create(AOnCreate,
                                                                AOnDestroy,
                                                                AOnConstructorParams));
end;

class function TBind<T>.SingletonLazy(const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback): TBind<TObject>;
begin
  Result := TBind<TObject>(TSingletonLazyBind<T>.Create(AOnCreate,
                                                        AOnDestroy,
                                                        AOnConstructorParams));
end;

class function TBind<T>.AddInstance(const AInstance: TObject): TBind<TObject>;
begin
  Result := TBind<TObject>(TAddInstanceBind<T>.Create(AInstance));
end;

{ TSingletonBind }

procedure TSingletonBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.Singleton<T>(FOnCreate, FOnDestroy, FOnParams);
end;

{ TSingletonLazyBind<T> }

procedure TSingletonLazyBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.SingletonLazy<T>(FOnCreate, FOnDestroy, FOnParams);
end;

{ TFactoryBind<T> }

procedure TFactoryBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.Factory<T>(FOnCreate, FOnDestroy, FOnParams);
end;

{ TSingletonInterfaceBind<T> }

procedure TSingletonInterfaceBind<I, T>.IncludeInjector(
  const AAppInjector: TAppInjector);
begin
  AAppInjector.SingletonInterface<I, T>('', FOnCreate, FOnDestroy, FOnParams);
end;

{ TInstanceBind<I, T> }

constructor TAddInstanceBind<T>.Create(const AInstance: TObject);
begin
  FAddInstance := Ainstance;
end;

procedure TAddInstanceBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.AddInstance<T>(FAddInstance);
end;

end.
