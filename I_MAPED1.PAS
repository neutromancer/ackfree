

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

function selectobj(cats,start,esc:byte):byte;
 {0:anything, 1..12 thatcat,
  101:worldmapok, 102:ownitem 103:ownitem+veh 104:weapons 111:not spell}
 {start:1..255}
const
 XLOC=20;
 YLOC=20;
var
 numobjs:byte; {number of objs in this catagory}
 currcat:byte; {current catagory}
 whatobj,whatobjold:byte; {what obj, 1..numobjs}
 topobj,topobjold:byte;
 objlist:array[1..254] of byte;
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
      1..10:ok:=true;
      end;
  102:case destcat of
      6,7,8,9,11,12:ok:=true;
      end;
  103:case destcat of
      6..12:ok:=true;
      end;
  123:if (destcat<>11) and (destcat<>5) then ok:=true;
  104:case destcat of
      7,8:ok:=true;
      end;
  105:if destcat<6 then ok:=true;
  111:if destcat<>11 then ok:=true;
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
      say(XLOC+12,YLOC+8+(16*i),0,'#'+strnum(objlist[topobj+i])+'  ');
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
 j:=upcase(upcase_sync(readkey));
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
  #32,#13:done:=true;
  #27:begin;whatobj:=0;done:=true;end;
 end; {keycase}

until done;
 if numobjs=0 then whatobj:=0;
 if whatobj<>0 then selectobj:=objlist[whatobj]
 else selectobj:=esc;
 end;


function loadcreatures:boolean;
var cf:file of creaturerec;
    i:byte;
begin
 assign(cf,ADVNAME+CREATUREFILE);
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then begin;loadcreatures:=false;exit;end;


  for i:=1 to 64 do read(cf,crc^[i]);
  if not eof(cf) then
    for i:=65 to MAXCRCS do read(cf,crc^[i])
   else
    begin
	 for i:=65 to MAXCRCS do crc^[i].t:=0;
	end;

 close(cf);
 loadcreatures:=true;
end;


function hinyb(b:byte):byte;
begin
 hinyb:=b DIV 16;
end;
function lonyb(b:byte):byte;
begin
 lonyb:=b MOD 16;
end;
procedure sethinyb(var by:byte;nb:byte);
begin
 by:=lonyb(by)+(nb*16);
end;
procedure setlonyb(var by:byte;nb:byte);
begin
 by:=(hinyb(by)*16)+nb;
end;

function objnam(num:byte):string;
begin
 if num<>0 then objnam:=concat('#',strnum(num),' ',obj^[num].n)
 else objnam:='(?)';
end;


procedure save_longmsgfile(mn:byte);
 var f:file of longmsgrec;
begin
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} rewrite(f); {$I+}
 if ioresult<>0 then exit;
 longmsg.empty:=false;
 seek(f,mn-1);
 write(f,longmsg);
 close(f);
end;

procedure clear_longmsg;
var i,i1:integer;
begin
 longmsg.empty:=true;
 longmsg.chars[1]:='';
 for i1:=1 to 32 do
  begin
   for i:=1 to 22 do
    longmsg.attrs[i,i1]:=0;
    longmsg.chars[1]:=concat(longmsg.chars[1],#1);
  end;
 for i:=2 to 22 do
  longmsg.chars[i]:=longmsg.chars[1];
 end;


procedure create_longmsgfile;
 var i,i1:byte;
  f:file of longmsgrec;
begin
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} rewrite(f); {$I+}
 if ioresult<>0 then exit;
  clear_longmsg;
  write(f,longmsg);
  close(f);
 end;


procedure load_longmsgfile(mn:byte);
 var f:file of longmsgrec;
begin
 if mn=0 then exit;
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then begin;create_longmsgfile;exit;end;
 seek(f,mn-1);
 read(f,longmsg);
 close(f);
end;



procedure show_longmsg;
var i,i1:integer;
begin
 for i1:=1 to 22 do
  for i:=1 to 32 do
   putletter(i*2-1,2+(i1-1)*8,ord(longmsg.chars[i1,i]),longmsg.attrs[i1,i]);
end;

