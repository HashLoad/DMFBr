{
         DMFBr - Desenvolvimento Modular Framework for Delphi


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

unit dmfbr.bind.provider;

interface

uses
  SysUtils,
  result.pair,
  dmfbr.tracker;

type
  TBindProvider = class
  private
    FTracker: TTracker;
  public
    constructor Create(const ATracker: TTracker);
    destructor Destroy; override;
    function GetBind<T: class, constructor>(const ATag: string): TResultPair<Exception, T>;
    function GetBindInterface<I: IInterface>(const ATag: string): TResultPair<Exception, I>;
//    procedure IncludeTracker(const ATracker: TTracker);
  end;

implementation

constructor TBindProvider.Create(const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

destructor TBindProvider.Destroy;
begin
  FTracker := nil;
  inherited;
end;

//procedure TBindProvider.IncludeTracker(
//  const ATracker: TTracker);
//begin
//  FTracker := ATracker;
//end;

function TBindProvider.GetBindInterface<I>(const ATag: string): TResultPair<Exception, I>;
begin
  Result.Success(FTracker.GetBindInterface<I>(ATag));
end;

function TBindProvider.GetBind<T>(const ATag: string): TResultPair<Exception, T>;
begin
  Result.Success(FTracker.GetBind<T>(ATag));
end;

end.

