unit cgt_1d_model;
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  //----------------------------------------------
  // PASCAL 1-d model for testing ecosystem models
  // hagen.radtke@io-warnemuende.de
  //----------------------------------------------

interface

uses NetCDFAnsi, math, SysUtils, DateUtils, sun_pos, matinv, ap;

var
  time_axis: DoubleArray1d;
  max_output_index: Integer;
  current_date: Real;

  depths:          DoubleArray1d;
  cellheights:     DoubleArray1d;
  kmax:            Integer;
  depths_sed:      DoubleArray1d;
  cellheights_sed: DoubleArray1d;
  kmax_sed:        Integer;

  output_temperature   : DoubleArray2d;
  output_salinity      : DoubleArray2d;
  output_opacity       : DoubleArray2d;
  output_light         : DoubleArray2d;
  output_diffusivity   : DoubleArray2d;
  output_light_at_top  : DoubleArray1d;
  output_zenith_angle  : DoubleArray1d;
  output_bottom_stress : DoubleArray1d;

  output_sed_diffusivity_porewater: DoubleArray2d;
  output_sed_diffusivity_solids:    DoubleArray2d;
  output_sed_inert_ratio:           DoubleArray2d;
  output_sed_inert_deposition:      DoubleArray1d;
  output_sed_grain_size:      DoubleArray1d;

  forcing_vector_temperature: DoubleArray1d;
  forcing_vector_salinity: DoubleArray1d;
  forcing_vector_opacity_water: DoubleArray1d;
  forcing_vector_opacity_bio: DoubleArray1d;
  forcing_vector_opacity: DoubleArray1d;
  forcing_vector_diffusivity: DoubleArray1d;
  forcing_vector_light: DoubleArray1d;
  forcing_scalar_light_at_top: Double;
  forcing_scalar_bottom_stress: Double;
  forcing_scalar_zenith_angle: Double;

  forcing_vector_sed_diffusivity_porewater: DoubleArray1d;
  forcing_vector_sed_diffusivity_solids:    DoubleArray1d;
  forcing_vector_sed_diffusivity_basic:    DoubleArray1d;
  forcing_scalar_sed_diffusivity_porewater: Double;
  forcing_scalar_sed_diffusivity_solids:    Double;
  forcing_vector_sed_inert_ratio:           DoubleArray1d;
  forcing_scalar_sed_inert_deposition:      Double;
  forcing_scalar_sed_grain_size:      Double;

  output_vector_temperature: DoubleArray1d;
  output_vector_salinity: DoubleArray1d;
  output_vector_opacity: DoubleArray1d;
  output_vector_light: DoubleArray1d;
  output_vector_diffusivity: DoubleArray1d;
  output_scalar_light_at_top  :Double;
  output_scalar_zenith_angle  :Double;
  output_scalar_bottom_stress :Double;

  output_vector_sed_diffusivity_porewater: DoubleArray1d;
  output_vector_sed_diffusivity_solids:    DoubleArray1d;
  output_vector_sed_inert_ratio:           DoubleArray1d;
  output_scalar_sed_inert_deposition:      Double;
  output_scalar_sed_grain_size:      Double;


  start_date         :Real; // initial date
  end_date           :Real; // final date
  repeated_runs      :Integer;                   // how often the same forcing period is repeated
  timestep           :Real;              // timestep [days]
  timestep_increment :Real;             // increment the timestep at every timestep by a constant factor
  output_interval    :Real;             // output interval [days]
  location: TLocation; //longitude, latitude, altitude
  density_water      :Real;              // Density of water [kg/m3] to convert between mol/kg and mol/m3
  num_vmove_steps    :Integer;                   // if >1, this splits the vertical movement timestep (keep CFL criterion valid if tracers move very fast)
  num_vdiff_steps    :Integer;                  // if >1, this splits the vertical mixing (keep CFL criterion valid if tracers move very fast)
  num_vdiff_steps_sed:Integer;                  // if >1, this splits the vertical mixing (keep CFL criterion valid if tracers move very fast)
  min_diffusivity    :Real;                // minimum vertical turbulent diffusivity [m2/s]
  max_diffusivity    :Real;                   // maximum vertical turbulent diffusivity [m2/s]

  current_output_date: Real;
  current_output_index: Integer;

  forcing_matrix_temperature,  forcing_matrix_salinity,
  forcing_matrix_light_at_top,  forcing_matrix_bottom_stress,   forcing_matrix_opacity_water,  forcing_matrix_diffusivity: DoubleArray2d;
  forcing_matrix_sed_diffusivity_porewater: DoubleArray2d;
  
  forcing_matrix_sed_diffusivity_solids: DoubleArray2d;
  
  forcing_matrix_sed_inert_deposition: DoubleArray2d;
  forcing_matrix_sed_grain_size: DoubleArray2d;

  forcing_index_temperature: Integer;
  forcing_index_salinity: Integer;
  forcing_index_light_at_top: Integer;
  forcing_index_bottom_stress: Integer;
  forcing_index_opacity_water: Integer;
  forcing_index_diffusivity: Integer;
  forcing_index_sed_diffusivity_porewater: Integer;
  
  forcing_index_sed_diffusivity_solids: Integer;
  
  forcing_index_sed_inert_deposition: Integer;
  forcing_index_sed_grain_size: Integer;

<constants dependsOn=xyzt>
  forcing_matrix_<name>: DoubleArray2d; // <description>
  forcing_matrix_sed_<name>: DoubleArray2d;
  forcing_index_<name>: Integer;
  forcing_index_sed_<name>: Integer;

</constants>

  output_count: Integer;

  sun_posi: tSunPosition;
  zenith_angle_under_water, light_path_length: Double;

  myviscosity: Real;
  sed_basicdiff_mol, sed_basicdiff_porewater, sed_basicdiff_solids: Double;
  // basic diffusivity which, if applied for 1 second, moves 1% of the material away from the nearest cell [m2]  

  sed_basicdiff_mol_lhs, sed_basicdiff_porewater_lhs, sed_basicdiff_solids_lhs: DoubleArray2d; //left-hand side for diffusion matrix calculation
  sed_basicdiff_mol_rhs, sed_basicdiff_porewater_rhs, sed_basicdiff_solids_rhs: DoubleArray2d; //right-hand side for diffusion matrix calculation
  sed_basicdiff_mol_eig, sed_basicdiff_porewater_eig, sed_basicdiff_solids_eig: DoubleArray1d; //eigenvalues for diffusion matrix calculation
  sed_diffmat_mol_lhs, sed_diffmat_porewater_lhs, sed_diffmat_solids_lhs: DoubleArray2d; //left-hand side for diffusion matrix calculation
  sed_diffmat_mol_rhs, sed_diffmat_porewater_rhs, sed_diffmat_solids_rhs: DoubleArray2d; //right-hand side for diffusion matrix calculation
  sed_diffmat_mol_eig, sed_diffmat_porewater_eig, sed_diffmat_solids_eig: DoubleArray1d; //eigenvalues for diffusion matrix calculation

  inverse_diffmat_oxygen, actual_diffmat_oxygen: DoubleArray2d;
  consumption_rate_of_oxygen, concentration_vector_of_oxygen: DoubleArray1d;


procedure run(RungeKuttaDepth: Integer=1);

implementation

uses Unit1, pow_trid;

const
  fluffy_layer_thickness = 0.003;
  diffusive_layer_thickness = 0.003; // see Boudreau: Diagenetic models and their implementation, page 180

  <constants variation=0; dependsOn=none>
    <name> = <value>; // <description>
  </constants>

var
  <constants variation=1>
    <name>: Double; // <description>
  </constants>
  <constants dependsOn/=none>
    constant_vector_<name>: DoubleArray1d; // <description>
    constant_vector_sed_<name>: DoubleArray1d;
  </constants>
  <tracers vertLoc=WAT>
    tracer_vector_<name> : DoubleArray1d;
    tracer_vector_intermediate_<name> : DoubleArray1d;
    patankar_modification_<name> : DoubleArray1d;
  </tracers>
  <celements isAging/=0>
    old_vector_<aged> : DoubleArray1d;
    old_vector_sed_<aged> : DoubleArray1d;
  </celements>
  <tracers vertLoc/=WAT>
    tracer_scalar_<name> : Double;
    tracer_scalar_intermediate_<name> : Double;
    patankar_modification_<name> : Double;
  </tracers>
  <tracers vertLoc=WAT; vertSpeed/=0>
    vertical_speed_of_<name> : DoubleArray1d;
    vertical_diffusivity_of_<name> : DoubleArray1d;
  </tracers>
  <tracers vertLoc=WAT; molDiff/=0>
    molecular_diffusivity_of_<name> : DoubleArray1d;
  </tracers>

  <tracers vertLoc=WAT; isInPorewater=1>
    tracer_vector_sed_<name> : DoubleArray1d;
    tracer_vector_intermediate_sed_<name> : DoubleArray1d;
    patankar_modification_sed_<name> : DoubleArray1d;
  </tracers>
  <tracers vertLoc/=WAT>
    tracer_vector_sed_<name> : DoubleArray1d;
    tracer_vector_intermediate_sed_<name> : DoubleArray1d;
    patankar_modification_sed_<name> : DoubleArray1d;
  </tracers>

  <auxiliaries vertLoc=WAT; isUsedElsewhere=1>
    auxiliary_vector_<name>: DoubleArray1d;
  </auxiliaries>
  <auxiliaries vertLoc/=WAT; isUsedElsewhere=1>
    auxiliary_scalar_<name>: Double;
  </auxiliaries>

  <auxiliaries vertLoc=WAT; isUsedElsewhere=1>
    auxiliary_vector_sed_<name>: DoubleArray1d;
  </auxiliaries>
  <auxiliaries vertLoc/=WAT; isUsedElsewhere=1>
    auxiliary_vector_sed_<name>: DoubleArray1d;
  </auxiliaries>

    
  <auxiliaries vertLoc=WAT; isOutput=1>
    output_<name> : DoubleArray2d;
    output_vector_<name> : DoubleArray1d;
  </auxiliaries>
  <auxiliaries vertLoc/=WAT; isOutput=1>
    output_<name> : DoubleArray1d;
    output_scalar_<name> : Double;
  </auxiliaries>
  <tracers vertLoc=WAT; isOutput=1>
    output_<name> : DoubleArray2d;
    output_vector_<name> : DoubleArray1d;
  </tracers>
  <tracers vertLoc/=WAT; isOutput=1>
    output_<name> : DoubleArray1d;
    output_scalar_<name> : Double;
  </tracers>
  <processes vertLoc=WAT; isOutput=1>
    output_<name> : DoubleArray2d;
    output_vector_<name> : DoubleArray1d;
  </processes>
  <processes vertLoc=WAT>
    saved_rate_<name> : DoubleArray1d;
  </processes>
  <processes vertLoc/=WAT; isOutput=1>
    output_<name> : DoubleArray1d;
    output_scalar_<name> : Double;
  </processes>
  <processes vertLoc/=WAT>
    saved_rate_<name> : Double;
  </processes>

  <auxiliaries vertLoc=WAT; isOutput=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </auxiliaries>
  <auxiliaries vertLoc=SED; isOutput=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </auxiliaries>
  <tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </tracers>
  <tracers vertLoc/=WAT; isOutput=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </tracers>
  <processes vertLoc=WAT; isOutput=1; isInPorewater=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </processes>
  <processes vertLoc=WAT; isInPorewater=1>
    saved_rate_sed_<name> : DoubleArray1d;
  </processes>
  <processes vertLoc=SED; isOutput=1; isInPorewater=1>
    output_sed_<name> : DoubleArray2d;
    output_vector_sed_<name> : DoubleArray1d;
  </processes>
  <processes vertLoc=SED; isInPorewater=1>
    saved_rate_sed_<name> : DoubleArray1d;
  </processes>

  ivlev_lookup_table: Array[0..100] of Double;
  dz, dzr, dzrq, dztr: DoubleArray1d;
  dz_sed, dzr_sed, dzrq_sed, dztr_sed: DoubleArray1d;

//------------------------------------------------------------
// FIRST PART
// not modified by code generation tool
//------------------------------------------------------------

procedure fill_ivlev_lookup_table;
var 
  i: Integer;
begin
  for i:=0 to length(ivlev_lookup_table)-1 do
    ivlev_lookup_table[i]:=1-exp(-0.1*i);
end;

function quick_ivlev(x: Double):Double;
var
  i_low: Integer;
  deltax: Double;
begin
  if x<0 then result:=0
  else if x>10 then result:=1
  else
  begin
    i_low:=trunc(10*x);
    deltax:=10*x-i_low;
    result:=deltax*ivlev_lookup_table[i_low+1]+(1-deltax)*ivlev_lookup_table[i_low];
  end;
end;

procedure fill_dz_arrays;
var i: Integer;
begin
  setLength(dz,kmax-1);
  setLength(dzr,kmax-1);
  setLength(dzrq,kmax-1);
  setLength(dztr,kmax);
  for i:=0 to kmax-2 do
  begin
    dz[i] := 0.5*(cellheights[i]+cellheights[i+1]);
    dzr[i] := 1.0/dz[i];
    dzrq[i]:=dzr[i]*dzr[i];
    dztr[i]:=1.0/cellheights[i];
  end;
  dztr[kmax-1]:=1.0/cellheights[kmax-1];
end;

procedure fill_dz_arrays_sed;
var i: Integer;
begin
  setLength(dz_sed,kmax_sed);
  setLength(dzr_sed,kmax_sed);
  setLength(dzrq_sed,kmax_sed);
  setLength(dztr_sed,kmax_sed+1);
  dz_sed[0]:=cellheights_sed[0];
  dzr_sed[0] := 1.0/dz_sed[0];
  dzrq_sed[0]:=dzr_sed[0]*dzr_sed[0];
  dztr_sed[0]:=1.0/cellheights[kmax-1];
  for i:=1 to kmax_sed-1 do
  begin
    dz_sed[i] := 0.5*(cellheights_sed[i-1]+cellheights_sed[i]);
    dzr_sed[i] := 1.0/dz_sed[i];
    dzrq_sed[i]:=dzr_sed[i]*dzr_sed[i];
    dztr_sed[i]:=1.0/cellheights_sed[i-1];
  end;
  dztr_sed[kmax_sed]:=1.0/cellheights_sed[kmax_sed-1];
end;

function log(x: Double):Double;
begin
  result:=ln(x);
end;

function theta(x: Double):Double;
begin
  if x>0 then result:=1 else result:=0;
end;

function SpaceItem(var s: String):String;
begin
  s:=trim(s);
  if pos(' ',s)>0 then
  begin
    result:=trim(copy(s,1,pos(' ',s)-1));
    s:=trim(copy(s,pos(' ',s)+1,length(s)));
  end
  else
  begin
    result:=s;
    s:='';
  end;
end;

procedure loadMatlabMatrix(filename: String; var a:Double); overload;
var
  F: TextFile;
  s: String;
  buf: Array[1..256*256] of Byte;
begin
  decimalSeparator:='.';
  assignFile(F,filename);
  SetTextBuf(F,buf);
  reset(F);
  while not EOF(F) do
  begin
    readln(F,s);
    s:=trim(s);
    if copy(s,1,1)='%' then continue;
    if length(s)=0 then continue;
    a:=StrToFloat(SpaceItem(s));
    break;
  end;
  closefile(F);
end;

procedure loadMatlabMatrix(filename: String; var a:DoubleArray1d); overload;
var
  F: TextFile;
  s: String;
  i: Integer;
  buf: Array[1..256*256] of Byte;
begin
  setLength(a,0);
  decimalSeparator:='.';
  assignFile(F,filename);
  SetTextBuf(F,buf);
  reset(F);
  i:=0;
  while not EOF(F) do
  begin
    readln(F,s);
    s:=trim(s);
    if copy(s,1,1)='%' then continue;
    if length(s)=0 then continue;
    while length(s)>0 do
    begin
      if length(a)<i+1 then
        setLength(a,i+1);
      a[i]:=StrToFloat(SpaceItem(s));
      i:=i+1;
      s:=trim(s);
    end;
  end;
  closefile(F);
end;

procedure loadMatlabMatrix(filename: String; var a:DoubleArray2d); overload;
var
  F: TextFile;
  s: String;
  i, j: Integer;
  buf: Array[1..256*256] of Byte;
begin
  setLength(a,0,0);
  decimalSeparator:='.';
  assignFile(F,filename);
  SetTextBuf(F,buf);  reset(F);
  i:=0;
  while not EOF(F) do
  begin
    if length(a)<i+1 then
    begin
      setLength(a,i+1);
      setLength(a[i],length(a[0]));
    end;
    readln(F,s);
    s:=trim(s);
    if copy(s,1,1)='%' then continue;
    if length(s)=0 then continue;
    j:=0;
    while length(s)>0 do
    begin
      if length(a[0])<j+1 then
        setLength(a,i+1,j+1);
      a[i,j]:=StrToFloat(SpaceItem(s));
      j:=j+1;
      s:=trim(s);
    end;
    i:=i+1;
  end;
  closefile(F);
end;

procedure load_forcing( input_matrix: DoubleArray2d; orig_date, start_date, end_date: Double; kmax: Integer; var i_to_load: Integer; var final_vector: DoubleArray1d); overload;
var
  date, newdate1, newdate2: Double;
  i, k: Integer;
  yy,y,m,d,hh,mm,ss,ms: Word;
begin
  // if the same forcing is repeated several times, find the correct date
  // within the forcing period
  date:=orig_date;
//  while date >= end_date do
//      date := date - (end_date-start_date);

  if date >= end_date then
  begin
    DecodeDateTime(start_date,yy,m,d,hh,mm,ss,ms);
    DecodeDateTime(date,y,m,d,hh,mm,ss,ms);
    date:=EncodeDateTime(yy,m,d,hh,mm,ss,ms);
  end;
  // seek the index to load
  // check if current index is still valid
  i:=i_to_load;
  newdate1:=EncodeDateTime(round(input_matrix[i-1,0]),round(input_matrix[i-1,1]),round(input_matrix[i-1,2]),0,0,0,0)+input_matrix[i-1,3]/24.0;
  if i<length(input_matrix) then
    newdate2:=EncodeDateTime(round(input_matrix[i,0]),round(input_matrix[i,1]),round(input_matrix[i,2]),0,0,0,0)+input_matrix[i,3]/24.0
  else
    newdate2:=date;
  if (newdate1<date) and (newdate2>=date) then
      //everything is fine, the current vector is good
      i_to_load:=i
  else
  begin
      if (newdate1 > date) then //some time loop has finished and the date moved backwards behind the loaded date
          i:=1;
      while (i<length(input_matrix)) do
      begin
          newdate2:=EncodeDateTime(round(input_matrix[i,0]),round(input_matrix[i,1]),round(input_matrix[i,2]),0,0,0,0)+input_matrix[i,3]/24.0;
          if newdate2<date then
              i:=i+1
          else
          begin
              i_to_load:=i;
              i:=length(input_matrix)+1000;
          end;
      end;
      if i<=length(input_matrix)+1 then //found no good i in the middle => use the last one
          i_to_load:=length(input_matrix);
  end;
  // load the forcing
  for k:=0 to length(final_vector)-1 do
    final_vector[k]:=input_matrix[i_to_load-1,k+4];
end;

procedure load_forcing( input_matrix: DoubleArray2d; orig_date, start_date, end_date: Double; kmax: Integer; var i_to_load: Integer; var final_scalar: Double); overload;
var
  date, newdate1, newdate2: Double;
  i: Integer;
  yy,y,m,d,hh,mm,ss,ms: Word;
begin
  // if the same forcing is repeated several times, find the correct date
  // within the forcing period
  date:=orig_date;
//  while date >= end_date do
//      date := date - (end_date-start_date);

  if date >= end_date then
  begin
    DecodeDateTime(start_date,yy,m,d,hh,mm,ss,ms);
    DecodeDateTime(date,y,m,d,hh,mm,ss,ms);
    date:=EncodeDateTime(yy,m,d,hh,mm,ss,ms);
  end;
  // seek the index to load
  // check if current index is still valid
  i:=i_to_load;
  newdate1:=EncodeDateTime(round(input_matrix[i-1,0]),round(input_matrix[i-1,1]),round(input_matrix[i-1,2]),0,0,0,0)+input_matrix[i-1,3]/24.0;
  if i<length(input_matrix) then
    newdate2:=EncodeDateTime(round(input_matrix[i,0]),round(input_matrix[i,1]),round(input_matrix[i,2]),0,0,0,0)+input_matrix[i,3]/24.0
  else
    newdate2:=date;
  if (newdate1<date) and (newdate2>=date) then
      //everything is fine, the current vector is good
      i_to_load:=i
  else
  begin
      if (newdate1 > date) then //some time loop has finished and the date moved backwards behind the loaded date
          i:=1;
      while (i<length(input_matrix)) do
      begin
          newdate2:=EncodeDateTime(round(input_matrix[i,0]),round(input_matrix[i,1]),round(input_matrix[i,2]),0,0,0,0)+input_matrix[i,3]/24.0;
          if newdate2<date then
              i:=i+1
          else
          begin
              i_to_load:=i;
              i:=length(input_matrix)+1000;
          end;
      end;
      if i<=length(input_matrix)+1 then //found no good i in the middle => use the last one
          i_to_load:=length(input_matrix);
  end;
  // load the forcing
  final_scalar:=input_matrix[i_to_load-1,4];
