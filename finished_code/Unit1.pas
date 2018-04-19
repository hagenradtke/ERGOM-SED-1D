unit Unit1;

{$MODE Delphi}

interface

type appType=record
  exeName: String;
end;

procedure disp(s: String);

var application: appType;

implementation

procedure disp(s: String);
begin
  Writeln(s);
end;

end.