function longmessageedit:integer; {1:save 0:ESC -1:del}
var
 xl,yl:byte;
 attr:byte;
 j,j1:char;
 thischar:byte;
 result:integer;
 yloc:byte;
begin
 yloc:=2;
 xl:=1;yl:=1;attr:=0;
 thickln(317,0,319,199,3);
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,199,319,3);
 thickln(261,0,262,179,3);
 show_longmsg;
repeat
 thischar:=0;
 result:=7;
while not keypressed do
 begin
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),6);
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),0);
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
  end;
 putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
 j:=readkey;
 case j of
  #0:begin
      j1:=readkey;
     case j1 of
      #59:help;
      #32:result:=-1;
      #46:begin;clear_longmsg;show_longmsg;end;
      #120..#125:attr:=ord(j1)-119;
      #129:attr:=0;
      'H':if yl>1 then dec(yl);
      'P':if yl<22 then inc(yl);
      'K':if xl>1 then dec(xl);
      'M':if xl<32 then inc(xl);
      #71:begin;xl:=1;yl:=1;end;
      #79:begin;xl:=1;yl:=22;end;
     end;end;
    #8:if xl>1 then begin;dec(xl);longmsg.chars[yl,xl]:=#1;
       longmsg.attrs[yl,xl]:=0;end;
    #9:if xl<29 then inc(xl,8) else xl:=32;
    #32..#96:thischar:=ord(j)-31;
    #123..#126:thischar:=ord(j)-57;
    #97..#122:thischar:=ord(j)-16;
    #27:result:=1;
    #13:begin;xl:=1;if yl<22 then inc(yl);end;
   end; {case}
  if thischar<>0 then begin
   longmsg.chars[yl,xl]:=chr(thischar);
   longmsg.attrs[yl,xl]:=attr;
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
   if xl<32 then inc(xl) else begin;xl:=1;if yl>1 then dec(yl);end;
  end;
 until result<>7;
 if result=-1 then longmsg.empty:=true else longmsg.empty:=false;
 longmessageedit:=result;
end;



procedure show_shortmsg(yloc:byte);
var i:integer;
begin
 for i:=1 to 37 do
   begin
   putletter(i*2+1,yloc,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
   putletter(i*2+1,yloc+8,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
  end;
  say(1,yloc,5,' ');
  say(1,yloc+8,5,' ');
  say(77,yloc,5,' ');
  say(77,yloc+8,5,' ');
end;

function shortmessageedit(yloc:byte):integer; {1:save 0:ESC -1:del}
var
 xl,yl:byte;
 attr:byte;
 j,j1:char;
 thischar:byte;
 result:integer;
begin
 dec(yloc,8);
 xl:=1;yl:=1;attr:=0;
 show_shortmsg(yloc);
repeat
 thischar:=0;
 result:=7;
while not keypressed do
 begin
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),6);
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),0);
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
  end;
 putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
 j:=(readkey);
 case j of
  #0:begin
      j1:=readkey;
     case j1 of
      #59:help;
      #32:result:=-1;
      #120..#125:attr:=ord(j1)-119;
      #129:attr:=0;
      'H','P':if yl=1 then yl:=2 else yl:=1;
      'K':if xl>1 then dec(xl);
      'M':if xl<37 then inc(xl);
      #71:xl:=1;
     end;end;
    #8:if xl>1 then begin;dec(xl);shortmsg.chars[yl,xl]:=#1;
       shortmsg.attrs[yl,xl]:=0;end;
    #9:if xl<29 then inc(xl,8) else xl:=37;
    #32..#96:thischar:=ord(j)-31;
    #123..#126:thischar:=ord(j)-57;
    #97..#122:thischar:=ord(j)-16;
    #27:result:=1;
    #13:begin;xl:=1;if yl=1 then yl:=2 else yl:=1;end;
   end; {case}
  if thischar<>0 then begin
   shortmsg.chars[yl,xl]:=chr(thischar);
   shortmsg.attrs[yl,xl]:=attr;
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
   if xl<37 then inc(xl) else begin;xl:=1;if yl=1 then yl:=2 else yl:=1;end;
  end;
 until result<>7;
 if result=-1 then shortmsg.empty:=true else shortmsg.empty:=false;
 shortmessageedit:=result;
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

