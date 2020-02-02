{$O+}

{$F+}
unit o_play2;

{This unit contains world-map functions.}

interface

uses xms,u_sound,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,dos,u_fonts,u_graps,o_play0,o_play0a,o_play1,u_delay2;

const
 NORTH=1;SOUTH=2;EAST=3;WEST=4;
var onlycell:boolean;
    dp8:byte;

procedure numscan(var arg:integer;amt:integer);
procedure getchunks(chunkx,chunky:byte);
procedure chunkmove(dir:byte);
function wtrymove(therex,therey,herex,herey:Byte):Byte;

procedure walkworldmap(var rgn,xchunk,ychunk,x,y:byte);


implementation



procedure trueterrain(var tmspot:byte;var tmdata:byte);
 var okay:boolean;
begin
 repeat
  okay:=true;
  if tmspot<>0 then
   if tmspot=255 then
    begin
     if rcrc^[tmdata].show=false then
      begin
       okay:=false;
       tmspot:=rcrc^[tmdata].obj;
       tmdata:=rcrc^[tmdata].objdata;
      end;
    end else
   if (obj^[tmspot].t>5) then
    begin
     tmspot:=veh[tmdata].obj;
     tmdata:=veh[tmdata].objcode;
     okay:=false;
    end;
 until okay;
 writelog(0,'Drilling for trueterrain: '+strnum(tmspot)+' '+strnum(tmdata));
end;

procedure settrueterrain(xin,yin,ntmspot,ntmdata:byte);
var okay:boolean;tmspot,tmdata,oldtmd:byte;
begin
 if obj^[map[xin DIV 16+1,yin DIV 16+1,xin MOD 16+1,yin MOD 16+1].o].t<6 then
  begin
   map[xin DIV 16+1,yin DIV 16+1,xin MOD 16+1,yin MOD 16+1].o:=ntmspot;
   map[xin DIV 16+1,yin DIV 16+1,xin MOD 16+1,yin MOD 16+1].d:=ntmdata;
  end else
 begin
  okay:=false;
  tmspot:=map[xin DIV 16+1,yin DIV 16+1,xin MOD 16+1,yin MOD 16+1].o;
  tmdata:=map[xin DIV 16+1,yin DIV 16+1,xin MOD 16+1,yin MOD 16+1].d;
  repeat
   if tmspot=255 then
    begin
     oldtmd:=tmdata;
     tmspot:=rcrc^[tmdata].objdata;
     tmdata:=rcrc^[tmdata].obj;
     if (tmspot<>0) and (tmspot<>255) then
      if obj^[tmspot].t<6 then
       begin
        rcrc^[oldtmd].obj:=ntmspot;
        rcrc^[oldtmd].objdata:=ntmdata;
        okay:=true;
       end;

    end else
   if obj^[tmspot].t<6 then
    okay:=true else
   begin
    tmspot:=rcrc^[tmdata].obj;
    tmdata:=veh[tmdata].objcode;
    if (tmspot<>0) and (tmspot<>255) then
     if obj^[tmspot].t<6 then
      begin
       veh[oldtmd].obj:=ntmspot;
       veh[oldtmd].objcode:=ntmdata;
       okay:=true;
      end;
   end;
   if tmspot=0 then okay:=true;
  until okay;
 end;
end;

procedure savewmap;
 var chf:file of chunkrec;
    c1,c2:byte;
    ch:chunkprec;
    vhf:file of vehrec;
begin
 ch:=chunk;
 assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
 {$I-} reset(chf); {$I+}
 if ioresult<>0 then exit;
 for c1:=1 to 3 do for c2:=1 to 3 do
  if ch[c1,c2]=chunk[2,2] then ch[c1,c2]:=0;
 ch[2,2]:=chunk[2,2];
 for c1:=1 to 3 do for c2:=1 to 3 do
  if ch[c1,c2]<>0 then begin
   seek(chf,ch[c1,c2]-1);
   write(chf,map[c1,c2]);
  end;
 close(chf);
 assign(vhf,ADVNAME+MAPBFILE+strnum(thisregion));
 {$I-} reset(vhf); {$I+}
 if ioresult<>0 then exit;
 write(vhf,veh);
 close(vhf);

end;


procedure loadwmap;
 var chf:file of chunkrec;
   c1,c2,cx,cy:byte;
begin
 assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
 {$I-} reset(chf); {$I+}
 if ioresult<>0 then exit;
 for c1:=1 to 3 do for c2:=1 to 3 do
  if chunk[c1,c2]<>0 then begin
   if chunk[c1,c2]<=filesize(chf) then
   begin
    seek(chf,chunk[c1,c2]-1);
    read(chf,map[c1,c2]);
   end;
  end else
    for cx:=1 to 16 do for cy:=1 to 16 do
     begin
      map[c1,c2,cx,cy].o:=region.room.wallgrap[1];
      map[c1,c2,cx,cy].d:=region.room.wallgrap[2];
     end;
 close(chf);
end;



procedure numscan(var arg:integer;amt:integer);
begin
 arg:=arg+amt;
 if arg>32 then arg:=1;if arg<1 then arg:=32;
end;


procedure getchunks(chunkx,chunky:byte);
 var c1,c2,cc1,cc2,scanarg:integer;
 newchs:array[1..3,1..3] of byte;
 oldchs:array[1..9] of byte;
 creatureslot,creatureslott,laycreature:byte;

begin
 {$IFDEF PRINTF}
  for c1:=1 to 3 do say(55,c1*20,0,strnum(chunk[1,c1])+
     ' '+strnum(chunk[2,c1])+' '+strnum(chunk[3,c1]));
  say(2,170,6,'PRESS A KEY');
  repeat until readkey=#13;
 {$ENDIF}
 for c1:=1 to 3 do for c2:=1 to 3 do
  begin
   oldchs[(c1-1)*3+c2]:=chunk[c1,c2];
   chunk[c1,c2]:=0;
  end;
 for c1:=chunkx-1 to chunkx+1 do
  for c2:=chunky-1 to chunky+1 do
   begin
    cc1:=chunkx;cc2:=chunky;
    scanarg:=(c1-chunkx+2)*10+(c2-chunky+2);
    if region.room.wallgrap[1]=0 then
    case scanarg of
     21:repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
     12:repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
     23:repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
     32:repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
     11:begin
         repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
        end;
     31:begin
         repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
        end;
     13:begin
         repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
        end;
     33:begin
         repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
        end;
     end else
      begin
       cc1:=c1;cc2:=c2;
      end;
      if (cc1>=1) and (cc1<=32) and (cc2>=1) and (cc2<=32) then
      chunk[c1-chunkx+2,c2-chunky+2]:=region.room.wmap[cc1,cc2]
       else chunk[c1-chunkx+2,c2-chunky+2]:=0;
 end;
 loadwmap;

{if wander_index^[1].x<>0 then}
begin {wander}

 for c1:=1 to 3 do for c2:=1 to 3 do
  begin
   newchs[c1,c2]:=chunk[c1,c2];
   if not newwmapload then
    for cc1:=1 to 9 do if newchs[c1,c2]=oldchs[cc1] then
     newchs[c1,c2]:=0;

  end;
 newwmapload:=false;

 for c1:=1 to 3 do for c2:=1 to 3 do if newchs[c1,c2]<>0 then
  for i:=1 to WANDERMAX do if wander_index^[i].x=newchs[c1,c2] then
   if map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].d<>255 then
    if random(100)<wander_index^[i].odds then
    begin
   {add a creature to chunk[c1,c2]}

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
    if map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].o<>255 then
        with rcrc^[creatureslott] do
        begin {*****}
         rcrc^[creatureslott].xchunk:=xchunkloc;
         rcrc^[creatureslott].ychunk:=ychunkloc;
         used:=true;show:=true;
         obj:=map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].o;
         objdata:=map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].d;
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
         map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].d:=creatureslott;
         map[c1,c2,wander_index^[i].xin,wander_index^[i].yin].o:=255;
        end; {*****}
   end; {***}

  end; {add a creature...}

end; {wander}

end;




procedure chunkmove(dir:byte);
 var wrap:boolean;
begin
 if region.room.wallgrap[1]=0 then wrap:=true else wrap:=false;
 if onlycell then exit;
 case dir of
  NORTH:
        if wrap then begin
         repeat
          numscan(ychunkloc,-1);
         until region.room.wmap[xchunkloc,ychunkloc]<>0;
         yinloc:=16;
        end else begin
         dec(ychunkloc);
         yinloc:=16;
        end;
  SOUTH:
        if wrap then begin
         repeat
          numscan(ychunkloc,1);
         until region.room.wmap[xchunkloc,ychunkloc]<>0;
        yinloc:=1;
        end else begin
         yinloc:=1;
         inc(ychunkloc);
        end;
  EAST:
       if wrap then begin
        repeat
         numscan(xchunkloc,1);
        until region.room.wmap[xchunkloc,ychunkloc]<>0;
        xinloc:=1;
       end else begin
        xinloc:=1;
        inc(xchunkloc);
       end;
  WEST:
       if wrap then begin
        repeat
         numscan(xchunkloc,-1);
        until region.room.wmap[xchunkloc,ychunkloc]<>0;
        xinloc:=16;
        end else begin
         xinloc:=16;
         dec(xchunkloc);
       end;
 end; {case}
 savewmap;
{ if CHUNKSAVE then saveconfig; }
 CHUNKSAVE:=false;
 getchunks(xchunkloc,ychunkloc);
end;



function wtrymove(therex,therey,herex,herey:Byte):Byte;
var
 therecx,therecy:byte;
 tmresult:byte;
 tmdata,tmspot:byte;
 tmst:byte;
 okay:boolean;
