unit sun_pos;

interface

uses DateUtils, math;

type
  tLocation = record
    longitude: Double;
    latitude: Double;
    altitude: Double;
  end;
  tSunPosition = record
    zenith: Double;
    azimuth: Double;
  end;
  tJulianDate=record
    day: Double;
    ephemeris_day: Double;
    century: Double;
    ephemeris_century: Double;
    ephemeris_millenium: Double;
  end;
  TNutation = record
    longitude: Double;
    obliquity: Double;
  end;
  TTopocentricPosition = record
    rigth_ascension_parallax: Double;
    rigth_ascension: Double;
    declination: Double;
  end;

function sun_position(date: Real; location: tLocation):tSunPosition;

implementation

// sun = sun_position(time, location)
//
// This function compute the sun position (zenith and azimuth angle at the observer
// location) as a function of the observer local time and position.
// History
//   09/03/2004  Original creation by Vincent Roy (vincent.roy@drdc-rddc.gc.ca)
//   10/03/2004  Fixed a bug in julian_calculation subfunction (was
//               incorrect for year 1582 only), Vincent Roy
//   18/03/2004  Correction to the header (help display) only. No changes to
//               the code. (changed the «elevation» field in «location» structure
//               information to «altitude»), Vincent Roy
//   13/04/2004  Following a suggestion from Jody Klymak (jklymak@ucsd.edu),
//               allowed the 'time' input to be passed as a Matlab time string.
//   22/08/2005  Following a bug report from Bruce Bowler
//               (bbowler@bigelow.org), modified the julian_calculation function. Bug
//               was 'MATLAB has allowed structure assignment  to a non-empty non-structure
//               to overwrite the previous value.  This behavior will continue in this release,
//               but will be an error in a  future version of MATLAB.  For advice on how to
//               write code that  will both avoid this warning and work in future versions of
//               MATLAB,  see R14SP2 Release Notes'. Script should now be
//               compliant with futher release of Matlab...

function set_to_range(x, min_interval, max_interval: Double): Double;
begin
  result := x - max_interval * trunc(x/max_interval);
  if result<min_interval then
    result := result + max_interval;
end;

function topocentric_local_hour_calculate(observer_local_hour: Double; topocentric_sun_position: TTopocentricPosition):Double;
begin
  result := observer_local_hour - topocentric_sun_position.rigth_ascension_parallax;
end;

function sun_topocentric_zenith_angle_calculate(location: TLocation; topocentric_sun_position:TTopocentricPosition; topocentric_local_hour: Double):TSunPosition;
// This function compute the sun zenith angle, taking into account the
// atmospheric refraction. A default temperature of 283K and a
// default pressure of 1010 mbar are used.
var
  true_elevation, argument: Double;
  refraction_corr, apparent_elevation: Double;
  nominator, denominator: Double;
begin
// Topocentric elevation, without atmospheric refraction
  argument := (sin(location.latitude * pi/180) * sin(topocentric_sun_position.declination * pi/180)) +
    (cos(location.latitude * pi/180) * cos(topocentric_sun_position.declination * pi/180) * cos(topocentric_local_hour * pi/180));
  true_elevation := arcsin(argument) * 180/pi;

  // Atmospheric refraction correction (in degrees)
  argument := true_elevation + (10.3/(true_elevation + 5.11));
  refraction_corr := 1.02 / (60 * tan(argument * pi/180));
// For exact pressure and temperature correction, use this,
// with P the pressure in mbar amd T the temperature in Kelvins:
// refraction_corr = (P/1010) * (283/T) * 1.02 / (60 * tan(argument * pi/180));

// Apparent elevation
  if true_elevation > -5 then
    apparent_elevation := true_elevation + refraction_corr
  else
    apparent_elevation := true_elevation;

  result.zenith := 90 - apparent_elevation;

  nominator := sin(topocentric_local_hour * pi/180);
  denominator := (cos(topocentric_local_hour * pi/180) * sin(location.latitude * pi/180)) -
    (tan(topocentric_sun_position.declination * pi/180) * cos(location.latitude * pi/180));
  result.azimuth := (arctan2(nominator, denominator) * 180/pi) + 180;
  result.azimuth := set_to_range(result.azimuth, 0, 360);