end;

procedure vmove_explicit( const move: DoubleArray1d; var field: DoubleArray1d; const flux_field: DoubleArray1d; const numerator: DoubleArray1d; numFactor: Double; const denominator, dzt: DoubleArray1d; dt: Double);
var
  k: Integer;
  ft1, ft2, velocity, wpos, wneg: Double;
begin
    ft1  := 0.0;                    // upward transport through upper boundary of the cell [mol*m/kg/s]
    for k := 1 to kmax-1 do
    begin
        velocity := 0.5*move[k-1];
        wpos     := velocity + abs(velocity);                   // velocity if upward, else 0.0   [m/s]
        wneg     := velocity - abs(velocity);                   // velocity if downward, else 0.0 [m/s]
        if numerator[k-1] = denominator[k-1] then
           ft2 := (wneg*max(flux_field[k-1],0.0)+wpos*max(flux_field[k],0.0) )   
                                                               // upward transport through lower boundary of the t cell [mol*m/kg/s]
        else
           ft2 := (wneg*max(flux_field[k-1],0.0)*max(numerator[k-1]*numFactor,0.0)/max(denominator[k-1],1e-20) 
                 +wpos*max(flux_field[k],0.0)*max(numerator[k]*numFactor,0.0)/max(denominator[k],1e-20) );  
                                                               // upward transport through lower boundary of the t cell [mol*m/kg/s]
        field[k-1] := field[k-1] - dt*(ft1-ft2)/dzt[k-1];  // change in the cell due to transports through lower and upper boundary [mol/kg]
        ft1 := ft2;
    end;
    k := kmax;
    field[k-1] := field[k-1] - dt*ft1/dzt[k-1];
end;

procedure vdiff_explicit( const diff: DoubleArray1d; var field: DoubleArray1d; const flux_field: DoubleArray1d; const numerator: DoubleArray1d; numFactor: Double; const denominator, dzt: DoubleArray1d; dt: Double); overload;
var
  k, kmax: Integer;
  ft1, ft2, diffusivity, speed, mixed_height, actual_mixed_height, actual_speed: Double;
begin
    kmax:=length(diff);
    ft1  := 0.0;                    // upward transport through upper boundary of the cell [mol*m/kg/s]
    for k := 1 to kmax-1 do
    begin
        diffusivity := 0.5*diff[k-1]+0.5*diff[k];
        speed := diffusivity/(0.5*(dzt[k-1]+dzt[k])); // speed of exchange [m/s]
        mixed_height := speed*dt;                     // height of mixed water column which would be mixed if the gradient would remain the same
        // now limit it by 1/4 of the cell
        actual_mixed_height := (0.5*(dzt[k-1]+dzt[k]))*0.25*quick_ivlev(mixed_height/ (0.5*(dzt[k-1]+dzt[k]))); 
        actual_speed := actual_mixed_height/dt;
        
        ft2 := (max(flux_field[k],0.0)*max(numerator[k]*numFactor,0.0)/max(denominator[k],1e-20) 
                 -max(flux_field[k-1],0.0)*max(numerator[k-1]*numFactor,0.0)/max(denominator[k-1],1e-20)) 
                      *actual_speed; 
                                    // upward transport through lower boundary of the cell [mol*m/kg/s]
        field[k-1] := field[k-1] - dt*(ft1-ft2)/dzt[k-1];  // change in the cell due to transports through lower and upper boundary [mol/kg]
        ft1 := ft2;
    end;
    k := kmax;
    field[k-1] := field[k-1] - dt*ft1/dzt[k-1];
end;

procedure vdiff_explicit( const diff: DoubleArray1d; var field: DoubleArray1d; const dzt: DoubleArray1d; dt: Double; const dz,dzr,dzrq,dztr: DoubleArray1d); overload;
var
  k, kmax: Integer;
  ft1, ft2, diffusivity, mixed_height, speed, actual_mixed_height, actual_speed: Double;
begin
    kmax:=length(diff);
    ft1  := 0.0;                    // upward transport through upper boundary of the cell [mol*m/kg/s]
    for k := 1 to kmax-1 do
    begin
        diffusivity := 0.5*diff[k-1]+0.5*diff[k];
        mixed_height := dt*diffusivity*dzrq[k-1];
        mixed_height := 0.25*dz[k-1]*quick_ivlev(mixed_height);
        ft2 := (field[k]-field[k-1])*mixed_height;

        field[k-1] := field[k-1] - (ft1-ft2)*dztr[k-1];  // change in the cell due to transports through lower and upper boundary [mol/kg]
        ft1 := ft2;
    end;
    k := kmax;
    field[k-1] := field[k-1] - ft1*dztr[k-1];
end;

procedure vdiff_quick(var v: DoubleArray1d; exponent: Double; const lhs: DoubleArray2d; const rhs: DoubleArray2d; const eig: DoubleArray1d);
// performs a quick vertical diffusion for tracer vector v if the decomposed diffusion matrix is known except for an exponent determining the strength
var
  i,j: Integer;
  w: SingleArray1d; // a temporary vector
begin
  //result is v:=LHS * EIG^exponent * RHS * v
  setLength(w,length(v));

  //step 1: w := RHS * v
  for i:=0 to length(v)-1 do
  begin
    w[i]:=0;
    for j:=0 to length(v)-1 do
      w[i]:=w[i]+v[j]*RHS[i,j];
  end;

  //step 2: w:=w.*EIG^exponent
  for i:=0 to length(v)-1 do
    w[i]:=w[i]*power(eig[i],exponent);
  
  //step 3: v:=LHS*w
  for i:=0 to length(v)-1 do
  begin
    v[i]:=0;
    for j:=0 to length(v)-1 do
      v[i]:=v[i]+w[j]*LHS[i,j];
  end;
  setLength(w,0);
end;

//------------------------------------------------------------
// SECOND PART
// modified by code generation tool
//------------------------------------------------------------

procedure cgt_init_constants;  
var
  F: TextFile;
  s: String;
begin
//set the values of the constants which are allowed to vary
//if a file "values_of_constants.txt" exists, load that one
//otherwise, use default values
  if FileExists(ExtractFilePath(application.exeName)+'values_of_constants.txt') then
  begin
    AssignFile(F,ExtractFilePath(application.exeName)+'values_of_constants.txt');
    reset(F);
<constants variation=1>
    readln(F,s);
    if pos('!',s)>0 then s:=copy(s,1,pos('!',s)-1);
    <name> := StrToFloat(trim(s));
</constants>
    closefile(F);
  end
  else
  begin
<constants variation=1>
    <name> := <value>; // <description>
</constants>
  end;
//constants which have dependsOn/=none will be loaded in cgt_init_tracers
end;

procedure cgt_init_tracers;
var 
  i: Integer;
  tempstring: String;
begin

//--------------------------------
// load initial values for tracers
//--------------------------------

// some need to be loaded from files
<tracers vertLoc=WAT; useInitValue=0>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/'+tempstring+'.txt';
  setLength(tracer_vector_<name>,kmax);
  setLength(tracer_vector_intermediate_<name>,kmax);
  setLength(patankar_modification_<name>,kmax);
  loadMatlabMatrix(tempstring,tracer_vector_<name>);

</tracers>
<tracers vertLoc=SED; useInitValue=0>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/'+tempstring+'.txt';
  loadMatlabMatrix(tempstring,tracer_scalar_<name>);

</tracers>
<tracers vertLoc=SUR; useInitValue=0>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/'+tempstring+'.txt';
  loadMatlabMatrix(tempstring,tracer_scalar_<name>);

</tracers>
<tracers vertLoc=FIS; useInitValue=0>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/'+tempstring+'.txt';
  loadMatlabMatrix(tempstring,tracer_scalar_<name>);

</tracers>

// others are initialized as constant
<tracers vertLoc=WAT; useInitValue=1>
  setLength(tracer_vector_<name>,kmax);
  setLength(tracer_vector_intermediate_<name>,kmax); 
  setLength(patankar_modification_<name>,kmax); 
  for i:=0 to kmax-1 do
    tracer_vector_<name>[i] := <initValue>;
</tracers>
<tracers vertLoc=SED; useInitValue=1>
  tracer_scalar_<name> := <initValue>;
</tracers>
<tracers vertLoc=SUR; useInitValue=1>
  tracer_scalar_<name> := <initValue>;
</tracers>
<tracers vertLoc=FIS; useInitValue=1>
  tracer_scalar_<name> := <initValue>;
</tracers>
<celements isAging/=0>
  setLength(old_vector_<aged>,kmax);
  for i:=0 to kmax-1 do
    old_vector_<aged>[i] := 0.0;
</celements>
<celements isAging/=0>
  setLength(old_vector_sed_<aged>,kmax_sed);
  for i:=0 to kmax_sed-1 do
    old_vector_sed_<aged>[i] := 0.0;
</celements>


// some tracers have vertical movement
<tracers vertLoc=WAT; vertSpeed/=0>
  setLength(vertical_speed_of_<name>,kmax);
  setLength(vertical_diffusivity_of_<name>,kmax);
  for i:=0 to kmax-1 do
  begin
    vertical_speed_of_<name>[i] := 0;
    vertical_diffusivity_of_<name>[i] := 0;
  end;
</tracers>

// auxiliaries which communicate data from the last time step are set to 0
<auxiliaries vertLoc=WAT; isUsedElsewhere=1>
  setLength(auxiliary_vector_<name>,kmax);
  for i:=0 to kmax-1 do
    auxiliary_vector_<name>[i] := 0;
</auxiliaries>
<auxiliaries vertLoc=SED; isUsedElsewhere=1>
  auxiliary_scalar_<name> := 0.0;
</auxiliaries>
<auxiliaries vertLoc=SUR; isUsedElsewhere=1>
  auxiliary_scalar_<name> := 0.0;
</auxiliaries>

// constants which have dependsOn=xyz are loaded here
<constants dependsOn=xyz>
  setLength(constant_vector_<name>,kmax);  //<description>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/'+tempstring+'.txt';
  setLength(constant_vector_<name>,kmax);
  loadMatlabMatrix(tempstring,constant_vector_<name>);
</constants>

// for constants which have dependsOn=xyzt, we initialize the array here
<constants dependsOn=xyzt>
  setLength(constant_vector_<name>,kmax);  //<description>
</constants>

end;

procedure cgt_init_tracers_sed;
var 
  i: Integer;
  tempstring: String;
begin

//--------------------------------
// load initial values for tracers
//--------------------------------

// some need to be loaded from files
<tracers vertLoc=WAT; useInitValue=0; isInPorewater=1>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/sed_'+tempstring+'.txt';
  setLength(tracer_vector_sed_<name>,kmax_sed);
  setLength(tracer_vector_intermediate_sed_<name>,kmax_sed);
  setLength(patankar_modification_sed_<name>,kmax_sed);
  loadMatlabMatrix(tempstring,tracer_vector_sed_<name>);

</tracers>
<tracers vertLoc/=WAT; useInitValue=0>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/sed_'+tempstring+'.txt';
  setLength(tracer_vector_sed_<name>,kmax_sed);
  setLength(tracer_vector_intermediate_sed_<name>,kmax_sed);
  setLength(patankar_modification_sed_<name>,kmax_sed);
  loadMatlabMatrix(tempstring,tracer_vector_sed_<name>);

</tracers>

// others are initialized as constant
<tracers vertLoc=WAT; useInitValue=1; isInPorewater=1>
  setLength(tracer_vector_sed_<name>,kmax_sed);
  setLength(tracer_vector_intermediate_sed_<name>,kmax_sed); 
  setLength(patankar_modification_sed_<name>,kmax_sed); 
  for i:=0 to kmax_sed-1 do
    tracer_vector_sed_<name>[i] := <initValue>;
</tracers>
<tracers vertLoc/=WAT; useInitValue=1; isInPorewater=1>
  setLength(tracer_vector_sed_<name>,kmax_sed);
  setLength(tracer_vector_intermediate_sed_<name>,kmax_sed); 
  setLength(patankar_modification_sed_<name>,kmax_sed); 
  for i:=0 to kmax_sed-1 do
    tracer_vector_sed_<name>[i] := <initValue>;
</tracers>

<celements isAging/=0>
  setLength(old_vector_sed_<aged>,kmax_sed);
  for i:=0 to kmax_sed-1 do
    old_vector_sed_<aged>[i] := 0.0;
</celements>

//some tracers have molecular diffusivity in pore water
<tracers vertLoc=WAT; molDiff/=0; isInPorewater=1>
  setLength(molecular_diffusivity_of_<name>,kmax_sed);
  for i:=0 to kmax_sed-1 do
    molecular_diffusivity_of_<name>[i] := 0;
</tracers>


// auxiliaries which communicate data from the last time step are set to 0
<auxiliaries vertLoc=WAT; isUsedElsewhere=1>
  setLength(auxiliary_vector_sed_<name>,kmax_sed);
  for i:=0 to kmax_sed-1 do
    auxiliary_vector_sed_<name>[i] := 0;
</auxiliaries>
<auxiliaries vertLoc=WAT; isUsedElsewhere=1>
  setLength(auxiliary_vector_sed_<name>,kmax_sed);
  for i:=0 to kmax_sed-1 do
    auxiliary_vector_sed_<name>[i] := 0;
</auxiliaries>

// constants which have dependsOn=xyz are loaded here
<constants dependsOn=xyz>
  setLength(constant_vector_sed_<name>,kmax);  //<description>
  tempstring := trim('<name>');
  tempstring := ExtractFilePath(application.exeName)+'init/sed_'+tempstring+'.txt';
  setLength(constant_vector_sed_<name>,kmax);
  loadMatlabMatrix(tempstring,constant_vector_sed_<name>);
</constants>

// for constants which have dependsOn=xyzt, we initialize the array here
<constants dependsOn=xyzt>
  setLength(constant_vector_sed_<name>,kmax);  //<description>
</constants>

end;


procedure cgt_init_output;
var
  i, j: Integer;
begin
// auxiliary variables
<auxiliaries vertLoc=WAT; isOutput=1>
  // <description> :
    setLength(output_<name>,kmax,max_output_index);  
    for i:=0 to kmax-1 do 
      for j:=0 to max_output_index-1 do 
        output_<name>[i,j]:=0;
    setLength(output_vector_<name>,kmax);  
    for i:=0 to kmax-1 do 
      output_vector_<name>[i] := 0;
</auxiliaries>
<auxiliaries vertLoc=SED; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</auxiliaries>
<auxiliaries vertLoc=SUR; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</auxiliaries>

// tracers
<tracers vertLoc=WAT; isOutput=1>
  // <description> :
    setLength(output_<name>,kmax,max_output_index);  
    for i:=0 to kmax-1 do 
      for j:=0 to max_output_index-1 do 
        output_<name>[i,j]:=0;
    setLength(output_vector_<name>,kmax);  
    for i:=0 to kmax-1 do 
      output_vector_<name>[i] := 0;
</tracers>
<tracers vertLoc=SED; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</tracers>
<tracers vertLoc=SUR; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</tracers>
<tracers vertLoc=FIS; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</tracers>

// processes
<processes vertLoc=WAT; isOutput=1>
  // <description> :
    setLength(output_<name>,kmax,max_output_index);  
    for i:=0 to kmax-1 do 
      for j:=0 to max_output_index-1 do 
        output_<name>[i,j]:=0;
    setLength(output_vector_<name>,kmax);  
    for i:=0 to kmax-1 do 
      output_vector_<name>[i] := 0;
</processes>
<processes vertLoc=WAT>
  setLength(saved_rate_<name>,kmax);  
</processes>
<processes vertLoc=SED; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</processes>
<processes vertLoc=SUR; isOutput=1>
  // <description> :
    setLength(output_<name>,max_output_index);  
    for j:=0 to max_output_index-1 do 
      output_<name>[j]:=0;
    output_scalar_<name> := 0;
</processes>
end;

procedure cgt_init_output_sed;
var
  i, j: Integer;
begin
// auxiliary variables
<auxiliaries vertLoc=WAT; isOutput=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</auxiliaries>
<auxiliaries vertLoc=SED; isOutput=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</auxiliaries>

// tracers
<tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</tracers>
<tracers vertLoc/=WAT; isOutput=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</tracers>

// processes
<processes vertLoc=WAT; isOutput=1; isInPorewater=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</processes>
<processes vertLoc=WAT; isInPorewater=1>
  setLength(saved_rate_sed_<name>,kmax_sed);  
</processes>
<processes vertLoc=SED; isOutput=1; isInPorewater=1>
  // <description> :
    setLength(output_sed_<name>,kmax_sed,max_output_index);  
    for i:=0 to kmax_sed-1 do 
      for j:=0 to max_output_index-1 do 
        output_sed_<name>[i,j]:=0;
    setLength(output_vector_sed_<name>,kmax_sed);  
    for i:=0 to kmax_sed-1 do 
      output_vector_sed_<name>[i] := 0;
</processes>
<processes vertLoc=SED; isInPorewater=1>
  setLength(saved_rate_sed_<name>,kmax_sed);  
</processes>
end;

procedure cgt_calc_opacity_bio(var forcing_vector_opacity_bio: DoubleArray1d);
var i: Integer;
begin
  for i:=0 to kmax-1 do
    forcing_vector_opacity_bio[i]:=0.0;
  // water column tracers
  // calculate opacity contribution [1/m] as product of
  // opacity [m2/mol] * concentration [mol/kg] * water density [kg/m3]
  for i:=0 to kmax-1 do
  begin
    <tracers vertLoc=WAT; opacity/=0>
      forcing_vector_opacity_bio[i] := forcing_vector_opacity_bio[i] + 
          <opacity> * tracer_vector_<name>[i] * density_water;
    </tracers>
  end;
  
  // surface tracers (only in uppermost cell)
  // calculate opacity contribution [1/m] as product of
  // opacity [m2/mol] * concentration [mol/m2] / cell height [m]
  <tracers vertLoc=SUR; opacity/=0>
      forcing_vector_opacity_bio[0] := forcing_vector_opacity_bio[0] + 
          <opacity> * tracer_scalar_<name> / cellheights[0];
  </tracers>
end;

procedure cgt_bio_timestep(intermediate: Boolean; useSavedRates: Boolean);
// if intermediate=true, nothing is sent to the output and no tracer values are changed, but "saved rates" are stored.
// if useSavedRates=true, the opposite is done: The saved rates are used instead of calculating new ones.
// these two options are for using Runge-Kutta methods
var
  k, m: Integer;

  cgt_temp                : Double;           // potential temperature     [Celsius]
  cgt_sali                : Double;           // salinity                  [g/kg]
  cgt_light               : Double;           // light intensity           [W/m2]
  cgt_cellheight          : Double;           // cell height               [m]
  cgt_density             : Double;           // density                   [kg/m3]
  cgt_timestep            : Double;           // timestep                  [days]
  cgt_longitude           : Double;           // geographic longitude      [deg]
  cgt_latitude            : Double;           // geographic latitude       [deg]
  cgt_current_wave_stress : Double;           // bottom stress             [N/m2]
  cgt_bottomdepth         : Double;           // bottom depth              [m]
  cgt_year                : Double;           // year (integer value)      [years]
  cgt_dayofyear           : Double;           // julian day of the year (integer value) [days]
  cgt_hour                : Double;           // hour plus fraction (0..23.99) [hours]
  cgt_iteration           : Integer;          // number of iteration in iterative loop [1]
  cgt_in_sediment         : Double;           // 1 in sediment porewater, 0 in water column

  number_of_loop            : Integer;

  temp1                     : Double;
  temp2                     : Double;
  temp3                     : Double;
  temp4                     : Double;
  temp5                     : Double;
  temp6                     : Double;
  temp7                     : Double;
  temp8                     : Double;
  temp9                     : Double;

  <constants dependsOn/=none>
    <name> : Double; // <description>
  </constants>
  <tracers>
    <name>          : Double; // <description>
    <limitations>
      <name> : Double;
    </limitations>
  </tracers>
  <auxiliaries>
    <name>       : Double; // <description>
  </auxiliaries>
  <processes>
    <name>            : Double;
  </processes>
  <tracers vertLoc=WAT>
    above_<name> : Double; 
  </tracers>
  <tracers vertLoc=FIS>
    cumulated_change_of_<name> : Double;
  </tracers>
  <processes isStiff/=0>
    after_patankar_<name> : Double;
  </processes>

  timestep_fraction         : Double;
  timestep_fraction_new     : Double;
  fraction_of_total_timestep: Double;
  <tracers>
    change_of_<name>: Double;
  </tracers>
  <processes>
    total_rate_<name> : Double;
  </processes>
  which_tracer_exhausted    : Integer;

