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

unit dmfbr.route.param;

interface

uses
  SysUtils,
  Math,
  Rtti;

type
  TRouteParam = record
  private
    FPath: string;
    FSchema: string;
    FArguments: TArray<TValue>;
  public
    constructor Create(const APath: string;
      const AArguments: TArray<TValue> = nil;
      const ASchema: string = '');
    procedure ResolveURL;
    property Path: string read FPath;
    property Schema: string read FSchema;
    property Arguments: TArray<TValue> read FArguments;
  end;

implementation

constructor TRouteParam.Create(const APath: string;
  const AArguments: TArray<TValue>;
  const ASchema: string);
begin
  FPath := APath;
  FSchema := ASchema;
  FArguments := AArguments;
end;

procedure TRouteParam.ResolveURL;
begin
  FPath := FPath + '/';
end;

end.