end;

function topocentric_sun_position_calculate(earth_heliocentric_position, location: TLocation; observer_local_hour, sun_rigth_ascension, sun_geocentric_declination: Double): TTopocentricPosition;
var
  sun_rigth_ascension_parallax, eq_horizontal_parallax, u, x, y, nominator, denominator: Double;
begin
  eq_horizontal_parallax := 8.794 / (3600 * earth_heliocentric_position.altitude);
  u := arctan(0.99664719 * tan(location.latitude * pi/180));
  x := cos(u) + ((location.altitude/6378140) * cos(location.latitude * pi/180));
  y := (0.99664719 * sin(u)) + ((location.altitude/6378140) * sin(location.latitude * pi/180));
  nominator := -x * sin(eq_horizontal_parallax * pi/180) * sin(observer_local_hour * pi/180);
  denominator := cos(sun_geocentric_declination * pi/180) - (x * sin(eq_horizontal_parallax * pi/180) * cos(observer_local_hour * pi/180));
  sun_rigth_ascension_parallax := arctan2(nominator, denominator);
  result.rigth_ascension_parallax := sun_rigth_ascension_parallax * 180/pi;
  result.rigth_ascension := sun_rigth_ascension + (sun_rigth_ascension_parallax * 180/pi);
  nominator := (sin(sun_geocentric_declination * pi/180) - (y*sin(eq_horizontal_parallax * pi/180))) * cos(sun_rigth_ascension_parallax);
  denominator := cos(sun_geocentric_declination * pi/180) - (x*sin(eq_horizontal_parallax * pi/180)) * cos(observer_local_hour * pi/180);
  result.declination := arctan2(nominator, denominator) * 180/pi;
end;

function sun_rigth_ascension_calculation(apparent_sun_longitude, true_obliquity: Double; sun_geocentric_position: TLocation):Double;
var
  argument_numerator, argument_denominator: Double;
begin
  // This function compute the sun rigth ascension.
  argument_numerator := (sin(apparent_sun_longitude * pi/180) * cos(true_obliquity * pi/180)) -
    (tan(sun_geocentric_position.latitude * pi/180) * sin(true_obliquity * pi/180));
  argument_denominator := cos(apparent_sun_longitude * pi/180);
  result := arctan2(argument_numerator, argument_denominator) * 180/pi;
  // Limit the range to [0,360];
  result := set_to_range(result, 0, 360);
end;

function sun_geocentric_declination_calculation(apparent_sun_longitude, true_obliquity: Double; sun_geocentric_position: TLocation): Double;
var
  argument: Double;
begin
  argument := (sin(sun_geocentric_position.latitude * pi/180) * cos(true_obliquity * pi/180)) +
    (cos(sun_geocentric_position.latitude * pi/180) * sin(true_obliquity * pi/180) * sin(apparent_sun_longitude * pi/180));
  result := arcsin(argument) * 180/pi;
end;

function observer_local_hour_calculation(apparent_stime_at_greenwich: Double; location: TLocation; sun_rigth_ascension: Double): Double;
begin
  result := apparent_stime_at_greenwich + location.longitude - sun_rigth_ascension;
  result := set_to_range(result, 0, 360);
end;

function abberation_correction_calculation(earth_heliocentric_position: TLocation):Double;
begin
  result := -20.4898/(3600*earth_heliocentric_position.altitude);
end;


function apparent_sun_longitude_calculation(sun_geocentric_position: TLocation; nutation: TNutation; aberration_correction: Double): Double;
begin
  result := sun_geocentric_position.longitude + nutation.longitude + aberration_correction;
end;

function apparent_stime_at_greenwich_calculation(julian: TJulianDate; nutation: TNutation; true_obliquity: Double): Double;
// This function compute the apparent sideral time at Greenwich.
var
  jd, jc, mean_stime: Double;
begin
  JD := julian.day;
  JC := julian.century;
  mean_stime := 280.46061837 + (360.98564736629*(JD-2451545)) + (0.000387933*JC*JC) - (JC*JC*JC/38710000);
  mean_stime := set_to_range(mean_stime, 0, 360);
  result := mean_stime + (nutation.longitude * cos(true_obliquity * pi/180));
