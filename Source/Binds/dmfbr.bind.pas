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
  dmfbr.bind.abstract;

type
  TBind<T: class, constructor> = class(TBindAbstract<T>)
  public
    constructor Create(const AOnFree: TFreeCallback;
      const AOnNotifier: TNotifierCallback);
    destructor Destroy; override;
    class function Singleton(const AOnFree: TFreeCallback = nil;
                             const AOnNotifier: TNotifierCallback = nil): TBind<TObject>;
    class function SingletonLazy(const AOnFree: TFreeCallback = nil;
                                 const AOnNotifier: TNotifierCallback = nil): TBind<TObject>;
    class function Factory(const AOnFree: TFreeCallback = nil;
                           const AOnNotifier: TNotifierCallback = nil): TBind<TObject>;
    class function SingletonInterface<I: IInterface>(const AOnFree: TFreeCallback = nil;
      const AOnNotifier: TNotifierCallback = nil): TBind<TObject>;
  end;

  TSingletonBind<T: class, constructor> = class(TBind<TObject>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TSingletonLazyBind<T: class, constructor> = class(TBind<TObject>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TFactoryBind<T: class, constructor> = class(TBind<TObject>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

  TSingletonInterfaceBind<I: IInterface; T: class, constructor> = class(TBind<TObject>)
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); override;
  end;

implementation

{ TBind<T> }

constructor TBind<T>.Create(const AOnFree: TFreeCallback;
  const AOnNotifier: TNotifierCallback);
begin
  FFreeCallback := AOnFree;
  FNotifierCallback := AOnNotifier;
end;

destructor TBind<T>.Destroy;
begin
  FFreeCallback := nil;
  FNotifierCallback := nil;
  inherited;
end;

class function TBind<T>.Factory(const AOnFree: TFreeCallback;
  const AOnNotifier: TNotifierCallback): TBind<TObject>;
begin
  Result := TFactoryBind<T>.Create(AOnFree, AOnNotifier);
end;

class function TBind<T>.Singleton(const AOnFree: TFreeCallback;
  const AOnNotifier: TNotifierCallback): TBind<TObject>;
begin
  Result := TSingletonBind<T>.Create(AOnFree, AOnNotifier);
end;

class function TBind<T>.SingletonInterface<I>(const AOnFree: TFreeCallback;
  const AOnNotifier: TNotifierCallback): TBind<TObject>;
begin
  Result := TSingletonInterfaceBind<I, T>.Create(AOnFree, AOnNotifier);
end;

class function TBind<T>.SingletonLazy(const AOnFree: TFreeCallback;
  const AOnNotifier: TNotifierCallback): TBind<TObject>;
begin
  Result := TSingletonLazyBind<T>.Create(AOnFree, AOnNotifier);
end;

{ TSingletonBind }

procedure TSingletonBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.Singleton<T>();
end;

{ TSingletonLazyBind<T> }

procedure TSingletonLazyBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.SingletonLazy<T>();
end;

{ TFactoryBind<T> }

procedure TFactoryBind<T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.Factory<T>();
end;

{ TSingletonInterfaceBind<T> }

procedure TSingletonInterfaceBind<I, T>.IncludeInjector(const AAppInjector: TAppInjector);
begin
  AAppInjector.SingletonInterface<I, T>();
end;

end.
