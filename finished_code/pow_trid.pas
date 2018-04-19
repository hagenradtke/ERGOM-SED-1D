unit pow_trid;
//used to quickly calculate powers of tridiagonal matrices
//following the method described in
//Al-Hassan, Q., 2012. On Powers of Tridiagonal Matrices with Nonnegative Entries.
//Journal of Applied Mathematical Sciences 6, 2357–2368.

interface
uses math, NetCDFAnsi;

function power_tridiag(a,b,c: DoubleArray1d; exponent: Double):DoubleArray2d;
procedure decomp_tridiag(a,b,c: DoubleArray1d; var LHS: DoubleArray2d; var RHS: DoubleArray2d; var EIG: DoubleArray1d);

implementation

function power_tridiag(a,b,c: DoubleArray1d; exponent: Double):DoubleArray2d;
//a = diagonal elements, b = superdiagonal elements, c = subdiagonal elements
const
  Nmax = 1000;
  TOL = 1e-15;
var
  i,j,k,n: Integer;
  prodB, prodC: Double;
  gamma: DoubleArray1d; //gamma stores the elements of D_1
  Jd, Jsd: DoubleArray1d;             //diagonal and superdiagonal elements of J
  s,lambda,bb,cc,col1: DoubleArray1d;
  v, tempmat: DoubleArray2d;
  togo, its: Integer;
  shift, trace, det, disc, mu1, mu2, s1, r, oldb, temp1, temp2: Double;
begin
  n:=length(a);
  setLength(result, n,n);

  //first step is to compute a symetric tridiagonal matrix J which is similar to T
  setLength(gamma,n);
  gamma[n-1]:=1.0;
  prodC:=1; prodB:=1;

  for i:=n-1 downto 1 do
  begin
    prodB:=prodB*b[i-1];
    prodC:=prodC*c[i-1];
    gamma[i-1]:=sqrt(prodB/prodC); //gamma stores the elements of the diagonal matrix D_1
  end;

  setLength(Jd,n);
  setLength(Jsd,n-1);
  for i:=1 to n do
    Jd[i-1]:=a[i-1];               //diagonal elements of J
  for i:=1 to n-1 do
    Jsd[i-1]:=sqrt(b[i-1]*c[i-1]); //superdiagonal elements of J

  //second step is to find the eigenvectors and eigenvalues of J
  //using the QR algorithm with Wilkinson shift (from MATLAB file qrst.m)
  setlength(bb,n); for i:=1 to n do bb[i-1]:=0.0;
  setlength(cc,n); for i:=1 to n do cc[i-1]:=0.0;
  setlength(col1,n); for i:=1 to n do col1[i-1]:=0.0;
  setlength(s,n); for i:=1 to n do s[i-1]:=0.0;
  setlength(lambda,n);
  setLength(v,n,n); for i:=1 to n do for j:=1 to n do if i=j then v[i-1,j-1]:=1.0 else v[i-1,j-1]:=0.0;
  shift:=0;
  togo:=n;
  for its:=1 to nmax do
  begin
    if togo = 1 then
    begin
	    lambda[0] := Jd[0] + shift;
	    break;
    end;
    trace := Jd[togo-2] + Jd[togo-1];
    det   := Jd[togo-2]*Jd[togo-1] - Jsd[togo-2]*Jsd[togo-2];
    disc  := sqrt ( trace*trace - 4*det );
	  mu1 := 0.5 * ( trace + disc );
	  mu2 := 0.5 * ( trace - disc );
    if  abs ( mu1 - Jd[togo-1] ) < abs ( mu2 - Jd[togo-1] ) then
	    s1 := mu1
    else
	    s1 := mu2;

    shift := shift + s1;
	  for i := 1 to togo do
    begin
	    Jd[i-1] := Jd[i-1] - s1;
	  end;

    oldb := Jsd[0];
    for i := 2 to togo do
    begin
      j := i-1;
	    r := sqrt ( Jd[j-1]*Jd[j-1] + oldb*oldb );
	    cc[i-1] := Jd[j-1] / r;
	    s[i-1] := oldb / r;
	    Jd[j-1] := r;
	    temp1 := cc[i-1]*Jsd[i-2] + s[i-1]*Jd[i-1];
	    temp2 := -s[i-1]*Jsd[i-2] + cc[i-1]*Jd[i-1];
	    Jsd[i-2] := temp1;
	    Jd[i-1] := temp2;
	    if i <> togo then
      begin
        oldb := Jsd[i-1];
        Jsd[i-1] := cc[i-1]*Jsd[i-1];
      end;
    end;

    Jd[0] := cc[1]*Jd[0] + s[1]*Jsd[0];
    Jsd[0] := s[1]*Jd[1];
    for i := 2 to togo-1 do
    begin
      Jd[i-1] := s[i]*Jsd[i-1] + cc[i-1]*cc[i]*Jd[i-1];
	    Jsd[i-1] := s[i]*Jd[i];
    end;
    Jd[togo-1] := cc[togo-1]*Jd[togo-1];

    for i := 2 to togo do
    begin
      for j:=1 to n do
	      col1[j-1] := v[j-1,i-2] * cc[i-1] + v[j-1,i-1] * s[i-1];
      for j:=1 to n do
		    v[j-1,i-1] := -s[i-1] * v[j-1,i-2] + cc[i-1] * v[j-1,i-1];
      for j:=1 to n do
  		  v[j-1,i-2] := col1[j-1];
	  end;

  	if abs(Jsd[togo-2]) < TOL  then
    begin
      lambda[togo-1] := Jd[togo-1] + shift;
      togo := togo - 1;
  	end;
	end;