begin
 therecx:=2;therecy:=2;
 if therex=0 then begin;therex:=16;therecx:=1;end;
 if therex=17 then begin;therex:=1;therecx:=3;end;
 if therey=0 then begin;therey:=16;therecy:=1;end;
 if therey=17 then begin;therey:=1;therecy:=3;end;
 tmresult:=0; {assume okay}
 if encumberance>3 then tmresult:=99;

 if not ack.fly then
 begin {fly}
 tmspot:=map[therecx,therecy,therex,therey].o;       {}{}{}
 writelog(0,'wtrymove: from '+strnum(herex)+','+strnum(herey)+' to '+strnum(therex)+','+strnum(therey)+' obj='+strnum(tmspot));
 if tmspot=255 then tmresult:=99 else
 begin

 if tmspot<>0 then if obj^[tmspot].t<6 then if obj^[tmspot].d[8]=3 then
   begin

    trypassable(tmresult,obj^[tmspot].d[4],obj^[tmspot].d[5]);
    if tmresult<>0 then tmspot:=obj^[tmspot].d[12];
    tmresult:=0;
   end;
 tmdata:=map[2,2,therex,therey].d;

 repeat
  okay:=true;
  if tmspot<>0 then
   if tmspot=255 then
    begin
     if rcrc^[tmdata].show=false then
      begin
       okay:=false;
       tmspot:=rcrc^[tmdata].obj;
       tmdata:=rcrc^[tmdata].objdata;
      end;
    end else
   if (obj^[tmspot].t>5) and (obj^[tmspot].t<>10) then
    begin
     if ((therecx+therex-2)<>veh[tmdata].xchunk) or
        ((therecy+therey-2)<>veh[tmdata].ychunk) then
      begin
       tmspot:=veh[tmdata].obj;
       tmdata:=veh[tmdata].objcode;
       okay:=false;
      end;
    end;
 until okay;
 if tmspot<>0 then
 begin
  tmst:=obj^[tmspot].t;
  if (tmst=3) or (tmst=4) then tmresult:=99;  {1 means attempted obstacle}
  if tmresult<99 then
   if tmst<6 then trypassable(tmresult,obj^[tmspot].d[4],obj^[tmspot].d[5]);
  block_message:=obj^[tmspot].d[7];
  if tmst=5 then pass_message:=obj^[tmspot].d[13] else pass_message:=0;
   if pass_message<>0 then if tmresult<99 then shortmessage(pass_message);

  actionparser(tmresult,tmspot,tmdata,0,
   therex+16*(therecx-1)-1,therey+16*(therecy-1)-1,herex+15,herey+15);

 end else
  begin
   tmresult:=0;if ack.stepsound<>0 then
    if (therex<>herex) or (therey<>herey) then
     soundeffect(ack.stepsound,1);
  end;
  end; {creature check}
  end; {fly}

 wtrymove:=tmresult;
end;








procedure walkworldmap(var rgn,xchunk,ychunk,x,y:byte);
 const XCONST=8;
       YCONST=2;
 var j2,j:char;
     done2,done:boolean;
     putgrapc:byte;
     xorx,xory,xmod,ymod:integer;
     visimap,quasimap:array[0..10,0..8] of byte;
     xloc,yloc,xsc,ysc:byte;
     moved,arrowmoved,vehhere:boolean;
     vehcount:byte;
     old_xch,old_ych,old_yin,old_xin:byte;
     bytebuf:byte;
     old_region:byte;
     old_onlycell:boolean;
     dropping,dropping2,dri,dri1:integer; no_drop:boolean;
     s:string;
     weapon1n,weapon1t,weapon2n,weapon2t,maxrange,wxloc,wyloc,weaponskill:byte;
     registerattacks:array[1..16,1..8] of byte;
     regattacknum:byte;
     whoops:byte;
     attacker_alignment,attacker_id:byte;
     hitcrc_bugfix:array[1..16,1..4] of byte;
     hitcrc_bugfix_counter:byte;
(*
     what_o,what_d:byte;

procedure whatshere(xch,ych,x,y:byte);
 var
     o,d:byte;
     okay:boolean;
begin
 o:=map[xch,ych,x,y].o;
 d:=map[xch,ych,x,y].d;
 repeat
  okay:=true;
  if o<>0 then
   if o=255 then
    begin
     if rcrc^[d].show=false then
      begin
       okay:=false;
       o:=rcrc^[d].obj;
       d:=rcrc^[d].objdata;
      end;
    end else
   if obj^[o].t>5 then
    begin
     if ((xch+xchunkloc-2)<>veh[d].xchunk) or
        ((ych+ychunkloc-2)<>veh[d].ychunk) then
      begin
       o:=veh[d].obj;
       d:=veh[d].objcode;
       okay:=false;
      end;
    end;
 until okay;
 what_o:=o;what_d:=d;
end;
*)

procedure showwalk;
 var layc:byte;
begin
 if starting_up_clearscreen then clearscreen else
  starting_up_clearscreen:=true;
 erset(true);
 {
 boxx(1+XCONST,1+YCONST,48+XCONST,39+YCONST);
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,200,319,3);
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3);
 }
{ say(3,2,0,region.name); }
end;

procedure roomprojectile(xloc,yloc:byte;var xsc,ysc:byte);
 var rise,run,xstep,ystep,herex,herey:integer;
     done:boolean;
     shootingover:byte;
	 count:integer;
