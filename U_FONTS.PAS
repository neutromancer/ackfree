{$O+}
unit u_fonts;

interface

uses u_graph,crt2,u_adv;

const
      BLOCKS=106;

type xbytes=array[1..2] of byte;
type grpblock=array[1..8] of xbytes;
     blockarray=array[0..0] of grpblock;

var block:^blockarray;

procedure loadfont;
procedure putletter(xb,yy,bb,cs:integer);
procedure say(xx,yy,colorset:integer;s:string);
procedure talksay(xx,yy:byte;s:string);

implementation

procedure loadfont;
var bf:file of grpblock;
   i:integer;
   fn:string;
begin
  fn:=concat(ADVNAME,FONTFILE);
  assign(bf,fn);
  {$I-} reset(bf); {$I+}
  if ioresult<>0 then exit;
  for i:=1 to filesize(bf) do read(bf,block^[i]);
  close(bf);
  if i<100 then
   begin
    assign(bf,'ACKDATA0.FNT');
    reset(bf);
    for i:=34 to 59 do
     begin
      seek(bf,i-1);
      read(bf,block^[i-34+81]);
     end;
    end;
end;


procedure putletter(xb,yy,bb,cs:integer);
var i,i1,i2:integer;
    bx:xbytes;
    b1to2,bit1to4,n:byte;
    eightbytes:array[1..8] of byte;
    bit_on,bit_off:byte;

begin
 if ((mouseon) and (mouseactive)) then hidemouse;
   bit_off:=0;
   case cs of
    0,3:begin;bit_on:=hi(TEXTC0);bit_off:=lo(TEXTC0);end;
    1:begin;bit_on:=hi(TEXTC1);bit_off:=lo(TEXTC1);end;
    2:begin;bit_on:=hi(TEXTC2);bit_off:=lo(TEXTC2);end;
    4:begin;bit_on:=hi(TEXTC4);bit_off:=lo(TEXTC4);end;
    5:begin;bit_on:=hi(TEXTC5);bit_off:=lo(TEXTC5);end;
    6,7:begin;bit_on:=hi(TEXTC6);bit_off:=lo(TEXTC6);end;
   end;
   { VGA char write routines }
   for i:=1 to 8 do
     begin
      if (block^[bb,i,1] AND 3)<>0 then
         eightbytes[4]:=bit_on else eightbytes[4]:=bit_off;
      if (block^[bb,i,1] AND 12)<>0 then
         eightbytes[3]:=bit_on else eightbytes[3]:=bit_off;
      if (block^[bb,i,1] AND 48)<>0 then
         eightbytes[2]:=bit_on else eightbytes[2]:=bit_off;
      if (block^[bb,i,1] AND 192)<>0 then
         eightbytes[1]:=bit_on else eightbytes[1]:=bit_off;
      if (block^[bb,i,2] AND 3)<>0 then
         eightbytes[8]:=bit_on else eightbytes[8]:=bit_off;
      if (block^[bb,i,2] AND 12)<>0 then
         eightbytes[7]:=bit_on else eightbytes[7]:=bit_off;
      if (block^[bb,i,2] AND 48)<>0 then
         eightbytes[6]:=bit_on else eightbytes[6]:=bit_off;
      if (block^[bb,i,2] AND 192)<>0 then
         eightbytes[5]:=bit_on else eightbytes[5]:=bit_off;
      move(eightbytes[1],mem[$a000:xb*4+scrnh[yy+i]],8);
     end;
end;

(*
procedure scanletter(xb,yy,bb:integer);
var i:integer;
begin
 for i:=1 to 8 do
  move(screen[xy(xb,yy+i-1)],block[bb,i],2);
 end;
*)

procedure say(xx,yy,colorset:integer;s:string);
var i:integer;
begin
 if s='' then s:=' ';
 {if HIRES then if colorset<4 then colorset:=0 else colorset:=-1;}
 i:=0;
 repeat
   inc(i);
   if s[i]=#219 then begin;inc(i);colorset:=ord(s[i])-48;inc(i);end;
   {for i:=1 to length(s) do begin}
   if ord(s[i])>130 then putletter(xx,yy,(ord(s[i])-61),colorset) else
   if ord(s[i])<97 then putletter(xx,yy,(ord(s[i])-31),colorset) else
   if (ord(s[i])<123) and (ord(s[i])>96)
     then putletter(xx,yy,(ord(s[i])-16),colorset)
   else putletter(xx,yy,(ord(s[i])-57),colorset);
   xx:=xx+2;
 { end;}
  until i>=length(s);
 if ((mouseon) and (not mouseactive)) then showmouse;
end;

procedure talksay(xx,yy:byte;s:string);
var i:integer;colorset:byte;
begin
 if s='' then s:=' ';
 {if HIRES then if colorset<4 then colorset:=0 else colorset:=-1;}
 i:=0;
 repeat
   inc(i);
   if ord(s[i])>127 then begin;colorset:=2;s[i]:=chr(ord(s[i]) AND 127);end else colorset:=0;
   {for i:=1 to length(s) do begin}

   if ord(s[i])<97 then putletter(xx,yy,(ord(s[i])-31),colorset) else
   if (ord(s[i])<123) and (ord(s[i])>96)
     then putletter(xx,yy,(ord(s[i])-16),colorset)
   else putletter(xx,yy,(ord(s[i])-57),colorset);
   xx:=xx+2;
 { end;}
  until i>=length(s);
 if ((mouseon) and (not mouseactive)) then showmouse;
end;



begin
{ getmem(block,BLOCKS*sizeof(grpblock)); }
end.