{$O+}
{$F+}
{.DEFINE DEBUG}
unit o_play3;

 {Room-region procedures are in this overlay.}

interface

uses xms,u_sound,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,dos,u_fonts,u_graps,o_play0,o_play0a,o_play1,u_delay2;

procedure getroom(n:byte);
function rtrymove(therex,therey,herex,herey,room:Byte):Byte;
procedure walkroom(var rgn,room,ydummy,x,y:byte);


implementation

var obj8,dp8:byte;

roomunder:array[1..16,1..11] of byte;

procedure getroom(n:byte);
 var c1,c2:byte;
     b1,b2:byte;
     point,nextpoint:locpointer;
	 donedigging:boolean;
begin
 if n>region.rooms then exit;
 with region.room do
  begin
   roomwide:=x2[n]-x1[n]+1;roomtall:=y2[n]-y1[n]+1;
   for c1:=x1[n] to x2[n] do for c2:=y1[n] to y2[n] do
    begin
	 roomunder[c1-x1[n]+1,c2-y1[n]+1]:=0;
     point:=roomloc(n,c1-x1[n]+1,c2-y1[n]+1);
     if point=0 then 
	  begin
	   b1:=0;

      end
	   else
      begin
       b1:=locnt^[point].obj;
       b2:=locnt^[point].objcode;
	   
	   if (b1=255) or (obj^[b1].t>5) then
	   begin
	   donedigging:=locnt^[point].p=0;
	   nextpoint:=point;
	   while not donedigging do
	    begin
		 nextpoint:=locnt^[nextpoint].p;
		 if locnt^[nextpoint].p=0 then donedigging:=true;
		 if (locnt^[nextpoint].obj<>0) and (locnt^[nextpoint].obj<>255)
		  then if obj^[locnt^[nextpoint].obj].t<6 then
		   begin; roomunder[c1-x1[n]+1,c2-y1[n]+1]:=locnt^[nextpoint].obj; donedigging:=true; end;
		   
		end;
		{writelog(0,'digging result at '+strnum(c1-x1[n]+1)+','+
		strnum(c2-y1[n]+1)+' was '+strnum(roomunder[c1-x1[n]+1,c2-y1[n]+1]));}

	  end;
		
      end;
     map[2,2,c1-x1[n]+1,c2-y1[n]+1].o:=b1;
     map[2,2,c1-x1[n]+1,c2-y1[n]+1].d:=b2;

    end;
  end;
end;


procedure roomloadwandering(n:byte);
 var i,addslot,addslotc:integer;
     creatureslot,creatureslott,laycreature:byte;
begin




   for i:=1 to WANDERMAX do if wander_index^[i].x=n then
    if wander_index^[i].odds>random(100) then
     if locnt^[roomloc(n,wander_index^[i].xin,wander_index^[i].yin)].obj<>255 then begin
      addslot:=0;
      for addslotc:=1 to locntsize do
       if locnt^[addslotc].obj=0 then addslot:=addslotc;
      if addslot=0 then if locntsize<LOCNTMAX then
       begin;addslot:=locntsize+1;inc(locntsize);end;
      if addslot<>0 then
       begin


   creatureslot:=0;creatureslott:=0;
   repeat
    inc(creatureslot);
    if creatureslot>RCMAX then creatureslott:=255
     else if rcrc^[creatureslot].used=false then
     creatureslott:=creatureslot;
    until creatureslott<>0;
   if creatureslott<>255 then
   begin {***}

   laycreature:=wander_index^[i].creature;
   if laycreature<>0 then
        with rcrc^[creatureslott] do
        begin {*****}
        { rcrc^[creatureslott].xchunk:=xchunkloc;
         rcrc^[creatureslott].ychunk:=ychunkloc; }
         used:=true;show:=true;
        { obj:=map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].o;
         objdata:=map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].d; }
         crcsource:=laycreature;
         hp:=crc^[laycreature].hm;
         mp:=crc^[laycreature].mm;
         recurring:=false;odds:=100;

         motive:=0;
         anger:=0;
         if crc^[laycreature].t=2 then anger:=1;
         if crc^[laycreature].t=4 then anger:=6;
         if crc^[laycreature].t=1 then anger:=2;
         talk:=0;

         locnt^[addslot].p:=
           rmcnt^[wander_index^[i].xin+region.room.x1[n]-1,wander_index^[i].yin+region.room.y1[n]-1];
         rmcnt^[wander_index^[i].xin+region.room.x1[n]-1,wander_index^[i].yin+region.room.y1[n]-1]:=addslot;
         locnt^[addslot].obj:=255;
         locnt^[addslot].objcode:=creatureslott;
         end; {if creature}
         end; {if creature slot}
       end; {if room addslot}
     end; {if odds}




end;


function rtrymove(therex,therey,herex,herey,room:Byte):Byte;
var
 llp:locpointer;
 tmresult:byte;
 tmspot:byte;
 tmdata:byte;
 tmst:byte;
 stepclick:boolean;
begin
 readkey_time:=R150;
 if arcade then readkey_default:=#255 else
  readkey_default:=#1;
 tmresult:=0; {assume okay}
 tmspot:=map[2,2,therex,therey].o;
 tmdata:=map[2,2,therex,therey].d;

 if tmspot<>0 then if obj^[tmspot].t<6 then if obj^[tmspot].d[8]=3 then
   begin
    dp8:=0;
    trypassable(dp8,obj^[tmspot].d[4],obj^[tmspot].d[5]);
    if dp8<>0 then tmspot:=obj^[tmspot].d[12];

   end;



 if tmspot<>0 then
 begin
  tmst:=obj^[tmspot].t;
  if tmst=10 then if ack.plvehicle<>0 then tmst:=3;
  if (tmst>5) and (tmst<>10) then
    begin   {DIG}
     llp:=locnt^[roomloc(room,therex,therey)].p;
      repeat
       tmst:=obj^[locnt^[llp].obj].t;
       if tmst<6 then
        begin
         tmspot:=locnt^[llp].obj;
         tmdata:=locnt^[llp].objcode;
        end;
         llp:=locnt^[llp].p;
        until (llp=0) or (tmst<6);
      end;
  if (tmst=3) or (tmst=4) then
   tmresult:=99;  {99 means impassable}
  if (tmst=5) then tmresult:=5;
  if tmresult<99 then
   if tmst<6 then trypassable(tmresult,obj^[tmspot].d[4],obj^[tmspot].d[5]);
  if tmst<6 then block_message:=obj^[tmspot].d[7] else block_message:=0;
  if (tmst=5) and (tmresult<99)
    then pass_message:=obj^[tmspot].d[13] else pass_message:=0;
   if pass_message<>0 then shortmessage(pass_message);
  actionparser(tmresult,tmspot,tmdata,room,therex,therey,herex,herey);
 end else
  begin
   tmresult:=0;if ack.stepsound<>0 then
    if (herex<>therex) or (herey<>therey) then
     soundeffect(ack.stepsound,1);
  end;
 rtrymove:=tmresult;
end;





procedure walkroom(var rgn,room,ydummy,x,y:byte);
 var j2,j:char;
     steal_llp:word;
     done2,done:boolean;
     putgrapc:byte;
     tracer:boolean;
     dropping2,dropping:byte; no_drop:boolean;
     llp,addslot,addslotc:locpointer;
     rtryval:byte;
     xmod,ymod,xorx,xory:integer;
     aimxloc,aimyloc,n,xloc,yloc,xlocold,ylocold:byte;
     moved,arrowmoved:boolean;
     dri,dri1:integer;
     dropamount:word;
     weapon1n,weapon1t,weapon2n,weapon2t,maxrange,wxloc,wyloc:byte;
     registerattacks:array[1..16,1..8] of byte;
     regattacknum:byte;
     whoops:byte;
     attacker_alignment,attacker_id:byte;
     hitcrc_bugfix:array[1..16,1..4] of byte;
     hitcrc_bugfix_counter:byte;
     newroom:boolean;
     vehcount:byte;
     quasimap:array[1..16,1..11] of byte;
     tmspot,tmdata:byte;


procedure checkadjacent(xl,yl,dir:byte);
 var roomsearch:Byte;  {dir is 0 up  1 dn  2 lf  3 rt}
begin
 xl:=xl-1+region.room.x1[room];
 yl:=yl-1+region.room.y1[room];
 {search for another room that includes those two}
 for roomsearch:=1 to region.rooms do
  with region.room do begin
   if (x1[roomsearch]<xl) and (x2[roomsearch]>xl) and
      (y1[roomsearch]<yl) and (y2[roomsearch]>yl) then
    begin
     case dir of
      0:begin;yloc:=y2[roomsearch]-y1[roomsearch]+1;
        xloc:=x1[room]+ xloc -x1[roomsearch];newroom:=true;end;
      1:begin;yloc:=1;
        xloc:=x1[room]+ xloc -x1[roomsearch];newroom:=true;end;
      2:begin;xloc:=x2[roomsearch]-x1[roomsearch]+1;
        yloc:=y1[room]+ yloc -y1[roomsearch];newroom:=true;end;
      3:begin;xloc:=1;
        yloc:=y1[room]+ yloc -y1[roomsearch];newroom:=true;end;
     end;
     room:=roomsearch;
    end;
  end;
end;

procedure roomprojectile(px,py:byte; var x,y:byte; skill:byte);
 var rise,run,xstep,ystep,herex,herey:integer;
     done:boolean;
	 count:integer;
	 shootingover:byte;
