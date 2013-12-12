unit LibUnit;

interface

uses
  SysUtils;

function LibUnitFunction: string;

implementation

function LibUnitFunction: string;
begin
  Result := '-=WITH LIBS=-';
end;

end.