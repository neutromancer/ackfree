{$M 50000,280000,640000}
uses xms,overlay,overlay2,u_sound,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,dos,u_fonts,u_graps,
       o_play0,o_play0a,o_play2,o_play1,o_play3,u_delay2;

{$O o_play3}
{$O o_play2}
{$O o_play1}
{.O o_play0}
{.O o_play0a}

var
    savedexitproc:pointer;  {for custom exit routine}

{$F+}

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

procedure CustomExit;
 var re:string;
begin
if erroraddr<>NIL then
begin
re:=concat('RUNTIME ERROR ',
            numtostr(exitcode)
           ,
            ' AT ',
            converttohex(seg(erroraddr^)),':',
            converttohex(ofs(erroraddr^)));
say(2,2,0,re);erroraddr:=nil;exitcode:=0;readln;
end;
exitproc:=savedexitproc;
end;



procedure Ack_Walk_Server;
 var old_rr,rr,xc,yc,xx,yy:byte;

begin
 swapinfo^.data[7]:=0;
 action_weap:=0;
 keybuffer:=false;
 arcade:=false;
 macroloaded:=0;
 macro_teleport:=false;
 entrancemacro:=0;
 
 pass_message:=0;block_message:=0;
 if ack.anim_speed=0 then animate:=false else animate:=true;
 nextanim:=1;anim_phase_one:=true;
 rr:=Ack.PLregion;
 xc:=Ack.PLxch;yc:=Ack.PLych;
 xx:=Ack.PLxloc;yy:=Ack.PLyloc;
 old_rr:=0;
 readkey_time:=R150;
 if arcade then readkey_default:=#255 else
  readkey_default:=#1;
 if rr=0 then
  begin
   clearscreen;
   say(1,1,0,'THE PLAYER HAS NOT BEEN PLACED');
   say(1,11,0,'ON THE MAP.  ABORTING...');
   say(1,21,1,'PRESS A KEY.');
   repeat until readkey<>#0;
   halt;
  end;
repeat
 if brandnewgame then
  begin
   run_macro(ack.hourmacro);
   brandnewgame:=false;
   saveconfig;
   fullgamesave;

  end;
 if rr<>0 then
 begin
  if old_rr<>rr then
   begin
    lastaggro:=255;
    if old_rr<>0 then
      begin
        
        ack.criminal:=0;
        loadmap(rr);
        old_rr:=rr;
        case region.shadow of
         0,255:ack.viewdistance:=17;
		 1:if ack.time_cycle=0 then ack.viewdistance:=17 else cycletime;
         2..21:ack.viewdistance:=region.shadow - 1;

        end;
        entrancemacro:=region.room.wallgrap[3];   {new entrance macro: wallgrap 3}
        oldtimepic:=99;

      end else
      begin
	    entrancemacro:=0;
        loadmap(rr);
        case region.shadow of
         0,255:ack.viewdistance:=17;
         2..21:ack.viewdistance:=region.shadow - 1;
         1:if ack.time_cycle<>0 then cycletime;
         end;
         old_rr:=rr;
         oldtimepic:=99;
      end;
   end;
  initmouse;
 { stopmusic;}
  if region.rooms>20 then
     begin

      walkworldmap(rr,xc,yc,xx,yy)
     end
   else if region.rooms>0 then
    begin
     walkroom(rr,xc,yc,xx,yy);
     if rr<>old_rr then savemap;
    end;
 end;
newwmapload:=true;

until rr=0;
 saveconfig;
end;


{$I PTR_PORT.PAS}

var p4ts:^swapinfo_rec absolute f4b;

procedure prerender_dark(dark,back:byte);
var g,x,y:byte;
begin
 for g:=0 to 240 do
  for x:=1 to 16 do for y:=1 to 16 do
  if graphic^[g,x,y]=back then graphicdark^[g,x,y]:=back
   else graphicdark^[g,x,y]:=dark;

end;


