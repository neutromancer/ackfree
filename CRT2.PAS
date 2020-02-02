unit crt2;

interface

uses dos,u_adv;

var textattr:byte;
var creg:registers;


const co80 = 0;

procedure textmode(m:byte);
procedure sound(hz:word);
procedure nosound;
procedure window(x1,x2,y1,y2:integer);
function readkey:char;
function keypressed:boolean;
procedure clrscr;
procedure clreol;
procedure gotoxy(x,y:byte);
function wherex:byte;
function wherey:byte;
procedure writec(x,y,a:byte;s:String);

implementation

procedure textmode;
begin
end;

(*
procedure delay;
 var starttime:word;
begin
 d:=round(d * 0.018);
 creg.ah:=0;
 intr($1A,creg);
 starttime:=creg.dx;
 repeat
  creg.ah:=0;
  intr($1A,creg);
 until abs(creg.dx - starttime) > d;
end;
*)



var saveportb:byte;

procedure sound;
begin
 port[$43]:=$B6;
 port[$42]:=lo(hz);
 port[$42]:=hi(hz);
 saveportb:=port[$61];
 port[$61]:=saveportb OR $03;
end;

procedure nosound;
begin
 saveportb:=port[$61];
 port[$61]:=saveportb AND $FC;
end;


procedure window;
begin
end;

function readkey;
begin
 if ((mouseon) and (not mouseactive)) then showmouse;
 creg.ah:=0;
 intr($16,creg);
 if creg.al=0 then
  begin
   readkey:=#0;
   creg.ch:=creg.al;
   creg.cl:=creg.ah;
   creg.ah:=5;
   intr($16,creg);
  end else

 readkey:=char(creg.al);
end;

function keypressed;
 var kp:boolean;
begin
 if ((mouseon) and (not mouseactive)) then showmouse;
 creg.ah:=1;
 creg.Flags := creg.Flags OR 68;
 intr($16,creg);
 {writeln(creg.Flags);}
  if (creg.Flags AND 64)<>0 then kp:=false else kp:=true;
{ if kp then
  begin
   creg.ch:=creg.ah;
   creg.cl:=creg.al;
   creg.ah:=5;
   intr($16,creg);
  end;}

 keypressed:=kp;
end;


procedure clrscr;
begin
 creg.ah:=0;
 creg.al:=3;
 intr($10,creg);
end;

procedure clreol;
begin
end;

procedure gotoxy;
begin
 creg.ah:=2;
 creg.bh:=0;
 creg.dh:=y;
 creg.dl:=x;
 intr($10,creg);
end;

function wherex;
begin
 creg.ah:=3;
 creg.bh:=0;
 intr($10,creg);
 wherex:=creg.dl;
end;

function wherey;
begin
 creg.ah:=3;
 creg.bh:=0;
 intr($10,creg);
 wherey:=creg.dh;
end;

procedure writec;
begin
 { x,y,a,s }
 creg.ah:=$13;
 creg.al:=1;
 creg.bh:=0;
 creg.bl:=a;
 creg.cx:=length(s);
 creg.dh:=y;
 creg.dl:=x;
 creg.bp:=ofs(s)+1;
 creg.es:=seg(s);
 intr($10,creg);
end;


begin

end.
