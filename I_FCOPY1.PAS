var othergrap:^graparray256;



procedure initconfig;
var i:byte;
begin

 with ack do begin
  ackversion:=ACKVERSION;

  {for i:=1 to BLANKSPACE_SIZE do blankspace[i]:=0;}
  criminal:=0;

  copytype:=0;
  password:=#27;
  playericon:=1;
  plregion:=0;
  plxch:=0;plych:=0;
  plxloc:=0;plyloc:=0;
  plvehicle:=0;
  pweapready:=0;
  for i:=2 to 254 do pinv[i]:=0;
  pcash:=0;
  race[1]:='HUMAN';
  race[2]:='DWARF';
  race[3]:='ELF';
  HP[1]:=10;HP[2]:=12;HP[3]:=8;HP[0]:=0;
  for i:=0 to 3 do HPmax[i]:=HP[i];
  MP[1]:=12;MP[2]:=4;MP[3]:=10;MP[0]:=0;
  for i:=0 to 3 do MPmax[i]:=MP[i];
  strength[1]:=10;strength[2]:=14;strength[3]:=8;strength[0]:=0;
  intelligence[1]:=14;intelligence[2]:=7;
  intelligence[3]:=13;intelligence[0]:=0;
  weapskill[1]:=30;weapskill[2]:=50;weapskill[3]:=25;weapskill[0]:=0;
  rweapskill[1]:=40;rweapskill[2]:=15;rweapskill[3]:=60;rweapskill[0]:=0;
  for i:=0 to 3 do icon[0]:=1;
  for i:=0 to 3 do begin;vara[i]:=0;varb[i]:=0;varc[i]:=0;vard[i]:=0;end;

  playername:=' ';
  titlepic:=0;titlemsg:=0;
  intropic:=0;intromsg:=0;
  intromacro:=0;titlemacro:=0;
 end;
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


var startdir:string;

function ackfinder(f_Ext,bartop:string):string;
 var
 files:array[1..42] of string[10];
 fcolors:array[1..42] of byte;
 sr:searchrec;
 fc:byte;
 done:boolean;
 whatf:byte;
 j:char;
 thisdir:string;
 x,y:byte;

procedure showdirs;
begin
 whatf:=1;
 clearscreen;
 say(2,2,6,bartop);
 getdir(0,ss);if length(ss)<20 then ss:='CURRENT DIRECTORY: '+ss;
 if length(ss)>39 then ss:='‰'+copy(ss,length(ss)-37,38);
 say(1,15,0,ss);
 say(1,169,0,'SELECT AN ADVENTURE AND PRESS Û6…†Û0.');
 say(1,179,0,'SUBDIRECTORIES APPEAR IN BRACKETS.');
 say(2,189,6,'ESCÛ0: ABORT');
 fc:=1;
 files[1]:='{DISK}';fcolors[1]:=1;
 findfirst('*.',16,sr);
 while doserror=0 do
  begin
   if sr.name<>'.' then
    begin;inc(fc);fcolors[fc]:=2;files[fc]:='['+sr.name+']';end;
   findnext(sr);
  end;
 findfirst('*'+'.'+f_Ext,0,sr);
 while doserror=0 do
  begin
   inc(fc);
   with sr do
    files[fc]:=copy(name,1,length(name)-4);
   fcolors[fc]:=0;
   findnext(sr);
  end;
 if fc<=14 then i1:=fc else i1:=14;
 for i:=1 to i1 do
  say(5,25+(i*8),fcolors[i],files[i]);
 if fc<=28 then i1:=fc else i1:=28;
 for i:=15 to i1 do
  say(30,25+(i-14)*8,fcolors[i],files[i]);
 for i:=29 to fc do
  say(55,25+(i-28)*8,fcolors[i],files[i]);
end;

procedure showfn(c,n:byte);
 var x,y:byte;
begin
 if n>28 then begin;x:=55;y:=25+(n-28)*8;end else
 if n>14 then begin;x:=30;y:=25+(n-14)*8;end else
 begin;x:=5;y:=25+(n*8);end;
 say(x,y,c,files[n]);
end;

begin
 getdir(0,startdir);
 showdirs;
 repeat
  done:=false;
  showfn(6,whatf);
  j:=readkey;
  showfn(fcolors[whatf],whatf);
  case j of
   #0:case readkey of
       #59:help;
       'H':if whatf>1 then dec(whatf) else whatf:=fc;
       'P':if whatf<fc then inc(whatf) else whatf:=1;
       'K':if whatf-14>=1 then dec(whatf,14);
       'M':if whatf+14<=fc then inc(whatf,14);
       'G','I':whatf:=1;
       'O','Q':whatf:=fc;
      end;
   #32,#13:if (files[whatf,1]='[') and (files[whatf,length(files[whatf])]=']')
           then begin
            chdir(copy(files[whatf],2,length(files[whatf])-2));
            showdirs;
           end else if whatf=1 then
            begin
             say(5,33,0,'DRIVE? [A-Z]');
             repeat
              i:=ord(upcase(readkey));
              case chr(i) of
               'A'..'Z':begin;{$I-}chdir(chr(i)+':');{$I+}done:=true;end;
              end;
             until done;
             done:=false;
            end else done:=true;
   #27:begin;whatf:=0;done:=true;end;
   end;
 until done;
 if whatf=0 then thisdir:='NONAME'
 else begin
       getdir(0,thisdir);
       thisdir:=thisdir+'.\'+files[whatf];
      end;
 ackfinder:=thisdir;
end;


{$I I_BYTCPY.PAS}


procedure importkit(ss:string;truekit:boolean);
 var oldadvname:string;
     ft:text;s:string[40];
function erasing:boolean;
var f:file;
   sr:searchrec;
  verified:boolean;
  j:char;
begin
 verified:=false;
 findfirst(ADVNAME+'.*',0,sr);
 while doserror=0 do
  begin
   if not verified then
    begin
     say(18,118,2,'THIS WILL OVERWRITE THE');
     say(18,128,2,'CURRENT ADVENTURE: '+ADVNAME);
     say(18,138,2,'DO YOU WANT TO DO THIS?');
     repeat
      j:=upcase(readkey);
      if j=#0 then if readkey=#59 then help;
      if j='N' then begin;erasing:=false;exit;end;
     until j='Y';
     verified:=true;
    end;
   s:=copy(sr.name,pos('.',sr.name)+1,3);
   if pos(s,'-MST-GRP-FNT-')=0 then
    begin
     assign(f,ADVNAME+copy(sr.name,pos('.',sr.name),4));
     erase(f);
    end;
   findnext(sr);
  end;
  erasing:=true;
end;

