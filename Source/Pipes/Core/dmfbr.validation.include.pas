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
  @abstract(DMFBr Framework for Delphi)
  @created(01 Mai 2023)
  @author(Isaque Pinheiro <isaquesp@gmail.com>)
  @homepage(https://www.isaquepinheiro.com.br)
  @documentation(https://dmfbr-en.docs-br.com)
}

unit dmfbr.validation.include;

interface

uses
  Rtti,
  Generics.Collections,
  dmfbr.transform.pipe,
  dmfbr.transform.arguments,
  dmfbr.transform.interfaces,
  dmfbr.parse.json.pipe,
  dmfbr.parse.integer.pipe,
  dmfbr.validation.arguments,
  dmfbr.validator.constraint,
  dmfbr.validation.isstring,
  dmfbr.validation.isinteger,
  dmfbr.validation.isempty,
  dmfbr.validation.isnotempty,
  dmfbr.validation.isarray,
  dmfbr.validation.isobject,
  dmfbr.validation.isnumber,
  dmfbr.validation.isdate,
  dmfbr.validation.isboolean,
  dmfbr.validation.isenum,
  dmfbr.validation.interfaces;

type
  TResultValidation = dmfbr.validation.interfaces.TResultValidation;
  TResultTransform = dmfbr.transform.interfaces.TResultTransform;
  TJsonMapped = dmfbr.transform.interfaces.TJsonMapped;
  //
  TTransformPipe = dmfbr.transform.pipe.TTransformPipe;
  ITransformArguments = dmfbr.transform.interfaces.ITransformArguments;
  TTransformArguments = dmfbr.transform.arguments.TTransformArguments;
  //
  IValidationArguments = dmfbr.validation.interfaces.IValidationArguments;
  IValidatorConstraint = dmfbr.validation.interfaces.IValidatorConstraint;
  IValidationInfo = dmfbr.validation.interfaces.IValidationInfo;
  IValidationPipe = dmfbr.validation.interfaces.IValidationPipe;
  ITransformInfo = dmfbr.transform.interfaces.ITransformInfo;
  ITransformPipe = dmfbr.transform.interfaces.ITransformPipe;
  //
  TValidationArguments = dmfbr.validation.arguments.TValidationArguments;
  TValidatorConstraint = dmfbr.validator.constraint.TValidatorConstraint;
  //
  TParseJsonPipe = dmfbr.parse.json.pipe.TParseJsonPipe;
  TParseIntegerPipe = dmfbr.parse.integer.pipe.TParseIntegerPipe;
  //
  TIsEmpty = dmfbr.validation.isempty.TIsEmpty;
  TIsNotEmpty = dmfbr.validation.isnotempty.TIsNotEmpty;
  TIsString = dmfbr.validation.isstring.TIsString;
  TIsInteger = dmfbr.validation.isinteger.TIsInteger;
  TIsNumber = dmfbr.validation.isnumber.TIsNumber;
  TIsBoolean = dmfbr.validation.isboolean.TIsBoolean;
  TIsDate = dmfbr.validation.isdate.TIsDate;
  TIsEnum = dmfbr.validation.isenum.TIsEnum;
  TIsObject = dmfbr.validation.isobject.TIsObject;
  TIsArray = dmfbr.validation.isarray.TIsArray;

implementation

end.
