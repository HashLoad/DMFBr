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
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.parse.time.pipe;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  Generics.Collections,
  dmfbr.transform.pipe,
  dmfbr.transform.interfaces;


type
  TParseTimePipe = class(TTransformPipe)
  public
    function Transform(const Value: TValue;
      const Metadata: ITransformArguments): TResultTransform; override;
  end;

implementation

function TParseTimePipe.Transform(const Value: TValue;
  const Metadata: ITransformArguments): TResultTransform;
var
  LValue: TDateTime;
  LMessage: string;
begin
  if TryStrToTime(Value.ToString, LValue) then
    Result.Success(LValue)
  else
  begin
    LMessage := ifThen(Metadata.Message = '',
                       Format('[%s] %s-> [%s] Validation failed (time string is expected)', [Metadata.TagName,
                                                                                             Self.ClassName,
                                                                                             Metadata.FieldName]), Metadata.Message);
    Result.Failure(LMessage);
  end;
end;

end.