end;

function true_obliquity_calculation(julian: TJulianDate; nutation:TNutation):Real;
const
  p: Array[1..11] of Double =
(2.45,5.79,27.87,7.12,-39.05,-249.67,-51.38,1999.25,-1.55,-4680.93,84381.448);
var
  u,u2,u4: Double;
  mean_obliquity: Double;
begin
  U := julian.ephemeris_millenium/10;
  u2:=u*u;
  u4:=u2*u2;
  mean_obliquity := p[1]*u4*u4*u2 + p[2]*u4*u4*u + p[3]*u4*u4 + p[4]*u4*u2*u + p[5]*u4*u2 + p[6]*u4*u + p[7]*u4 + p[8]*u2*u + p[9]*u2 + p[10]*U + p[11];
  result := (mean_obliquity/3600) + nutation.obliquity;
end;

function nutation_calculation(julian:TJulianDate):TNutation;
// This function compute the nutation in longtitude and in obliquity, in
// degrees.
const
 p0: Array[1..4] of Double =
((1/189474),-0.0019142,445267.11148,297.85036);
 p1: Array[1..4] of Double =
(-(1/300000),-0.0001603,35999.05034,357.52772);
 p2: Array[1..4] of Double =
((1/56250),0.0086972,477198.867398,134.96298);
 p3: Array[1..4] of Double =
((1/327270),-0.0036825,483202.017538,93.27191);
 p4: Array[1..4] of Double =
((1/450000),0.0020708,-1934.136261,125.04452);
 Y_terms: Array[1..5*63] of Double =
(0,0,0,0,1
,-2,0,0,2,2
,0,0,0,2,2
,0,0,0,0,2
,0,1,0,0,0
,0,0,1,0,0
,-2,1,0,2,2
,0,0,0,2,1
,0,0,1,2,2
,-2,-1,0,2,2
,-2,0,1,0,0
,-2,0,0,2,1
,0,0,-1,2,2
,2,0,0,0,0
,0,0,1,0,1
,2,0,-1,2,2
,0,0,-1,0,1
,0,0,1,2,1
,-2,0,2,0,0
,0,0,-2,2,1
,2,0,0,2,2
,0,0,2,2,2
,0,0,2,0,0
,-2,0,1,2,2
,0,0,0,2,0
,-2,0,0,2,0
,0,0,-1,2,1
,0,2,0,0,0
,2,0,-1,0,1
,-2,2,0,2,2
,0,1,0,0,1
,-2,0,1,0,1
,0,-1,0,0,1
,0,0,2,-2,0
,2,0,-1,2,1
,2,0,1,2,2
,0,1,0,2,2
,-2,1,1,0,0
,0,-1,0,2,2
,2,0,0,2,1
,2,0,1,0,0
,-2,0,2,2,2
,-2,0,1,2,1
,2,0,-2,0,1
,2,0,0,0,1
,0,-1,1,0,0
,-2,-1,0,2,1
,-2,0,0,0,1
,0,0,2,2,1
,-2,0,2,0,1
,-2,1,0,2,1
,0,0,1,-2,0
,-1,0,1,0,0
,-2,1,0,0,0
,1,0,0,0,0
,0,0,1,2,0
,0,0,-2,2,2
,-1,-1,1,0,0
,0,1,1,0,0
,0,-1,1,2,2
,2,-1,-1,2,2
,0,0,3,2,2
,2,-1,0,2,2);
 nutation_terms: Array[1..4*63] of Double =
