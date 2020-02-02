unit u_objed0;


interface

uses u_vars,u_adv,u_graph;

const
      PASSMAX=25;
      TRIGMAX=14;
      O_TRIGMIN=6;
      O_TRIGMAX=14;
      ACTMAX=47;

var    creatureok:boolean;




function objnam(num:byte):string;


function hinyb(b:byte):byte;

function lonyb(b:byte):byte;

procedure sethinyb(var by:byte;nb:byte);

procedure setlonyb(var by:byte;nb:byte);


function strblastradius(br:byte):string;


function straction(actionnum:byte):string;


function stractionp(actionnum,actionparam:byte;notcustom:boolean):string;


function strtrigger(trigger:byte):string;

function strtriggerp(trigger,trigparam:byte):string;


function strpassable(pss:byte):string;

function strpassablep(pss,pssp:byte):string;

function strdisappear(disap:byte):string;






implementation

 {$I I_SNDNAM.PAS}

function strnum(n:integer):string;
var s:string;
begin
 str(n,s);
 strnum:=s;
end;

function objnam(num:byte):string;
begin
 if num<>0 then objnam:=concat('#',strnum(num),' ',obj^[num].n)
 else objnam:='(?)';
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



function stractionp(actionnum,actionparam:byte;notcustom:boolean):string;
var s:string;i:byte;
 begin
  if notcustom then
begin
  case actionnum of
   0,21:s:=' ';
   1,2:if actionnum=0 then s:='NONE YET'
        else s:=concat('#',strnum(actionparam));
   3:if actionnum=0 then s:='NONE YET'
       else s:=concat('#',strnum(actionparam));
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
   41,13:case actionparam of
       2:s:='EVIL   ';
       3:s:='NEUTRAL';
       4:s:='ANIMAL ';
       else s:='GOOD   ';
      end;
   14,15,17,18,19,20,22,23:s:=objnam(actionparam);
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
   25..36,39,40,44..47:s:=strnum(actionparam);
   42,43:if actionparam>245 then s:=strnum(actionparam-245)+' TURNS' else s:=strnum(actionparam*10)+' TURNS';

   37:if actionparam<>0 then s:='#'+strnum(actionparam) else s:='NONE';
   end;{case}
   end
  else if (actionnum<>0) and (actionnum<>21) then s:='(SET LATER)'
       else s:=' ';
  for i:=length(s) to 20 do s:=concat(s,' ');
  stractionp:=s;
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
function strtriggerp(trigger,trigparam:byte):string;
var s:string;i:byte;
begin
 case trigger of
  0,1,6,7,11,13:s:=' ';
  14:if trigparam=0 then s:='NO MESSAGE' else
      s:='SHORTMSG:#'+strnum(trigparam);
  2..5,8..10:s:=objnam(trigparam);
  12:if trigparam=0 then s:='ANY ITEM'
   else s:=objnam(trigparam);
 end;
  for i:=length(s) to 20 do s:=concat(s,' ');
 strtriggerp:=s;
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
  6:s:='IF STRENGTH > N';
  7:s:=s+'A > N';
  8:s:=s+'A = N';
  9:s:=s+'A < N';
 10:s:=s+'B > N';
 11:s:=s+'B = N';
 12:s:=s+'B < N';
 13:s:=s+'C > N';
 14:s:=s+'C = N';
 15:s:=s+'C < N';
 16:s:=s+'D > N';
 17:s:=s+'D = N';
 18:s:=s+'D < N';
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
function strpassablep(pss,pssp:byte):string;
var s:string;i:byte;
begin
 pss:=pss AND 63;
 case pss of

  19:s:=strnum(pssp);
  24,25:if (pssp>0) and (pssp<53) then
    begin
    if pssp>26 then s:=chr((pssp-26) + 64)+'2'
     else s:=chr((pssp) + 64);
	end else s:='?';
  2,3,4:s:=objnam(pssp);
  5:s:=objnames[pssp];
  6..18:s:=concat('N = ',strnum(pssp));
  else s:=' ';
 end;
  for i:=length(s) to 20 do s:=concat(s,'-');
 strpassablep:=s;
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
