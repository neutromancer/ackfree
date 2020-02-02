{$O+}
{$F+}
unit o_play0a;

{This unit contains just about everything that should always be in memory.}
{NOT an overlay, but it's closely related to them.}

interface

uses xms,u_sound,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,u_delay2,dos,u_fonts,u_graps,o_play0;


var     lastaggro:byte;
        talktome:byte;


procedure do_action(action,tmdata,caller,tmresult,tmspot,tmdta,room,x,y:byte);

procedure queue_stepaction(a,b,c,d,e,f,g,h,i:byte);

procedure doqueued_stepaction;
function roomloc(r,x,y:byte):locpointer;
procedure actionparser(tmresult,tmspot,tmdata,room,x,y,herex,herey:byte);
procedure trypassable(var result:byte;p,pp:byte);

procedure erset(showtime:boolean); {Show menu. Shouldn't be called Erset. :-}
{procedure readkey_report;  }
function timed_readkey(var j2:char):char;
function promptverify(s:string):boolean;
procedure getadjacentlocation(var xmod,ymod:integer;galprompt:string;otherkey:boolean);
procedure scrollsay(s:string);
function sharedcommand(j:char):boolean;
procedure checkdropping(dropping:byte);
function checkfuel:boolean;
 {end i_ply1}
procedure showweapon(weapon0t,weapon0n,aimxloc,aimyloc,wxloc,wyloc,rwide,rtall:byte);
{end i_ply2}


implementation




procedure prepare_second_pass(tmresult,tmspot,tmdata,room,x,y:byte);
begin
 doublepass:=true;
 dp_tmresult:=tmresult;
 dp_tmspot:=tmspot;
 dp_tmdata:=tmdata;
 dp_room:=room;
 dp_x:=x;dp_y:=y;
end;

procedure Inc2(var n:byte;ar:integer);
begin
 if (n+ar)<0 then n:=0 else
  if (n+ar)>255 then n:=255 else
   inc(n,ar);
end;

procedure do_action(action,tmdata,caller,tmresult,tmspot,tmdta,room,x,y:byte);
 var shi:shortint;
     dac,dac2,dacx,dacy:byte;
     rci,rci2:integer;
     done:boolean;
begin
 writelog(tmdata,'Do action: '+strnum(action));
 if tmspot<>0 then
  if obj^[tmspot].t<6 then
   if obj^[tmspot].d[8]=1 then
    if room=0 then
     begin
      map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o:=obj^[tmspot].d[12];
      {wmap terrain vanishes}
     end else
     begin
      if obj^[tmspot].d[12]<>0 then
       begin
        locnt^[rmcnt^[region.room.x1[room]+x-1,
         region.room.y1[room]+y-1]].obj:=obj^[tmspot].d[12];
       end else
       begin
        locnt^[rmcnt^[region.room.x1[room]+x-1,
         region.room.y1[room]+y-1]].obj:=0;
        rmcnt^[region.room.x1[room]+x-1,
         region.room.y1[room]+y-1]:=
           locnt^[rmcnt^[region.room.x1[room]+x-1,
            region.room.y1[room]+y-1]].p;
       end;
      {room-map terrain vanishes}
     end;
 queued_actions:=0; next_queued_action:=1; {action_weap:=0;}

 repeat

 done:=true;

 bumpnoise:=false;
 shi:=shortint(tmdata);
 writelog(action,'Performing action '+strnum(action)+', raw parameter='+strnum(tmdata));
 case action of
  42:begin {temp torchlight}
      if tmdata>245 then ack.torchduration:=tmdata-245 else ack.torchduration:=tmdata*10;
      ack.minviewdistance:=4;
     end;
  43:begin {temp daylight}
      if tmdata>245 then ack.torchduration:=tmdata-245 else ack.torchduration:=tmdata*10;
      ack.minviewdistance:=32;
     end;
  44:ack.regen_hp:=tmdata;
  45:ack.regen_mp:=tmdata;
  46:ack.poison:=tmdata;
  47:begin
      readkey_default:='T';
	  talktome:=tmdata;
	  readkey_time:=0;
     end;
  40:ack.playericon:=tmdata;
  1:begin
     if (not doublepass) and (not do_all) and (caller=0) and (room<>0) then
       begin;prepare_second_pass(tmresult,tmspot,tmdta,room,x,y);
       exit;end;
     if not do_all then doublepass:=false;
     shortmessage(tmdata);end;
  2:begin;savepage;longmessage(tmdata);restorepage;end;
  3:begin;savepage;picturemessage(tmdata);restorepage;end;
  4:begin;soundeffect(tmdata,1);stepnoise:=false;end;
  5:if shi<>0 then Inc2(Ack.HP[0],shi) else ack.hp[0]:=ack.hpmax[0];
  6:begin;Inc2(Ack.HPmax[0],shi);Inc2(Ack.HP[0],shi);end;
  7:if shi<>0 then Inc2(Ack.MP[0],shi) else ack.mp[0]:=ack.mpmax[0];
  8:Inc2(Ack.MPmax[0],shi);
  9:Inc2(Ack.strength[0],shi);
  10:Inc2(Ack.intelligence[0],shi);
  11:Inc2(Ack.rweapskill[0],shi);
  12:Inc2(Ack.weapskill[0],shi);
  13:begin
      ack.alignment:=tmdata;
      if (tmdata<1) or (tmdata>4) then ack.alignment:=1;
     end;
  14:begin
      if tmdata>1 then Inc2(Ack.PINV[tmdata],-1)
       else Dec(Ack.PCASH,1);

     end;
  15:begin
      if tmdata>1 then Ack.PINV[tmdata]:=0
       else Ack.PCASH:=0;

     end;
  16:begin
      if tmdata=12 then
       ack.Pcash:=0 else
      for dac:=2 to 254 do if obj^[dac].t=tmdata then
       ack.Pinv[dac]:=0;

     end;
  17:begin
      if tmdata>1 then Inc2(Ack.PINV[tmdata],1)
       else Inc(Ack.PCASH,1);
      {clearbottom;
      bottomsay(2,'YOU NOW HAVE: '+obj^[tmdata].n);
      erasebottom:=3;}

     end;
  41:if room=0 then
      begin
       {wmap}
       for dac:=(x)-5 to (x)+5 do
        for dac2:=(y)-4 to (y)+4 do
         if (map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].o=255)
          then if crc^[rcrc^[map[dac DIV 16+1,dac2 DIV 16+1,
           dac MOD 16+1,dac2 MOD 16+1].d].crcsource].t=tmdata then
          begin
           if ack.alignment<>tmdata then
           rcrc^[map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,
            dac2 MOD 16+1].d].anger:=5
             else ack.criminal:=tmdata;
          end;
      end else
      begin
       for dac:=region.room.x1[room] to region.room.x1[room]+roomwide-1 do
        for dac2:=region.room.y1[room] to region.room.y1[room]+roomtall-1 do
         begin
          {room-map}
          if locnt^[rmcnt^[dac,dac2]].obj=255 then
           if crc^[rcrc^[locnt^[rmcnt^[dac,dac2]].objcode].crcsource].t=tmdata
           then
            begin
             if ack.alignment<>tmdata then
             rcrc^[locnt^[rmcnt^[dac,dac2]].objcode].anger:=5
              else ack.criminal:=tmdata;
            end;
         end;
      end;
  18:if room=0 then
      begin
       {strip all of tmdata from wmap}
       for dac:=(x)-5 to (x)+5 do
        for dac2:=(y)-4 to (y)+4 do
         if (map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].o=
           tmdata) and (tmdata<>0) then
          begin
           chunksave:=true;
           if (obj^[tmdata].t>5)
               then
            begin
             map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].o:=
               veh[map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].d].obj;
             map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].d:=
               veh[map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].d].objcode;
            end else
            begin
              map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].o:=
               obj^[tmdata].d[12];
             dacy:=0;
             if obj^[obj^[tmdata].d[12]].t>5 then
             begin
              for dacx:=255 downto 1 do if veh[dacx].used=false then
               dacy:=dacx;
              if dacy=0 then
               map[dac DIV 16+1,dac2 DIV 16+1,dac MOD 16+1,dac2 MOD 16+1].o:=0
                else
               begin
                veh[dacy].used:=true;
                veh[dacy].obj:=0;
                veh[dacy].objcode:=0;
                veh[dacy].howmany:=1;
               end;
             end;
            end;
          end;
      end else
      begin
       for dac:=region.room.x1[room] to region.room.x1[room]+roomwide-1 do
        for dac2:=region.room.y1[room] to region.room.y1[room]+roomtall-1 do
         begin
          {strip all of tmdata from room-map}
          if locnt^[rmcnt^[dac,dac2]].obj=tmdata then
           if obj^[tmdata].d[12]=0 then
           begin
            locnt^[rmcnt^[dac,dac2]].obj:=0;
            rmcnt^[dac,dac2]:=locnt^[rmcnt^[dac,dac2]].p;
           end else
           begin
            locnt^[rmcnt^[dac,dac2]].obj:=obj^[tmdata].d[12];
            if obj^[tmdata].d[12]=1 then
             locnt^[rmcnt^[dac,dac2]].objcode:=1;
           end;
         end;
      end;
  19:if tmdata<>0 then
      if room=0 then
      begin
       if obj^[tmdata].t>5 then
        begin
         dac2:=0;
         for dac:=255 downto 1 do
          if veh[dac].used=false then dac2:=dac;
         if dac2<>0 then
          begin
           veh[dac2].obj:=
             map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o;
           veh[dac2].objcode:=
             map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].d;
           veh[dac2].used:=true;
           if tmdata=1 then veh[dac2].howmany:=2;
           {x/ychunk: REVISIT}
           map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o:=tmdata;
           map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].d:=dac2;
           {add item to wmap}
          end;
        end else if obj^[tmdata].t<>5 then
        begin
         map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o:=tmdata;
         map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].d:=0;
         {add terrain to wmap}
        end;
      end else
      begin
       rci2:=0;
       for rci:=LOCNTMAX downto 1 do if locnt^[rci].obj=0 then
        rci2:=rci;
       if rci2<>0 then
        if obj^[tmdata].t<>5 then
        begin
         locnt^[rci2].p:=rmcnt^[region.room.x1[room]+x-1,
          region.room.y1[room]+y-1];
         locnt^[rci2].obj:=tmdata;
         if tmdata<>1 then locnt^[rci2].objcode:=0
          else locnt^[rci2].objcode:=2;
         rmcnt^[region.room.x1[room]+x-1,
          region.room.y1[room]+y-1]:=rci2;
         {add item to room-map}
        end;
      end;
  20:if tmdata=1 then
      begin
       if ack.Pcash=0 then ack.hp[0]:=0;
      end else
     if ack.Pinv[tmdata]=0 then ack.hp[0]:=0;
  {21: activate all}
  22:begin
      action_weap:=22;
      a_weap_type:=tmdata;
      a_weap_org_x:=x;
      a_weap_org_y:=y;
     end;
  23:begin
      action_weap:=23;
      a_weap_type:=tmdata;

     end;
  24:if tmdata<>0 then
     begin
      dac:=0;
      for dac2:=RCMAX downto 1 do
       if rcrc^[dac2].used=false then dac:=dac2;
      if dac<>0 then
       begin
         rcrc^[dac].used:=true;
         rcrc^[dac].crcsource:=tmdata;
         rcrc^[dac].hp:=crc^[tmdata].hm;
         rcrc^[dac].mp:=crc^[tmdata].mm;
         rcrc^[dac].recurring:=false;
         rcrc^[dac].odds:=100;
         rcrc^[dac].motive:=0;
         rcrc^[dac].anger:=0;
         rcrc^[dac].talk:=0;
         if crc^[tmdata].t=2 then rcrc^[dac].anger:=1;
         if crc^[tmdata].t=4 then rcrc^[dac].anger:=6;
         if crc^[tmdata].t=1 then rcrc^[dac].anger:=2;
       end;
      if (room=0) and (dac<>0) then
       begin
        rcrc^[dac].obj:=map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o;
        rcrc^[dac].objdata:=
          map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].d;
        map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].o:=255;
        map[x DIV 16+1,y DIV 16+1,x MOD 16+1,y MOD 16+1].d:=dac;

        {add creature to wmap}
       end else
       begin
        rcrc^[dac].obj:=0;
        rcrc^[dac].objdata:=0;

        rci2:=0;
        for rci:=LOCNTMAX downto 1 do if locnt^[rci].obj=0 then
         rci2:=rci;
        if rci2<>0 then
         begin
          locnt^[rci2].p:=rmcnt^[region.room.x1[room]+x-1,
           region.room.y1[room]+y-1];
          locnt^[rci2].obj:=255;
          locnt^[rci2].objcode:=dac;
          rmcnt^[region.room.x1[room]+x-1,
           region.room.y1[room]+y-1]:=rci2;
         end;

        {add creature to room-map}
       end;
     end;
  25:Ack.variables[1]:=tmdata;
  26:Ack.variables[2]:=tmdata;
  27:Ack.variables[3]:=tmdata;
  28:Ack.variables[4]:=tmdata;
  29:Inc2(Ack.variables[1],tmdata);
  30:Inc2(Ack.variables[2],tmdata);
  31:Inc2(Ack.variables[3],tmdata);
  32:Inc2(Ack.variables[4],tmdata);
  33:Inc2(Ack.variables[1],-tmdata);
  34:Inc2(Ack.variables[2],-tmdata);
  35:Inc2(Ack.variables[3],-tmdata);
  36:Inc2(Ack.variables[4],-tmdata);
  37:begin