begin
    // calculate total element concentrations in the water column
    for k := 1 to kmax do
    begin
          <celements>
             tracer_vector_<total>[k-1] := 
             <containingTracers vertLoc=WAT>
                max(0.0,tracer_vector_<ct>[k-1])*<ctAmount> + 
             </containingTracers>
                0.0;
          </celements>   
    end;

    // calculate total colored element concentrations at bottom
       <celements>
          tracer_scalar_<totalBottom> := 
          <containingTracers vertLoc=SED>
             max(0.0,tracer_scalar_<ct>)*<ctAmount> + 
          </containingTracers>
             0.0;
       </celements>    

        // First, do the Pre-Loop to calculate isZIntegral=1 auxiliaries

    cgt_year     :=yearOf(current_date);
    cgt_dayofyear:=dayOfTheYear(current_date);
    cgt_hour     :=hourOf(current_date)+minuteOf(current_date)/60+secondOf(current_date)/3600;
    cgt_in_sediment := 0.0;

    cgt_bottomdepth := 0.0;

    // initialize isZIntegral auxiliary variables with zero
    <auxiliaries isZIntegral=1; calcAfterProcesses=0>
       <name> := 0.0; 
    </auxiliaries>

    for k := 1 to kmax do
    begin
       cgt_bottomdepth := cgt_bottomdepth + cellheights[k-1];
          
             //------------------------------------
             // STEP 0.1: prepare abiotic parameters
             //------------------------------------
             cgt_temp       := forcing_vector_temperature[k-1];         // potential temperature     [Celsius]
             cgt_sali       := forcing_vector_salinity[k-1];            // salinity                  [g/kg]
             cgt_light      := forcing_vector_light[k-1];               // light intensity           [W/m2]
             cgt_cellheight := cellheights[k-1];                        // cell height               [m]
             cgt_density    := density_water;                           // density                   [kg/m3]
             cgt_timestep   := timestep;                                // timestep                  [days]
             cgt_longitude  := location.longitude;                      // geographic longitude      [deg]
             cgt_latitude   := location.latitude;                       // geographic latitude       [deg]
             if k = kmax then
                cgt_current_wave_stress:=forcing_scalar_bottom_stress;  // bottom stress             [N/m2]
             
             //------------------------------------
             // STEP 0.2: load tracer values
             //------------------------------------
<constants dependsOn/=none>
             <name> := constant_vector_<name>[k-1]; // <description>
</constants>
<tracers vertLoc=WAT; calcBeforeZIntegral=1>
             <name> := tracer_vector_<name>[k-1]; // <description>
             if k = 1 then
                above_<name> := tracer_vector_<name>[k-1]
             else
                above_<name> := tracer_vector_<name>[k-2];
</tracers>
<tracers vertLoc=FIS; calcBeforeZIntegral=1>
             <name> := tracer_scalar_<name>; // <description>
</tracers>             
<auxiliaries vertLoc=WAT; isUsedElsewhere=1; calcBeforeZIntegral=1>
             <name> := auxiliary_vector_<name>[k-1]; // <description>
</auxiliaries>

<tracers vertLoc=WAT; isPositive=1; calcBeforeZIntegral=1>
             <name>       := max(<name>,0.0);
             above_<name> := max(above_<name>,0.0);
</tracers>
<tracers vertLoc=FIS; isPositive=1; calcBeforeZIntegral=1>
             <name>       := max(<name>,0.0);
</tracers>

             if k = kmax then
             begin
<tracers vertLoc=SED; calcBeforeZIntegral=1>
                <name> := tracer_scalar_<name>; // <description>
</tracers>

<tracers vertLoc=SED; isPositive=1; calcBeforeZIntegral=1>
                <name> := max(<name>,0.0);
</tracers>
             end;

             //------------------------------------
             // STEP 0.3: calculate auxiliaries with vertLoc=WAT
             //------------------------------------

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=1; calcBeforeZIntegral=1>
             // <description> :
             <name> := (above_<formula>-<formula>)/cgt_cellheight;

</auxiliaries>

             //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations/=0>
             <name> := <iterInit>;
</auxiliaries>

             //iterative loop follows
             for cgt_iteration:=1 to <maxIterations> do
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations/=0>
               // <description> :
               if cgt_iteration <= <iterations> then
               begin
                 temp1  := <temp1>;
                 temp2  := <temp2>;
                 temp3  := <temp3>;
                 temp4  := <temp4>;
                 temp5  := <temp5>;
                 temp6  := <temp6>;
                 temp7  := <temp7>;
                 temp8  := <temp8>;
                 temp9  := <temp9>;
                 <name> := <formula>;
               end;
</auxiliaries>
             end;

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations=0>
             // <description> :
             temp1  := <temp1>;
             temp2  := <temp2>;
             temp3  := <temp3>;
             temp4  := <temp4>;
             temp5  := <temp5>;
             temp6  := <temp6>;
             temp7  := <temp7>;
             temp8  := <temp8>;
             temp9  := <temp9>;
             <name> := <formula>;
             
</auxiliaries>

             //------------------------------------
             // STEP 0.4: add contribution of the current layer k to the zIntegral
             //------------------------------------
<auxiliaries isZIntegral=1; calcAfterProcesses=0>             
             <name> := <name> + (<formula>)*cgt_cellheight*cgt_density;
</auxiliaries>


             //------------------------------------
             // STEP 0.5: pre-calculate auxiliaries with vertLoc=SED or vertLoc=SUR
             //------------------------------------

             if k = kmax then
             begin
               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; calcBeforeZIntegral=1; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; calcBeforeZIntegral=1; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SED; calcAfterProcesses=0; calcBeforeZIntegral=1; isZIntegral=0; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;
                <name> := <formula> ;
                
</auxiliaries>
             end;
             
             if k = 1 then
             begin
               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SUR; calcAfterProcesses=0; calcBeforeZIntegral=1; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SUR; calcAfterProcesses=0; calcBeforeZIntegral=1; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SUR; calcAfterProcesses=0; calcBeforeZIntegral=1; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;                
                <name> := <formula> ;
                
</auxiliaries>
             end;
             
    end;

    // initialize isZIntegral auxiliary variables with zero
<auxiliaries isZIntegral=1; calcAfterProcesses=1>
    <name> := 0.0; 
</auxiliaries>


    //initialize the variable which cumulates the change of the vertLoc=FIS tracer in each k layer with zero
<tracers vertLoc=FIS>
    cumulated_change_of_<name> := 0.0;
</tracers>


    cgt_bottomdepth := 0.0;
    for k := 1 to kmax do
    begin
       cgt_bottomdepth := cgt_bottomdepth + cellheights[k-1];
          
             //------------------------------------
             // STEP 1: prepare abiotic parameters
             //------------------------------------
             cgt_temp       := forcing_vector_temperature[k-1];         // potential temperature     [Celsius]
             cgt_sali       := forcing_vector_salinity[k-1];            // salinity                  [g/kg]
             cgt_light      := forcing_vector_light[k-1];               // light intensity           [W/m2]
             cgt_cellheight := cellheights[k-1];                        // cell height               [m]
             cgt_density    := density_water;                           // density                   [kg/m3]
             cgt_timestep   := timestep;                                // timestep                  [days]
             cgt_latitude   := location.latitude;                       // geographic latitude       [deg]
             cgt_longitude  := location.longitude;                      // geographic longitude      [deg]
             if k = kmax then
                cgt_current_wave_stress:=forcing_scalar_bottom_stress;  // bottom stress             [N/m2]        
             
             //------------------------------------
             // STEP 2: load tracer values
             //------------------------------------
<constants dependsOn/=none>
             <name> := constant_vector_<name>[k-1]; // <description>
</constants>
<tracers vertLoc=WAT>
             <name> := tracer_vector_<name>[k-1]; // <description>
             if k = 1 then
                above_<name> := tracer_vector_<name>[k-1]
             else
                above_<name> := tracer_vector_<name>[k-2];
</tracers>             
<tracers vertLoc=FIS>
             <name> := tracer_scalar_<name>; // <description>
</tracers>             
<auxiliaries vertLoc=WAT; isUsedElsewhere=1>
             <name> := auxiliary_vector_<name>[k-1]; // <description>
</auxiliaries>

<tracers vertLoc=WAT; isPositive=1>
             <name>       := max(<name>,0.0);
             above_<name> := max(above_<name>,0.0);
</tracers>
<tracers vertLoc=FIS; isPositive=1>
             <name>       := max(<name>,0.0);
</tracers>

             if k = kmax then
             begin 
<tracers vertLoc=SED>
                <name> := tracer_scalar_<name>; // <description>
</tracers>

<tracers vertLoc=SED; isPositive=1>
                <name> := max(<name>,0.0);
</tracers>
             end;

             //------------------------------------
             // STEP 4.1: calculate auxiliaries
             //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=1>
             // <description> :
             <name> := (above_<formula>-<formula>)/cellheights[k-1];

</auxiliaries>

             //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; iterations/=0>
             <name> := <iterInit>;
</auxiliaries>

             //iterative loop follows
             for cgt_iteration:=1 to <maxIterations> do
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isGradient=0; iterations/=0>
               // <description> :
               if cgt_iteration <= <iterations> then
               begin
                 temp1  := <temp1>;
                 temp2  := <temp2>;
                 temp3  := <temp3>;
                 temp4  := <temp4>;
                 temp5  := <temp5>;
                 temp6  := <temp6>;
                 temp7  := <temp7>;
                 temp8  := <temp8>;
                 temp9  := <temp9>;
                 <name> := <formula>;
               end;
</auxiliaries>
             end;

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; iterations=0>
             // <description> :
             temp1  := <temp1>;
             temp2  := <temp2>;
             temp3  := <temp3>;
             temp4  := <temp4>;
             temp5  := <temp5>;
             temp6  := <temp6>;
             temp7  := <temp7>;
             temp8  := <temp8>;
             temp9  := <temp9>;
             <name> := <formula>;
             
</auxiliaries>

             if k = kmax then
             begin
               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;
                <name> := <formula> ;
                
</auxiliaries>
             end;
             
             if k = 1 then
             begin
               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SUR; calcAfterProcesses=0; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SUR; calcAfterProcesses=0; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SUR; calcAfterProcesses=0; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;
                <name> := <formula> ;
                
</auxiliaries>
             end;
             
             //------------------------------------
             // STEP 4.2: output of auxiliaries
             //------------------------------------
             if not intermediate then
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isOutput=1>             
               output_vector_<name>[k-1] := output_vector_<name>[k-1] + <name>;
</auxiliaries>

               if k = kmax then
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isOutput=1>
                     output_scalar_<name> := output_scalar_<name> + <name>;
</auxiliaries>
               end;
               if k = 1 then
               begin
<auxiliaries vertLoc=SUR; calcAfterProcesses=0; isOutput=1>
                     output_scalar_<name> := output_scalar_<name> + <name>;
</auxiliaries>
               end;
             end;

             //------------------------------------
             // STEP 5: calculate process limitations
             //------------------------------------

<tracers vertLoc=WAT>
  <limitations>
             <name> := <formula>;
  </limitations>
</tracers>

             if k = kmax then
             begin
<tracers vertLoc=SED>
  <limitations>
                <name> := <formula>;
  </limitations>
</tracers>
             end;

             if k = 1 then
             begin
<tracers vertLoc=SUR>
  <limitations>
                <name> := <formula>;
  </limitations>
</tracers>
             end;

             //------------------------------------
             //-- STEP 6: POSITIVE-DEFINITE SCHEME --------
             //-- means the following steps will be repeated as often as nessecary
             //------------------------------------
             number_of_loop:=1;
             fraction_of_total_timestep:=1.0;
<processes>
             total_rate_<name>          := 0.0;
</processes>

             while cgt_timestep > 0.0 do
             begin
                //------------------------------------
                // STEP 6.1: calculate process rates
                //------------------------------------
<processes vertLoc=WAT>
                // <description> :
                <name> := <turnover>;
                <name> := max(<name>,0.0);

</processes>

                if k = kmax then
                begin
<processes vertLoc=SED>
                   // <description> :
                   <name> := <turnover>;
                   <name> := max(<name>,0.0);
                
</processes>
                end;
             
                if k = 1 then
                begin
<processes vertLoc=SUR>
                   // <description> :
                   <name> := <turnover>;
                   <name> := max(<name>,0.0);
                
</processes>
                end;

                //------------------------------------
                // STEP 6.1.1: save the process rates if intermediate time step
                //------------------------------------

                if (number_of_loop=1) and intermediate then
                begin
<processes vertLoc=WAT>
                  saved_rate_<name>[k-1]:=saved_rate_<name>[k-1]+<name>;
</processes>

<processes vertLoc=SED>
                  if k = kmax then saved_rate_<name>:=saved_rate_<name>+<name>;
</processes>

<processes vertLoc=SUR>
                  if k = 1 then saved_rate_<name>:=saved_rate_<name>+<name>;
</processes>
                end;

                //------------------------------------
                // STEP 6.1.2: use saved rates if they apply
                //------------------------------------

                if useSavedRates then
                begin
<processes vertLoc=WAT>
                  if (<name> > 0) and (saved_rate_<name>[k-1] >= 0) then <name>:=saved_rate_<name>[k-1];
</processes>
<processes vertLoc=WAT; isStiff/=0>
                  if (<name> > 0) and (saved_rate_<name>[k-1] >= 0) then <name>:=<name> * patankar_modification_<stiffTracer>[k-1];
</processes>

                  if k = kmax then
                  begin
<processes vertLoc=SED>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=saved_rate_<name>;
</processes>
<processes vertLoc=SED; isStiff/=0>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=<name> * patankar_modification_<stiffTracer>[k-1];
</processes>
                  end;
             
                  if k = 1 then
                  begin
<processes vertLoc=SUR>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=saved_rate_<name>;
</processes>
<processes vertLoc=SUR; isStiff/=0>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=<name> * patankar_modification_<stiffTracer>[k-1];
</processes>
                  end;
                end;
                
                //------------------------------------
                // STEP 6.1.3: apply Patankar limitations
                //------------------------------------
<processes vertLoc=WAT; isStiff/=0>
                // <description> :
                after_patankar_<name> := <name> * <stiffFactor>;

</processes>

                if k = kmax then
                begin
<processes vertLoc=SED; isStiff/=0>
                   // <description> :
                after_patankar_<name> := <name> * <stiffFactor>;
                
</processes>
                end;
             
                if k = 1 then
                begin
<processes vertLoc=SUR; isStiff/=0>
                   // <description> :
                after_patankar_<name> := <name> * <stiffFactor>;
                
</processes>
                end;

<processes vertLoc=WAT; isStiff/=0>
                // <description> :
                <name> := after_patankar_<name>;

</processes>

                if k = kmax then
                begin
<processes vertLoc=SED; isStiff/=0>
                   // <description> :
                <name> := after_patankar_<name>;
                
</processes>
                end;
             
                if k = 1 then
                begin
<processes vertLoc=SUR; isStiff/=0>
                   // <description> :
                <name> := after_patankar_<name>;
                
</processes>
                end;
                //------------------------------------
                // STEP 6.2: calculate possible euler-forward change (in a full timestep)
                //------------------------------------

<tracers>
                change_of_<name> := 0.0;
</tracers>

<tracers vertLoc=WAT; hasTimeTendenciesVertLoc=WAT>
             
                change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                <timeTendencies vertLoc=WAT>
                   <timeTendency>  // <description>
                </timeTendencies>
                );
</tracers>
<tracers vertLoc=FIS; hasTimeTendenciesVertLoc=WAT>
             
                change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                <timeTendencies vertLoc=WAT>
                   <timeTendency>  // <description>
                </timeTendencies>
                );
</tracers>


                if k = 1 then
                begin
<tracers vertLoc=WAT; hasTimeTendenciesVertLoc=SUR>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies vertLoc=SUR>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>
                end;

                if k = kmax then
                begin
<tracers vertLoc=WAT; hasTimeTendenciesVertLoc=SED>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies vertLoc=SED>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>
<tracers vertLoc=SED; hasTimeTendencies>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>                         
<tracers vertLoc=FIS; hasTimeTendenciesVertLoc=SED>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies vertLoc=SED>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>

                end;           

                //------------------------------------
                // STEP 6.3: calculate maximum fraction of the timestep before some tracer gets exhausted
                //------------------------------------

                timestep_fraction := 1.0;
                which_tracer_exhausted := -1;

                // find the tracer which is exhausted after the shortest period of time

                // in the water column
<tracers vertLoc=WAT; isPositive=1>
             
                // check if tracer <name> was exhausted from the beginning and is still consumed
                if (tracer_vector_<name>[k-1] <= 0.0) and (change_of_<name> < 0.0) then
                begin
                   timestep_fraction := 0.0;
                   which_tracer_exhausted := <numTracer>;
                end;
                // check if tracer <name> was present, but got exhausted
                if (tracer_vector_<name>[k-1] > 0.0) and (tracer_vector_<name>[k-1] + change_of_<name> < 0.0) then
                begin
                   timestep_fraction_new := tracer_vector_<name>[k-1] / (0.0 - change_of_<name>);
                   if timestep_fraction_new <= timestep_fraction then
                   begin
                      which_tracer_exhausted := <numTracer>;
                      timestep_fraction := timestep_fraction_new;
                   end;
                end;
</tracers>
          
                // in the bottom layer
                if k = kmax then
                begin
<tracers vertLoc=SED; isPositive=1>

                   // check if tracer <name> was exhausted from the beginning and is still consumed
                   if (tracer_scalar_<name> <= 0.0) and (change_of_<name> < 0.0) then
                   begin
                      timestep_fraction := 0.0;
                      which_tracer_exhausted := <numTracer>;
                   end;
                   // check if tracer <name> was present, but got exhausted
                   if (tracer_scalar_<name> > 0.0) and (tracer_scalar_<name> + change_of_<name> < 0.0) then
                   begin
                      timestep_fraction_new := tracer_scalar_<name> / (0.0 - change_of_<name>);
                      if timestep_fraction_new <= timestep_fraction then
                      begin
                         which_tracer_exhausted := <numTracer>;
                         timestep_fraction := timestep_fraction_new;
                      end;
                   end;
</tracers>                         
                end;          

                // now, update the limitations: rates of the processes limited by this tracer become zero in the future

<tracers isPositive=1; vertLoc/=FIS>
                if <numTracer> = which_tracer_exhausted then
                begin
                  <limitations>
                   <name> := 0.0;
                  </limitations>
                end;
</tracers>

                //------------------------------------
                // STEP 6.4: apply a Euler-forward timestep with the fraction of the time
                //------------------------------------ 

                // in the water column
<tracers vertLoc=WAT>
             
                // tracer <name> (<description>):
                tracer_vector_<name>[k-1] := tracer_vector_<name>[k-1] + change_of_<name> * timestep_fraction;
</tracers>
<tracers vertLoc=FIS>
             
                // tracer <name> (<description>):
                cumulated_change_of_<name> := cumulated_change_of_<name> + change_of_<name> * timestep_fraction;
</tracers>

          
                // in the bottom layer
                if k = kmax then
                begin
<tracers vertLoc=SED>

                   // tracer <name> (<description>)
                   tracer_scalar_<name> := tracer_scalar_<name> + change_of_<name> * timestep_fraction;
</tracers>                         
                end;

                //------------------------------------
                // STEP 6.5: output of process rates
                //------------------------------------
                if not intermediate then
                begin
<processes vertLoc=WAT>
                  total_rate_<name>    := total_rate_<name>    + <name> * timestep_fraction * fraction_of_total_timestep;          
</processes>
                  if k = kmax then
                  begin
<processes vertLoc=SED>
                     total_rate_<name>    := total_rate_<name>    + <name> * timestep_fraction * fraction_of_total_timestep;
</processes>
                  end;
                  if k = 1 then
                  begin
<processes vertLoc=SUR>
                     total_rate_<name>    := total_rate_<name>    + <name> * timestep_fraction * fraction_of_total_timestep;
</processes>
                  end;
                end;

                //------------------------------------
                // STEP 6.6: set timestep to remaining timestep only
                //------------------------------------

                cgt_timestep := cgt_timestep * (1.0 - timestep_fraction);                         // remaining timestep
                fraction_of_total_timestep := fraction_of_total_timestep * (1.0 - timestep_fraction); // how much of the original timestep is remaining


                if number_of_loop > 100 then
                begin
                  disp('aborted positive-definite scheme: more than 100 iterations');
                end;
                number_of_loop:=number_of_loop+1;

             end;
             //------------------------------------
             //-- END OF POSITIVE-DEFINITE SCHEME -
             //------------------------------------  
                                       
             //------------------------------------
             // STEP 7.0: add cumulated change to vertLoc=FIS tracers
             //------------------------------------
             
             if k = kmax then
             begin
<tracers vertLoc=FIS>
               // apply change of <description>:
               tracer_scalar_<name> := tracer_scalar_<name> + cumulated_change_of_<name>;
               <name> := tracer_scalar_<name>;
</tracers>
             end;

             if not intermediate then
             begin
               //------------------------------------
               // STEP 7.1: output of new tracer concentrations
               //------------------------------------
<tracers vertLoc=WAT; isOutput=1>
               output_vector_<name>[k-1] := output_vector_<name>[k-1] + <name>;
</tracers>
               if k = kmax then
               begin
<tracers vertLoc=SED; isOutput=1>
                 output_scalar_<name> := output_scalar_<name> + <name>;
</tracers>
<tracers vertLoc=FIS; isOutput=1>
                 output_scalar_<name> := output_scalar_<name> + <name>;
</tracers>
               end;
               if k=1 then
               begin
<tracers vertLoc=SUR; isOutput=1>
                 output_scalar_<name> := output_scalar_<name> + <name>;
