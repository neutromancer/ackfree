{$O+}
unit u_graph;

interface

uses graph,u_adv,crt2,u_delay2;

const
  MONO:boolean=false;
  SPACEMONO:boolean=true;
  HIRES:boolean=false;
  PALETTE:byte=0;  {if 16, EGA. if 32, MCGA}
  INTENSE:byte=2;
  MONOFF=58;

var scrnh:array[0..199] of integer;
    scrnl:word;
	combatpacing:byte;

    bgi_dir:string;

procedure graphicsmode;
procedure clearscreen;
procedure putthing(xx,yy,ty:integer);
procedure fputthing(xx,yy,ty:integer);
procedure xorthing(xx,yy:integer);
procedure xorthing2(xx,yy:integer);
procedure drawv(x1,y1,y2,color:integer);
procedure drawh(x1,y1,x2,color:integer);
procedure sketchline(x1,y1,x2,y2,color:integer);
procedure sweepdot(x1,y1,x2,y2,c:integer;b:boolean;color:byte);
procedure thickln(x1,y1,x2,y2,color:integer);
procedure thickln2(x1,y1,x2,y2,color,thickness:integer);
procedure blankbox(x1,y1,x2,y2:integer);
procedure boxx(x1,y1,x2,y2:byte);
procedure u_graph_setup;

implementation
{$F+}
function detectvga256:byte;
begin
 detectvga256:=0;
end;
{$F-}

procedure graphicsmode;
var gd,gm:integer;
begin
(* if MONO then
 begin;gd:=7;gm:=0;end else
 begin
   gd:=1;
   if HIRES then gm:=4 else
    case palette of
     0:gm:=1+INTENSE; {blues}
     1:gm:=0+INTENSE; {greens}
     16:begin
        {set gm and gd for EGA}
       end;
     32:begin
         scrnl:=$a000;
         {setup for VGA}
        gd:=installuserdriver('SVGA256',@detectvga256);
        gm:=0;
       end;
    end;
 end;
 { initgraph(gd,gm,''); }
 if MONO then scrnl:=$b000 else
  if PALETTE<16 then scrnl:=$b800 else scrnl:=$A000;
 if MONO then xmlt:=2 else xmlt:=1;
 if HIRES then xmlt:=2;
*)
 { initgraph; }
 gd:=graphresult; gd:=grok;
 if gd<>grok then begin;writeln('2nd:'+grapherrormsg(gd));
  writeln('bgi_dir = '+bgi_dir);readln;halt;end;
 scrnl:=$a000;HIRES:=false;
 for gm:=0 to 199 do
  scrnh[gm]:=gm*320;
end;



procedure clearscreen;
begin
 if mouseon then hidemouse;
 fillchar(mem[$a000:0000],64000,lo(TEXTC0));
 if mouseon then showmouse;
end;


procedure putthing(xx,yy,ty:integer);
var i:integer;
    tyy:byte;
begin
(* case ty of
  0:tyy:=lo(TEXTC1);
  1:tyy:=hi(TEXTC1);
  2:tyy:=hi(TEXTC2);
  3:tyy:=hi(TEXTC0);
 end; *)

 if ((mouseon) and (mouseactive)) then hidemouse;

 tyy:=ty;
 xx:=xx*4;
 for i:=yy+1 to yy+4 do fillchar(mem[scrnl:xx+scrnh[i]],4,tyy);
end;


procedure fputthing(xx,yy,ty:integer);
var tyy:byte;
  var c1,c2:byte;
begin

 if ((mouseon) and (mouseactive)) then hidemouse;

 tyy:=ty;
 for c2:=1 to 8 do for c1:=0 to 3 do
  mem[scrnl:scrnh[yy+c2]+(xx*4)+c1]:=tyy;
 end;


procedure xorthing(xx,yy:integer);
var i:integer;
begin
 for i:=yy+1 to yy+4 do meml[scrnl:(xx*4)+scrnh[i]]:=
   meml[scrnl:(xx*4)+scrnh[i]] XOR $0f0f0f0f;
end;

procedure xorthing2(xx,yy:integer);
var i:integer;
begin
 for i:=yy+1 to yy+4 do meml[scrnl:(xx)+scrnh[i]]:=
   meml[scrnl:(xx)+scrnh[i]] XOR $0f0f0f0f;
end;

procedure drawv;
begin
 setcolor(color);
 line(x1,y1,x1,y2);
end;

procedure drawh;
begin
 setcolor(color);
 line(x1,y1,x2,y1);
end;

procedure sketchline;
begin
 setcolor(color);
 if (x1=x2) and (y1=y2) then
  mem[scrnl:scrnh[y1]+x1]:=color
 else line(x1,y1,x2,y2);
end;

(*
procedure sweepdot;
var c,xxx,yyy:integer;
begin
 for c:=1 to 4 do
  begin
   xxx:=round(x1+((x2-x1)*(c/4)));
   yyy:=round(y1+((y2-y1)*(c/4)));
   meml[scrnl:xxx+scrnh[yyy]]:=meml[scrnl:xxx+scrnh[yyy]] XOR $0F;
   delay2(speed);
   meml[scrnl:xxx+scrnh[yyy]]:=meml[scrnl:xxx+scrnh[yyy]] XOR $0F;
  end;
end;
*)
procedure sweepdot;
{x1,y1,x2,y2, and c (combat pacing, default 100, lower is faster)}
 var
  rise,run:integer;
  lastx,lasty,dotx,doty:word;
  b1,b2:shortint;
  lastball:array[-1..1,-1..1] of byte;
  lastdot:byte;
  progress:real;
  w,w2,dc,counter,distance:word;
