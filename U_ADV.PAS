{$O+}
unit u_adv;

interface

uses dos, u_delay2;


type string4 = string[4];
     string2 = string[2];

const
  ACKVERSION:byte=032;  {021 = v2.1, 010 = v1.0}
  ADVNAME:string='NONAME';
  GRAPHICSFILE:string4='.GRP';
  FONTFILE:string4='.FNT';
  OBJECTFILE:string4='.ITM';
  SHORTMSGFILE:string4='.SMS';
  SHORTMSGFILE2:string4='.SM2';
  {PICTUREMSGFILE:string4='.PMS';}
  LONGMSGFILE:string4='.LMS';
  DIALOGUEFILE:string4='.DLG';
  MOSAICFILE:string4='.MOS';
  CREATUREFILE:string4='.PPL';
  CREATURESOUNDFILE:string4='.PSF';
  MACROFILE:string4='.MCR';
  MASTERFILE:string4='.MST';
  PLAYMASTERFILE:string4='.PLY';
  TEMPMASTERFILE:string4='.TPF';
  REGIONFILE:string4='.RGN'; {.RGX,.RGT}
  EXCFILE:string4='.EXC';
  LISTFILE:string4='.LST';
  MAPAFILE:string2='.A'; {.A, .X, .1}
  MAPBFILE:string2='.B'; {.B, .Y, .2}
  MAPCFILE:string2='.C'; {.C, .Z, .3}
  MAPWFILE:string2='.W';
  DOCUMENTFILE:string4='.DOC';
  TEXTC0:word=15*256;
  TEXTC1:word=8*256;
  TEXTC2:word=7*256;
  TEXTC4:word=8;
  TEXTC5:word=7;
  TEXTC6:word=15;

type
     paletterec=array[1..3] of byte;

var mouseon:boolean;
    disablemouse:boolean;
    mouseregs:registers;
    mousex,mousey:integer;
    mouseLB,mouseRB:boolean;
    mousekey:char;
    nochar:char;
    nonum:byte;
    mouseactive:boolean;
    pausemouse:boolean;

{procedure loadpalette;  }
procedure loadbmppalette(version:byte;advname,homedir:string);
procedure initmouse;
procedure closemouse;
procedure restartmouse;
procedure showmouse;
procedure hidemouse;
function mousein(x1,y1,x2,y2:integer):boolean;
function checkmouse(x1,y1,x2,y2,nv,n:integer;var cv:char;c:char):integer;
procedure trackmouse;
procedure delay(d:word);

implementation





procedure loadbmppalette(version:byte;advname,homedir:string);
var bmpf:file of byte;
    header:array[1..54] of byte;
    pal:array[0..255,0..2] of byte;
    b,b2:byte;
    w:word;
    s1:string[2];
    greg:registers;
begin
 {
 writeln(version);
 writeln(advname);
 writeln(homedir);
 readln;}
 assign(bmpf,'PALETTE.BMP');
 {$I-} reset(bmpf); {$I+}
 if ioresult<>0 then
  begin

   if version>19 then s1:='2' else s1:='1';
   assign(bmpf,homedir+'PALETTE'+s1+'.DAT');
  { writeln(homedir+'PALETTE'+s1+'.DAT'); readln; }
   {$I-} reset(bmpf); {$I+}
   if ioresult<>0 then exit;
  end;

 {BlockRead(bmpf,header[1],54);}
 seek(bmpf,54);
 {w:=header[51];}
 {if w=0 then w:=256;}
 for b:=0 to 255 do
   begin
   { blockread(bmpf,pal[b,2],1);
    blockread(bmpf,pal[b,1],1);
    blockread(bmpf,pal[b,0],1);
    blockread(bmpf,b2,1); }
    read(bmpf,pal[b,2]);
    read(bmpf,pal[b,1]);
    read(bmpf,pal[b,0]);
    read(bmpf,b2);

   end;
 close(bmpf);


 for b:=0 to 255 do for b2:=0 to 2 do
  pal[b,b2]:=pal[b,b2] SHR 2;

 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal[0,0]);
 greg.dx:=ofs(pal[0,0]);
 intr($10,greg);


