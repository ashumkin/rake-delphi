program TestProject;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  fmTest in 'fmTest.pas' {TestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
