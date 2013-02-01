{$O+}
unit u_graps;

interface

uses u_graph,u_adv,crt2;

type sixteenbytes=array[1..16] of byte;       { VGA definitions }
     grap256unit=array[1..16] of sixteenbytes;
     graparray256=array[0..0] of grap256unit;

const GRAPS=240;

var
    graphic:^graparray256;
    graphic2:^graparray256;
	graphicdark:^graparray256;
    graphic2enabled:boolean;

	transparency:boolean;
	tmask:byte;


procedure loadgraps;
procedure loadgraps2(load2high:boolean);
procedure quartertile(place:byte;tile:word);
procedure putgrap(xb,yy,bb:integer);
procedure putgrap2(xb,yy,bb:integer);
procedure putdarkgrap(xb,yy,bb:integer);
procedure putdarkgrap2(xb,yy,bb:integer;dark,back:byte);
procedure invertgrap(xb,yy:integer);
procedure inverttarget(x,y,rw,rt:byte);
procedure targeticon(xb,yy:byte);
procedure no_targeticon(xb,yy:byte);
procedure blank0(n:byte);
procedure puttransgrap11(xb,yy,over,under:integer);
procedure puttransgrap21(xb,yy,over,under:integer);
procedure puttransgrap22(xb,yy,over,under:integer);
procedure puttransgrap12(xb,yy,over,under:integer);
procedure putdarktransgrap11(xb,yy,over,under:integer);
procedure preparemask;

implementation


procedure loadgraps;
var bf:file;
    i:integer;
    fn:string;
begin
 fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
{$I-} reset(bf,256); {$I+}
if ioresult<>0 then exit;
 for i:=1 to GRAPS do blockread(bf,graphic^[i],1);
 close(bf);
end;

procedure loadgraps2(load2high:boolean);
var bf:file;
    i:integer;
    fn:string;
begin
 if graphic2enabled then fn:=concat(ADVNAME,'.GR2') else fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
{$I-} reset(bf,256); {$I+}
 if ioresult<>0 then
  begin
   fn:=concat(ADVNAME,GRAPHICSFILE);
   assign(bf,fn);
   reset(bf,256);
  end;
 if load2high then
   for i:=1 to GRAPS do blockread(bf,graphic2^[i],1)
   else for i:=1 to GRAPS do blockread(bf,graphic^[i],1);
 close(bf);
end;

procedure quartertile(place:byte;tile:word);
var t,i,x,y,yoff:byte;
begin
 if tile=0 then exit;
 if place>6 then begin;yoff:=132;place:=place-6;end
  else yoff:=1;
 t:=(tile DIV 4);
 case (tile MOD 4) of
  0:begin;x:=1;y:=1;end;
  1:begin;x:=9;y:=1;end;
  2:begin;x:=1;y:=9;end;
  else begin;x:=9;y:=9;end;
 end;
 for i:=0 to 7 do
   move(graphic^[t,i+y,x],mem[scrnl:(255+(place*9))+scrnh[i+yoff]],8);
end;

procedure putgrap(xb,yy,bb:integer);
var i:integer;

begin
 if ((mouseon) and (mouseactive)) then hidemouse;
 for i:=1 to 16 do
  move(graphic^[bb,i],mem[scrnl:(xb*4)+scrnh[yy+i]],16);
end;

procedure putgrap2(xb,yy,bb:integer);
var i:integer;

begin
 if graphic2enabled then
 begin
 if ((mouseon) and (mouseactive)) then hidemouse;
 for i:=1 to 16 do
  move(graphic2^[bb,i],mem[scrnl:(xb*4)+scrnh[yy+i]],16);
 end else putgrap(xb,yy,bb);
end;


procedure putdarkgrap(xb,yy,bb:integer);
var i,i1:byte;

begin
 if ((mouseon) and (mouseactive)) then hidemouse;
 for i:=1 to 16 do
  move(graphicdark^[bb,i],mem[scrnl:(xb*4)+scrnh[yy+i]],16);
 
 { for i:=1 to 16 do for i1:=1 to 16 do
   if graphic^[bb,i,i1]=back then mem[scrnl:(xb*4+(i1-1))+scrnh[yy+i]]:=back
   else mem[scrnl:(xb*4+(i1-1))+scrnh[yy+i]]:=dark;
}
end;


procedure putdarkgrap2(xb,yy,bb:integer;dark,back:byte);
var i,i1:byte;

begin
 if not graphic2enabled then begin;putdarkgrap(xb,yy,bb);exit;end;


 if ((mouseon) and (mouseactive)) then hidemouse;

 for i:=1 to 16 do for i1:=1 to 16 do
  if graphic2^[bb,i,i1]=back then mem[scrnl:(xb*4+(i1-1))+scrnh[yy+i]]:=back
   else mem[scrnl:(xb*4+(i1-1))+scrnh[yy+i]]:=dark;

end;


(*
procedure scangrap(xb,yy,bb:integer);
var i:integer;
begin
 for i:=1 to 16 do
  move(screen[xy(xb,yy+i-1)],block[bb,i],4);
 end;
*)

