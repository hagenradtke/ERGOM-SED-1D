unit NetCDFAnsi;

(*
These declarations facilitate the use of netCDF.dll with Delphi v 5.0
To use it, all you need is this file and netCDF.dll.  Put both of these
files into the same directory as your project and compile.  In any of your
units that call these functions add 'DelphiDeclarations' to your uses
clause.
After that, you should be able to call the routines in the straightforward
manner.

I created this file by taking the information in Appendix C - Summary of
C Interface of the NetCDF User's Guide for C, Version 3, June 1997, and
converting all the C function calls to pascal calls.

I have done very little testing.  The only functions I have tested are
nc_open, nc_strerror, nc_inq_libvers, nc_inq, nc_inq_dimid, nc_inq_varid,
nc_get_var_float and nc_close which are basically the ones you need to read
a netCDF file.  I have not tried to write a file using these calls.  I make
no
guarantees that any of this will work properly.

Good luck, hope it works for you.
Sandy Ballard
Sandia National Laboratories
Albuquerque, New Mexico, USA
sballar@sandia.gov
2/8/2001
*)

interface

const NC_MAXLEN=100;

type size_t = cardinal;
     ptrdiff_t = integer;
     nc_type = (NC_NAT,    { NAT = 'Not A Type' (c.f. NaN) }
                NC_BYTE,   { signed 1 byte integer }
                NC_AnsiChar,   { ISO/ASCII AnsiCharacter }
                NC_SHORT,  { signed 2 byte integer }
                NC_INT,    { signed 4 byte integer }
                NC_FLOAT,  { single precision floating point number }
                NC_DOUBLE); { double precision floating point number }


function nc_inq_libvers  : pAnsiChar; cdecl; external 'netcdf.DLL';
function nc_strerror (ncerr : integer) : pAnsiChar; cdecl; external 'netcdf.DLL';