(*     if doublepass then writelog(37,'doublepass true');
     if do_all then writelog(37,'do_all true');	
     writelog(37,'caller: '+strnum(caller)+'  room: '+strnum(room));	
     if (not doublepass) and (not do_all) and (caller=0) and (room<>0) then
       begin;prepare_second_pass(tmresult,tmspot,tmdta,room,x,y);
       exit;end;
     if not do_all then doublepass:=false; *)
    { savepage; }

      run_macro(tmdata);

     { restorepage; }
     end;
  39:ack.viewdistance:=tmdata;
  38:if caller=0 then
     begin
      readkey_time:=(tmdata MOD 16)*20; {(tmdata MOD 16);}
      case (tmdata DIV 16) of
       0:begin;readkey_default:=#0;readkey_0default:='H';end;
       1:begin;readkey_default:=#0;readkey_0default:='K';end;
       2:begin;readkey_default:=#0;readkey_0default:='M';end;
       3:begin;readkey_default:=#0;readkey_0default:='P';end;
      end;
      {scoot}
     end;
 end;
if queued_actions>0 then
if next_queued_action<=queued_actions then
  begin
   action:=queued_action[next_queued_action,1];
   tmdata:=queued_action[next_queued_action,2];
   inc(next_queued_action);
   done:=false;
  end;
until done;
 if queued_actions>0 then writelog(0,'actions are queued');
end;


var queued_stepaction:array[0..9] of byte;

procedure queue_stepaction(a,b,c,d,e,f,g,h,i:byte);