begin
 
 rise:=y2-y1; run:=x2-x1;
 distance:= round(((sqrt(sqr(abs(x2-x1)) + sqr(abs(y2-y1)))))); 

 lastx:=0; lasty:=0;
 dc := round( (c/100) * delay_calibration * (1/500));
  
 
 for counter:=1 to distance do
 if (dotx<>x2) or (doty<>y2) then
 begin
  progress:= (distance-counter)/distance;
  dotx:= x2 - trunc(run * progress);
  doty:= y2 - trunc(rise * progress);
  if (lastx<>dotx) or (lasty<>doty) then
   begin
    {the dot has moved, draw}
	 if lastx+lasty>0 then
	  {redraw the old dot}
	  begin
	      delay2(dc); 
	      if b then
	       begin
	        for b1:= -1 to 1 do for b2:= -1 to 1 do
		 	   mem[scrnl:lastx+b1+scrnh[lasty+b2]]:=lastball[b1,b2];
		   end else 
	   mem[scrnl:lastx+scrnh[lasty]]:=lastdot;
	  end; {redraw}	  
		  
	  {draw the new dot}	  
	  if b then
       begin	  
	     for b1:= -1 to 1 do for b2:= -1 to 1 do
  		 begin		 
	       lastball[b1,b2]:=mem[scrnl:dotx+b1+scrnh[doty+b2]];
	       mem[scrnl:dotx+b1+scrnh[doty+b2]]:= color;
		  end; 
	   end else
	   begin
	    lastdot:=mem[scrnl:dotx+scrnh[doty]];
	    mem[scrnl:dotx+scrnh[doty]]:= color;
       end;
	   
   	  lastx:=dotx; lasty:=doty;
   end;	

  
 end; {counter}
 
end;




(* 
procedure sweepball;
var c,c2,xxx,yyy:integer;
begin

 for c:=1 to 4 do
  begin
   xxx:=(round(x1+((x2-x1)*(c/4))))-2;
   yyy:=round(y1+((y2-y1)*(c/4)))-2;
   meml[scrnl:xxx+scrnh[yyy-2]]:=meml[scrnl:xxx+scrnh[yyy-2]] XOR $000F0F00;
   for c2:=yyy-1 to yyy+1 do 
   begin
   meml[scrnl:xxx+scrnh[c2]]:=meml[scrnl:xxx+scrnh[c2]] XOR $0F0F0F0F;
   end;
   meml[scrnl:xxx+scrnh[yyy+2]]:=meml[scrnl:xxx+scrnh[yyy+2]] XOR $000F0F00;

   delay2(speed);

   meml[scrnl:xxx+scrnh[yyy-2]]:=meml[scrnl:xxx+scrnh[yyy-2]] XOR $000F0F00;
   for c2:=yyy-1 to yyy+1 do 
   begin
   meml[scrnl:xxx+scrnh[c2]]:=meml[scrnl:xxx+scrnh[c2]] XOR $0F0F0F0F;
   end;
   meml[scrnl:xxx+scrnh[yyy+2]]:=meml[scrnl:xxx+scrnh[yyy+2]] XOR $000F0F00;


  end;
end;
*)
procedure thickln(x1,y1,x2,y2,color:integer);
var c:integer;
begin
 if (x2-x1)<(y2-y1) then
  for c:=x1 to x2 do drawv(c,y1,y2,color)
  else for c:=y1 to y2 do drawh(x1,c,x2,color);
 end;

procedure thickln2(x1,y1,x2,y2,color,thickness:integer);
var cx,cy:integer; thick:real;
begin
 if thickness>0 then dec(thickness);
 thick:=thickness;
 thick:=sqr(thick+0.5);
 if thickness=0 then sketchline(x1,y1,x2,y2,color) else
 for cx:=-1*thickness to thickness do
  for cy:=-1*thickness to thickness do
   begin
    if sqr(cx)+sqr(cy)<=thick then sketchline(x1+cx,y1+cy,x2+cx,y2+cy,color);  
   end;
 

end; 
 
procedure blankbox;
 var yc:integer;
begin
 if mouseon then hidemouse;
  for yc:=y1 to y2 do
   fillchar(mem[$a000:yc*320+x1],x2-x1,lo(TEXTC0));
 if mouseon then showmouse;
 end;


procedure boxx(x1,y1,x2,y2:byte);
 var xx:byte;
begin
 for xx:=x1 to x2 do
  begin
   putthing(xx,y1*4,hi(TEXTC0));
   putthing(xx,y2*4,hi(TEXTC0));
  end;
 for xx:=y1+1 to y2-1 do
  begin
   putthing(x1,xx*4,hi(TEXTC0));
   putthing(x2,xx*4,hi(TEXTC0));
  end;
 end;



var y:integer;
   gd,gm:integer;
   vert:array[0..299] of integer;
   pars:string;

procedure u_graph_Setup;
begin
 exit; { no longer needed! }
(* pars:=paramstr(1);
 if pars[1]<>'!' then gd:=installuserdriver('SVGA256',@detectvga256);
 gd:=graphresult;
 if gd<>grok then begin;writeln('1st:'+grapherrormsg(gd));
 writeln('bgi_dir = '+bgi_dir);readln;halt;end; *)
end;

begin
 combatpacing:=100;
end.