procedure Ack_Main;
begin

 key_report:=false;
 for i:=1 to 99 do modified[i]:=false;

 if ovrresult<>0 then if ovrresult<>-5 then
  writeln('Overlay error: ',ovrresult);
 barcolor:=0;
 savedexitproc:=exitproc;   {Set up for custom exit routine}
 exitproc:=@CustomExit;
{ getmem2(pointer(wbuffer),sizeof(windowbuffertype));}
 getmem2(pointer(rmcnt), 6400);
 getmem2(pointer(graphic2), (GRAPS+1)*256 );
 getmem2(pointer(graphicdark), (GRAPS+1)*256 );
{ getmem2(pointer(bank1),64000); }
 getmem2(pointer(screenstrip),6400);
 getmem2(pointer(locnt), LOCNTMAX * sizeof(loccontrec));
 getmem2(pointer(obj), (MAXOBJS+2) * sizeof(objectrec));
 getmem2(pointer(wander_index), (WANDERMAX+1) * sizeof(wander_record));
 getmem2(pointer(rcrc), (RCMAX+1) * sizeof(rregioncreature)); 
  obj^[0].d[1]:=0; obj^[0].t:=1; {this used to be 255, going to try it as 1}
  xinloc:=255;
  obj^[xinloc].t:=3;
  obj^[xinloc].d[4]:=0;
  obj^[xinloc].d[2]:=0;
  obj^[xinloc].d[7]:=0;
  obj^[xinloc].d[9]:=0;
  obj^[xinloc].d[11]:=0;
  obj^[xinloc].d[8]:=0;
 getmem2(pointer(crc), MAXCRCS * sizeof(creaturerec));
 getmem2(pointer(talk), 1001 * sizeof (talkrec) );
 getmem2(pointer(macro), 102 * sizeof (macrorec) );
 getmem2(pointer(bmptemp), 65080);

 if copy(paramstr(4),1,2)<>'CH' then begin;
   writeln('ACK v',(ACKVERSION DIV 10),'.',(ACKVERSION MOD 10),
    ' program file.');
   for i:=0 to paramcount do writeln(paramstr(i));writeln;readln;halt;end;

 usepointers;
 byte4(copy(paramstr(4),3,length(paramstr(4))-2),f4b);
 swapinfo:=@p4ts^;

 ss:=paramstr(1);
 i:=pos('*',ss);
 if ss[1]<>'.' then disablemouse:=true;

 ADVNAME:=copy(ss,i+1,length(ss)-i);
 bgi_dir:=copy(ss,2,i-2);
 calibratedelay(bgi_dir+'\SPEED.DAT');
 
 loadconfig;

 case ack.hour of
  6..9:timephase:=3;
  19..22:timephase:=4;
 end;
 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
  blank0(ack.darkbackground);
 doublepass:=false;
 helpindex:=2;
 u_graph_setup;

 graphicsmode;
 (* initgraph; {shouldn't need this! } *)
 
 
 check_requiredfiles;
 
 loadcreatures;loadobjs;

 loadgraps2(true);
 
 preparemask;
 initmouse;

 if swapinfo^.data[3]=1 then
  begin
   startupgraph;
   loadbmppalette(ack.ackversion,ADVNAME,bgi_dir);
   initmouse;
  end;

 if swapinfo^.data[1]=1 then titlebars;

 helpfile:=bgi_dir+'\ACKDATA1.HLP';
 if swapinfo^.data[1]=1 then
  if swapinfo^.data[7]>0 then
   begin

    run_macro(swapinfo^.data[6]);
    swapinfo^.data[1]:=0;
    startup_sequence;

    ack_walk_server;
    halt;
    {back into title-screen stream}
   end else
  begin
   MASTERFILE:=TEMPMASTERFILE;
   MAPAFILE:='.1';
   MAPBFILE:='.2';
   MAPCFILE:='.3';
   REGIONFILE:='.RGT';


   loadconfig;
   loadmap(ack.PLregion);
   if region.rooms>250 then loadwmap;
   run_macro(swapinfo^.data[6]);
   swapinfo^.data[1]:=0;
   Ack_Walk_Server;
   halt;
  end;

 starting_up_clearscreen:=true;

 loadconfig;
(* assign(printer,'PRN');
 {$I-} rewrite(printer); {$I+} *)

 startup_sequence;
 oldhour:=ack.hour;

 prerender_dark(ack.darkforeground,ack.darkbackground);
 
 
 Ack_Walk_Server;
end;




begin
{ ovrinit('ACK02.OVR');}
 starting_up_clearscreen:=false;
 allowmix;
 ack_main;
end.