begin
  clearscreen;
  say(1,1,6,'  IMPORT ADVENTURE KIT   ');
  oldadvname:=ADVNAME;ADVNAME:=ss;
  loadfont;loadgraps;
  drawh(2,13,317,3);
  for i:=0 to 18 do
   putgrap(i*4+2,15,i+1);

if truekit then
begin
  assign(ft,ADVNAME+'.DOC');
  {$I-} reset(ft); {$I+}
  if ioresult<>0 then
   say(10,45,1,'(NO DESCRIPTION FOUND)') else
   for i:=1 to 16 do
    if not eof(ft) then
     begin
      s:=' ';
      readln(ft,s);
      say(0,24+(i*9),0,s);
     end;
    close(ft);
end else
 begin
  say(1,40,0,'abcdefghABCDEFGH1234567890!?,.=+-()"');
  say(1,66,0,'THIS OPTION ALLOWS YOU TO IMPORT');
  say(1,76,0,'ALL BASIC FILES FROM ANOTHER GAME,');
  say(1,86,0,'TREATING THAT GAME AS IF IT WERE A');
  say(1,96,0,'KIT.  INCLUDES: CREATURES, OBJECTS,');
  say(1,106,0,'GRAPHIC TILES, FONT, DIALOGUE,');
  say(1,116,0,'CONFIGURATION, AND SHORT/LONG MSGS.');
  say(1,126,0,'(NOTE THAT MAPS ARE NOT COPIED)');
 end;


  ADVNAME:=oldadvname;
  say(2,190,5,' DO YOU WANT TO USE THIS KIT? ');
  oldadvname:='R';
  repeat
   case upcase(readkey) of
    #0:if readkey=#59 then help;
    'Y':begin;oldadvname:='Y';say(63,190,0,'YES');end;
    'N',#27:begin;oldadvname:='N';say(63,190,0,'NO');end;
   end;
  until oldadvname<>'R';
  if oldadvname<>'Y' then exit;

  clearscreen;say(15,90,6,'  COPYING ADVENTURE KIT...  ');
  if erasing=true then
  begin
  bytecopyall(ss,'BMP',thisgame_dir);
  bytecopyall(ss,'RAW',thisgame_dir);


  bytecopy(ss+CREATUREFILE,thisgame_dir+ADVNAME+CREATUREFILE);
  bytecopy(ss+OBJECTFILE,thisgame_dir+ADVNAME+OBJECTFILE);
  bytecopy(ss+GRAPHICSFILE,thisgame_dir+ADVNAME+GRAPHICSFILE);
  bytecopy(ss+'.GR2',thisgame_dir+ADVNAME+'.GR2');

  bytecopy(ss+FONTFILE,thisgame_dir+ADVNAME+FONTFILE);
  bytecopy(ss+DIALOGUEFILE,thisgame_dir+ADVNAME+DIALOGUEFILE);
  bytecopy(ss+'.KIT',thisgame_dir+ADVNAME+MASTERFILE);
  bytecopy(ss+SHORTMSGFILE,thisgame_dir+ADVNAME+SHORTMSGFILE);
  bytecopy(ss+LONGMSGFILE,thisgame_dir+ADVNAME+LONGMSGFILE);
  bytecopy(ss+'.MCR',thisgame_dir+ADVNAME+'.MCR');
  bytecopy(ss+'.MDX',thisgame_dir+ADVNAME+'.MDX');
  bytecopy(ss+'.PSF',thisgame_dir+ADVNAME+'.PSF');
  bytecopy(ss+'.SND',thisgame_dir+ADVNAME+'.SND');
  end;
  chdir(thisgame_dir+'.');
end;