(-171996,-174.2,92025,8.9
,-13187,-1.6,5736,-3.1
,-2274,-0.2,977,-0.5
,2062,0.2,-895,0.5
,1426,-3.4,54,-0.1
,712,0.1,-7,0
,-517,1.2,224,-0.6
,-386,-0.4,200,0
,-301,0,129,-0.1
,217,-0.5,-95,0.3
,-158,0,0,0
,129,0.1,-70,0
,123,0,-53,0
,63,0,0,0
,63,0.1,-33,0
,-59,0,26,0
,-58,-0.1,32,0
,-51,0,27,0
,48,0,0,0
,46,0,-24,0
,-38,0,16,0
,-31,0,13,0
,29,0,0,0
,29,0,-12,0
,26,0,0,0
,-22,0,0,0
,21,0,-10,0
,17,-0.1,0,0
,16,0,-8,0
,-16,0.1,7,0
,-15,0,9,0
,-13,0,7,0
,-12,0,6,0
,11,0,0,0
,-10,0,5,0
,-8,0,3,0
,7,0,-3,0
,-7,0,0,0
,-7,0,3,0
,-7,0,3,0
,6,0,0,0
,6,0,-3,0
,6,0,-3,0
,-6,0,3,0
,-6,0,3,0
,5,0,0,0
,-5,0,3,0
,-5,0,3,0
,-5,0,3,0
,4,0,0,0
,4,0,0,0
,4,0,0,0
,-4,0,0,0
,-4,0,0,0
,-4,0,0,0
,3,0,0,0
,-3,0,0,0
,-3,0,0,0
,-3,0,0,0
,-3,0,0,0
,-3,0,0,0
,-3,0,0,0
,-3,0,0,0);

var
  JCE: Double;
  X0, X1, X2, X3, X4: Double;
  tabulated_argument, delta_longitude, delta_obliquity: Array[1..63] of Double;
  i: Integer;
begin
JCE := julian.ephemeris_century;

// 1. Mean elongation of the moon from the sun
X0 := p0[1] * JCE*JCE*JCE + p0[2] * JCE*JCE + p0[3] * JCE + p0[4];
// 2. Mean anomaly of the sun (earth)
X1 := p1[1] * JCE*JCE*JCE + p1[2] * JCE*JCE + p1[3] * JCE + p1[4];
// 3. Mean anomaly of the moon
X2 := p2[1] * JCE*JCE*JCE + p2[2] * JCE*JCE + p2[3] * JCE + p2[4];
// 4. Moon argument of latitude
X3 := p3[1] * JCE*JCE*JCE + p3[2] * JCE*JCE + p3[3] * JCE + p3[4];
// 5. Longitude of the ascending node of the moon's mean orbit on the
// ecliptic, measured from the mean equinox of the date
X4 := p4[1] * JCE*JCE*JCE + p4[2] * JCE*JCE + p4[3] * JCE + p4[4];

for i:=1 to 63 do
begin
  tabulated_argument[i]:=Y_terms[5*(i-1)+1]*X0
                        +Y_terms[5*(i-1)+2]*X1
                        +Y_terms[5*(i-1)+3]*X2
                        +Y_terms[5*(i-1)+4]*X3
                        +Y_terms[5*(i-1)+5]*X4;
  delta_longitude[i] := ((nutation_terms[4*(i-1)+1] + (nutation_terms[4*(i-1)+2] * JCE))) * sin(tabulated_argument[i]);
  delta_obliquity[i] := ((nutation_terms[4*(i-1)+3] + (nutation_terms[4*(i-1)+4] * JCE))) * cos(tabulated_argument[i]);
end;

// Nutation in longitude
  result.longitude := 0;
  for i:=1 to 63 do
    result.longitude := result.longitude + delta_longitude[i] / 36000000;

// Nutation in obliquity
  result.obliquity := 0;
  for i:=1 to 63 do
    result.obliquity := result.obliquity + delta_obliquity[i] / 36000000;
end;

function sun_geocentric_position_calculation(earth_heliocentric_position:TLocation):TLocation;
begin
  result.longitude := earth_heliocentric_position.longitude + 180;
  result.longitude := set_to_range(result.longitude, 0, 360);
  result.latitude := -earth_heliocentric_position.latitude;
  result.latitude := set_to_range(result.latitude, 0, 360);
end;