begin
 rise:=ysc-(yloc); run:=xsc-(xloc);
 xstep:=abs(run); ystep:=abs(rise);
 if xstep=0 then xstep:=1;if ystep=0 then ystep:=1;
 if xstep>ystep then ystep:=xstep else xstep:=ystep;
 herex:=xloc*xstep; herey:=yloc*ystep;
 done:=false;
 count:=0;

 repeat
  if (round(herex/xstep)=xsc) AND (round(herey/ystep)=ysc) then
    done:=true {we've arrived}
   else
    begin
	 {look at what the projectile is passing over}
     shootingover:=map[round(herex/xstep) DIV 16+1,round(herey/ystep) DIV 16+1,
       round(herex/xstep) MOD 16+1,round(herey/ystep) MOD 16+1].o;
	 if ( herex<>xloc*xstep ) OR ( herey<>yloc*ystep ) {make sure we've actually left home}
	  then
	 begin
	  {check what we are shooting over}
	  if shootingover<>255 then
      if (shootingover<>0) then
	   begin
       {it is an object...}
        case obj^[shootingover].t of
	     1,2,5:if obj^[shootingover].d[4]>127 then done:=true;
	   	 3,4:done:=true;
	    end; {case}
	   end; {object}
	   if done then begin;xsc:=round(herex/xstep);ysc:=round(herey/ystep);end;
	  end; {check}
	
    end; {look}
   inc(herex,run);inc(herey,rise);
   inc(count);if count>300 then done:=true;
  until done;
end;


procedure shootterrain(weapon0t,weapon0n:byte);
 var bigthing:byte;
     stc2,stc:byte;
begin
       bigthing:=map[wxloc DIV 16+1,wyloc DIV 16+1,
         wxloc MOD 16+1,wyloc MOD 16+1].o;
       if bigthing<>0 then
        if (obj^[bigthing].t<6) and (obj^[bigthing].d[9]=11) then
         if (obj^[bigthing].d[10]=0) or (obj^[bigthing].d[10]=weapon0n) then
         do_action(obj^[bigthing].d[2],obj^[bigthing].d[3],0,0,bigthing,
          map[wxloc DIV 16+1,wyloc DIV 16+1,
           wxloc MOD 16+1,wyloc MOD 16+1].d,0,wxloc,wyloc);
       if bigthing<>0 then
        if (obj^[weapon0n].d[4]>=obj^[bigthing].d[11])
        AND (obj^[bigthing].t<6) AND
            (obj^[bigthing].d[11]<>0) then
			begin
			 {process terrain destruction}
			 if obj^[bigthing].d[8]>5 then begin
			   writelog(obj^[bigthing].d[8]-5,'Running terrain death macro');			
			  run_macro(obj^[bigthing].d[8]-5);
			  end;
              if obj^[bigthing].d[12]=0 then
               begin
                map[wxloc DIV 16+1,wyloc DIV 16+1,
                 wxloc MOD 16+1,wyloc MOD 16+1].o:=0;
                moved:=true;CHUNKSAVE:=true;
                {eliminate}
               end else
               begin
                map[wxloc DIV 16+1,wyloc DIV 16+1,
                 wxloc MOD 16+1,wyloc MOD 16+1].o:=obj^[bigthing].d[12];
                if obj^[bigthing].d[12]<>0 then
                 if obj^[obj^[bigthing].d[12]].t>5 then
                  begin
                   stc2:=0;
                   for stc:=255 downto 1 do
                    if veh[stc].used=false then stc2:=stc;
                   if stc2=0 then
                    map[wxloc DIV 16+1,wyloc DIV 16+1,
                     wxloc MOD 16+1,wyloc MOD 16+1].o:=0 else
                    begin
                     map[wxloc DIV 16+1,wyloc DIV 16+1,
                      wxloc MOD 16+1,wyloc MOD 16+1].d:=stc2;
                     veh[stc2].used:=true;
                     veh[stc2].obj:=0;
                     veh[stc2].objcode:=0;
                     veh[stc2].howmany:=1;
                    end;
                  end;
                moved:=true;CHUNKSAVE:=true;
                {replace with...}
               end;
			end; {terrain destruction}
end;


function hitcreature(weapon0t,weapon0n,skill:byte):boolean;
 var who:byte;
     i:integer;
     damage:integer;
     dropcount:integer;
     hitpoints:integer;


begin

 if ((ack.fly=true) and (weapon0t=7)) then exit;
 damage:=0;

{process weapon damage}
 if weapon0n<>0 then hitpoints:=obj^[weapon0n].d[4] {base damage}
     else hitpoints:=0;

 i:=skill;                       {skill from 1-100 is chance of hitting for that damage}
 if i>random(100) then damage:=random(hitpoints)+1;

                                 {skill from 101-200 is chance of hitting for double damage}
 if skill>100 then i:=skill-100 else i:=0;
 if i>random(100) then damage:=damage*2;

                                 {skill from 201+ is chance of hitting for quadruple damage}
 if skill>200 then i:=skill-200 else i:=0;
 if i>random(100) then damage:=damage*2;





 hitcreature:=false;
 if map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].o=255 then
 begin   {target is a creature}
  hitcreature:=true;
  chunksave:=true;
  who:=map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].d;
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

    {if damage has become zero, this is a miss; play the sound}

	if rcrc^[who].hp>crc^[rcrc^[who].crcsource].hm then rcrc^[who].hp:=crc^[rcrc^[who].crcsource].hm;
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
      soundeffect(ack.misssound,1);delay2(combatpacing*5);
     end;
    end else
    begin {messages indicating hot NPC on NPC action}

    if damage>0 then
     begin
      soundeffect(ack.hitsound,1);

      scrollsay(crc^[attacker_id].n+' HITS '+crc^[rcrc^[who].crcsource].n+' FOR '+strnum(damage)+' DMG');
      delay2(combatpacing*4);
      if hitpoints<=0 then
        begin
         scrollsay(crc^[rcrc^[who].crcsource].n+' HAS BEEN KILLED!');
         soundeffect(lo(crcsounds[rcrc^[who].crcsource]),1);   {play death sound}
         delay2(combatpacing*4);
        end;
     end;

    end;

    if hitpoints<=0 then
     begin
      if ack.ackversion>24 then   {grant experience}
       with crc^[rcrc^[who].crcsource] do ack.experience:=ack.experience+ ((exphi-1)*256 + exp);

      rcrc^[who].show:=false;  {stop showing this creature}

      {remove creature from map}
      map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].o:=rcrc^[who].obj;
      map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].d:=rcrc^[who].objdata;

      {drop remains, if any}
      for i:=3 downto 1 do if crc^[rcrc^[who].crcsource].inv[i]<>0 then
       with crc^[rcrc^[who].crcsource] do
        if (obj^[inv[i]].t<6) or (inv[i]=1) or ((random(100)<invn[i]) or (ack.ackversion<31)) then	
        begin
         if obj^[inv[i]].t<6 then
          begin
          {drop terrain}
          map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].o:=inv[i];
          map[wxloc DIV 16+1,wyloc DIV 16+1,wxloc MOD 16+1,wyloc MOD 16+1].d:=invn[i];
          end else if inv[i]=1 then flopitem(wxloc,wyloc,inv[i],invn[i])
		   else flopitem(wxloc,wyloc,inv[i],1);
        end; {drop remains}

      if ((wxloc-xinloc-10>=0) and (wxloc-xinloc-10<=10) and
       (wyloc-yinloc-11>=0) and (wyloc-yinloc-11<=8)) then
         begin {if the creature is visible, although I'm not sure how it wouldn't be}
           {make sure this spot isn't animated anymore}
           visimap[wxloc-xinloc-10,wyloc-yinloc-11]:=
                obj^[map[wxloc DIV 16+1,wyloc DIV 16+1,
                wxloc MOD 16+1,wyloc MOD 16+1].o].d[1];
           anim_screen[wxloc-xinloc-9,wyloc-yinloc-10].tb:=false;
           anim_screen[wxloc-xinloc-9,wyloc-yinloc-10].tb4:=false;
         end;
      if crc^[rcrc^[who].crcsource].deathm<>0 then   {run death macro}
        if ack.ackversion>11 then run_macro(crc^[rcrc^[who].crcsource].deathm);
   end {creature death}
    else rcrc^[who].hp:=hitpoints; {creature isn't dead -- set hit points}
 end  {end of creature hit processing}
 else
  if (wxloc=xinloc+15) and (wyloc=yinloc+15) then
  begin  {target is the player}

    {process armor damage absorb}
    for i:=1 to 7 do  {for each slot}
     if ack.parmor[i]<>0 then    {if wearing armor}
      if ack.countarmor[i]=0 then      {and its not disabled}
       if
	   ( obj^[ack.parmor[i]].d[6] > random(100) ) then  {and random coverage}
        damage:=damage-obj^[ack.parmor[i]].d[5];    {then absorb damage}

    if damage<0 then damage:=0;
    hitpoints:=ack.hp[0]-damage; {inflict damage}

    {sound effect}
    if damage>0 then
     begin
      soundeffect(ack.hitsound,1);

      scrollsay(crc^[attacker_id].n+' HITS YOU FOR '+strnum(damage)+' DAMAGE!');
      delay2(combatpacing*5);
      if crc^[rcrc^[who].crcsource].touchm<>0 then
       if weapon0t=7 then
	   if ack.ackversion>=30 then run_macro(crc^[rcrc^[who].crcsource].touchm);
	
      if hitpoints<=0 then scrollsay('YOU HAVE BEEN KILLED!');

     end else
     begin
      scrollsay(crc^[attacker_id].n+' ATTACKS YOU AND MISSES!');
      soundeffect(ack.misssound,1);delay2(combatpacing*3);
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
{      if (distance(xloc,yloc,wxloc,wyloc)>1) then }


       for wxlocc:=wxloc2+10 to wxloc2+30 do
        for wylocc:=wyloc2+10 to wyloc2+30 do
       begin
        wxloc:=wxlocc-20;wyloc:=wylocc-20;
         if distance(wxloc2,wyloc2,wxloc,wyloc)<=obj^[weapon0n].d[5] DIV 16
       then begin

        showweapon(weapon0t,weapon0n,xloc-9-xinloc,yloc-10-yinloc,wxloc-9-xinloc,wyloc-10-yinloc,11,9);
                            {assume a blast radius every time,
                             using BR 0 for pinpoint shots}
        if not hitcreature(weapon0t,weapon0n,skill)
         then shootterrain(weapon0t,weapon0n);

      {process ranged weapon 1}
      end;
      end; { else if attacker_alignment=5 then adjacent_error; }
            {attacking adjacent squares is now OK}

     end else
     if (xmod<>0) or (ymod<>0) then begin
      wxloc:=xloc;wyloc:=yloc;
      wxloc2:=wxloc;wyloc2:=wyloc;
      wxlocc_begin:=20;
      wxlocc_end:=20;
      wylocc_begin:=20;
      wylocc_end:=20;
      for conecounter:=0 to obj^[weapon0n].d[5] MOD 16 do
       begin
        wxloc2:=xloc+(xmod*(conecounter+1));
        wyloc2:=yloc+(ymod*(conecounter+1));
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
         if distance(xloc,yloc,wxloc,wyloc)-1<=obj^[weapon0n].d[5] MOD 16 then
         begin
          roomprojectile(xloc,yloc,wxloc,wyloc);

          showweapon(weapon0t,weapon0n,xloc-9-xinloc,yloc-10-yinloc,wxloc-9-xinloc,wyloc-10-yinloc,11,9);
          inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);
          if not hitcreature(weapon0t,weapon0n,skill)
           then shootterrain(weapon0t,weapon0n);
          inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);
         end;
        end;
       end;
     wxloc:=old_wxloc;wyloc:=old_wyloc;
     end;
     delay2(combatpacing);
end;

procedure attacking(jxloc,jyloc,jwxloc,jwyloc,jweapon1n,jweapon2n,skill:byte);
begin

  xloc:=jxloc;yloc:=jyloc;wxloc:=jwxloc;wyloc:=jwyloc;
   weapon1n:=jweapon1n;weapon2n:=jweapon2n;
  if weapon1n=0 then weapon1t:=0
   else weapon1t:=obj^[weapon1n].t;
  if weapon2n=0 then weapon2t:=0
   else weapon2t:=obj^[weapon2n].t;
  if (weapon1n=0) and (weapon2n=0) then exit;
  sounded:=false;
  roomprojectile(jxloc,jyloc,wxloc,wyloc);
{  savepage; }
    {process ranged weapons}
   resolve_rangedweapon(weapon1t,weapon1n,skill);
   sounded:=false;
   xloc:=jxloc;yloc:=jyloc;wxloc:=jwxloc;wyloc:=jwyloc;
   weapon2n:=jweapon2n;
   if weapon2n=0 then weapon2t:=0
    else weapon2t:=obj^[weapon2n].t;
{   restorepage;   }
   roomprojectile(jxloc,jyloc,wxloc,wyloc);
   resolve_rangedweapon(weapon2t,weapon2n,skill);
   if ((wxloc<>xloc) or (wyloc<>yloc)) then begin
    if weapon1t=7 then
     begin
     xloc:=jxloc;yloc:=jyloc;wxloc:=jwxloc;wyloc:=jwyloc;
      weapon1n:=jweapon1n;
     if weapon1n=0 then weapon1t:=0
      else weapon1t:=obj^[weapon1n].t;

      showweapon(weapon1t,weapon1n,xloc-9-xinloc,yloc-10-yinloc,wxloc-9-xinloc,wyloc-10-yinloc,11,9);
      inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);delay2(100);
      if not hitcreature(weapon1t,weapon1n,skill)
       then shootterrain(weapon1t,weapon1n);
      inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);

      {process melee weapon 1}
{      restorepage; }
     end;
    if weapon2t=7 then
     begin
     xloc:=jxloc;yloc:=jyloc;wxloc:=jwxloc;wyloc:=jwyloc;
     weapon2n:=jweapon2n;
     if weapon2n=0 then weapon2t:=0
      else weapon2t:=obj^[weapon2n].t;

      showweapon(weapon2t,weapon2n,xloc-9-xinloc,yloc-10-yinloc,wxloc-9-xinloc,wyloc-10-yinloc,11,9);
      inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);
      if not hitcreature(weapon2t,weapon2n,skill)
       then shootterrain(weapon2t,weapon2n);
      inverttarget(wxloc-9-xinloc,wyloc-10-yinloc,11,9);
       {process melee weapon 2}
     end;
   end;
{   restorepage; }
end;




procedure showview;
 var putgrapc,xsc,ysc:integer;
     shadowing:byte;
     rise,run,herex,herey,xystep:integer;
     xstep,ystep:shortint;
     done,opaque:boolean;
     limit_found,two_found:boolean;
     two_x,two_y:byte;
     attacktaken:boolean;
     creatureslot:byte;
     shadowscan:Array[1..11,1..9] of byte;


var motionx,motiony,attacklocx,attacklocy:byte; {what it would like to do}
    found,fight:boolean;

  var movedindex:byte;
    foundrange:integer;
    longisbest:boolean;


function checkdest(xscc,yscc,who:integer):boolean;
var
    mapobj,mapobjdata,creaturevehicle:byte;
    passable:boolean;
    therecx,therex,therecy,therey:byte;

