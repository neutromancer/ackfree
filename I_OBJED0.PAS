

var    creatureok:boolean;


function objnam(num:byte):string;
begin
 if num<>0 then objnam:=concat('#',strnum(num),' ',obj^[num].n)
 else objnam:='(?)';
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

   37:if actionparam<>0 then s:='#'+strnum(actionparam) else s:='NONE';
   42,43:if actionparam>245 then s:=strnum(actionparam-245)+' TURNS' else s:=strnum(actionparam*10)+' TURNS';

   end;{case}
   end
  else if (actionnum<>0) and (actionnum<>21) then s:='(SET LATER)'
       else s:=' ';
  for i:=length(s) to 20 do s:=concat(s,' ');
  stractionp:=s;
  end;



function strtriggerp(trigger,trigparam:byte):string;
var s:string;i:byte;
begin
 case trigger of
  0,1,6,7,13:s:=' ';
  14:if trigparam=0 then s:='NO MESSAGE' else
      s:='SHORTMSG:#'+strnum(trigparam);
  2..5,8..10:s:=objnam(trigparam);
  12:if trigparam=0 then s:='ANY ITEM'
   else s:=objnam(trigparam);
  11:if trigparam=0 then s:='ANY WEAPON'
   else s:=objnam(trigparam);
 end;
  for i:=length(s) to 20 do s:=concat(s,' ');
 strtriggerp:=s;
end;


function strpassablep(pss,pssp:byte):string;
var s:string;i:byte;
begin

 pss:=pss AND 63;
 case pss of
  24,25:if (pssp>0) and (pssp<53) then
    begin
    if pssp>26 then s:=chr((pssp-26) + 64)+'2'
     else s:=chr((pssp) + 64);
	end else s:='?';
  19:s:=strnum(pssp);
  2,3,4:s:=objnam(pssp);
  5:s:=objnames[pssp];
  6..18:s:=concat('N = ',strnum(pssp));
  else s:=' ';
 end;
  for i:=length(s) to 20 do s:=concat(s,' ');
 strpassablep:=s;
end;