function nc_create (path : pAnsiChar; cmode : integer; var ncidp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_open (path : pAnsiChar; mode : integer; var ncidp : integer) : integer; cdecl; external 'netcdf.DLL';
                                //0=read, 1=write

function nc_set_fill (ncid : integer; fillmode : integer; var old_modep : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_redef (ncid : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_enddef (ncid : integer) : integer; cdecl; external 'netcdf.DLL';

function nc_sync (ncid : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_abort (ncid : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_close (ncid : integer) : integer; cdecl; external 'netcdf.DLL';

function nc_inq (ncid : integer; var ndimsp : integer; var nvarsp : integer; var ngattsp : integer; var unlimdimidp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_ndims (ncid : integer; var ndimsp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_nvars (ncid : integer; var nvarsp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_natts (ncid : integer; var ngattsp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_unlimdim (ncid : integer; var unlimdimidp : integer) : integer; cdecl; external 'netcdf.DLL';

function nc_def_dim (ncid : integer; name : pAnsiChar; len : size_t; var idp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_dimid (ncid : integer; name : pAnsiChar; var idp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_dim (ncid : integer; dimid : integer; name : pAnsiChar; var lenp : size_t) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_dimname (ncid : integer; dimid : integer; name : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_dimlen (ncid : integer; dimid : integer; var lenp : size_t): integer; cdecl; external 'netcdf.DLL';
function nc_rename_dim (ncid : integer; dimid : integer; name : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';

function nc_def_var (ncid : integer; name : pAnsiChar; xtype : nc_type; ndims : integer; dimidsp : Pointer; var varidp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_var (ncid : integer; varid : integer; name : pAnsiChar; var xtypep : nc_type; var ndimsp : integer; var dimidsp : integer; var nattsp :integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_varid (ncid : integer; name : pAnsiChar; var varidp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_varname (ncid : integer; varid : integer; name : pAnsiChar) :  integer; cdecl; external 'netcdf.DLL';
function nc_inq_vartype (ncid : integer; varid : integer; var xtypep :  nc_type) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_varndims (ncid : integer; varid : integer; var ndimsp :integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_vardimid (ncid : integer; varid : integer; dimidsp : Pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_varnatts (ncid : integer; varid : integer; var nattsp :  integer) : integer; cdecl; external 'netcdf.DLL';
function nc_rename_var (ncid : integer; varid : integer; name : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';

function nc_put_var_text (ncid : integer; varid : integer; op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_text (ncid : integer; varid : integer; ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_uAnsiChar (ncid : integer; varid : integer; op : pointer) :integer; cdecl; external 'netcdf.DLL';
function nc_get_var_uAnsiChar (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_sAnsiChar (ncid : integer; varid : integer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_sAnsiChar (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_short (ncid : integer; varid : integer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_short (ncid : integer; varid : integer; ip : pointer) :integer; cdecl; external 'netcdf.DLL';
function nc_put_var_int (ncid : integer; varid : integer; op : pointer) :  integer; cdecl; external 'netcdf.DLL';
function nc_get_var_int (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_long (ncid : integer; varid : integer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_long (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_float (ncid : integer; varid : integer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_float (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var_double (ncid : integer; varid : integer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var_double (ncid : integer; varid : integer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';

function nc_put_var1_text (ncid : integer; varid : integer; var indexp : size_t; op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_text (ncid : integer; varid : integer; var indexp : size_t; ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_uAnsiChar (ncid : integer; varid : integer; var indexp :  size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_uAnsiChar (ncid : integer; varid : integer; var indexp :  size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_sAnsiChar (ncid : integer; varid : integer; var indexp :  size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_sAnsiChar (ncid : integer; varid : integer; var indexp :  size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_short (ncid : integer; varid : integer; var indexp :  size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_short (ncid : integer; varid : integer; var indexp :  size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_int (ncid : integer; varid : integer; var indexp :   size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_int (ncid : integer; varid : integer; var indexp :   size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_long (ncid : integer; varid : integer; var indexp :  size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_long (ncid : integer; varid : integer; var indexp :  size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_float (ncid : integer; varid : integer; var indexp : size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_float (ncid : integer; varid : integer; var indexp : Array of size_t; ip : Pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_var1_double(ncid : integer; varid : integer; var indexp : size_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_var1_double(ncid : integer; varid : integer; var indexp : size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';

function nc_put_vara_text (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vara_text (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vara_uAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_get_vara_uAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vara_sAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; op : pointer) : integer; cdecl; external  'netcdf.DLL';
function nc_get_vara_sAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vara_short (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; op : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_get_vara_short (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; ip : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_put_vara_int (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; op : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_get_vara_int (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; ip : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_put_vara_long (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; op : pointer) : integer; cdecl; external'netcdf.DLL';
function nc_get_vara_long (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vara_float (ncid : integer; varid : integer;  startp : pointer; countp : pointer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vara_float (ncid : integer; varid : integer;  startp : pointer; countp : pointer; ip : pointer) : integer; cdecl; external  'netcdf.DLL';
function nc_put_vara_double(ncid : integer; varid : integer; startp : pointer; countp : pointer; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vara_double(ncid : integer; varid : integer; startp : pointer; countp : pointer; ip : pointer) : integer; cdecl; external 'netcdf.DLL';

function nc_put_vars_text (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_text (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_uAnsiChar (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_uAnsiChar (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_sAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_sAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_short (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_short (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_int (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :  integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_int (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :  integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_long (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :  integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_long (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) :  integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_float (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_float (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_vars_double(ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; op : pointer) :integer; cdecl; external 'netcdf.DLL';
function nc_get_vars_double(ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; ip : pointer):integer; cdecl; external 'netcdf.DLL';

function nc_put_varm_text (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_text (ncid : integer; varid : integer; var startp : size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_uAnsiChar (ncid : integer; varid : integer; var startp :   size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_uAnsiChar (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_sAnsiChar (ncid : integer; varid : integer; var startp :size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_sAnsiChar (ncid : integer; varid : integer; var startp :   size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_short (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_short (ncid : integer; varid : integer; var startp :   size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t;ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_int (ncid : integer; varid : integer; var startp :    size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_int (ncid : integer; varid : integer; var startp :    size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_long (ncid : integer; varid : integer; var startp :   size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_long (ncid : integer; varid : integer; var startp :   size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_float (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_float (ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_varm_double(ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; op : pointer) : integer; cdecl; external 'netcdf.DLL';
function nc_get_varm_double(ncid : integer; varid : integer; var startp :  size_t; var countp : size_t; var stridep : ptrdiff_t; var imapp : ptrdiff_t; ip : pointer) : integer; cdecl; external 'netcdf.DLL';

function nc_inq_att (ncid : integer; varid : integer; name : pAnsiChar; var    xtypep : nc_type; var lenp : size_t) : integer; cdecl; external              'netcdf.DLL';
function nc_inq_attid (ncid : integer; varid : integer; name : pAnsiChar; var  idp : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_atttype (ncid : integer; varid : integer; name : pAnsiChar; var xtypep : nc_type) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_attlen (ncid : integer; varid : integer; name : pAnsiChar; var  lenp : size_t) : integer; cdecl; external 'netcdf.DLL';
function nc_inq_attname (ncid : integer; varid : integer; attnum : integer; name : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_copy_att (ncid_in : integer; varid_in : integer; name : pAnsiChar;  ncid_out : integer; varid_out : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_rename_att (ncid : integer; varid : integer; name : pAnsiChar; newname : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_del_att (ncid : integer; varid : integer; name : pAnsiChar) :  integer; cdecl; external 'netcdf.DLL';

function nc_put_att_text (ncid : integer; varid : integer; name : pAnsiChar; len: size_t; op : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_get_att_text (ncid : integer; varid : integer; name : pAnsiChar; ip : pAnsiChar) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_uAnsiChar (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; var op : byte) : integer; cdecl; external 'netcdf.DLL';
function nc_get_att_uAnsiChar (ncid : integer; varid : integer; name : pAnsiChar; var ip : byte) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_sAnsiChar (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; var op : shortint) : integer; cdecl; external  'netcdf.DLL';
function nc_get_att_sAnsiChar (ncid : integer; varid : integer; name : pAnsiChar; var ip : shortint) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_short (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; var op : smallint) : integer; cdecl; external  'netcdf.DLL';
function nc_get_att_short (ncid : integer; varid : integer; name : pAnsiChar; var ip : smallint) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_int (ncid : integer; varid : integer; name : pAnsiChar;   xtype : nc_type; len : size_t; var op : integer) : integer; cdecl; external   'netcdf.DLL';
function nc_get_att_int (ncid : integer; varid : integer; name : pAnsiChar; var ip : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_long (ncid : integer; varid : integer; name : pAnsiChar;  xtype : nc_type; len : size_t; var op : integer) : integer; cdecl; external   'netcdf.DLL';
function nc_get_att_long (ncid : integer; varid : integer; name : pAnsiChar; var ip : integer) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_float (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; var op : single) : integer; cdecl; external    'netcdf.DLL';
function nc_get_att_float (ncid : integer; varid : integer; name : pAnsiChar; var ip : single) : integer; cdecl; external 'netcdf.DLL';
function nc_put_att_double (ncid : integer; varid : integer; name : pAnsiChar; xtype : nc_type; len : size_t; var op : double) : integer; cdecl; external   'netcdf.DLL';
function nc_get_att_double (ncid : integer; varid : integer; name : pAnsiChar; var ip : double) : integer; cdecl; external 'netcdf.DLL';

//my own auxillary functions

function nc_typeAnsiString(nctype: nc_type):AnsiString;

type TAnsiCharArray = Array [0..nc_maxlen] of AnsiChar;
procedure InitAnsiCharArray(var CA: TAnsiCharArray);
function AnsiCharArrayToAnsiString(var CA: TAnsiCharArray; var s: AnsiString; n: Integer):Integer;
function AnsiStringToAnsiCharArray(var s: AnsiString; var CA: TAnsiCharArray): Integer;

//simple NetCDF access

const MaxAnsiStringLength=8000;

type
  TNetcdfAttribute = record
    att_type: AnsiString; //'Byte','AnsiChar','Short','Int','Single','Double'
    name: AnsiString;
    byte: Byte;
    ansichar: AnsiString;
    short: SmallInt;
    int: Integer;
    single: Single;
    double: Double;
  end;

  TAttributeArray = array of TNetcdfAttribute;

  singleArray1D = array of single;
  singleArray2D = array of singleArray1D;
  singleArray3D = array of singleArray2D;
  singleArray4D = array of singleArray3D;

  doubleArray1D = array of double;
  doubleArray2D = array of doubleArray1D;
  doubleArray3D = array of doubleArray2D;
  doubleArray4D = array of doubleArray3D;

procedure AssignValueToArray(val: Double; a: DoubleArray1d); overload;
procedure AssignValueToArray(val: Double; a: DoubleArray2d); overload;
procedure AssignValueToArray(val: Double; a: DoubleArray3d); overload;
procedure AssignValueToArray(val: Double; a: DoubleArray4d); overload;
procedure AssignValueToArray(val: Single; a: SingleArray1d); overload;
procedure AssignValueToArray(val: Single; a: SingleArray2d); overload;
procedure AssignValueToArray(val: Single; a: SingleArray3d); overload;
procedure AssignValueToArray(val: Single; a: SingleArray4d); overload;

function readnc_varnames(Filename: AnsiString; NumDims: Integer=-1; ContainedDims: AnsiString=''): AnsiString;
//returns variable names, ';'-separated, which have NumDims dimensions,
//including the ';'-seperated dimensions in ContainedDims

function readnc_dimnames(Filename: AnsiString; Varname: AnsiString):AnsiString;
//returns a ';'-separated list of dimension names, or '' if file or variable were not found

function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray1D; indexes: AnsiString=''):Integer; overload;
function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray2D; indexes: AnsiString=''):Integer; overload;
function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray3D; indexes: AnsiString=''):Integer; overload;
function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray4D; indexes: AnsiString=''):Integer; overload;

function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray1D; indexes: AnsiString=''):Integer; overload;
function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray2D; indexes: AnsiString=''):Integer; overload;
function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray3D; indexes: AnsiString=''):Integer; overload;
function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray4D; indexes: AnsiString=''):Integer; overload;
//result:  0=success
//        -1=number of specified dimensions incorrect
//        -2=additional dimensions found in file
//        -3=file does not exist
//        -4=error reading NetCDF file

function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray1D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;

function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray1D; indexes: AnsiString=''; isRecordDim: Boolean=false; defineOnly: Boolean=false):Integer; overload;
function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;

//result:  0=success
//        -1=number of specified dimensions incorrect
//        -2=some dimensions not found in file
//        -3=error creating NetCDF
//        -4=error reading NetCDF file

function readNC_attributes(filename: AnsiString; varname: AnsiString; var attArray: TAttributeArray):Integer;
function writeNC_attributes(filename: AnsiString; varname: AnsiString; attArray: TAttributeArray):Integer;
//result:  0=success
//        -1=file does not exist
//        -2=error opening file
//        -3=var does not exist


function writeNC_attribute(filename: AnsiString; varname: AnsiString; AttributeName: AnsiString; AttributeValue: AnsiString):Integer; overload;
function writeNC_attribute(filename: AnsiString; varname: AnsiString; AttributeName: AnsiString; AttributeValue: Double):Integer; overload;
//result:  0=success
//        -1=file does not exist
//        -2=error opening file
//        -3=var does not exist
//        -4=attribute does not exist

procedure keepNC_open_init;
function keepNC_open(filename: AnsiString; DefineMode: Boolean):Integer;
procedure enddefNC(filename: AnsiString);
procedure closeNC(filename: AnsiString);

implementation

uses SysUtils;

type
  tOpenNCFile = record
    filename: AnsiString;
    ncid: Integer;
    definemode: Boolean;
  end;

var OpenNCFiles: Array of TOpenNCFile;

procedure keepNC_open_init;
begin
  setLength(OpenNCFiles,0);
end;

function keepNC_open(filename: AnsiString; DefineMode: Boolean):Integer;
var
  i, ncid: Integer;
  found: Boolean;
begin
  result:=-100;
  found:=false;
  for i:=0 to length(OpenNCFiles)-1 do
    if OpenNCFiles[i].filename = filename then found:=true;
  if not found then
  begin
    result:=nc_open(pAnsiChar(filename),1,ncid);
    setLength(OpenNCFiles,length(OpenNCFiles)+1);
    OpenNCFiles[length(OpenNCFiles)-1].filename:=filename;
    OpenNCFiles[length(OpenNCFiles)-1].ncid:=ncid;
    OpenNCFiles[length(OpenNCFiles)-1].definemode:=definemode;
    if definemode then
      nc_redef(ncid);
  end;
end;

procedure enddefNC(filename:AnsiString);
var i, index: Integer;
begin
  index:=-1;
  for i:=0 to length(OpenNCFiles)-1 do
    if OpenNCFiles[i].filename = filename then index:=i;
  if index>=0 then
  begin
    nc_enddef(OpenNCFiles[index].ncid);
    OpenNCFiles[index].definemode:=false;
  end;
end;

procedure closeNC(filename:AnsiString);
var i, index: Integer;
begin
  index:=-1;
  for i:=0 to length(OpenNCFiles)-1 do
    if OpenNCFiles[i].filename = filename then index:=i;
  if index>=0 then
  begin
    nc_sync(OpenNCFiles[index].ncid);
    nc_close(OpenNCFiles[index].ncid);
    for i:=index to length(OpenNCFiles)-2 do
    begin
      OpenNCFiles[i].filename:=OpenNCFiles[i+1].filename;
      OpenNCFiles[i].ncid:=OpenNCFiles[i+1].ncid;
      OpenNCFiles[i].defineMode:=OpenNCFiles[i+1].defineMode;
    end;
    setLength(OpenNCFiles,length(OpenNCFiles)-1);
  end;
end;

function my_nc_open(path: PAnsiChar; mode:Integer; var ncidp: Integer):Integer;
var
  i: Integer;
  ncid: Integer;
begin
  ncidp:=-1;
  for i:=0 to length(OpenNCFiles)-1 do
    if path = openNCFiles[i].filename then
      ncidp:=openNCFiles[i].ncid;
  if ncidp>=0 then
    result:=0
  else
  begin
    result:=nc_open(path,mode,ncidp);
  end;
end;

function my_nc_sync(ncid: Integer): Integer;
var
  i: Integer;
  found: Boolean;
begin
  found:=false;
  for i:=0 to length(OpenNCFiles)-1 do
    if ncid = OpenNCFiles[i].ncid then
      found:=true;
  if found then
    result:=0
  else
    result:=nc_sync(ncid);
end;

function my_nc_close(ncid: Integer): Integer;
var
  i: Integer;
  found: Boolean;
begin
  found:=false;
  for i:=0 to length(OpenNCFiles)-1 do
    if ncid = OpenNCFiles[i].ncid then
      found:=true;
  if found then
    result:=0
  else
    result:=nc_close(ncid);
end;

function my_nc_redef(ncid: Integer): Integer;
var
  i: Integer;
  found: Boolean;
begin
  found:=false;
  for i:=0 to length(OpenNCFiles)-1 do
    if ncid = OpenNCFiles[i].ncid then
      if OpenNCFiles[i].definemode then
        found:=true;
  if found then
    result:=0
  else
    result:=nc_redef(ncid);
end;

function my_nc_enddef(ncid: Integer): Integer;
var
  i: Integer;
  found: Boolean;
begin
  found:=false;
  for i:=0 to length(OpenNCFiles)-1 do
    if ncid = OpenNCFiles[i].ncid then
      if OpenNCFiles[i].definemode then
        found:=true;
  if found then
    result:=0
  else
    result:=nc_enddef(ncid);
end;

function nc_typeAnsiString(nctype: nc_type):AnsiString;
begin
  result:='';
  if nctype=NC_NAT then Result:='NAT';
  if nctype=NC_BYTE then Result:='Byte';
  if nctype=NC_AnsiChar then Result:='AnsiChar';
  if nctype=NC_SHORT then Result:='Short';
  if nctype=NC_INT then Result:='Int';
  if nctype=NC_FLOAT then Result:='Single';
  if nctype=NC_DOUBLE then Result:='Double';
end;

procedure InitAnsiCharArray(var CA: TAnsiCharArray);
var i: Integer;
begin
  for i:=0 to nc_maxlen do
    ca[i]:=#0;
end;

function AnsiCharArrayToAnsiString(var CA: TAnsiCharArray; var s: AnsiString; n: Integer):Integer;
var i: Integer;
begin
  s:='';
  n:=nc_maxlen;
  for i:=0 to n-2 do
    if ca[i]<>#0 then
      s:=s+ca[i];
  result:=n;
end;

function AnsiStringToAnsiCharArray(var s: AnsiString; var CA: TAnsiCharArray): Integer;
var i,n: Integer;
begin
  n:=length(s);
  for i:=0 to length(s)-1 do
    ca[i]:=s[i+1];
  for i:=length(s) to nc_maxlen-1 do
    ca[i]:=#0;
  result:=n;
end;

procedure AssignValueToArray(val: Double; a: DoubleArray1d); overload;
var i: Integer;
begin
  for i:=0 to length(a)-1 do
    a[i]:=val;
end;
procedure AssignValueToArray(val: Single; a: SingleArray1d); overload;
var i: Integer;
begin
  for i:=0 to length(a)-1 do
    a[i]:=val;
end;
procedure AssignValueToArray(val: Double; a: DoubleArray2d); overload;
var i, j: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      a[i,j]:=val;
end;
procedure AssignValueToArray(val: Single; a: SingleArray2d); overload;
var i, j: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      a[i,j]:=val;
end;
procedure AssignValueToArray(val: Double; a: DoubleArray3d); overload;
var i, j, k: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      for k:=0 to length(a[i,j])-1 do
        a[i,j,k]:=val;
end;
procedure AssignValueToArray(val: Single; a: SingleArray3d); overload;
var i, j, k: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      for k:=0 to length(a[i,j])-1 do
        a[i,j,k]:=val;
end;
procedure AssignValueToArray(val: Double; a: DoubleArray4d); overload;
var i, j, k, l: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      for k:=0 to length(a[i,j])-1 do
        for l:=0 to length(a[i,j,k])-1 do
          a[i,j,k,l]:=val;
end;
procedure AssignValueToArray(val: Single; a: SingleArray4d); overload;
var i, j, k, l: Integer;
begin
  for i:=0 to length(a)-1 do
    for j:=0 to length(a[i])-1 do
      for k:=0 to length(a[i,j])-1 do
        for l:=0 to length(a[i,j,k])-1 do
          a[i,j,k,l]:=val;
end;

//************* SIMPLE NETCDF ACCESS *****************************************//

function FillBuffer(val:AnsiChar;Buf:pAnsiChar;Count:Integer):Integer;
var i: Integer;
begin
  for i:=0 to count-1 do
    buf[i]:=val;
  result:=0;
end;

function SemiItem(var s: AnsiString):AnsiString;
begin
  if pos(';',s)>0 then
  begin
    result:=copy(s,1,pos(';',s)-1);
    s:=copy(s,pos(';',s)+1,length(s));
  end
  else
  begin
    result:=s;
    s:='';
  end;
end;

//************* reading single variables *************************************//

function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray1D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=1;
var
  f: Integer;
  i: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]]);
      for i:=0 to countidx[newdims[0]]-1 do
        a[i]:=tempArray[diminc[newdims[0]]*i];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray2D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=2;
var
  f: Integer;
  i, j: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          a[i,j]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray3D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=3;
var
  f: Integer;
  i, j, k: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]],countidx[newdims[2]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            a[i,j,k]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_single(filename: AnsiString; varname: AnsiString; var a: singleArray4D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=4;
var
  f: Integer;
  i, j, k, l: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(a,0);
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]],countidx[newdims[2]],countidx[newdims[3]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            for l:=0 to countidx[newdims[3]]-1 do
              a[i,j,k,l]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k+diminc[newdims[3]]*l];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
 setLength(TempArray,0);
end;

//************* reading double variables *************************************//

function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray1D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=1;
var
  f: Integer;
  i: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]]);
      for i:=0 to countidx[newdims[0]]-1 do
        a[i]:=tempArray[diminc[newdims[0]]*i];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray2D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=2;
var
  f: Integer;
  i, j: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          a[i,j]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray3D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=3;
var
  f: Integer;
  i, j, k: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]],countidx[newdims[2]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            a[i,j,k]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

function readNC_double(filename: AnsiString; varname: AnsiString; var a: doubleArray4D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=4;
var
  f: Integer;
  i, j, k, l: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin reading
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      nc_get_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place read values into the output array
      setLength(a,countidx[newdims[0]],countidx[newdims[1]],countidx[newdims[2]],countidx[newdims[3]]);
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            for l:=0 to countidx[newdims[3]]-1 do
              a[i,j,k,l]:=tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k+diminc[newdims[3]]*l];
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_close(f);
 end;
end;

//****************** write to existing variable - single *********************//

function writeNC_single_varexists(filename: AnsiString; varname: AnsiString; a: singleArray1D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=1;
var
  f: Integer;
  i: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        tempArray[diminc[newdims[0]]*i]:=a[i];
      nc_put_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
 setLength(tempArray,0);
end;

function writeNC_single_varexists(filename: AnsiString; varname: AnsiString; a: singleArray2D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=2;
var
  f: Integer;
  i, j: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j]:=a[i,j];
      nc_put_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

function writeNC_single_varexists(filename: AnsiString; varname: AnsiString; a: singleArray3D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=3;
var
  f: Integer;
  i, j, k: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k]:=a[i,j,k];
      nc_put_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

function writeNC_single_varexists(filename: AnsiString; varname: AnsiString; a: singleArray4D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=4;
var
  f: Integer;
  i, j, k, l: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of Single;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a single index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            for l:=0 to countidx[newdims[3]]-1 do
              tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k+diminc[newdims[3]]*l]:=a[i,j,k,l];
      nc_put_vara_float(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

//********* write to existing file *******************************************//

function writeNC_single_fileexists(filename: AnsiString; varname: AnsiString; a: singleArray1D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_single_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis
      my_nc_redef(F);
      nc_def_dim(F,pAnsiChar(varname),length(a),axisid);
      axisid_t:=axisid;
      nc_def_var(F,pAnsiChar(varname),nc_float,1,@axisid_t,varid);
      my_nc_enddef(F);
      setLength(startidx,1);
      setLength(countidx,1);
      startidx[0]:=0;
      countidx[0]:=length(a);
      nc_put_vara_float(f,varid,@startidx[0],@countidx[0],@a[0]);
      my_nc_sync(F);
      my_nc_close(F);
      result:=0;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_float,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_single_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_single_fileexists(filename: AnsiString; varname: AnsiString; a: singleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_single_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_float,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_single_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_single_fileexists(filename: AnsiString; varname: AnsiString; a: singleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_single_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_float,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_single_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_single_fileexists(filename: AnsiString; varname: AnsiString; a: singleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_single_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_float,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_single_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

//********* writing to NetCDF ************************************************//

function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray1D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_single_fileexists(filename,varname,a,indexes,defineOnly);
end;

function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_single_fileexists(filename,varname,a,indexes,defineOnly);
end;

function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_single_fileexists(filename,varname,a,indexes,defineOnly);
end;

function writeNC_single(filename: AnsiString; varname: AnsiString; a: singleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_single_fileexists(filename,varname,a,indexes,defineOnly);
end;

//****************** write to existing variable - double *********************//

function writeNC_double_varexists(filename: AnsiString; varname: AnsiString; a: doubleArray1D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=1;
var
  f: Integer;
  i: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a double index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        tempArray[diminc[newdims[0]]*i]:=a[i];
      nc_put_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

function writeNC_double_varexists(filename: AnsiString; varname: AnsiString; a: doubleArray2D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=2;
var
  f: Integer;
  i, j: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a double index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j]:=a[i,j];
      nc_put_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

function writeNC_double_varexists(filename: AnsiString; varname: AnsiString; a: doubleArray3D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=3;
var
  f: Integer;
  i, j, k: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a double index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k]:=a[i,j,k];
      nc_put_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

function writeNC_double_varexists(filename: AnsiString; varname: AnsiString; a: doubleArray4D; indexes: AnsiString=''):Integer; overload;
const
  ArrayDim=4;
var
  f: Integer;
  i, j, k, l: Integer;
  varmax, varid, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims, newdims: Array of Integer;
  diminc: Array of Integer;
  dimlen: Array of cardinal;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex, myrange: AnsiString;
  foundMoreDims: Boolean;
  tempArray: Array of double;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  //obtain grid information
  nc_inq_varndims(f,varid,dimmax);
  setLength(dims,dimmax);
  setLength(dimlen,dimmax);
  setLength(dimname,dimmax);
  setLength(startidx,dimmax);
  setLength(countidx,dimmax);
  nc_inq_vardimid(f,varid,@dims[0]);
  for d:=0 to dimmax-1 do
  begin
    nc_inq_dimlen(f,dims[d],dimlen[d]);
    startidx[d]:=0;
    countidx[d]:=dimlen[d];
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_dimname(f,dims[d],s);
    dimname[d]:=trim(lowercase(s));
  end;
  //shrink the grid according to the choice in indexes
  nd:=-1;
  setlength(newdims,0);
  myindexes:=indexes;
  while length(myindexes)>0 do
  begin
    nd:=nd+1;
    setlength(newdims,nd+1);
    myindex:=SemiItem(myindexes);
    if pos('=',myindex)>0 then
    begin
      myrange:=copy(myindex,pos('=',myindex)+1,length(myindex));
      myindex:=copy(myindex,1,pos('=',myindex)-1);
      if pos(':',myrange)>0 then  // a range is selected
      begin
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(copy(myrange,1,pos(':',myrange)-1))-1;
            countidx[d]:=StrToInt(copy(myrange,pos(':',myrange)+1,length(myrange)))-1;
            countidx[d]:=countidx[d]-startidx[d]+1;
            newdims[nd]:=d;
          end;
      end
      else                        // a double index is selected
      begin
        nd:=nd-1;  //dimension does not appear in the new array
        setlength(newdims,nd+1);
        for d:=0 to dimmax-1 do
          if dimname[d]=trim(lowercase(myindex)) then
          begin
            startidx[d]:=StrToInt(myrange)-1;
            countidx[d]:=1;
          end;
      end;
    end
    else                          // the whole variable is selected
    begin
      for d:=0 to dimmax-1 do
        if dimname[d]=trim(lowercase(myindex)) then
          newdims[nd]:=d;
    end;
  end;
  //if no indexes are specified, use those in the netCDF file
  if indexes='' then
  begin
    setLength(newdims,dimmax);
    for nd:=0 to dimmax-1 do
      newdims[nd]:=nd;
  end;
  if length(newdims)=ArrayDim then // number of new dimensions is correct
  begin
    //search for dimensions of length >1 that have not become new dimensions
    foundMoreDims:=false;
    d:=0;
    while (foundMoreDims=false) and (d<dimmax) do
    begin
      if countidx[d]>1 then
      begin
        foundMoreDims:=true;
        for nd:=0 to length(newdims)-1 do
          if newdims[nd]=d then foundMoreDims:=false;
      end;
      d:=d+1;
    end;
    if foundMoreDims then
      result:=-2
    else
    begin //dimensions are correct, begin placing data in tempArray
      setLength(tempArray,1);
      for d:=0 to dimmax-1 do
        setLength(tempArray,length(tempArray)*countidx[d]);
      //calculate axis-specific increments to locate values in tempArray
      setLength(diminc,dimmax);
      diminc[dimmax-1]:=1;
      for d:=dimmax-2 downto 0 do
        diminc[d]:=diminc[d+1]*countidx[d+1];
      //now place values into the output array
      for i:=0 to countidx[newdims[0]]-1 do
        for j:=0 to countidx[newdims[1]]-1 do
          for k:=0 to countidx[newdims[2]]-1 do
            for l:=0 to countidx[newdims[3]]-1 do
              tempArray[diminc[newdims[0]]*i+diminc[newdims[1]]*j+diminc[newdims[2]]*k+diminc[newdims[3]]*l]:=a[i,j,k,l];
      nc_put_vara_double(f,varid,@startidx[0],@countidx[0],@temparray[0]);
      result:=0;
    end;
  end
  else                             // number of new dimensions is incorrect
    result:=-1;
  my_nc_sync(f);
  my_nc_close(f);
 end;
end;

//********* write to existing file *******************************************//

function writeNC_double_fileexists(filename: AnsiString; varname: AnsiString; a: doubleArray1D; indexes: AnsiString=''; isRecordDim: Boolean=false; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_double_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis
      my_nc_redef(F);
      if isRecordDim then //this is the record dimension
        nc_def_dim(F,pAnsiChar(varname),0,axisid)
      else
        nc_def_dim(F,pAnsiChar(varname),length(a),axisid);
      axisid_t:=axisid;
      nc_def_var(F,pAnsiChar(varname),nc_double,1,@axisid_t,varid);
      my_nc_enddef(F);
      if defineOnly=false then
      begin
        setLength(startidx,1);
        setLength(countidx,1);
        startidx[0]:=0;
        countidx[0]:=length(a);
        nc_put_vara_double(f,varid,@startidx[0],@countidx[0],@a[0]);
        my_nc_sync(F);
      end;
      my_nc_close(F);
      result:=0;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_double,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_double_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_double_fileexists(filename: AnsiString; varname: AnsiString; a: doubleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_double_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_double,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_double_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_double_fileexists(filename: AnsiString; varname: AnsiString; a: doubleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_double_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_double,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_double_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

function writeNC_double_fileexists(filename: AnsiString; varname: AnsiString; a: doubleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
  axisid_t: Size_T;
  axisid: integer;
  varmax, v, varid: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of size_t;
  dimname: Array of AnsiString;
  startidx, countidx: Array of size_t;
  myindexes, myindex: AnsiString;
  foundMoreDims: Boolean;
begin
 if fileExists(filename)=false then
  result:=-3
 else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
  result:=-4
 else
 begin
  //try to find variable
  nc_inq_nvars(f, varmax);
  varid:=-1;
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    if trim(lowercase(s))=trim(lowercase(varname)) then
      varid:=v;
  end;
  if varid <> -1 then
  begin
    my_nc_close(F);
    if defineOnly=false then
      result:=writeNC_double_varexists(filename, varname, a, indexes);
  end
  else
  begin     //variable does not exist yet
    if (indexes='') or (trim(lowercase(indexes))=trim(lowercase(varname))) then
    begin   //this variable is meant to be an axis? But it is multi-dimensional!
      my_nc_close(F);
      result:=-1;
    end
    else
    begin   //this is not an axis
      //check if all axes specified in indexes exist
      nc_inq_ndims(f,dimmax);
      d:=-1;
      setlength(dims,0); setlength(dimname,0);
      myindexes:=indexes;
      foundMoreDims:=false;
      while (length(myindexes)>0) and (foundMoreDims=false) do
      begin
        d:=d+1;
        setlength(dims,d+1); setlength(dimname,d+1);
        myindex:=SemiItem(myindexes);
        if pos('=',myindex)>0 then
          myindex:=copy(myindex,1,pos('=',myindex)-1);
        dimname[d]:=trim(myindex);
        foundMoreDims:=true;
        for nd:=0 to dimmax-1 do
        begin
          nc_inq_dimname(F,nd,s);
          if trim(lowercase(s))=trim(lowercase(dimname[d])) then
          begin
            dims[d]:=nd;
            foundMoreDims:=false;
          end;
        end;
      end;
      if foundMoreDims=false then
      begin
        my_nc_redef(F);
        nc_def_var(F,pAnsiChar(varname),nc_double,length(dims),@dims[0],varid);
        my_nc_enddef(F);
        my_nc_close(F);
        if defineOnly=false then
          result:=writeNC_double_varexists(filename, varname, a, indexes);
      end
      else //dimensions are specified that do not exist in the file
      begin
        my_nc_close(F);
        result:=-2;
      end;
    end;
  end;
 end;
end;

//********* writing to NetCDF ************************************************//

function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray1D; indexes: AnsiString=''; isRecordDim: Boolean=false; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_double_fileexists(filename,varname,a,indexes,isRecordDim,defineOnly);
end;

function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray2D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_double_fileexists(filename,varname,a,indexes,defineOnly);
end;

function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray3D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_double_fileexists(filename,varname,a,indexes,defineOnly);
end;

function writeNC_double(filename: AnsiString; varname: AnsiString; a: doubleArray4D; indexes: AnsiString=''; defineOnly: Boolean=false):Integer; overload;
var
  f: Integer;
begin
  if fileExists(filename)=false then
  begin
    nc_create(pAnsiChar(filename),0,F);
    my_nc_close(F);
  end;
  result:=writenc_double_fileexists(filename,varname,a,indexes,defineOnly);
end;

//**************** seeking functions *****************************************//

function readnc_varnames(Filename: AnsiString; NumDims: Integer=-1; ContainedDims: AnsiString=''): AnsiString;
var
  f: Integer;
  varmax, v: Integer;
  dimmax, d, nd: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  dims: Array of Integer;
  dimname: AnsiString;
  seekedNames: Array of AnsiString;
  foundNames: Array of Boolean;
  myAnsiString: AnsiString;
  varSeeked: Boolean;
  varname: AnsiString;
begin
  result:='';
  my_nc_open(pAnsiChar(filename),0,f);
  //prepare seeking information
  myAnsiString:=ContainedDims;
  setLength(seekedNames,0);
  while not (length(myAnsiString)=0) do
  begin
    setLength(seekedNames, length(seekedNames)+1);
    seekedNames[length(seekedNames)-1]:=trim(lowercase(SemiItem(myAnsiString)));
  end;
  setLength(foundNames,length(seekedNames));
  //scan variables
  nc_inq_nvars(f, varmax);
  for v:=0 to varmax-1 do
  begin
    FillBuffer(chr(0), s, SizeOf(s));
    nc_inq_varname(f,v,s);
    varname:=trim(lowercase(s));
    //init dimension seeking
    for nd:=0 to length(seekedNames)-1 do
      foundNames[nd]:=false;
    //check if number of dimensions is correct
    nc_inq_varndims(f,v,dimmax);
    if (dimmax=NumDims) or (NumDims=-1) then
    begin
      //seek contained dimensions
      setLength(dims,dimmax);
      nc_inq_vardimid(f,v,@dims[0]);
      for d:=0 to dimmax-1 do
      begin
        FillBuffer(chr(0), s, SizeOf(s));
        nc_inq_dimname(f,dims[d],s);
        dimname:=trim(lowercase(s));
        for nd:=0 to length(seekedNames)-1 do
          if dimname=seekedNames[nd] then foundNames[nd]:=true;
      end;
      varSeeked:=true;
      for nd:=0 to length(seekedNames)-1 do
        if foundNames[nd]=false then varSeeked:=false;
      if varSeeked=true then
      begin
        if result='' then result:=varname
        else result:=result+';'+varname;
      end;
    end;
  end;

  my_nc_close(f);
end;

function readnc_dimnames(filename: AnsiString; varname: AnsiString):AnsiString;
var
  f: Integer;
  v, varid, varmax: Integer;
  d, ndims: Integer;
  dims: Array of Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
  Dimname: AnsiString;
begin
  if fileExists(filename)=false then
    result:=''
  else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
    result:=''
  else
  begin
    //find variable
    nc_inq_nvars(f, varmax);
    varid:=-1;
    for v:=0 to varmax-1 do
    begin
      FillBuffer(chr(0), s, SizeOf(s));
      nc_inq_varname(f,v,s);
      if trim(lowercase(s))=trim(lowercase(varname)) then
        varid:=v;
    end;
    if varid=-1 then
      result:=''
    else
    begin
      nc_inq_varndims(f,varid,ndims);
      setLength(dims,ndims);
      nc_inq_vardimid(f,varid,@dims[0]);
      for d:=0 to ndims-1 do
      begin
        FillBuffer(chr(0), s, SizeOf(s));
        nc_inq_dimname(f,dims[d],s);
        dimname:=trim(lowercase(s));
        if d=0 then result:=dimname else result:=result+';'+dimname;
      end;
    end;
    my_nc_close(f);
  end;
end;

function writeNC_attribute(filename: AnsiString; varname: AnsiString; AttributeName: AnsiString; AttributeValue: AnsiString):Integer; overload;
var
  f: Integer;
  v, varid, varmax: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
begin
  if fileExists(filename)=false then
    result:=-1
  else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
    result:=-2
  else
  begin
    //find variable
    nc_inq_nvars(f, varmax);
    varid:=-1;
    for v:=0 to varmax-1 do
    begin
      FillBuffer(chr(0), s, SizeOf(s));
      nc_inq_varname(f,v,s);
      if trim(lowercase(s))=trim(lowercase(varname)) then
        varid:=v;
    end;
    if varid=-1 then
      result:=-3
    else
    begin
      my_nc_redef(F);
      nc_put_att_text(F,varid,PAnsiChar(AttributeName),length(AttributeValue),PAnsiChar(AttributeValue));
      my_nc_enddef(F);
    end;
    my_nc_sync(F);
    my_nc_close(F);
  end;
end;

function writeNC_attribute(filename: AnsiString; varname: AnsiString; AttributeName: AnsiString; AttributeValue: Double):Integer; overload;
var
  f: Integer;
  v, varid, varmax: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
begin
  if fileExists(filename)=false then
    result:=-1
  else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
    result:=-2
  else
  begin
    //find variable
    nc_inq_nvars(f, varmax);
    varid:=-1;
    for v:=0 to varmax-1 do
    begin
      FillBuffer(chr(0), s, SizeOf(s));
      nc_inq_varname(f,v,s);
      if trim(lowercase(s))=trim(lowercase(varname)) then
        varid:=v;
    end;
    if varid=-1 then
      result:=-3
    else
    begin
      my_nc_redef(F);
      nc_put_att_double(F,varid,PAnsiChar(AttributeName),NC_DOUBLE,1,AttributeValue);
      my_nc_enddef(F);
    end;
    my_nc_sync(F);
    my_nc_close(F);
  end;
end;

function readNC_attributes(filename: AnsiString; varname: AnsiString; var attArray: TAttributeArray):Integer;
var
  f: Integer;
  v, varid, varmax: Integer;
  attid, attmax: Integer;
  atttype: nc_type;
  s, s1: array[0..MaxAnsiStringLength] of AnsiChar;
begin
  if fileExists(filename)=false then
    result:=-1
  else if my_nc_open(pAnsiChar(filename),0,f) <> 0 then
    result:=-2
  else
  begin
    //find variable
    nc_inq_nvars(f, varmax);
    varid:=-1;
    for v:=0 to varmax-1 do
    begin
      FillBuffer(chr(0), s, SizeOf(s));
      nc_inq_varname(f,v,s);
      if trim(lowercase(s))=trim(lowercase(varname)) then
        varid:=v;
    end;
    if varid=-1 then
      result:=-3
    else
    begin
      nc_inq_varnatts(f, varid, attmax);
      SetLength(attArray,attmax);
      for attid:=0 to attmax-1 do
      begin
        FillBuffer(chr(0), s, SizeOf(s));
        nc_inq_attname (f, varid, attid, s);
        attArray[attid].name:=s;
        nc_inq_atttype(f, varid, s, atttype);
        attArray[attid].att_type:=nc_typeAnsiString(atttype);
        if attArray[attid].att_type='AnsiChar' then
        begin
          FillBuffer(chr(0), s1, SizeOf(s1));
          nc_get_att_text(f, varid, s, s1);
          attArray[attid].ansichar:=s1;
        end;
        if attArray[attid].att_type='Short' then
          nc_get_att_short(f, varid, s, attArray[attid].Short);
        if attArray[attid].att_type='Int' then
          nc_get_att_int(f, varid, s, attArray[attid].Int);
        if attArray[attid].att_type='Single' then
          nc_get_att_float(f, varid, s, attArray[attid].single);
        if attArray[attid].att_type='Double' then
          nc_get_att_double(f, varid, s, attArray[attid].double);
      end;
    end;
    my_nc_sync(F);
    my_nc_close(F);
  end;
end;

function writeNC_attributes(filename: AnsiString; varname: AnsiString; attArray: TAttributeArray):Integer;
var
  f: Integer;
  v, varid, varmax: Integer;
  attid: Integer;
  s: array[0..MaxAnsiStringLength] of AnsiChar;
begin
  if fileExists(filename)=false then
    result:=-1
  else if my_nc_open(pAnsiChar(filename),1,f) <> 0 then
    result:=-2
  else
  begin
    //find variable
    nc_inq_nvars(f, varmax);
    varid:=-1;
    for v:=0 to varmax-1 do
    begin
      FillBuffer(chr(0), s, SizeOf(s));
      nc_inq_varname(f,v,s);
      if trim(lowercase(s))=trim(lowercase(varname)) then
        varid:=v;
    end;
    if varid=-1 then
      result:=-3
    else
    begin
      my_nc_redef(f);
      for attid:=0 to length(attArray)-1 do
      begin
        if attArray[attid].att_type='Short' then
          nc_put_att_short(f, varid, pAnsiChar(attArray[attid].name), nc_short, 1, attArray[attid].Short);
        if attArray[attid].att_type='Int' then
          nc_put_att_int(f, varid, pAnsiChar(attArray[attid].name), nc_int, 1, attArray[attid].Int);
        if attArray[attid].att_type='Single' then
          nc_put_att_float(f, varid, pAnsiChar(attArray[attid].name), nc_float, 1, attArray[attid].single);
        if attArray[attid].att_type='Double' then
          nc_put_att_double(f, varid, pAnsiChar(attArray[attid].name), nc_double, 1, attArray[attid].double);
      end;
    end;
    my_nc_sync(F);
    my_nc_close(F);
  end;
end;

end.