{  //save the eigenvectors to the matrix
  for i:=1 to n do
    for j:=1 to n do
      result[i-1,j-1]:=v[i-1,j-1];
  for i:=1 to n do
    result[i-1,n-1]:=lambda[i-1];}

  // now, D1 is stored in gamma, D2 is stored in lambda and U is stored in v.
  // calculate the desired power of D2
  for i:=1 to n do
    lambda[i-1]:=power(lambda[i-1],exponent);

  //finally calculate T^k = D1^-1 * U * D2^k * U^T * D1
  //first step: calculate D2^k * U^T * D1
  setLength(tempmat,n,n);
  for i:=1 to n do
    for j:=1 to n do
      tempmat[i-1,j-1]:=lambda[i-1]*v[j-1,i-1]*gamma[j-1];
  //second step: the matrix multiplication
  for i:=1 to n do
    for j:=1 to n do
    begin
      result[i-1,j-1]:=0.0;
      for k:=1 to n do
        result[j-1,i-1]:=result[j-1,i-1]+v[i-1,k-1]*tempmat[k-1,j-1];
    end;
  //third step: dividing by D1^-1
  for i:=1 to n do
    for j:=1 to n do
      result[j-1,i-1]:=result[j-1,i-1]/max(gamma[i-1],1e-30);
end;

procedure decomp_tridiag(a,b,c: DoubleArray1d; var LHS: DoubleArray2d; var RHS: DoubleArray2d; var EIG: DoubleArray1d);
//a = diagonal elements, b = superdiagonal elements, c = subdiagonal elements
const
  Nmax = 1000;
  TOL = 1e-15;
var
  i,j,k,n: Integer;
  prodB, prodC: Double;
  gamma: DoubleArray1d; //gamma stores the elements of D_1
  Jd, Jsd: DoubleArray1d;             //diagonal and superdiagonal elements of J
  s,lambda,bb,cc,col1: DoubleArray1d;
  v, tempmat: DoubleArray2d;
  togo, its: Integer;
  shift, trace, det, disc, mu1, mu2, s1, r, oldb, temp1, temp2: Double;
