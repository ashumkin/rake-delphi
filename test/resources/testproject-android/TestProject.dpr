program TestProject;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  Forms,
  SysUtils,
  {$IFDEF LIBS}
  LibUnit,
  {$ENDIF LIBS}
  {$IFDEF EXPLICIT_LIBS}
  ExplicitLibUnit,
  {$ENDIF}
  fmTest in 'fmTest.pas' {TestForm};

{$R *.res}

var
  s: string;
begin
  s := EmptyStr;
  {$IFDEF LIBS}
  s := s + LibUnit.LibUnitFunction;
  {$ENDIF LIBS}
  {$IFDEF EXPLICIT_LIBS}
  s := s + ExplicitLibUnit.ExplicitLibUnitFunction;
  {$ENDIF EXPLICIT_LIBS}
  Application.Initialize;
  Application.CreateForm(TTestForm, TestForm);
  TestForm.Caption := s;
  Application.Run;
end.