function updowni(var numin:shortint;minim,maxim:integer):byte;
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
 updowni:=ud;
end;

procedure messager(xc,yc:byte;var d:byte);
 var f:file of shortmsgrec;
     filesz:word;
     i,i1:integer;
     ss:string[40];
     oh:byte;
           begin
            oh:=helpindex;helpindex:=49;
            assign(f,ADVNAME+SHORTMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_shortmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
            if d=0 then
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)') else
             say(1,191,0,'HIT …† TO EDIT THIS ONE.  (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                if d=0 then
                begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,shortmsg);
                 if shortmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else i1:=d;
               end else
               begin
                val(ss,i1,i);
                if (i1=0) and (i=0) then d:=0;
                if i<>0 then i1:=0;
                if i1-1>filesz+1 then i1:=0;
               end;

              if i1<>0 then
               begin
                say(xc,yc,0,'#'+strnum(i1)+'   ');
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,shortmsg);end
                 else
                  begin;seek(f,i1-2);read(f,shortmsg);clear_shortmsg;end;
                say(1,yc,0,'EDIT SHORT MESSAGE. PRESS ESC TO SAVE.');
                i:=shortmessageedit(yc+8);
                if i<>0 then
                    begin
                      if i>0 then d:=i1 else d:=0;
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,shortmsg);
                    end;
               end;
             end;
              close(f);
              helpindex:=oh;
            end;


procedure longmessager(xc,yc:byte;var d:byte);
 var f:file of longmsgrec;
     filesz:word;
     i,i1:integer;
     ss:string[40];
     oh:byte;
           begin
            oh:=helpindex;helpindex:=49;
            assign(f,ADVNAME+LONGMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_longmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
            if d=0 then
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)') else
             say(1,191,0,'HIT …† TO EDIT THIS ONE.  (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                if d=0 then
                begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,longmsg);
                 if longmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else i1:=d;
               end else
               begin
                val(ss,i1,i);
                if (i1=0) and (i=0) then d:=0;
                if i<>0 then i1:=0;
                if i1-1>filesz+1 then i1:=0;
               end;

              if i1<>0 then
               begin
                clearscreen;
                say(69,21,4,'MSG');
                say(69,30,4,'#'+strnum(i1));
                say(1,182,0,'ƒ„C:CLEAR MSG,  ESC:QUIT/SAVE      ');
                say(1,190,0,'ƒ„0-ƒ„6:SET COLOR,  ƒ„D:DELETE MSG.');
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,longmsg);end
                 else
                  begin;seek(f,i1-2);read(f,longmsg);clear_longmsg;end;
                i:=longmessageedit;
                if i<>0 then
                    begin
                      if i>0 then d:=i1 else d:=0;
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,longmsg);
                    end;
               end;
             end;
              close(f);
              helpindex:=oh;
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



function straction(actionnum:byte):string;
var s:string;i:byte;
begin
 case actionnum of
   0:S:='DO NOTHING.';
  01:S:='DISPLAY SHORT MSG:';
  02:S:='DISPLAY LONG MSG:';
  03:S:='DISPLAY PICT:';
  04:S:='PLAY SOUND:';
  05:S:='CHANGE H.P.:';
  06:S:='CHANGE H.P. MAX:';
  07:S:='CHANGE M.P.:';
  08:S:='CHANGE M.P. MAX:';
  09:S:='CHANGE STR:';
  10:S:='CHANGE INT:';
  11:S:='CHANGE RNG WP SKL:';
  12:S:='CHANGE WEAP SKL:';
  13:S:='CHANGE ALIGN:';
  14:S:='TAKE ONE OF:';
  15:s:='TAKE ALL OF:';
  16:s:='TAKE ALL OF TYPE:';
  17:S:='GIVE ONE OF:';
  18:S:='TAKE FROM AREA:'; {longest}
  19:S:='PUT HERE:';
  20:S:='KILL IF WITHOUT:';
  21:S:='ACTIVATE ALL.';
  22:S:='HIT USER WITH:';
  23:S:='LET USER AIM:';
  24:S:='SUMMON CREATURE:';
  25:S:='SET "A" TO:';
  26:S:='SET "B" TO:';
  27:S:='SET "C" TO:';
  28:S:='SET "D" TO:';
  29:S:='INC "A" BY:';
  30:S:='INC "B" BY:';
  31:S:='INC "C" BY:';
  32:S:='INC "D" BY:';
  33:S:='DEC "A" BY:';
  34:S:='DEC "B" BY:';
  35:S:='DEC "C" BY:';
  36:S:='DEC "D" BY:';
  37:S:='EXEC MACRO:';
  38:S:='MOVE USER:';
  39:S:='SET VIEWRANGE:';
  40:S:='SET P.ICON:';
  41:s:='PROVOKE';
  42:s:='TORCHLIGHT';
  43:s:='DAYLIGHT';
  44:s:='SET HPREGEN';
  45:s:='SET MPREGEN';
  46:s:='SET POISON';
  47:S:='RUN DIALOGUE';
  end; {case}
  straction:=s;
 end;