function earth_heliocentric_position_calculation(julian:TJulianDate):TLocation;
// This function compute the earth position relative to the sun, using
// tabulated values.
const
 L0_terms: Array[1..3*64] of Double =(175347046.0,0,0
,3341656.0,4.6692568,6283.07585
,34894.0,4.6261,12566.1517
,3497.0,2.7441,5753.3849
,3418.0,2.8289,3.5231
,3136.0,3.6277,77713.7715
,2676.0,4.4181,7860.4194
,2343.0,6.1352,3930.2097
,1324.0,0.7425,11506.7698
,1273.0,2.0371,529.691
,1199.0,1.1096,1577.3435
,990,5.233,5884.927
,902,2.045,26.298
,857,3.508,398.149
,780,1.179,5223.694
,753,2.533,5507.553
,505,4.583,18849.228
,492,4.205,775.523
,357,2.92,0.067
,317,5.849,11790.629
,284,1.899,796.298
,271,0.315,10977.079
,243,0.345,5486.778
,206,4.806,2544.314
,205,1.869,5573.143
,202,2.4458,6069.777
,156,0.833,213.299
,132,3.411,2942.463
,126,1.083,20.775
,115,0.645,0.98
,103,0.636,4694.003
,102,0.976,15720.839
,102,4.267,7.114
,99,6.21,2146.17
,98,0.68,155.42
,86,5.98,161000.69
,85,1.3,6275.96
,85,3.67,71430.7
,80,1.81,17260.15
,79,3.04,12036.46
,71,1.76,5088.63
,74,3.5,3154.69
,74,4.68,801.82
,70,0.83,9437.76
,62,3.98,8827.39
,61,1.82,7084.9
,57,2.78,6286.6
,56,4.39,14143.5
,56,3.47,6279.55
,52,0.19,12139.55
,52,1.33,1748.02
,51,0.28,5856.48
,49,0.49,1194.45
,41,5.37,8429.24
,41,2.4,19651.05
,39,6.17,10447.39
,37,6.04,10213.29
,37,2.57,1059.38
,36,1.71,2352.87
,36,1.78,6812.77
,33,0.59,17789.85
,30,0.44,83996.85
,30,2.74,1349.87
,25,3.16,4690.48);
L1_terms: Array[1..3*34] of Double =
(628331966747.0,0,0
,206059.0,2.678235,6283.07585
,4303.0,2.6351,12566.1517
,425.0,1.59,3.523
,119.0,5.796,26.298
,109.0,2.966,1577.344
,93,2.59,18849.23
,72,1.14,529.69
,68,1.87,398.15
,67,4.41,5507.55
,59,2.89,5223.69
,56,2.17,155.42
,45,0.4,796.3
,36,0.47,775.52
,29,2.65,7.11
,21,5.34,0.98
,19,1.85,5486.78
,19,4.97,213.3
,17,2.99,6275.96
,16,0.03,2544.31
,16,1.43,2146.17
,15,1.21,10977.08
,12,2.83,1748.02
,12,3.26,5088.63
,12,5.27,1194.45
,12,2.08,4694
,11,0.77,553.57
,10,1.3,3286.6
,10,4.24,1349.87
,9,2.7,242.73
,9,5.64,951.72
,8,5.3,2352.87
,6,2.65,9437.76
,6,4.67,4690.48);

L2_terms: Array[1..3*20] of Double =
(52919.0,0,0
,1720.0,1.0721,6283.0758
,309.0,0.867,12566.152
,27,0.05,3.52
,16,5.19,26.3
,16,3.68,155.42
,10,0.76,18849.23
,9,2.06,77713.77
,7,0.83,775.52
,5,4.66,1577.34
,4,1.03,7.11
,4,3.44,5573.14
,3,5.14,796.3
,3,6.05,5507.55
,3,1.19,242.73
,3,6.12,529.69
,3,0.31,398.15
,3,2.28,553.57
,2,4.38,5223.69
,2,3.75,0.98);

L3_terms: Array[1..3*7] of Double =
(289.0,5.844,6283.076
,35,0,0
,17,5.49,12566.15
,3,5.2,155.42
,1,4.72,3.52
,1,5.3,18849.23
,1,5.97,242.73);

L4_terms: Array[1..3*3] of Double =
(114.0,3.142,0
,8,4.13,6283.08
,1,3.84,12566.15);