</tracers>
               end;
             
               //------------------------------------
               // STEP 7.2: calculate "late" auxiliaries
               //------------------------------------
               //------------------------------------
               // STEP 7.2.0.1: Store the actual process rates in its variables to get them right for the calcAfterProcesses auxiliaries
               //------------------------------------
<processes vertLoc=WAT>
                  <name> := total_rate_<name>;
</processes>  
                  if k = kmax then
                  begin
<processes vertLoc=SED>
                     <name> := total_rate_<name>;
</processes>
                  end;
                  if k = 1 then
                  begin
<processes vertLoc=SUR>
                     <name> := total_rate_<name>;
</processes>
                  end;

               //------------------------------------
               // STEP 7.2.0.2: Output of process rates
               //------------------------------------

<processes vertLoc=WAT; isOutput=1>
                  output_vector_<name>[k-1] := output_vector_<name>[k-1] + <name>;
</processes>  
                  if k = kmax then
                  begin
<processes vertLoc=SED; isOutput=1>
                     output_scalar_<name> := output_scalar_<name> + <name>;
</processes>
                  end;
                  if k = 1 then
                  begin
<processes vertLoc=SUR; isOutput=1>
                     output_scalar_<name> := output_scalar_<name> + <name>;
</processes>
                  end;


               //------------------------------------
               // STEP 7.2.1: calculate all but the isZIntegral auxiliaries
               //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isZGradient=0>
               // <description> :
               temp1  := <temp1>;
               temp2  := <temp2>;
               temp3  := <temp3>;
               temp4  := <temp4>;
               temp5  := <temp5>;
               temp6  := <temp6>;
               temp7  := <temp7>;
               temp8  := <temp8>;
               temp9  := <temp9>;
               <name> := <formula>;
             
</auxiliaries>

               if k = kmax then
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isZIntegral=0>
                  // <description> :
                  temp1  := <temp1>;
                  temp2  := <temp2>;
                  temp3  := <temp3>;
                  temp4  := <temp4>;
                  temp5  := <temp5>;
                  temp6  := <temp6>;
                  temp7  := <temp7>;
                  temp8  := <temp8>;
                  temp9  := <temp9>;
                  <name> := <formula>;
                
</auxiliaries>
               end;
             
               if k = 1 then
               begin
<auxiliaries vertLoc=SUR; calcAfterProcesses=1>
                  // <description> :
                  temp1  := <temp1>;
                  temp2  := <temp2>;
                  temp3  := <temp3>;
                  temp4  := <temp4>;
                  temp5  := <temp5>;
                  temp6  := <temp6>;
                  temp7  := <temp7>;
                  temp8  := <temp8>;
                  temp9  := <temp9>;
                  <name> := <formula>;
                
</auxiliaries>
               end;

               //------------------------------------
               // STEP 7.3: add values from this k level to auxiliary variables with isZIntegral=1
               //------------------------------------
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isZIntegral=1>
               <name> := <name> + (<formula>)*cgt_cellheight*cgt_density;
</auxiliaries>

               //------------------------------------
               // STEP 7.4: output of "late" auxiliaries
               //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isOutput=1>             
               output_vector_<name>[k-1] := output_vector_<name>[k-1] + <name>;
</auxiliaries>
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isUsedElsewhere=1>             
               auxiliary_vector_<name>[k-1] := <name>;
</auxiliaries>
               if k = kmax then
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isOutput=1>
                 output_scalar_<name> := output_scalar_<name> + <name>;
</auxiliaries>
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isUsedElsewhere=1>             
                 auxiliary_scalar_<name> := <name>;
</auxiliaries>
               end;
               if k = 1 then
               begin
<auxiliaries vertLoc=SUR; calcAfterProcesses=1; isOutput=1>
                 output_scalar_<name> := output_scalar_<name> + <name>;
</auxiliaries>
<auxiliaries vertLoc=SUR; calcAfterProcesses=1; isUsedElsewhere=1>             
                 auxiliary_scalar_<name> := <name>;
</auxiliaries>
               end;

               //---------------------------------------
               // STEP 7.5: passing vertical velocity and diffusivity to the coupler
               //---------------------------------------

               // EXPLICIT MOVEMENT
               <tracers vertLoc=WAT; vertSpeed/=0>
                  vertical_speed_of_<name>[k-1]:=(<vertSpeed>)/(24*3600.0); // convert to m/s
                  vertical_diffusivity_of_<name>[k-1]:=(<vertDiff>);        // leave as m2/s
               </tracers> 
             end;
    end;
    
    //---------------------------------------
    // biological timestep has ended
    //---------------------------------------
    
    //---------------------------------------
    // vertical movement follows
    //---------------------------------------
    
    if not intermediate then
    begin
      // calculate new total marked element concentrations
      for k := 1 to kmax do
      begin
            <celements>
               tracer_vector_<total>[k-1] := 
               <containingTracers vertLoc=WAT>
                  max(0.0,tracer_vector_<ct>[k-1])*<ctAmount> + 
               </containingTracers>
                  0.0;
            </celements>
      end;
    
      // vertical movement of tracers
      for m := 1 to num_vmove_steps do
      begin
         // store the old age concentrations
            <celements isAging/=0>
            for k:=1 to kmax do
               old_vector_<aged>[k-1] := tracer_vector_<aged>[k-1];
            </celements>
         // first, move the age concentration of marked elements
         <tracers childOf/=none; vertLoc=WAT; vertSpeed/=0; hasCeAged>
           vmove_explicit(vertical_speed_of_<name>, 
                           tracer_vector_<ceAgedName>, old_vector_<ceAgedName>, 
                           tracer_vector_<name>,<ceAmount>,
                           tracer_vector_<ceTotalName>, 
                           cellheights, timestep/num_vmove_steps*(24*3600));
  
         </tracers>
         // second, move the tracers (including marked tracers) themselves
         <tracers vertLoc=WAT; vertSpeed/=0>
           vmove_explicit(vertical_speed_of_<name>, 
                                     tracer_vector_<name>, tracer_vector_<name>, 
                                     tracer_vector_<name>, 1.0, 
                                     tracer_vector_<name>, 
                                     cellheights, timestep/num_vmove_steps*(24*3600));
         </tracers>
         // third, calculate new total marked element concentrations
         for k := 1 to kmax do
         begin
               <celements>
                  tracer_vector_<total>[k-1] := 
                  <containingTracers vertLoc=WAT>
                     max(0.0,tracer_vector_<ct>[k-1])*<ctAmount> + 
                  </containingTracers>
                     0.0;
               </celements>       
         end;
      end;
      // vertical diffusion of tracers
      for m := 1 to num_vmove_steps do
      begin
         // store the old age concentrations
            <celements isAging/=0>
            for k:=1 to kmax do
               old_vector_<aged>[k-1] := tracer_vector_<aged>[k-1];
            </celements>
         // first, diffuse the age concentration of marked elements
         <tracers childOf/=none; vertLoc=WAT; vertSpeed/=0; hasCeAged>
            vdiff_explicit(vertical_diffusivity_of_<name>, 
                           tracer_vector_<ceAgedName>, old_vector_<ceAgedName>, 
                           tracer_vector_<name>,<ceAmount>,
                           tracer_vector_<ceTotalName>, 
                           cellheights, timestep/num_vmove_steps*(24*3600));
  
         </tracers>
         // second, diffuse the tracers (including marked tracers) themselves
         <tracers vertLoc=WAT; vertSpeed/=0>
            vdiff_explicit(vertical_diffusivity_of_<name>, 
                                     tracer_vector_<name>, 
                                     cellheights, timestep/num_vmove_steps*(24*3600), dz,dzr,dzrq,dztr);
         </tracers>
         // third, calculate new total marked element concentrations
         for k := 1 to kmax do
         begin
               <celements>
                  tracer_vector_<total>[k-1] := 
                  <containingTracers vertLoc=WAT>
                     max(0.0,tracer_vector_<ct>[k-1])*<ctAmount> + 
                  </containingTracers>
                     0.0;
               </celements>       
         end;
      end;

      // calculate total colored element concentrations at bottom
      <celements>
         tracer_scalar_<totalBottom> := 
         <containingTracers vertLoc=SED>
            max(0.0,tracer_scalar_<name>)*<ctAmount> + 
         </containingTracers>
            0.0;
      </celements>
    end;
end;

procedure MatTimesVec(const Mat: DoubleArray2d; const Vec: DoubleArray1d; var Res:DoubleArray1d);
var
  i,j: Integer;
begin
  setLength(Res,length(Mat));
  for i:=0 to length(Mat)-1 do
  begin
    res[i]:=0.0;
    for j:=0 to length(Mat[0])-1 do
      res[i]:=res[i]+Mat[i,j]*Vec[j];
  end;
end;

procedure MatTimesMat(const Mat: DoubleArray2d; const Mat2: DoubleArray2d; var Res:DoubleArray2d);
var
  i,j,k: Integer;
begin
  setLength(Res,length(Mat),length(Mat2[0]));
  for i:=0 to length(Res)-1 do
    for j:=0 to length(Res[0])-1 do
    begin
      res[i,j]:=0.0;
      for k:=0 to length(Mat[0])-1 do
        res[i,j]:=res[i,j]+Mat[i,k]*Mat2[k,j];
    end;
end;

procedure VecScaleMat(const Vec: DoubleArray1d; const Mat: DoubleArray2d; var Res:DoubleArray2d);
// scale the rows of Mat by the entries of Vec
var
  i,j: Integer;
begin
  setLength(Res,length(Mat),length(Mat[0]));
  for i:=0 to length(Mat)-1 do
    for j:=0 to length(Mat[0])-1 do
      Res[i,j]:=Mat[i,j]*Vec[i];
end;

procedure ScaScaleMat(const Sca: Double; const Mat: DoubleArray2d; var Res:DoubleArray2d);
// scale the Mat by scalar
var
  i,j: Integer;
begin
  setLength(Res,length(Mat),length(Mat[0]));
  for i:=0 to length(Mat)-1 do
    for j:=0 to length(Mat[0])-1 do
      Res[i,j]:=Mat[i,j]*Sca;
end;

procedure ScaScaleVec(const Sca: Double; const Vec: DoubleArray1d; var Res:DoubleArray1d);
// scale the Vec by scalar
var
  i,j: Integer;
begin
  setLength(Res,length(Vec));
  for i:=0 to length(Vec)-1 do
    Res[i]:=Vec[i]*Sca;
end;

procedure MatInv(const Mat: DoubleArray2d; var Res: DoubleArray2d);
//invert a matrix
var
  tempmat: TReal2dArray;
  i,j: Integer;
  info: integer;
  rep:MatInvReport;
begin
  setLength(tempmat,length(Mat),length(Mat[0]));
  setLength(Res,length(Mat),length(Mat[0]));
  for i:=0 to length(Mat)-1 do
    for j:=0 to length(Mat[0])-1 do
      tempmat[i,j]:=Mat[i,j];
  rmatrixinverse(tempmat,length(tempmat),info,rep);
  for i:=0 to length(Mat)-1 do
    for j:=0 to length(Mat[0])-1 do
      res[i,j]:=tempmat[i,j];
end;

procedure VecPowerSca(const Vec: DoubleArray1d; const Pow: Double; var Res: DoubleArray1d);
//compute the power of a vector's components
var
  i: Integer;
begin
  SetLength(Res,length(Vec));
  for i:=0 to length(Vec)-1 do
    Res[i]:=power(Vec[i],Pow);
end;

procedure calc_inverse_diffmat_oxygen(moldiff:Double;porediff:Double;timestep:Double);
//moldiff is molecular diffusivity [m2/s]
//porediff is bioturbation diffusivity of pore water [m2/s]
var
  i,j,k: Integer;
  Diffmat1, Diffmat2, Tempmat1, Tempmat2: DoubleArray2d;
  TempVec1, TempVec2: DoubleArray1d;
  mytimestep: Double;
begin
 //do matrix calculations only once (assume oxygen diffusivity is constant)
 if length(inverse_diffmat_oxygen)=0 then
 begin
  // calculates a power series (I-exp(Mt))M^-1 of the diffusion matrix M of oxygen
  // first calculate molecular diffusion matrix itself
  VecScaleMat(sed_diffmat_mol_eig,sed_diffmat_mol_rhs,tempmat1);              
  MatTimesMat(sed_diffmat_mol_lhs,tempmat1,Tempmat2);                         
  ScaScaleMat(moldiff*24*3600/sed_basicdiff_mol,Tempmat2,Diffmat1); //[1/d]  
  // second calculate bioturbation matrix
  VecScaleMat(sed_diffmat_porewater_eig,sed_diffmat_porewater_rhs,tempmat1);
  MatTimesMat(sed_diffmat_porewater_lhs,tempmat1,Tempmat2);
  ScaScaleMat(porediff*24*3600/sed_basicdiff_porewater,Tempmat2,Diffmat2); //[1/d]
  // add the matrixes
  setLength(inverse_diffmat_oxygen,length(diffmat1),length(diffmat1[0]));
  for i:=0 to length(Diffmat1)-1 do
    for j:=0 to length(Diffmat1)-1 do
      inverse_diffmat_oxygen[i,j]:=(Diffmat1[i,j]+Diffmat2[i,j]/24/3600);  //[1/d]

  //now calculate (1-exp(Mt)) M^-1 --> inverse_diffmat_oxygen
  //(1-exp(Mt)) M^-1 = -t -M*t^2/2 -M^2*t^3/6 -M^3*t^4/24 - ...
  //this is calculated by an iteration
  //however, for a large time step t, the method is numerically unstable
  //therefore, we reduce the time step by the fact that
  //(1-exp(Mt)) M^-1 = (1+exp(Mt/2)) (1-exp(Mt/2)) M^-1
  for i:=0 to length(Diffmat1)-1 do
    for j:=0 to length(Diffmat1)-1 do
      if i<>j then
        tempmat2[i,j]:=0.0
      else
        tempmat2[i,j]:=1.0;  //[d]
  mytimestep:=timestep;
  while mytimestep > 0.1 do
  begin
    mytimestep:=mytimestep/2.0;
    //now calculate exp(Mt) = exp(Mmol t) * exp(Mporewater t)  --> tempmat1
    VecPowerSca(sed_basicdiff_mol_eig,moldiff*mytimestep*24*3600/sed_basicdiff_mol,tempvec2);
    VecScaleMat(tempvec2,sed_basicdiff_mol_rhs,tempmat1);
    MatTimesMat(sed_basicdiff_mol_lhs,tempmat1,Diffmat1);
    VecPowerSca(sed_basicdiff_porewater_eig,porediff*mytimestep*24*3600/sed_basicdiff_porewater,tempvec2);
    VecScaleMat(tempvec2,sed_basicdiff_porewater_rhs,tempmat1);
    MatTimesMat(sed_basicdiff_porewater_lhs,tempmat1,Diffmat2);
    MatTimesMat(Diffmat1,Diffmat2,tempmat1);
    //add unity matrix
    for i:=0 to length(Diffmat1)-1 do
      tempmat1[i,i]:=tempmat1[i,i]+1.0;
    //temporarily store tempmat2 in diffmat1
    for i:=0 to length(Diffmat1)-1 do
      for j:=0 to length(Diffmat1)-1 do
        diffmat1[i,j]:=tempmat2[i,j];
    //do matrix multiplication
    MatTimesMat(diffmat1,tempmat1,tempmat2);
  end;
  //store tempmat2 in diffmat2
  for i:=0 to length(Diffmat1)-1 do
    for j:=0 to length(Diffmat1)-1 do
      diffmat2[i,j]:=tempmat2[i,j];

  //now calculate (1-exp(Mt/2)) M^-1 with small t
  for i:=0 to length(Diffmat1)-1 do
    for j:=0 to length(Diffmat1)-1 do
      if i<>j then
        tempmat1[i,j]:=0.0
      else
        tempmat1[i,j]:=0.0-mytimestep;  //[d]
  for i:=0 to length(Diffmat1)-1 do
    for j:=0 to length(Diffmat1)-1 do
      tempmat2[i,j]:=tempmat1[i,j];

  for i:=2 to 50 do   //200 is appropriate for a time step of 0.2
                      // 50 is appropriate for a time step of 0.1
                      //the reason is that the number should be > max(Mt)*max(Mt)
  begin
    MatTimesMat(inverse_diffmat_oxygen,tempmat1,diffmat1);   //[1/d]*[d] = [1]
    ScaScaleMat(mytimestep/i,diffmat1,tempmat1); //[d] *[1] = [d]
    for j:=0 to length(Diffmat1)-1 do
      for k:=0 to length(Diffmat1)-1 do
        tempmat2[j,k]:=tempmat2[j,k]+tempmat1[j,k];
  end;
  //multiply left and right hand side to obtain final matrix
  MatTimesMat(diffmat2,tempmat2,inverse_diffmat_oxygen);

  //now calculate exp(Mt) = exp(Mmol t) * exp(Mporewater t)  --> tempmat1
  VecPowerSca(sed_basicdiff_mol_eig,moldiff*timestep*24*3600/sed_basicdiff_mol,tempvec2);
  VecScaleMat(tempvec2,sed_basicdiff_mol_rhs,tempmat1);
  MatTimesMat(sed_basicdiff_mol_lhs,tempmat1,Diffmat1);
  VecPowerSca(sed_basicdiff_porewater_eig,porediff*timestep*24*3600/sed_basicdiff_porewater,tempvec2);
  VecScaleMat(tempvec2,sed_basicdiff_porewater_rhs,tempmat1);
  MatTimesMat(sed_basicdiff_porewater_lhs,tempmat1,Diffmat2);
  MatTimesMat(Diffmat1,Diffmat2,actual_diffmat_oxygen);
 end;
  setLength(consumption_rate_of_oxygen,length(inverse_diffmat_oxygen));
  for i:=0 to length(inverse_diffmat_oxygen)-1 do
    consumption_rate_of_oxygen[i]:=0.0;
  // store initial concentration in a vector
  setLength(concentration_vector_of_oxygen,length(inverse_diffmat_oxygen));
  concentration_vector_of_oxygen[0]:=tracer_vector_t_o2[kmax-1];
  for i:=1 to kmax_sed do
    concentration_vector_of_oxygen[i]:=tracer_vector_sed_t_o2[i-1];
end;


function calc_max_consumption_oxygen(k:Integer;moldiff:Double;porediff:Double;timestep:Double):Double;
// calculates maximum consumption of oxygen [mol/kg/d] in layer k
// if consumption in layers above k is known and stored in consumption_rate_of_oxygen
var
  i: integer;
  tempvec1, tempvec2, finalconc, concvec, c_u: DoubleArray1d;
  Diffmat1, Diffmat2, Tempmat1, Tempmat2: DoubleArray2d;
