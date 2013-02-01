
function digit(n:byte):char;              {digit, convertTOhex, and numtostr}
begin                                     {are used only in converting the}
 if n<10 then digit:=chr(ord('0')+n)      {run-time error into something that}
  else digit:=chr(ord('A')+(n-10));       {can be written to the //LOG.}
end;


function convertTOhex(number:integer):string;
var boofer:array[1..4] of char;
begin
 boofer[1]:=digit(hi(number) DIV 16);
 boofer[2]:=digit(hi(number) MOD 16);
 boofer[3]:=digit(lo(number) DIV 16);
 boofer[4]:=digit(lo(number) MOD 16);
 convertToHex:=boofer;
end;

function numtostr(number:integer):string;
var s:string;
begin
 str(number,s);
 numtostr:=s;
end;

{$F+} procedure CustomExit; {$F-}
 var re:string;
begin
if erroraddr<>NIL then
begin
re:=concat('RUNTIME ERROR ',
            numtostr(exitcode),
            ' AT ',
            converttohex(seg(erroraddr^)),':',
            converttohex(ofs(erroraddr^)));
say(2,2,0,re);erroraddr:=nil;exitcode:=0;readln;
end;
exitproc:=savedexitproc;
end;


function objnam(num:byte):string;
begin
 if num<>0 then objnam:=concat('#',strnum(num),' ',obj^[num].n)
 else objnam:='(?)';
end;


function loadobjs:boolean;
 var f:file of objectrec;
     fc:byte;
begin
 assign(f,concat(ADVNAME,OBJECTFILE));
 {$I-} reset(f); {$I+}
 if IoResult<>0 then begin;loadobjs:=false;exit;end;
 for fc:=1 to MAXOBJS do read(f,obj^[fc]);
 close(f);
 loadobjs:=true;
end;



function grap_select_window(default:byte):byte;
const XLOC=18;YLOC=50;
var ge_whatchar:byte;
   done:boolean;
   whatbefore:byte;
   i,i1,i2:integer;
   pg:byte;
   s:string;
   j:char;

procedure showgrapspage;
var page,i:integer;
begin
 for i:=0 to 9 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
 case ge_whatchar of
  1..24:begin;page:=1;say(XLOC,YLOC+0*8,6,' ');end;
  25..48:begin;page:=25;say(XLOC,YLOC+1*8,6,' ');end;
  49..72:begin;page:=49;say(XLOC,YLOC+2*8,6,' ');end;
  73..96:begin;page:=73;say(XLOC,YLOC+3*8,6,' ');end;
  97..120:begin;page:=97;say(XLOC,YLOC+4*8,6,' ');end;
  121..144:begin;page:=121;say(XLOC,YLOC+5*8,6,' ');end;
  145..168:begin;page:=145;say(XLOC,YLOC+6*8,6,' ');end;
  169..192:begin;page:=169;say(XLOC,YLOC+7*8,6,' ');end;
  193..216:begin;page:=193;say(XLOC,YLOC+8*8,6,' ');end;
  217..240:begin;page:=217;say(XLOC,YLOC+9*8,6,' ');end;
  end;
 for i:=page to page+7 do
   putgrap((i-page+1)*6+XLOC,2+YLOC,i);
 for i:=page+8 to page+15 do
   putgrap((i-page-8+1)*6+XLOC,21+YLOC,i);
 for i:=page+16 to page+23 do
   putgrap((i-page-16+1)*6+XLOC,40+YLOC,i);
end;

begin
 blankbox(XLOC*4-3,YLOC-3,XLOC*4+220,YLOC+82);
 drawh(XLOC*4-2,YLOC-2,XLOC*4+219,3);
 drawh(XLOC*4-2,YLOC+81,XLOC*4+219,3);
 drawv(XLOC*4-2,YLOC-2,YLOC+81,3);
 drawv(XLOC*4+219,YLOC-2,YLOC+81,3);
 say(XLOC+6,YLOC+70,0,'‡UP   ‡DN   ˆ‰   Š   …†');
 ge_whatchar:=default;
 if ge_whatchar=0 then inc(ge_whatchar);
 whatbefore:=ge_whatchar;
 showgrapspage;
 repeat
  done:=false;
  case ge_whatchar of
  1..24:pg:=1;
  25..48:pg:=25;
  49..72:pg:=49;
  73..96:pg:=73;
  97..120:pg:=97;
  121..144:pg:=121;
  145..168:pg:=145;
  169..192:pg:=169;
  193..216:pg:=193;
  217..240:pg:=217;
  end;
i:=ge_whatchar-pg+1;
case i of
 1..8:i1:=2;
 9..16:i1:=21;
 17..24:i1:=40;
 end;
i:=((i-1) MOD 8)+1;
putthing(i*6-1+XLOC,YLOC+i1,3);
putthing(i*6-1+XLOC,YLOC+i1+4,3);
putthing(i*6-1+XLOC,YLOC+i1+8,3);
putthing(i*6-1+XLOC,YLOC+i1+12,3);
putthing(i*6+4+XLOC,YLOC+i1,3);
putthing(i*6+4+XLOC,YLOC+i1+4,3);
putthing(i*6+4+XLOC,YLOC+i1+8,3);
putthing(i*6+4+XLOC,YLOC+i1+12,3);
  j:=upcase_sync(readkey);
i2:=TEXTC0 MOD 256;
putthing(i*6-1+XLOC,YLOC+i1,i2);
putthing(i*6-1+XLOC,YLOC+i1+4,i2);
putthing(i*6-1+XLOC,YLOC+i1+8,i2);
putthing(i*6-1+XLOC,YLOC+i1+12,i2);
putthing(i*6+4+XLOC,YLOC+i1,i2);
putthing(i*6+4+XLOC,YLOC+i1+4,i2);
putthing(i*6+4+XLOC,YLOC+i1+8,i2);
putthing(i*6+4+XLOC,YLOC+i1+12,i2);
 case j of
  #0:case readkey of
   #59:help;
   'K':if ge_whatchar>pg then dec(ge_whatchar) else ge_whatchar:=pg+23;
   'M':if ge_whatchar<pg+23 then inc(ge_whatchar) else ge_whatchar:=pg;
   'H':if (ge_whatchar-8)>=pg then ge_whatchar:=ge_whatchar-8;
   'P':if (ge_whatchar+8)<=pg+23 then ge_whatchar:=ge_whatchar+8;
   'I':begin;if ge_whatchar>24 then ge_whatchar:=ge_whatchar-24
       else ge_whatchar:=(GRAPS-23);
           showgrapspage;end;
   'Q':begin;if ge_whatchar<(GRAPS-23) then ge_whatchar:=ge_whatchar+24
       else ge_whatchar:=1;
           showgrapspage;end;
   #46:begin;done:=true;grap_select_window:=255;end;
   end;
 #13:begin;done:=true;grap_select_window:=ge_whatchar;end;
 #27:begin;done:=true;grap_select_window:=default;end;
 end;
 until done;
end;

function selectobj(cats,start,esc:byte):byte;
 {0:anything, 1..12 thatcat,
  101:worldmapok, 102:ownitem 103:ownitem+veh 104:weapons}
 {start:1..255}
const
 XLOC=20;
 YLOC=20;
var
 numobjs:byte; {number of objs in this catagory}
 currcat:byte; {current catagory}
 whatobj,whatobjold:byte; {what obj, 1..numobjs}
 topobj,topobjold:byte;
 objlist:array[1..255] of byte;
 done:boolean;
 redisplay_sidebar:boolean;
 i:integer;
 j:char;

function incats(destcat:byte):boolean;
 var ok:boolean;
begin
 ok:=false;
 case cats of
  0:ok:=true;
  1..12: if destcat=cats then ok:=true;
  101:case destcat of
      1,2,3,4,5,10:ok:=true;
      end;
  102:case destcat of
      6,7,8,9,11,12:ok:=true;
      end;
  103:case destcat of
      6..12:ok:=true;
      end;
  104:case destcat of
      7,8:ok:=true;
      end;
  123:case destcat of
       6,7,8,9,11:ok:=true;
      end;
 end; {case cats}
 incats:=ok;
end;

procedure makeobjlist;
var c:byte;
begin
 topobjold:=255;
 whatobjold:=255;
 blankbox(XLOC*4,YLOC+8,XLOC*4+183,YLOC+153);
 say(XLOC+6,YLOC,6,'‰'+OBJNAMES[currcat]);
 numobjs:=0;
 whatobj:=1;
 topobj:=1;
 for c:=1 to 254 do
  if obj^[c].t=currcat then
    begin;inc(numobjs);objlist[numobjs]:=c;end;
end;


begin
 done:=false;
 if start<>0 then
  currcat:=obj^[start].t
  else currcat:=1;
  whatobjold:=1;
  while not incats(currcat) do
   begin
    cycle(currcat,1,12,+1);
    inc(whatobjold);
    if whatobjold>15 then exit;
   end;
 whatobjold:=255;
 blankbox(XLOC*4-3,YLOC-3,XLOC*4+187,YLOC+156);
 drawh(XLOC*4-2,YLOC-2,XLOC*4+186,3);
 drawh(XLOC*4-2,YLOC+155,XLOC*4+186,3);
 drawv(XLOC*4-2,YLOC-2,YLOC+155,3);
 drawv(XLOC*4+186,YLOC-2,YLOC+155,3);
  makeobjlist;
    if start<>0 then
   begin
    for i:=1 to numobjs do if objlist[i]=start then whatobj:=i;
    if whatobj>9 then topobj:=whatobj-5;
   end;	
repeat
   if numobjs>9 then
    if whatobjold<>whatobj then
   begin
    for i:=1 to 18 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
    i:=trunc(whatobj/numobjs*18);
    say(XLOC,YLOC+i*8,6,' ');           {Remember, whatobj is NOT 1..255}
   end;

if topobjold<>topobj then
  if numobjs=0 then say(XLOC+12,YLOC+8,0,'NONE.')
   else for i:=0 to 8 do
    begin
     if i+topobj<=numobjs then
     begin
       case currcat of
        1,3,5,6,7,8,9,10,12:
          putgrap(XLOC+6,YLOC+8+(16*i),obj^[objlist[topobj+i]].d[1]);
        2,4:if obj^[objlist[topobj+i]].d[1]=255 then
            say(XLOC+6,YLOC+8+(16*i),0,'?') else
             putgrap(XLOC+6,YLOC+8+(16*i),obj^[objlist[topobj+i]].d[1]);
       end;
      say(XLOC+12,YLOC+16*(i+1),0,obj^[objlist[topobj+i]].n);
     if cats<>123 then
      say(XLOC+12,YLOC+8+(16*i),0,'#'+strnum(objlist[topobj+i])+'  ')
     else
      say(XLOC+12,YLOC+8+(16*i),0,'#'+strnum(objlist[topobj+i])+': '+
       strnum(ack.PINV[objlist[topobj+i]])+'  ');

     end
     else begin
      say(XLOC+6,YLOC+8+(16*i),0,'                   ');
      say(XLOC+6,YLOC+16*(i+1),0,'                   ');
      end;
    end;
 if numobjs>0 then
  begin
   say(XLOC+10,YLOC+8+(16*(whatobj-topobj)),6,' ');
   say(XLOC+10,YLOC+(16*(whatobj-topobj+1)),6,' ');
  end;
 topobjold:=topobj;
 whatobjold:=whatobj;
 j:=upcase_sync(readkey);
  say(XLOC+10,YLOC+8+(16*(whatobj-topobj)),0,' ');
  say(XLOC+10,YLOC+(16*(whatobj-topobj+1)),0,' ');
 case j of
  #0:case readkey of
   #59:help;
   'K':begin;repeat cycle(currcat,1,12,-1) until incats(currcat);
       makeobjlist;end;
   'M':begin;repeat cycle(currcat,1,12,+1) until incats(currcat);
       makeobjlist;end;
   'H':if whatobj>topobj then dec(whatobj)
       else if topobj>9 then begin;dec(topobj,9);dec(whatobj);end
       else begin;topobj:=1;whatobj:=1;end;
   'P':if whatobj<numobjs then
        if whatobj<topobj+8 then inc(whatobj)
        else begin;topobj:=whatobj+1;inc(whatobj);end;
   'I':if topobj>9 then begin;dec(topobj,9);whatobj:=topobj;end
       else begin;topobj:=1;whatobj:=1;end;
   'Q':if topobj+9<=numobjs then begin;inc(topobj,9);whatobj:=topobj;end
       else begin;topobj:=numobjs;whatobj:=numobjs;end;
   'G':begin;topobj:=1;whatobj:=1;end;
   'O':begin;topobj:=numobjs;whatobj:=numobjs;end;
  end; {0case}
   '+':if cats=123 then if ack.PINV[objlist[whatobj]]<255 then
        begin;topobjold:=0;inc(ack.PINV[objlist[whatobj]]);end;
   '-':if cats=123 then if ack.PINV[objlist[whatobj]]>0 then
        begin;topobjold:=0;dec(ack.PINV[objlist[whatobj]]);end;
  #32,#13:if cats<>123 then done:=true;
  #27:begin;whatobj:=0;done:=true;end;
 end; {keycase}

until done;
 if numobjs=0 then whatobj:=0;
 if whatobj<>0 then selectobj:=objlist[whatobj]
 else selectobj:=esc;
 end;

function updown(var numin:byte;minim,maxim:byte):byte;
var ud:byte;
begin
 ud:=0;
 case upcase_sync(readkey) of
  #0: case readkey of
     #59:help;
     'H','K':if numin>=maxim then numin:=minim else inc(numin);
     'M','P':if numin<=minim then numin:=maxim else dec(numin);
     'G':numin:=minim;
     'O':numin:=maxim;
     end;
  #32,#13:ud:=2;
  #27:ud:=1;
 end;
 updown:=ud;
end;


procedure loadconfig;
var ackf:file of masterrec;
    s:string;
    tf:text;
    ioe:integer;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf);
 ioe:=ioresult;
 if ioe<>0 then
   begin;ADVNAME:='NONAME';chdir(systemdir+'.');exit;end;
 read(ackf,ack);
 close(ackf);
 {$I+}


end;

procedure saveconfig;
var ackf:file of masterrec;
begin

 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} rewrite(ackf); {$I+}
 if ioresult<>0 then exit;
 write(ackf,ack);
 close(ackf);
end;
