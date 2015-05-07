program testproject;

uses
  Classes, SysUtils, Types
  {$IFDEF LIBS}
  , LibUnit
  {$ENDIF LIBS}
  {$IFDEF INDY}
  , IdURI
  {$ENDIF INDY}
  {$IFDEF EXPLICIT_LIBS}
  , ExplicitLibUnit
  {$ENDIF}
  ;

{$APPTYPE CONSOLE}

{$R *.res}
{$IFDEF RESOURCES}
{$R 'resources.res' 'resources.rc'}
{$ENDIF RESOURCES}
{$IFDEF RESOURCES_EXT}
{$R 'extended_resources.dres'}
{$ENDIF RESOURCES_EXT}
{$IFDEF ASSIGNABLE_CONSTS}
const
  TEST_CONST: string = '-=ASSIGNED CONST=-';
{$ENDIF ASSIGNABLE_CONSTS}
function GetResource(const pResourceName: string): string;
var
  res: TResourceStream;
  str: TStringStream;
begin
  Result := EmptyStr;
  try
    res := TResourceStream.Create(HInstance, pResourceName, RT_RCDATA);
    try
      str := TStringStream.Create(EmptyStr);
      try
        res.SaveToStream(str);
        Result := str.DataString;
      finally
        FreeAndNil(str);
      end;
    finally
      FreeAndNil(res);
    end;
  except
    Result := EmptyStr;
  end;
end;

var
  s: string;
begin
  {$IFDEF DEBUG}
  Write('DEBUG: ');
  {$ENDIF}
  {$IFOPT D+}
  Write('D+: ');
  {$ENDIF}
  s := GetResource('LOCAL_RESOURCES');
  s := s + GetResource('LOCAL_RESOURCES_EXT');
  {$IFDEF LIBS}
  s := s + LibUnit.LibUnitFunction;
  {$ENDIF LIBS}
  {$IFDEF EXPLICIT_LIBS}
  s := s + ExplicitLibUnit.ExplicitLibUnitFunction;
  {$ENDIF EXPLICIT_LIBS}
  {$IFDEF ASSIGNABLE_CONSTS}
  s := s + TEST_CONST;
  {$ENDIF ASSIGNABLE_CONSTS}
  {$IFDEF RELEASE_CFG}
  s := s + '-=RELEASE=-';
  {$ENDIF RELEASE_CFG}
  {$IFDEF CONFIG}
  s := s + '-=CONFIG=-';
  {$ENDIF CONFIG}
  {$IFDEF INDY}
  with TIdURI.Create('http://indy/path') do
    try
      s := s + Format('-=%s#%s=-', [Host, Document]);
    finally
      Free;
    end;
  {$ENDIF}
  WriteLn('testproject works', s);
end.
