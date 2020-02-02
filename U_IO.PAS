{$O+}
unit u_io;

interface

uses crt2,u_fonts,u_adv,u_help;

const barcolor:byte=4;

function readlin(xat,yat:integer;maxchars,typeofchars:byte):string;
function strnum(n:longint):string;

implementation

function readlin;

type setos=set of char;
     setosa=array[0..2] of setos;
{0: any chars, 1: number only, 2: filename chars}

const allowedchars:setosa=( [#32..#126] , ['1'..'9','0'] ,
   ['A'..'Z','-','!','&','1'..'9','0','_'] );

var cp:byte;
    inkey:char;
    s:string;
    showstr:string;
    blankstr:string;
    insmode,done:boolean;
    c:byte;
    lengths:byte;

begin
hidemouse;
pausemouse:=true;
blankstr:='';
for cp:=1 to maxchars do blankstr:=concat(blankstr,' ');
cp:=1;
s:='';
insmode:=true;
done:=false;
repeat
if ord(s[0])>maxchars then s[0]:=chr(maxchars);

showstr:=blankstr;
move(s[1],showstr[1],length(s));
say(xat,yat,barcolor,showstr+'Û0 ');

say(xat+( (cp-1)*2 ),yat,6,' ');

inkey:=upcase(readkey);
case inkey of
 #32..#126:if (inkey in allowedchars[typeofchars]) then
          if length(s)<=maxchars then
            begin {string can grow}
              if cp<=maxchars then
              begin
                if insmode then s:=concat(s,s[length(s)]);
                if insmode then move(s[cp],s[cp+1],length(s)-cp);
                s[cp]:=inkey;inc(cp);
               end;
            end
           else
           begin {string can NOT grow}
             if cp<length(s) then
              begin
                if insmode then move(s[cp],s[cp+1],length(s)-cp+1);
                s[cp]:=inkey;inc(cp);
              end;

            end;
    #8:if cp>1 then begin;dec(cp);
       move(s[cp+1],s[cp],length(s)-cp);dec(s[0]);end;
    #0:case readkey of
        #59:help;
        #75:if cp>1 then dec(cp);
        #77:if cp<length(s) then inc(cp) else
          if length(s)<maxchars then begin;inc(cp);s:=concat(s,' ');end;
        {#82:if insmode=true then insmode:=false else insmode:=true;}
        #83:if cp<=length(s) then
        begin;move(s[cp+1],s[cp],length(s)-cp);dec(s[0]);end;
       end; {0case}
     #13:done:=true;
     #27:begin;s:=#27;done:=true;end;
     end; {case}
until done;
readlin:=s;
pausemouse:=false;
showmouse;
end;

function strnum;
var s:string;
begin
 str(n,s);
 strnum:=s;
end;


begin
end.
