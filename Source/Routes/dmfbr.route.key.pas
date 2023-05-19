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

unit dmfbr.route.key;

interface

uses
  SysUtils;

type
  TRouteKey = record
  public
    Path: string;
    Schema: string;
    constructor Create(const APath: string; const ASchema: string);
    function CopyWith(const APath: string; const ASchema: string): TRouteKey;
    function GetHashCode: integer;
    class operator Equal(const ALeft, ARight: TRouteKey): boolean;
    class operator NotEqual(const ALeft, ARight: TRouteKey): boolean;
  end;

implementation

{ TModularKey }

constructor TRouteKey.Create(const APath: string; const ASchema: string);
begin
  Schema := ASchema;
  Path := APath;
end;

function TRouteKey.CopyWith(const APath: string; const ASchema: string): TRouteKey;
begin
  Result.Schema := ASchema;
  Result.Path := APath;
end;

class operator TRouteKey.Equal(const ALeft, ARight: TRouteKey): boolean;
begin
  Result := (ALeft.Schema = ARight.Schema) and (ALeft.Path = ARight.Path);
end;

class operator TRouteKey.NotEqual(const ALeft, ARight: TRouteKey): boolean;
begin
  Result := not (ALeft = ARight);
end;

function TRouteKey.GetHashCode: integer;
begin
  Result := Schema.GetHashCode + Path.GetHashCode;
end;

end.