{$I I_CHKDST.PAS} {the same code is used by wmap and room regions}
	
 begin

  therecx:=((xinloc+xscc+10) DIV 16)+1;
  therecy:=((yinloc+yscc+11) DIV 16)+1;
  therex:=((xinloc+xscc+10) MOD 16)+1;
  therey:=((yinloc+yscc+11) MOD 16)+1;
  mapobj:=map[therecx,therecy,therex,therey].o;  {figure out the map data}
  mapobjdata:=map[therecx,therecy,therex,therey].d;
  trueterrain(mapobj,mapobjdata); {now figure out what's really there}	
  creaturevehicle:=crc^[rcrc^[who].crcsource].veh;

  {perform the actual check... }
  passable:=checkdest2(mapobj,creaturevehicle);


  {one final check: make sure they're not trying to step on the player!}
  if (xscc=5) and (yscc=4) then passable:=false;

  {return the result}
  checkdest:=passable;


 end;	
	
procedure movecreature(xsc,ysc,xscc,yscc:integer);
 var cnum:byte;
begin
 cnum:=map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
  ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].d;
 {writelog(cnum,'Moving '+strnum(cnum)+': '+strnum(movedindex)+','+strnum(creaturemoved[cnum]));}
 if movedindex=creaturemoved[cnum] then exit;

 CHUNKSAVE:=true;
 creaturemoved[cnum]:=movedindex;               {prevents double moves}

 {restore footpad}
 map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
  ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].o:=
    rcrc^[cnum].obj;
 map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
  ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].d:=
    rcrc^[cnum].objdata;

 {create new footpad data}
 rcrc^[cnum].obj:=
  map[((xinloc+xscc+10) DIV 16)+1,((yinloc+yscc+11) DIV 16)+1,
   ((xinloc+xscc+10) MOD 16)+1,((yinloc+yscc+11) MOD 16)+1].o;
 rcrc^[cnum].objdata:=
  map[((xinloc+xscc+10) DIV 16)+1,((yinloc+yscc+11) DIV 16)+1,
   ((xinloc+xscc+10) MOD 16)+1,((yinloc+yscc+11) MOD 16)+1].d;

 {write creature on footpad}
 map[((xinloc+xscc+10) DIV 16)+1,((yinloc+yscc+11) DIV 16)+1,
  ((xinloc+xscc+10) MOD 16)+1,((yinloc+yscc+11) MOD 16)+1].o:=255;
 map[((xinloc+xscc+10) DIV 16)+1,((yinloc+yscc+11) DIV 16)+1,
  ((xinloc+xscc+10) MOD 16)+1,((yinloc+yscc+11) MOD 16)+1].d:=cnum;

end;


procedure scanalign(anger,crcalign:byte;var x,y:byte;this_crcsource:byte);
 var xloop,yloop:byte;
     myx,myy:byte;
begin

 { you are xinloc+15, yinloc+15 }
 myx:=xinloc+xsc+10;
 myy:=yinloc+ysc+11;
 found:=false;
 foundrange:=32760;
 if anger=0 then exit;
 if (anger>4) or (anger=ack.alignment) or (ack.criminal=crcalign) then
  if (ack.hp[0]>0) and (ack.invisible=0) and (resurrect=false) then begin
  { if random(6)<4 then
    soundeffect(hi(crcsounds[rcrc^[this_crcsource].crcsource]));}
   found:=true;
   x:=xinloc+15;
   y:=yinloc+15;
   foundrange:=round(1000*sqrt(sqr(x-myx)+sqr(y-myy)));
  end;
{$IFDEF DEBUG}
 write(printer,'Scanning.  MyLoc=',myx,',',myy,'.  YourLoc=',x,',',y,
         '  Anger=',anger,'.  ');
{$ENDIF}

 for xloop:=myx-5 to myx+5 do
  for yloop:=myy-4 to myy+4 do
  if (map[(xloop DIV 16)+1,(yloop DIV 16)+1,
       (xloop MOD 16)+1,(yloop MOD 16)+1].o=255) then
    if (round(1000*sqrt(sqr(xloop-myx)+sqr(yloop-myy)))<foundrange)
     and (((myx=xloop) and (myy=yloop))=false) then
      begin
      if (crc^[rcrc^[map[(xloop DIV 16)+1,(yloop DIV 16)+1,
            (xloop MOD 16)+1,(yloop MOD 16)+1].d].crcsource].t=anger)
       or (anger=6) and
       (rcrc^[map[(xloop DIV 16)+1,(yloop DIV 16)+1,
            (xloop MOD 16)+1,(yloop MOD 16)+1].d].crcsource<>this_crcsource)
       then
         begin
           found:=true;
           if random(6)<2 then
            soundeffect(hi(crcsounds[rcrc^[this_crcsource].crcsource]),1);
           x:=xloop;
           y:=yloop;
           foundrange:=round(1000*sqrt(sqr(xloop-myx)+sqr(yloop-myy)));
         end;
      {check creature}
     end;

(*
     else if (xloop=xinloc+15) and (yloop=yinloc+15) then
     begin
      if (ack.alignment=anger) or (anger>4) then
        begin
          found:=true;
          x:=xloop;
          y:=yloop;
          foundrange:=round(1000*sqrt(sqr(xloop-myx)+sqr(yloop-myy)));
        end;
      {check player}
     end;
  *)
end;


var xmotion,ymotion:integer;
    mee:byte;
    nowviewdistance:byte;
    xlit,ylit:byte;
	tto,ttd:byte;

	
begin
 if resurrect then exit;
 aggro:=0;
 shadowing:=region.shadow;

 movedindex:=random(256);
 regattacknum:=1;

  for xsc:=0 to 10 do for ysc:=0 to 8 do anim_screen[xsc+1,ysc+1].aggro:=false;

 for xsc:=0 to 10 do for ysc:=0 to 8 do
   if map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
     ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].o=255

{************}

    then with rcrc^[map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].d] do
    begin
     mee:=map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].d;
     scanalign(anger,crc^[crcsource].t,attacklocx,attacklocy,crcsource);

     if found then
      with crc^[crcsource] do begin
       attacker_alignment:=t;
       inc(aggro); anim_screen[xsc+1,ysc+1].aggro:=true;
       {enemy found. determine action}
       fight:=false;
       if (motive=2) or (motive=130) {oops, old bug fix}
         then fight:=true {stop: can't move. try firing}
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
          if foundrange>5000 then fight:=false;
		  if fr+fw=0 then fight:=false;
          {consider motion. if not moving, set fight:=true.}


         end;
       if creaturemoved[map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].d]=movedindex
           then fight:=false;
		
       if not fight then begin
		 writelog(199,'creature is moving');	
         xmotion:=0;ymotion:=0;
         if xsc>5 then xmotion:=-1;
         if xsc<5 then xmotion:=1;
         if ysc>4 then ymotion:=-1;
         if ysc<4 then ymotion:=1;
         if (longisbest) and (foundrange<3000) then
            begin;xmotion:=-xmotion;ymotion:=-ymotion;end;
         if (ymotion<>0) and (xmotion<>0) then
          if random(2)=1 then ymotion:=0 else xmotion:=0;
         if checkdest(xsc+xmotion,ysc+ymotion,mee) then
          movecreature(xsc,ysc,xsc+xmotion,ysc+ymotion)
		  else begin;fight:=true;writelog(0,'cannot move, will try fighting');end;
         {do motion}
        end;		
		
       if fight then
	   begin
		 writelog(199,'creature is fighting');	
	   if ((foundrange>1) AND (fr<>0)) or ((foundrange<=1000) AND (fw<>0)) then
        begin

         if foundrange>1000 then whoops:=rws else whoops:=ws; if fw=0 then whoops:=rws;

         registerattacks[regattacknum,1]:=xinloc+xsc+10;
         registerattacks[regattacknum,2]:=yinloc+ysc+11;
         registerattacks[regattacknum,3]:=attacklocx;
         registerattacks[regattacknum,4]:=attacklocy;
         if (foundrange<=1000) and (fw<>0) then
            registerattacks[regattacknum,5]:=fw else
            registerattacks[regattacknum,5]:=0;
         if (foundrange>1000) or (fw=0) then
           registerattacks[regattacknum,6]:=fr else
           registerattacks[regattacknum,6]:=0;
         registerattacks[regattacknum,7]:=whoops;
         registerattacks[regattacknum,8]:=crcsource;
         if regattacknum<16 then
		   inc(regattacknum);

         creaturemoved[map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].d]:=movedindex;
         {fire weapon}
		 end;
        end;

		
		
      end {determine} else
       if motive=0 then
        case random(8) of
         1:if checkdest(xsc-1,ysc,mee) then movecreature(xsc,ysc,xsc-1,ysc);
         2:if checkdest(xsc+1,ysc,mee) then movecreature(xsc,ysc,xsc+1,ysc);
         3:if checkdest(xsc,ysc-1,mee) then movecreature(xsc,ysc,xsc,ysc-1);
         4:if checkdest(xsc,ysc+1,mee) then movecreature(xsc,ysc,xsc,ysc+1);
        end; {rnd8 case}

     end; {with do}

{**************}
 writelog(0,'Drawing map');
 for xsc:=0 to 10 do
  for ysc:=0 to 8 do
   begin
    anim_screen[xsc+1,ysc+1].lit:=1;
    quasimap[xsc,ysc]:=map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
     ((xinloc+xsc+10) MOD 16)+1,((yinloc+ysc+11) MOD 16)+1].o;
    if obj^[quasimap[xsc,ysc]].t<6 then
     begin
     if obj^[quasimap[xsc,ysc]].d[8]=3 then
      begin
       dp8:=0;
       trypassable(dp8,obj^[quasimap[xsc,ysc]].d[4],obj^[quasimap[xsc,ysc]].d[5]);
       if dp8<>0 then quasimap[xsc,ysc]:=obj^[quasimap[xsc,ysc]].d[12];

      end;
     if (obj^[quasimap[xsc,ysc]].d[4] AND 64)=64 then anim_screen[xsc+1,ysc+1].lit:=2; {light source}
     end;

   end;
{ quasimap[5,4]:=0;}