L5_terms: Array[1..3] of Double =
(1,3.14,0);
B0_terms: Array[1..3*5] of Double =
(280.0,3.199,84334.662
,102.0,5.422,5507.553
,80,3.88,5223.69
,44,3.7,2352.87
,32,4,1577.34);
B1_terms: Array[1..3*2] of Double =
(9,3.9,5507.55
,6,1.73,5223.69);
R0_terms: Array[1..3*40] of Double =
(100013989.0,0,0
,1670700.0,3.0984635,6283.07585
,13956.0,3.05525,12566.1517
,3084.0,5.1985,77713.7715
,1628.0,1.1739,5753.3849
,1576.0,2.8469,7860.4194
,925.0,5.453,11506.77
,542.0,4.564,3930.21
,472.0,3.661,5884.927
,346.0,0.964,5507.553
,329.0,5.9,5223.694
,307.0,0.299,5573.143
,243.0,4.273,11790.629
,212.0,5.847,1577.344
,186.0,5.022,10977.079
,175.0,3.012,18849.228
,110.0,5.055,5486.778
,98,0.89,6069.78
,86,5.69,15720.84
,86,1.27,161000.69
,85,0.27,17260.15
,63,0.92,529.69
,57,2.01,83996.85
,56,5.24,71430.7
,49,3.25,2544.31
,47,2.58,775.52
,45,5.54,9437.76
,43,6.01,6275.96
,39,5.36,4694
,38,2.39,8827.39
,37,0.83,19651.05
,37,4.9,12139.55
,36,1.67,12036.46
,35,1.84,2942.46
,33,0.24,7084.9
,32,0.18,5088.63
,32,1.78,398.15
,28,1.21,6286.6
,28,1.9,6279.55
,26,4.59,10447.39);
R1_terms: Array[1..3*10] of Double =
(103019.0,1.10749,6283.07585
,1721.0,1.0644,12566.1517
,702.0,3.142,0
,32,1.02,18849.23
,31,2.84,5507.55
,25,1.32,5223.69
,18,1.42,1577.34
,10,5.91,10977.08
,9,1.42,6275.96
,9,0.27,5486.78);
R2_terms: Array[1..3*6] of Double =
(4359.0,5.7846,6283.0758
,124.0,5.579,12566.152
,12,3.14,0
,9,3.63,77713.77
,6,1.87,5573.14
,3,5.47,18849);
R3_terms: Array[1..3*2] of Double =
(145.0,4.273,6283.076
,7,3.92,12566.15);
R4_terms: Array[1..3*1] of Double =
(4,2.56,6283.08);
var
  A0, B0, C0: Array[1..64] of Double;
  A1, B1, C1: Array[1..34] of Double;
  A2, B2, C2: Array[1..20] of Double;
  A3, B3, C3: Array[1..7] of Double;
  A4, B4, C4: Array[1..3] of Double;
  A5, B5, C5: Array[1..1] of Double;
  i: Integer;
  JME: Double;
  L0, L1, L2, L3, L4, L5: Double;
begin
for i:=0 to length(A0)-1 do
begin
  A0[i+1] := L0_terms[i*3+1];
  B0[i+1] := L0_terms[i*3+2];
  C0[i+1] := L0_terms[i*3+3];
end;

for i:=0 to length(A1)-1 do
begin
  A1[i+1] := L1_terms[i*3+1];
  B1[i+1] := L1_terms[i*3+2];
  C1[i+1] := L1_terms[i*3+3];
end;

for i:=0 to length(A2)-1 do
begin
  A2[i+1] := L2_terms[i*3+1];
  B2[i+1] := L2_terms[i*3+2];
  C2[i+1] := L2_terms[i*3+3];
end;

for i:=0 to length(A3)-1 do
begin
  A3[i+1] := L3_terms[i*3+1];
  B3[i+1] := L3_terms[i*3+2];
  C3[i+1] := L3_terms[i*3+3];
end;

for i:=0 to length(A4)-1 do
begin
  A4[i+1] := L4_terms[i*3+1];
  B4[i+1] := L4_terms[i*3+2];
  C4[i+1] := L4_terms[i*3+3];
end;

for i:=0 to length(A5)-1 do
begin
  A5[i+1] := L5_terms[i*3+1];
  B5[i+1] := L5_terms[i*3+2];
  C5[i+1] := L5_terms[i*3+3];
end;

JME := julian.ephemeris_millenium;

