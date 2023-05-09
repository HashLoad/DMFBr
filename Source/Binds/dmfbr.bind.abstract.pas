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

unit dmfbr.bind.abstract;

interface

uses
  SysUtils,
  dmfbr.injector;

type
  TFreeCallback = TProc<TObject>;
  TNotifierCallback = TFunc<TObject>;

  TBindAbstract<T: class, constructor> = class
  protected
    FFreeCallback: TFreeCallback;
    FNotifierCallback: TNotifierCallback;
  public
    procedure IncludeInjector(const AAppInjector: TAppInjector); virtual; abstract;
  end;

implementation

end.