for xsc:=0 to 10 do for ysc:=0 to 8 do
 begin
  anim_screen[xsc+1,ysc+1].under:=0;
  if (ack.anim_speed=0) or (obj^[quasimap[xsc,ysc]].t>=6) then
   begin
    visimap[xsc,ysc]:=
     obj^[quasimap[xsc,ysc]].d[1];
    if obj^[quasimap[xsc,ysc]].t>=6 then
	   begin
		    tto:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].o;
		    ttd:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].d;
		    trueterrain(tto,ttd);
			anim_screen[xsc+1,ysc+1].under:=tto;
	   end;	
    anim_screen[xsc+1,ysc+1].tb:=false;
	
   end
    else
      if quasimap[xsc,ysc]=255 then
      begin
        creatureslot:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].d;
		if transparency then
		 begin
		  anim_screen[xsc+1,ysc+1].under:=rcrc^[creatureslot].obj;
		  if obj^[anim_screen[xsc+1,ysc+1].under].t>5 then
		   begin
		    tto:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].o;
		    ttd:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].d;
		    trueterrain(tto,ttd);
			anim_screen[xsc+1,ysc+1].under:=tto;
		   end;	
		 end;
        if ((obj^[rcrc^[creatureslot].obj].t<3)
         and (obj^[rcrc^[creatureslot].obj].d[13]<>0))
         then
          begin
           visimap[xsc,ysc]:=obj^[rcrc^[creatureslot].obj].d[13];
           anim_screen[xsc+1,ysc+1].tb:=false;  {creature in chair, etc}
		   anim_screen[xsc+1,ysc+1].under:=0;
          end
         else
          begin
           visimap[xsc,ysc]:=crc^[rcrc^[creatureslot].crcsource].g1;
           if crc^[rcrc^[creatureslot].crcsource].g2=0 then
		    anim_screen[xsc+1,ysc+1].tb:=false else anim_screen[xsc+1,ysc+1].tb:=true;
           anim_screen[xsc+1,ysc+1].tb4:=true;
           with anim_screen[xsc+1,ysc+1] do
            begin
             t1:=crc^[rcrc^[creatureslot].crcsource].g1;
             t2:=crc^[rcrc^[creatureslot].crcsource].g2;
             t3:=crc^[rcrc^[creatureslot].crcsource].g3;
             t4:=crc^[rcrc^[creatureslot].crcsource].g4;
            end;
          end;
      end else
      begin
       {animation sequence}
      { if anim_phase_one then }
        visimap[xsc,ysc]:=obj^[quasimap[xsc,ysc]].d[1];
	
        { else visimap[xsc,ysc]:=obj^[quasimap[xsc,ysc]].d[6]; }
      with anim_screen[xsc+1,ysc+1] do
      begin
       t1:=obj^[quasimap[xsc,ysc]].d[1];
       if t1=DECOGRP then
	    t2:=map[((xinloc+xsc+10) DIV 16)+1,
         ((yinloc+ysc+11) DIV 16)+1,((xinloc+xsc+10) MOD 16)+1,
         ((yinloc+ysc+11) MOD 16)+1].d
	    else t2:=obj^[quasimap[xsc,ysc]].d[6];
       if (t2=0) or (t1=DECOGRP) then tb:=false else tb:=true;
       tb4:=false;
      end;
      end;

if transparency then anim_screen[6,5].under:=quasimap[5,4];

if ack.minviewdistance>ack.viewdistance then nowviewdistance:=ack.minviewdistance
  else nowviewdistance:=ack.viewdistance;


