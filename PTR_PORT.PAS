type
 fourbytes=array[1..4] of byte;
var f4b:fourbytes; p4tf:^blockarray absolute f4b;
 p4tg:^graparray256 absolute f4b;

procedure string4(fb:fourbytes;var s:string);
begin
 s:=concat(strnum(fb[1]),'-',strnum(fb[2]),'-',
                 strnum(fb[3]),'-',strnum(fb[4]));
end;

procedure byte4(s:string;var frb:fourbytes);
 var ss:array[1..4] of string;
   b,b1:integer;
begin
 b1:=1;for b:=1 to 4 do ss[b]:='';
 for b:=1 to length(s) do
  if s[b]='-' then inc(b1)
   else ss[b1]:=concat(ss[b1],s[b]);
 for b:=1 to 4 do val(ss[b],frb[b],b1);
end;

procedure usepointers;
begin
 byte4(paramstr(2),f4b);
 block:=@p4tf^;
 byte4(paramstr(3),f4b);
 graphic:=@p4tg^;
end;

