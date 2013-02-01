procedure bytecopy(fn1,fn2:string);
var f1,f2:file;
    f3:file of byte;
    b:byte;
    stepsize,numsteps:longint;
    l,l1:longint;
    step,stepc,stepac:byte;
    stepa:array[1..8192] of byte;
    r,r1,r2:integer;
begin


 assign(f1,fn1);assign(f2,fn2);assign(f3,fn1);
 {$I-}
 reset(f3);
 r1:=ioresult;
  stepsize:=filesize(f3);
 close(f3);
 if stepsize>8192 then begin;numsteps:=stepsize;stepsize:=1;end
  else numsteps:=1;
 reset(f1,stepsize);
 r2:=ioresult*1000;

  if r1+r2<>0 then
   begin
    say(1,10,0,'WARNING: COULD NOT COPY');
    say(1,18,0,fn1+' TO '+fn2);
	say(1,28,0,strnum(r2));
    readln;
	halt;
   end else rewrite(f2,stepsize);

 if stepsize=1 then
  begin
   step:=numsteps DIV 8192;
   r:=numsteps MOD 8192;
   l:=8192;
  end else
  begin
   step:=1;
   r:=0;
   l:=1;
  end;
 for stepc:=1 to step do
  begin
   blockread(f1,stepa[1],l);
   blockwrite(f2,stepa[1],l);
  end;
 if r<>0 then begin
  blockread(f1,stepa[1],r);
  blockwrite(f2,stepa[1],r);
 end;
 close(f1);close(f2);
 {$I+}
end;


procedure bytecopyall(kitpath,ext,copypath:string);
var sr:searchrec;
begin
  while (length(kitpath)>1) and (kitpath[length(kitpath)]<>'\') do
   begin
    kitpath:=copy(kitpath,1,length(kitpath)-1);
   end;

 {
  say(1,170,1,kitpath+'*.'+ext);
  say(1,180,1,copypath);}

  findfirst(kitpath+'*.'+ext,anyfile,sr);
  while doserror=0 do
   begin
{    say(25,190,1,sr.name); }
    bytecopy(kitpath+sr.name,copypath+sr.name);

    findnext(sr);
   end;
end;