program consolemodel;

{$MODE Delphi}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  cgt_1d_model,
  Unit1 in 'Unit1.pas';

procedure configure(startDate, endDate, repRuns, timestep, outInt: String);
begin
  FormatSettings.DecimalSeparator:='.';
  FormatSettings.ShortDateFormat:='dd.mm.yyyy';
  FormatSettings.DateSeparator:='.';
  cgt_1d_model.start_date         := StrToDate(startDate); // initial date
  cgt_1d_model.end_date           := StrToDate(endDate); // final date
  cgt_1d_model.repeated_runs      := StrToInt(repRuns);  // how often the same forcing period is repeated

  cgt_1d_model.timestep           := StrToFloat(timestep);              // timestep [days]
  cgt_1d_model.timestep_increment := 1.0;                 // increment the timestep at every timestep by a constant factor
//  cgt_1d_model.timestep           := 1.0e-6;              // timestep [days]
//  cgt_1d_model.timestep_increment := power(1.8,1);                 // increment the timestep at every timestep by a constant factor

  cgt_1d_model.output_interval    := StrToFloat(outInt); // output interval [days]
  cgt_1d_model.location.longitude := 20.0;                // longitude [deg], for zenith angle calculation
  cgt_1d_model.location.latitude  := 57.33;               // latitude  [deg], for zenith angle calculation
  cgt_1d_model.location.altitude  := 0.0;                 // altitude [m], for zenith angle calculation
  cgt_1d_model.density_water      := 1035.0;              // Density of water [kg/m3] to convert between mol/kg and mol/m3
  cgt_1d_model.num_vmove_steps    := 1;                   // if >1, this splits the vertical movement timestep (keep CFL criterion valid if tracers move very fast)
  cgt_1d_model.num_vdiff_steps    := 10;                  // if >1, this splits the vertical mixing (keep CFL criterion valid if tracers move very fast)
  cgt_1d_model.num_vdiff_steps_sed:= 1;                   // if >1, this splits the vertical mixing (keep CFL criterion valid if tracers move very fast)
  cgt_1d_model.min_diffusivity    := 1e-4;                // minimum vertical turbulent diffusivity [m2/s]
  cgt_1d_model.max_diffusivity    := 1;                   // maximum vertical turbulent diffusivity [m2/s]
end;

var
  F: TextFile;
  mypath: AnsiString;
  startDate, endDate, repRuns, timestep, outInt, rkdepth: String;
begin
  if ParamCount=0 then mypath:=ExtractFilePath(ParamStr(0)) else mypath:=paramStr(1);
  application.exeName:=mypath+'no.exe';
  if FileExists(mypath+'options_run.txt') then
  begin
    assignFile(F,mypath+'options_run.txt');
    reset(F);
    readln(F);
    readln(F);
    readln(F,startDate);
    readln(F);
    readln(F,endDate);
    readln(F);
    readln(F,repRuns);
    readln(F);
    readln(F,timestep);
    readln(F);
    readln(F,outInt);
    readln(F);
    readln(F,rkDepth);
    closefile(F);
  end
  else
  begin
    startDate:='01.01.1964';
    endDate:='01.01.1965';
    repRuns:='1';
    timestep:='0.05';
    outInt:='1';
    rkdepth:='1';
  end;
  configure(startDate, endDate, repRuns, timestep, outInt);
  run(StrToInt(RKDepth));

  { TODO -oUser -cConsole Main : Insert code here }
end.