begin
  MatTimesVec(inverse_diffmat_oxygen,consumption_rate_of_oxygen,tempvec1);{  MatTimesVec(inverse_diffmat_oxygen,consumption_rate_of_oxygen,tempvec1); //[s*mol/kg/d]
  for i:=0 to length(tempvec1)-1 do
    tempvec1[i]:=tempvec1[i]/24.0/3600.0; //[mol/kg]}

  // final concentration consists of three contributions: 
  //   (1-exp(Mt) * M^-1 * S
  // + exp(Mt) * c

  
  setLength(finalconc,length(tempvec1));
  for i:=0 to length(tempvec1)-1 do
    finalconc[i]:=tempvec1[i];
  
  MatTimesVec(actual_diffmat_oxygen,concentration_vector_of_oxygen,tempvec2);
  for i:=0 to length(tempvec1)-1 do
    finalconc[i]:=finalconc[i]+tempvec2[i];

  //now we calculate how much a consumption of 1 [mol/kg/d] would change the final concentration ([mol/kg] / [mol/kg/d])
  //extract column k from M^-1
  for i:=0 to length(tempvec1)-1 do
    tempvec1[i]:=0.0;
  tempvec1[k]:=1.0;
  MatTimesVec(inverse_diffmat_oxygen,tempvec1,c_u);
  
  result:=-1.0;
  //now, if the change is negative, it may constrain the rate depending on the concentration
  for i:=0 to length(tempvec1)-1 do
    if c_u[i]<0 then
      if (finalconc[i]/(0.0-c_u[i]) > 0) and ((finalconc[i]/(0.0-c_u[i]) < result) or (result<0)) then
        result:=finalconc[i]/(0.0-c_u[i]); //[mol/kg/d]
end;

function apply_oxygen_consumption(moldiff:Double;porediff:Double;timestep:Double):Double;
// applies new oxygen concentration after synchronous diffusion / consumption
var
  i: Integer;
  tempvec1, tempvec2, finalconc, concvec: DoubleArray1d;
  Diffmat1, Diffmat2, Tempmat1, Tempmat2: DoubleArray2d;
begin
  //first of all, calculate (1-exp(Mt)) M^-1 * S  --> tempvec1
  //(1-exp(Mt)) M^-1 * S = -t*S -M*t^2/2*S -M^2*t^3/6*S -M^3*t^4/24*S - ...
  //this is calculated by an iteration
  MatTimesVec(inverse_diffmat_oxygen,consumption_rate_of_oxygen,tempvec1);

  // final concentration consists of three contributions: 
  //   M^-1 * S
  // + exp(Mt) * c
  // - exp(Mt) * M^-1 * S

  
  setLength(finalconc,length(tempvec1));
  for i:=0 to length(tempvec1)-1 do
    finalconc[i]:=tempvec1[i];
  
  MatTimesVec(actual_diffmat_oxygen,concentration_vector_of_oxygen,tempvec2);
  for i:=0 to length(tempvec1)-1 do
    finalconc[i]:=finalconc[i]+tempvec2[i];


  tracer_vector_t_o2[kmax-1]:=finalconc[0];
  for i:=1 to kmax_sed do
    tracer_vector_sed_t_o2[i-1]:=finalconc[i];
end;

procedure cgt_bio_timestep_sed(intermediate: Boolean; useSavedRates: Boolean);
// if intermediate=true, nothing is sent to the output and no tracer values are changed, but "saved rates" are stored.
// if useSavedRates=true, the opposite is done: The saved rates are used instead of calculating new ones.
// these two options are for using Runge-Kutta methods
var
  k, m: Integer;

  cgt_temp                : Double;           // potential temperature     [Celsius]
  cgt_sali                : Double;           // salinity                  [g/kg]
  cgt_light               : Double;           // light intensity           [W/m2]
  cgt_cellheight          : Double;           // cell height               [m]
  cgt_density             : Double;           // density                   [kg/m3]
  cgt_timestep            : Double;           // timestep                  [days]
  cgt_longitude           : Double;           // geographic longitude      [deg]
  cgt_latitude            : Double;           // geographic latitude       [deg]
  cgt_current_wave_stress : Double;           // bottom stress             [N/m2]
  cgt_bottomdepth         : Double;           // bottom depth              [m]
  cgt_year                : Double;           // year (integer value)      [years]
  cgt_dayofyear           : Double;           // julian day of the year (integer value) [days]
  cgt_hour                : Double;           // hour plus fraction (0..23.99) [hours]
  cgt_iteration           : Integer;          // number of iteration in iterative loop [1]
  cgt_in_sediment         : Double;           // 1 in sediment porewater, 0 in water column

  forcing_scalar_tortuosity: Double;
  mydiffusivity: DoubleArray1d;
  myconcentration: DoubleArray1d;
  mycellheights: DoubleArray1d;
  dztr_sed2: DoubleArray1d;

  number_of_loop            : Integer;

  temp1                     : Double;
  temp2                     : Double;
  temp3                     : Double;
  temp4                     : Double;
  temp5                     : Double;
  temp6                     : Double;
  temp7                     : Double;
  temp8                     : Double;
  temp9                     : Double;

  <constants dependsOn/=none>
    <name> : Double; // <description>
  </constants>
  <tracers>
    <name>          : Double; // <description>
    <limitations>
      <name> : Double;
    </limitations>
  </tracers>
  <auxiliaries>
    <name>       : Double; // <description>
  </auxiliaries>
  <processes>
    <name>            : Double;
  </processes>
  <tracers vertLoc=WAT; isInPorewater=1>
    above_<name> : Double; 
  </tracers>

  timestep_fraction         : Double;
  timestep_fraction_new     : Double;
  fraction_of_total_timestep: Double;
  <tracers>
    change_of_<name>: Double;
  </tracers>
  <processes>
    total_rate_<name> : Double;
  </processes>
  which_tracer_exhausted    : Integer;
  // variables needed for implicit diffusion of oxygen follow
  relative_remains, used_from_above, cgt_distance_to_cell_above, porosity, tortuosity, maximum_flux, maximum_concentration, old_concentration: Double;

begin
    // calculate total element concentrations in pore water and solid phase
    for k := 1 to kmax_sed do
    begin
          <celements>
             tracer_vector_sed_<total>[k-1] := 
             <containingTracers vertLoc=WAT; isInPorewater=1>
                max(0.0,tracer_vector_sed_<ct>[k-1])*<ctAmount> + 
             </containingTracers>
                0.0;
          </celements>   
          <celements>
             tracer_vector_sed_<totalBottom>[k-1] := 
             <containingTracers vertLoc=SED>
                max(0.0,tracer_vector_sed_<ct>[k-1])*<ctAmount> + 
             </containingTracers>
                0.0;
          </celements>   
    end;

        // First, do the Pre-Loop to calculate isZIntegral=1 auxiliaries

    cgt_year     :=yearOf(current_date);
    cgt_dayofyear:=dayOfTheYear(current_date);
    cgt_hour     :=hourOf(current_date)+minuteOf(current_date)/60+secondOf(current_date)/3600;
    cgt_in_sediment := 1.0;

    cgt_bottomdepth := depths[kmax-1];

    // initialize isZIntegral auxiliary variables with zero
    <auxiliaries isZIntegral=1; calcAfterProcesses=0>
       <name> := 0.0; 
    </auxiliaries>

    for k := 1 to kmax_sed do
    begin
       cgt_bottomdepth := cgt_bottomdepth + cellheights_sed[k-1];
          
             //------------------------------------
             // STEP 0.1: prepare abiotic parameters
             //------------------------------------
             cgt_temp       := forcing_vector_temperature[kmax-1];      // potential temperature     [Celsius]
             cgt_sali       := forcing_vector_salinity[kmax-1];         // salinity                  [g/kg]
             cgt_light      := 0.0;                                     // light intensity           [W/m2]
             cgt_cellheight := cellheights_sed[k-1]*(1.0-forcing_vector_sed_inert_ratio[k-1]); // cell height               [m]
             cgt_density    := density_water;                           // density                   [kg/m3]
             cgt_timestep   := timestep;                                // timestep                  [days]
             cgt_longitude  := location.longitude;                      // geographic longitude      [deg]
             cgt_latitude   := location.latitude;                       // geographic latitude       [deg]
             cgt_current_wave_stress:=forcing_scalar_bottom_stress;     // bottom stress             [N/m2]
             
             //------------------------------------
             // STEP 0.2: load tracer values
             //------------------------------------
<constants dependsOn/=none>
             <name> := constant_vector_sed_<name>[k-1]; // <description>
</constants>
<tracers vertLoc=WAT; calcBeforeZIntegral=1; isInPorewater=1>
             <name> := tracer_vector_sed_<name>[k-1]; // <description>
             if k = 1 then
                above_<name> := tracer_vector_sed_<name>[k-1]
             else
                above_<name> := tracer_vector_sed_<name>[k-2];
</tracers>           
<auxiliaries vertLoc=WAT; isUsedElsewhere=1; calcBeforeZIntegral=1>
             <name> := auxiliary_vector_sed_<name>[k-1]; // <description>
</auxiliaries>

<tracers vertLoc=WAT; isPositive=1; calcBeforeZIntegral=1; isInPorewater=1>
             <name>       := max(<name>,0.0);
             above_<name> := max(above_<name>,0.0);
</tracers>
<tracers vertLoc=SED; calcBeforeZIntegral=1>
                <name> := tracer_vector_sed_<name>[k-1]; // <description>
</tracers>

<tracers vertLoc=SED; isPositive=1; calcBeforeZIntegral=1>
                <name> := max(<name>,0.0);
</tracers>

             //------------------------------------
             // STEP 0.3: calculate auxiliaries
             //------------------------------------

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=1; calcBeforeZIntegral=1>
             // <description> :
             <name> := (above_<formula>-<formula>)/cgt_cellheight;

</auxiliaries>

             //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations/=0>
             <name> := <iterInit>;
</auxiliaries>

             //iterative loop follows
             for cgt_iteration:=1 to <maxIterations> do
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations/=0>
               // <description> :
               if cgt_iteration <= <iterations> then
               begin
                 temp1  := <temp1>;
                 temp2  := <temp2>;
                 temp3  := <temp3>;
                 temp4  := <temp4>;
                 temp5  := <temp5>;
                 temp6  := <temp6>;
                 temp7  := <temp7>;
                 temp8  := <temp8>;
                 temp9  := <temp9>;
                 <name> := <formula>;
               end;
</auxiliaries>
             end;

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; calcBeforeZIntegral=1; iterations=0>
             // <description> :
             temp1  := <temp1>;
             temp2  := <temp2>;
             temp3  := <temp3>;
             temp4  := <temp4>;
             temp5  := <temp5>;
             temp6  := <temp6>;
             temp7  := <temp7>;
             temp8  := <temp8>;
             temp9  := <temp9>;
             <name> := <formula>;
             
</auxiliaries>

               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; calcBeforeZIntegral=1; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; calcBeforeZIntegral=1; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SED; calcAfterProcesses=0; calcBeforeZIntegral=1; isZIntegral=0; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;
                <name> := <formula> ;
                
</auxiliaries>                          
    end;

    cgt_bottomdepth := depths[kmax-1];
    for k := 1 to kmax_sed do
    begin
       cgt_bottomdepth := cgt_bottomdepth + cellheights_sed[k-1];
          
             //------------------------------------
             // STEP 1: prepare abiotic parameters
             //------------------------------------
             cgt_temp       := forcing_vector_temperature[kmax-1];      // potential temperature     [Celsius]
             cgt_sali       := forcing_vector_salinity[kmax-1];         // salinity                  [g/kg]
             cgt_light      := 0.0;                                     // light intensity           [W/m2]
             cgt_cellheight := cellheights_sed[k-1]*(1.0-forcing_vector_sed_inert_ratio[k-1]); // cell height               [m]
             cgt_density    := density_water;                           // density                   [kg/m3]
             cgt_timestep   := timestep;                                // timestep                  [days]
             cgt_latitude   := location.latitude;                       // geographic latitude       [deg]
             cgt_longitude  := location.longitude;                      // geographic longitude      [deg]
             cgt_current_wave_stress:=forcing_scalar_bottom_stress;     // bottom stress             [N/m2]        
             
             //------------------------------------
             // STEP 2: load tracer values
             //------------------------------------
<constants dependsOn/=none>
             <name> := constant_vector_sed_<name>[k-1]; // <description>
</constants>
<tracers vertLoc=WAT; isInPorewater=1>
             <name> := tracer_vector_sed_<name>[k-1]; // <description>
             if k = 1 then
                above_<name> := tracer_vector_sed_<name>[k-1]
             else
                above_<name> := tracer_vector_sed_<name>[k-2];
</tracers>             
<tracers vertLoc=FIS>
             <name> := tracer_scalar_<name>; // <description>
</tracers>             
<auxiliaries vertLoc=WAT; isUsedElsewhere=1>
             <name> := auxiliary_vector_sed_<name>[k-1]; // <description>
</auxiliaries>

<tracers vertLoc=WAT; isPositive=1; isInPorewater=1>
             <name>       := max(<name>,0.0);
             above_<name> := max(above_<name>,0.0);
</tracers>
<tracers vertLoc=SED>
                <name> := tracer_vector_sed_<name>[k-1]; // <description>
</tracers>
<tracers vertLoc=SED; isPositive=1>
                <name> := max(<name>,0.0);
</tracers>

             //------------------------------------
             // STEP 4.1: calculate auxiliaries
             //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=1>
             // <description> :
             <name> := (above_<formula>-<formula>)/cellheights_sed[k-1];

</auxiliaries>

             //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; iterations/=0>
             <name> := <iterInit>;
</auxiliaries>

             //iterative loop follows
             for cgt_iteration:=1 to <maxIterations> do
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isGradient=0; iterations/=0>
               // <description> :
               if cgt_iteration <= <iterations> then
               begin
                 temp1  := <temp1>;
                 temp2  := <temp2>;
                 temp3  := <temp3>;
                 temp4  := <temp4>;
                 temp5  := <temp5>;
                 temp6  := <temp6>;
                 temp7  := <temp7>;
                 temp8  := <temp8>;
                 temp9  := <temp9>;
                 <name> := <formula>;
               end;
</auxiliaries>
             end;

<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isZGradient=0; iterations=0>
             // <description> :
             temp1  := <temp1>;
             temp2  := <temp2>;
             temp3  := <temp3>;
             temp4  := <temp4>;
             temp5  := <temp5>;
             temp6  := <temp6>;
             temp7  := <temp7>;
             temp8  := <temp8>;
             temp9  := <temp9>;
             <name> := <formula>;
             
</auxiliaries>

               //initialize auxiliaries for iterative loop
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations/=0>
               <name> := <iterInit>;
</auxiliaries>

               //iterative loop follows
               for cgt_iteration:=1 to <maxIterations> do
               begin
<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations/=0>
                 // <description> :
                 if cgt_iteration <= <iterations> then
                 begin
                   temp1  := <temp1>;
                   temp2  := <temp2>;
                   temp3  := <temp3>;
                   temp4  := <temp4>;
                   temp5  := <temp5>;
                   temp6  := <temp6>;
                   temp7  := <temp7>;
                   temp8  := <temp8>;
                   temp9  := <temp9>;
                   <name> := <formula>;
                 end;
</auxiliaries>
               end;

<auxiliaries vertLoc=SED; calcAfterProcesses=0; isZIntegral=0; iterations=0>
                // <description> :
                temp1  := <temp1>;
                temp2  := <temp2>;
                temp3  := <temp3>;
                temp4  := <temp4>;
                temp5  := <temp5>;
                temp6  := <temp6>;
                temp7  := <temp7>;
                temp8  := <temp8>;
                temp9  := <temp9>;
                <name> := <formula> ;
                
</auxiliaries>
             
             //------------------------------------
             // STEP 4.2: output of auxiliaries
             //------------------------------------
             if not intermediate then
             begin
<auxiliaries vertLoc=WAT; calcAfterProcesses=0; isOutput=1>             
               output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</auxiliaries>

<auxiliaries vertLoc=SED; calcAfterProcesses=0; isOutput=1>
                     output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</auxiliaries>
             end;

             //------------------------------------
             // STEP 5: calculate process limitations
             //------------------------------------

<tracers vertLoc=WAT; isInPorewater=1>
  <limitations>
             <name> := <formula>;
  </limitations>
</tracers>

<tracers vertLoc=SED>
  <limitations>
                <name> := <formula>;
  </limitations>
</tracers>

             //------------------------------------
             //-- STEP 6: POSITIVE-DEFINITE SCHEME --------
             //-- means the following steps will be repeated as often as nessecary
             //------------------------------------
             number_of_loop:=1;
             fraction_of_total_timestep:=1.0;
<processes>
             total_rate_<name>          := 0.0;
</processes>

             while cgt_timestep > 0.0 do
             begin

               //---------------------------------------
               // STEP 6.0: obtaining molecular diffusivity for quick-diffusing tracers
               //---------------------------------------

               // EXPLICIT MOVEMENT
               <tracers vertLoc=WAT; molDiff/=0; isInPorewater=1; name=t_o2>
                  molecular_diffusivity_of_<name>[k-1]:=<molDiff>; // in m2/s
               </tracers> 


                //------------------------------------
                // STEP 6.1: calculate process rates
                //------------------------------------
<processes vertLoc=WAT; isInPorewater=1>
                // <description> :
                <name> := <turnover>;
                <name> := max(<name>,0.0);

</processes>

<processes vertLoc=SED; isInPorewater=1>
                   // <description> :
                   <name> := <turnover>;
                   <name> := max(<name>,0.0);
                
</processes>
<processes isInPorewater=0>
                <name> := 0.0;
</processes>


                //------------------------------------
                // STEP 6.1.1: save the process rates if intermediate time step
                //------------------------------------

                if (number_of_loop=1) and intermediate then
                begin
<processes vertLoc=WAT; isInPorewater=1>
                  saved_rate_<name>[k-1]:=saved_rate_<name>[k-1]+<name>;
</processes>

<processes vertLoc=SED; isInPorewater=1>
                  saved_rate_<name>:=saved_rate_<name>+<name>;
</processes>
                end;

                //------------------------------------
                // STEP 6.1.2: use saved rates if they apply
                //------------------------------------

                if useSavedRates then
                begin
<processes vertLoc=WAT; isInPorewater=1>
                  if (<name> > 0) and (saved_rate_<name>[k-1] >= 0) then <name>:=saved_rate_<name>[k-1];
</processes>
<processes vertLoc=WAT; isStiff/=0; isInPorewater=1>
                  if (<name> > 0) and (saved_rate_<name>[k-1] >= 0) then <name>:=<name> * patankar_modification_<stiffTracer>[k-1];
</processes>

<processes vertLoc=SED; isInPorewater=1>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=saved_rate_<name>;
</processes>
<processes vertLoc=SED; isStiff/=0; isInPorewater=1>
                    if (<name> > 0) and (saved_rate_<name> >= 0) then <name>:=<name> * patankar_modification_<stiffTracer>[k-1];
</processes>
                end;
                
                //------------------------------------
                // STEP 6.1.3: apply Patankar limitations
                //------------------------------------
<processes vertLoc=WAT; isStiff/=0; isInPorewater=1>
                // <description> :
                after_patankar_<name> := <name> * <stiffFactor>;

</processes>

<processes vertLoc=SED; isStiff/=0; isInPorewater=1>
                   // <description> :
                after_patankar_<name> := <name> * <stiffFactor>;
                
</processes>

<processes vertLoc=WAT; isStiff/=0; isInPorewater=1>
                // <description> :
                <name> := after_patankar_<name>;

</processes>

<processes vertLoc=SED; isStiff/=0; isInPorewater=1>
                   // <description> :
                <name> := after_patankar_<name>;
                
</processes>

                //------------------------------------
                // STEP 6.1.4: implicit treatment of tracers which  
                // have such a quick diffusion and consumption that
                // their local concentration gets completely exhausted 
                // several times during one time step
                //------------------------------------

                if k=1 then // uppermost sediment cell
                begin
                  if number_of_loop=1 then 
                  begin
<tracers vertLoc=WAT; isInPorewater=1; name=t_o2>
                    //calculate inverse matrix of M
                    calc_inverse_diffmat_oxygen(molecular_diffusivity_of_<name>[0],forcing_vector_sed_diffusivity_porewater[0],cgt_timestep);
                    maximum_concentration:=cgt_timestep*calc_max_consumption_oxygen(k,molecular_diffusivity_of_<name>[k-1],forcing_vector_sed_diffusivity_porewater[k-1],cgt_timestep); //[d]*[mol/kg/d] = [mol/kg]
                    old_concentration:=tracer_vector_sed_<name>[k-1];
                    tracer_vector_sed_<name>[k-1]:=maximum_concentration; //[mol/kg]
                    used_from_above:=0.0; //mol/kg
</tracers>
                  end;
                end
                else // not uppermost sediment cell
                begin
                  if number_of_loop=1 then 
                  begin
<tracers vertLoc=WAT; isInPorewater=1; name=t_o2>
                    maximum_concentration:=cgt_timestep*calc_max_consumption_oxygen(k,molecular_diffusivity_of_<name>[0],forcing_vector_sed_diffusivity_porewater[0],cgt_timestep); //[d]*[mol/kg/d] = [mol/kg]
                    old_concentration:=tracer_vector_sed_<name>[k-1];
                    tracer_vector_sed_<name>[k-1]:=maximum_concentration; //[mol/kg]
                    used_from_above:=0.0; //mol/kg
</tracers>
                  end;
                end;
                //------------------------------------
                // STEP 6.2: calculate possible euler-forward change (in a full timestep)
                //------------------------------------

<tracers>
                change_of_<name> := 0.0;
</tracers>

<tracers vertLoc=WAT; hasTimeTendenciesVertLoc=WAT; isInPorewater=1>
             
                change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                <timeTendencies vertLoc=WAT; isInPorewater=1>
                   <timeTendency>  // <description>
                </timeTendencies>
                );
</tracers>
<tracers vertLoc=WAT; hasTimeTendenciesVertLoc=SED; isInPorewater=1>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies vertLoc=SED; isInPorewater=1>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>
<tracers vertLoc=SED; hasTimeTendencies>

                   change_of_<name> := change_of_<name> + cgt_timestep*(0.0 
                   <timeTendencies isInPorewater=1>
                      <timeTendency>  // <description>
                   </timeTendencies>
                   );
</tracers>                                    

                //------------------------------------
                // STEP 6.3: calculate maximum fraction of the timestep before some tracer gets exhausted
                //------------------------------------

                timestep_fraction := 1.0;
                which_tracer_exhausted := -1;

                // find the tracer which is exhausted after the shortest period of time

                // in the pore water
<tracers vertLoc=WAT; isPositive=1; isInPorewater=1>
             
                // check if tracer <name> was exhausted from the beginning and is still consumed
                if (tracer_vector_sed_<name>[k-1] <= 0.0) and (change_of_<name> < 0.0) then
                begin
                   timestep_fraction := 0.0;
                   which_tracer_exhausted := <numTracer>;
                end;
                // check if tracer <name> was present, but got exhausted
                if (tracer_vector_sed_<name>[k-1] > 0.0) and (tracer_vector_sed_<name>[k-1] + change_of_<name> < 0.0) then
                begin
                   timestep_fraction_new := tracer_vector_sed_<name>[k-1] / (0.0 - change_of_<name>);
                   if timestep_fraction_new <= timestep_fraction then
                   begin
                      which_tracer_exhausted := <numTracer>;
                      timestep_fraction := timestep_fraction_new;
                   end;
                end;
</tracers>
          
                // in the solid phase