end;






 (*
var
   greg:registers;

procedure loadpalette;
 var x,y:byte;
  pal1:array[0..255] of paletterec;

procedure readyrgbpalette(cc,rr,gg,bb:byte);
begin
{ setrgbpalette(cc,rr,bb,gg);}
 pal1[cc,1]:=rr;
 pal1[cc,2]:=gg;
 pal1[cc,3]:=bb;
end;

begin
 greg.ax:=$1017;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0]);
 greg.dx:=ofs(pal1[0]);
 intr($10,greg);

 {greens}
 for x:=0 to 7 do
  readyrgbpalette(x+32,0,round(63*((x+3)/10)),0);
 for x:=8 to 15 do
  readyrgbpalette(x+32,round(40/(20-x)),round(230/(20-x)),round(120/(20-x)));
 {browns}
 readyrgbpalette(15*16+0,62 SHR 2,34 SHR 2,15 SHR 2);
 readyrgbpalette(15*16+1,86 SHR 2,47 SHR 2,21 SHR 2);
 readyrgbpalette(15*16+2,101 SHR 2,55 SHR 2,25 SHR 2);
 readyrgbpalette(15*16+3,121 SHR 2,66 SHR 2,30 SHR 2);
 readyrgbpalette(15*16+4,155 SHR 2,85 SHR 2,38 SHR 2);
 readyrgbpalette(15*16+5,189 SHR 2,103 SHR 2,47 SHR 2);


 for x:=0 to 4 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*(x/4)),0,round(63*((y-2)/3)));
 for x:=5 to 10 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*((10-x)/5)),18,round(63*((y-2)/3)));
 for x:=11 to 15 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*((x-11)/4)),20,round(63*((y-2)/3)));

 for x:=0 to 4 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*(x/4)),22,round(63*((5-y)/3)));
 for x:=5 to 10 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*((10-x)/5)),35,round(63*((5-y)/3)));
 for x:=11 to 15 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*((x-11)/4)),37,round(63*((5-y)/3)));

 for x:=0 to 4 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*(x/4)),40,round(63*((y-2)/3)));
 for x:=5 to 10 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*((10-x)/5)),52,round(63*((y-2)/3)));
 for x:=11 to 15 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*((x-11)/4)),63,round(63*((y-2)/3)));

 for x:=0 to 4 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*(x/4)) DIV 2,10 DIV 2,round(63*((5-y)/3)) DIV 2);
 for x:=5 to 10 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*((10-x)/5)) DIV 2,35 DIV 2,round(63*((5-y)/3)) DIV 2);
 for x:=11 to 15 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*((x-11)/4)) DIV 2,50 DIV 2,round(63*((5-y)/3)) DIV 2);
 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0]);
 greg.dx:=ofs(pal1[0]);
 intr($10,greg);

end;

 *)

procedure initmouse;
begin

 if pausemouse then exit;
 if disablemouse then exit;
 mouseregs.ax:=0;
 intr($33,mouseregs);
 if mouseregs.ax=0 then mouseon:=false else mouseon:=true;
 mouseregs.ax:=1;
 intr($33,mouseregs);
 if mouseon then mouseactive:=true;
end;

procedure closemouse;
begin

 if pausemouse then exit;
 if disablemouse then exit;
 mouseactive:=false;
 mouseregs.ax:=0;
 intr($33,mouseregs);
 mouseregs.ax:=2;
 intr($33,mouseregs);
end;

procedure restartmouse;
begin

 if pausemouse then exit;
  if disablemouse then exit;
 mouseactive:=true;
 mouseregs.ax:=0;
 intr($33,mouseregs);
{ mouseregs.ax:=1;
 intr($33,mouseregs); }
end;


procedure showmouse;
begin

 if mouseactive then exit;
 if pausemouse then exit;
  if disablemouse then exit;
 mouseactive:=true;
 mouseregs.ax:=1;
 intr($33,mouseregs);
end;

procedure hidemouse;
begin

 if not mouseactive then exit;
 if pausemouse then exit;
  if disablemouse then exit;
 mouseactive:=false;
 mouseregs.ax:=2;
 intr($33,mouseregs);
end;

{ Checks if mouse has had a button pressed within a certain area }
function mousein(x1,y1,x2,y2:integer):boolean;
 var answer:boolean;
begin

 if not mouseon then begin;mousein:=false;exit;end;
 if (mouseLB) = FALSE then mousein:=false else
 begin
  if (((mousex DIV 8) >= x1) AND ((mousex DIV 8) <= x2) AND
    (mousey >= y1) AND (mousey <= y2)) then answer:=true
      else answer:=false;
  if answer=true then delay(200);
  mousein:=answer;
 end;
end;

{ Weird function: checks mousein(), and if it returns true, it
  will set a number (returned by function) and a character
  (in parameter list) to the specified values. }
function checkmouse(x1,y1,x2,y2,nv,n:integer;var cv:char;c:char):integer;
begin

 if mousein(x1,y1,x2,y2) then
  begin
   nv:=n;
   cv:=c;
  end;
 checkmouse:=nv;
end;

procedure trackmouse;
begin

 if disablemouse then exit;
 if mouseLB then delay(100);
 mouseregs.ax:=3;
 intr($33,mouseregs);
 mousey:=mouseregs.dx;
 mousex:=mouseregs.cx;
 mouseLB:=((mouseregs.bx AND 1)<>0);
 mouseRB:=((mouseregs.bx AND 2)<>0);
end;



procedure delay(d:word);

begin
 delay2(d);
end;
(*
procedure logentry;
var f:text;i:byte;
begin
 assign(f,'ACK.LOG');
 {$I-} append(f);{$I+}
 if ioresult<>0 then rewrite(f);
 write(f,'Entry: ');
 for i:=0 to paramcount do write(f,paramstr(i)+' ');writeln(f,'');
 close(f);
end;
*)
begin
 mouseon:=false;
 mouseactive:=false;
 pausemouse:=false;
 disablemouse:=false;

end.