begin
  n:=length(a);

  //first step is to compute a symetric tridiagonal matrix J which is similar to T
  setLength(gamma,n);
  gamma[n-1]:=1.0;
  prodC:=1; prodB:=1;

  for i:=n-1 downto 1 do
  begin
    prodB:=prodB*b[i-1];
    prodC:=prodC*c[i-1];
    if (prodB=0) and (prodC=0) then
      gamma[i-1]:=1.0
    else
      gamma[i-1]:=sqrt(prodB/prodC); //gamma stores the elements of the diagonal matrix D_1
  end;

  setLength(Jd,n);
  setLength(Jsd,n-1);
  for i:=1 to n do
    Jd[i-1]:=a[i-1];               //diagonal elements of J
  for i:=1 to n-1 do
    Jsd[i-1]:=sqrt(b[i-1]*c[i-1]); //superdiagonal elements of J

  //second step is to find the eigenvectors and eigenvalues of J
  //using the QR algorithm with Wilkinson shift (from MATLAB file qrst.m)
  setlength(bb,n); for i:=1 to n do bb[i-1]:=0.0;
  setlength(cc,n); for i:=1 to n do cc[i-1]:=0.0;
  setlength(col1,n); for i:=1 to n do col1[i-1]:=0.0;
  setlength(s,n); for i:=1 to n do s[i-1]:=0.0;
  setlength(lambda,n);
  setLength(v,n,n); for i:=1 to n do for j:=1 to n do if i=j then v[i-1,j-1]:=1.0 else v[i-1,j-1]:=0.0;
  shift:=0;
  togo:=n;
  for its:=1 to nmax do
  begin
    if togo = 1 then
    begin
	    lambda[0] := Jd[0] + shift;
	    break;
    end;
    trace := Jd[togo-2] + Jd[togo-1];
    det   := Jd[togo-2]*Jd[togo-1] - Jsd[togo-2]*Jsd[togo-2];
    disc  := sqrt ( trace*trace - 4*det );
	  mu1 := 0.5 * ( trace + disc );
	  mu2 := 0.5 * ( trace - disc );
    if  abs ( mu1 - Jd[togo-1] ) < abs ( mu2 - Jd[togo-1] ) then
	    s1 := mu1
    else
	    s1 := mu2;

    shift := shift + s1;
	  for i := 1 to togo do
    begin
	    Jd[i-1] := Jd[i-1] - s1;
	  end;

    oldb := Jsd[0];
    for i := 2 to togo do
    begin
      j := i-1;
	    r := sqrt ( Jd[j-1]*Jd[j-1] + oldb*oldb );
      if r=0 then
      begin
        cc[i-1]:=0;
        s[i-1]:=0;
      end
      else
      begin
  	    cc[i-1] := Jd[j-1] / r;
	      s[i-1] := oldb / r;
      end;
	    Jd[j-1] := r;
	    temp1 := cc[i-1]*Jsd[i-2] + s[i-1]*Jd[i-1];
	    temp2 := -s[i-1]*Jsd[i-2] + cc[i-1]*Jd[i-1];
	    Jsd[i-2] := temp1;
	    Jd[i-1] := temp2;
	    if i <> togo then
      begin
        oldb := Jsd[i-1];
        Jsd[i-1] := cc[i-1]*Jsd[i-1];
      end;
    end;

    Jd[0] := cc[1]*Jd[0] + s[1]*Jsd[0];
    Jsd[0] := s[1]*Jd[1];
    for i := 2 to togo-1 do
    begin
      Jd[i-1] := s[i]*Jsd[i-1] + cc[i-1]*cc[i]*Jd[i-1];
	    Jsd[i-1] := s[i]*Jd[i];
    end;
    Jd[togo-1] := cc[togo-1]*Jd[togo-1];

    for i := 2 to togo do
    begin
      for j:=1 to n do
	      col1[j-1] := v[j-1,i-2] * cc[i-1] + v[j-1,i-1] * s[i-1];
      for j:=1 to n do
		    v[j-1,i-1] := -s[i-1] * v[j-1,i-2] + cc[i-1] * v[j-1,i-1];
      for j:=1 to n do
  		  v[j-1,i-2] := col1[j-1];
	  end;

  	if abs(Jsd[togo-2]) < TOL  then
    begin
      lambda[togo-1] := Jd[togo-1] + shift;
      togo := togo - 1;
  	end;
	end;

  // now, D1 is stored in gamma, D2 is stored in lambda and U is stored in v.
  // finally we will calculate T^k = (D1^-1 * U) * D2^k * (U^T * D1)

  // output of D2:
  setLength(EIG,n);
  for i:=1 to n do
    EIG[i-1]:=lambda[i-1];

  // output of U^T * D1
  setLength(RHS,n,n);
  for i:=1 to n do
    for j:=1 to n do
      RHS[i-1,j-1]:=v[j-1,i-1]*gamma[j-1];

  // output of D1^-1*U
  setLength(LHS,n,n);
  for i:=1 to n do
    for j:=1 to n do
      LHS[i-1,j-1]:=v[i-1,j-1]/max(gamma[i-1],1e-30);
end;

end.