procedure invertgrap(xb,yy:integer);
var i,i1:integer;
begin
 if mouseon then hidemouse;
 for i:=1 to 16 do for i1:=0 to 16 do
  mem[scrnl:(xb*4)+i1+scrnh[yy+i]]:=mem[scrnl:(xb*4)+i1+scrnh[yy+i]]
   XOR 15;
 if mouseon then showmouse;
end;

 procedure inverttarget(x,y,rw,rt:byte);
  begin
   invertgrap(x*4-3+(32-(rw*2)),y*16-14+(88-(rt*8)));
  end;

var old_targeticon:grap256unit;

procedure targeticon(xb,yy:byte);
 var i,i1,i0,id:byte;
begin
 if mouseon then hidemouse;
 i0:=0;
 for i:=1 to 16 do for i1:=0 to 15 do
  old_targeticon[i,i1+1]:=mem[scrnl:(xb*4)+i1+scrnh[yy+i]];
 for i:=1 to 16 do for i1:=0 to 15 do
 mem[scrnl:(xb*4)+i1+scrnh[yy+i]]:=
  (old_targeticon[i,i1+1] AND graphic^[i0+241,i,i1+1])
    OR graphic^[i0+242,i,i1+1];
 if mouseon then showmouse;
end;


procedure no_targeticon(xb,yy:byte);
 var i,i1,id:byte;
begin
 if mouseon then hidemouse;
 for i:=1 to 16 do for i1:=0 to 15 do
  mem[scrnl:(xb*4)+i1+scrnh[yy+i]]:=old_targeticon[i,i1+1];
 if mouseon then showmouse;
end;

(*
 See also: save/restore page routines in I_PLY3.PAS

*)

procedure blank0(n:byte);
var i,i1:byte;
begin
 for i:=1 to 16 do for i1:=1 to 16 do graphic^[0,i,i1]:=n;
end;
{
procedure graplog(a,b,c:byte);
var f:text;
begin
 assign(f,'TMASK.LOG');
 append(f);
 write(f,a); write(f,'  '); write(f,b); write(f,'>'); writeln(f,c);
 close(f);
end;
}
procedure puttransgrap11;
var i,i1:byte;
begin
{
 for i:=1 to 16 do for i1:=1 to 16 do
  mem[scrnl:(xb*4+(i1-1))+scrnh[yy+i]]:=(graphic^[under,i,i1] AND graphicmask^[over,i,i1]) OR graphic^[over,i,i1];
}
 {graplog(11,over,under);}
 if not transparency then begin;putgrap(xb,yy,over);exit;end;
 for i:=1 to 16 do for i1:=1 to 16 do
  if graphic^[over,i,i1]=tmask then
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic^[under,i,i1]
  else 
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic^[over,i,i1];
end;

procedure puttransgrap21;
var i,i1:byte;
begin
 if not transparency then begin;putgrap2(xb,yy,over);exit;end;
 if under>240 then under:=0;
 for i:=1 to 16 do for i1:=1 to 16 do
  if graphic2^[over,i,i1]=tmask then
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic^[under,i,i1]
  else 
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic2^[over,i,i1];
end;

procedure puttransgrap22;
var i,i1:byte;
begin
 if not transparency then begin;putgrap2(xb,yy,over);exit;end;
 for i:=1 to 16 do for i1:=1 to 16 do
  if graphic2^[over,i,i1]=tmask then
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic2^[under,i,i1]
  else 
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic2^[over,i,i1];
end;

procedure puttransgrap12;
var i,i1:byte;
begin
 if not transparency then begin;putgrap(xb,yy,over);exit;end;
for i:=1 to 16 do for i1:=1 to 16 do
  if graphic^[over,i,i1]=tmask then
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic2^[under,i,i1]
  else 
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphic^[over,i,i1];

end;

procedure putdarktransgrap11;
var i,i1:byte;
begin
 if not transparency then begin;putdarkgrap(xb,yy,over);exit;end;
 if under>240 then under:=0;
 for i:=1 to 16 do for i1:=1 to 16 do
  if graphic^[over,i,i1]=tmask then
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphicdark^[under,i,i1]
  else 
   mem[scrnl:(xb*4)+i1+scrnh[yy+i]-1]:=graphicdark^[over,i,i1];
end;

procedure preparemask;
var c,x,y:byte;
   f:text;
   s:string[4];
   i,ie:integer;

begin
 assign(f,'TMASK.TXT');
 {$I-} reset(f); 
 if ioresult<>0 then exit;
 read(f,s);
 val(s,i,ie);
 close(f);
 if (ie<>0) or (ioresult<>0) or (i>255) or (i<0) then exit;
 tmask:=i;
 transparency:=true;

 {$I+}
{ for c:=1 to 240 do
 for x:=1 to 16 do
 for y:=1 to 16 do
  if graphic^[c,x,y]=tmask then
   begin
    graphicmask^[c,x,y]:=255;
	graphic^[c,x,y]:=0;
   end	else graphicmask^[c,x,y]:=0; }

   {This creates the graphic mask.  
       Now the terrain tile can be painted AND mask, 
	   and the top tile can be painted XOR what's 
	   on the screen.}
   
end;  
  
begin
{ getmem(graphic,(GRAPS+1)*sizeof(grapunit)); }
 graphic2enabled:=true;
 transparency:=false;
end.