begin
 writelog(0,'queueing stepaction');
 queued_stepaction[0]:=1;
 queued_stepaction[1]:=a;
 queued_stepaction[2]:=b;
 queued_stepaction[3]:=c;
 queued_stepaction[4]:=d;
 queued_stepaction[5]:=e;
 queued_stepaction[6]:=f;
 queued_stepaction[7]:=g;
 queued_stepaction[8]:=h;
 queued_stepaction[9]:=i;


end;


procedure doqueued_stepaction;
begin
 if queued_stepaction[0]=0 then exit;
 writelog(0,'doing queued stepaction');
 do_action(queued_stepaction[1],
	   queued_stepaction[2],
	   queued_stepaction[3],
	   queued_stepaction[4],
	   queued_stepaction[5],
	   queued_stepaction[6],
	   queued_stepaction[7],
	   queued_stepaction[8],
	   queued_stepaction[9]);
 queued_stepaction[0]:=0;
end;


function roomloc(r,x,y:byte):locpointer;
begin
 with region.room do
  roomloc:=rmcnt^[x1[r]-1+x,y1[r]-1+y];
end;

procedure actionparser(tmresult,tmspot,tmdata,room,x,y,herex,herey:byte);
var tmst:byte;
   action:byte;
   doaction:boolean;
   tmtrig:byte;
   shi:shortint;
   llp:locpointer;
   wmx,wmy:byte;

function own(owned_obj:byte):boolean;
begin
 own:=false;
 if owned_obj=1 then if ack.pcash>0 then own:=true;
 if owned_obj>1 then if ack.plvehicle=owned_obj then own:=true;
 if owned_obj>1 then if ack.pinv[owned_obj]>0 then own:=true;
end;

begin

 writelog(1,strnum(encumberance));

  if tmspot<>0 then if obj^[tmspot].t<6 then if obj^[tmspot].d[8]=3 then
   begin
    tmst:=0;
    trypassable(tmst,obj^[tmspot].d[4],obj^[tmspot].d[5]);

    if tmst<>0 then tmspot:=obj^[tmspot].d[12];
   end;
  writelog(tmdata,'Action parser, '+obj^[tmspot].n);

  bumpnoise:=true;stepnoise:=true;
  readkey_time:=R150;
  if arcade then readkey_default:=#255 else
   readkey_default:=#1;
   if doublepass then
    begin
     tmresult:=dp_tmresult;
     tmspot:=dp_tmspot;
     tmdata:=dp_tmdata;
     room:=dp_room;
     x:=dp_x;
     y:=dp_y;
     bumpnoise:=false;stepnoise:=false;
    end;
  if room=0 then
   begin
    wmx:=x;wmy:=y;
    x:=x MOD 16+1;
    y:=y MOD 16+1;
   end else
   begin
    wmx:=x;wmy:=y;
   end;
  doaction:=false;tmtrig:=obj^[tmspot].d[9];
  tmst:=obj^[tmspot].t;
  if ((tmst=1) or (tmst=2) or (tmst=5)) then
   begin
    action:=obj^[tmspot].d[2];
    if action<>0 then
    with Ack do begin
    if tmtrig=1 then doaction:=true else
     if ((tmtrig=3) and (tmresult<>99) and
      (PINV[obj^[tmspot].d[10]]>0)) then doaction:=true else
     if ((tmtrig=5) and (tmresult<>99) and
      (PINV[obj^[tmspot].d[10]]=0)) then doaction:=true else
     if ((tmtrig=4) and (tmresult<>99) and
      (PINV[obj^[tmspot].d[10]]>0)) then
      begin;doaction:=true;dec(PINV[obj^[tmspot].d[10]]);end else
    if (tmtrig=7) and (tmresult=99) then doaction:=true else
     if ((tmresult=99) and (tmtrig=8) and (own(obj^[tmspot].d[10])))
      then doaction:=true else
     if ((tmresult=99) and (tmtrig=10) and (not own(obj^[tmspot].d[10])))
      then doaction:=true else
     if ((tmresult=99) and (tmtrig=9) and (own(obj^[tmspot].d[10])))
      then begin
        doaction:=true;
        if obj^[tmspot].d[10]=1 then ack.pcash:=0
         else
         begin
          if ack.pinv[obj^[tmspot].d[10]]>0 then
           dec(ack.pinv[obj^[tmspot].d[10]])
           else ack.plvehicle:=0;
         end;


      end;


    if (tmtrig=1) then if tmresult=99 then doaction:=false;
    if tmst>5 then doaction:=false;
    if tmst<>2 then tmdata:=obj^[tmspot].d[3];
       if (herex=x) and (herey=y) then
     begin
      stepnoise:=false;
      if (action=38) or (action=21)
       or ((action=37) and (doublepass))
        then doaction:=true else doaction:=false;  { NO clue what this is supposed to do! }
     end;
    if doaction then
     if action<>21 then
      begin;do_all:=false;

      if (((tmtrig=1) or (tmtrig=3) or (tmtrig=4) or (tmtrig=5)) and (action=37)) then

       queue_stepaction(action,tmdata,0,tmresult,tmspot,tmdata,room,wmx,wmy)
        else do_action(action,tmdata,0,tmresult,tmspot,tmdata,room,wmx,wmy);



      end else
       if room<>0 then
         if locnt^[roomloc(room,x,y)].p<>0 then
          begin   {DIG}
           if not doublepass then begin;
           prepare_second_pass(tmresult,tmspot,tmdata,room,wmx,wmy);
           exit;end;
           doublepass:=false;
           llp:=locnt^[roomloc(room,x,y)].p;
           do_all:=true;
          repeat
           tmst:=obj^[locnt^[llp].obj].t;
           if tmst<6 then
           begin
            action:=obj^[locnt^[llp].obj].d[2];
            if (tmst=2) or (tmst=4) then tmdata:=locnt^[llp].objcode
             else tmdata:=obj^[locnt^[llp].obj].d[3];
            if (herex<>x) or (herey<>y) then
             do_action(action,tmdata,0,tmresult,tmspot,tmdata,room,wmx,wmy)
             else if action=38 then
              do_action(action,tmdata,0,tmresult,tmspot,tmdata,room,wmx,wmy);
           end;
           llp:=locnt^[llp].p;
          until llp=0;
          end;
         {activate all underneath}
    end;
   end else
  if (tmst<6) then
   begin
    action:=obj^[tmspot].d[2];
    if action<>0 then
    with Ack do begin
    if tmtrig=7 then doaction:=true else
     if ((tmtrig=8) and (PINV[obj^[tmspot].d[10]]>0)) then doaction:=true else
     if ((tmtrig=10) and (PINV[obj^[tmspot].d[10]]=0)) then doaction:=true else
     if ((tmtrig=9) and (PINV[obj^[tmspot].d[10]]>0)) then
      begin;doaction:=true;dec(PINV[obj^[tmspot].d[10]]);end;
    if tmst=3 then tmdata:=obj^[tmspot].d[3];
    if doaction then do_action(action,tmdata,0,tmresult,tmspot,tmdata,room,wmx,wmy);
    end;
   end;
  if tmresult=99 then
   if encumberance>3 then
    begin
     clearbottom;
     soundeffect(ack.bumpsound,1);
     bottomsay(1,'YOU ARE CARRYING TOO MUCH WEIGHT.');
     bottomsay(2,'Û1(PRESS A KEY)');
     repeat until readkey<>#0;
     readkey_time:=0;
     readkey_default:='D';
    end else
   begin
    if block_message<>0 then shortmessage(block_message) else
     begin
      if (ack.bumpsound<>0) and (bumpnoise) then soundeffect(ack.bumpsound,1);

      {clearbottom;
      bottomsay(0,'BLOCKED.');erasebottom:=4;}
      delay2(300);clear_keyboard_buffer;

     end;


   end;
  if tmresult<99 then
    if (ack.stepsound<>0) and (stepnoise) then soundeffect(ack.stepsound,1);

  if doaction then
   begin
   writelog(0,'End action parser: true, '
    +strnum(action)+', '
    +strnum(tmdata)+', '
    +strnum(tmresult)+', '
    +strnum(tmspot));
	  if readkey_default=#1 then
	   begin
        readkey_time:=0;
        readkey_default:=#255	
	   end;	
   end	else
   writelog(0,'End action parser: false, '
    +strnum(action)+', '
    +strnum(tmdata)+', '
    +strnum(tmresult)+', '
    +strnum(tmspot));