{$I I_SNDNAM.PAS}

function stractionp(actionnum,actionparam:byte;endadd:boolean):string;
var s:string;i:byte;
 begin
  s:=' ';
  case actionnum of
   0,21:s:=' ';
   1,2:if actionnum=0 then s:='NONE YET'
        else s:=concat('MESSAGE #',strnum(actionparam));
   3:if actionnum=0 then s:='NONE YET'
       else s:=concat('PICTURE #',strnum(actionparam));
   4:s:=soundname(actionparam);
   6,8..12:if shortint(actionparam)<0 then
         s:=strnum(shortint(actionparam))
         else s:=concat('+',strnum(actionparam));
   5,7:begin
        if shortint(actionparam)<0 then
        s:=strnum(shortint(actionparam))
        else s:=concat('+',strnum(actionparam));
        if actionparam=0 then s:='NORMAL' else s:=s+'    ';
       end;
   13:case actionparam of
       2:s:='EVIL   ';
       3:s:='NEUTRAL';
       4:s:='ANIMAL ';
    else s:='GOOD   ';
      end;
   14,15,17,18,19,20,22,23:if actionparam>0 then s:=objnam(actionparam);
   16:s:=objnames[actionparam];
   24:if (actionparam=0) or (not creatureok) then s:='NONE YET' else
      s:=concat('#',strnum(actionparam),' ',crc^[actionparam].n);
   38:begin
       case hinyb(actionparam) of
        0:s:='NORTH ';
        1:s:='WEST  ';
        2:s:='EAST  ';
        3:s:='SOUTH ';
        end;
       s:=concat(s,'D=',strnum((lonyb(actionparam)*20) DIV 100)+'.'+
         strnum((lonyb(actionparam)*20) MOD 100));
       end;
   25..36,44..47:s:=strnum(actionparam);
   37:if actionparam<>0 then s:='#'+strnum(actionparam) else s:='NONE';
   39,40:s:=strnum(actionparam);
   42,43:if actionparam>240 then s:=strnum(actionparam-240) else s:=strnum(actionparam*10);
   end;{case}
  if endadd then for i:=length(s) to 20 do s:=concat(s,' ');
  stractionp:=s;
  end;



procedure editactionp(act,xloc,yloc:byte;var actp:byte);
 var newactp:byte;
     ss:string[6];
     i,i1:integer;
     redisp:boolean;
     oh:byte;