<tracers vertLoc=SED; isPositive=1>

                   // check if tracer <name> was exhausted from the beginning and is still consumed
                   if (tracer_vector_sed_<name>[k-1] <= 0.0) and (change_of_<name> < 0.0) then
                   begin
                      timestep_fraction := 0.0;
                      which_tracer_exhausted := <numTracer>;
                   end;
                   // check if tracer <name> was present, but got exhausted
                   if (tracer_vector_sed_<name>[k-1] > 0.0) and (tracer_vector_sed_<name>[k-1] + change_of_<name> < 0.0) then
                   begin
                      timestep_fraction_new := tracer_vector_sed_<name>[k-1] / (0.0 - change_of_<name>);
                      if timestep_fraction_new <= timestep_fraction then
                      begin
                         which_tracer_exhausted := <numTracer>;
                         timestep_fraction := timestep_fraction_new;
                      end;
                   end;
</tracers>                         

                // now, update the limitations: rates of the processes limited by this tracer become zero in the future

<tracers isPositive=1; vertLoc/=FIS>
                if <numTracer> = which_tracer_exhausted then
                begin
                  <limitations>
                   <name> := 0.0;
                  </limitations>
                end;
</tracers>

                //------------------------------------
                // STEP 6.4: apply a Euler-forward timestep with the fraction of the time
                //------------------------------------ 

                // in the pore water
<tracers vertLoc=WAT; isInPorewater=1>
             
                // tracer <name> (<description>):
                tracer_vector_sed_<name>[k-1] := tracer_vector_sed_<name>[k-1] + change_of_<name> * timestep_fraction;
</tracers>
          
                // in the bottom layer
<tracers vertLoc=SED>

                   // tracer <name> (<description>)
                   tracer_vector_sed_<name>[k-1] := tracer_vector_sed_<name>[k-1] + change_of_<name> * timestep_fraction;
</tracers>                         

                //------------------------------------
                // STEP 6.5: output of process rates
                //------------------------------------
                if not intermediate then
                begin
<processes vertLoc=WAT; isInPorewater=1>
                  total_rate_<name>    := total_rate_<name>    + <name> * timestep_fraction * fraction_of_total_timestep;          
</processes>
<processes vertLoc=SED; isInPorewater=1>
                     total_rate_<name>    := total_rate_<name>    + <name> * timestep_fraction * fraction_of_total_timestep;
</processes>
                end;

                //------------------------------------
                // STEP 6.6: set timestep to remaining timestep only
                //------------------------------------

                cgt_timestep := cgt_timestep * (1.0 - timestep_fraction);                         // remaining timestep
                fraction_of_total_timestep := fraction_of_total_timestep * (1.0 - timestep_fraction); // how much of the original timestep is remaining

                if number_of_loop > 100 then
                begin
                  disp('aborted positive-definite scheme: more than 100 iterations');
                end;
                number_of_loop:=number_of_loop+1;

             end;
             //------------------------------------
             //-- END OF POSITIVE-DEFINITE SCHEME -
             //------------------------------------  

                //------------------------------------
                // STEP 7.0: implicit treatment of tracers which  
                // have such a quick diffusion and consumption that
                // their local concentration gets completely exhausted 
                // several times during one time step
                //------------------------------------

<tracers vertLoc=WAT; isInPorewater=1; name=t_o2>
                // see how much was consumed
                used_from_above:=maximum_concentration-tracer_vector_sed_<name>[k-1];
                consumption_rate_of_oxygen[k]:=used_from_above/timestep;
                if k=kmax_sed then
                  apply_oxygen_consumption(molecular_diffusivity_of_<name>[0],forcing_vector_sed_diffusivity_porewater[0],timestep);
</tracers>

                                       
             if not intermediate then
             begin
               //------------------------------------
               // STEP 7.1: output of new tracer concentrations
               //------------------------------------
<tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
               output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</tracers>
<tracers vertLoc=SED; isOutput=1>
                 output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</tracers>
             
               //------------------------------------
               // STEP 7.2: calculate "late" auxiliaries
               //------------------------------------
               //------------------------------------
               // STEP 7.2.0.1: Store the actual process rates in its variables to get them right for the calcAfterProcesses auxiliaries
               //------------------------------------
<processes vertLoc=WAT; isInPorewater=1>
                  <name> := total_rate_<name>;
</processes>  
<processes vertLoc=SED; isInPorewarter=1>
                     <name> := total_rate_<name>;
</processes>
               //------------------------------------
               // STEP 7.2.0.2: output of process rates
               //------------------------------------

<processes vertLoc=WAT; isOutput=1; isInPorewater=1>
                  output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</processes>  
<processes vertLoc=SED; isOutput=1; isInPorewater=1>
                     output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</processes>

               //------------------------------------
               // STEP 7.2.1: calculate all but the isZIntegral auxiliaries
               //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isZGradient=0>
               // <description> :
               temp1  := <temp1>;
               temp2  := <temp2>;
               temp3  := <temp3>;
               temp4  := <temp4>;
               temp5  := <temp5>;
               temp6  := <temp6>;
               temp7  := <temp7>;
               temp8  := <temp8>;
               temp9  := <temp9>;
               <name> := <formula>;
             
</auxiliaries>

<auxiliaries vertLoc=SED; calcAfterProcesses=1; isZIntegral=0>
                  // <description> :
                  temp1  := <temp1>;
                  temp2  := <temp2>;
                  temp3  := <temp3>;
                  temp4  := <temp4>;
                  temp5  := <temp5>;
                  temp6  := <temp6>;
                  temp7  := <temp7>;
                  temp8  := <temp8>;
                  temp9  := <temp9>;
                  <name> := <formula>;
                
</auxiliaries>

               //------------------------------------
               // STEP 7.4: output of "late" auxiliaries
               //------------------------------------
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isOutput=1>             
               output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</auxiliaries>
<auxiliaries vertLoc=WAT; calcAfterProcesses=1; isUsedElsewhere=1>             
               auxiliary_vector_sed_<name>[k-1] := <name>;
</auxiliaries>
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isOutput=1>
                 output_vector_sed_<name>[k-1] := output_vector_sed_<name>[k-1] + <name>;
</auxiliaries>
<auxiliaries vertLoc=SED; calcAfterProcesses=1; isUsedElsewhere=1>             
                 auxiliary_vector_sed_<name>[k-1] := <name>;
</auxiliaries>

               //---------------------------------------
               // STEP 7.5: passing molecular diffusivity to the coupler
               //---------------------------------------

               // EXPLICIT MOVEMENT
               <tracers vertLoc=WAT; molDiff/=0; isInPorewater=1>
                  molecular_diffusivity_of_<name>[k-1]:=<molDiff>; // in m2/s
               </tracers> 
             end;
    end;
    
    //---------------------------------------
    // biological timestep has ended
    //---------------------------------------
        
    if not intermediate then
    begin
      //  calculate new total marked element concentrations
      for k := 1 to kmax_sed do
      begin
             <celements>
                tracer_vector_sed_<total>[k-1] := 
                <containingTracers vertLoc=WAT; isInPorewater=1>
                   max(0.0,tracer_vector_sed_<ct>[k-1])*<ctAmount> + 
                </containingTracers>
                   0.0;
             </celements>             
             <celements>
                tracer_vector_sed_<totalBottom>[k-1] := 
                <containingTracers vertLoc=WAT; isInPorewater=1>
                   max(0.0,tracer_vector_sed_<ct>[k-1])*<ctAmount> + 
                </containingTracers>
                   0.0;
             </celements>       
      end;
    
      // vertical diffusion of tracers
      setLength(mydiffusivity,kmax_sed+1);
      setLength(mycellheights,kmax_sed+1);
      mycellheights[0]:=cellheights[kmax-1];
      for k:=0 to kmax_sed-1 do
        mycellheights[k+1]:=cellheights_sed[k]*(1.0-forcing_vector_sed_inert_ratio[k]);
      setLength(myconcentration,kmax_sed+1);


 <tracers vertLoc=WAT; isInPorewater=1; name/=t_o2>
      //diffuse <description>
      mydiffusivity[0]:=molecular_diffusivity_of_<name>[0];
      for k:=0 to kmax_sed-1 do
        mydiffusivity[k+1]:=molecular_diffusivity_of_<name>[k];
      myconcentration[0]:=tracer_vector_<name>[kmax-1];
      for k:=0 to kmax_sed-1 do
        myconcentration[k+1]:=tracer_vector_sed_<name>[k];
      vdiff_quick(myconcentration,molecular_diffusivity_of_<name>[0]*timestep*(24*3600)/sed_basicdiff_mol,sed_basicdiff_mol_lhs,sed_basicdiff_mol_rhs,sed_basicdiff_mol_eig);
      tracer_vector_<name>[kmax-1]:=myconcentration[0];
      for k:=0 to kmax_sed-1 do
        tracer_vector_sed_<name>[k]:=myconcentration[k+1];

 </tracers>
   end;
end;

procedure cgt_mixing_timestep;
var
  i, m: Integer;
begin
  // vertical diffusion of all tracers
  for i:=0 to kmax-1 do
  begin
    forcing_vector_diffusivity[i] := max(forcing_vector_diffusivity[i],min_diffusivity);
    forcing_vector_diffusivity[i] := min(forcing_vector_diffusivity[i],max_diffusivity);
  end;
  for m := 1 to num_vdiff_steps do
  begin
       // diffuse the tracers (including marked tracers) themselves
       <tracers vertLoc=WAT>
          vdiff_explicit(forcing_vector_diffusivity, 
                                   tracer_vector_<name>, 
                                   cellheights, timestep/num_vdiff_steps*(24*3600), dz,dzr,dzrq,dztr);
       </tracers>
  end;
end;

procedure cgt_mixing_timestep_sed;
var
  i: Integer;
  myconcentration: DoubleArray1d;
begin
  setLength(myconcentration,kmax_sed+1);

  //first, diffuse the porewater components  
 <tracers vertLoc=WAT; isInPorewater=1; name/=t_o2>
      //diffuse <description>
      myconcentration[0]:=tracer_vector_<name>[kmax-1];
      for i:=0 to kmax_sed-1 do
        myconcentration[i+1]:=tracer_vector_sed_<name>[i];
      vdiff_quick(myconcentration,forcing_scalar_sed_diffusivity_porewater*timestep*(24*3600)/sed_basicdiff_porewater,sed_basicdiff_porewater_lhs,sed_basicdiff_porewater_rhs,sed_basicdiff_porewater_eig);
      tracer_vector_<name>[kmax-1]:=myconcentration[0];
      for i:=0 to kmax_sed-1 do
        tracer_vector_sed_<name>[i]:=myconcentration[i+1];

 </tracers>

  //second, diffuse the solid components
 <tracers vertLoc=SED>
      //diffuse <description>
      myconcentration[0]:=tracer_scalar_<name>;
      for i:=0 to kmax_sed-1 do
        myconcentration[i+1]:=tracer_vector_sed_<name>[i];
      vdiff_quick(myconcentration,forcing_scalar_sed_diffusivity_solids*timestep*(24*3600)/sed_basicdiff_solids,sed_basicdiff_solids_lhs,sed_basicdiff_solids_rhs,sed_basicdiff_solids_eig);
      tracer_scalar_<name>:=myconcentration[0];
      for i:=0 to kmax_sed-1 do
        tracer_vector_sed_<name>[i]:=myconcentration[i+1];

 </tracers>
  setLength(myconcentration,0);
end;

procedure cgt_sedimentation_timestep_sed;
var
  vertspeed: Double;
  k: Integer;
begin
  //tracers are moved downward using an upwind scheme
  
  //first, downward movement of solid tracers
  vertspeed := forcing_scalar_sed_inert_deposition/forcing_vector_sed_inert_ratio[kmax_sed-1];
 <tracers vertLoc=SED>
  tracer_vector_sed_<name>[kmax_sed-1]:=tracer_vector_sed_<name>[kmax_sed-1]*(1.0-vertspeed*timestep*24*3600/cellheights_sed[kmax_sed-1]);
 </tracers>
  for k:=kmax_sed-2 downto 0 do
  begin
    vertspeed := forcing_scalar_sed_inert_deposition/forcing_vector_sed_inert_ratio[k];
  <tracers vertLoc=SED>
    tracer_vector_sed_<name>[k+1]:=tracer_vector_sed_<name>[k+1]+tracer_vector_sed_<name>[k]*vertspeed*timestep*24*3600/cellheights_sed[k];
    tracer_vector_sed_<name>[k]:=tracer_vector_sed_<name>[k]*(1.0-vertspeed*timestep*24*3600/cellheights_sed[k]);
  </tracers>   
  end;
  vertspeed := forcing_scalar_sed_inert_deposition;
 <tracers vertLoc=SED>
  tracer_vector_sed_<name>[0]:=tracer_vector_sed_<name>[0]+tracer_scalar_<name>*vertspeed*timestep*24*3600/fluffy_layer_thickness;
  tracer_scalar_<name>:=tracer_scalar_<name>*(1.0-vertspeed*timestep*24*3600/fluffy_layer_thickness);
 </tracers>
end;

procedure cgt_output_final(current_output_index, output_count: Integer);
var
  i: Integer;
begin
  // in the water column
 for i:=0 to kmax-1 do
 begin
  <tracers vertLoc=WAT; isOutput=1>
    output_<name>[i,current_output_index-1]:=output_vector_<name>[i]/output_count;
  </tracers>
  <auxiliaries vertLoc=WAT; isOutput=1>
    output_<name>[i,current_output_index-1]:=output_vector_<name>[i]/output_count;
  </auxiliaries>
  <processes vertLoc=WAT; isOutput=1>
    output_<name>[i,current_output_index-1]:=output_vector_<name>[i]/output_count;
  </processes>
 end;
// in the sediment
<tracers vertLoc=SED; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</tracers>
<auxiliaries vertLoc=SED; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</auxiliaries>
<processes vertLoc=SED; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</processes>
// at the sea surface
<tracers vertLoc=SUR; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</tracers>
<auxiliaries vertLoc=SUR; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</auxiliaries>
<processes vertLoc=SUR; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</processes>
//pseudo-3d tracers
<tracers vertLoc=FIS; isOutput=1>
  output_<name>[current_output_index-1]:=output_scalar_<name>/output_count;
</tracers>

// now, set the temporary output vector to zero
 for i:=0 to kmax-1 do
 begin
<tracers vertLoc=WAT; isOutput=1>
  output_vector_<name>[i] := 0.0;
</tracers>
<auxiliaries vertLoc=WAT; isOutput=1>
  output_vector_<name>[i] := 0.0;
</auxiliaries>
<processes vertLoc=WAT; isOutput=1>
  output_vector_<name>[i] := 0.0;
</processes>
 end;
<tracers vertLoc=SED; isOutput=1>
  output_scalar_<name> := 0.0;        
</tracers>
<auxiliaries vertLoc=SED; isOutput=1>
  output_scalar_<name> := 0.0;        
</auxiliaries>
<processes vertLoc=SED; isOutput=1>
  output_scalar_<name> := 0.0;        
</processes>
<tracers vertLoc=SUR; isOutput=1>
  output_scalar_<name> := 0.0;        
</tracers>
<auxiliaries vertLoc=SUR; isOutput=1>
  output_scalar_<name> := 0.0;        
</auxiliaries>
<processes vertLoc=SUR; isOutput=1>
  output_scalar_<name> := 0.0;        
</processes>
<tracers vertLoc=FIS; isOutput=1>
  output_scalar_<name> := 0.0;        
</tracers>

end;

procedure cgt_output_final_sed(current_output_index, output_count: Integer);
var
  i: Integer;
begin
  // in the water column
 for i:=0 to kmax_sed-1 do
 begin
  <tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </tracers>
  <auxiliaries vertLoc=WAT; isOutput=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </auxiliaries>
  <processes vertLoc=WAT; isOutput=1; isInPorewater=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </processes>

  <tracers vertLoc=SED; isOutput=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </tracers>
  <auxiliaries vertLoc=SED; isOutput=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </auxiliaries>
  <processes vertLoc=SED; isOutput=1; isInPorewater=1>
    output_sed_<name>[i,current_output_index-1]:=output_vector_sed_<name>[i]/output_count;
  </processes>
 end;

// now, set the temporary output vector to zero
 for i:=0 to kmax_sed-1 do
 begin
<tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
   output_vector_sed_<name>[i] := 0.0;
</tracers>
<auxiliaries vertLoc=WAT; isOutput=1>
   output_vector_sed_<name>[i] := 0.0;
</auxiliaries>
<processes vertLoc=WAT; isOutput=1; isInPorewater=1>
   output_vector_sed_<name>[i] := 0.0;
</processes>
<tracers vertLoc=SED; isOutput=1>
   output_vector_sed_<name>[i] := 0.0;
</tracers>
<auxiliaries vertLoc=SED; isOutput=1>
   output_vector_sed_<name>[i] := 0.0;
</auxiliaries>
<processes vertLoc=SED; isOutput=1; isInPorewater=1>
   output_vector_sed_<name>[i] := 0.0;
</processes>
 end;

end;


<tracers vertLoc=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing tracer <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</tracers>
<tracers vertLoc/=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing tracer <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'time',false,defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/m**2');  
    end;
  end;
</tracers>
<auxiliaries vertLoc=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing auxiliary <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</auxiliaries>
<auxiliaries vertLoc/=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing auxiliary <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'time',false,defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/m**2');  
    end;
  end;
</auxiliaries>
<processes vertLoc=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing process <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</processes>
<processes vertLoc/=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing process <name>');
    writenc_double(filename,trim('<name>'),output_<name>,'time',false,defineOnly);
    if defineOnly then
    begin 
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/m**2');  
    end;
  end;
</processes>

procedure cgt_write_output_to_netcdf(defineOnly: Boolean);
var
  filename: AnsiString;
  lonarray,latarray: DoubleArray1d;
begin
  filename:=ExtractFilePath(application.exeName)+'results_1d_model.nc';
  if FileExists(filename) then deletefile(filename);
  writenc_double(filename,'time',time_axis,'',false,defineOnly);
    writenc_attribute(filename,'time','units','days since 1899-12-30 00:00:00.0');
    writenc_attribute(filename,'time','cartesian_axis','T');
  writenc_double(filename,'z_axis',depths,'',false,defineOnly);
    writenc_attribute(filename,'z_axis','units','m');
    writenc_attribute(filename,'z_axis','cartesian_axis','Z');
    writenc_attribute(filename,'z_axis','positive','down');
  writenc_double(filename,'temperature',output_temperature,'z_axis;time',defineOnly);
    writenc_attribute(filename,'temperature','long_name','potential temperature');
    writenc_attribute(filename,'temperature','units','Celsius');
  writenc_double(filename,'salinity',output_salinity,'z_axis;time',defineOnly);
    writenc_attribute(filename,'salinity','long_name','salinity');
    writenc_attribute(filename,'salinity','units','g/kg');
  writenc_double(filename,'opacity',output_opacity,'z_axis;time',defineOnly);
    writenc_attribute(filename,'opacity','long_name','opacity of the water for PAR');
    writenc_attribute(filename,'opacity','units','1/m');
  writenc_double(filename,'light',output_light,'z_axis;time',defineOnly);
    writenc_attribute(filename,'light_at_top','long_name','downward shortwave light flux');
    writenc_attribute(filename,'light_at_top','units','W/m**2');
  writenc_double(filename,'diffusivity',output_diffusivity,'z_axis;time',defineOnly);
    writenc_attribute(filename,'diffusivity','long_name','vertical turbulent diffusivity');
    writenc_attribute(filename,'diffusivity','units','m**2/s');
  writenc_double(filename,'light_at_top',output_light_at_top,'time',false,defineOnly);
    writenc_attribute(filename,'light_at_top','long_name','downward shortwave light flux at sea surface');
    writenc_attribute(filename,'light_at_top','units','W/m**2');
  writenc_double(filename,'zenith_angle',output_zenith_angle,'time',false,defineOnly);
    writenc_attribute(filename,'zenith_angle','long_name','solar zenith angle');
    writenc_attribute(filename,'zenith_angle','units','deg');
  writenc_double(filename,'bottom_stress',output_bottom_stress,'time',false,defineOnly);
    writenc_attribute(filename,'bottom_stress','long_name','shear stress at the sea floor');
    writenc_attribute(filename,'bottom_stress','units','N/m**2');

  setLength(lonArray,1); 
  lonArray[0]:=location.longitude;
  writenc_double(filename,'longitude',lonArray,'',false,defineOnly);
    writenc_attribute(filename,'longitude','long_name','longitude');
    writenc_attribute(filename,'longitude','units','deg');
  setLength(latArray,1); 
  latArray[0]:=location.latitude;
  writenc_double(filename,'latitude',latArray,'',false,defineOnly);
    writenc_attribute(filename,'latitude','long_name','longitude');
    writenc_attribute(filename,'latitude','units','deg');

  <tracers vertLoc=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </tracers>
  <tracers vertLoc/=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </tracers>
  <auxiliaries vertLoc=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </auxiliaries>
  <auxiliaries vertLoc/=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </auxiliaries>
  <processes vertLoc=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </processes>
  <processes vertLoc/=WAT; isOutput=1>
    cgt_write_output_to_netcdf_<name>(filename,defineOnly);
  </processes>
end;

<tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing tracer <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</tracers>
<tracers vertLoc=SED; isOutput=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing tracer <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</tracers>
<auxiliaries vertLoc=WAT; isOutput=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing auxiliary <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</auxiliaries>
<auxiliaries vertLoc=SED; isOutput=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing auxiliary <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</auxiliaries>
<processes vertLoc=WAT; isOutput=1; isInPorewater=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing process <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</processes>
<processes vertLoc=SED; isOutput=1; isInPorewater=1>
  procedure cgt_write_output_to_netcdf_sed_<name>(filename: AnsiString; defineOnly: Boolean);
  begin
    disp('    writing process <name>');
    writenc_double(filename,trim('<name>'),output_sed_<name>,'z_axis;time',defineOnly);
    if defineOnly then
    begin
      writenc_attribute(filename,trim('<name>'),'long_name','<description>');
      writenc_attribute(filename,trim('<name>'),'units','mol/kg');
    end;
  end;
</processes>

procedure cgt_write_output_to_netcdf_sed(defineOnly: Boolean);
var
  filename: AnsiString;
  lonarray,latarray: DoubleArray1d;
begin
  filename:=ExtractFilePath(application.exeName)+'results_1d_model_sed.nc';
  if FileExists(filename) then deletefile(filename);
  writenc_double(filename,'time',time_axis,'',false,defineOnly);
    writenc_attribute(filename,'time','units','days since 1899-12-31 00:00:00.0');
    writenc_attribute(filename,'time','cartesian_axis','T');
  writenc_double(filename,'z_axis',depths_sed,'',false,defineOnly);
    writenc_attribute(filename,'z_axis','units','m');
    writenc_attribute(filename,'z_axis','cartesian_axis','Z');
    writenc_attribute(filename,'z_axis','positive','down');
  writenc_double(filename,'temperature',output_temperature[kmax-1],'time',defineOnly);
    writenc_attribute(filename,'temperature','long_name','potential temperature');
    writenc_attribute(filename,'temperature','units','Celsius');
  writenc_double(filename,'salinity',output_salinity[kmax-1],'time',defineOnly);
    writenc_attribute(filename,'salinity','long_name','salinity');
    writenc_attribute(filename,'salinity','units','g/kg');
  writenc_double(filename,'sed_diffusivity_porewater',output_sed_diffusivity_porewater,'z_axis;time',defineOnly);
    writenc_attribute(filename,'sed_diffusivity_porewater','long_name','effective vertical diffusivity in porewater');
    writenc_attribute(filename,'sed_diffusivity_porewater','units','m**2/s');
  writenc_double(filename,'sed_diffusivity_solids',output_sed_diffusivity_solids,'z_axis;time',defineOnly);
    writenc_attribute(filename,'sed_diffusivity_porewater','long_name','effective vertical diffusivity of solids');
    writenc_attribute(filename,'sed_diffusivity_porewater','units','m**2/s');
  writenc_double(filename,'sed_inert_ratio',output_sed_inert_ratio,'z_axis;time',defineOnly);
    writenc_attribute(filename,'sed_inert_ratio','long_name','volume fraction of inert solids');
    writenc_attribute(filename,'sed_inert_ratio','units','1');
            writenc_double(filename,'sed_inert_deposition',output_sed_inert_deposition,'time',defineOnly);
    writenc_attribute(filename,'sed_inert_deposition','long_name','accumulation speed of inert solids');
    writenc_attribute(filename,'sed_inert_deposition','units','m/s');
  writenc_double(filename,'sed_grain_size',output_sed_grain_size,'time',defineOnly);
    writenc_attribute(filename,'sed_grain_size','long_name','sinking velocity of sediment particles');
    writenc_attribute(filename,'sed_grain_size','units','m/s');
  setLength(lonArray,1); 
  lonArray[0]:=location.longitude;
  writenc_double(filename,'longitude',lonArray,'',false,defineOnly);
    writenc_attribute(filename,'longitude','long_name','longitude');
    writenc_attribute(filename,'longitude','units','deg');
  setLength(latArray,1); 
  latArray[0]:=location.latitude;
  writenc_double(filename,'latitude',latArray,'',false,defineOnly);
    writenc_attribute(filename,'latitude','long_name','longitude');
    writenc_attribute(filename,'latitude','units','deg');

  <tracers vertLoc=WAT; isOutput=1; isInPorewater=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </tracers>
  <tracers vertLoc=SED; isOutput=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </tracers>
  <auxiliaries vertLoc=WAT; isOutput=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </auxiliaries>
  <auxiliaries vertLoc=SED; isOutput=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </auxiliaries>
  <processes vertLoc=WAT; isOutput=1; isInPorewater=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </processes>
  <processes vertLoc=SED; isOutput=1; isInPorewater=1>
    cgt_write_output_to_netcdf_sed_<name>(filename,defineOnly);
  </processes>
end;

//------------------------------------------------------------
// THIRD PART
// not modified by code generation tool
//------------------------------------------------------------

procedure calc_diffusivity_matrices;
//calculate matrices to enable large time steps for diffusion
//The matrices we calculate here are:
//  sed_basicdiff_..._lhs,rhs,eig = (I+Mt/n)
//    where M is the diffusivity matrix and n=0.01*max(Mt) -> we need it later on, because we estimate exp(Mt)=(I+Mt/n)^n
//  We store the diffusivity*time for which n=1 in sed_basicdiff_..., so our true n can be found out by n=diffusivity*time/sed_basicdiff_...
//  sed_diffmat_..._lha,rhs,eig = Mt/n 
//    => so the true Mt can be calculated as sed_diffmat_...*diffsivity*time/sed_basicdiff_...

const
  basicdiff=1.0e-12; // basic diffusivity for one diffusion step, may one day be calculated from the fact that a should be positive and close to 1.
var
  i,j,k: Integer;
  gradient: Double;                // concentration gradient [mol/kg/m]
  trp_up, trp_down: DoubleArray1d; // transport [mol/m2/s]
  porosity, tortuosity: Double;    // [1]
  effDiff: Double;                 // effective diffusivity [m2/s]
  change_a, change_b, change_c: DoubleArray1d; //concentration changes in the cells [mol/kg/s]
  a,b,c: DoubleArray1d;            // diffusion tridiagonal matrix
  change_a_max: Double;
  F: TextFile;
begin
  setLength(trp_up, kmax_sed+1); 
  setLength(trp_down, kmax_sed+1); 
  setLength(change_a,kmax_sed+1); setLength(change_b,kmax_sed+1); setLength(change_c,kmax_sed+1); 
  setLength(a,kmax_sed+1); setLength(b,kmax_sed); setLength(c,kmax_sed);

  //MOLECULAR DIFFUSIVITY
  //at first, we calculate the mass transports among the cells if molecular diffusivity is 1 m2/s
  //and concentration is 1 mol/kg in one cell and 0 mol/kg in the other cells [mol/m2/s]
  trp_up[0]:=0.0;
  trp_down[kmax_sed]:=0.0;
  for i:=0 to kmax_sed-1 do
  begin
    if i=0 then gradient:=1.0/(cellheights_sed[0]*0.5+diffusive_layer_thickness) else gradient:=2.0/(cellheights_sed[i-1]+cellheights_sed[i]);
    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    tortuosity:=sqrt(1.0-2.02*log(porosity));
    effDiff:=porosity/(tortuosity*tortuosity);   //[m2/s]
    trp_up[i+1]:=effDiff*gradient*density_water; //[m2/s*mol/kg/m*kg/m3 = mol/m2/s]
    trp_down[i]:=trp_up[i+1];
  end;
  //then, we calculate the concentration change in each cell if a) upward and downward transport go out
  //                                                            b) upward transport goes in
  //                                                            c) downward transport goes in
  for i:=0 to kmax_sed do
  begin
    change_a[i]:=0; change_b[i]:=0; change_c[i]:=0; 
  end;

  change_b[0]:=trp_up[1]/cellheights[kmax-1]/density_water;  //[mol/kg/s], effectively [1/s]
  porosity:=1.0-forcing_vector_sed_inert_ratio[0];
  change_a[1]:=change_a[1]-trp_up[1]/cellheights_sed[0]/density_water/porosity;  //[mol/kg/s], effectively [1/s]

  porosity:=1.0-forcing_vector_sed_inert_ratio[0];
  change_c[1]:=trp_down[0]/cellheights_sed[0]/density_water/porosity;
  change_a[0]:=change_a[0]-trp_down[0]/cellheights[kmax-1]/density_water;

  for i:=1 to kmax_sed-1 do
  begin
    porosity:=1.0-forcing_vector_sed_inert_ratio[i-1];
    change_b[i]:=trp_up[i+1]/cellheights_sed[i-1]/density_water/porosity;
    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    change_a[i+1]:=change_a[i+1]-trp_up[i+1]/cellheights_sed[i]/density_water/porosity;

    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    change_c[i+1]:=trp_down[i]/cellheights_sed[i]/density_water/porosity;
    porosity:=1.0-forcing_vector_sed_inert_ratio[i-1];
    change_a[i]:=change_a[i]-trp_down[i]/cellheights_sed[i-1]/density_water/porosity;
  end;
  change_a_max:=abs(change_a[0]);
  for i:=0 to kmax_sed do
    if abs(change_a[i])>change_a_max then change_a_max:=abs(change_a[i]);
  sed_basicdiff_mol := 0.01/change_a_max; // basic diffusivity which, if applied for 1 second, moves 1% of the material away from the nearest cell [1 m2/s / (1/s) = 1 m2]  

  for i:=0 to kmax_sed do a[i]:=1.0+change_a[i]*sed_basicdiff_mol;
  for i:=0 to kmax_sed-1 do b[i]:=change_b[i]*sed_basicdiff_mol;
  for i:=0 to kmax_sed-1 do c[i]:=change_c[i+1]*sed_basicdiff_mol;

  decomp_tridiag(a,c,b,sed_basicdiff_mol_lhs,sed_basicdiff_mol_rhs,sed_basicdiff_mol_eig);  //[m2/s]

  for i:=0 to kmax_sed do a[i]:=a[i]-1.0;
  decomp_tridiag(a,c,b,sed_diffmat_mol_lhs,sed_diffmat_mol_rhs,sed_diffmat_mol_eig);


  //BIOTURBATION OF LIQUIDS
  //at first, we calculate the mass transports among the cells if molecular diffusivity is 1 m2/s
  //and concentration is 1 mol/kg in one cell and 0 mol/kg in the other cells [mol/m2/s]
  trp_up[0]:=0.0;
  trp_down[kmax_sed]:=0.0;
  for i:=0 to kmax_sed-1 do
  begin
    if i=0 then gradient:=1.0/(cellheights_sed[0]*0.5+diffusive_layer_thickness) else gradient:=2.0/(cellheights_sed[i-1]+cellheights_sed[i]);
    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    effDiff:=porosity*forcing_vector_sed_diffusivity_basic[i];   //[m2/s]
    trp_up[i+1]:=effDiff*gradient*density_water; //[m2/s*mol/kg/m*kg/m3 = mol/m2/s]
    trp_down[i]:=trp_up[i+1];
  end;
  //then, we calculate the concentration change in each cell if a) upward and downward transport go out
  //                                                            b) upward transport goes in
  //                                                            c) downward transport goes in
  for i:=0 to kmax_sed do
  begin
    change_a[i]:=0; change_b[i]:=0; change_c[i]:=0; 
  end;

  change_b[0]:=trp_up[1]/cellheights[kmax-1]/density_water;
  porosity:=1.0-forcing_vector_sed_inert_ratio[0];
  change_a[1]:=change_a[1]-trp_up[1]/cellheights_sed[0]/density_water/porosity;

  porosity:=1.0-forcing_vector_sed_inert_ratio[0];
  change_c[1]:=trp_down[0]/cellheights_sed[0]/density_water/porosity;
  change_a[0]:=change_a[0]-trp_down[0]/cellheights[kmax-1]/density_water;

  for i:=1 to kmax_sed-1 do
  begin
    porosity:=1.0-forcing_vector_sed_inert_ratio[i-1];
    change_b[i]:=trp_up[i+1]/cellheights_sed[i-1]/density_water/porosity;
    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    change_a[i+1]:=change_a[i+1]-trp_up[i+1]/cellheights_sed[i]/density_water/porosity;

    porosity:=1.0-forcing_vector_sed_inert_ratio[i];
    change_c[i+1]:=trp_down[i]/cellheights_sed[i]/density_water/porosity;
    porosity:=1.0-forcing_vector_sed_inert_ratio[i-1];
    change_a[i]:=change_a[i]-trp_down[i]/cellheights_sed[i-1]/density_water/porosity;
  end;
  change_a_max:=abs(change_a[0]);
  for i:=0 to kmax_sed do
    if abs(change_a[i])>change_a_max then change_a_max:=abs(change_a[i]);
  sed_basicdiff_porewater := 0.01/change_a_max; // basic diffusivity which, if applied for 1 second, moves 1% of the material away from the nearest cell [m2]  



  for i:=0 to kmax_sed do a[i]:=1.0+change_a[i]*sed_basicdiff_porewater;
  for i:=0 to kmax_sed-1 do b[i]:=change_b[i]*sed_basicdiff_porewater;
  for i:=0 to kmax_sed-1 do c[i]:=change_c[i+1]*sed_basicdiff_porewater;

  decomp_tridiag(a,c,b,sed_basicdiff_porewater_lhs,sed_basicdiff_porewater_rhs,sed_basicdiff_porewater_eig);

  for i:=0 to kmax_sed do a[i]:=a[i]-1.0;
  decomp_tridiag(a,c,b,sed_diffmat_porewater_lhs,sed_diffmat_porewater_rhs,sed_diffmat_porewater_eig);

{//correction: where there is no diffusivity, numerical diffusivity shall be avoided
//seek first cell with no diffusivity
  k:=kmax_sed+2;
  for i:=kmax_sed-1 downto 0 do
    if forcing_vector_sed_diffusivity_basic[i]<=110*basicdiff then k:=i+1;
//set eigenvalues to 1
  for i:=k to kmax_sed do
    sed_basicdiff_porewater_eig[i]:=1.0;
//set lhs and rhs submatrices to unity matrices
  for i:=k to kmax_sed do
    for j:=0 to kmax_sed do
    begin
      sed_basicdiff_porewater_rhs[i,j]:=0.0;
      sed_basicdiff_porewater_rhs[j,i]:=0.0;
      if i=j then sed_basicdiff_porewater_rhs[j,i]:=1.0;
      sed_basicdiff_porewater_lhs[i,j]:=0.0;
      sed_basicdiff_porewater_lhs[j,i]:=0.0;
      if i=j then sed_basicdiff_porewater_lhs[j,i]:=1.0;
    end;    }

  //BIOTURBATION OF SOLIDS
  //at first, we calculate the mass transports among the cells if molecular diffusivity is 1 m2/s
  //and concentration is 1 mol/m2 in one cell and 0 mol/m2 in the other cells [mol/m2/s]
  //therefore, we have to calculate a concentration in the solid part of the volume [mol/m3] for which we use a gradient
  //so, divide the 1 mol/m2 by cellheight and solid volume fraction
  trp_up[0]:=0.0;
  trp_down[kmax_sed]:=0.0;
  
  gradient:=1.0/fluffy_layer_thickness/cellheights_sed[0];
  effDiff:=forcing_vector_sed_diffusivity_basic[0]*forcing_vector_sed_inert_ratio[0];   //[m2/s]
  trp_down[0]:=effDiff*gradient; //[mol/m2/s]
  for i:=1 to kmax_sed-1 do
  begin
    gradient:=2.0/cellheights_sed[i-1]/forcing_vector_sed_inert_ratio[i-1]/(cellheights_sed[i-1]+cellheights_sed[i]);
    effDiff:=forcing_vector_sed_diffusivity_basic[i]*forcing_vector_sed_inert_ratio[i];   //[m2/s]
    trp_down[i]:=effDiff*gradient; //[mol/m2/s]
  end;

  gradient:=1.0/cellheights_sed[0]/forcing_vector_sed_inert_ratio[0]/cellheights_sed[0];
  effDiff:=forcing_vector_sed_diffusivity_basic[0]*forcing_vector_sed_inert_ratio[0];   //[m2/s]
  trp_up[1]:=effDiff*gradient; //[mol/m2/s]
  for i:=1 to kmax_sed-1 do
  begin
    gradient:=2.0/cellheights_sed[i]/forcing_vector_sed_inert_ratio[i]/(cellheights_sed[i-1]+cellheights_sed[i]);
    effDiff:=forcing_vector_sed_diffusivity_basic[i]*forcing_vector_sed_inert_ratio[i];   //[m2/s]
    trp_up[i+1]:=effDiff*gradient; //[mol/m2/s]
  end;
  //then, we calculate the concentration change in each cell if a) upward and downward transport go out
  //                                                            b) upward transport goes in
  //                                                            c) downward transport goes in
  //where we assume that the concentration is measured in [mol/m3] in the solid part of the volume, therefore we obtain [mol/m3/s]
  for i:=0 to kmax_sed do
  begin
    change_a[i]:=0; change_b[i]:=0; change_c[i]:=0; 
  end;

  change_b[0]:=trp_up[1];
  change_a[1]:=change_a[1]-trp_up[1];

  change_c[1]:=trp_down[0];
  change_a[0]:=change_a[0]-trp_down[0];

  for i:=1 to kmax_sed-1 do
  begin
    change_b[i]:=trp_up[i+1];
    change_a[i+1]:=change_a[i+1]-trp_up[i+1];

    change_c[i+1]:=trp_down[i];
    change_a[i]:=change_a[i]-trp_down[i];
  end;
  change_a_max:=abs(change_a[0]);
  for i:=0 to kmax_sed do
    if abs(change_a[i])>change_a_max then change_a_max:=abs(change_a[i]);
  sed_basicdiff_solids := 0.01/change_a_max; // basic diffusivity which, if applied for 1 second, moves 1% of the material away from the nearest cell [m2]  

  for i:=0 to kmax_sed do a[i]:=1.0+change_a[i]*sed_basicdiff_solids;
  for i:=0 to kmax_sed-1 do b[i]:=change_b[i]*sed_basicdiff_solids;
  for i:=0 to kmax_sed-1 do c[i]:=change_c[i+1]*sed_basicdiff_solids;

  decomp_tridiag(a,c,b,sed_basicdiff_solids_lhs,sed_basicdiff_solids_rhs,sed_basicdiff_solids_eig);
  for i:=0 to kmax_sed do a[i]:=a[i]-1.0;
  decomp_tridiag(a,c,b,sed_diffmat_solids_lhs,sed_diffmat_solids_rhs,sed_diffmat_solids_eig);

end;


procedure run_before;
var i: Integer;
    bioturb: DoubleArray1d;
begin
  disp('initialization');

  fill_ivlev_lookup_table;

  //get values for constants
  cgt_init_constants;

  //initialize the date
  current_date        :=start_date;
  current_output_date :=start_date;
  current_output_index:=1; // time index in output matrix
  if timestep_increment=1.0 then
  begin
    max_output_index    :=trunc(repeated_runs*(end_date-start_date)/output_interval)+1;
    setLength(time_axis,max_output_index);
    for i:=0 to max_output_index-1 do
      time_axis[i]:=i*output_interval+start_date;
  end
  else
  begin
    max_output_index:=2000;
    setLength(time_axis,max_output_index);
    for i:=0 to max_output_index-1 do
    try
      time_axis[i]:=timestep*(power(timestep_increment,i)-1)/(timestep_increment-1);
      if time_axis[i]>7.3e5 then time_axis[i]:=7.3e6+i;
    except
      time_axis[i]:=7.3e6+i;
    end;
  end;

  disp('  loading physical forcing');

  //load cell heights
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/cellheights.txt', cellheights); // cell heights [m]
  kmax := length(cellheights);             // number of vertical layers
  if fileExists(ExtractFilePath(application.exeName)+'physics/sed_cellheights.txt') then
  begin
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_cellheights.txt', cellheights_sed); // cell heights [m]
    kmax_sed := length(cellheights_sed);             // number of vertical layers
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_depth_bioturbation.txt', bioturb); // depths of bioturbation [m]
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_inert_ratio.txt',forcing_vector_sed_inert_ratio);  // fraction of sediment volume filled by inert solids [1]
  end
  else kmax_sed := 0;
  setLength(depths,kmax);

  setLength(depths_sed,kmax_sed);

  depths[0]:=cellheights[0];

  for i:=1 to length(cellheights)-1 do

    depths[i]:=depths[i-1]+cellheights[i];

  if kmax_sed>0 then

  begin

    depths_sed[0]:=cellheights_sed[0];

    for i:=1 to length(cellheights_sed)-1 do

      depths_sed[i]:=depths_sed[i-1]+cellheights_sed[i];

    //create vertical shape of diffusivity profile
    setLength(forcing_vector_sed_diffusivity_basic,kmax_sed);
    for i:=0 to kmax_sed-1 do
    begin
      if depths_sed[i]<=bioturb[0] then
        forcing_vector_sed_diffusivity_basic[i]:=1.0
      else if depths_sed[i]>=bioturb[2] then
        forcing_vector_sed_diffusivity_basic[i]:=1.0e-5
      else
        forcing_vector_sed_diffusivity_basic[i]:=max(1.0e-5,exp(-(depths_sed[i]-bioturb[0])/bioturb[1]));      
    end;
  end;
  fill_dz_arrays;
  if kmax_sed>0 then fill_dz_arrays_sed;  

  //calculate matrices for fast explicit diffusivity
  if kmax_sed>0 then calc_diffusivity_matrices;

  //load physics
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/temperature.txt',forcing_matrix_temperature);  // temperature [deg_C]
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/salinity.txt',forcing_matrix_salinity);     // salinity [g/kg]
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/light_at_top.txt',forcing_matrix_light_at_top); // downward flux of
                                                                 // shortwave light at sea surface [W/m2]
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/bottom_stress.txt',forcing_matrix_bottom_stress);// bottom stress [N/m2]
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/opacity_water.txt',forcing_matrix_opacity_water);// clear-water opacity [1/m]
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/diffusivity.txt',forcing_matrix_diffusivity);  // turbulent vertical diffusivity [m2/s]

  forcing_index_temperature := 1;
  forcing_index_salinity := 1;
  forcing_index_light_at_top := 1;
  forcing_index_bottom_stress := 1;
  forcing_index_opacity_water := 1;
  forcing_index_diffusivity := 1;

  //load constants with dependsOn=xyzt