end;


procedure trypassable(var result:byte;p,pp:byte);
 var ppp:byte;
     needed:boolean;
begin
 p:=p AND 63;
 needed:=false;
 if Ack.PLvehicle<>0 then
  if obj^[Ack.PLvehicle].d[3]=1 then needed:=true;
 if (p=1) and (not needed) then exit else
  case p of
   0:result:=99;
   2:begin
      if pp=1 then ppp:=Ack.PCASH else ppp:=ack.PINV[pp];
      if pp<>0 then
       if (pp=Ack.PLvehicle) or ((obj^[Ack.PLvehicle].d[2]=pp) and (pp<>0))
        then begin;ppp:=1;needed:=false;end;
      if ppp=0 then result:=99;
     end;
   3:if pp<>1 then
   begin;if ack.PINV[pp]>0 then dec(ack.PINV[pp]) else result:=99;end
   else if pp=1 then begin;if ack.PCASH>0 then dec(ack.PCASH) else
   result:=99;end;
   4:begin
      if pp=1 then ppp:=Ack.PCASH else ppp:=ack.PINV[pp];
      if pp<>0 then
       if (pp=Ack.PLvehicle) or ((obj^[Ack.PLvehicle].d[2]=pp) and (pp<>0))
        then begin;ppp:=1;needed:=false;end;
      if ppp<>0 then result:=99;
     end;
   5:if pp>1 then
      begin
       for ppp:=2 to 254 do
        if (ack.PINV[ppp]<>0) and (obj^[ppp].t=pp) then result:=99;
       if ack.plvehicle<>0 then
        if pp=10 then result:=99;
      end else if ack.PCASH<>0 then result:=99;
   6:if Ack.strength[0]<=pp then result:=99;
   7:if ack.variables[1]<=pp then result:=99;
   8:if ack.variables[1]<>pp then result:=99;
   9:if ack.variables[1]>=pp then result:=99;
   10:if ack.variables[2]<=pp then result:=99;
   11:if ack.variables[2]<>pp then result:=99;
   12:if ack.variables[2]>=pp then result:=99;
   13:if ack.variables[3]<=pp then result:=99;
   14:if ack.variables[3]<>pp then result:=99;
   15:if ack.variables[3]>=pp then result:=99;
   16:if ack.variables[4]<=pp then result:=99;
   17:if ack.variables[4]<>pp then result:=99;
   18:if ack.variables[4]>=pp then result:=99;
   19:if ack.mp[0]<pp then result:=99 else
       dec(ack.mp[0],pp);
   20:if encumberance<>0 then needed:=true;
   22:if (ack.hour>=6) and (ack.hour<=18) then result:=99; {night only}
   21:if (ack.hour<6) or (ack.hour>18) then result:=99; {day only}
   23:needed:=false;
   24,25:if (pp>0) and (pp<53) then
      begin
      if pp>26 then
       begin
	    {var2}
		ppp:=ack.variables2[pp-26];
		if pp>7 then if ack.variables2hi[pp-26]>0 then ppp:=255;
	   end else
	  begin
	   {variable}
	   	ppp:=ack.variables[pp];
		if pp>7 then if ack.variableshi[pp]>0 then ppp:=255;
	
	  end;
	   if p=24 then {var is zero}
	    if ppp<>0 then result:=99;
	   if p=25 then {var is not zero}
	    if ppp=0 then result:=99;
		
	
	  end else result:=99;
  end;

  if needed then result:=99;

end;



{ graphHP was here }



(*
procedure regenerate;
begin
 if (ack.hp[0]=ack.hpmax[0]) and (ack.mp[0]=ack.mpmax[0]) then exit;
 if ack.hp[0]>ack.hpmax[0] then dec(ack.hp[0])
  else if (ack.regen_hp<>0) and
   (random(1024)<ack.strength[0]) and (ack.hp[0]<ack.hpmax[0]) then
   inc(ack.hp[0]);
 if ack.mp[0]>ack.mpmax[0] then dec(ack.mp[0])
  else if (ack.regen_mp<>0) and
   (random(1024)<ack.intelligence[0]) and (ack.mp[0]<ack.mpmax[0]) then
   inc(ack.mp[0]);
end;

*)