// Compute the Earth Heliochentric longitude from the tabulated values.
L0:=0; L1:=0; L2:=0; L3:=0; L4:=0; L5:=0;
for i:=1 to length(A0) do
  L0 := L0 + (A0[i] * cos(B0[i] + (C0[i] * JME)));
for i:=1 to length(A1) do
  L1 := L1 + (A1[i] * cos(B1[i] + (C1[i] * JME)));
for i:=1 to length(A2) do
  L2 := L2 + (A2[i] * cos(B2[i] + (C2[i] * JME)));
for i:=1 to length(A3) do
  L3 := L3 + (A3[i] * cos(B3[i] + (C3[i] * JME)));
for i:=1 to length(A4) do
  L4 := L4 + (A4[i] * cos(B4[i] + (C4[i] * JME)));
for i:=1 to length(A5) do
  L5 := L5 + (A5[i] * cos(B5[i] + (C5[i] * JME)));

result.longitude := (L0 + (L1 * JME) + (L2 * JME*JME) + (L3 * JME*JME*JME) + (L4 * JME*JME*JME*JME) + (L5 * JME*JME*JME*JME*JME)) / 1e8;
// Convert the longitude to degrees.
result.longitude := result.longitude * 180/pi;
// Limit the range to [0,360[;
result.longitude := set_to_range(result.longitude,0,360);

// Tabulated values for the earth heliocentric latitude.
// B terms  from the original code.

for i:=1 to 5 do
begin
  A0[i] := B0_terms[i]*3+1;
  B0[i] := B0_terms[i]*3+2;
  C0[i] := B0_terms[i]*3+3;
end;

for i:=1 to 2 do
begin
  A1[i] := B1_terms[i]*3+1;
  B1[i] := B1_terms[i]*3+2;
  C1[i] := B1_terms[i]*3+3;
end;

L0:=0; L1:=0;
for i:=1 to 5 do
  L0 := L0 + (A0[i] * cos(B0[i] + (C0[i] * JME)));
for i:=1 to 2 do
  L1 := L1 + (A1[i] * cos(B1[i] + (C1[i] * JME)));

result.latitude := (L0 + (L1 * JME)) / 1e8;
// Convert the latitude to degrees.
result.latitude := result.latitude * 180/pi;
// Limit the range to [0,360];
result.latitude := set_to_range(result.latitude,0,360);

for i:=1 to 40 do
begin
  A0[i] := L0_terms[i]*3+1;
  B0[i] := L0_terms[i]*3+2;
  C0[i] := L0_terms[i]*3+3;
end;

for i:=1 to 10 do
begin
  A1[i] := L1_terms[i]*3+1;
  B1[i] := L1_terms[i]*3+2;
  C1[i] := L1_terms[i]*3+3;
end;

for i:=1 to 6 do
begin
  A2[i] := L2_terms[i]*3+1;
  B2[i] := L2_terms[i]*3+2;
  C2[i] := L2_terms[i]*3+3;
end;

for i:=1 to 2 do
begin
  A3[i] := L3_terms[i]*3+1;
  B3[i] := L3_terms[i]*3+2;
  C3[i] := L3_terms[i]*3+3;
end;

for i:=1 to 1 do
begin
  A4[i] := L4_terms[i]*3+1;
  B4[i] := L4_terms[i]*3+2;
  C4[i] := L4_terms[i]*3+3;
end;

L0:=0; L1:=0; L2:=0; L3:=0; L4:=0;
for i:=1 to 40 do
  L0 := L0 + (A0[i] * cos(B0[i] + (C0[i] * JME)));
for i:=1 to 10 do
  L1 := L1 + (A1[i] * cos(B1[i] + (C1[i] * JME)));
for i:=1 to 6 do
  L2 := L2 + (A2[i] * cos(B2[i] + (C2[i] * JME)));
for i:=1 to 2 do
  L3 := L3 + (A3[i] * cos(B3[i] + (C3[i] * JME)));
for i:=1 to 1 do
  L4 := L4 + (A4[i] * cos(B4[i] + (C4[i] * JME)));

result.altitude := (L0 + (L1 * JME) + (L2 * JME*JME) + (L3 * JME*JME*JME) + (L4 * JME*JME*JME*JME)) / 1e8;
end;