(*
procedure copyadventure;
 var sr:searchrec;
     verified:boolean;
     listfile:text;
     s:string;

procedure erasing;
var f:file;
  j:char;
  s:string;
begin
 verified:=false;
 findfirst(ss+'.*',0,sr);
 while doserror=0 do
  begin
   if not verified then
    begin
     say(18,118,2,'THIS WILL OVERWRITE AN');
     say(18,128,2,'EXISTING ADVENTURE: ARE YOU');
     say(18,138,2,'SURE YOU WANT TO DO THIS?');
     repeat
      j:=upcase(readkey);
      if j=#0 then if readkey=#59 then help;
      if j='N' then exit;
     until j='Y';
     verified:=true;
    end;
   s:=copy(sr.name,pos('.',sr.name)+1,3);
   if pos(s,'-MST-GRP-FNT-')=0 then
    begin
     assign(f,ADVNAME+copy(sr.name,pos('.',sr.name),4));
     erase(f);
    end;
   findnext(sr);
  end;
end;

begin
 clearscreen;
 say(1,2,6,' COPY CURRENT ADVENTURE ');
 say(3,20,0,'ENTER THE PATH AND FILENAME FOR');
 say(3,29,0,'THE NEW FILE. DO NOT INCLUDE EXTENTION.');
 ss:=readlin(3,39,35,0);
 if (ss='') or (ss=#27) or (ss[length(ss)]='\') then exit;
 erasing;
 if not verified then exit;
 say(3,69,1,'COPYING');
 findfirst(ADVNAME+'.*',0,sr);
 while doserror=0 do
  begin
   bytecopy(sr.name,ss+copy(sr.name,pos('.',sr.name),4));
   findnext(sr);
  end;
 assign(listfile,ADVNAME+'.LST');
 while (length(ss)>0) and (ss[length(ss)]<>'\') do
 begin
  ss:=copy(ss,1,length(ss)-1);
 end;
 {$I-} reset(listfile); {$I+}
 if ioresult=0 then
  while not eof(listfile) do
   begin
    say(19,69,2,sr.name+'       ');
    readln(listfile,s);
    bytecopy(s,ss+s);
   end;
 close(listfile);
end;
*)





{*******************************************************************}

var othergrap_shared:byte;
    prevtile,otherprevtile:byte;

procedure loadothergraps(fn:string);
var bf:file;
    i:integer;
begin
 fn:=concat(fn,GRAPHICSFILE);
 assign(bf,fn);
{$I-} reset(bf,256); {$I+}
if ioresult<>0 then exit;
 for i:=1 to GRAPS do blockread(bf,othergrap^[i],1);
 close(bf);
end;

procedure loadothergraps16(fn:string;start,count:word; color16:byte);
var bf:file of byte;
    i:integer;x,y,b,b2,b3,b4,xc:byte;
begin

 assign(bf,fn);
{$I-} reset(bf); {$I+}
if ioresult<>0 then exit;
seek(bf,(start-1)*128);
if count>GRAPS then count:=GRAPS;
if color16=2 then xc:=2 else xc:=8;
 for i:=1 to count do 
  begin
   for y:=1 to 16 do
   for x:=1 to xc do
    begin
	 case color16 of
	  1:begin
       if not eof(bf) then read(bf,b);
       othergrap^[i,y,(x*2)]:=b AND 15;
       othergrap^[i,y,(x*2)-1]:=(b AND 240) DIV 16;
	  end;
      0:begin
       if not eof(bf) then read(bf,b);
	   othergrap^[i,y,(x*2)-1]:=b;
       if not eof(bf) then read(bf,b);
	   othergrap^[i,y,(x*2)]:=b;
	   end;
	  2:begin
         if not eof(bf) then read(bf,b);
		 if not eof(bf) then read(bf,b2);
		 if not eof(bf) then read(bf,b3);
		 if not eof(bf) then read(bf,b4);
		 othergrap^[i,y,(x-1)*8 +1]:=b AND 128;
		 othergrap^[i,y,(x-1)*8 +2]:=b AND 64;
		 othergrap^[i,y,(x-1)*8 +3]:=b AND 32;
		 othergrap^[i,y,(x-1)*8 +4]:=b AND 16;
		 othergrap^[i,y,(x-1)*8 +5]:=b AND 8;
		 othergrap^[i,y,(x-1)*8 +6]:=b AND 4;
		 othergrap^[i,y,(x-1)*8 +7]:=b AND 2;
		 othergrap^[i,y,(x-1)*8 +8]:=b AND 1;		 

        end;	  	  
     end; {case}
    end;


  end;
 close(bf);

end;

procedure loadothergraps2(fn:string);
var bf:file;
    i:integer;
begin
 fn:=concat(fn,'.GR2');
 assign(bf,fn);
{$I-} reset(bf,256); {$I+}
if ioresult<>0 then exit;
 for i:=1 to GRAPS do blockread(bf,othergrap^[i],1);
 close(bf);
end;

procedure putothergrap(xb,yy,bb:integer);
var i:integer;

begin
 for i:=1 to 16 do
  move(othergrap^[bb,i],mem[scrnl:(xb*4)+scrnh[yy+i]],16);
end;



function othergrap_select_window(default:byte):byte;
const XLOC=20;YLOC=5;
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
   putothergrap((i-page+1)*6+XLOC,2+YLOC,i);
 for i:=page+8 to page+15 do
   putothergrap((i-page-8+1)*6+XLOC,21+YLOC,i);
 for i:=page+16 to page+23 do
   putothergrap((i-page-16+1)*6+XLOC,40+YLOC,i);
end;

begin
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
  j:=readkey;
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
   #46:begin;done:=true;othergrap_select_window:=255;end;
   end;
 #13:begin;done:=true;othergrap_select_window:=ge_whatchar;end;
 #27:begin;done:=true;othergrap_select_window:=255;end;
 'Q','q':begin;othergrap_select_window:=0;done:=true;end;
 end;
 until done;
end;



procedure makeallboxes;
 var XLOC,YLOC:byte;
     i,page:byte;
begin

 XLOC:=20;
 YLOC:=94;

 blankbox(XLOC*4-3,YLOC-3,XLOC*4+220,YLOC+82);
 drawh(XLOC*4-2,YLOC-2,XLOC*4+219,3);
 drawh(XLOC*4-2,YLOC+81,XLOC*4+219,3);
 drawv(XLOC*4-2,YLOC-2,YLOC+81,3);
 drawv(XLOC*4+219,YLOC-2,YLOC+81,3);
 say(XLOC+6,YLOC+70,0,'‡UP   ‡DN   ˆ‰   Š   …†');

 for i:=0 to 9 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
 case prevtile of
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

 XLOC:=20;
 YLOC:=5;

 blankbox(XLOC*4-3,YLOC-3,XLOC*4+220,YLOC+82);
 drawh(XLOC*4-2,YLOC-2,XLOC*4+219,3);
 drawh(XLOC*4-2,YLOC+81,XLOC*4+219,3);
 drawv(XLOC*4-2,YLOC-2,YLOC+81,3);
 drawv(XLOC*4+219,YLOC-2,YLOC+81,3);
 say(XLOC+6,YLOC+70,0,'‡UP   ‡DN   ˆ‰   Š   …†');

 for i:=0 to 9 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
 case otherprevtile of
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
   putothergrap((i-page+1)*6+XLOC,2+YLOC,i);
 for i:=page+8 to page+15 do
   putothergrap((i-page-8+1)*6+XLOC,21+YLOC,i);
 for i:=page+16 to page+23 do
   putothergrap((i-page-16+1)*6+XLOC,40+YLOC,i);

end;

procedure copysomegraps(var fn:string);


begin
 clearscreen;
 say(0,15,5,' SOURCE ');
 say(0,104,5,' TARGET ');
 say(0,35,0,'OTHER');
 say(0,44,0,'ADVENTURE');
 say(0,124,0,'YOUR');
 say(0,133,0,'ADVENTURE');
 othergrap_shared:=0;
 prevtile:=1;otherprevtile:=1;
 loadothergraps(fn);
 repeat
  makeallboxes;
  say(1,181,0,'SELECT A GRAPHIC TILE TO BE COPIED.');
  say(1,190,0,'[ENTER] TO SELECT,  [Q] TO QUIT.');
  otherprevtile:=othergrap_select_window(otherprevtile);
  if (otherprevtile=0) or (otherprevtile=255) then othergrap_shared:=99
  else
   begin
    prevtile:=grap_select_window(prevtile,prevtile);
    if prevtile=0 then othergrap_shared:=99 else
     if prevtile<241 then
      begin
       move(othergrap^[otherprevtile],graphic^[prevtile],256);
      end;
   end;

 until othergrap_shared=99;
 savegraps;
end;


procedure savegraps2;
var bf:file;
    i:integer;
    fn:string;
begin
 fn:=concat(ADVNAME,'.GR2');
 assign(bf,fn);
 {$I-} rewrite(bf,256); {$I+}
 if ioresult<>0 then begin;sound(100);delay(100);nosound;exit;end;
 for i:=1 to GRAPS do blockwrite(bf,graphic^[i],1);
 close(bf);
end;

procedure copysomegraps2(var fn:string);


begin
 clearscreen;
 say(0,15,5,' SOURCE ');
 say(0,104,5,' TARGET ');
 say(0,35,0,'OTHER');
 say(0,44,0,'ADVENTURE');
 say(0,124,0,'YOUR');
 say(0,133,0,'ADVENTURE');
 othergrap_shared:=0;
 prevtile:=1;otherprevtile:=1;
 loadothergraps2(fn);loadgraps2(false);
 repeat
  makeallboxes;
  say(1,181,0,'SELECT A SECONDARY TILE TO COPY. ');
  say(1,190,0,'[ENTER] TO SELECT,  [Q] TO QUIT.');
  otherprevtile:=othergrap_select_window(otherprevtile);
  if (otherprevtile=0) or (otherprevtile=255) then othergrap_shared:=99
  else
   begin
    prevtile:=grap_select_window(prevtile,prevtile);
    if prevtile=0 then othergrap_shared:=99 else
     if prevtile<241 then
      begin
       move(othergrap^[otherprevtile],graphic^[prevtile],256);
      end;
   end;

 until othergrap_shared=99;
 savegraps2;loadgraps;
end;



procedure copysomegraps16(var fn:string; start,count:word; color16:byte);


begin
 clearscreen;
 say(0,15,5,' SOURCE ');
 say(0,104,5,' TARGET ');
{ say(0,35,0,'16 COLOR');}
 say(0,44,0,'RAW FILE');
 say(0,124,0,'YOUR');
 say(0,133,0,'ADVENTURE');
 othergrap_shared:=0;
 prevtile:=1;otherprevtile:=1;
 loadothergraps16(fn,start,count,color16);
 repeat
  makeallboxes;
  say(1,181,0,'SELECT A GRAPHIC TILE TO BE COPIED.');
  say(1,190,0,'[ENTER] TO SELECT,  [Q] TO QUIT.');
  otherprevtile:=othergrap_select_window(otherprevtile);
  if (otherprevtile=0) or (otherprevtile=255) then othergrap_shared:=99
  else
   begin
    prevtile:=grap_select_window(prevtile,prevtile);
    if prevtile=0 then othergrap_shared:=99 else
     if prevtile<241 then
      begin
       move(othergrap^[otherprevtile],graphic^[prevtile],256);
      end;
   end;

 until othergrap_shared=99;
 savegraps;
end;


procedure copysomegraps216(var fn:string; start,count:word; color16:byte);


begin
 clearscreen;
 say(0,15,5,' SOURCE ');
 say(0,104,5,' TARGET ');
{ say(0,35,0,'16 COLOR');}
 say(0,44,0,'RAW FILE');
 say(0,124,0,'YOUR');
 say(0,133,0,'ADVENTURE');
 othergrap_shared:=0;
 prevtile:=1;otherprevtile:=1;
 loadothergraps16(fn,start,count,color16);loadgraps2(false);
 repeat
  makeallboxes;
  say(1,181,0,'SELECT A SECONDARY TILE TO COPY. ');
  say(1,190,0,'[ENTER] TO SELECT,  [Q] TO QUIT.');
  otherprevtile:=othergrap_select_window(otherprevtile);
  if (otherprevtile=0) or (otherprevtile=255) then othergrap_shared:=99
  else
   begin
    prevtile:=grap_select_window(prevtile,prevtile);
    if prevtile=0 then othergrap_shared:=99 else
     if prevtile<241 then
      begin
       move(othergrap^[otherprevtile],graphic^[prevtile],256);
      end;
   end;

 until othergrap_shared=99;
 savegraps2;loadgraps;
end;

{*******************************************************************}


procedure deleteadventure;

begin

 clearscreen;
            say(6,70,4,' ARE YOU SURE YOU WANT TO  ');
            say(6,78,4,' DELETE ALL THE GAME-IN-   ');
            say(6,86,4,' PROGRESS FILES/SAVEGAMES? ');
            say(6,94,4,' PRESS [Y] TO CONFIRM.     ');
            if upcase(readkey)='Y' then
              
			  begin
			   say(20,114,0,'WORKING...');
			   deletesaves(ADVNAME);
			  end; 
			 
end;


{$I I_MSGEXP.PAS}





(*

procedure exportconfig;
var f:text;i:byte;
procedure lf;
begin
 writeln(f,'');
end;

begin

 assign(f,'CONFIG.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult<>0 then exit;
 writeln(f,'Adventure name: '+ADVNAME);
 writeln(f,'This file is an export of the configuration editor.');
 writeln(f,'DO NOT EDIT THIS FILE, it is just for reference.');
 lf;lf;

with ack do begin
writeln(f,'General info:');
lf;
writeln(f,' Version code: '+strnum(ackversion)+' (determines color palette)');
writeln(f,' Animation speed: '+strnum(anim_speed));
if password<>#27 then writeln(f,' Password: '+password);
writeln(f,' HP Regen: '+strnum(regen_hp)+'  MP Regen: '+strnum(regen_mp));
writeln(f,' Step macro: '+strnum(stepmacro)+'  Step sound: '+soundname(stepsound));
writeln(f,' Bump sound: '+soundname(bumpsound)+'  Melee sound: #98');
writeln(f,' Death macro: '+strnum(deathmacro)+'  Death sound: #99');

if extracommand<>#27 then
  writeln(f,' Extra command: '+extracommand+' (Macro '+strnum(extracommand1)+')');
if extracommand2<>0 then writeln(f,' Extra command #2 macro: '+strnum(extracommand2));

write(f,' Day/night view radius change: '); if time_cycle=1 then writeln(f,'ON') else writeln(f,'OFF');
writeln(f,' Daily macro: '+strnum(day_macro));

lf;
writeln(f,'Title info (performed every time game is launched)');
lf;
writeln(f,' Title picture: '+strnum(titlepic));
writeln(f,' Title long-message: '+strnum(titlemsg));
writeln(f,' Title macro: '+strnum(titlemacro));
lf;
writeln(f,'Intro info (performed when a new character is created)');
lf;
writeln(f,' Intro picture: '+strnum(intropic));
writeln(f,' Intro long-message: '+strnum(intromsg));
writeln(f,' Intro macro: '+strnum(intromacro));
lf;

writeln(f,'Player info:');
lf;
writeln(f,' Player name: '+Playername);
writeln(f,' Starting location: Region '+strnum(plregion)+', location code '+
  strnum(plxch)+','+strnum(plych)+','+strnum(plxloc)+','+strnum(plyloc));
lf;
writeln(f,' Player choices:');
lf;
for i:=1 to 3 do if race[i]<>#255 then
 begin
  writeln(f,'  #'+strnum(i)+' '+race[i]);
  write(f,'    HP: '+strnum(hp[i])+'/'+strnum(hpmax[i])+'  MP:'+strnum(mp[i])+'/'+strnum(mpmax[i]));
  writeln(f,'  STR: '+strnum(strength[i])+'  INT: '+strnum(intelligence[i]));
  write(f,'  Weapon Skill: '+strnum(weapskill[i]));
  writeln(f,'   Ranged Weapon Skill: '+strnum(rweapskill[i]));
  write(f,'    Variables:  A = '+strnum(varA[i])+'   B = '+strnum(varB[i]));
  writeln(f,'   C = '+strnum(varC[i])+'   D = '+strnum(varD[i]));
  lf;
 end;
writeln(f,' Player inventory:');
lf;
if pcash>0 then
   write(f,'  #'+strnum(i)+' '+obj^[(i*0)+1].n+' (Quantity '+strnum(pcash)+')');
for i:=2 to 254 do if pinv[i]>0 then
  begin
   write(f,'  #'+strnum(i)+' '+obj^[i].n);
   if pinv[i]>1 then writeln(f,' (Quantity '+strnum(pinv[i])+')') else lf;
  end;

end; {with ack}

 writeln(f,'');
 writeln(f,'Export completed successfully.');
 close(f);

end;


*)

procedure exportcreatures;
var i,i1,alignment:byte; f:text;



function loadcreatures:boolean;
var cf:file of creaturerec;
    csf:file of word;
    i:byte;
    alignment:byte;
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
 assign(csf,ADVNAME+CREATURESOUNDFILE);
 {$I-} reset(csf); {$I+}
 if ioresult<>0 then
  begin;for i:=1 to MAXCRCS do crcsounds[i]:=0;exit;end;
 for i:=1 to 64 do read(csf,crcsounds[i]);
  if not eof(csf) then   
    for i:=65 to MAXCRCS do read(csf,crcsounds[i])
   else
    begin
	 for i:=65 to MAXCRCS do crcsounds[i]:=0;
	end;  
  

 close(csf);
 loadcreatures:=true;
end;

begin
 if not loadcreatures then exit;
 assign(f,'CREATURE.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult<>0 then exit;
  writeln(f,'Adventure name: '+ADVNAME);
 writeln(f,'This file is an export of the creatures from the creature editor.');
 writeln(f,'DO NOT EDIT THIS FILE, it is just for reference.');
 writeln(f,'You should delete this file before distributing your adventure, as it may contain spoilers!');
 for alignment:=1 to 4 do
  for i:=1 to MAXCRCS do
   with crc^[i] do
    if t=alignment then begin
      writeln(f,''); writeln(f,'');
      write(f,strnum(i)+': '+n+' ');
      case t of
    1:writeln(f,'(good)');
    2:writeln(f,'(evil)');
    3:writeln(f,'(neutral)');
    4:writeln(f,'(animal)');

   end;
      write(f,'    HP: ');
    if hm=0 then write(f,'(Invulnerable)') else if h<>hm then write(f,strnum(h)+' of '+strnum(hm)) else write(f,strnum(hm));
    writeln(f,'  Weapon skill: '+strnum(ws)+'  Ranged weapon skill: '+strnum(rws));
    write(f,'    Equipment: ');
    if fw<>0 then write(f,'#'+strnum(fw)+' '+obj^[fw].n+' ');
    if fr<>0 then write(f,'#'+strnum(fr)+' '+obj^[fr].n+' ');
    if ar<>0 then writeln(f,'#'+strnum(ar)+' '+obj^[ar].n+' ');
	case veh of
	 1..254:case obj^[veh].t of
	          1,2:writeln(f,'    Movement: Limited to terrain: '+'#'+strnum(veh)+' '+obj^[veh].n);
			  6..9,11,12:writeln(f,'    Movement: As if holding: '+'#'+strnum(veh)+' '+obj^[veh].n);
			  10:writeln(f,'    Movement: As if riding: '+'#'+strnum(veh)+' '+obj^[veh].n);
			 end;
     255:writeln(f,'    Movement: Any SPACE terrain (can fly)');
    end;	 

    writeln(f,'');

    writeln(f,'    Loot/Remains: ');
    for i1:=1 to 3 do
     if inv[i1]<>0 then
	   case obj^[inv[i1]].t of
	   1..5:writeln(f,'     #'+strnum(inv[i1])+' '+obj^[inv[i1]].n+' /'+strnum(invn[i1]));
	   6..11:writeln(f,'     #'+strnum(inv[i1])+' '+obj^[inv[i1]].n+' ('+strnum(invn[i1])+'% chance)');
	   12:writeln(f,'     '+strnum(invn[i1]*10)+' of #1 '+obj^[inv[i1]].n+' ');
	   end;
    if ack.ackversion<31 then writeln(f,'    (Note that any %chance settings above will be ignored due to game version)');
    if ack.ackversion>24 then writeln(f,'    Experience: '+strnum((exphi-1)*256 + exp));
    writeln(f,'    Fight sound: '+soundname(hi(crcsounds[i]))+'  Death sound: '+soundname(hi(crcsounds[i])));
    if deathm<>0 then writeln(f,'  Death macro: #'+strnum(deathm));
    if touchm<>0 then writeln(f,'  Touch macro: #'+strnum(touchm));


    end; {with crc}


   writeln(f,'');writeln(f,'');

   writeln(f,'Index:');writeln(f,'');
   for i:=1 to MAXCRCS do
   with crc^[i] do
     if (t>0) and (t<5) then
       begin
       write(f,' '+strnum(i)+': '+n+' ');
       case t of
    1:writeln(f,'(good)');
    2:writeln(f,'(evil)');
    3:writeln(f,'(neutral)');
    4:writeln(f,'(animal)');

   end;
       end;


 writeln(f,'');
 writeln(f,'Export completed successfully.');
 close(f);
end;




procedure exportobjects;
var i:byte; f:text; objtype:byte;

procedure writeshortmsg(n:byte;s:string);
var sf:file of shortmsgrec; smsg:shortmsgrec; x,y,c:byte; write_this_line:boolean;
 begin
   writeln(f,'    '+s+': #'+strnum(n));
   assign(sf,ADVNAME+SHORTMSGFILE);
   {$I-} reset(sf); {$I+}
   if ioresult=0 then
   begin
     if filesize(sf)>=n then seek(sf,n-1) else begin;writeln(f,'**   (WARNING: Invalid Message)');close(sf);exit;end;
     read(sf,smsg);
     if smsg.empty=false then
     begin
     for y:=1 to 2 do
     begin
      write_this_line:=false; s:='     |';
      for x:=1 to 37 do
       begin
        c:=ord(smsg.chars[y,x]);
        s:=s+ackchar(c);
        if c<>1 then write_this_line:=true;
      end; {x}
      if write_this_line then writeln(f,s+'|');
     end; {y}
     end;
    close(sf);
    end; {ioresult}
  end;


begin
 if loadobjs=false then exit;
 assign(f,'OBJECTS.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult=0 then begin
  writeln(f,'Adventure name: '+ADVNAME);
 writeln(f,'This file is an export of the objects from the object editor.');
 writeln(f,'DO NOT EDIT THIS FILE, it is just for reference.');
 writeln(f,'You should delete this file before distributing your adventure, as it may contain spoilers!');
 for objtype:=1 to 12 do
  for i:=1 to MAXOBJS do
  with obj^[i] do
  begin
     if t=objtype then
      begin
       writeln(f,''); writeln(f,'');
       writeln(f,strnum(i)+': '+n+' '+OBJNAMES[t]);
       case t of
       1,2:begin
            write(f,'    Graphic tile: #'+strnum(d[1]));
            if d[1]<>d[6] then write(f,' & #'+strnum(d[6]));
            if d[4]>127 then write(f,' (opaque)');
            if d[4] AND 64=64 then write(f,' (lightsource)');
            case d[13] of
              1..240:writeln(f,'  Player tile: #'+strnum(d[13]));
              255:writeln(f,'  Tile covers player');
              0:writeln(f,'');
              end;
            if d[2]<>0 then
            begin
             writeln(f,'    Action: '+straction(d[2])+'  '+stractionp(d[2],d[3],((d[1]=255) OR (t=1))));
             writeln(f,'    Triggered by: '+strtrigger(d[9])+'  '+strtriggerp(d[9],d[10]));
            end;
            if (d[4] AND 63)=0 then writeln(f,'    Not passable') else
             if (d[4] AND 63)<>1 then
               writeln(f,'    Passable: '+strpassable(d[4])+'  '+strpassablep(d[4],d[5]));
            if d[7]<>0 then writeshortmsg(d[7],'Message if blocked');
            if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
            if ((d[8]<>0) or (d[11]<>0)) then
             begin {this object can disappear}
              write(f,'    Disappear: '+strdisappear(d[8])+'  Structural Strength: ');
              if d[11]=0 then writeln(f,'N/A  ') else writeln(f,strnum(d[11])+'  ');
              write(f,'    Replaced with: ');
              if d[12]=0 then writeln(f,'Nothing') else writeln(f,'#'+strnum(d[12])+' '+obj^[d[12]].n);
             end;
           end; {1,2}
         3,4:begin
            write(f,'    Graphic tile: #'+strnum(d[1]));
            if d[1]<>d[6] then write(f,' & #'+strnum(d[6]));
            if d[4]>127 then write(f,' (opaque)');
            if d[4] AND 64=64 then write(f,' (lightsource)');

            writeln(f,'');
            if d[2]<>0 then
            begin
             writeln(f,'    Action: '+straction(d[2])+'  '+stractionp(d[2],d[3],((d[1]=255) OR (t=3))));
             writeln(f,'    Triggered by: '+strtrigger(d[9])+'  '+strtriggerp(d[9],d[10]));
            end;
            if d[7]<>0 then writeshortmsg(d[7],'Message when blocked');
            if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
            if ((d[8]<>0) or (d[11]<>0)) then
             begin {this object can disappear}
              write(f,'    Disappear: '+strdisappear(d[8])+'  Structural Strength: ');
              if d[11]=0 then writeln(f,'N/A  ') else writeln(f,strnum(d[11])+'  ');
              write(f,'    Replaced with: ');
              if d[12]=0 then writeln(f,'Nothing') else writeln(f,'#'+strnum(d[12])+' '+obj^[d[12]].n);
             end;
            end; {3,4}
          5:begin
            write(f,'    Graphic tile: #'+strnum(d[1]));
            if d[1]<>d[6] then write(f,' & #'+strnum(d[6]));
            if d[4]>127 then write(f,' (opaque)');
            if d[4] AND 64=64 then write(f,' (lightsource)');

            writeln(f,'');
            if d[2]<>0 then
            begin
             writeln(f,'    Action: '+straction(d[2])+'  '+stractionp(d[2],d[3],((d[1]=255) OR (t=1))));
             writeln(f,'    Triggered by: '+strtrigger(d[9])+'  '+strtriggerp(d[9],d[10]));
            end;
            if (d[4] AND 63)=0 then writeln(f,'    Not passable') else
             if (d[4] AND 63)<>1 then
               writeln(f,'    Passable: '+strpassable(d[4])+'  '+strpassablep(d[4],d[5]));
            if d[13]<>0 then writeshortmsg(d[13],'Message when passed');
            if d[7]<>0 then writeshortmsg(d[7],'Message if blocked');
            if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
            if ((d[8]<>0) or (d[11]<>0)) then
             begin {this object can disappear}
              write(f,'    Disappear: '+strdisappear(d[8])+'  Structural Strength: ');
              if d[11]=0 then writeln(f,'N/A  ') else writeln(f,strnum(d[11])+'  ');
              write(f,'    Replaced with: ');
              if d[12]=0 then writeln(f,'Nothing') else writeln(f,'#'+strnum(d[12])+' '+obj^[d[12]].n);
             end;
           end; {5}
         6:begin
             writeln(f,'    Graphic tile: #'+strnum(d[1]));
             if d[2]<>0 then
              writeln(f,'    Action: '+straction(d[2])+'  '+stractionp(d[2],d[3],true));
             if d[6]<>0 then writeln(f,'    (Disappears when used)');
             if d[4]<>0 then if d[4]<255 then begin
               write(f,'    Usage requires: '+obj^[d[4]].n);
               if d[5]<100 then writeln(f,'  (Used '+strnum(d[5])+'% of the time)') else writeln(f,'');
              end else writeln(f,'    Usage requires energy ('+strnum(d[5])+'MP)');
              if d[7]<>0 then writeshortmsg(d[7],'Message if used');
              if d[8]<>0 then writeshortmsg(d[8],'Message if inoperative');
              if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
              writeln(f,'    Weight: '+strnum((d[9]*256)+d[10])+'  Price: '+strnum((d[11]*256)+d[12]));

           end; {6}
         7:begin
             write(f,'    Graphic tile: #'+strnum(d[1]));
             if d[13]<>0 then if d[13]=255 then writeln(f,'  (Player uses weapon tile)') else
             if d[13]=0 then writeln(f,'');
             writeln(f,'  Player tile: #'+strnum(d[13]));
             writeln(f,'    Damage: '+strnum(d[4]));
             writeln(f,'    Sound effect: '+soundname(d[2]));
              if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
              writeln(f,'    Weight: '+strnum((d[9]*256)+d[10])+'  Price: '+strnum((d[11]*256)+d[12]));

           end; {7}
          8:begin
             write(f,'    Graphic tile: #'+strnum(d[1]));
             if d[13]<>0 then if d[13]=255 then writeln(f,'  (Player uses weapon tile)') else
               writeln(f,'  Player tile: #'+strnum(d[13]));
             if d[13]=0 then writeln(f,'');
             write(f,'    Damage: '+strnum(d[4])+'  Range: '+
              strnum(lonyb(d[5])+1)+' '+strblastradius(hinyb(d[5])));
                  case d[3] of
                  0:writeln(f,' invisible');
                  1..240:writeln(f,' tiled');
                  241:writeln(f,' dot');
                  242:writeln(f,' line');
                  243:writeln(f,' ball');
                  244:writeln(f,' beam');
                  end;
             writeln(f,'    Sound effect: '+soundname(d[2]));
             if d[6]<>0 then if d[6]<255 then begin
               write(f,'    Usage requires: '+obj^[d[6]].n);
               if d[7]<100 then writeln(f,'  (Used '+strnum(d[7])+'% of the time)') else writeln(f,'');
              end else writeln(f,'    Usage requires energy ('+strnum(d[7])+'MP)');

              if d[8]<>0 then writeshortmsg(d[8],'Message if out of ammo');
              if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
              writeln(f,'    Weight: '+strnum((d[9]*256)+d[10])+'  Price: '+strnum((d[11]*256)+d[12]));

           end; {8}
         9:begin
             write(f,'    Graphic tile: #'+strnum(d[1]));
             if d[13]<>0 then if d[13]=255 then writeln(f,'  (Player uses armor tile)') else
               writeln(f,'  Player tile: #'+strnum(d[13]));
             if d[13]=0 then writeln(f,'');
         writeln(f,'    Worn in slot '+strnum(d[2])+', covers '+strnum(d[6])+'%, absorbs '+strnum(d[5]));

              if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
              writeln(f,'    Weight: '+strnum((d[9]*256)+d[10])+'  Price: '+strnum((d[11]*256)+d[12]));
            end; {9}
          10:begin
             write(f,'    Graphic tile: #'+strnum(d[1]));
             if d[13]=0 then writeln(f,'  (Player appearance unchanged)')
              else if d[13]=255 then writeln(f,'  (Vehicle appearance unchanged)')
               else writeln(f,'  (Tile# '+strnum(d[13])+' while used)');
             if d[4]<>0 then writeln(f,'    Built-in weapon: #'+strnum(d[4])+' '+obj^[d[4]].n);
             if d[2]<>0 then writeln(f,'    Counts as: #'+strnum(d[2])+' '+obj^[d[2]].n);
             if d[3]=0 then writeln(f,'    Can go anywhere player can go')
               else writeln(f,'    Can go only on terrain that requires it');
             if d[6]<>0 then if d[6]<255 then begin
             write(f,'    Fuel required: '+obj^[d[6]].n);
             if d[7]<100 then writeln(f,'  (Used '+strnum(d[7])+'% of the time)') else writeln(f,'');
              end else writeln(f,'    Usage requires energy ('+strnum(d[7])+'MP)');
              if d[11]<>0 then writeshortmsg(d[11],'Message when boarded');
              if d[8]<>0 then writeshortmsg(d[8],'Message when out of fuel');
              if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
             writeln(f,'    Weight capacity: '+strnum((d[9]*256)+d[10]));
             if (d[5]<>0) or (d[12]<>0) then
              writeln(f,'    Macro on boarding: '+strnum(d[5])+'   Macro on exit: '+strnum(d[12]));

             end; {9}
         11:begin
             if d[2]<>0 then
              writeln(f,'    Action: '+straction(d[2])+'  '+stractionp(d[2],d[3],true));
             if d[6]<>0 then writeln(f,'    (Disappears when used)');
             if d[4]<>0 then if d[4]<255 then begin
               write(f,'    Usage requires: '+obj^[d[4]].n);
               if d[5]<100 then writeln(f,'  (Used '+strnum(d[5])+'% of the time)') else writeln(f,'');
              end else writeln(f,'    Usage requires energy ('+strnum(d[5])+'MP)');
              if d[7]<>0 then writeshortmsg(d[7],'Message if used');
              if d[8]<>0 then writeshortmsg(d[8],'Message if inoperative');
              if d[11]<>0 then writeln(f,'    Energy used: '+strnum(d[11]));
           end; {11}
          12:begin
            write(f,'    Graphic tile: #'+strnum(d[1]));
            if (d[9]*256)+d[10]>0 then write(f,'  Weight: '+strnum((d[9]*256)+d[10]));
            if d[14]<>0 then writeshortmsg(d[14],'Message if examined');
            end; {12}
        end; {case}
       end; {if object}
  end; {loop}
   writeln(f,'');writeln(f,'');

   writeln(f,'Index:');writeln(f,'');
   for i:=1 to MAXOBJS do
   with obj^[i] do
     if (t>0) and (t<13) then
       writeln(f,' '+strnum(i)+': '+n+' '+OBJNAMES[t]);



   writeln(f,'');
   writeln(f,'Export completed successfully.');
  close(f);
  end; {file}
end;

{$I I_GETIMP.PAS}

procedure filemover;
 var done:boolean;
     j,j2:char;
     s,ss:string;
     i,ie,i2:word;
	 color16:byte;
begin
 done:=false;
 getmem(othergrap,241*256);
 repeat
 clearscreen;
 say(0,2,6,' IMPORT/EXPORT UTILITY ');
 say(5,20,5,' F Û0: IMPORT A FONT');
 say(5,30,5,' G Û0: IMPORT NORMAL GRAPHIC TILES');
 say(5,40,5,'ƒ„GÛ0: IMPORT SECONDARY GRAPHIC TILES');
 say(5,50,5,'ƒ„RÛ0: RAW GRAPHIC TILE IMPORT');
 say(5,60,5,' O Û0: IMPORT OBJECTS AND GRAPHICS');
 say(5,70,5,' K Û0: IMPORT AN ADVENTURE KIT');
 say(5,80,5,'ƒ„KÛ0: IMPORT ''KIT'' FROM ADVENTURE');
{ say(5,84,5,' C Û0: COPY THIS ADVENTURE'); }
 say(5,90,5,' D Û0: DELETE SAVED GAME FILES');
 say(5,100,5,' X Û0: EXPORT TXT REPORTS');
 say(5,120,5,'F10Û0: EXIT');
  j:=upcase(readkey);
  case j of
   #0:case readkey of
     #59:help;
     #68:done:=true;
     #37:begin {alt-K}
        helpindex:=36;
        s:=ackfinder('MST',' IMPORT KIT FROM ADVENTURE ');
        chdir(startdir);
        if s<>'NONAME' then
         begin
          importkit(s,false);
          loadfont;
          loadgraps;
         end;
        helpindex:=4;
       end;
      #19:begin {alt-R}
        s:=getimportfilename(false,'');
{

	  say(1,140,0,'ENTER THE PATH AND NAME OF A RAW');
           say(1,148,0,'GRAPHIC TILE FILE TO LOAD.');
           s:=readlin(1,158,38,0); 
           if s='' then s:=#27; }
           if s<>'' then
            begin
			clearscreen;

           say(1,168,0,'START AT WHAT POSITION?');
           val(readlin(1,178,4,1),i,ie);
           if (i=0) or (ie<>0) then i:=1;
          { say(1,168,0,'READ HOW MANY TILES?   ');
           val(readlin(1,178,4,1),i2,ie);
           if (i2=0) or (ie<>0) then i2:=1; } i2:=240;
		   say(1,188,0,'[E]GA OR [V]GA TILES?');
           j2:=upcase(readkey);
           if j2='E' then color16:=1 else color16:=0;
         {  if color16=1 then begin
		    say(1,188,0,'[P]LANAR OR [N]ORMAL?');
            j2:=upcase(readkey);
            if j2='P' then color16:=2;
           end;}
           
		   
           say(1,188,0,'IMPORT AS [N]ORMAL OR [S]ECONDARY?');
           j2:=upcase(readkey);
           if j2='N' then copysomegraps16(s,i,i2,color16);
           if j2='S' then copysomegraps216(s,i,i2,color16);
            end;
          end;
      #34:begin
        helpindex:=36;
        s:=ackfinder('GRP',' IMPORT SECONDARY TILES ');
        chdir(startdir);
        if s<>'NONAME' then
         begin
          copysomegraps2(s);
         end;
        helpindex:=4;
       end;
  (*   #34:begin {alt-G}
        helpindex:=36;
        s:=ackfinder('GRP',' IMPORT ALL GRAPHIC TILES ');
        chdir(startdir);
        if s<>'NONAME' then
         begin
          bytecopy(s+GRAPHICSFILE,ADVNAME+GRAPHICSFILE);
          loadgraps;
         end;
        helpindex:=4;
       end;   *)
     end;
   'X':begin
        clearscreen;
        say(5,10,0,'EXPORTED REPORTS WILL BE IN THE');
        say(5,20,0,'GAME FOLDER AS ''.TXT'' FILES.');

        say(5,40,0,'OBJECTS.TXT...');


        exportobjects;
        say(40,40,0,'DONE');

        say(5,50,0,'MESSAGES.TXT...');
        say(5,60,0,'DIALOGUE.TXT...');


        exportmessages;
        say(40,50,0,'DONE');
        say(40,60,0,'DONE');

        say(5,70,0,'MACROS.TXT...');

        openmacronamefile;
        makemacrolist;
        closemacronamefile;
        say(40,70,0,'DONE');

        say(5,80,0,'CREATURE.TXT...');

  exportcreatures;
        say(40,80,0,'DONE');
        {say(5,90,0,'CONFIG.TXT...');

        exportconfig;}
        say(5,90,0,'SOUNDS.TXT...');
		exportsounds(bgi_dir,ADVNAME);
        say(40,90,0,'DONE');



        say(5,120,0,'PRESS A KEY.');
        if readkey=#0 then j:=readkey; j:='X';
       end;


   'D':begin;helpindex:=38;deleteadventure;helpindex:=4;end;
   'F':begin
        clearscreen;
        say(20,50,0,'SELECT A FONT:');
        say(21,60,5,' 1 Û0: STANDARD');
        say(21,70,5,' 2 Û0: ITALIC');
        say(21,80,5,' 3 Û0: IBM PC');
        say(21,90,5,' 4 Û0: FUTURISTIC');
        say(21,100,5,' 5 Û0: LOWERCASE');
        say(21,110,5,' 6 Û0: FANCY');
        say(21,120,5,' 7 Û0: BOLD');
        say(21,130,5,' 8 Û0: ULTIMA');


        say(21,140,5,' A Û0: LOAD FONT FROM');
        say(21,148,0,'      AN ADVENTURE');
        case upcase(readkey) of
         '1':bytecopy(systemdir+'ACKDATA1'+FONTFILE,ADVNAME+FONTFILE);
         '2':bytecopy(systemdir+'ACKDATA2'+FONTFILE,ADVNAME+FONTFILE);
         '3':bytecopy(systemdir+'ACKDATA3'+FONTFILE,ADVNAME+FONTFILE);
         '4':bytecopy(systemdir+'ACKDATA4'+FONTFILE,ADVNAME+FONTFILE);
         '5':bytecopy(systemdir+'ACKDATA5'+FONTFILE,ADVNAME+FONTFILE);
        '6':bytecopy(systemdir+'ACKDATA6'+FONTFILE,ADVNAME+FONTFILE);
        '7':bytecopy(systemdir+'ACKDATA7'+FONTFILE,ADVNAME+FONTFILE);
		'8':bytecopy(systemdir+'ACKDATA8'+FONTFILE,ADVNAME+FONTFILE);
         'A':begin
              helpindex:=36;
              s:=ackfinder('FNT',' IMPORT FONT ');
              chdir(startdir);
              if s<>'NONAME' then
               begin
                bytecopy(s+FONTFILE,ADVNAME+FONTFILE);
               end;
             end;
         end;
        loadfont;
        helpindex:=4;
       end;
   'G':begin
        helpindex:=36;
        s:=ackfinder('GRP',' IMPORT SOME GRAPHIC TILES ');
        chdir(startdir);
        if s<>'NONAME' then
         begin
          copysomegraps(s);
         end;
        helpindex:=4;
       end;
   'O':begin
        helpindex:=36;
        s:=ackfinder('MST',' IMPORT OBJECTS ');
        chdir(startdir);
        if s<>'NONAME' then
         bytecopy(s+OBJECTFILE,ADVNAME+OBJECTFILE);
        helpindex:=4;
       end;
   'K':begin
        helpindex:=36;
        getdir(0,ss);
        {$I-} chdir(systemdir+'KITS'); {$I+}
        s:=ackfinder('KIT',' IMPORT ADVENTURE KIT ');
        chdir(ss);
        loadfont;
        loadgraps;
        if s<>'NONAME' then
         begin
          importkit(s,true);
          loadfont;
          loadgraps;
         end;
        helpindex:=4;
        end;
   {'C':begin;helpindex:=37;copyadventure;helpindex:=4;end;}
  end;
 until done;
 chdir(thisgame_dir+'.');
end;