unit u_ack04;

interface

uses dos;

const
      PASSMAX=25;
      TRIGMAX=14;
      O_TRIGMIN=6;
      O_TRIGMAX=14;
      ACTMAX=47;







function strnum(n:integer):string;

procedure exportsounds(bgi_dir,advname:string);

function hinyb(b:byte):byte;

function lonyb(b:byte):byte;

procedure sethinyb(var by:byte;nb:byte);

procedure setlonyb(var by:byte;nb:byte);

function strblastradius(br:byte):string;


function straction(actionnum:byte):string;


 function strtrigger(trigger:byte):string;


function strpassable(pss:byte):string;


 function strdisappear(disap:byte):string;


function strvar(d1,d2,d3:byte):string;


procedure msgexptext(var f:text;b:byte);


procedure deletesaves(ADVNAME:string);

{
procedure macrodefrag(n,e:string);
}









implementation

function strnum(n:integer):string;
var s:string;
begin
 str(n,s);
 strnum:=s;
end;

procedure exportsounds(bgi_dir,advname:string);

  var dirinfo: searchrec; f:text; sz:longint;
 begin
  assign(f,'SOUNDS.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult=0 then begin
  writeln(f,'Adventure name: '+ADVNAME);
  writeln(f,'');
  writeln(f,'These sounds were found in the adventure folder:');
  writeln(f,'');
  FindFirst('*.RAW', AnyFile, dirinfo);
  while doserror=0 do
   begin
    write(f,dirinfo.name+'  (');
	if dirinfo.size>=11025 then write(f,strnum(dirinfo.size DIV 11025))
	 else write(f,'<1');
	writeln(f,' sec)');
	FindNext(dirinfo);
   end;

  writeln(f,'');
  writeln(f,'These sounds were found installed with ACK:');
  writeln(f,'');
  FindFirst(bgi_dir+'\SOUNDS\DEFAULT\*.RAW', AnyFile, dirinfo);
  while doserror=0 do
   begin
    write(f,dirinfo.name+'  (');
	if dirinfo.size>=11025 then write(f,strnum(dirinfo.size DIV 11025))
	 else write(f,'<1');
	writeln(f,' sec)');
	FindNext(dirinfo);
   end;
  close(f);

 end;
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

function strblastradius(br:byte):string;
var s:string;i:byte;
begin
  case br of
    0:s:='PINPOINT';
    1..10:s:='B.R. '+strnum(br);
    11:s:='STREAM -';
    12:s:='CONE   <';
   end;
  for i:=length(s) to 12 do s:=concat(s,' ');
  strblastradius:=s;
 end;


function straction(actionnum:byte):string;
var s:string;i:byte;
begin
 case actionnum of
   0:S:='DO NOTHING';
  01:S:='DISPLAY SHORT MESSAGE';
  02:S:='DISPLAY LONG MESSAGE';
  03:S:='DISPLAY PICTURE';
  04:S:='PLAY SOUND EFFECT';
  05:S:='CHANGE H.P.';
  06:S:='CHANGE H.P. MAX';
  07:S:='CHANGE M.P.';
  08:S:='CHANGE M.P. MAX';
  09:S:='CHANGE STRENGTH';
  10:S:='CHANGE INTELLIGENCE';
  11:S:='CHANGE RANGED WEAPON SKIL';
  12:S:='CHANGE WEAPON SKILL';
  13:S:='CHANGE ALIGN';
  14:S:='TAKE FROM YOU ONE OF:';
  15:s:='TAKE FROM USER ALL ITEM:';
  16:s:='TAKE FROM USER ALL TYPE:';
  17:S:='GIVE TO PERSON ONE OF:';
  18:S:='TAKE ALL THESE FROM AREA:'; {longest}
  19:S:='PUT ONE OF THIS HERE:';
  20:S:='KILL USER IF NOT HOLDING:';
  21:S:='ACTIVATE ALL UNDERNEATH';
  22:S:='HIT PLAYER WITH WEAPON';
  23:S:='LET PLAYER SHOOT WEAPON';
  24:S:='SUMMON CREATURE:';
  25:S:='SET VARIABLE "A" TO:';
  26:S:='SET VARIABLE "B" TO:';
  27:S:='SET VARIABLE "C" TO:';
  28:S:='SET VARIABLE "D" TO:';
  29:S:='INCREASE "A" BY:';
  30:S:='INCREASE "B" BY:';
  31:S:='INCREASE "C" BY:';
  32:S:='INCREASE "D" BY:';
  33:S:='DECREASE "A" BY:';
  34:S:='DECREASE "B" BY:';
  35:S:='DECREASE "C" BY:';
  36:S:='DECREASE "D" BY:';
  37:S:='EXECUTE MACRO:';
  38:S:='MOVE CHARACTER ONE SPACE:';
  39:S:='SET VIEW RANGE TO:';
  40:S:='SET ICON TO:';
  41:S:='PROVOKE NEARBY CREATURES';
  42:S:='TEMPORARY TORCHLIGHT';
  43:S:='TEMPORARY DAYLIGHT';
  44:S:='SET HP REGEN RATE';
  45:S:='SET MP REGEN RATE';
  46:S:='SET HP POISON RATE';
  47:S:='RUN DIALOGUE';
  end; {case}
  for i:=length(s) to 24 do s:=concat(s,' ');
  straction:=s;
 end;

 function strtrigger(trigger:byte):string;
var s:string;i:byte;
begin
 case trigger of
  0:S:='NOTHING';
  01:S:='PASSING';
  02:S:='DROPPING ITEM HERE';
  03:s:='PASSING, HOLDING';
  04:s:='PASSING, REDEEMING';
  05:s:='PASSING, WITHOUT';
  06:s:='EXAMINING, FAR';
  07:s:='BUMPING';
  08:s:='BUMPING, HOLDING';
  09:s:='BUMPING, REDEEMING';
  10:s:='BUMPING, WITHOUT';

  11:s:='IF ATTACKED';
  12:s:='TAKING ITM FRM HERE';
  13:s:='EXAMINING, NEAR';
  14:s:='GATHERING FROM HERE';
 end;
  for i:=length(s) to 18 do s:=concat(s,' ');
 strtrigger:=s;
end;

function strpassable(pss:byte):string;
var s:String;i:byte;
begin
 s:='IF VARIABLE ';
 pss:=pss AND 63;
 case pss of
  0:s:='NOTHING';
  1:s:='ANYTHING';
  2:s:='ONLY IF HOLDING:';
  3:s:='ONLY IF REDEEMING:';
  4:s:='ONLY IF W/OUT ITEM:';
  5:s:='ONLY IF W/OUT TYPE:';
  6:s:='IF STRENGTH > #';
  7:s:=s+'A > #';
  8:s:=s+'A = #';
  9:s:=s+'A < #';
 10:s:=s+'B > #';
 11:s:=s+'B = #';
 12:s:=s+'B < #';
 13:s:=s+'C > #';
 14:s:=s+'C = #';
 15:s:=s+'C < #';
 16:s:=s+'D > #';
 17:s:=s+'D = #';
 18:s:=s+'D < #';
 19:s:='ENERGY DRAIN:';
 20:s:='UNBURDENED ONLY';

 21:s:='DAYTIME ONLY';
 22:s:='NIGHTTIME ONLY';
 23:s:='ANYTHING AT ALL';
 24:s:='VARIABLE IS 0';
 25:s:='VARIABLE ISN''T 0';

 end;
  for i:=length(s) to 18 do s:=concat(s,' ');
  strpassable:=s;
 end;

 function strdisappear(disap:byte):string;
var s:string;i:byte;
begin
 case disap of
  0:s:='ONLY IF DESTROYED';
  1:s:='IF ACTION TRIGGERED';
  2:s:='IF PASSED';
  3:s:='WHILE IMPASSABLE';
  6..255:s:='IF DESTROYED ['+strnum(disap-5)+']';
 end;
  for i:=length(s) to 18 do s:=concat(s,' ');
 strdisappear:=s;
end;

function strvar(d1,d2,d3:byte):string;
 var s:string[10];
begin
 case d1 of
  0:s:=strnum(d2*256+d3);
  1:s:=chr(d2+64); {a thru z}
  2:case d2 of
      0:s:='HP';
      1:s:='HPMAX';
      2:s:='MP';
      3:s:='MPMAX';
      4:s:='STR';
      5:s:='INT';
      6:s:='WSK';
      7:s:='RWSK';
      8:s:='ALIGN';
	  9:s:='CRIM';
	  10:s:='HREGEN';
	  11:s:='MREGEN';
	  12:s:='POISON';
     end;
   3:s:='INV['+strnum(d2)+']';
   31:s:='WORN['+strnum(d2)+']';
   32:s:='WEAPON';

   4:s:='LOC[RG]';
   5:s:='LOC[RM]';
   6:s:='LOC[X]';
   7:s:='LOC[Y]';
   8:s:='VEH';
   9:s:='VIEW';
   10:s:='ICON';
   11:s:='MONEY';
   12:s:='RND('+strnum(d2)+')';
   13:s:='DAYS';
   14:s:='HOUR';
   15:s:='MINUTE';
   16:s:='KEYPRESS';
   17:s:='TORCHL';
   18:s:='ESCKEY';
   19:s:='AGGRO';
   20:s:='TORCHD';
   21:s:='LEVEL';
   22:s:='EXP';
   23:s:='SUCCESS';
   24:s:='PORTAL';
   25:s:='FLY';
   {27:s:='AUTORUN';}
   28:s:='INVISDUR';
   29:s:='INVISICO';
   30:s:=chr(d2+64)+'2'; {a thru z}
   33:s:='WMUSIC';
   34:s:='CMUSIC';
   35:s:='LASTMOV';
   36:s:='HELLO['+strnum(d2)+']';
   26:begin
        s:='NOMOVE(';
		case d2 of
		 1:s:=s+'N)';
		 2:s:=s+'S)';
		 3:s:=s+'E)';
		 4:s:=s+'W)';
		 else s:=s+'ALL)';
		end;
	  end;
  end;
strvar:=s;
end;


procedure msgexptext(var f:text;b:byte);
begin
 case b of
  1:   writeln(f,'This file is an export of the contents of all short and long messages');
  2:   writeln(f,'Blank lines are skipped.  DO NOT EDIT THIS FILE, it is just for reference.');
  3:   writeln(f,'This file is an export of the contents of all dialogues.');
  4:   writeln(f,'DO NOT EDIT THIS FILE, it is just for reference.');
  end;

end;
(*
procedure macrodefrag(n,e:string);

type
   macrorec = record
      cmd:byte;
      data:Array[1..6,1..3] of byte;
      next:word;
     end;

var
   oldf,newf:file of macrorec;
   macroline: macrorec;
   {newstarts:array[1..255] of word;}
   header:array[1..255] of macrorec;
   i2,i1:integer;
   thismacro:byte;
   newnext,oldnext:word;


begin

 assign(oldf,n+e);
 assign(newf,'MACROS.OLD');
 reset(oldf);
 rewrite(newf);

 while not eof(oldf) do
  begin
   read(oldf,macroline);
   write(newf,macroline);
  end;
 close(oldf);
 close(newf);




 assign(oldf,'MACROS.OLD');
 assign(newf,n+e);
 reset(oldf);

 rewrite(newf);
 macroline.next:=0;
 macroline.cmd:=0;

 for i1:=1 to 6 do for i2:=1 to 3 do macroline.data[i1,i2]:=0;
 for i1:=0 to 255 do write(newf,macroline);
 newnext:=256;
 for i1:=1 to 255 do header[i1]:=macroline;

 for thismacro:=1 to 255 do
  begin
   seek(oldf,thismacro);
   read(oldf,macroline);
   header[thismacro]:=macroline;
   if macroline.next<>0 then header[thismacro].next:=newnext;

   while macroline.next<>0 do
    begin
     seek(oldf,macroline.next);
	 read(oldf,macroline);
	 oldnext:=macroline.next;
	 newnext:=newnext+1;
	 if oldnext<>0 then macroline.next:=newnext;
	 write(newf,macroline);
	 macroline.next:=oldnext;
	end;


  end;

  close(oldf);
 for thismacro:=1 to 255 do
  begin
   seek(newf,thismacro);
   write(newf,header[thismacro]);
  end;

 close(newf);



end;
*)


procedure deletebunch(filename:string);
var
  sr:searchrec;
  f:file;
begin
   findfirst(filename,anyfile,sr);
   while doserror=0 do
    begin
	 if sr.name[1]<>'.' then
	  begin
       assign(f,sr.name);
       erase(f);
	  end;
     findnext(sr);
    end;
end;

 function file_exists(s:string):string;
 var dirinfo: searchrec;
 begin
    FindFirst(s, AnyFile, dirinfo);
    if doserror=0 then file_exists:=dirinfo.name else file_exists:='';
 end;

procedure deletesaves(ADVNAME:string);
var i:byte;
begin
 deletebunch(ADVNAME+'.X*');
 deletebunch(ADVNAME+'.Y*');
 deletebunch(ADVNAME+'.Z*');
 deletebunch(ADVNAME+'.1*');
 deletebunch(ADVNAME+'.2*');
 deletebunch(ADVNAME+'.3*');
 deletebunch(ADVNAME+'.RGX');
 deletebunch(ADVNAME+'.RGT');
 deletebunch(ADVNAME+'.PLY');
 deletebunch(ADVNAME+'.TPF');
 deletebunch(ADVNAME+'.DQS');
 deletebunch(ADVNAME+'.DQT');
 for i:=1 to 9 do
  begin
   if file_exists('SAVED'+strnum(i)+'\SAVENAME.TXT')<>'' then
    begin
	 chdir('SAVED'+strnum(i));
	 deletebunch('*.*');
	 chdir('..');
	 rmdir('SAVED'+strnum(i));
	end;
  end;	

end;

begin
end.