function julian_calculation(t_input:Double):TJulianDate;
// This function computes the julian day and julian century from the local time
var
  year,month,day,hour,minute,second,millisecond: Word;
  A, Y, M, B: Integer;
  D, delta_t, ut_time: Double;
begin
  DecodeDateTime(t_input,year,month,day,hour,minute,second,millisecond);

  if (month = 1) or (month = 2) then
  begin
    Y := year - 1;
    M := month + 12;
  end
  else
  begin
    Y := year;
    M := month;
  end;
  ut_time := (hour/24) + (minute/(60*24)) + ((second+millisecond/1000)/(60*60*24)); // time of day in UT time.
  D := day + ut_time; // Day of month in decimal time, ex. 2sd day of month at 12:30:30UT, D=2.521180556
  A:=0;

  // In 1582, the gregorian calendar was adopted
  if year = 1582 then
  begin
    if month = 10 then
    begin
        if day <= 4 then // The Julian calendar ended on October 4, 1582
            B := 0
        else if day >= 15 then // The Gregorian calendar started on October 15, 1582
        begin
            A := trunc(Y/100);
            B := 2 - A + trunc(A/4);
        end
        else
        begin
            //ShowMessage('This date never existed!. Date automatically set to October 4, 1582');
            month := 10;
            day := 4;
            B := 0;
        end;
    end
    else if month<10 then // Julian calendar
        B := 0
    else // Gregorian calendar
    begin
        A := trunc(Y/100);
        B := 2 - A + trunc(A/4);
    end;
  end
  else if(year<1582) then // Julian calendar
    B := 0
  else
  begin
    A := trunc(Y/100); // Gregorian calendar
    B := 2 + trunc(A/4) - A;
  end;

  result.day := trunc(365.25*(Y+4716)) + trunc(30.6001*(M+1)) + D + B - 1524.5;
  delta_t := 0; // 33.184;
  result.ephemeris_day := result.day + (delta_t/86400);
  result.century := (result.day - 2451545) / 36525;
  result.ephemeris_century := (result.ephemeris_day - 2451545) / 36525;
  result.ephemeris_millenium := result.ephemeris_century / 10;
end;

function sun_position(date: Real; location: tLocation):tSunPosition;
var
  julian: TJulianDate;
  earth_heliocentric_position: TLocation;
  sun_geocentric_position: TLocation;
  nutation: TNutation;
  true_obliquity: Double;
  aberration_correction: Double;
  apparent_sun_longitude: Double;
  apparent_stime_at_greenwich: Double;
  sun_rigth_ascension: Double;
  sun_geocentric_declination: Double;
  observer_local_hour: Double;
  topocentric_sun_position: TTopocentricPosition;
  topocentric_local_hour: Double;
  sun: TSunPosition;
begin
  julian := julian_calculation(date);
  earth_heliocentric_position := earth_heliocentric_position_calculation(julian);
  sun_geocentric_position := sun_geocentric_position_calculation(earth_heliocentric_position);
  nutation := nutation_calculation(julian);
  true_obliquity := true_obliquity_calculation(julian, nutation);
  aberration_correction := abberation_correction_calculation(earth_heliocentric_position);
  apparent_sun_longitude := apparent_sun_longitude_calculation(sun_geocentric_position, nutation, aberration_correction);
  apparent_stime_at_greenwich := apparent_stime_at_greenwich_calculation(julian, nutation, true_obliquity);
  sun_rigth_ascension := sun_rigth_ascension_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position);
  sun_geocentric_declination := sun_geocentric_declination_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position);
  observer_local_hour := observer_local_hour_calculation(apparent_stime_at_greenwich, location, sun_rigth_ascension);
  topocentric_sun_position := topocentric_sun_position_calculate(earth_heliocentric_position, location, observer_local_hour, sun_rigth_ascension, sun_geocentric_declination);
  topocentric_local_hour := topocentric_local_hour_calculate(observer_local_hour, topocentric_sun_position);
  sun := sun_topocentric_zenith_angle_calculate(location, topocentric_sun_position, topocentric_local_hour);

  result.zenith:=sun.zenith;
  result.azimuth:=sun.azimuth;
end;






end.