<constants dependsOn=xyzt>
  loadMatlabMatrix(ExtractFilePath(application.exeName)+'init/'+trim('<name>')+'.txt',forcing_matrix_<name>);  // <description>
  forcing_index_<name> := 1;
</constants>

  if kmax_sed>0 then
  begin
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_diffusivity_porewater.txt',forcing_matrix_sed_diffusivity_porewater);  // vertical diffusivity for porewater [m2/s]    
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_diffusivity_solids.txt',forcing_matrix_sed_diffusivity_solids);  // vertical diffusivity for solids in sediment [m2/s] 
        loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_inert_deposition.txt',forcing_matrix_sed_inert_deposition);  // volume flux of deposition of inert solids [m/s]
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'physics/sed_grain_size.txt',forcing_matrix_sed_grain_size);  // median grain size of sediment particles [m] to calculate their sinking speed

    forcing_index_sed_diffusivity_porewater := 1;
    forcing_index_sed_diffusivity_solids := 1;
    forcing_index_sed_inert_deposition := 1;
    forcing_index_sed_grain_size := 1;

<constants dependsOn=xyzt>
    loadMatlabMatrix(ExtractFilePath(application.exeName)+'init/sed_'+trim('<name>')+'.txt',forcing_matrix_sed_<name>);  // <description>
    forcing_index_sed_<name> := 1;
</constants>

  end;

  disp('  loading biological initialization values');

  //load initial tracer concentrations
  cgt_init_tracers;
  if kmax_sed>0 then
    cgt_init_tracers_sed;

  // fill the output with zeros or NaNs
  cgt_init_output;
  if kmax_sed>0 then
    cgt_init_output_sed;

  setlength(output_vector_temperature,kmax); for i:=0 to kmax-1 do output_vector_temperature[i]:=0;
  setlength(output_vector_salinity,kmax);    for i:=0 to kmax-1 do output_vector_salinity[i]:=0;
  setlength(output_vector_opacity,kmax);     for i:=0 to kmax-1 do output_vector_opacity[i]:=0;
  setlength(output_vector_light,kmax);       for i:=0 to kmax-1 do output_vector_light[i]:=0;
  setlength(output_vector_diffusivity,kmax); for i:=0 to kmax-1 do output_vector_diffusivity[i]:=0;
  output_scalar_light_at_top  := 0.0;
  output_scalar_zenith_angle  := 0.0;
  output_scalar_bottom_stress := 0.0;

  if kmax_sed>0 then
  begin
    setLength(output_vector_sed_diffusivity_porewater,kmax_sed); for i:=0 to kmax_sed-1 do output_vector_sed_diffusivity_porewater[i]:=0;
    setLength(output_vector_sed_diffusivity_solids,kmax_sed); for i:=0 to kmax_sed-1 do output_vector_sed_diffusivity_solids[i]:=0;
    setLength(output_vector_sed_inert_ratio,kmax_sed); for i:=0 to kmax_sed-1 do output_vector_sed_inert_ratio[i]:=0;
    output_scalar_sed_inert_deposition:=0;
    output_scalar_sed_grain_size:=0;
  end;

  setLength(output_temperature   ,kmax,max_output_index);
  setLength(output_salinity      ,kmax,max_output_index);
  setLength(output_opacity       ,kmax,max_output_index);
  setLength(output_light         ,kmax,max_output_index);
  setLength(output_diffusivity   ,kmax,max_output_index);
  setLength(output_light_at_top  ,max_output_index);
  setLength(output_zenith_angle  ,max_output_index);
  setLength(output_bottom_stress ,max_output_index);
  if kmax_sed>0 then
  begin
    setLength(output_sed_diffusivity_porewater ,kmax_sed,max_output_index);
    setLength(output_sed_diffusivity_solids    ,kmax_sed,max_output_index);
    setLength(output_sed_inert_ratio           ,kmax_sed,max_output_index);
    setLength(output_sed_inert_deposition      ,max_output_index);
    setLength(output_sed_grain_size      ,max_output_index);
  end;

  output_count  := 0;

  setLength(forcing_vector_temperature,kmax);
  setLength(forcing_vector_salinity,kmax);
  setLength(forcing_vector_opacity_water,kmax);
  setLength(forcing_vector_opacity_bio,kmax);
  setLength(forcing_vector_opacity,kmax);
  setLength(forcing_vector_diffusivity,kmax);
  if kmax_sed>0 then
  begin
    setLength(forcing_vector_sed_diffusivity_porewater ,kmax_sed);
    setLength(forcing_vector_sed_diffusivity_solids    ,kmax_sed);
    setLength(forcing_vector_sed_diffusivity_basic    ,kmax_sed);
    setLength(forcing_vector_sed_inert_ratio           ,kmax_sed);
      end;
end;

procedure run_output;
var 
  k: Integer;
begin
// display current date/time
        disp('  '+DateTimeToStr(current_date));
        // do the output of physics
        for k:=1 to kmax do
        begin
            output_temperature[k-1,current_output_index-1] := output_vector_temperature[k-1] /output_count;
            output_salinity[k-1,current_output_index-1]    := output_vector_salinity[k-1]    /output_count;
            output_opacity[k-1,current_output_index-1]     := output_vector_opacity[k-1]     /output_count;
            output_light[k-1,current_output_index-1]       := output_vector_light[k-1]       /output_count;
            output_diffusivity[k-1,current_output_index-1] := output_vector_diffusivity[k-1] /output_count;
        end;
        output_light_at_top[current_output_index-1]  := output_scalar_light_at_top   /output_count;
        output_bottom_stress[current_output_index-1] := output_scalar_bottom_stress  /output_count;
        output_zenith_angle[current_output_index-1]  := output_scalar_zenith_angle   /output_count;
        // reset temporary physics output values
        for k:=1 to kmax do
        begin
          output_vector_temperature[k-1]   := 0;
          output_vector_salinity[k-1]      := 0;
          output_vector_opacity[k-1]       := 0;
          output_vector_light[k-1]         := 0;
          output_vector_diffusivity[k-1]   := 0;
        end;
        output_scalar_light_at_top  := 0.0;
        output_scalar_zenith_angle  := 0.0;
        output_scalar_bottom_stress := 0.0;
        if kmax_sed>0 then
        begin
          //do the output of physics in the sediment
          for k:=1 to kmax_sed do
          begin
              output_sed_diffusivity_porewater[k-1,current_output_index-1] := output_vector_sed_diffusivity_porewater[k-1] /output_count;
              output_sed_diffusivity_solids   [k-1,current_output_index-1] := output_vector_sed_diffusivity_solids   [k-1] /output_count;
              output_sed_inert_ratio          [k-1,current_output_index-1] := output_vector_sed_inert_ratio          [k-1] /output_count;
                        output_sed_inert_deposition[current_output_index-1]  := output_scalar_sed_inert_deposition   /output_count;
          output_sed_grain_size[current_output_index-1]  := output_scalar_sed_grain_size   /output_count;
          // reset temporary physics in sediment output values
          for k:=1 to kmax_sed do
          begin
            output_vector_sed_diffusivity_porewater[k-1]   := 0;
            output_vector_sed_diffusivity_solids   [k-1]   := 0;
            output_vector_sed_inert_ratio          [k-1]   := 0;
          end;
          output_scalar_sed_inert_deposition := 0.0;
          output_scalar_sed_grain_size := 0.0;
        end;
        //do the output of biology
        if current_output_index <= max_output_index then 
        begin
          cgt_output_final(current_output_index, output_count);
          if kmax_sed>0 then cgt_output_final_sed(current_output_index, output_count);
        end;
        //reset output indexes
        output_count  := 0;
        current_output_index := current_output_index + 1;
        current_output_date:=current_output_date+output_interval;
end;

procedure run_step(RungeKuttaDepth: Integer=1);
var i,k: Integer;
begin
// load the physics
    load_forcing(forcing_matrix_temperature,current_date,start_date,end_date, kmax, forcing_index_temperature, forcing_vector_temperature);
    load_forcing(forcing_matrix_salinity,current_date,start_date,end_date, kmax, forcing_index_salinity, forcing_vector_salinity);
    load_forcing(forcing_matrix_opacity_water,current_date,start_date,end_date, kmax, forcing_index_opacity_water, forcing_vector_opacity_water);
    load_forcing(forcing_matrix_diffusivity,current_date,start_date,end_date, kmax, forcing_index_diffusivity, forcing_vector_diffusivity);
    load_forcing(forcing_matrix_light_at_top,current_date,start_date,end_date, kmax, forcing_index_light_at_top, forcing_scalar_light_at_top);
    load_forcing(forcing_matrix_bottom_stress,current_date,start_date,end_date, kmax, forcing_index_bottom_stress, forcing_scalar_bottom_stress);
// load constants with dependsOn=xyzt
<constants dependsOn=xyzt>
    load_forcing(forcing_matrix_<name>,current_date,start_date,end_date,kmax,forcing_index_<name>,constant_vector_<name>);
</constants>
    if kmax_sed>0 then
    begin
      load_forcing(forcing_matrix_sed_diffusivity_porewater,current_date,start_date,end_date, kmax, forcing_index_sed_diffusivity_porewater, forcing_scalar_sed_diffusivity_porewater);
      for i:=0 to kmax_sed-1 do
        forcing_vector_sed_diffusivity_porewater[i]:=forcing_vector_sed_diffusivity_basic[i]*forcing_scalar_sed_diffusivity_porewater;
      load_forcing(forcing_matrix_sed_diffusivity_solids   ,current_date,start_date,end_date, kmax, forcing_index_sed_diffusivity_solids   , forcing_scalar_sed_diffusivity_solids   );
      for i:=0 to kmax_sed-1 do
        forcing_vector_sed_diffusivity_solids[i]:=forcing_vector_sed_diffusivity_basic[i]*forcing_scalar_sed_diffusivity_solids;
            load_forcing(forcing_matrix_sed_inert_deposition     ,current_date,start_date,end_date, kmax, forcing_index_sed_inert_deposition     , forcing_scalar_sed_inert_deposition     );
      load_forcing(forcing_matrix_sed_grain_size     ,current_date,start_date,end_date, kmax, forcing_index_sed_grain_size     , forcing_scalar_sed_grain_size     );
<constants dependsOn=xyzt>
      load_forcing(forcing_matrix_sed_<name>,current_date,start_date,end_date,kmax,forcing_index_sed_<name>,constant_vector_sed_<name>);
</constants>
    end;

    // light calculation
    sun_posi := sun_position(current_date,location);
    forcing_scalar_zenith_angle := sun_posi.zenith*pi/180;

    cgt_calc_opacity_bio(forcing_vector_opacity_bio);

    for i:=0 to kmax-1 do
      forcing_vector_opacity[i]   := forcing_vector_opacity_bio[i] + forcing_vector_opacity_water[i];
    setLength(forcing_vector_light,kmax);
    for i:=0 to kmax-1 do
      forcing_vector_light[i]:=0;
    if forcing_scalar_zenith_angle*180/pi < 90 then // daytime
    begin
      zenith_angle_under_water := arcsin(sin(forcing_scalar_zenith_angle*pi/180)/1.33);// consider refraction at sea surface
      forcing_vector_light[0]  := forcing_scalar_light_at_top;
      for k:=1 to kmax do
      begin
        light_path_length := cellheights[k-1]/cos(zenith_angle_under_water);
        if k<kmax then
        begin
          forcing_vector_light[k] := forcing_vector_light[k-1]*exp(-forcing_vector_opacity[k-1]*light_path_length);
          forcing_vector_light[k]   := forcing_vector_light[k-1]*exp(-forcing_vector_opacity[k-1]*light_path_length*0.5);
        end;
      end;
    end;

    // output of physics during this time step
    for i:=0 to kmax-1 do
    begin
      output_vector_temperature[i]   := output_vector_temperature[i]   + forcing_vector_temperature[i];
      output_vector_salinity[i]      := output_vector_salinity[i]      + forcing_vector_salinity[i];
      output_vector_opacity[i]       := output_vector_opacity[i]       + forcing_vector_opacity[i];
      output_vector_light[i]         := output_vector_light[i]         + forcing_vector_light[i];
      output_vector_diffusivity[i]   := output_vector_diffusivity[i]   + forcing_vector_diffusivity[i];
    end;
    output_scalar_light_at_top  := output_scalar_light_at_top  + forcing_scalar_light_at_top;
    output_scalar_zenith_angle  := output_scalar_zenith_angle  + forcing_scalar_zenith_angle;
    output_scalar_bottom_stress := output_scalar_bottom_stress + forcing_scalar_bottom_stress;
    if kmax_sed>0 then
    begin
      for i:=0 to kmax_sed-1 do
      begin
        output_vector_sed_diffusivity_porewater[i]   := output_vector_sed_diffusivity_porewater[i]+ forcing_vector_sed_diffusivity_porewater[i];
        output_vector_sed_diffusivity_solids[i]      := output_vector_sed_diffusivity_solids[i]   + forcing_vector_sed_diffusivity_solids[i];
        output_vector_sed_inert_ratio[i]             := output_vector_sed_inert_ratio[i]          + forcing_vector_sed_inert_ratio[i];
      end;
      output_scalar_sed_inert_deposition := output_scalar_sed_inert_deposition + forcing_scalar_sed_inert_deposition;
      output_scalar_sed_grain_size := output_scalar_sed_grain_size + forcing_scalar_sed_grain_size;
    end;
    output_count:=output_count+1;


    // do the biology including vertical migration / particle sinking
    if RungeKuttaDepth=1 then //positive Euler forward or positive Euler forward Patankar
      cgt_bio_timestep(false, false)
    else if RungeKuttaDepth=2 then // positive Runge Kutta or positive Runge Kutta Patankar
    begin
      //Step 1: save initial tracer values
      for i:=0 to kmax-1 do
      begin
<tracers vertLoc=WAT>
        tracer_vector_intermediate_<name>[i]:=tracer_vector_<name>[i];
</tracers>
      end;
<tracers vertLoc/=WAT>
      tracer_scalar_intermediate_<name>:=tracer_scalar_<name>;
</tracers>

      //Step 2: initialize saved process rates
      for i:=0 to kmax-1 do
      begin
<processes vertLoc=WAT>
        saved_rate_<name>[i]:=0.0;
</processes>
      end;
<processes vertLoc/=WAT>
      saved_rate_<name>:=0.0;
</processes>

      //Step 3: Do intermediate timestep
      cgt_bio_timestep(false,true);

      //Step 4: Calculate the patankar modification factors
      for i:=0 to kmax-1 do
      begin
<tracers vertLoc=WAT>
        patankar_modification_<name>[i]:=tracer_vector_intermediate_<name>[i]/max(tracer_vector_<name>[i],1.0e-30);
</tracers>
      end;
<tracers vertLoc/=WAT>
      patankar_modification_<name>:=tracer_scalar_intermediate_<name>/max(tracer_scalar_<name>,1.0e-30);
</tracers>

      //Step 5: Do another intermediate timestep to get the new process rates
      cgt_bio_timestep(false,true);

      //Step 6: calculate the average of the process rates
      for i:=0 to kmax-1 do
      begin
<processes vertLoc=WAT>
        saved_rate_<name>[i]:=saved_rate_<name>[i]/2.0;
</processes>
      end;
<processes vertLoc/=WAT>
      saved_rate_<name>:=saved_rate_<name>/2.0;
</processes>      
      
      //Step 7: Reload original tracer values
      for i:=0 to kmax-1 do
      begin
<tracers vertLoc=WAT>
        tracer_vector_<name>[i]:=tracer_vector_intermediate_<name>[i];
</tracers>
      end;
<tracers vertLoc/=WAT>
      tracer_scalar_<name>:=tracer_scalar_intermediate_<name>;
</tracers>

      //Step 8: Do the actual time step
      cgt_bio_timestep(true,false);

    end;

    // do the same for the sediment
    if kmax_sed>0 then
    begin
      if RungeKuttaDepth=1 then //positive Euler forward or positive Euler forward Patankar
        cgt_bio_timestep_sed(false,false)
      else if RungeKuttaDepth=2 then // positive Runge Kutta or positive Runge Kutta Patankar
      begin
        //Step 1: save initial tracer values
        for i:=0 to kmax_sed-1 do
        begin
  <tracers vertLoc=WAT; isInPorewater=1>
          tracer_vector_intermediate_sed_<name>[i]:=tracer_vector_sed_<name>[i];
  </tracers>
  <tracers vertLoc=SED>
          tracer_vector_intermediate_sed_<name>[i]:=tracer_vector_sed_<name>[i];
  </tracers>
        end;
  
        //Step 2: initialize saved process rates
        for i:=0 to kmax_sed-1 do
        begin
  <processes vertLoc=WAT; isInPorewater=1>
          saved_rate_sed_<name>[i]:=0.0;
  </processes>
  <processes vertLoc=SED; isInPorewater=1>
          saved_rate_sed_<name>[i]:=0.0;
  </processes>
        end;
  
        //Step 3: Do intermediate timestep
        cgt_bio_timestep_sed(false,true);
  
        //Step 4: Calculate the patankar modification factors
        for i:=0 to kmax_sed-1 do
        begin
  <tracers vertLoc=WAT; isInPorewater=1>
          patankar_modification_sed_<name>[i]:=tracer_vector_intermediate_sed_<name>[i]/max(tracer_vector_sed_<name>[i],1.0e-30);
  </tracers>
  <tracers vertLoc=SED>
          patankar_modification_sed_<name>[i]:=tracer_vector_intermediate_sed_<name>[i]/max(tracer_vector_sed_<name>[i],1.0e-30);
  </tracers>
        end;
  
        //Step 5: Do another intermediate timestep to get the new process rates
        cgt_bio_timestep_sed(false,true);
  
        //Step 6: calculate the average of the process rates
        for i:=0 to kmax_sed-1 do
        begin
  <processes vertLoc=WAT; isInPorewater=1>
          saved_rate_sed_<name>[i]:=saved_rate_sed_<name>[i]/2.0;
  </processes>
  <processes vertLoc=SED; isInPorewater=1>
          saved_rate_sed_<name>[i]:=saved_rate_sed_<name>[i]/2.0;
  </processes>
        end;
      
        //Step 7: Reload original tracer values
        for i:=0 to kmax_sed-1 do
        begin
  <tracers vertLoc=WAT; isInPorewater=1>
          tracer_vector_sed_<name>[i]:=tracer_vector_intermediate_sed_<name>[i];
  </tracers>
  <tracers vertLoc=SED>
          tracer_vector_sed_<name>[i]:=tracer_vector_intermediate_sed_<name>[i];
  </tracers>
        end;
  
        //Step 8: Do the actual time step
        cgt_bio_timestep_sed(true,false);
  
      end;
    end;

    if (current_date*(1.0+1.0e-10) >= current_output_date + output_interval) and (current_output_index <= max_output_index) then
      run_output;

    // do the vertical mixing
    cgt_mixing_timestep;
//    myviscosity:=output_scalar_viscosity/output_count;
    if kmax_sed>0 then 
    begin
      cgt_mixing_timestep_sed;
      cgt_sedimentation_timestep_sed;
    end;

    // update the current date/time
    current_date := current_date + timestep;
    timestep:=timestep*timestep_increment;
end;

procedure run_after;
begin
  disp('calculation ended, writing results to output file');
  disp('writing water model results');
  cgt_write_output_to_netcdf(false);
  if kmax_sed>0 then
  begin
    disp('writing sediment model results');
    cgt_write_output_to_netcdf_sed(false);
  end;
end;

procedure run(RungeKuttaDepth: Integer=1);
begin
  run_before;

  disp('starting the run');

  // do the timestep
  while current_date <= repeated_runs*(end_date-start_date)+start_date do
  begin
    run_step(RungeKuttaDepth);
    
    // check if output needs to be saved in final array
//    if (current_date*(1.0+1.0e-10) >= current_output_date + output_interval) and (current_output_index <= max_output_index) then
//      run_output;

  end;
  run_after;
  disp('done.');
end;

end.