begin
 writelog(0,'roomprojectile begin: '+strnum(px)+','+strnum(py)+' - '+strnum(x)+','+strnum(y));
 rise:=y-py; run:=x-px;
 xstep:=abs(run); ystep:=abs(rise);
 if xstep=0 then xstep:=1;if ystep=0 then ystep:=1;
 if xstep>ystep then ystep:=xstep else xstep:=ystep;
 herex:=px*xstep; herey:=py*ystep; done:=false;
 count:=0;
 writelog(0,'roomprojectile: herex:'+strnum(herex)+' herey:'+strnum(herey)+
 ' run:'+strnum(run)+' rise:'+strnum(rise)+' xstep:'+strnum(xstep)+' ystep:'+strnum(ystep));
 
  repeat
  if (round(herex/xstep)=x) AND (round(herey/ystep)=y) then
    begin;done:=true;writelog(0,'roomprojectile: arrival');end {we've arrived}
   else
    begin
	 {look at what the projectile is passing over}
     shootingover:=map[2,2,round(herex/xstep),round(herey/ystep)].o;
	 if ( herex<>xloc*xstep ) OR ( herey<>yloc*ystep ) {make sure we've actually left home}
	  then
	 begin
	  {check what we are shooting over}
	  if shootingover<>255 then {no friendly fire, the AI isn't nearly smart enough}

      if (shootingover<>0) then 
	   begin
       {it is an object...}
        case obj^[shootingover].t of
	     1,2,5:if obj^[shootingover].d[4]>127 then begin;writelog(0,'roomprojectile: hit opaque terrain');done:=true;end;
	   	 3,4:begin;done:=true;writelog(0,'roomprojectile: hit obstacle');end;
	    end; {case}
	   end; {object}
	   if done then begin;x:=round(herex/xstep);y:=round(herey/ystep);end;
	  end; {check}
	  
    end; {look}
   inc(herex,run);inc(herey,rise);
   inc(count);if count>300 then done:=true;
  until done;
 
 writelog(0,'roomprojectile end: '+strnum(px)+','+strnum(py)+' - '+strnum(x)+','+strnum(y)); 


end;


procedure shootterrain(weapon0t,weapon0n:byte);
begin
       if map[2,2,wxloc,wyloc].o<>0 then
        if (obj^[map[2,2,wxloc,wyloc].o].t<6)
         and (obj^[map[2,2,wxloc,wyloc].o].d[9]=11) then
         if (obj^[map[2,2,wxloc,wyloc].o].d[10]=0) or (obj^[map[2,2,wxloc,wyloc].o].d[10]=weapon0n) then
         do_action(obj^[map[2,2,wxloc,wyloc].o].d[2],
          obj^[map[2,2,wxloc,wyloc].o].d[3],0,0,map[2,2,wxloc,wyloc].o,
          map[2,2,wxloc,wyloc].d,room,wxloc,wyloc);
       if map[2,2,wxloc,wyloc].o<>0 then
        if (obj^[weapon0n].d[4]>=obj^[map[2,2,wxloc,wyloc].o].d[11])
        AND (obj^[map[2,2,wxloc,wyloc].o].t<6) AND
            (obj^[map[2,2,wxloc,wyloc].o].d[11]<>0) then
			begin
			 {process terrain destruction}
			 if obj^[map[2,2,wxloc,wyloc].o].d[8]>5 then begin
			   writelog(obj^[map[2,2,wxloc,wyloc].o].d[8]-5,'Running terrain death macro');
			   run_macro(obj^[map[2,2,wxloc,wyloc].o].d[8]-5);
			   end;
 			
              if obj^[map[2,2,wxloc,wyloc].o].d[12]=0 then
               begin
                llp:=roomloc(room,wxloc,wyloc);
                locnt^[llp].obj:=0;
                rmcnt^[wxloc+region.room.x1[room]-1,
                 wyloc+region.room.y1[room]-1]:=locnt^[llp].p;
                if llp=locntsize then dec(locntsize);
                getroom(room);moved:=true;
                {eliminate}
               end else
               begin
                llp:=roomloc(room,wxloc,wyloc);
                locnt^[llp].obj:=obj^[map[2,2,wxloc,wyloc].o].d[12];
                getroom(room);moved:=true;
                {replace with...}
               end;
			end;   
end;



function hitcreature(weapon0t,weapon0n,skill:byte):boolean;
 var who:byte;
     i:integer;
     damage:integer;
     dropcount:integer;
     hitpoints:integer;
     addslotc:integer;

begin

 damage:=0;

{process weapon damage}
 if weapon0n<>0 then hitpoints:=obj^[weapon0n].d[4] {base damage}
     else hitpoints:=0;

 i:=skill;                       {skill from 1-100 is chance of hitting for that damage}
 i:=skill;                       {skill from 1-100 is chance of hitting for that damage}
 if i>random(100) then damage:=random(hitpoints)+1;

                                 {skill from 101-200 is chance of hitting for double damage}
 if skill>100 then i:=skill-100 else i:=0;
 if i>random(100) then damage:=damage*2;

                                 {skill from 201+ is chance of hitting for quadruple damage}
 if skill>200 then i:=skill-200 else i:=0;
 if i>random(100) then damage:=damage*2;





 hitcreature:=false;

 if map[2,2,wxloc,wyloc].o=255 then
 begin  {target is a creature}
  hitcreature:=true;
  chunksave:=true;
  who:=map[2,2,wxloc,wyloc].d;
  if crc^[rcrc^[who].crcsource].hm=0 then exit;

  if attacker_alignment=5 then
    begin
     if oops_i_missed then
      begin  {i missed}
        if crc^[rcrc^[who].crcsource].t<>ack.alignment then
                   if random(2)=0 then rcrc^[who].anger:=5;
      end else
      begin {deliberate shot}
        soundeffect(hi(crcsounds[rcrc^[who].crcsource]),1);
        if crc^[rcrc^[who].crcsource].t=ack.alignment then
           ack.criminal:=ack.alignment else rcrc^[who].anger:=5;
      end; {if missed}
     end {if attacker is player}
     else
    if ((rcrc^[who].anger=attacker_alignment) or (rcrc^[who].anger=0))
      then
       begin {not angry, or already angry}
        rcrc^[who].anger:=attacker_alignment;
       end else
      if (random(4)=0) then {angry at someone else}
         if crc^[rcrc^[who].crcsource].t<>1 then
            rcrc^[who].anger:=attacker_alignment;   {if not good, then maybe go berserk}
    if random(4)=0 then
         soundeffect(hi(crcsounds[rcrc^[who].crcsource]),1);   {make attack sound}


    {if creature has armor, process it}
    if crc^[rcrc^[who].crcsource].ar<>0 then
        with crc^[rcrc^[who].crcsource] do
         if 
		 ( obj^[ar].d[6] > random(100) ) then 
		  begin;damage:=damage-obj^[ar].d[5];if damage<0 then damage:=0;end;

    {if creature is invulnerable, damage becomes zero}
    if crc^[rcrc^[who].crcsource].hm=0 then damage:=0;



	if rcrc^[who].hp>crc^[rcrc^[who].crcsource].hm then rcrc^[who].hp:=crc^[rcrc^[who].crcsource].hm;

    {if damage has become zero, this is a miss; play the sound}
    hitpoints:=rcrc^[who].hp-damage;





   if attacker_alignment=5 then
    begin {messages indicating you are the attacker}
    if damage>0 then
     begin
      soundeffect(ack.hitsound,1);

      scrollsay('YOU HIT '+crc^[rcrc^[who].crcsource].n+' FOR '+strnum(damage)+' DAMAGE!');
      delay2(combatpacing*3);
      if hitpoints<=0 then
        begin
         scrollsay(crc^[rcrc^[who].crcsource].n+' HAS BEEN KILLED!');
         soundeffect(lo(crcsounds[rcrc^[who].crcsource]),1);   {play death sound}
         delay2(combatpacing*3);
        end;
       delay2(combatpacing*3);
     end
     else
     begin
      scrollsay('YOU ATTACK '+crc^[rcrc^[who].crcsource].n+', BUT MISS!');
      soundeffect(ack.misssound,1);delay(500);
     end;
    end else
    begin {messages indicating hot NPC on NPC action}

    if damage>0 then
     begin
      soundeffect(ack.hitsound,1);

      scrollsay(crc^[attacker_id].n+' HITS '+crc^[rcrc^[who].crcsource].n+' FOR '+strnum(damage)+' DMG');
      delay2(combatpacing*5);
      if hitpoints<=0 then
        begin
         scrollsay(crc^[rcrc^[who].crcsource].n+' HAS BEEN KILLED!');
         soundeffect(lo(crcsounds[rcrc^[who].crcsource]),1);   {play death sound}
         delay2(combatpacing*5);
        end;
     end;

    end;









  if hitpoints<=0 then
   begin
    if ack.ackversion>24 then
   {  if attacker_alignment=ack.alignment then  }
     with crc^[rcrc^[who].crcsource] do ack.experience:=ack.experience+ ((exphi-1)*256 + exp);

    soundeffect(lo(crcsounds[rcrc^[who].crcsource]),1);
    xmod:=wxloc;ymod:=wyloc;
    rcrc^[who].show:=false;if not rcrc^[who].recurring then
     rcrc^[who].used:=false;

    {remove creature}
    locnt^[rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]].obj:=0;
   rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=
    locnt^[rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]].p;

    {drop inventory, if any}
    for i:=3 downto 1 do if crc^[rcrc^[who].crcsource].inv[i]<>0 then
     with crc^[rcrc^[who].crcsource] do
      if (obj^[inv[i]].t<6) or (inv[i]=1) or ((random(100)<invn[i]) or (ack.ackversion<31)) then
	  {if terrain, or money, or random chance}
	   begin
         dropping:=inv[i];
		 if (dropping<>1) and (obj^[dropping].t>5) then dri:=1 else dri:=invn[i];
         addslot:=0;
         if locntsize>5000 then
          begin
           {search for empty slot}
           for addslotc:=1 to locntsize do
            if locnt^[addslotc].obj=0 then addslot:=addslotc;
          end;
         if addslot=0 then if locntsize<LOCNTMAX then
           begin;addslot:=locntsize+1;inc(locntsize);end;
         if addslot<>0 then
          begin
           locnt^[addslot].p:=
            rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1];
           rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=addslot;
            locnt^[addslot].obj:=dropping;
           locnt^[addslot].objcode:=dri;

          end;
      end;

     {draw what's really there}
     getroom(room);moved:=true;

     if crc^[rcrc^[who].crcsource].deathm<>0 then
      if ack.ackversion>11 then run_macro(crc^[rcrc^[who].crcsource].deathm);
   end else rcrc^[who].hp:=hitpoints;
 end else
 if (wxloc=xloc) and (wyloc=yloc) then
  begin  {target is the player}

    {process armor damage absorb}
    for i:=1 to 7 do  {for each slot}
     if ack.parmor[i]<>0 then    {if wearing armor}
      if ack.countarmor[i]=0 then      {and its not disabled}

	   if ( obj^[ack.parmor[i]].d[6] > random(100) ) then  {and random coverage}
        damage:=damage-obj^[ack.parmor[i]].d[5];    {then absorb damage}

    if damage<0 then damage:=0;
    hitpoints:=ack.hp[0]-damage; {inflict damage}

    {sound effect}


    if damage>0 then
     begin
      soundeffect(ack.hitsound,1);

      scrollsay(crc^[attacker_id].n+' HITS YOU FOR '+strnum(damage)+' DAMAGE!');
      if crc^[rcrc^[who].crcsource].touchm<>0 then
       if weapon0t=7 then
	   if ack.ackversion>=30 then run_macro(crc^[rcrc^[who].crcsource].touchm);
      delay2(combatpacing*5);
      if hitpoints<=0 then scrollsay('YOU HAVE BEEN KILLED!');

     end else
     begin
      scrollsay(crc^[attacker_id].n+' ATTACKS YOU AND MISSES!');
      soundeffect(ack.misssound,1);delay(500);
     end;







    if hitpoints<=0 then hitpoints:=0;

    ack.hp[0]:=hitpoints;
    graphHP;
    chunksave:=true;
    hitcreature:=true;
  end;  {target is player}
  erasebottom:=1;
end;





procedure resolve_rangedweapon(weapon0t,weapon0n,skill:byte);
var
     Conecounter,old_wxloc,old_wyloc,wxloc2,wyloc2:byte;
     wxlocc_begin,wxlocc_end,wylocc_begin,wylocc_end,wxlocc,wylocc:byte;
begin
    old_wxloc:=wxloc;old_wyloc:=wyloc;
    if weapon0t=8 then
     if obj^[weapon0n].d[5] DIV 16<11 then
     begin
      wxloc2:=wxloc;wyloc2:=wyloc;
     { if (distance(aimxloc,aimyloc,wxloc,wyloc)>1) then}
       for wxlocc:=wxloc2+10 to wxloc2+30 do
        for wylocc:=wyloc2+10 to wyloc2+30 do
       begin
        wxloc:=wxlocc-20;wyloc:=wylocc-20;
        if (wxloc>=1) and (wyloc>=1) and
         (wxloc<=roomwide) and (wyloc<=roomtall) then
         if distance(wxloc2,wyloc2,wxloc,wyloc)<=obj^[weapon0n].d[5] DIV 16
       then begin
        showweapon(weapon0t,weapon0n,aimxloc,aimyloc,wxloc,wyloc,roomwide,roomtall);
        if not hitcreature(weapon0t,weapon0n,skill)
         then shootterrain(weapon0t,weapon0n);
      {process ranged weapon 1}
      end;
      end; { else if attacker_alignment=5 then adjacent_error;}
     end else
     if (xmod<>0) or (ymod<>0) then begin
      wxloc:=aimxloc;wyloc:=aimyloc;
      wxloc2:=wxloc;wyloc2:=wyloc;
      wxlocc_begin:=20;
      wxlocc_end:=20;
      wylocc_begin:=20;
      wylocc_end:=20;
      for conecounter:=0 to obj^[weapon0n].d[5] MOD 16 do
       begin
        wxloc2:=aimxloc+(xmod*(conecounter+1));
        wyloc2:=aimyloc+(ymod*(conecounter+1));
       if obj^[weapon0n].d[5] DIV 16 = 12 then
       begin
        if ymod<>0 then
         begin
          wxlocc_begin:=20-conecounter;
          wxlocc_end:=20+conecounter;
         end;
        if xmod<>0 then begin
          wylocc_begin:=20-conecounter;
          wylocc_end:=20+conecounter;
         end;
       end;
        for wxlocc:=(wxlocc_begin) to (wxlocc_end) do
         for wylocc:=(wylocc_begin) to (wylocc_end) do
        begin
         wxloc:=wxloc2+wxlocc-20;
         wyloc:=wyloc2+wylocc-20;
          if (wxloc>=1) and (wyloc>=1) and
           (wxloc<=roomwide) and (wyloc<=roomtall) then
         if distance(aimxloc,aimyloc,wxloc,wyloc)-1<=obj^[weapon0n].d[5] MOD 16 then
         begin
          roomprojectile(aimxloc,aimyloc,wxloc,wyloc,skill);
          showweapon(weapon0t,weapon0n,aimxloc,aimyloc,wxloc,wyloc,roomwide,roomtall);
          if not hitcreature(weapon0t,weapon0n,skill)
           then shootterrain(weapon0t,weapon0n);
         end;
        end;
       end;
     wxloc:=old_wxloc;wyloc:=old_wyloc;
     end;
     sounded:=false;
     delay2(combatpacing);

end;

procedure attacking(ttxloc,ttyloc,ttwxloc,ttwyloc,
                    ttweapon1n,ttweapon2n,skill:byte);
begin
  aimxloc:=ttxloc;
  aimyloc:=ttyloc;
  wxloc:=ttwxloc;
  wyloc:=ttwyloc;
  weapon1n:=ttweapon1n;weapon2n:=ttweapon2n;
  if weapon1n=0 then weapon1t:=0
   else weapon1t:=obj^[weapon1n].t;
  if weapon2n=0 then weapon2t:=0
   else weapon2t:=obj^[weapon2n].t;
  if (weapon1n=0) and (weapon2n=0) then exit;
  sounded:=false;
  roomprojectile(aimxloc,aimyloc,wxloc,wyloc,skill);

    {process ranged weapons}
   resolve_rangedweapon(weapon1t,weapon1n,skill);
   sounded:=false;
   aimxloc:=ttxloc;
   aimyloc:=ttyloc;
   wxloc:=ttwxloc;
   wyloc:=ttwyloc;
   weapon2n:=ttweapon2n;
   if weapon2n=0 then weapon2t:=0
    else weapon2t:=obj^[weapon2n].t;

   roomprojectile(aimxloc,aimyloc,wxloc,wyloc,skill);
   resolve_rangedweapon(weapon2t,weapon2n,skill);
   if ((wxloc<>aimxloc) or (wyloc<>aimyloc)) then begin
    if weapon1t=7 then
     begin
      aimxloc:=ttxloc;
      aimyloc:=ttyloc;
      wxloc:=ttwxloc;
      wyloc:=ttwyloc;
      weapon1n:=ttweapon1n;
      if weapon1n=0 then weapon1t:=0
       else weapon1t:=obj^[weapon1n].t;
      showweapon(weapon1t,weapon1n,aimxloc,aimyloc,wxloc,wyloc,roomwide,roomtall);
      inverttarget(wxloc,wyloc,roomwide,roomtall);
      if not hitcreature(weapon1t,weapon1n,skill)
       then shootterrain(weapon1t,weapon1n);
      inverttarget(wxloc,wyloc,roomwide,roomtall);
      {process melee weapon 1}
     end;
    if weapon2t=7 then
     begin
      aimxloc:=ttxloc;
      aimyloc:=ttyloc;
      wxloc:=ttwxloc;
      wyloc:=ttwyloc;
      weapon2n:=ttweapon2n;
      if weapon2n=0 then weapon2t:=0
       else weapon2t:=obj^[weapon2n].t;
      showweapon(weapon2t,weapon2n,aimxloc,aimyloc,wxloc,wyloc,roomwide,roomtall);
            inverttarget(wxloc,wyloc,roomwide,roomtall);
      if not hitcreature(weapon2t,weapon2n,skill)
       then shootterrain(weapon2t,weapon2n);
             inverttarget(wxloc,wyloc,roomwide,roomtall);
       {process melee weapon 2}
     end;
   end;

end;


procedure maponly(room,px,py:byte);
var putgrapc,x,y:byte;
    shadowing:byte;
    creatureslot:byte;
    oldspot:byte;
    rise,run,herex,herey,xystep:integer;
    xstep,ystep:shortint;
    done,opaque:boolean;
    limit_found,two_found:boolean;
    two_x,two_y:byte;
    attacktaken:boolean;
    shadowscan:Array[1..16,1..11] of byte;

var motionx,motiony,attacklocx,attacklocy:byte; {what it would like to do}
    found,fight:boolean;

  var movedindex:byte;
    foundrange:integer;
    longisbest:boolean;



function checkdest(xscc,yscc:integer;who:byte):boolean;
var 
    mapobj,mapobjdata,creaturevehicle:byte;
    passable:boolean;
	point,nextpoint:word;
	donedigging:boolean;

	
{$I I_CHKDST.PAS} {the same code is used by wmap and room regions}	
	
 begin
    mapobj:=map[2,2,xscc,yscc].o;
    mapobjdata:=map[2,2,xscc,yscc].d;
    creaturevehicle:=crc^[rcrc^[who].crcsource].veh;
	
    if (mapobj=255) or (obj^[mapobj].t>5) then
	  begin
	   if mapobj<>255 then mapobj:=0;
	   point:=locnt^[roomloc(room,xscc,yscc)].p;
	   donedigging:=(locnt^[point].p=0);
	   nextpoint:=point;
	   while not donedigging do
	    begin
		 nextpoint:=locnt^[nextpoint].p;
		 if locnt^[nextpoint].p=0 then donedigging:=true;
		 if (locnt^[nextpoint].obj<>0) and (locnt^[nextpoint].obj<>255)
		  then if obj^[locnt^[nextpoint].obj].t<6 then
		   begin; mapobj:=locnt^[nextpoint].obj; donedigging:=true; end;
		   
		end;
	  end;	

  {perform the actual check... }
  if (xscc>=roomwide) or (xscc<=1) or (yscc<=1) or (yscc>=roomtall) then passable:=false else
   passable:=checkdest2(mapobj,creaturevehicle);

  {one final check: make sure they're not trying to step on the player!}
  if (xscc=xloc) and (yscc=yloc) then passable:=false;

  {return the result}
  checkdest:=passable;	  
end;
	


procedure movecreature(xsc,ysc,xscc,yscc:integer);
 var cnum:byte;
     addslotc:integer;
     buffer_p:word;
begin
 cnum:=map[2,2,xsc,ysc].d;
 {$IFDEF DEBUG}
  writeln(printer,'Moving creature: from ',xsc,',',ysc,' to ',xscc,',',yscc);

 {$ENDIF}
 if movedindex=creaturemoved[cnum] then exit;

 CHUNKSAVE:=true;
 creaturemoved[cnum]:=movedindex;               {prevents double moves}

 {restore footpad}
 xmod:=xsc;ymod:=ysc;

{find inital pointer, store in buffer}
 buffer_p:=rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1];

{set inital pointer to what's under the creature}
 rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=
  locnt^[buffer_p].p;

{set creature's pointer to the new space's initial pointer}
 locnt^[buffer_p].p:=
  rmcnt^[xscc+region.room.x1[room]-1,yscc+region.room.y1[room]-1];

{set new space's initial pointer to the creature}
 rmcnt^[xscc+region.room.x1[room]-1,yscc+region.room.y1[room]-1]:=
  buffer_p;

 moved:=true;getroom(room);
end;


procedure scanalign(anger,crcalign:byte;var ax,ay:byte;this_crcsource:byte);
 var xloop,yloop:byte;
     myx,myy:byte;
begin
 { you are xinloc+15, yinloc+15 }
 writelog(0,'scanalign '+strnum(this_crcsource)+' anger: '+strnum(anger)+' crcalign: '+
   strnum(crcalign)+' ack.align: '+strnum(ack.alignment)+' ack.crim: '+strnum(ack.criminal));
 myx:=x;
 myy:=y;
 found:=false;
 foundrange:=32760;
 if anger=0 then exit;
 if (anger>4) or (anger=ack.alignment) or (ack.criminal=crcalign) then
  if (ack.hp[0]>0) and (ack.invisible=0) and (resurrect=false) then 
  begin
   {if random(6)<4 then
    soundeffect(hi(crcsounds[rcrc^[this_crcsource].crcsource]));}
   found:=true;
   ax:=xloc;
   ay:=yloc;
   foundrange:=round(1000*sqrt(sqr(ax-myx)+sqr(ay-myy)));
  end;
{$IFDEF DEBUG}
 write(printer,'Scanning.  MyLoc=',myx,',',myy,'.  YourLoc=',xloc,',',yloc,
         '  Anger=',anger,'.  ');
{$ENDIF}

 for xloop:=1 to roomwide do
  for yloop:=1 to roomtall do
  if (map[2,2,xloop,yloop].o=255) then
    if (round(1000*sqrt(sqr(xloop-myx)+sqr(yloop-myy)))<foundrange)
     and (((myx=xloop) and (myy=yloop))=false) then
      begin
      if (crc^[rcrc^[map[2,2,xloop,yloop].d].crcsource].t=anger)
       or (anger=6) and
       (rcrc^[map[2,2,xloop,yloop].d].crcsource<>this_crcsource)
       then
         begin
           found:=true;
           ax:=xloop;
           ay:=yloop;
           foundrange:=round(1000*sqrt(sqr(xloop-myx)+sqr(yloop-myy)));
         end;
      {check creature}
     end;

end;


var xmotion,ymotion:integer;

 nowviewdistance,xlit,ylit:byte;

begin
 aggro:=0;
 anim_tall:=roomtall;anim_wide:=roomwide;
 shadowing:=region.shadow;
 movedindex:=random(256);

 regattacknum:=1;
 for x:=1 to roomwide do for y:=1 to roomtall do anim_screen[x,y].aggro:=false;
 for x:=1 to roomwide do for y:=1 to roomtall do
   if map[2,2,x,y].o=255

{************}

    then with rcrc^[map[2,2,x,y].d] do
    begin
     scanalign(anger,crc^[crcsource].t,attacklocx,attacklocy,crcsource);
{$IFDEF DEBUG}
     if not found then writeln(printer,'Nothing found.') else
      writeln(printer,'Target at ',attacklocx,',',attacklocy,'.');
{$ENDIF}

     if found then
      with crc^[crcsource] do begin
	   anim_screen[x,y].aggro:=true;
	   writelog(199,'processing aggro for '+n+' (#'+strnum(crcsource)+') at range '+strnum(foundrange));
       attacker_alignment:=t;
       attacker_id:=crcsource;
	   inc(aggro);
       {enemy found. determine action}
       fight:=false;
       if (motive=2) or (motive=130) {oops, old bug fix}
         then fight:=true {stop: hammer time.  can't move. try firing}
        else
         begin

          if (fw<>0) and (fr<>0) then
           if u_vars.obj^[fw].d[4]>u_vars.obj^[fr].d[4] then
            longisbest:=false else longisbest:=true;
			
          if random(3)=1 then longisbest:=true;
          if random(4)=1 then longisbest:=false;
          if fr=0 then longisbest:=false;
          if fw=0 then longisbest:=true;
		  if ((u_vars.obj^[fr].d[5] MOD 16)+1)*1000 < foundrange then longisbest:=false; {fix for NPCs ignoring range}
          if ( (foundrange<=1000) and (not longisbest) ) or
             ( (foundrange>1) and (longisbest) ) then fight:=true;
          {consider motion. if not moving, set fight:=true.}


         end;
       if creaturemoved[map[2,2,x,y].d]=movedindex
           then fight:=false;
       if not fight then
        begin
		 writelog(199,'creature is moving');
         xmotion:=0;ymotion:=0;
         if x>xloc then xmotion:=-1;
         if x<xloc then xmotion:=1;
         if y>yloc then ymotion:=-1;
         if y<yloc then ymotion:=1;
         if (longisbest) and (foundrange<3000) then
            begin;xmotion:=-xmotion;ymotion:=-ymotion;end;
         if (ymotion<>0) and (xmotion<>0) then
          if random(2)=1 then ymotion:=0 else xmotion:=0;
         if checkdest(x+xmotion,y+ymotion,map[2,2,x,y].d) then
          movecreature(x,y,x+xmotion,y+ymotion) 
		   else begin;fight:=true;writelog(0,'cannot move, will try fighting');end; 

         {do motion}
        end;		   
		   
       if fight then
        begin
		 writelog(199,'creature is fighting');
	     if ((foundrange>1) AND (fr<>0)) or ((foundrange<=1000) AND (fw<>0)) then
		 begin
         if foundrange>1000 then whoops:=rws else whoops:=ws; if fw=0 then whoops:=rws;
      (*   if random(whoops)<OOPS then
          case random(4) of
           0:dec(attacklocx);
           1:dec(attacklocy);
           2:inc(attacklocx);
           3:inc(attacklocy);
          end; {whoops}   *)
      registerattacks[regattacknum,8]:=crcsource;
         registerattacks[regattacknum,1]:=x;
         registerattacks[regattacknum,2]:=y;
         registerattacks[regattacknum,3]:=attacklocx;
         registerattacks[regattacknum,4]:=attacklocy;
         if (foundrange<=1000) and (fw<>0) then
           registerattacks[regattacknum,5]:=fw else
           registerattacks[regattacknum,5]:=0;
         if (foundrange>1000) or (fw=0) then
           registerattacks[regattacknum,6]:=fr else
           registerattacks[regattacknum,6]:=0;
         registerattacks[regattacknum,7]:=whoops;

         if regattacknum<16 then inc(regattacknum);
         creaturemoved[map[2,2,x,y].d]:=movedindex;
         {fire weapon}
		 end;
        end;

      end {determine} else
       if motive=0 then
        case random(8) of
         1:if checkdest(x-1,y,map[2,2,x,y].d) then movecreature(x,y,x-1,y);
         2:if checkdest(x+1,y,map[2,2,x,y].d) then movecreature(x,y,x+1,y);
         3:if checkdest(x,y-1,map[2,2,x,y].d) then movecreature(x,y,x,y-1);
         4:if checkdest(x,y+1,map[2,2,x,y].d) then movecreature(x,y,x,y+1);
        end; {rnd8 case}

     end; {with do}

{**************}


 for x:=1 to roomwide do for y:=1 to roomtall do
begin

  obj8:=map[2,2,x,y].o;
  anim_screen[x,y].lit:=1;
  anim_screen[x,y].under:=0;

    if obj^[obj8].t<6 then
    begin
     if obj^[obj8].d[8]=3 then
      begin
       dp8:=0;
       trypassable(dp8,obj^[obj8].d[4],obj^[obj8].d[5]);
       if dp8<>0 then obj8:=obj^[obj8].d[12];

              {}{}{}
      end;
     if (obj^[obj8].d[4] AND 64) = 64 then anim_screen[x,y].lit:=2;
    end;

  if (ack.anim_speed=0) or (obj^[obj8].t>=6) then
   begin
    quasimap[x,y]:=obj^[obj8].d[1];
    anim_screen[x,y].tb:=false;
		if transparency then 
		if (obj^[obj8].t>5) then
		 begin
		  {this is an item, drill down}
		   anim_screen[x,y].under:=roomunder[x,y];
         end;		
   end
    else
      if obj8=255 then
       begin
        creatureslot:=map[2,2,x,y].d;
{}{}    rcrc^[creatureslot].obj:=locnt^[locnt^[roomloc(room,x,y)].p].obj;
	    if transparency then
		 begin
		  {this is a creature, drill down}
		  
		  anim_screen[x,y].under:=roomunder[x,y];
		 end; 
        if ((obj^[rcrc^[creatureslot].obj].t<3)
         and (obj^[rcrc^[creatureslot].obj].d[13]<>0))
         then
          begin
           quasimap[x,y]:=obj^[rcrc^[creatureslot].obj].d[13];
           anim_screen[x,y].tb:=false;
		   anim_screen[x,y].under:=0;
          end
         else
          begin
           quasimap[x,y]:=crc^[rcrc^[creatureslot].crcsource].g1;
           if crc^[rcrc^[creatureslot].crcsource].g2=0 then anim_screen[x,y].tb:=false else anim_screen[x,y].tb:=true;
           anim_screen[x,y].tb4:=true;
           with anim_screen[x,y] do
            begin
             t1:=crc^[rcrc^[creatureslot].crcsource].g1;
             t2:=crc^[rcrc^[creatureslot].crcsource].g2;
             t3:=crc^[rcrc^[creatureslot].crcsource].g3;
             t4:=crc^[rcrc^[creatureslot].crcsource].g4;
            end;
          end;
       end else
      begin
       anim_screen[x,y].tb4:=false;
       {animation sequence}
       {if anim_phase_one then }
        quasimap[x,y]:=obj^[obj8].d[1];
	  

        { else
         quasimap[x,y]:=obj^[map[2,2,x,y].o].d[6]; }
       with anim_screen[x,y] do
       begin
       t1:=obj^[obj8].d[1];
       t2:=obj^[obj8].d[6];
       if t2=0 then tb:=false else tb:=true;
       end;
      end;

if ack.minviewdistance>ack.viewdistance then nowviewdistance:=ack.minviewdistance
  else nowviewdistance:=ack.viewdistance;
if nowviewdistance<16 then
  if distance(px,py,x,y)>nowviewdistance then
   begin
    {anim_screen[x,y].tb:=false;
    quasimap[x,y]:=240;}
    anim_screen[x,y].lit:=(anim_screen[x,y].lit AND 2);
   end;
end;
 oldspot:=map[2,2,px,py].o;map[2,2,px,py].o:=0;




  if shadowing<>255 then
   begin
    for x:=1 to roomwide do for y:=1 to roomtall do
     shadowscan[x,y]:=0;  {clear shadowscan array}
     shadowscan[xloc,yloc]:=2; {start expansion at xloc,yloc}
     limit_found:=false;
    repeat
      x:=0;y:=1;two_found:=false;
      repeat
       inc(x);
       if x>roomwide then begin;x:=1;inc(y);end;
       if y<=roomtall then
        begin
         if shadowscan[x,y]=2 then
          begin
           two_found:=true;
           two_x:=x;
           two_y:=y;
          end;
        end
        else limit_found:=true;
      until (two_found) or (limit_found);
     {search for two, set two_found,two_x,two_y.}
     if two_found then
      begin

       if two_x-1>0 then    {check x-1,y}
        if shadowscan[two_x-1,two_y]=0 then
         if (obj^[map[2,2,two_x-1,two_y].o].t>5) or
          (obj^[map[2,2,two_x-1,two_y].o].d[4]<127) then
           shadowscan[two_x-1,two_y]:=2 else
            shadowscan[two_x-1,two_y]:=1;

       if two_x+1<=roomwide then   {check x+1,y}
        if shadowscan[two_x+1,two_y]=0 then
         if (obj^[map[2,2,two_x+1,two_y].o].t>5) or
          (obj^[map[2,2,two_x+1,two_y].o].d[4]<127) then
           shadowscan[two_x+1,two_y]:=2 else
            shadowscan[two_x+1,two_y]:=1;

       if two_y-1>0 then    {check x,y-1}
        if shadowscan[two_x,two_y-1]=0 then
         if (obj^[map[2,2,two_x,two_y-1].o].t>5) or
          (obj^[map[2,2,two_x,two_y-1].o].d[4]<127) then
           shadowscan[two_x,two_y-1]:=2 else
            shadowscan[two_x,two_y-1]:=1;

       if two_y+1<=roomtall then   {check x,y+1}
        if shadowscan[two_x,two_y+1]=0 then
         if (obj^[map[2,2,two_x,two_y+1].o].t>5) or
          (obj^[map[2,2,two_x,two_y+1].o].d[4]<127) then
           shadowscan[two_x,two_y+1]:=2 else
            shadowscan[two_x,two_y+1]:=1;

       if (two_x-1>0) and (two_y-1>0) then    {check x-1,y-1}
        if shadowscan[two_x-1,two_y-1]=0 then
         if (obj^[map[2,2,two_x-1,two_y-1].o].t>5) or
          (obj^[map[2,2,two_x-1,two_y-1].o].d[4]<127) then
           shadowscan[two_x-1,two_y-1]:=2 else
            shadowscan[two_x-1,two_y-1]:=1;

       if (two_x+1<=roomwide) and (two_y-1>0) then   {check x+1,y-1}
        if shadowscan[two_x+1,two_y-1]=0 then
         if (obj^[map[2,2,two_x+1,two_y-1].o].t>5) or
          (obj^[map[2,2,two_x+1,two_y-1].o].d[4]<127) then
           shadowscan[two_x+1,two_y-1]:=2 else
            shadowscan[two_x+1,two_y-1]:=1;

       if (two_x-1>0) and (two_y+1<=roomtall) then    {check x-1,y+1}
        if shadowscan[two_x-1,two_y+1]=0 then
         if (obj^[map[2,2,two_x-1,two_y+1].o].t>5) or
          (obj^[map[2,2,two_x-1,two_y+1].o].d[4]<127) then
           shadowscan[two_x-1,two_y+1]:=2 else
            shadowscan[two_x-1,two_y+1]:=1;

       if (two_x+1<=roomwide) and (two_y+1<=roomtall) then   {check x+1,y+1}
        if shadowscan[two_x+1,two_y+1]=0 then
         if (obj^[map[2,2,two_x+1,two_y+1].o].t>5) or
          (obj^[map[2,2,two_x+1,two_y+1].o].d[4]<127) then
           shadowscan[two_x+1,two_y+1]:=2 else
            shadowscan[two_x+1,two_y+1]:=1;

       shadowscan[two_x,two_y]:=1;
      end; {two_found}
    until limit_found;
    for x:=1 to roomwide do for y:=1 to roomtall do
     if shadowscan[x,y]=0 then
      begin
	   if anim_screen[x,y].aggro then dec(aggro);
       quasimap[x,y]:=0;
       anim_screen[x,y].tb:=false;
       anim_screen[x,y].lit:=1;
	   anim_screen[x,y].under:=0;
      end else 
	  begin
	  if (anim_screen[x,y].lit AND 2)=2 then
       begin
	   
      {  for xlit:=0 to 2 do
         for ylit:=0 to 2 do
          anim_screen[x+xlit-1,y+ylit-1].lit:=anim_screen[x+xlit-1,y+ylit-1].lit OR 1; }

        for xlit:=0 to 4 do
         for ylit:=0 to 4 do
		  if
		   (x+xlit-2 > 0) and
		   (y+ylit-2 > 0) and
		   (x+xlit-2 <= roomwide) and
		   (y+ylit-2 <= roomtall) and
		   (xlit+ylit<>0) and
		   (xlit*10 + ylit <> 40) and
		   (xlit*10 + ylit <> 44) and
		   (xlit*10 + ylit <> 4) 
		   then	   
		    anim_screen[x+xlit-2,y+ylit-2].lit:=anim_screen[x+xlit-2,y+ylit-2].lit OR 1;
		  
		  

       end;
	   if quasimap[x,y]=DECOGRP then
	    begin
		 anim_screen[x,y].tb:=false;
		 anim_screen[x,y].t2:=map[2,2,x,y].d;
		end;
      end;
   end; {if shadowing}


if ack.hp[0]>0 then
begin
 anim_screen[px,py].tb:=false;
 quasimap[px,py]:=curricon;

end; 
 map[2,2,px,py].o:=oldspot;
 if transparency then anim_screen[px,py].under:=map[2,2,px,py].o; 
 for y:=1 to roomtall do for x:=1 to roomwide do
   {if quasimap[x,y]<>0 then}
  if anim_screen[x,y].lit=0 then 
  begin
   if quasimap[x,y]=DECOGRP then
    putdarkgrap2((x*4-3 +(32-(roomwide*2))),(y*16-14 +(88-(roomtall*8))),anim_screen[x,y].t2,
	ack.darkforeground,ack.darkbackground) else
	begin
     if anim_screen[x,y].under=0 then
	  putdarkgrap((x*4-3 +(32-(roomwide*2))),
       (y*16-14 +(88-(roomtall*8))),quasimap[x,y])
	  else begin
         	putdarktransgrap11((x*4-3 +(32-(roomwide*2))),
             (y*16-14 +(88-(roomtall*8))),quasimap[x,y],obj^[anim_screen[x,y].under].d[1]);
			end; 
     anim_screen[x,y].tb:=false;
	end; 
  end
   else 
   if quasimap[x,y]=DECOGRP then
   putgrap2((x*4-3 +(32-(roomwide*2))),(y*16-14 +(88-(roomtall*8))),anim_screen[x,y].t2)
   else 
    begin
	 if anim_screen[x,y].under=0 then
	  putgrap((x*4-3 +(32-(roomwide*2))),(y*16-14 +(88-(roomtall*8))),quasimap[x,y]) else
	 puttransgrap11((x*4-3 +(32-(roomwide*2))),(y*16-14 +(88-(roomtall*8))),quasimap[x,y],obj^[anim_screen[x,y].under].d[1]);
	end; 

  {clearbottom;}
 savepage;
 for x:= 1 to regattacknum-1 do
  begin
   xlit:=registerattacks[x,3];
   ylit:=registerattacks[x,4];
   roomprojectile(registerattacks[x,1],registerattacks[x,2],xlit,ylit,registerattacks[x,7]);
   if (registerattacks[x,3]=xlit) and (registerattacks[x,4]=ylit) then
   begin {only bother attacking if you can hit}  
    attacker_id:= registerattacks[x,8];
    attacking(registerattacks[x,1],registerattacks[x,2],
            registerattacks[x,3],registerattacks[x,4],
            registerattacks[x,5],registerattacks[x,6],
            registerattacks[x,7]);
   end;
  end;
  if regattacknum>1 then begin;delay2(combatpacing*6);restorepage;end;
 if roomtall<>11 then
    if region.room.name[room]<>'NEW ROOM' then
      say(34-(length(region.room.name[room])),(10-roomtall)*8 + 2,0,region.room.name[room]);
 anim_toggle;
end;


procedure showroom(room,px,py:byte);
begin
 if resurrect then exit;
 if starting_up_clearscreen then clearscreen else
   starting_up_clearscreen:=true;
 {
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,200,319,3);
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3);
 }
 {if roomtall>10 then erset(false) else }erset(true);
 getroom(room);
 maponly(room,px,py);
 global_room:=room;
 global_xloc:=px;
 global_yloc:=py;

end;



begin
 calculate_weight;
 curricon:=0;
 newroom:=true;
 done:=false;
  getroom(room);
  
 if entrancemacro<>0 then 
  begin
   writelog(entrancemacro,'Running entrance macro');
   run_macro(entrancemacro);
   
  end;   
  
  xloc:=x;yloc:=y;
  anim_wide:=roomwide;anim_tall:=roomtall;
  erasebottom:=6;
  clearbottom;{bottomsay(0,'   '+region.name);}
  moved:=true;
repeat
 arrowmoved:=false;
      ack.plregion:=rgn;
      ack.plxch:=room;
      ack.plych:=255;
      ack.plxloc:=xloc;
      ack.plyloc:=yloc;

  levelup;
{ if key_report then readkey_Report; }


 cycletime;
 (*
 if timephase=1 then
  begin
   {morning}
   clearbottom;
   bottomsay(0,'DAY IS BREAKING.');
   erasebottom:=7;
   timephase:=3;
  end;
 if timephase=2 then
  begin
   {evening}
   clearbottom;
   bottomsay(0,'NIGHT IS FALLING.');
   erasebottom:=7;
   timephase:=4;
  end;
  *)
 if ack.hp[0]=0 then begin;playerdeath;readkey_time:=0;readkey_default:=#255;end;
 if macro_teleport then
  begin
   if moved then maponly(room,xloc,yloc);
   
    readkey_time:=0;
    readkey_default:=#201;
    macrosuccess:=1;
  	thisportal:=255;
    region.port[thisportal].region:=global_region;
	if global_region<>rgn then
	begin
	 {traveling to new region}
	 if teleport_room<>0 then region.port[thisportal].rx:=teleport_room
	  else region.port[thisportal].rx:=global_xchunk;
	end else
    begin	
	 region.port[thisportal].rx:=global_room;
	end;	
    region.port[thisportal].ry:=global_ychunk;
    region.port[thisportal].x:=global_xloc;
    region.port[thisportal].y:=global_yloc;   
   
   
   (*
   
   done:=true;
   rgn:=global_region;
   room:=global_xchunk;
   ydummy:=global_ychunk;
   x:=global_xloc;
   y:=global_yloc;
   xloc:=global_xloc; 
   yloc:=global_yloc;
   if global_room<>0 then room:=global_room; *)
   macro_teleport:=false;
  end;
  teleport_room:=0;
  global_xloc:=xloc;
  global_yloc:=yloc;
  global_xchunk:=room;
  global_ychunk:=0;
  global_room:=room;
  global_region:=rgn;

  curricon:=ack.playericon;
    if ack.invisible>0 then if ack.invis_icon<>0 then curricon:=ack.invis_icon;
  if ack.pweapready<>0 then if obj^[ack.pweapready].d[13]<>0 then
   curricon:=obj^[ack.pweapready].d[13];
  if ack.parmor[1]<>0 then if obj^[ack.parmor[1]].d[13]<>0 then
   curricon:=obj^[ack.parmor[1]].d[13];
  if ack.plvehicle<>0 then if obj^[ack.plvehicle].d[13]<>0 then
    curricon:=obj^[ack.plvehicle].d[13];
  if map[2,2,xloc,yloc].o<>0 then
   if (obj^[map[2,2,xloc,yloc].o].t<3) AND (obj^[map[2,2,xloc,yloc].o].d[13]<>0)
    then if obj^[map[2,2,xloc,yloc].o].d[13]=255 then
     curricon:=obj^[map[2,2,xloc,yloc].o].d[1] else
       curricon:=obj^[map[2,2,xloc,yloc].o].d[13];
  if obj^[map[2,2,xloc,yloc].o].t<3 then
       if (obj^[map[2,2,xloc,yloc].o].d[4]=19) and (ack.plvehicle<>0) then
        curricon:=obj^[map[2,2,xloc,yloc].o].d[1];
{  if newroom then blankbox(3,1,260,178); }
  if newroom then begin;roomloadwandering(room);showroom(room,xloc,yloc);moved:=false;end;
  newroom:=false;
   if moved then begin;getroom(room);maponly(room,xloc,yloc);end;

   if erasebottom=1 then clearbottom;
   if erasebottom<>0 then dec(erasebottom);
{REVISIT?}
   if doublepass then actionparser(0,0,0,0,0,0,0,0);
  if not done then begin
  
  if moved then
  if region.room.wallgrap[16]<>0 then
   begin
   if region.room.wallgrap[16]=1 then
    begin
     if ack.stepmacro<>0 then run_macro(ack.stepmacro)
    end else run_macro(region.room.wallgrap[16]-1);
   end;
  moved:=false;
 
 if action_weap=22 then
  begin
   wxloc:=xloc;
   wyloc:=yloc;
   showweapon(obj^[a_weap_type].t,a_weap_type,a_weap_org_x,a_weap_org_y,
      wxloc,wyloc,roomwide,roomtall);
   {whack player with weapon}
   if not hitcreature(obj^[a_weap_type].t,a_weap_type,100)
    then shootterrain(obj^[a_weap_type].t,a_weap_type);
   action_weap:=0;
  end;



   calculate_weight;
   doqueued_stepaction;
   graphHP;
    if ack.hp[0]=0 then begin;readkey_time:=0;readkey_default:=#255;end;
	
   writelog(255,'Readkey_default: '+readkey_default+' (#'+strnum(ord(readkey_default))+')');
   if action_weap=23 then begin;writelog(255,'...changing to A to process weapon');readkey_default:='A';readkey_time:=0;end;
   if (random(encumberance+1)<=1) or (j=#253) then
  j:=upcase(timed_readkey(j2)) else
  j:=#253;
  writelog(255,'Readkey result: '+j+' (#'+strnum(ord(j))+')');
   xlocold:=xloc;ylocold:=yloc;
 case j of
  #0:case j2 of
       #50:begin
       if disablemouse then
        begin
          disablemouse:=false;
          initmouse;
        end else
        begin
          closemouse;
          disablemouse:=true;
        end;
      end;
  #47:mutesoundmenu;
  #68,#16,#31:begin
      say(43,188,6,' SAVE GAME? [Y/N] ');
      ack.plregion:=rgn;
      ack.plxch:=room;
      ack.plych:=255;
      ack.plxloc:=xloc;
      ack.plyloc:=yloc;
      moved:=false;
      repeat
       case upcase(readkey) of
        'Y':begin;done:=true;moved:=true;end;
        'N':if ((j2=#16) or (j2=#68)) then begin;shutdownsound;halt;end else moved:=true;
        #27:begin;moved:=true;j2:=#31;done:=false;end;
        end;
      until moved;
      if done then
       begin
        say(43,188,4,'  SAVING GAME...  ');
        saveconfig;
        savemap;
        fullgamesave;
		savegame_menu;
        if (j2=#16) or (j2=#68) then begin;shutdownsound;halt;end;
        say(43,188,0,'                  ');
       end;
       done:=false;moved:=false;clearbottom;
      end;

  'H':begin
      if yloc>2 then begin;moved:=true;passtime(region.room.wallgrap[15]);
       if rtrymove(xloc,yloc-1,xloc,yloc,room)<99 then
       begin;dec(yloc);arrowmoved:=true;end;
	   end else
       begin
        rtryval:=rtrymove(xloc,1,xloc,yloc,room);passtime(region.room.wallgrap[15]);
        if rtryval=0 then checkadjacent(xloc,0,0)
        else if rtryval=5 then begin;moved:=true;
         if checkfuel then begin;dec(yloc);arrowmoved:=true;end;
		 end;
       end;lastmov:=1; 
      end;
  'K':begin
      if xloc>2 then begin;moved:=true;passtime(region.room.wallgrap[15]);
       if rtrymove(xloc-1,yloc,xloc,yloc,room)<99 then
       if checkfuel then 
	   begin;dec(xloc);arrowmoved:=true;end;
	   end else
       begin
        rtryval:=rtrymove(1,yloc,xloc,yloc,room);passtime(region.room.wallgrap[15]);
        if rtryval=0 then checkadjacent(0,yloc,2)
        else if rtryval=5 then begin;moved:=true;
         if checkfuel then begin;dec(xloc);arrowmoved:=true;end;
		 end;
       end;lastmov:=4; 	
      end;
  'M':begin
      if xloc<roomwide-1 then begin;moved:=true;passtime(region.room.wallgrap[15]);
      if rtrymove(xloc+1,yloc,xloc,yloc,room)<99
      then if checkfuel then 
	  begin;inc(xloc);arrowmoved:=true;end;
	  end else
       begin
        rtryval:=rtrymove(roomwide,yloc,xloc,yloc,room);passtime(region.room.wallgrap[15]);
        if rtryval=0 then checkadjacent(roomwide+1,yloc,3)
        else if rtryval=5 then begin;moved:=true;
         if checkfuel then begin;inc(xloc);arrowmoved:=true;end;
		 end;
       end;lastmov:=3; 
	  end; 
  'P':begin
      if yloc<roomtall-1 then begin;moved:=true;passtime(region.room.wallgrap[15]);
      if rtrymove(xloc,yloc+1,xloc,yloc,room)<99
      then if checkfuel then 
	  begin;inc(yloc);arrowmoved:=true;end;
	  end else
       begin
        rtryval:=rtrymove(xloc,roomtall,xloc,yloc,room);passtime(region.room.wallgrap[15]);
        if rtryval=0 then checkadjacent(xloc,roomtall+1,1)
        else if rtryval=5 then begin;moved:=true;
         if checkfuel then begin;inc(yloc);arrowmoved:=true;end;
		 end;
       end;
	   lastmov:=2; 
	  end; 
  end;

  #32:begin;clear_keyboard_buffer;moved:=true;passtime(region.room.wallgrap[15]);end;
    #9:begin
      sound(500); loadgraps; loadobjs; loadfont; loadcreatures; nosound;
     end;
  'A':begin
       ack.invisible:=0;
       passtime(2);
       if ack.pweapready<>0 then
        if ack.pinv[ack.pweapready]=0 then ack.pweapready:=0;
       moved:=true;
       attacker_alignment:=5;
       weapon2t:=0;weapon2n:=0;weapon1t:=0;weapon1n:=0;
       if ack.pweapready<>0 then
        begin;weapon1t:=obj^[ack.pweapready].t;
        weapon1n:=ack.pweapready;end;
       if ack.plvehicle<>0 then
        if obj^[ack.plvehicle].d[4]<>0 then
         begin;weapon2t:=obj^[obj^[ack.plvehicle].d[4]].t;
         weapon2n:=obj^[ack.plvehicle].d[4];end;
      

      if action_weap<>23 then
      begin
       if weapon1n<>0 then if obj^[weapon1n].t=8 then
       if obj^[weapon1n].d[6]=255 then
        begin
         if ack.mp[0]<obj^[weapon1n].d[7] then
          begin
           weapon1n:=0;
           bottomsay(1,obj^[weapon1n].n);
           bottomsay(2,'OUT OF ENERGY');
           delay2(combatpacing*10);
           clearbottom;
          end;
        end else
       if obj^[weapon1n].d[6]=1 then
        begin
         if ack.PCASH=0 then
          begin
           weapon1n:=0;
           bottomsay(1,obj^[weapon1n].n);
           bottomsay(2,'OUT OF AMMUNITION');
           delay2(combatpacing*10);
           clearbottom;
          end;
        end else
       if (obj^[weapon1n].d[6]<>0) and (obj^[weapon1n].d[7]<>0) then
         if (ack.PINV[obj^[weapon1n].d[6]])=0 then
           begin
            weapon1n:=0;
            bottomsay(1,obj^[weapon1n].n);
            bottomsay(2,'OUT OF AMMUNITION');
            delay2(combatpacing*10);
            clearbottom;
           end;

      if weapon2n<>0 then if obj^[weapon2n].t=8 then
       if obj^[weapon2n].d[6]=255 then
        begin
         if ack.mp[0]<obj^[weapon2n].d[7] then
          begin
           weapon2n:=0;
           bottomsay(1,obj^[weapon2n].n);
           bottomsay(2,'OUT OF ENERGY');
           delay2(combatpacing*10);
           clearbottom;
          end;
        end else
       if obj^[weapon2n].d[6]=1 then
        begin
         if ack.PCASH=0 then
          begin
           weapon2n:=0;
           bottomsay(1,obj^[weapon2n].n);
           bottomsay(2,'OUT OF AMMUNITION');
           delay2(combatpacing*10);
           clearbottom;
          end;
        end else
       if (obj^[weapon2n].d[6]<>0) and (obj^[weapon2n].d[7]<>0) then
         if (ack.PINV[obj^[weapon2n].d[6]])=0 then
           begin
            weapon2n:=0;
            bottomsay(1,obj^[weapon2n].n);
            bottomsay(2,'OUT OF AMMUNITION');
            delay2(combatpacing*10);
            clearbottom;
           end;
       end;
       if action_weap=23 then
        begin
         weapon1n:=a_weap_type;
         weapon1t:=obj^[a_weap_type].t;
         weapon2t:=0;weapon2n:=0;
        end;

       if (weapon1t=0) and (weapon2t=0) then
        begin
         clearbottom;bottomsay(0,'NO WEAPON');delay2(combatpacing*5);erasebottom:=3;
        end else

       begin
        maxrange:=0;
        if (weapon1t=8) then
         if obj^[weapon1n].d[5] DIV 16 < 11 then
          maxrange:=obj^[weapon1n].d[5] MOD 16;
        if (weapon2t=8) then
         if obj^[weapon2n].d[5] DIV 16 < 11 then
          if maxrange<obj^[weapon2n].d[5] MOD 16 then
           maxrange:=obj^[weapon2n].d[5] MOD 16;
        wxloc:=xloc;wyloc:=yloc;
 if maxrange=0 then
  begin
   xmod:=0;
   getadjacentlocation(xmod,ymod,'SELECT DIRECTION TO ATTACK',false);
   wxloc:=xloc+xmod;wyloc:=yloc+ymod;
   if wxloc>roomwide then wxloc:=roomwide;
   if wyloc>roomtall then wyloc:=roomtall;
   if wxloc<1 then wxloc:=1;
   if wyloc<1 then wyloc:=1;
  end else
begin
        clearbottom;bottomsay(0,'SELECT TARGET');
        done2:=false;
repeat
 xorx:=wxloc*4-3+(32-(roomwide*2));
 xory:=wyloc*16-14+(88-(roomtall*8));
 targeticon(xorx,xory);
 j:=upcase(readkey);
 no_targeticon(xorx,xory);
{    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory);
 j:=upcase(readkey);
    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory); }
 case j of
  #0: case readkey of
  #59:help;
  'H':if wyloc>1 then if distance(xloc,yloc,wxloc,wyloc-1)<=maxrange+1 then
       dec(wyloc);
  'K':if wxloc>1 then if distance(xloc,yloc,wxloc-1,wyloc)<=maxrange+1 then
       dec(wxloc);
  'M':if wxloc<roomwide then if distance(xloc,yloc,wxloc+1,wyloc)<=maxrange+1
       then inc(wxloc);
  'P':if wyloc<roomtall then if distance(xloc,yloc,wxloc,wyloc+1)<=maxrange+1
       then inc(wyloc);
  end;
  #27:begin;ymod:=99;done2:=true;end;
  #13:done2:=true;
  end;
until done2;
clearbottom;
if ymod=99 then moved:=false;
 {set xmod and ymod for Cone-weapons}
if ymod<>99 then
begin
 xmod:=0;ymod:=0;
 if wxloc>xloc then xmod:=1 else if wxloc<>xloc then xmod:=-1;
 if wyloc>yloc then ymod:=1 else if wyloc<>yloc then ymod:=-1;
 if abs(wyloc-yloc)>abs(wxloc-xloc) then xmod:=0 else ymod:=0;
end;
end;
  if distance(xloc,yloc,wxloc,wyloc)>1 then dropping:=ack.rweapskill[0]
    else dropping:=ack.weapskill[0];
  if action_weap=23 then dropping:=100;
  {REVISIT: add oops}
     (*  if random(dropping)<OOPS then
        case random(4) of
         0:dec(wxloc);
         1:dec(wyloc);
         2:inc(wxloc);
         3:inc(wyloc);
         end;      *)
     if ymod<>99 then
      begin
         if (xloc<>wxloc) or (yloc<>wyloc) then attacking(xloc,yloc,wxloc,wyloc,weapon1n,weapon2n,dropping);

      if action_weap<>23 then
      begin
       if weapon1n<>0 then if obj^[weapon1n].t=8 then
       if obj^[weapon1n].d[6]=255 then
        begin
         if ack.mp[0]>=obj^[weapon1n].d[7] then
          dec(ack.mp[0],obj^[weapon1n].d[7]) else
           ack.mp[0]:=0;
        end else
       if obj^[weapon1n].d[6]=1 then
        begin
         if ack.PCASH>0 then dec(ack.PCASH,1);
        end else
       if (obj^[weapon1n].d[6]<>0) and (obj^[weapon1n].d[7]<>0) then
{ !         if (ack.PINV[obj^[weapon1n].d[6]])=0 then    }
           begin
            if (ack.PINV[obj^[weapon1n].d[6]]>0) and
			 ( obj^[weapon1n].d[7] > random(100) )then
             dec(ack.PINV[obj^[weapon1n].d[6]],1);
           end;
       if weapon2n<>0 then if obj^[weapon2n].t=8 then
       if obj^[weapon2n].d[6]=255 then
        begin
         if ack.mp[0]>=obj^[weapon2n].d[7] then
          dec(ack.mp[0],obj^[weapon2n].d[7]) else
           ack.mp[0]:=0;
        end else
       if obj^[weapon2n].d[6]=1 then
        begin
         if ack.PCASH>0 then dec(ack.PCASH,1);
        end else
       if (obj^[weapon2n].d[6]<>0) and (obj^[weapon2n].d[7]<>0) then
{ !         if (ack.PINV[obj^[weapon2n].d[6]])=0 then   }
           begin
            if (ack.PINV[obj^[weapon2n].d[6]]>0) and
			 ( obj^[weapon2n].d[7] > random(100) ) then
             dec(ack.PINV[obj^[weapon2n].d[6]],1);
           end;
      end; {23}

      end;
       end;
       action_weap:=0;
       readkey_time:=R150;
       if arcade then readkey_default:=#255 else
        readkey_default:=#1;
      end;
  #253:begin
        passtime(region.room.wallgrap[15]);
        erasebottom:=2;
        clearbottom;bottomsay(1,'SLOW PROGRESS...');
        bottomsay(2,'TRY DROPPING EXTRA ITEMS.');
        moved:=true;
       end;

  #255:begin
       { passtime(region.room.wallgrap[15]);
        rtryval:=rtrymove(xloc,yloc,xloc,yloc,room); }
        moved:=false;
		maponly(room,xloc,yloc);
        if erasebottom>=90 then begin
         readkey_time:=0;
         readkey_default:=#255;

        end;
         if erasebottom<=100 then
          begin;readkey_time:=R150;
          if arcade then readkey_default:=#255 else
           readkey_default:=#1;
          erasebottom:=2;clearbottom;end;
       end;
	   
  
	   
(*  'W':if erasebottom<100 then
        begin
         erasebottom:=109;
         readkey_time:=0;
         readkey_default:=#255;
         clearbottom;
         bottomsay(0,'RESTING...');
        end;
*)

  'L':begin
       moved:=false;
        clearbottom;bottomsay(0,'LOOK...');
        wxloc:=xloc;
        wyloc:=yloc;
        done2:=false;
repeat
 xorx:=(wxloc*4-3 +(32-(roomwide*2)));
 xory:=(wyloc*16-14 +(88-(roomtall*8)));
 targeticon(xorx,xory);
 j:=upcase(readkey);
 no_targeticon(xorx,xory);
 case j of
  #0: case readkey of
  'H':if wyloc>1 then dec(wyloc);
  'K':if wxloc>1 then dec(wxloc);
  'M':if wxloc<roomwide then inc(wxloc);
  'P':if wyloc<roomtall then inc(wyloc);
  end;
  #13,#32,#27:done2:=true;
  end;
until done2;
   if j<>#27 then
     begin
      clearbottom;
      vehcount:=map[2,2,wxloc,wyloc].o;
      if (vehcount=0) or (quasimap[wxloc,wyloc]=0) then
        bottomsay(0,'YOU SEE: NOTHING.')
      else if vehcount=255 then
       begin
        putgrapc:=map[2,2,wxloc,wyloc].d;
        s:=crc^[rcrc^[putgrapc].crcsource].n;
        if (rcrc^[putgrapc].anger>4) or
         (rcrc^[putgrapc].anger=ack.alignment) or
          (crc^[rcrc^[putgrapc].crcsource].t=ack.criminal) then
          s:=s+' Û1(HOSTILE)';
        bottomsay(1,'YOU SEE: '+s);
        with rcrc^[putgrapc] do
         begin
          dropping:=crc^[crcsource].hm;
          if hp>=dropping then s:='NOT WOUNDED' else
           if hp>=round(dropping*0.75) then s:='SLIGHTLY WOUNDED' else
           if hp>=round(dropping*0.50) then s:='WOUNDED' else
           if hp>=round(dropping*0.25) then s:='HEAVILY WOUNDED' else
            s:='CRITICAL';
		   if ack.cheat=123 then s:=strnum(hp)+' of '+strnum(dropping)+' HP';
          end;
		  		  
        bottomsay(2,'CONDITION: Û1'+s);
        {see creature}
       end
      else
      begin
      if vehcount=1 then
      begin
        s:=strnum(map[2,2,wxloc,wyloc].d*10);
        bottomsay(1,'YOU SEE: '+obj^[vehcount].n+' Û1['+s+']');
        {see currency}
       end
      else
       begin
        bottomsay(1,'YOU SEE: '+obj^[vehcount].n);
        {see item}
       end;
       if obj^[vehcount].d[14]<>0 then
         begin
          {waitkey;}
          shortmessage(obj^[vehcount].d[14]);
         end;
       if ((abs(wxloc-xloc)=1) and (abs(wyloc-yloc)=0))
         or ((abs(wxloc-xloc)=0) and (abs(wyloc-yloc)=1)) then
          dropping:=1 else dropping:=0; {space adjacent?}
       if obj^[vehcount].t<6 then
        if (obj^[vehcount].d[9]=6) or
         ((obj^[vehcount].d[9]=13) and (dropping=1)) then
         begin
          {if obj^[vehcount].d[14]=0 then begin;waitkey;clearbottom;end;}
          if obj^[vehcount].d[2]<>21 then
          begin
           dropping:=obj^[vehcount].d[3];
           if (obj^[vehcount].t=2) or (obj^[vehcount].t=4) then
            dropping:=map[2,2,wxloc,wyloc].d;

           do_action(obj^[vehcount].d[2],dropping,1,0,vehcount,
            map[2,2,wxloc,wyloc].d,room,wxloc,wyloc);
           end else

           begin
            {do-all}
             llp:=locnt^[roomloc(room,wxloc,wyloc)].p;
             while llp<>0 do
             begin
              if obj^[locnt^[llp].obj].t<6 then
               begin
                vehcount:=locnt^[llp].obj;
                dropping:=obj^[vehcount].d[3];
                if (obj^[vehcount].t=2) or (obj^[vehcount].t=4) then
                 dropping:=locnt^[llp].objcode;

                do_action(obj^[vehcount].d[2],dropping,1,0,
                 vehcount,0,room,wxloc,wyloc);
               end;
              llp:=locnt^[llp].p;
             end;

           end;
          moved:=true;getroom(room);
         end;
      end;
     end;

     erasebottom:=3;
      end; {look}
  #199:key_report:=NOT key_report;
  

  'D':
	 begin
       readkey_time:=R150;
       if arcade then readkey_default:=#255 else readkey_default:=#1;
       savepage;
       dropping:=selectinventory(111,' DROP ITEM');
       restorepage;
       if dropping=1 then
        begin
         clearbottom;

         if Ack.PCASH>2550 then dri:=2550 else dri:=trunc(Ack.PCASH/10)*10;		 
         bottomsay(1,'DROP HOW MUCH? (UP TO '+strnum(dri)+')');
         bottomsay(2,'Û1AMOUNT:');
         val(readlin(17,188,4,1),dri,dri1);
         if dri>2550 then dri:=2550;
		 if dri>(trunc(ack.pcash/10)*10) then dri:=(trunc(ack.pcash/10)*10);
         if (dri1<>0) or (dri=0) then dropping:=0;
		 dri:=trunc(dri/10)*10; 
         end;
    if dropping<>0 then
     begin
       xmod:=99; {allow discard}
	   if region.room.wallgrap[7]=1 then xmod:=98;
       getadjacentlocation(xmod,ymod,'DROP ITEM: '+obj^[dropping].n,true);
       if ymod=99 then dropping:=0;
     end;
    if xmod=99 then {discarding...}
     begin
      if obj^[dropping].t<>12 then dec(Ack.PINV[dropping],1)
       else dec(Ack.PCASH,dri);
      checkdropping(dropping);
      clearbottom;erasebottom:=3;bottomsay(2,'DESTROYED: '+obj^[dropping].n);
      dropping:=0;
     end;
    if dropping<>0 then
     begin
       xmod:=xmod+xloc;ymod:=ymod+yloc;
       if (xmod>roomwide) or (xmod<1) then xmod:=xloc;
       if (ymod>roomtall) or (ymod<1) then ymod:=yloc;
       if map[2,2,xmod,ymod].o<>255 then
        dri1:=obj^[map[2,2,xmod,ymod].o].t else dri1:=3;
		if ((dri1=1) or (dri1=2)) and (obj^[map[2,2,xmod,ymod].o].d[4]>127) then dropping:=0;
       if (dri1=3) or (dri1=4) or (dri1=5) or (dri1=10) then dropping:=0;
	   
	   if dropping=0 then
	    begin
		 bottomsay(2,'CAN''T DROP THINGS THERE!');
		 erasebottom:=3;
		 end
	    else 
		 begin
		  if region.room.wallgrap[7]=1 then
		   begin
		    bottomsay(2,'DESTROYED: '+obj^[dropping].n);
			if obj^[dropping].t<>12 then dec(Ack.PINV[dropping],1)
             else if Ack.PCASH-dri>=0 then dec(Ack.PCASH,dri) else
             begin;dri:=Ack.PCASH;Ack.PCASH:=0;end;
               checkdropping(dropping);
			 dropping:=0;
           end
		   else
		  bottomsay(2,'DROPPED: '+obj^[dropping].n);erasebottom:=3;
		  end;	   
	   
     end;
       if dropping<>0 then
   begin
    if obj^[dropping].t<>12 then dec(Ack.PINV[dropping],1)
     else if Ack.PCASH-dri>=0 then dec(Ack.PCASH,dri) else
      begin;dri:=Ack.PCASH;Ack.PCASH:=0;end;
       checkdropping(dropping);
    {drop item}
    addslot:=0;
    if locntsize>5000 then
     begin
      {search for empty slot}
      for addslotc:=1 to locntsize do
       if locnt^[addslotc].obj=0 then addslot:=addslotc;
     end;
     if addslot=0 then if locntsize<LOCNTMAX then
       begin;addslot:=locntsize+1;inc(locntsize);end;
     addslotc:=map[2,2,xmod,ymod].o;
     if (addslotc<>0) and (addslotc<>255) then
      if ((obj^[addslotc].t<3) or (obj^[addslotc].t=5)) and
       (obj^[addslotc].d[9]=2) and (obj^[addslotc].d[10]=dropping) then
        begin
		 writelog(dropping,'action trigger: item drop');
         dropping2:=obj^[addslotc].d[3];
         if (not odd(obj^[addslotc].t)) then
          dropping2:=map[2,2,xmod,ymod].d;

         do_action(obj^[addslotc].d[2],dropping2,0,0,addslotc,
          map[2,2,xmod,ymod].d,room,xmod,ymod);
         if obj^[map[2,2,xmod,ymod].o].d[8]=1 then
         begin
          llp:=roomloc(room,xmod,ymod);
          locnt^[llp].obj:=obj^[map[2,2,xmod,ymod].o].d[12];
          if locnt^[llp].obj=0 then
          begin
           rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=
            locnt^[llp].p;
           if llp=locntsize then dec(locntsize);
          end;
         end;
         addslot:=0;
        end;
     if addslot<>0 then
     begin
       {clearbottom;bottomsay(2,'DROPPED: '+obj^[dropping].n);erasebottom:=3;}
       locnt^[addslot].p:=
         rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1];
       rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=addslot;
       locnt^[addslot].obj:=dropping;
       if dropping=1 then locnt^[addslot].objcode:=dri DIV 10;
       moved:=true;
     end;
      end;
     end;
  
  
  'G':begin
      ack.invisible:=0;
       getadjacentlocation(xmod,ymod,'GET ITEM (SELECT DIRECTION)',true);
     if xmod<>99 then
      begin
       xmod:=xmod+xloc;ymod:=ymod+yloc;
       if (xmod>roomwide) or (xmod<1) then xmod:=xloc;
       if (ymod>roomtall) or (ymod<1) then ymod:=yloc;
       addslot:=0; {catagory of object}
       if map[2,2,xmod,ymod].o<>0 then
	   begin
         addslot:=obj^[map[2,2,xmod,ymod].o].t;
       if addslot<6 then
         {check for gathering trigger}
         if obj^[map[2,2,xmod,ymod].o].d[9]=14 then
          begin

           if obj^[map[2,2,xmod,ymod].o].d[10]<>0 then
           begin
            load_shortmsgfile(obj^[map[2,2,xmod,ymod].o].d[10]);
            clearbottom;
            for i:=1 to 37 do
             begin
              putletter(i*2+1,180,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
              putletter(i*2+1,188,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
             end;
             erasebottom:=3;
            end;


              llp:=roomloc(room,xmod,ymod);
              readkey_time:=0;readkey_default:=#255;
			  do_action(obj^[locnt^[llp].obj].d[2],
               obj^[locnt^[llp].obj].d[3],0,0,locnt^[llp].obj,
               locnt^[llp].objcode,room,xmod,ymod); {this was xloc,yloc - changed it to see if that fixes bug}

              if obj^[locnt^[llp].obj].d[8]=1 then
               begin
              if obj^[map[2,2,xmod,ymod].o].d[12]=0 then
               begin
                llp:=roomloc(room,xmod,ymod);
                locnt^[llp].obj:=0;
                rmcnt^[xmod+region.room.x1[room]-1,
                 ymod+region.room.y1[room]-1]:=locnt^[llp].p;
                if llp=locntsize then dec(locntsize);
                getroom(room);moved:=true;
                {eliminate}
               end else
               begin
                llp:=roomloc(room,xmod,ymod);
                locnt^[llp].obj:=obj^[map[2,2,xmod,ymod].o].d[12];
                getroom(room);moved:=true;
                {replace with...}
               end;
               end;

              
          end; {gathering}
       if addslot=12 then
        begin;addslotc:=map[2,2,xmod,ymod].d;
        if Ack.PCASH+addslotc>65536 then addslot:=0;end
         else begin;addslotc:=1;
         if Ack.PINV[map[2,2,xmod,ymod].o]+addslotc>255 then
          addslot:=0;end;
       if (addslot>5) then
        begin
         llp:=roomloc(room,xmod,ymod);
         locnt^[llp].obj:=0;
         rmcnt^[xmod+region.room.x1[room]-1,ymod+region.room.y1[room]-1]:=
           locnt^[llp].p;
         if llp=locntsize then dec(locntsize);
         if addslot=12 then inc(Ack.PCASH,addslotc*10)
          else inc(Ack.PINV[map[2,2,xmod,ymod].o],addslotc);
         clearbottom;
		 if map[2,2,xmod,ymod].o=1 then
            bottomsay(0,'GET: '+strnum(map[2,2,xmod,ymod].d*10)+' '+obj^[map[2,2,xmod,ymod].o].n)
		  else bottomsay(0,'GET: '+obj^[map[2,2,xmod,ymod].o].n);
         erasebottom:=3;

         {take item}
         moved:=true;
         dropping:=map[2,2,xmod,ymod].o;
         llp:=roomloc(room,xmod,ymod);
         if llp<>0 then
         while llp<>0 do
         begin
          if obj^[locnt^[llp].obj].t<6 then
           begin
            steal_llp:=llp;
            if obj^[locnt^[llp].obj].d[9]=12 then
              if (obj^[locnt^[llp].obj].d[10]=0) or
                 (obj^[locnt^[llp].obj].d[10]=dropping) then
             begin
              do_action(obj^[locnt^[llp].obj].d[2],
               obj^[locnt^[llp].obj].d[3],0,0,locnt^[llp].obj,
               locnt^[llp].objcode,room,xloc,yloc);
              if obj^[locnt^[llp].obj].d[8]=1 then
               begin
                {make this disappear.  Somehow?}
               end;
             end; {d[9]=12}
            llp:=0;
           end else llp:=locnt^[llp].p;
         end; {while}
         {checked trigger 12}


        end;
      end;
     end;
	 end;

'T':if talktome<>0 then
  begin
   {action-triggered talk}
   conversation(talktome,dropping);
   talktome:=0;
  end else 
  begin
   ack.invisible:=0;
   passtime(11);
   erasebottom:=3;
   xorx:=0;xory:=0;
   getadjacentlocation(xorx,xory,'TALK (SELECT DIRECTION)',false);
   xmod:=xloc;ymod:=yloc;
dropping:=0;
if xory<>99 then
repeat
   xmod:=xmod+xorx;ymod:=ymod+xory;
   vehcount:=map[2,2,xmod,ymod].o;
   if (vehcount=255) then
    begin
        begin

         dropping:=rcrc^[map[2,2,xmod,ymod].d].talk;
         if dropping<>0 then
          conversation(dropping,
            rcrc^[map[2,2,xmod,ymod].d].anger)
         else begin;bottomsay(0,'NO RESPONSE.');erasebottom:=3;end;

         dropping:=99;
        end;
    end else
     if vehcount<>0 then if (obj^[vehcount].t=3) or (obj^[vehcount].t=4)
       then dropping:=10;  {can't talk thru obstacles!}
inc(dropping);
until dropping>3;
  if dropping<50 then bottomsay(0,'NOBODY THERE!');
      end;


  'X':if Ack.PLvehicle<>0 then
   begin
    {dismount}
	ack.invisible:=0;
    addslot:=0;
    if locntsize>5000 then
     begin
      {search for empty slot}
      for addslotc:=1 to locntsize do
       if locnt^[addslotc].obj=0 then addslot:=addslotc;
     end;
     if addslot=0 then if locntsize<LOCNTMAX then
       begin;addslot:=locntsize+1;inc(locntsize);end;
     if addslot<>0 then
     begin





       erasebottom:=3;
       locnt^[addslot].p:=
         rmcnt^[xloc+region.room.x1[room]-1,yloc+region.room.y1[room]-1];
       rmcnt^[xloc+region.room.x1[room]-1,yloc+region.room.y1[room]-1]:=addslot;
       locnt^[addslot].obj:=Ack.PLvehicle;
       vehcount:=Ack.PLvehicle;
	   Ack.PLvehicle:=0;
	   
             if obj^[vehcount].d[12]<>0 then
              run_macro(obj^[vehcount].d[12]) else
            begin
             clearbottom;bottomsay(0,'DISMOUNTING VEHICLE.');

            end;	   
	   
       moved:=true;
     end;
       end;

   #201:begin
   
   
   if macrosuccess>0 then begin
    delay2(300);
    done:=true;
	if thisportal=0 then thisportal:=255;
    rgn:=region.port[thisportal].region;
    room:=region.port[thisportal].rx;
    ydummy:=region.port[thisportal].ry;
    x:=region.port[thisportal].x;
    y:=region.port[thisportal].y;
	end;
              readkey_time:=R150;
        if arcade then readkey_default:=#255 else
         readkey_default:=#1;


   end;

 'B':if ack.plvehicle=0 then
         if (obj^[map[2,2,xloc,yloc].o].t=10) then
        begin
          ack.invisible:=0;
       macrosuccess:=200;
       if obj^[map[2,2,xloc,yloc].o].d[5]<>0 then
        run_macro(obj^[map[2,2,xloc,yloc].o].d[5]);
       if macrosuccess>0 then

        begin
         llp:=roomloc(room,xloc,yloc);
         locnt^[llp].obj:=0;
         rmcnt^[xloc+region.room.x1[room]-1,yloc+region.room.y1[room]-1]:=
           locnt^[llp].p;
         if llp=locntsize then dec(locntsize);
         Ack.PLvehicle:=map[2,2,xloc,yloc].o;
         if macrosuccess=200 then
          begin
           clearbottom;bottomsay(0,'USE VEHICLE: '+obj^[Ack.PLvehicle].n);
          end;
         erasebottom:=3;
         {boarded vehicle}


         dropping:=ack.plvehicle;
         llp:=roomloc(room,xloc,yloc);
         if llp<>0 then
         while llp<>0 do
         begin
          if obj^[locnt^[llp].obj].t<6 then
           begin
            steal_llp:=llp;
            if obj^[locnt^[llp].obj].d[9]=12 then
              if (obj^[locnt^[llp].obj].d[10]=0) or
                 (obj^[locnt^[llp].obj].d[10]=dropping) then
             begin
              do_action(obj^[locnt^[llp].obj].d[2],
               obj^[locnt^[llp].obj].d[3],0,0,locnt^[llp].obj,
               locnt^[llp].objcode,room,xloc,yloc);
              if obj^[locnt^[llp].obj].d[8]=1 then
               begin
                {make this disappear, somehow}
               end;
             end; {d[9]=12}
            llp:=0;
           end else llp:=locnt^[llp].p;
         end; {while}
         {checked trigger 12}


         moved:=true;
        end;

       end;






  else if sharedcommand(j) then if macro_teleport=false then begin;{showroom(room,xloc,yloc);}moved:=true;
   {erset;}end;
 end;
{ if moved then putgrap(xorx,xory,obj^[map[2,2,xlocold,ylocold].o].d[1]); }

 dri1:=map[2,2,xloc,yloc].o;
 if dri1<>0 then if obj^[dri1].t<6 then if obj^[dri1].d[8]=3 then
  begin
    dp8:=0;
    trypassable(dp8,obj^[dri1].d[4],obj^[dri1].d[5]);
    if dp8<>0 then dri1:=obj^[dri1].d[12];
  end;

 if arrowmoved then writelog(0,'arrowmoved') else writelog(0,'no arrow');
 
 if obj^[dri1].t=5 then
  if map[2,2,xloc,yloc].d<>0 then
   if arrowmoved then
   begin
    thisportal:=map[2,2,xloc,yloc].d;
	writelog(thisportal,'Starting portal');
    macrosuccess:=1;
    readkey_time:=0;
    readkey_default:=#201;

   end;
  end; {done}
  arrowmoved:=false;
  until done;
  
 if rgn<>thisregion then
  begin
   writelog(thisregion,'Leaving for new region: '+strnum(rgn));
   if region.room.wallgrap[4]>0 then
    run_macro(region.room.wallgrap[4]); {old exit macro: wallgrap 4}
 
  end;
  
 resurrect:=false;
 if doublepass then actionparser(0,0,0,0,0,0,0,0);
 savemap;
end;


{.UNDEF DEBUG}

begin
end.