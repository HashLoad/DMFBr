{
             DMFBr - Development Modular Framework for Delphi


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
  Rtti,
  dmfbr.request;

type
  TRouteParam = record
  private
    FPath: string;
    FSchema: string;
    FRequest: IRouteRequest;
  public
    constructor Create(const APath: string;
      const AReq: IRouteRequest = nil; const ASchema: string = '');
    procedure ResolveURL;
    property Path: string read FPath;
    property Schema: string read FSchema;
    property Request: IRouteRequest read Frequest;
  end;

implementation

constructor TRouteParam.Create(const APath: string;
  const AReq: IRouteRequest; const ASchema: string);
begin
  FPath := APath;
  FSchema := ASchema;
  FRequest := AReq;
end;

procedure TRouteParam.ResolveURL;
begin
  FPath := FPath + '/';
end;

end.
