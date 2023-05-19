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

unit dmfbr.module.abstract;

interface

uses
  Generics.Collections,
  dmfbr.route,
  dmfbr.route.handler,
  dmfbr.bind;

type
  TRoutes = array of TRoute;
  TBinds = array of TBind<TObject>;
  TImports = array of TClass;
  TExportedBinds = array of TBind<TObject>;
  TRouteHandlers = array of TClass;

  TModuleAbstract = class
  public
    constructor Create; virtual; abstract;
    function Routes: TRoutes; virtual; abstract;
    function Binds: TBinds; virtual; abstract;
    function Imports: TImports; virtual; abstract;
    function ExportedBinds: TExportedBinds; virtual; abstract;
    function RouteHandlers: TRouteHandlers; virtual; abstract;
  end;

implementation

end.
