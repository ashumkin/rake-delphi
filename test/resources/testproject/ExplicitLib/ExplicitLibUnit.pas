unit ExplicitLibUnit;

interface

uses
  SysUtils;

function ExplicitLibUnitFunction: string;

implementation

function ExplicitLibUnitFunction: string;
begin
  Result := '-=WITH EXPLICIT LIBS=-';
end;

end.