if nowviewdistance<16 then
  if distance(5,4,xsc,ysc)>nowviewdistance then
   {if not illuminated then}
   begin
    {anim_screen[xsc+1,ysc+1].tb:=false;}
    {visimap[xsc,ysc]:=0;}
    anim_screen[xsc+1,ysc+1].lit:=(anim_screen[xsc+1,ysc+1].lit AND 2);
   end;
 {if light source then anim_screen[xsc+1,ysc+1].lit:=2;}
 end;
{}
  if shadowing<>255 then
   begin
    for xsc:=1 to 11 do for ysc:=1 to 9 do
     shadowscan[xsc,ysc]:=0;  {clear shadowscan array}
     shadowscan[6,5]:=2; {start expansion at 6,5}
     limit_found:=false;
    repeat
      xsc:=0;ysc:=1;two_found:=false;
      repeat
       inc(xsc);
       if xsc>11 then begin;xsc:=1;inc(ysc);end;
       if ysc<>10 then
        begin
         if shadowscan[xsc,ysc]=2 then
          begin
           two_found:=true;
           two_x:=xsc;
           two_y:=ysc;
          end;
        end
        else limit_found:=true;
      until (two_found) or (limit_found);
     {search for two, set two_found,two_x,two_y.}
     if two_found then
      begin

       if two_x-1>0 then    {check x-1,y}
        if shadowscan[two_x-1,two_y]=0 then
         if (obj^[quasimap[two_x-2,two_y-1]].t>5) or
          (obj^[quasimap[two_x-2,two_y-1]].d[4]<127) then
           shadowscan[two_x-1,two_y]:=2 else
            shadowscan[two_x-1,two_y]:=1;

       if two_x+1<12 then   {check x+1,y}
        if shadowscan[two_x+1,two_y]=0 then
         if (obj^[quasimap[two_x,two_y-1]].t>5) or
          (obj^[quasimap[two_x,two_y-1]].d[4]<127) then
           shadowscan[two_x+1,two_y]:=2 else
            shadowscan[two_x+1,two_y]:=1;

       if two_y-1>0 then    {check x,y-1}
        if shadowscan[two_x,two_y-1]=0 then
         if (obj^[quasimap[two_x-1,two_y-2]].t>5) or
          (obj^[quasimap[two_x-1,two_y-2]].d[4]<127) then
           shadowscan[two_x,two_y-1]:=2 else
            shadowscan[two_x,two_y-1]:=1;

       if two_y+1<10 then   {check x,y+1}
        if shadowscan[two_x,two_y+1]=0 then
         if (obj^[quasimap[two_x-1,two_y]].t>5) or
          (obj^[quasimap[two_x-1,two_y]].d[4]<127) then
           shadowscan[two_x,two_y+1]:=2 else
            shadowscan[two_x,two_y+1]:=1;

       if (two_x-1>0) and (two_y-1>0) then    {check x-1,y-1}
        if shadowscan[two_x-1,two_y-1]=0 then
         if (obj^[quasimap[two_x-2,two_y-2]].t>5) or
          (obj^[quasimap[two_x-2,two_y-2]].d[4]<127) then
           shadowscan[two_x-1,two_y-1]:=2 else
            shadowscan[two_x-1,two_y-1]:=1;

       if (two_x+1<12) and (two_y-1>0) then   {check x+1,y-1}
        if shadowscan[two_x+1,two_y-1]=0 then
         if (obj^[quasimap[two_x,two_y-2]].t>5) or
          (obj^[quasimap[two_x,two_y-2]].d[4]<127) then
           shadowscan[two_x+1,two_y-1]:=2 else
            shadowscan[two_x+1,two_y-1]:=1;

       if (two_x-1>0) and (two_y+1<10) then    {check x-1,y+1}
        if shadowscan[two_x-1,two_y+1]=0 then
         if (obj^[quasimap[two_x-2,two_y]].t>5) or
          (obj^[quasimap[two_x-2,two_y]].d[4]<127) then
           shadowscan[two_x-1,two_y+1]:=2 else
            shadowscan[two_x-1,two_y+1]:=1;

       if (two_x+1<12) and (two_y+1<10) then   {check x+1,y+1}
        if shadowscan[two_x+1,two_y+1]=0 then
         if (obj^[quasimap[two_x,two_y]].t>5) or
          (obj^[quasimap[two_x,two_y]].d[4]<127) then
           shadowscan[two_x+1,two_y+1]:=2 else
            shadowscan[two_x+1,two_y+1]:=1;

       shadowscan[two_x,two_y]:=1;
      end; {two_found}
    until limit_found;
    for xsc:=1 to 11 do for ysc:=1 to 9 do
    begin
     if shadowscan[xsc,ysc]=0 then
      begin
       if not ack.fly then
	    begin
		 if anim_screen[xsc,ysc].aggro then dec(aggro);
		 visimap[xsc-1,ysc-1]:=0;
         anim_screen[xsc,ysc].tb:=false;
		 anim_screen[xsc,ysc].lit:=1;
		 anim_screen[xsc,ysc].under:=0;
		end;

      end else if (anim_screen[xsc,ysc].lit AND 2)=2 then
       begin
        for xlit:=0 to 4 do
         for ylit:=0 to 4 do
		  if
		   (xsc+xlit-2 > 0) and
		   (ysc+ylit-2 > 0) and
		   (xsc+xlit-2 < 12) and
		   (ysc+ylit-2 < 10) and
		   (xlit+ylit<>0) and
		   (xlit*10 + ylit <> 40) and
		   (xlit*10 + ylit <> 44) and
		   (xlit*10 + ylit <> 4)
		   then	
		    anim_screen[xsc+xlit-2,ysc+ylit-2].lit:=anim_screen[xsc+xlit-2,ysc+ylit-2].lit OR 1;

       end;
    end;
   end; {if shadowing}
{}
  if ack.hp[0]>0 then
  begin
   visimap[5,4]:=curricon;
   anim_screen[6,5].tb:=false;
  end;
 for xsc:=0 to 10 do for ysc:=0 to 8 do
  {if visimap[xsc,ysc]<>0 then}
  if anim_screen[xsc+1,ysc+1].lit>0 then
    begin
	 if visimap[xsc,ysc]=DECOGRP then
	   putgrap2((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,anim_screen[xsc+1,ysc+1].t2)
	 else if anim_screen[xsc+1,ysc+1].under=0 then
	  putgrap((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,visimap[xsc,ysc])
	  else
	     puttransgrap11((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,visimap[xsc,ysc],obj^[anim_screen[xsc+1,ysc+1].under].d[1]);
	end
   else
    if visimap[xsc,ysc]=DECOGRP then
	 putdarkgrap2((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,anim_screen[xsc+1,ysc+1].t2,ack.darkforeground,ack.darkbackground)
	 else
	  begin
	   if anim_screen[xsc+1,ysc+1].under=0 then
	    putdarkgrap((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,visimap[xsc,ysc])
		else begin
		 putdarktransgrap11((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,
		  visimap[xsc,ysc],obj^[anim_screen[xsc+1,ysc+1].under].d[1]);
		 anim_screen[xsc+1,ysc+1].tb:=false;
		 end;
	
	  end;

 {clearbottom;}
 savepage;
 for xsc:= 1 to regattacknum-1 do
 begin
  xlit:=registerattacks[xsc,3];
  ylit:=registerattacks[xsc,4];
  roomprojectile(registerattacks[xsc,1],registerattacks[xsc,2],xlit,ylit);
  if (registerattacks[xsc,3]=xlit) and (registerattacks[xsc,4]=ylit) then
  begin {only bother attacking if you can hit}
   attacker_id:=registerattacks[xsc,8];
   attacking(registerattacks[xsc,1],registerattacks[xsc,2],
            registerattacks[xsc,3],registerattacks[xsc,4],
            registerattacks[xsc,5],registerattacks[xsc,6],
            registerattacks[xsc,7]);
  end; 			
 end;
 if regattacknum>1 then begin;delay2(combatpacing*6);restorepage;end;
 {for xsc:=0 to 10 do for ysc:=0 to 8 do
  if anim_screen[xsc+1,ysc+1].lit>0 then putgrap((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,visimap[xsc,ysc])
   else putdarkgrap((xsc)*4+XCONST+3,ysc*16+(YCONST*4)+10,visimap[xsc,ysc]);}


 anim_toggle;
end;


{********** Main procedure! **********}

begin
 calculate_weight;
 anim_wide:=0;anim_tall:=0;nextanim:=0;
 erasebottom:=1;curricon:=0;
 CHUNKSAVE:=false;
 onlycell:=false;
 xchunkloc:=xchunk;ychunkloc:=ychunk;xinloc:=x;yinloc:=y;
 getchunks(xchunkloc,ychunkloc);

 if entrancemacro<>0 then
  begin
   writelog(entrancemacro,'Running entrance macro');
   run_macro(entrancemacro);

  end;


 showwalk;
 done:=false;moved:=true;
repeat
 arrowmoved:=false;
      ack.plregion:=rgn;
      ack.plxch:=xchunkloc;
      ack.plych:=ychunkloc;
      ack.plxloc:=xinloc;
      ack.plyloc:=yinloc;
 levelup;

{ if key_Report then readkey_Report;}


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
	 region.port[thisportal].rx:=global_xchunk;
	end;
    region.port[thisportal].ry:=global_ychunk;
    region.port[thisportal].x:=global_xloc;
    region.port[thisportal].y:=global_yloc;
    {if moved then showview;}
   { done:=true;
	
   rgn:=global_region;
   xchunk:=global_xchunk;xchunkloc:=xchunk;
   ychunk:=global_ychunk;ychunkloc:=ychunk;
   x:=global_xloc;xinloc:=global_xloc;
   y:=global_yloc;yinloc:=global_yloc;
   if global_room<>0 then xchunk:=global_room;}
   macro_teleport:=false;
  end;

 { teleport_xchunk:=xchunkloc;
  teleport_ychunk:=ychunkloc;
  teleport_yloc:=yinloc;
  teleport_xloc:=xinloc;
  teleport_room:=0;
  teleport_region:=rgn;}
  teleport_room:=0;
  global_xloc:=xinloc;
  global_yloc:=yinloc;
  global_xchunk:=xchunkloc;
  global_ychunk:=ychunkloc;
  global_room:=0;
  global_region:=rgn;


  curricon:=ack.playericon;
  if ack.invisible>0 then if ack.invis_icon<>0 then curricon:=ack.invis_icon;
  if ack.pweapready<>0 then if obj^[ack.pweapready].d[13]<>0 then
   curricon:=obj^[ack.pweapready].d[13];
  if ack.parmor[1]<>0 then if obj^[ack.parmor[1]].d[13]<>0 then
   curricon:=obj^[ack.parmor[1]].d[13];
  if ack.plvehicle<>0 then if obj^[ack.plvehicle].d[13]<>0 then
    curricon:=obj^[ack.plvehicle].d[13];
 if not ack.fly then begin	
  if map[2,2,xinloc,yinloc].o<>0 then
   if (obj^[map[2,2,xinloc,yinloc].o].t<3) AND
     (obj^[map[2,2,xinloc,yinloc].o].d[13]<>0)
    then if obj^[map[2,2,xinloc,yinloc].o].d[13]=255 then
     curricon:=obj^[map[2,2,xinloc,yinloc].o].d[1] else
       curricon:=obj^[map[2,2,xinloc,yinloc].o].d[13];
  if obj^[map[2,2,xinloc,yinloc].o].t<3 then
       if (obj^[map[2,2,xinloc,yinloc].o].d[4]=19) and (ack.plvehicle<>0) then
        curricon:=obj^[map[2,2,xinloc,yinloc].o].d[1];
 end;		
 if moved then showview;

 if erasebottom=1 then clearbottom;
 if erasebottom<>0 then dec(erasebottom);
 if doublepass then actionparser(0,0,0,0,0,0,0,0);
 if action_weap=22 then
  begin
   wxloc:=15+xinloc;
   wyloc:=15+yinloc;
   showweapon(obj^[a_weap_type].t,a_weap_type,a_weap_org_x-9-xinloc,a_weap_org_y-10-yinloc,
      wxloc-9-xinloc,wyloc-10-yinloc,11,9);
   {whack player with weapon}
   if not hitcreature(obj^[a_weap_type].t,a_weap_type,100)
    then shootterrain(obj^[a_weap_type].t,a_weap_type);
   action_weap:=0;
  end;

if not done then
begin
 if moved then
  if region.room.wallgrap[16]<>0 then
   begin
   if region.room.wallgrap[16]=1 then
    begin
     if ack.stepmacro<>0 then run_macro(ack.stepmacro)
    end else run_macro(region.room.wallgrap[16]-1);
   end;
 calculate_weight;
 doqueued_stepaction;
 moved:=false;
 graphHP;
    if ack.hp[0]=0 then begin;readkey_time:=0;readkey_default:=#255;end;
  writelog(255,'Readkey_default: '+readkey_default+' (#'+strnum(ord(readkey_default))+')');
 if action_weap=23 then begin;writelog(255,'...changing to A to process weapon');readkey_default:='A';readkey_time:=0;end;
 if (random(encumberance+1)<=1) or (j=#253) then
  j:=upcase(timed_readkey(j2)) else
  j:=#253;
  writelog(255,'Readkey result: '+j+' (#'+strnum(ord(j))+')');
 case j of
  #0: case j2 of
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
      ack.plxch:=xchunkloc;
      ack.plych:=ychunkloc;
      ack.plxloc:=xinloc;
      ack.plyloc:=yinloc;
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
        savewmap;
        fullgamesave;
		savegame_menu;
        if (j2=#16) or (j2=#68) then begin;shutdownsound;halt;end;
        say(43,188,0,'                  ');
       end;
       done:=false;moved:=false;clearbottom;
      end;
  'H':begin
     if wtrymove(xinloc,yinloc-1,xinloc,yinloc)=0 then
     if checkfuel then if yinloc>1 then
      begin;moved:=true;arrowmoved:=true;dec(yinloc);
	  passtime(region.room.wallgrap[15]);end
       else begin;chunkmove(NORTH);moved:=true;arrowmoved:=true;
	   passtime(region.room.wallgrap[15]);end;
	  lastmov:=1;
	  end;
  'K':begin
      if wtrymove(xinloc-1,yinloc,xinloc,yinloc)=0 then
       if checkfuel then if xinloc>1 then begin;passtime(region.room.wallgrap[15]);
	   moved:=true;arrowmoved:=true;dec(xinloc);end
       else begin;chunkmove(WEST);moved:=true;arrowmoved:=true;
	   passtime(region.room.wallgrap[15]);end;
	  lastmov:=4; 	
	  end;
  'M':begin
      if wtrymove(xinloc+1,yinloc,xinloc,yinloc)=0 then
       if checkfuel then if xinloc<16 then begin;passtime(region.room.wallgrap[15]);
	   moved:=true;arrowmoved:=true;inc(xinloc);end
       else begin;chunkmove(EAST);moved:=true;arrowmoved:=true;
	   passtime(region.room.wallgrap[15]);end;
	  lastmov:=3; 	
	  end;
  'P':begin
      if wtrymove(xinloc,yinloc+1,xinloc,yinloc)=0 then
       if checkfuel then if yinloc<16 then begin;passtime(region.room.wallgrap[15]);
	   moved:=true;arrowmoved:=true;inc(yinloc);end
       else begin;chunkmove(SOUTH);moved:=true;arrowmoved:=true;
	   passtime(region.room.wallgrap[15]);end;
	  lastmov:=2; 	
	  end;
  end;
  #32:begin;clear_keyboard_buffer;moved:=true;passtime(region.room.wallgrap[15]);end;
  #9:begin
      sound(500); loadgraps; loadobjs; loadfont; loadcreatures; nosound;
     end;
  'A':begin
       ack.invisible:=0; {attacking breaks invis}
	
       oops_i_missed:=false;
       passtime(2); {attacking takes time}
	
       if ack.pweapready<>0 then
        if ack.pinv[ack.pweapready]=0 then ack.pweapready:=0;
		  {make sure you actually own the weapon you're attacking with}
		
       moved:=true;
       attacker_alignment:=5; {signals to other procedures that you're the attacker}
	
       weapon2t:=0;weapon2n:=0;weapon1t:=0;weapon1n:=0; {reset weapon numbers}
	
       if ack.pweapready<>0 then
        begin;weapon1t:=obj^[ack.pweapready].t;
        weapon1n:=ack.pweapready;end;  {load your held weapon into #1}
		
       if ack.plvehicle<>0 then
        if obj^[ack.plvehicle].d[4]<>0 then
         begin;weapon2t:=obj^[obj^[ack.plvehicle].d[4]].t;
         weapon2n:=obj^[ack.plvehicle].d[4];end; {load vehicle weapon into #2}



      if action_weap<>23 then
	  {if this is not an action-triggered attack,
	    check for ammo, etc.}
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
       end; {if not 23}
	
       if action_weap=23 then
	   {load action weapon into #1, clear #2}
        begin
         weapon1n:=a_weap_type;
         weapon1t:=obj^[a_weap_type].t;
         weapon2t:=0;weapon2n:=0;
        end;
		
	    if weapon1n=0 then
	   {if you have no weapon, but your vehicle does, use that}
		    begin
			 weapon1t:=weapon2t;
			 weapon1n:=weapon2n;
			 weapon2t:=0;
			 weapon2n:=0;
			end;	
		
       if (weapon1t=0) and (weapon2t=0) then
        begin
		 {you have no weapon, don't attack}
         clearbottom;bottomsay(0,'NO WEAPON');delay2(combatpacing*5);moved:=false;erasebottom:=3;
        end else
		
       begin
	    {you have a weapon, determine your max range}
        maxrange:=0;
        if (weapon1t=8) then {if weapon 1 is ranged}
         {if obj^[weapon1n].d[5] DIV 16 < 11 then}
          maxrange:=obj^[weapon1n].d[5] MOD 16;
		
        if (weapon2t=8) then
        { if obj^[weapon2n].d[5] DIV 16 < 11 then}
          if maxrange<obj^[weapon2n].d[5] MOD 16 then
           maxrange:=obj^[weapon2n].d[5] MOD 16;
        xloc:=15+xinloc; yloc:=15+yinloc;
        wxloc:=xloc;wyloc:=yloc;

 if maxrange=0 then
  begin
   xmod:=0;
   getadjacentlocation(xmod,ymod,'SELECT DIRECTION TO ATTACK',false);
   wxloc:=xloc+xmod;wyloc:=yloc+ymod;
  end else
begin
        clearbottom;bottomsay(0,'SELECT TARGET');
        done2:=false;
        roomwide:=11; roomtall:=9;
repeat
 xorx:=(wxloc-9-xinloc)*4-3+(32-(roomwide*2));
 xory:=(wyloc-10-yinloc)*16-14+(88-(roomtall*8));
 targeticon(xorx,xory);
 j:=upcase(readkey);
 no_targeticon(xorx,xory);
 case j of
  #0: case readkey of
  #59:help;
  'H':if (wyloc-10-yinloc)>1
       then if distance(xloc,yloc,wxloc,wyloc-1)<=maxrange+1 then
       dec(wyloc);
  'K':if (wxloc-9-xinloc)>1
       then if distance(xloc,yloc,wxloc-1,wyloc)<=maxrange+1 then
       dec(wxloc);
  'M':if (wxloc-9-xinloc)<roomwide
       then if distance(xloc,yloc,wxloc+1,wyloc)<=maxrange+1
       then inc(wxloc);
  'P':if (wyloc-10-yinloc)<roomtall
       then if distance(xloc,yloc,wxloc,wyloc+1)<=maxrange+1
       then inc(wyloc);
  end;
  #13:done2:=true;
  #27:begin;done2:=true;ymod:=99;end;
  end;
until done2;
clearbottom;
if ymod=99 then moved:=false;
if ymod<>99 then
 begin
  {set xmod and ymod for Cone-weapons}
  xmod:=0;ymod:=0;
  if wxloc>xloc then xmod:=1 else if wxloc<>xloc then xmod:=-1;
  if wyloc>yloc then ymod:=1 else if wyloc<>yloc then ymod:=-1;
  if abs(wyloc-yloc)>abs(wxloc-xloc) then xmod:=0 else ymod:=0;
 end;
end;
       if distance(xloc,yloc,wxloc,wyloc)>1 then
	     begin
		  if weapon1t=7 then
		    begin
			 weapon1t:=weapon2t;
			 weapon1n:=weapon2n;
			 weapon2t:=0;
			 weapon2n:=0;
			end;
		  if weapon2t=7 then
		    begin
			 weapon2t:=0;
			 weapon2n:=0;
			end;			
		  weaponskill:=ack.rweapskill[0];
		 end
        else weaponskill:=ack.weapskill[0];
       if action_weap=23 then weaponskill:=100;
    (* if random(maxrange)<OOPS then
       begin
        oops_i_missed:=true;
        case random(4) of
         0:dec(wxloc);
         1:dec(wyloc);
         2:inc(wxloc);
         3:inc(wyloc);
         end;
       end;
     *)
      if ymod<>99 then
      begin
       if (xloc<>wxloc) or (yloc<>wyloc) then attacking(xloc,yloc,wxloc,wyloc,weapon1n,weapon2n,weaponskill);


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
{ !      if (ack.PINV[obj^[weapon1n].d[6]])<>0 then        }
           begin
            if (ack.PINV[obj^[weapon1n].d[6]]>0) and
             ( obj^[weapon1n].d[7] > random(100) ) then
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
{ !         if (ack.PINV[obj^[weapon2n].d[6]])=0 then     }
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

  'L':begin
       moved:=false;
        clearbottom;bottomsay(0,'LOOK...');
        erasebottom:=3;
        wxloc:=15+xinloc;
        wyloc:=15+yinloc;
        done2:=false;
        roomwide:=11; roomtall:=9;
repeat
 xorx:=(wxloc-9-xinloc)*4-3+(32-(roomwide*2));
 xory:=(wyloc-10-yinloc)*16-14+(88-(roomtall*8));
 targeticon(xorx,xory);
 j:=upcase(readkey);
 no_targeticon(xorx,xory);
 case j of
  #0: case readkey of
  #59:help;
  'H':if (wyloc-10-yinloc)>1 then
       dec(wyloc);
  'K':if (wxloc-9-xinloc)>1 then
       dec(wxloc);
  'M':if (wxloc-9-xinloc)<roomwide
       then inc(wxloc);
  'P':if (wyloc-10-yinloc)<roomtall
       then inc(wyloc);
  end;
  #13,#32,#27:done2:=true;
  end;
until done2;
   if j<>#27 then
     begin
      clearbottom;
      vehcount:=map[wxloc DIV 16+1,wyloc DIV 16+1,
       wxloc MOD 16+1,wyloc MOD 16+1].o;
      if (vehcount=0) or (visimap[(wxloc-9-xinloc)-1,(wyloc-10-yinloc)-1]=0) then

         bottomsay(0,'YOU SEE: NOTHING.')

      else if vehcount=255 then
       begin
        putgrapc:=map[wxloc DIV 16+1,wyloc DIV 16+1,
         wxloc MOD 16+1,wyloc MOD 16+1].d;
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
		  if ack.cheat=123 then
		    begin
			 s:='#'+strnum(putgrapc)+',H='+strnum(hp)+'/'+strnum(dropping)+',M='+
			  strnum(motive)+',A='+strnum(anger);
			end;
          end;
        bottomsay(2,'CONDITION: Û1'+s);
        {see creature}
       end
      else
      begin
      if vehcount=1 then
       begin
        s:=strnum(veh[map[wxloc DIV 16+1,wyloc DIV 16+1,
         wxloc MOD 16+1,wyloc MOD 16+1].d].howmany*10);
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
       if ((abs(wxloc-xinloc-15)=1) and (abs(wyloc-yinloc-15)=0))
         or ((abs(wxloc-xinloc-15)=0) and (abs(wyloc-yinloc-15)=1)) then
          dropping:=1 else dropping:=0; {space adjacent?}
{       if dropping=1 then say(191,2,0,'NEAR') else say(191,2,0,'FAR ');
        say(191,2,0,'<<'+strnum(wxloc)+','+strnum(xinloc+15)+':'+
        strnum(wyloc)+','+strnum(yinloc+15)+'>>'); }
       if obj^[vehcount].t<6 then
        if (obj^[vehcount].d[9]=6) or
         ((obj^[vehcount].d[9]=13) and (dropping=1)) then
         begin
          {if obj^[vehcount].d[14]=0 then begin;waitkey;clearbottom;end;}
          dropping:=obj^[vehcount].d[3];
          if (obj^[vehcount].t=2) or (obj^[vehcount].t=4) then
           dropping:=map[wxloc DIV 16+1,wyloc DIV 16+1,
            wxloc MOD 16+1,wyloc MOD 16+1].d;
          do_action(obj^[vehcount].d[2],dropping,1,0,vehcount,
           0,0,wxloc,wyloc);
          moved:=true;
         end;
      end;
     end;
      erasebottom:=3;

      end; {look}
  #199:key_report:=NOT key_Report;
  #198:if key_report then
       begin
         wxloc:=15+xinloc;
         wyloc:=15+yinloc;
         bottomsay(0,'YOU ARE AT MAP['+
          strnum(wxloc DIV 16+1)+','+strnum(wyloc DIV 16+1)+','+
          strnum(wxloc MOD 16+1)+','+strnum(wyloc MOD 16+1)+']. XCH='+
          strnum(xchunkloc)+' YCH='+strnum(ychunkloc));
         repeat until readkey<>#0;
       end;
  #254:begin
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
        putgrapc:=wtrymove(xinloc,yinloc,xinloc,yinloc); }
		showview;
        moved:=false;
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
 (* 'W':if erasebottom<100 then
        begin
         moved:=true;
         erasebottom:=109;
         readkey_time:=0;
         readkey_default:=#255;
         clearbottom;
         bottomsay(0,'RESTING...');
        end;
*)
'T':if talktome<>0 then
  begin
   {action-triggered talk}
   conversation(talktome,vehcount);
   talktome:=0;
  end else
  begin
   ack.invisible:=0;
   passtime(11);
   erasebottom:=3;
   getadjacentlocation(xorx,xory,'TALK (SELECT DIRECTION)',false);
   xmod:=15+xinloc; ymod:=15+yinloc;
dropping:=0;
if xory<>99 then
repeat
   xmod:=xmod+xorx;ymod:=ymod+xory;
   vehcount:=map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].o;
   if (vehcount=255) then
    begin
        begin

         dropping:=rcrc^[map[xmod DIV 16+1,ymod DIV 16+1,
           xmod MOD 16+1,ymod MOD 16+1].d].talk;
         if dropping<>0 then
          conversation(dropping,
            rcrc^[map[xmod DIV 16+1,ymod DIV 16+1,
             xmod MOD 16+1,ymod MOD 16+1].d].anger)
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
	
	
  'D':
     begin
       readkey_time:=R150;
       if arcade then readkey_default:=#255 else readkey_default:=#1;
       moved:=true;
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
		 dri:=(dri DIV 10)*10;
         end;
    if dropping<>0 then
     begin
       xmod:=99; {allow discard}
	   if region.room.wallgrap[7]=1 then xmod:=98;
       getadjacentlocation(xmod,ymod,'DROP ITEM: '+obj^[dropping].n,false);
       if ymod=99 then dropping:=0;
     end;
    if xmod=99 then {discarding...}
     begin
      if obj^[dropping].t<>12 then dec(Ack.PINV[dropping],1)
       else dec(Ack.PCASH,dri);
      checkdropping(dropping);
      clearbottom;bottomsay(2,'DESTROYED: '+obj^[dropping].n);
      erasebottom:=3;
      dropping:=0;
     end;
    if dropping<>0 then
     begin

       xmod:=xmod+15+xinloc;ymod:=ymod+15+yinloc;
       if map[xmod DIV 16+1,ymod DIV 16+1,
         xmod MOD 16+1,ymod MOD 16+1].o<>255 then
        dri1:=obj^[map[xmod DIV 16+1,ymod DIV 16+1,
         xmod MOD 16+1,ymod MOD 16+1].o].t else dri1:=3;
	   if ((dri1=1) or (dri1=2)) and (obj^[map[xmod DIV 16+1,ymod DIV 16+1,
         xmod MOD 16+1,ymod MOD 16+1].o].d[4]>127) then dropping:=0;
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
     dri1:=map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].o;
     if (dri1<>0) and (dri1<>255) then
      if ((obj^[dri1].t<3) or (obj^[dri1].t=5)) and
       (obj^[dri1].d[9]=2) and (obj^[dri1].d[10]=dropping) then
        begin
         {vending machine!}
         dropping2:=obj^[dri1].d[3];
         if not(odd(obj^[dri1].t)) then
          dropping2:=map[xmod DIV 16+1,ymod DIV 16+1,
            xmod MOD 16+1,ymod MOD 16+1].d;
         do_action(obj^[dri1].d[2],dropping2,0,0,dri1,
          map[xmod DIV 16+1,ymod DIV 16+1,
           xmod MOD 16+1,ymod MOD 16+1].d,0,xmod,ymod);
         if obj^[map[xmod DIV 16+1,ymod DIV 16+1,
           xmod MOD 16+1,ymod MOD 16+1].o].d[8]=1 then
          begin
           dri:=obj^[map[xmod DIV 16+1,ymod DIV 16+1,
            xmod MOD 16+1,ymod MOD 16+1].o].d[12];
           if obj^[dri].t<6 then
            map[xmod DIV 16+1,ymod DIV 16+1,
             xmod MOD 16+1,ymod MOD 16+1].o:=dri else
             flopitem(xmod,ymod,dri DIV 10,1);
          end;
         dropping:=0;
        end;

   if dropping<>0 then
    flopitem(xmod,ymod,dropping,dri DIV 10);
   end;
  end;
	
	
  'X':if Ack.PLvehicle<>0 then
        begin
		   macrosuccess:=1;
             i:=ACK.PLvehicle;
             if obj^[Ack.PLvehicle].d[12]<>0 then
			  begin
			   writelog(0,'vehicle exit macro');
               run_macro(obj^[Ack.PLvehicle].d[12]);
			  end else
            begin
             clearbottom;bottomsay(2,'DISMOUNTING VEHICLE.');

            end;		

		 if macrosuccess<>0 then
		 begin
		 ack.invisible:=0;
         vehhere:=true;
         if map[2,2,xinloc,yinloc].o=0 then vehhere:=false;
         if vehhere then
          if (obj^[map[2,2,xinloc,yinloc].o].t<5)
           then vehhere:=false;
         if not(vehhere) then
          begin
           vehcount:=1;
           repeat
            if veh[vehcount].used then inc(vehcount) else inc(vehcount,100);
           until vehcount>32;
           if vehcount>40 then
            begin
             CHUNKSAVE:=true;
             dec(vehcount,100);
             veh[vehcount].used:=true;
             veh[vehcount].obj:=map[2,2,xinloc,yinloc].o;
             veh[vehcount].objcode:=map[2,2,xinloc,yinloc].d;
             veh[vehcount].xchunk:=xchunkloc;
             veh[vehcount].ychunk:=ychunkloc;
             map[2,2,xinloc,yinloc].o:=i;
             map[2,2,xinloc,yinloc].d:=vehcount;
			
			 vehcount:=i;
             if i=ack.plvehicle then
			  ack.plvehicle:=0;
			

             erasebottom:=3;

             moved:=true;

            end;
          end;
		  end;
         {dismount}
        end;
  'G':begin
      ack.invisible:=0;
      getadjacentlocation(xmod,ymod,'GET ITEM (SELECT DIRECTION)',true);
      if ymod<>99 then
      begin
      xmod:=xmod+15+xinloc; ymod:=ymod+15+yinloc;
      vehcount:=map[xmod DIV 16+1,ymod DIV 16+1,
        xmod MOD 16+1,ymod MOD 16+1].o;
	 	
       if vehcount<>0 then
       begin
	   if obj^[vehcount].t<6 then


         {check for gathering trigger}
         if obj^[vehcount].d[9]=14 then
          begin

           if obj^[vehcount].d[10]<>0 then
           begin
            load_shortmsgfile(obj^[vehcount].d[10]);
            clearbottom;
            for i:=1 to 37 do
             begin
              putletter(i*2+1,180,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
              putletter(i*2+1,188,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
             end;
             erasebottom:=3;
            end;

			readkey_time:=0;readkey_default:=#255;
			do_action(obj^[vehcount].d[2],obj^[vehcount].d[3],0,0,
               vehcount,dri,0,xmod,ymod);
			
			
              if obj^[vehcount].d[8]=1 then
               begin
                if (obj^[vehcount].d[12]=0) or
                 (obj^[vehcount].t<6) then
                  begin
                   map[xmod DIV 16+1,ymod DIV 16+1,
                     xmod MOD 16+1,ymod MOD 16+1].o:=obj^[vehcount].d[12];
                   map[xmod DIV 16+1,ymod DIV 16+1,
                     xmod MOD 16+1,ymod MOD 16+1].d:=0;
                  end
                   else flopitem(xmod,ymod,obj^[vehcount].d[12],1);
               end;




          end; {gathering}



      vehhere:=true;
      if vehhere then
       if ((obj^[vehcount].t>5) and (obj^[vehcount].t<>10)) then
       begin
         dropping:=vehcount;
         if vehcount=1 then
          begin
		   vehcount:=map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].d;
		   writelog(0,'get cash: slot '+strnum(vehcount)+' amt '+strnum(veh[vehcount].howmany)+'x10');
           inc(ack.PCASH,veh[vehcount].howmany*10);
           clearbottom;erasebottom:=3;
           bottomsay(0,'GET: '+strnum(veh[vehcount].howmany*10)+' '+
            obj^[dropping].n);
			
          end else
        if ack.PINV[vehcount]<255 then
          begin
           if ack.PINV[vehcount]<255 then inc(ack.PINV[vehcount],1);
           clearbottom;erasebottom:=3;
           bottomsay(0,'GET: '+obj^[vehcount].n);
          end;
      vehcount:=map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].d;
       map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].o:=
         veh[vehcount].obj;
       map[xmod DIV 16+1,ymod DIV 16+1,xmod MOD 16+1,ymod MOD 16+1].d:=
         veh[vehcount].objcode;
         veh[vehcount].used:=false;


         bytebuf:=veh[vehcount].objcode;
         vehcount:=veh[vehcount].obj;
         trueterrain(vehcount,bytebuf);dri:=bytebuf;
         if vehcount<>0 then if obj^[vehcount].d[9]=12 then
          if (obj^[vehcount].d[10]=0) or
           (obj^[vehcount].d[10]=dropping) then
        begin
         {the anti- vending machine!}
		 if odd(obj^[vehcount].t) then
		  bytebuf:=obj^[vehcount].d[3];
         do_action(obj^[vehcount].d[2],bytebuf,0,0,vehcount,
          dri,0,xmod,ymod);
         if obj^[vehcount].d[8]=1 then
          begin
           dri1:=obj^[vehcount].d[12];
           if obj^[dri1].t<6 then
            settrueterrain(xmod,ymod,dri1,0)
            else flopitem(xmod,ymod,dri1,1);
          end;
        end;
         {checked for trigger 12}

         moved:=true;
         CHUNKSAVE:=true;
       end;
       end;
	   end;
      end;
 'B':if ack.plvehicle=0 then
         if (obj^[map[2,2,xinloc,yinloc].o].t=10) then
       begin
	   ack.invisible:=0;
       macrosuccess:=200;
       if obj^[map[2,2,xinloc,yinloc].o].d[5]<>0 then
	    begin
		 writelog(0,'vehicle boarding macro');
         run_macro(obj^[map[2,2,xinloc,yinloc].o].d[5]);
		 if macrosuccess=0 then writelog(0,'vehicle boarding macro returned FAIL!');
		end;
       if macrosuccess>0 then
        begin
         CHUNKSAVE:=true;
         Ack.PLvehicle:=map[2,2,xinloc,yinloc].o;

         if macrosuccess=200 then
          begin
           clearbottom;bottomsay(0,'USE VEHICLE: '+obj^[Ack.PLvehicle].n);
          end;



         erasebottom:=3;
         vehcount:=map[2,2,xinloc,yinloc].d;
         map[2,2,xinloc,yinloc].o:=veh[vehcount].obj;
         map[2,2,xinloc,yinloc].d:=veh[vehcount].objcode;
         veh[vehcount].used:=false;
         moved:=true;

         vehcount:=map[2,2,xinloc,yinloc].o;
         bytebuf:=map[2,2,xinloc,yinloc].d;
         trueterrain(vehcount,bytebuf);dri:=bytebuf;
         if vehcount<>0 then if obj^[vehcount].d[9]=12 then
          if (obj^[vehcount].d[10]=0) or
           (obj^[vehcount].d[10]=ack.plvehicle) then
        begin
         {the anti- vending machine!}
		 if odd(obj^[vehcount].t) then
		  bytebuf:=obj^[vehcount].d[3];
         do_action(obj^[vehcount].d[2],bytebuf,0,0,vehcount,
          dri,0,xinloc+15,yinloc+15);
         if obj^[vehcount].d[8]=1 then
          begin
           dri1:=obj^[vehcount].d[12];
           if obj^[dri1].t<6 then
            settrueterrain(xinloc+15,yinloc+15,dri1,0)
            else flopitem(xinloc+15,yinloc+15,dri1,1);
          end;
        end;
         {checked for trigger 12}

         {board vehicle}
        end;
      end;




   #201:begin

               readkey_time:=R150;
        if arcade then readkey_default:=#255 else
         readkey_default:=#1;
   if macrosuccess>0 then begin
    writelog(thisportal,'Completing portal');
    delay2(300);
    done:=true;
	if thisportal=0 then thisportal:=255;
    rgn:=region.port[thisportal].region;
    xchunk:=region.port[thisportal].rx;
    ychunk:=region.port[thisportal].ry;
    x:=region.port[thisportal].x;
    y:=region.port[thisportal].y;

    end else writelog(thisportal,'Portal success=0');
   end;
   else if sharedcommand(j) then if macro_teleport=false then begin;{showwalk;}moved:=true;end;
 end;

 {process portal}
 dri1:=map[2,2,xinloc,yinloc].o;
 if dri1<>0 then if obj^[dri1].t<6 then if obj^[dri1].d[8]=3 then
  begin
    dp8:=0;
    trypassable(dp8,obj^[dri1].d[4],obj^[dri1].d[5]);
    if dp8<>0 then dri1:=obj^[dri1].d[12];
  end;
 if arrowmoved then writelog(0,'arrowmoved') else writelog(0,'no arrow');
 if not ack.fly then
 if obj^[dri1].t=5 then
  if map[2,2,xinloc,yinloc].d<>0 then
   if arrowmoved then
   begin
    thisportal:=map[2,2,xinloc,yinloc].d;
    writelog(thisportal,'Starting portal');
    readkey_time:=0;
    readkey_default:=#201;
    macrosuccess:=1;
   end;
end; {if not done}
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
 savewmap;
end;



begin

end.
