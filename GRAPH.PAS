unit graph;

interface

uses dos,u_adv;

 var greg:registers;
 var graphresult:integer;
 var thisgraphiccolor:byte;
 var lastlinex,lastliney:integer;
 const detect=0;
       grok=0;
       getmaxcolor=15;

procedure startupgraph;
procedure initgraph;
procedure closegraph;
procedure shutdowngraph;
function grapherrormsg(n:integer):string;
procedure setcolor(n:integer);
procedure line(x1,y1,x2,y2:word);
procedure lineto(x,y:integer);
procedure putpixel(cx,cy,c:integer);
procedure setvisualpage(n:byte);
procedure setactivepage(n:byte);
procedure detectgraph(var gd,gm:integer);
{procedure setrgbpalette(c,r,b,g:byte);}

implementation

procedure startupgraph;
begin
 greg.ah:=0;
 greg.al:=19;
 intr($10,greg);
end;

procedure initgraph;
begin
 greg.ah:=0;
 greg.al:=19+128;
 intr($10,greg);
 graphresult:=0;
end;

procedure closegraph;
begin
 greg.ah:=0;
 greg.al:=2; {was +128}
 intr($10,greg);
end;

procedure shutdowngraph;
begin
 greg.ah:=0;
 greg.al:=2;
 intr($10,greg);
end;

function grapherrormsg;
begin
 grapherrormsg:='Blah, blah';
end;

procedure setcolor;
begin
 thisgraphiccolor:=n;
end;

procedure swap(var n1,n2:word);
 var t:word;
begin
 t:=n1;
 n1:=n2;
 n2:=t;
end;

procedure line;
 var cx,cy:word;
     ucx,ucy:word;
     xd,yd:word;
     factor:word;
     xswapped,yswapped:boolean;
begin

 {mult all by 64}
 x1:=x1 SHL 6; y1:=y1 SHL 6;
 x2:=x2 SHL 6; y2:=y2 SHL 6;

 if ((mouseon) and (mouseactive)) then hidemouse;

 if (x1>x2) then begin;swap(x1,x2);xswapped:=true;end else xswapped:=false;
 if (y1>y2) then begin;swap(y1,y2);yswapped:=true;end else yswapped:=false;

 xd:=abs(x2-x1);
 yd:=abs(y2-y1);

 if xd<yd then factor:=yd SHR 6 else factor:=xd SHR 6;
{ if factor<1 then factor:=1;}
 if factor>255 then factor:=9 else
 if factor>127 then factor:=8 else
 if factor>63 then factor:=7 else factor:=6;

 cx:=x1;cy:=y1;
 repeat

  ucx:=cx;
  ucy:=cy;
  if xswapped then ucx:=x2+(x1-ucx);
  if yswapped then ucy:=y2+(y1-ucy);
  ucx:=ucx SHR 6;
  ucy:=ucy SHR 6;

  mem[$a000:(ucy)*320 + (ucx)]:= thisgraphiccolor;

  cy:=cy+(yd SHR factor);
  cx:=cx+(xd SHR factor);

 until ((cx>x2) OR (cy>y2));
{ until (abs(cx-x1)>abs(x2-x1)) OR (abs(cy-y1)>abs(y2-y1)); }

 lastlinex:=x2;lastliney:=y2;
end;

procedure lineto;
begin
 line(lastlinex,lastliney,x,y);
end;

procedure putpixel;
begin
 mem[$a000:round(cy)*320 + round(cx)]:= c;
 lastlinex:=cx; lastliney:=cy;
end;

procedure setvisualpage;
begin
end;

procedure setactivepage;
begin
end;

procedure detectgraph;
begin
 gm:=0;
 gd:=9;

end;

{procedure setrgbpalette;
begin
 greg.ax:=$1010;
 greg.bx:=c;
 greg.dh:=r;
 greg.ch:=b;
 greg.cl:=g;
 intr($10,greg);
end;}

begin
end.