procedure erset(showtime:boolean); {Show menu. Shouldn't be called Erset. :-}


var i:byte;
procedure menusay(s:string);
begin
 say(66,i,1,s);
 say(66,i,4,s[1]);
 i:=i+9;
end;




begin


 {progresses through 0,1 or 16,17,18}
 case ack.showmenu of
  1,17:begin
     {show nothing.}
     menuskinbmp;
    end;

  16,0:begin {0,18}
     if ack.hpmax[0]>1 then say(66,140,1,'HP:');
     if ack.mpmax[0]>0 then say(66,149,1,'MP:');

     i:=11;

     if (ack.rweapskill[0]<>0) or (ack.weapskill[0]<>0) then menusay('ATTACK') else i:=i+9;
     if (ack.splituse<>0) then if ack.mpmax[0]>0 then menusay('CAST');

     menusay('LOOK');
     menusay('TALK');
     menusay('GET');
     menusay('USE');
     if (ack.splituse<>0) then menusay('READY');
     menusay('DROP');
     menusay('BOARD');
     menusay('X:EXIT');
     menusay('INFO');

     {x92, x101, x110, x119, t128, h137, m146, s155, q164}

     say(66,160,4,'ƒ„SÛ1AVE');
     say(66,169,4,'ƒ„QÛ1UIT');
    end;
  end; {case}
 oldtimepic:=99;
 if showtime then showtimepic;

   for i:=1 to 12 do
    if ack.qtile[i]<>0 then
     quartertile(i,ack.qtile[i]);

end;



var lastdiagmouse:byte; {1:NS 0:EW}


function timed_readkey(var j2:char):char;
 var h,m,s,s1:word;
     timenow,timetostop:longint;
     j:char;
     xmoub0,xmoub1,xmoub2,xmoub3,
     ymoub0,ymoub1,ymoub2,ymoub3:byte;
     roomwide,roomtall:Byte;
	 str1,str2:string;
	
procedure cursor(b:byte);
var i:byte;
begin
 for i:=0 to 7 do
  mem[scrnl:(5)+scrnh[i+188]]:=b;

end;	
	
	
begin

if not disable_music then
begin {music is enabled}
 if lastaggro=255 then begin;stopmusic;ack.music:=region.room.wallgrap[5];lastaggro:=0;end;

 if (aggro<>0) and (lastaggro=0) then
  if region.room.wallgrap[6]<>region.room.wallgrap[5] then
   begin
    clear_keyboard_buffer;
    stopmusic;
    if ack.music<>region.room.wallgrap[6] then stopmusic;
    ack.music:=region.room.wallgrap[6];
   end;

 if (aggro=0) and (lastaggro<>0) then
  if region.room.wallgrap[6]<>region.room.wallgrap[5] then
   begin
    stopmusic;
    if ack.music<>region.room.wallgrap[5] then stopmusic;
    ack.music:=region.room.wallgrap[5];
   end;

 if (aggro=0) and (lastaggro=0) then
  begin
   if ack.music<>region.room.wallgrap[5] then stopmusic;
   ack.music:=region.room.wallgrap[5];
  end;

 {this was moved out of the while-loop because smix handles looping now}
 if ack.music<>0 then
  if musicstatus=0 then soundeffect(ack.music,2);
end; {music is enabled}



 lastaggro:=aggro;
 j2:=#0;
 if not keybuffer then clear_keyboard_buffer;
 {gettime(h,m,s,s1); if h<starth then h:=h+24; h:=h-starth;

 timetostop:=(readkey_time DIV 10)+(s1 DIV 10)+(s*10)+(m*600)+(h*36000);}
 timetostop:=supergetclock+readkey_time;
 timenow:=0;
 if mouseon then trackmouse;
 while (not keypressed) and (not(mouseon and mouseLB)) and
   (timetostop>timenow) do
 begin
  if (s MOD 2)=1 then cursor(hi(TEXTC1)) else cursor(lo(TEXTC1));

  if mouseon then trackmouse;

  timenow:=supergetclock;
  if timenow+readkey_time<timetostop then timenow:=timetostop;
  if timenow+(ack.anim_speed*10)<nextanim then timenow:=nextanim;
 { str(timenow,str1);
  str(nextanim,str2);
  writelog(111,str1+'  '+str2);}
  if animate then if timenow>=nextanim then begin; {writelog(222,'----------Animate'); }animation;end;
 end;
 if ((keypressed) or (mouseon and mouseLB)) and (readkey_time<>0) then
  begin {if anything}
   if (mouseon and mouseLB) then
    begin {if mouseLB}
     if ((mousex DIV 8) > 65) and ((mousex DIV 8) < 78) then
      begin {bcase}
{       if ack.showmenu<>0 then }

       if ack.splituse=0 then {no C or R}
        case mousey of
        11..19:j:='A';
        20..28:j:='L';
        29..37:j:='T';
        38..46:j:='G';
        47..55:j:='U';
        56..64:j:='D';
        65..73:j:='B';
        74..82:j:='X';
        83..91:j:='I';
        92..100:if ack.extracommand1<>0 then j:=ack.extracommand[2];
        101..109:if ack.extracommand2<>0 then j:=ack.extracommand[3];
        110..118:if ack.extracommand3<>0 then j:=ack.extracommand[4];
        119..127:if ack.extracommand4<>0 then j:=ack.extracommand[5];
        160..168:begin;j:=#0;j2:=#31;end;
        169..177:begin;j:=#0;j2:=#16;end;
        else j:=' ';
       end else {case}
        case mousey of {yes C and R}
        11..19:j:='A';
        20..28:j:='C';
        29..37:j:='L';
        38..46:j:='T';
        47..55:j:='G';
        56..64:j:='U';
        65..73:j:='R';
        74..82:j:='D';
        83..91:j:='B';
        92..100:j:='X';
        101..109:j:='I';
        110..118:if ack.extracommand1<>0 then j:=ack.extracommand[2];
        119..127:if ack.extracommand2<>0 then j:=ack.extracommand[3];
        128..137:if ack.extracommand3<>0 then j:=ack.extracommand[4];

        160..168:begin;j:=#0;j2:=#31;end;
        169..177:begin;j:=#0;j2:=#16;end;
        else j:=' ';
       end;


      end else {bcase}
      begin {mouse hot}
       {check to see if mouse is in any other hot-spot}
       j:=' '; {just in case it isn't}

       if region.rooms > 99 then
        begin {worldmap}
         {check using worldmap screen}
         xmoub0:=11;
         ymoub0:=18;
         xmoub1:=29;
         ymoub1:=76;
         xmoub2:=37;
         ymoub2:=104;
         xmoub3:=54;
         ymoub3:=161;

       end {worldmap} else
        begin {roommap}

        with region.room do
        begin
         roomwide:=x2[global_room]-x1[global_room]+1;
         roomtall:=y2[global_room]-y1[global_room]+1;
        end;

        xmoub1:=(global_xloc*4-3 +(32-(roomwide*2)))  -2;
        ymoub1:=(global_yloc*16-14 +(88-(roomtall*8)))  -8;

        xmoub2:=xmoub1+3  +2;
        ymoub2:=ymoub1+15  +8;

        xmoub0:=(1*4-3 +(32-(roomwide*2)));
        ymoub0:=(1*16-14 +(88-(roomtall*8)));

        xmoub3:=(roomwide*4-3 +(32-(roomwide*2)))+3;
        ymoub3:=(roomtall*16-14 +(88-(roomtall*8)))+15;

         {check using room-map screen}
        end; {room map}

         if mousein(xmoub1,ymoub0,xmoub2,ymoub1) then begin;j:=#0;j2:='H';end {north}
         else if mousein(xmoub1,ymoub2,xmoub2,ymoub3) then begin;j:=#0;j2:='P';end {south}
         else if mousein(xmoub0,ymoub1,xmoub1,ymoub2) then begin;j:=#0;j2:='K';end {west}
         else if mousein(xmoub2,ymoub1,xmoub3,ymoub2) then begin;j:=#0;j2:='M';end {east}
         else if mousein(xmoub0,ymoub0,xmoub1,ymoub1) then
          begin {NW}
           if (lastdiagmouse AND 1)=1 then begin;j:=#0;j2:='H';end
            else begin;j:=#0;j2:='K';end;
           lastdiagmouse:=lastdiagmouse XOR 1;
          end {NW}
         else if mousein(xmoub2,ymoub0,xmoub3,ymoub1) then
          begin {NE}
           if (lastdiagmouse AND 1)=1 then begin;j:=#0;j2:='H';end
            else begin;j:=#0;j2:='M';end;
           lastdiagmouse:=lastdiagmouse XOR 1;
          end {NE}
         else if mousein(xmoub0,ymoub2,xmoub1,ymoub3) then
          begin {SW}
           if (lastdiagmouse AND 1)=1 then begin;j:=#0;j2:='P';end
            else begin;j:=#0;j2:='K';end;
           lastdiagmouse:=lastdiagmouse XOR 1;
          end {SW}
         else if mousein(xmoub2,ymoub2,xmoub3,ymoub3) then
          begin {SE}
           if (lastdiagmouse AND 1)=1 then begin;j:=#0;j2:='P';end
            else begin;j:=#0;j2:='M';end;
           lastdiagmouse:=lastdiagmouse XOR 1;
          end; {SE}



      end; {mouse hot}
    end {if mouseLB} else j:=readkey;
   if j=#0 then if j2=#0 then j2:=readkey;
   timed_readkey:=j;
   cursor(lo(TEXTC0));
  end {if anything} else begin
   {when it wiggs out, it DOES hit this many many times}
   timed_readkey:=readkey_default;
   j2:=readkey_0default;
   end;

  if (j=#0) and (j2=#59) then
   begin
    help;
    j2:=#0;
   end;
end;


function promptverify(s:string):boolean;
 var j:char;
begin
 clearbottom;
 bottomsay(2,s);
 repeat
  j:=upcase(readkey);
 until (j='Y') or (j='N');
 if j='Y' then promptverify:=true else promptverify:=false;
 clearbottom;
end;

procedure getadjacentlocation(var xmod,ymod:integer;galprompt:string;otherkey:boolean);
 var done:boolean;
     discard:boolean;
	 destroy:boolean;
     j,j2:char;
     xmoub0,xmoub1,xmoub2,xmoub3,ymoub0,ymoub1,ymoub2,ymoub3:byte;
     roomwide,roomtall:byte;
     go:boolean;
begin
 if xmod>97 then discard:=true else discard:=false;
 clearbottom;
 bottomsay(1,galprompt);
 if otherkey then galprompt:=', OR [ENTER]' else galprompt:='.';
 if discard then galprompt:=', OR [D] TO DESTROY.';
 if xmod=98 then bottomsay(2,'Û1CAN''T DROP HERE! PRESS [D] TO DESTROY')
   else bottomsay(2,'Û1PRESS AN ARROW KEY'+galprompt);
 if xmod=98 then destroy:=true else destroy:=false;
 done:=false;
 xmod:=0;ymod:=0;
 repeat
  go:=false;
  repeat

   trackmouse; if mouseLB then go:=true;

   if keypressed then
   begin
    j:=readkey;
    go:=true;
    if j=#0 then j2:=readkey;
   end;

  until go;

   if mouseon then

    begin

       {check to see if mouse is in any other hot-spot}

       if region.rooms > 99 then
        begin {worldmap}
         {check using worldmap screen}
         xmoub0:=11;
         ymoub0:=18;
         xmoub1:=29;
         ymoub1:=76;
         xmoub2:=37;
         ymoub2:=104;
         xmoub3:=54;
         ymoub3:=161;

       end {worldmap} else
        begin {roommap}

        with region.room do
        begin {with r.r}
         roomwide:=x2[global_room]-x1[global_room]+1;
         roomtall:=y2[global_room]-y1[global_room]+1;
        end; {with r.r}

        xmoub1:=(global_xloc*4-3 +(32-(roomwide*2)))  -2;
        ymoub1:=(global_yloc*16-14 +(88-(roomtall*8)))  -8;

        xmoub2:=xmoub1+3  +2;
        ymoub2:=ymoub1+15  +8;

        xmoub0:=(1*4-3 +(32-(roomwide*2)));
        ymoub0:=(1*16-14 +(88-(roomtall*8)));

        xmoub3:=(roomwide*4-3 +(32-(roomwide*2)))+3;
        ymoub3:=(roomtall*16-14 +(88-(roomtall*8)))+15;

         {check using room-map screen}
        end; {roommap}

   if mousein(xmoub1,ymoub0,xmoub2,ymoub1) then begin;j:=#0;j2:='H';end {north}
   else if mousein(xmoub1,ymoub2,xmoub2,ymoub3) then begin;j:=#0;j2:='P';end {south}
   else if mousein(xmoub0,ymoub1,xmoub1,ymoub2) then begin;j:=#0;j2:='K';end {west}
   else if mousein(xmoub2,ymoub1,xmoub3,ymoub2) then begin;j:=#0;j2:='M';end; {east}
  end; {if mouseon}

 case j of
  #0:case j2 of
   'H':if not destroy then begin;ymod:=-1;done:=true;end;
   'K':if not destroy then begin;xmod:=-1;done:=true;end;
   'M':if not destroy then begin;xmod:=1;done:=true;end;
   'P':if not destroy then begin;ymod:=1;done:=true;end;
  end;
  #27:begin;ymod:=99;done:=true;end;
  #13:if otherkey then done:=true;
  'D','d':if discard then begin;xmod:=99;done:=true;end;
  end;
 until done;
 clearbottom;

 trackmouse;
 mouseLB:=false;
 mouseRB:=false;

end;


procedure scrollsay(s:string);
var lines,y:byte; p:byte;
begin
 for lines:=1 to 8 do
 begin
  for y:=1 to 100 do p:=y;
  for y:=2 to 17 do
   move(mem[scrnl:scrnh[180+y]+4],mem[scrnl:scrnh[180+y-1]+4],314);

   fillchar(mem[scrnl:scrnh[180+y]+4],314,lo(TEXTC0));
   p:=pos(s,'  ');
   if p<>0 then delete(s,p,1);
 end;

 repeat
   p:=pos('  ',s);
   if p<>0 then delete(s,p,1);
 until p=0;

 say(2,188,0,s);

end;



function sharedcommand(j:char):boolean;
 var i,i1:integer;
     acting:boolean;
     w:word;
     r,rm:byte;x,y:word;
begin
 sharedcommand:=false;
 case j of
  '~':if transparency then scrollsay('TRANSPARENCY MASK: '+strnum(tmask)) else scrollsay('TRANSPARENCY IS OFF');

  '-':if combatpacing<200 then
       begin
	    combatpacing:=combatpacing+10;
		scrollsay('COMBAT MESSAGE SPEED DECREASED ('+strnum((200-combatpacing) DIV 10)+')');
	   end;
  '+':if combatpacing>0 then
       begin
	    combatpacing:=combatpacing-10;
		scrollsay('COMBAT MESSAGE SPEED INCREASED ('+strnum((200-combatpacing) DIV 10)+')');
	   end;	
  #6:if ack.cheat=123 then {control-f}
     begin
      ack.fly:=not (ack.fly);
	  if ack.fly then scrollsay('FLIGHT MODE ON') else scrollsay('FLIGHT MODE OFF');
	  sharedcommand:=true;
	 end;
  #7:scrollsay(strnum(XMSGetFreeMem));	 {control-G}

  #2:begin {control-b}
      keybuffer:=not (keybuffer);
      if keybuffer then scrollsay('KEY BUFFER IS NOW ON') else
       scrollsay('KEY BUFFER IS NOW OFF');



     end;
  #24:if ack.cheat=123 then begin {control-x}
        {run a macro}
         clearbottom;
         bottomsay(1,'MACRO TROUBLESHOOTING');
         bottomsay(2,'Û1  RUN:');
         val(readlin(17,188,3,1),i,i1);
         clearbottom;
         if i>255 then i:=0;
         if (i1=0) and (i<>0) then do_action(37,i,1,0,0,0,0,0,0);
       end;
  #8:if ack.cheat>98 then begin {control-h}
          ack.hp:=ack.hpmax; ack.mp:=ack.mpmax; graphhp;

         end;
  #26:if ack.cheat>98 then
       begin;scrollsay('GOING INVISIBLE...');ack.invisible:=255;end;
  #23:if ack.cheat=123 then begin {control-w}
          bottomsay(1,'WARP TO LOCATION');
         bottomsay(2,'Û1  REGION:');
         val(readlin(22,188,3,1),i,i1);
         if i<>0 then
          begin
           r:=i;

           bottomsay(2,'Û1    ROOM:');
           val(readlin(22,188,3,1),i,i1);
           rm:=i;
           bottomsay(2,'Û1      X:');
           val(readlin(20,188,4,1),i,i1);
           x:=i;
           if x<>0 then
            begin
             bottomsay(2,'Û1      Y:');
             val(readlin(20,188,4,1),i,i1);
             y:=i;
              if y<>0 then
                begin
                 macro_teleport:=true;
     global_region:=r;
     global_room:=rm;
     global_xloc:=(x-1) MOD 16 +1;
     global_yloc:=(y-1) MOD 16 +1;
           global_xchunk:=(x-1) DIV 16 +1;
           global_ychunk:=(y-1) DIV 16 +1;
                end;
            end;
           end;

         end;

  #22:mutesoundmenu;  {control-v}
  #16:if ack.cheat=123 then begin {control-p}
        {set a variable}
         clearbottom;
         bottomsay(1,'VARIABLE PEEK/POKE');
         bottomsay(2,'PRESS A KEY FROM A-Z');
         i:=ord(upcase(readkey));
         if (i>64) and (i<91) then
          begin
           clearbottom;
     w:=ack.variables[i-64];
           if (i-64)>7 then w:=w+(ack.variableshi[i-64]*256);
           bottomsay(1,'VARIABLE '+chr(i)+' IS CURRENTLY: '+strnum(w)+'.');
           bottomsay(2,'SET TO:');
           val(readlin(17,188,5,1),w,i1);
           if i1=0 then
            begin
             ack.variables[i-64]:=w MOD 256;
             if (i-64)>7 then ack.variableshi[i-64]:=w DIV 256;
            end;
          end;
         clearbottom;
        end;


  #20:if ack.cheat>98 then begin {control-t}
       bottomsay(1,'DAY='+strnum(ack.days)+' HR='+strnum(ack.hour)+' MIN='+strnum(ack.minute)+
        '  PIC='+strnum(timepic));
       bottomsay(2,'CYC='+strnum(ack.time_cycle)+' RGV='+strnum(region.shadow)+' V='+strnum(ack.viewdistance)+' T='+
         strnum(ack.minviewdistance)+','+strnum(ack.torchduration));

      end;

  #12:if ack.cheat>98 then begin {control-L}
       if ack.plych>32 then
       begin
       bottomsay(1,'REGION='+strnum(ack.plregion)+' ROOM='+strnum(ack.plxch)+
	    'X='+strnum(ack.plxloc)+' Y='+strnum(ack.plyloc));
       bottomsay(2,'SETPORT FORMAT: '+strnum(ack.plregion)+' '+strnum(ack.plxch)+
	    ' '+strnum(ack.plxloc)+' '+strnum(ack.plyloc))
       end else begin
       bottomsay(1,'REGION='+strnum(ack.plregion)+' (W='+strnum(ack.plxch)+','+strnum(ack.plych)
         +':'+strnum(ack.plxloc)+','+strnum(ack.plyloc)+') '+
		 'X='+strnum((ack.plxch-1)*16+ack.plxloc)+' Y='+strnum((ack.plych-1)*16+ack.plyloc));
       bottomsay(2,'SETPORT FORMAT: '+strnum(ack.plregion)+' 0 '+
	     strnum((ack.plxch-1)*16+ack.plxloc)+' '+strnum((ack.plych-1)*16+ack.plyloc));
       end;
      end;

  'I':begin;savepage;showplayerstatus;restorepage;end;

  'U':if ack.splituse=0 then
      begin
       sharedcommand:=true;
       clearbottom;
       savepage;bottomsay(1,'SELECT ITEM OR ABILITY TO USE, OR');
                bottomsay(2,'ARMOR/WEAPONS TO EQUIP OR REMOVE');
       i:=selectinventory(199,' USE ');
       restorepage;
       if i<>0 then
        if obj^[i].t=9 then
        begin
         acting:=true;
         if obj^[i].d[4]<>0 then
          begin
           i1:=obj^[i].d[4];
           if i1=1 then if ack.PCASH<=0 then acting:=false;
           if i1>1 then if ack.PINV[i1]<=0 then acting:=false;
           if not acting then
            if obj^[i].d[8]=0 then
             bottomsay(0,'MISSING: '+obj^[i].n) else
             shortmessage(obj^[i].d[8]);
           if acting then
            if obj^[i].d[5]>random(100) then if i1=1 then
             dec(ack.PCASH) else dec(ack.PINV[i1]);
          end;
         if obj^[i].d[11]<>0 then
          begin
           if ack.mp[0]>=obj^[i].d[11] then
            dec(ack.mp[0],obj^[i].d[11]) else
            begin;acting:=false;bottomsay(0,'NOT ENOUGH ENERGY.');end;
          end;
         if acting then
          begin
           macrosuccess:=1;
           do_action(obj^[i].d[2],obj^[i].d[3],1,0,0,0,0,0,0);
           if macrosuccess>0 then
           begin
            if obj^[i].d[9]<>0 then do_action(obj^[i].d[9],obj^[i].d[10],1,0,0,0,0,0,0);
            if obj^[i].d[6]<>0 then
             if obj^[i].d[6]<>1 then dec(ack.PINV[obj^[i].d[6]]) else dec(ack.pcash);
            if obj^[i].d[7]<>0 then shortmessage(obj^[i].d[7]);
           end;
           if action_weap=23 then sharedcommand:=false;
          end else
          begin
         end;



        end
        else if obj^[i].t=6 then begin
         acting:=true;
         if obj^[i].d[4]<>0 then
          begin
           i1:=obj^[i].d[4];
           if i1=1 then if ack.PCASH<=0 then acting:=false;
           if (i1>1) and (i1<255) then if ack.PINV[i1]<=0 then acting:=false;
           if i1=255 then if ack.mp[0]<obj^[i].d[5] then acting:=false;
           if not acting then
            if obj^[i].d[8]=0 then
             bottomsay(0,'MISSING: '+obj^[i].n) else
             shortmessage(obj^[i].d[8]);
           if acting then
            if obj^[i].d[4]=255 then
             begin;dec(ack.mp[0],obj^[i].d[5]);end else
            if obj^[i].d[5]>random(100) then if i1=1 then
             dec(ack.PCASH) else dec(ack.PINV[i1]);

          end;
         if acting then
          begin
           do_action(obj^[i].d[2],obj^[i].d[3],1,0,0,0,0,0,0);
           if obj^[i].d[6]<>0 then dec(ack.PINV[i]);
           if obj^[i].d[7]<>0 then shortmessage(obj^[i].d[7]);
          end else
          begin
          end;
        end;

        clearbottom;
      end else
      begin {old use}


       sharedcommand:=true;
       clearbottom;
       savepage;bottomsay(0,'USE ITEM...');
       i:=selectinventory(196,' USE ITEM');
       restorepage;
       if i<>0 then
        begin
         acting:=true;
         if obj^[i].d[4]<>0 then
          begin
           i1:=obj^[i].d[4];
           if i1=1 then if ack.PCASH<=0 then acting:=false;
           if (i1>1) and (i1<255) then if ack.PINV[i1]<=0 then acting:=false;
           if i1=255 then if ack.mp[0]<obj^[i].d[5] then acting:=false;
           if not acting then
            if obj^[i].d[8]=0 then
             bottomsay(0,'MISSING: '+obj^[i].n) else
             shortmessage(obj^[i].d[8]);
           if acting then
            if obj^[i].d[4]=255 then
             begin;dec(ack.mp[0],obj^[i].d[5]);end else
            if obj^[i].d[5]>random(100) then if i1=1 then
             dec(ack.PCASH) else dec(ack.PINV[i1]);

          end;
         if acting then
          begin
           do_action(obj^[i].d[2],obj^[i].d[3],1,0,0,0,0,0,0);
           if obj^[i].d[6]<>0 then dec(ack.PINV[i]);
           if obj^[i].d[7]<>0 then shortmessage(obj^[i].d[7]);
          end else
          begin
          end;
        end;
        if not acting then delay2(800);clearbottom;
        if action_weap=23 then sharedcommand:=false;
      end;



  'C':if ack.splituse<>0 then begin

       sharedcommand:=true;
       clearbottom;
       savepage;bottomsay(0,'CAST SPELL...');
       i:=selectinventory(11,' SPELL/SKILL ');
       restorepage;
       if i<>0 then
        begin
         acting:=true;
         if obj^[i].d[4]<>0 then
          begin
           i1:=obj^[i].d[4];
           if i1=1 then if ack.PCASH<=0 then acting:=false;
           if i1>1 then if ack.PINV[i1]<=0 then acting:=false;
           if not acting then
            if obj^[i].d[8]=0 then
             bottomsay(0,'MISSING: '+obj^[i].n) else
             shortmessage(obj^[i].d[8]);
           if acting then
            if obj^[i].d[5]>random(100) then if i1=1 then
             dec(ack.PCASH) else dec(ack.PINV[i1]);
          end;
         if obj^[i].d[11]<>0 then
          begin
           if ack.mp[0]>=obj^[i].d[11] then
            dec(ack.mp[0],obj^[i].d[11]) else
            begin;acting:=false;bottomsay(0,'NOT ENOUGH ENERGY.');end;
          end;
         if acting then
          begin
           macrosuccess:=1;
           do_action(obj^[i].d[2],obj^[i].d[3],1,0,0,0,0,0,0);
           if macrosuccess>0 then
           begin
            if obj^[i].d[9]<>0 then do_action(obj^[i].d[9],obj^[i].d[10],1,0,0,0,0,0,0);
            if obj^[i].d[6]<>0 then
             if i<>1 then dec(ack.PINV[i]) else dec(ack.pcash);
            if obj^[i].d[7]<>0 then shortmessage(obj^[i].d[7]);
           end;

          end else
          begin
          end;



        end;
        if not acting then delay2(800);clearbottom;
        if action_weap=23 then sharedcommand:=false;
      end;



   'R':if ack.splituse<>0 then begin
       {sharedcommand:=true;}
       clearbottom;
       savepage;bottomsay(0,'READY WEAPON/ARMOR');
       i:=selectinventory(204,' READY WEAPONS/ARMOR');
       restorepage;
       if i<>0 then ack.pweapready:=i;
       clearbottom;
      end;
   #3:begin;scrollsay('S='+strnum(musicstatus)+' A='+strnum(aggro)+' M='+strnum(ack.music)+' L='+
       strnum(lastaggro)+' W='+strnum(region.room.wallgrap[5])+' C='+strnum(region.room.wallgrap[6])); end;







  end; {case}



   if ack.extracommand[1]<>#27 then
   if ack.extracommand[1]<>'&' then
  begin
   if ((j=ack.extracommand[1]) and
    (j<>#27)) then
     begin

     i:=ack.hour*60+ack.minute+(ack.days MOD 7)*24;
     run_macro(ack.extracommand1);
     if i<>(ack.hour*60+ack.minute+(ack.days MOD 7)*24) then
      sharedcommand:=true;

    end;


  end else
  begin
   if ((j=ack.extracommand[2]) and
    (j<>#27)) then
     begin

     i:=ack.hour*60+ack.minute+(ack.days MOD 7)*24;
     run_macro(ack.extracommand1);
     if i<>(ack.hour*60+ack.minute+(ack.days MOD 7)*24) then
      sharedcommand:=true;

    end;
   if ((j=ack.extracommand[3]) and
    (j<>#27)) then
     begin

     i:=ack.hour*60+ack.minute+(ack.days MOD 7)*24;
     run_macro(ack.extracommand2);
     if i<>(ack.hour*60+ack.minute+(ack.days MOD 7)*24) then
      sharedcommand:=true;

    end;
   if ((j=ack.extracommand[4]) and
    (j<>#27)) then
     begin

     i:=ack.hour*60+ack.minute+(ack.days MOD 7)*24;
     run_macro(ack.extracommand3);
     if i<>(ack.hour*60+ack.minute+(ack.days MOD 7)*24) then
      sharedcommand:=true;

    end;
   if ((j=ack.extracommand[5]) and
    (j<>#27)) then
     begin

     i:=ack.hour*60+ack.minute+(ack.days MOD 7)*24;
     run_macro(ack.extracommand4);
     if i<>(ack.hour*60+ack.minute+(ack.days MOD 7)*24) then
      sharedcommand:=true;

    end;






  end;
end;



procedure checkdropping(dropping:byte);
 var i:byte;
begin
 if dropping=ack.pweapready then
  if ack.PINV[dropping]=0 then ack.pweapready:=0;
 for i:=1 to 7 do
  if ack.parmor[i]=dropping then
   if ack.PINV[dropping]=0 then ack.parmor[i]:=0;

end;


function checkfuel:boolean;
 var fuelok:boolean;
begin
 fuelok:=true;
 if ack.plvehicle<>0 then
   begin
    if (obj^[ack.plvehicle].d[6]=1) AND (Ack.PCASH=0) then fuelok:=false;
    if (obj^[ack.plvehicle].d[6]>1) AND (obj^[ack.plvehicle].d[6]<255) AND
     (Ack.PINV[obj^[ack.plvehicle].d[6]]=0) then fuelok:=false;
    if (obj^[ack.plvehicle].d[6]=255) AND
     (ack.mp[0]<obj^[ack.plvehicle].d[7]) then fuelok:=false;
    if fuelok then
     begin
      if obj^[ack.plvehicle].d[6]=255 then
       dec(ack.mp[0],obj^[ack.plvehicle].d[7]) else
       if obj^[ack.plvehicle].d[7]>random(100) then
        if obj^[ack.plvehicle].d[6]=1 then dec(ack.PCASH) else
         if (obj^[ack.plvehicle].d[6]>1) and
          (obj^[ack.plvehicle].d[6]<255) then
           dec(ack.PINV[obj^[ack.plvehicle].d[6]]);

     end;
   end;
 checkfuel:=fuelok;
end;


procedure showweapon(weapon0t,weapon0n,aimxloc,aimyloc,wxloc,wyloc,rwide,rtall:byte);
var xxx1,yyy1,xxx2,yyy2,d:integer;
    rise,run,xstep,ystep,herex,herey:integer;
    done:boolean;
    arrowc:word;

begin
  if (wxloc>rwide) or (aimxloc>rwide) or (aimxloc<1) or (wxloc<1) then exit;
  if (wyloc>rtall) or (aimyloc>rtall) or (aimyloc<1) or (wyloc<1) then exit;

  if not sounded then
       begin;soundeffect(obj^[weapon0n].d[2],1);sounded:=true;end;

  if weapon0t=8 then case obj^[weapon0n].d[3] of
    1..240:
     begin


       putgrap(wxloc*4-3+(32-(rwide*2)),wyloc*16-14+(88-(rtall*8)),
        obj^[weapon0n].d[3]);

      end;
    242:begin
         sketchline((aimxloc*4-3+(32-(rwide*2)))*4+8,(aimyloc*16-14+(88-(rtall*8)))+8,
         (wxloc*4-3+(32-(rwide*2)))*4+8,(wyloc*16-14+(88-(rtall*8)))+8,mapcolors[weapon0n]);
	    end;
	244:begin
	    thickln2((aimxloc*4-3+(32-(rwide*2)))*4+8,(aimyloc*16-14+(88-(rtall*8)))+8,
        (wxloc*4-3+(32-(rwide*2)))*4+8,(wyloc*16-14+(88-(rtall*8)))+8,mapcolors[weapon0n],2);
       end;
    241,243:begin

     xxx1:=((aimxloc*4-3+(32-(rwide*2)))*4+8);
     yyy1:=(aimyloc*16-14+(88-(rtall*8)))+8;
     xxx2:=((wxloc*4-3+(32-(rwide*2)))*4+8);
     yyy2:=(wyloc*16-14+(88-(rtall*8)))+8;

     if obj^[weapon0n].d[3]=243 then sweepdot(xxx1,yyy1,xxx2,yyy2,combatpacing,true,mapcolors[weapon0n])
	  else sweepdot(xxx1,yyy1,xxx2,yyy2,combatpacing,false,mapcolors[weapon0n]);


    end;
   end else
    begin

    end;

end;

procedure startclock;
var h,m,s,s1:word;
begin
  gettime(h,m,s,s1);
  starth:=h;
end;

begin
  talktome:=0;
  lastaggro:=255;
  queued_stepaction[0]:=0;
  action_weap:=0;
  startclock;
end.