begin
 oh:=helpindex;helpindex:=44;
 redisp:=false;
 newactp:=actp;

        case act of
          42,43:begin
                 say(xloc,yloc,0,'#     ');
                  ss:=readlin(xloc+2,yloc,4,1);
                  val(ss,i,i1);if i1<>0 then i:=0;
                  if i<10 then i:=i+240;
                  if ss<>#27 then actp:=i;
                  if actp>240 then say(xloc,yloc,1,strnum(actp-240)+'   ') else
                    say(xloc,yloc,1,strnum(actp*10)+'   ');
                 end;

          21,0:exit;
          1:messager(53,183,actp);
          2:longmessager(53,183,actp);
          3,37:begin;
                  say(xloc,yloc,0,'#    ');
                  ss:=readlin(xloc+2,yloc,3,1);
                  val(ss,i,i1);if i1<>0 then i:=0;
                  if ss<>#27 then actp:=i;
                  if actp<>0 then say(xloc,yloc,1,'#'+strnum(actp)+'   ')
                   else say(xloc,yloc,1,'NONE ');
                 end;
         4:begin
           say(xloc-2,yloc,1,'ˆ');
           repeat
            say(xloc,yloc,0,stractionp(act,actp,true));
           until updown(actp,0,NUMSOUNDS)>0;
           redisp:=true;
          end;
        13:begin
            say(xloc,yloc,1,'G,E,N,A?');
            case upcase_sync(readkey) of
             'E':actp:=2;
             'N':actp:=3;
             'A':actp:=4;
             else actp:=1;
            end;
           end;
        5,7:begin
             say(xloc-2,yloc,1,'ˆ');
             repeat
              if shortint(actp)<0 then ss:=strnum(shortint(actp))
              else ss:=concat('+',strnum(shortint(actp)));
              if actp=0 then ss:='NORMAL' else ss:=ss+'    ';
              say(xloc,yloc,0,ss);
             until updowni(shortint(actp),-100,100)>0;
            end;
        6,8..12:begin
             say(xloc-2,yloc,1,'ˆ');
             repeat
              if shortint(actp)<0 then ss:=strnum(shortint(actp))
              else ss:=concat('+',strnum(shortint(actp)));
              say(xloc,yloc,0,ss+'   ');
             until updowni(shortint(actp),-100,100)>0;
            end;
        14,15,17:begin
              actp:=selectobj(103,actp,actp);
              redisp:=true;
              end;
        16:begin
           say(xloc-2,yloc,1,'ˆ');
           repeat
            say(xloc,yloc,0,objnames[actp]);
           until updown(actp,6,12)>0;
           redisp:=true;
          end;
        18,19,20:begin
                if act=19 then i:=123 else i:=0;
                actp:=selectobj(i,actp,actp);
                redisp:=true;
               end;
         22,23:begin
                actp:=selectobj(104,actp,actp);
                redisp:=true;
               end;
          24:if creatureok then begin
                actp:=selectcreature(actp);
                redisp:=true;
               end;
          25..36,44..47:begin
                  ss:=readlin(xloc,yloc,3,1);
                  val(ss,i,i1);
                  if i1=0 then if (i>=0) and (i<=255) then actp:=i;
                 end;
          39: begin
               ss:=readlin(xloc,yloc,2,1);
               val(ss,i,i1);
               if i1<>0 then i:=30;
               if i>20 then i:=30;
               actp:=i;
               say(xloc,yloc,0,strnum(i)+'  ');
              end;
          40: begin
               actp:=grap_select_window(actp);
               redisp:=true;
              end;
          38: begin
               say(xloc-2,yloc,1,'ˆ');
               newactp:=hinyb(actp);
               repeat
                case upcase_sync(readkey) of
                #0:case readkey of
                 #59:help;
                 'H':newactp:=0;
                 'K':newactp:=1;
                 'M':newactp:=2;
                 'P':newactp:=3;
                 end;
                #13:ss:='DONE';
                end;
                if ss<>'DONE' then
                 case newactp of
                 0:ss:='NORTH';
                 1:ss:='WEST ';
                 2:ss:='EAST ';
                 3:ss:='SOUTH';
                end;
                say(xloc,yloc,0,ss);
               until ss='DONE';
               sethinyb(actp,newactp);newactp:=lonyb(actp);
               say(xloc,yloc,1,ss+'Û0 DELAY:ˆ');
               repeat
                say(xloc+26,yloc,0,strnum((newactp*20) DIV 100)+'.'+
                 strnum((newactp*20) MOD 100)+'   ');
               until updown(newactp,0,15)>0;
               setlonyb(actp,newactp);
               redisp:=true;
              end;

        end; {case}
        helpindex:=oh;
        say(1,182,0,BLANK);
        say(1,190,0,BLANK);

      end; {editactionp}
