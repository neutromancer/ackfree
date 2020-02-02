{$O+}
{$F+}
unit o_play0;

{This unit contains just about everything that should always be in memory.}
{NOT an overlay, but it's closely related to them.}

interface

uses u_sound,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,dos,u_fonts,u_graps,u_delay2;

const BLANK='                                       '; {39 chars}
      R150=1000;
	  DECOGRP=244;

type
    {windowbuffertype=array[1..176,1..64] of byte;}
   {  screenbank=array[1..64000] of byte; }
     screenstriparray=array[1..20,1..320] of byte;

     swapinfo_rec = record
      execfile:string[12];
      execparam:string[40];
      data:array[1..10] of byte; {@}
     end;
     bmpimage=array[0..0] of byte;
	
var
    bmptemp:^bmpimage;
    entrancemacro:byte;
	starth:byte;
    lastmov:byte;
    bmpskinname:string[12];
    thisportal:byte;
    oldhour:byte;
    aggro:byte;
	resurrect:boolean;
    macrosuccess:byte;
    oops_i_missed,newwmapload,brandnewgame:boolean;
    starting_up_clearscreen:boolean;
    swapinfo:^swapinfo_rec;
    modified:array[1..99] of boolean;
    next_queued_action,queued_actions:byte;
    queued_action:array[1..16,1..2] of byte;
    encumberance:byte;
    arcade:boolean;
    crc:^crcarray;
    {wbuffer:^windowbuffertype;}
    printer:text;
    a_weap_org_x,a_weap_org_y,action_weap,a_weap_type:byte;
    timestepsec:byte;
    timephase:byte;
    oldtimepic,timepic:byte;
	teleport_room:byte;
  {  qtile:array[1..12] of word; }

var pal1:array[0..255,0..2] of byte;
{    dpal:array[0..255,0..2] of byte; }


{$I I_MSTREC.PAS}
{$I I_CRCREC.PAS}
{$I I_WANDC1.PAS}

var i,i1:integer;
  {  bank1:^screenbank; }
    screenstrip:^screenstriparray;
    s,ss:string;
    quittime:boolean;
    curricon:byte;
    erasebottom:byte;
    readkey_time:word;
    readkey_default:char;
    readkey_0default:char;
    pass_message,block_message:byte;
    creaturemoved:array[1..RCMAX] of byte;
    sounded:boolean;
    keybuffer:boolean;
    nextanim: longint;
var doublepass:boolean;  {should it put off parsing until character moves?}
    dp_tmresult,dp_tmspot,dp_tmdata,dp_room,dp_x,dp_y:byte;
    do_all,bumpnoise,stepnoise:boolean;
    macroloaded:byte;


const
      LOCNTMAX=6400;
      OOPS=10;


type chunkprec = array[1..3,1..3] of byte;
     locrec = record
         o,d:byte;
         end;
     chunkrec = array[1..16,1..16] of locrec;

type vehrec = array[1..255] of
       record
       obj,objcode:byte;
       xchunk,ychunk:byte;
       used:boolean;
       howmany:byte;
       end;

var xinloc,yinloc:byte;
    xchunkloc,ychunkloc:integer;
    macro_teleport:boolean;
    global_xloc,global_yloc,global_xchunk,global_ychunk,
     global_room,global_region:byte;
    veh:vehrec;
    Ack:masterrec;
    thisregion:byte;
    chunk:chunkprec;
    gotolocation,chunksave:boolean;
    locntsize:word;
    roomwide,roomtall:byte;
    map:array[1..3,1..3] of chunkrec;
    mapcolors:array[0..255] of byte;

    type anim_rec = record
          t1,t2,t3,t4:byte;
          tb4,tb:boolean;
          lit:byte;
		  under:byte;
		  aggro:boolean;

         end;

var animate:boolean;
    anim_screen:array[0..17,0..12] of anim_rec;
    anim_wide,anim_tall:byte;

    anim_phase_one:boolean;
    key_report:boolean;

type
   macrorec = record
      cmd:byte;
      data:Array[1..6,1..3] of byte;
      next:word;
     end;
   macroarray=array[0..0] of macrorec;

var
    macro:^macroarray;

procedure flopitem(wxloc,wyloc,inv,invn:byte);	
procedure show_shortmsg;
procedure showmosaic;
function loadmosaic(n:byte):boolean;
procedure load_longmsgfile(mn:byte);
procedure show_longmsg;
procedure longmessage(n:byte);
procedure shortmessage(n:byte);
procedure writelog(n:integer; s:string);

procedure writelog2(n1,n2,n3,n4:word;n5,n6,n7:longint);

procedure calculate_weight;
{from i_msgply}
procedure clear_keyboard_buffer;

procedure bottomsay(y:byte;s:string);
procedure clearbottom;
procedure waitkey;
procedure adjacent_error;
procedure showbmp(n:word;transp:boolean);
procedure picturemessage(n:word);

{end i_msgply}
procedure soundeffect(snd:word; channel:byte);
procedure graphHP;
procedure playerdeath;
{from i_ply2:}
function distance(x1,y1,x2,y2:integer):byte;
  {from i_ply3:}
procedure loadconfig;
procedure saveconfig;
procedure loadcreatures;
procedure loadobjs;
procedure savestrip;
procedure restorestrip;
procedure savepage;
procedure restorepage;
procedure titlebars;
procedure showplayerstatus;
procedure boxx(x1,y1,x2,y2:byte);
procedure savewmap;
procedure loadwmap;
procedure savemap;
procedure loadmap(n:byte);
 {end i_ply3}
 {from i_ply1:}
function selectinventory(cats:byte;comment:string):byte;
procedure animation;
procedure anim_toggle;
procedure run_macro(n:byte);

procedure bytecopy(fn1,fn2:string);
function bytecopybunch(ext,newext:char):word;
function countfiles(ext:string2):word;
procedure deletebunch(ext:string4);
procedure fullgamesave;
procedure cycletime;
procedure menuskinbmp;
procedure showtimepic;
procedure mutesoundmenu;
procedure levelup;
procedure passtime(settimestep:byte);

implementation

var starting_h:byte;

procedure flopitem(wxloc,wyloc,inv,invn:byte);
var dropcount:integer;
       begin
          {drop items}
         dropcount:=1;
         repeat
          if (veh[dropcount].used) then inc(dropcount) else inc(dropcount,1000);
         until dropcount>255;
         if dropcount>300 then
          begin
           {write item}
           dec(dropcount,1000);
           veh[dropcount].used:=true;
           veh[dropcount].obj:=
           map[wxloc DIV 16+1,wyloc DIV 16+1,
            wxloc MOD 16+1,wyloc MOD 16+1].o;
           veh[dropcount].objcode:=
           map[wxloc DIV 16+1,wyloc DIV 16+1,
            wxloc MOD 16+1,wyloc MOD 16+1].d;
           veh[dropcount].howmany:=invn;
           veh[dropcount].xchunk:=xchunkloc+(wxloc DIV 16)-1;
           veh[dropcount].ychunk:=ychunkloc+(wyloc DIV 16)-1;
           map[wxloc DIV 16+1,wyloc DIV 16+1,
            wxloc MOD 16+1,wyloc MOD 16+1].o:=inv;
           map[wxloc DIV 16+1,wyloc DIV 16+1,
            wxloc MOD 16+1,wyloc MOD 16+1].d:=dropcount;
          end;
		
		
	     writelog(dropcount,'flopitem: '+strnum(invn)+' of '+strnum(inv)+' at '+strnum(wxloc)+','+strnum(wyloc));
		
        end;




procedure loadmapcolors;
var cf:file of byte;
    i:byte;
begin
 assign(cf,ADVNAME+'.MCO');
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then
  begin
   for i:=0 to 255 do mapcolors[i]:=i;
  end else
  begin
   for i:=0 to 255 do read(cf,mapcolors[i]);
   close(cf);
  end;
end;




procedure show_shortmsg;
var i:integer;
begin
{ thickln(261,170,262,190,0);}
 drawh(10,170,309,lo(TEXTC0));
 drawh(10,189,309,lo(TEXTC0));

 drawv(10,170,189,lo(TEXTC0));
 drawv(309,170,189,lo(TEXTC0));

 drawh(11,171,308,hi(TEXTC0));
 drawh(11,188,308,hi(TEXTC0));

 drawv(11,171,188,hi(TEXTC0));
 drawv(308,171,188,hi(TEXTC0));

 for i:=1 to 37 do
   begin
   putletter(i*2+1,171,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
   putletter(i*2+1,179,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
  end;
end;


procedure showmosaic;
 var x,y:byte;
begin
 for x:=1 to 16 do for y:=1 to 11 do
   putgrap(x*4-3,y*16-14,mosaic[x,y]);
end;

procedure transparent_mosaic;
 var x,y:byte;
begin
 for x:=1 to 16 do for y:=1 to 11 do
  if (mosaic[x,y]<>240) and (mosaic[x,y]<>0) then putgrap(x*4-3,y*16-14,mosaic[x,y]);
end;

function loadmosaic(n:byte):boolean;
var mf:file of mosaicrec;
begin
 writelog(n,'Loading mosaic');
 assign(mf,ADVNAME+MOSAICFILE);
 {$I-} reset(mf); {$I+}
 if ioresult<>0 then
  begin
   loadmosaic:=false;exit;
  end;
 if n>filesize(mf)+1 then
  begin
   loadmosaic:=false;exit;
  end;
 seek(mf,n-1);
 read(mf,mosaic);
 close(mf);
end;


procedure load_longmsgfile(mn:byte);
 var f:file of longmsgrec;
begin
 writelog(mn,'Loading long message');
 if mn=0 then exit;
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then exit;
 if filesize(f)>=mn then seek(f,mn-1);
 read(f,longmsg);
 close(f);
end;



procedure show_longmsg;
var i,i1:integer;
begin
 {for i:=1 to 177 do fillchar(mem[$a000:scrnh[i]+4],256,lo(TEXTC0));}
 for i1:=1 to 22 do
  for i:=1 to 32 do
   putletter(i*2-1,2+(i1-1)*8,ord(longmsg.chars[i1,i]),longmsg.attrs[i1,i]);
end;





procedure longmessage(n:byte);
 var i,i1,ii:byte;
     cs,ty,ty2,bb:byte;
begin
 load_longmsgfile(n);
 show_longmsg;
(*
 if PALETTE=16 then begin;show_longmsg;exit;end;
 for i1:=1 to 22 do
  for i:=1 to 32 do
   begin
    cs:=longmsg.attrs[i1,i];
    case cs of
     1,4:ty:=85;
     2,5:ty:=170;
     else ty:=255;
    end;
    if cs<4 then ty2:=0 else ty2:=255;
    bb:=byte(longmsg.chars[i1,i]);
  { putletter(i*2-1,2+(i1-1)*8,ord(longmsg.chars[i1,i]),longmsg.attrs[i1,i]);}
   for ii:=1 to 8 do
    begin
     move(block^[bb,ii],wbuffer^[i1*8-(8-ii),i*2-1],2);
     if cs>0 then
      begin { analyze and change the bx bytes }
  wbuffer^[i1*8-(8-ii),i*2-1]:=(wbuffer^[i1*8-(8-ii),i*2-1] XOR ty2) AND ty;
  wbuffer^[i1*8-(8-ii),i*2]:=(wbuffer^[i1*8-(8-ii),i*2] XOR ty2) AND ty;
      end;
    end;
   end;
 for i:=1 to 176 do
  move(wbuffer^[i,1],mem[scrnl:1+scrnh[i+2]],64);
*)
 clearbottom;
 waitkey;
end;


procedure internal_shortmsg;
begin
 (*
 savestrip;
 clearbottom;

 thickln(261,170,262,190,0);
 drawh(10,170,309,0);
 drawh(10,189,309,0);
 drawh(11,171,308,3);
 drawh(11,188,308,3);
 drawv(10,170,189,0);
 drawv(11,171,188,3);
 drawv(309,170,189,0);
 drawv(308,171,188,3);
 say(3,171,0,ack.shortmessage1);
 say(3,179,0,ack.shortmessage2);

 bottomsay(2,'PRESS A KEY TO CONTINUE.');
 if readkey=#0 then if readkey=#59 then help;
 bottomsay(2,'                        ');
 restorestrip;
 *)
end;

procedure internal_bmsg;
begin
{ bottomsay(1,ack.shortmessage1);
 bottomsay(2,ack.shortmessage2);}
end;



procedure shortmessage(n:byte);
 var j:char;
begin
 if n=0 then
 begin
  internal_shortmsg;
  exit;
 end;
 load_shortmsgfile(n);
 clearbottom;
 savestrip;

 show_shortmsg;
 bottomsay(2,'PRESS A KEY TO CONTINUE.');
 if readkey=#0 then if readkey=#59 then help;
 bottomsay(2,'                        ');
 restorestrip;
end;






procedure invertscr;
var b:byte; b2:word;
begin
 for b:=5 to 177 do for b2:=1 to 31 do
 begin
  meml[$a000:scrnh[b]+(b2*8)]:=meml[$a000:scrnh[b]+(b2*8)] XOR $0F0F0F0F;
  meml[$a000:scrnh[b]+(b2*8)+4]:=meml[$a000:scrnh[b]+(b2*8)+4] XOR $0F0F0F0F;
 end;
end;


procedure writelog(n:integer; s:string);
var logfile:text;
begin

 if ack.cheat<>123 then exit;
 assign(logfile,ADVNAME+'.LOG');
 {$I-} append(logfile); {$I+}
 if ioresult<>0 then rewrite(logfile);
 writeln(logfile,n,' '+s);
 close(logfile);

end;


procedure writelog2(n1,n2,n3,n4:word;n5,n6,n7:longint);
var logfile:text;
begin

 if ack.cheat<>123 then exit;
 assign(logfile,'TIMER.LOG');
 {$I-} append(logfile); {$I+}
 if ioresult<>0 then rewrite(logfile);
 writeln(logfile,n1,' ',n2,' ',n3,' ',n4,' ',n5,' ',n6,' ',n7);
 close(logfile);

end;


procedure calculate_weight;
 var i:integer;t:longint;max:longint;w:word;
begin
 i:=1;
 t:=ack.pcash*(obj^[i].d[9]*256+obj^[i].d[10]);
 for i:=2 to 254 do if ack.pinv[i]<>0 then
  if (obj^[i].t>5) and (obj^[i].t<10) then
   begin
    w:=obj^[i].d[9]*256+obj^[i].d[10];
    if w<=30000 then
	 t:=t+ack.pinv[i]*w;
   end;	
 if ack.plvehicle<>0 then
  max:=obj^[ack.plvehicle].d[9]*256+obj^[ack.plvehicle].d[10] else
  max:=ack.strength[0]*5;
 if max<10 then max:=10;
 encumberance:=t DIV max;

end;



procedure clear_keyboard_buffer;
 var regs:registers;
begin
 regs.ah:=$0c;regs.al:=$00;
 intr($21,regs);
end;


procedure fixpalette;
begin
 loadbmppalette(ack.ackversion,ADVNAME,bgi_dir);
{ greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(dpal[0,0]);
 greg.dx:=ofs(dpal[0,0]);
 intr($10,greg); }
end;



var macrolines:byte;


procedure loadmacro(n:byte);
var df:file of macrorec;
    macbuff:macrorec;
    i:integer;
begin
writelog(n,'Loading macro');
 assign(df,ADVNAME+MACROFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then exit;
 seek(df,n);
 read(df,macbuff);
 i:=1;
 macro^[i]:=macbuff;
 i:=2;
while (macbuff.next<>0) and (i<100) do
begin
 seek(df,macbuff.next);
 read(df,macbuff);
 macro^[i]:=macbuff;
 inc(i);
end;
 {macrolines:=i-1;}
 macro^[i].cmd:=22; {implied "stop" at the end}
 macrolines:=i;
 close(df);
 macroloaded:=n;
end;

procedure bottomsay(y:byte;s:string);
begin
 case y of
  0:y:=184;
  1:y:=180;
  2:y:=188;
 end;
 say(2,y,0,s);
end;

procedure clearbottom;
begin
 say(1,180,0,BLANK);
 say(1,188,0,BLANK);
end;

procedure waitkey;
 var j:char;
  done:boolean;
 begin
  clear_keyboard_buffer;
  bottomsay(2,'PRESS A KEY TO CONTINUE.');
  done:=false;
  repeat
   j:=readkey;
   if j=#0 then j:=readkey else done:=true;
  until done;
  bottomsay(2,'                        ');
 end;


procedure adjacent_error;
begin
 clearbottom;bottomsay(1,'RANGED WEAPONS CAN''T ATTACK ADJACENT');
 bottomsay(2,'SPACES.  PRESS A KEY TO CONTINUE...');
 if readkey=#0 then if readkey=#59 then help;
 clearbottom;
end;

{$I I_SNDEFF.PAS}   {procedure soundeffect}


procedure showbmp(n:word;transp:boolean);
var bmpf:file; bmph:file of byte;
    i,i2:integer;
    b,t:byte;
    pal2:array[0..255,0..2] of byte;
    name:string;
     header:Array[1..54] of byte;
	 headersize:word;
	 count:word;
	 j:char;

begin

               {first 54 bytes: header}
               {next 1024- bytes: pal in B-G-R-0}
               {next 64000 bytes: bitmap itself}

               {clear screen}
               {load new palette}
			
			   if n=65530 then
			    begin

				 name:=file_exists(bmpskinname);
				
				end else
			   if n=65529 then
			    begin

				 name:=file_exists('ABOUT.BMP');
				
				end else				
				begin
                 writelog(n,'Displaying BMP');
                 name:=custom_content_exists(n,'BMP');
			     end;
              if name<>'' then

			
              begin

              assign(bmph,name);
              reset(bmph);

              if ioresult=0 then
              begin
			   seek(bmph,46);
               read(bmph,b);
               i2:=b;
               if i2=0 then i2:=256;
			   headersize:=54+(i2*4);			
			   close(bmph);
			   writelog(100,strnum(64000+headersize));
               assign(bmpf,name);	
				{$I-}
			   reset(bmpf,64000+headersize);
			   blockread(bmpf,bmptemp^[0],1);
				
			   close(bmpf);
			    {$I+}
               {load and discard header}

              for i:=0 to i2-1 do
               begin
                pal2[i,2]:=bmptemp^[54+(i*4)];
                pal2[i,1]:=bmptemp^[54+(i*4)+1];
                pal2[i,0]:=bmptemp^[54+(i*4)+2];				

               end;
			
              {load palette off disk}

			
              {load and display picture}
              if not transp then
			  begin

				{load new palette into pal2}
                 for i:=0 to 255 do for i2:=0 to 2 do
                  pal2[i,i2]:=pal2[i,i2] SHR 2;
             { clearscreen;}

				{load current palette into pal1}
                greg.ax:=$1017;
				greg.bx:=0;
				greg.cx:=256;
				greg.es:=seg(pal1[0,0]);
				greg.dx:=ofs(pal1[0,0]);
				intr($10,greg);
		
			
                 if (pal1[0,1]<>pal2[0,1]) or
				    (pal1[10,2]<>pal2[10,2]) or
				    (pal1[20,1]<>pal2[20,1]) or
				    (pal1[30,2]<>pal2[30,2]) or
				    (pal1[40,1]<>pal2[40,1]) 				
				  then
				   begin
				    i:=-1;

					repeat
					  inc(i);
					  i2:=pal1[i,0]+pal1[i,1]+pal1[i,2];
					  until (i=255) or (i2<6);
				    fillchar(mem[$a000:0000],64000,i);
				   end;
			
			      begin
                   {load palette}
                   greg.ax:=$1012;
                   greg.bx:=0;
                   greg.cx:=256;
                   greg.es:=seg(pal2[0,0]);
                   greg.dx:=ofs(pal2[0,0]);
                   intr($10,greg);
                  end;		
			  {
              for i:=199 downto 0 do
			   begin
                BlockRead(bmpf,mem[$A000:i*320],320);
			   end;
			  }

              for i:=199 downto 0 do
			   begin
                move(bmptemp^[((199-i)*320)+headersize],mem[$A000:i*320],320);
			   end;

			
			  end
              else
               begin
			     count:=headersize;
			     t:=bmptemp^[count]; inc(count);
                 b:=t;
                 for i:=199 downto 0 do
                  for i2:=0 to 319 do
                   begin
                     if b<>t then mem[$A000:i*320 + i2]:=b;
                     b:=bmptemp^[count]; inc(count);

                   end;
               end;



             end; {if ioresult=0}

             end;


end;


procedure picturemessage(n:word);
var j:char;pausemouse2:boolean;
begin

 hidemouse;

 showbmp(n,false);
 if readkey=#0 then j:=readkey;
 clearscreen;
 fixpalette;
 showmouse;
end;



procedure fadeoutpal(speed:byte);
var pal2:array[0..255,0..2] of byte;
    i0,i,i1,i2:byte;
begin
 writelog(0,'Fading palette');
 greg.ax:=$1017;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0,0]);
 greg.dx:=ofs(pal1[0,0]);
 intr($10,greg);
 move(pal1[0,0],pal2[0,0],256*3);
 i2:=63;

 for i0:=1 to 5 do
  begin
   for i:=0 to 255 do for i1:=0 to 2 do
    pal2[i,i1]:=round(pal1[i,i1] - (pal1[i,i1] * (i0/5)));
    if speed<>0 then delay2(speed*10);
    greg.ax:=$1012;
    greg.bx:=0;
    greg.cx:=256;
    greg.es:=seg(pal2[0,0]);
    greg.dx:=ofs(pal2[0,0]);
    intr($10,greg);
   end;



end;


{var shownHP,shownMP:boolean;}
procedure graphHP;
{ var ycou:byte;
     xcou:byte; }
 var s:string[8]; b:byte;
begin

 if ack.hpmax[0]>1 then
 begin
 s:=strnum(ack.HP[0]);
 while length(s)<3 do s:=' '+s;
 if ack.poison>0 then s:=s+'Û2P';
 say(71,140,0,s);
 end;

 if ack.mpmax[0]>0 then
  begin
    s:=strnum(ack.MP[0]);
    while length(s)<3 do s:=' '+s;
    say(71,149,0,s);


  end;

(*

 if ack.HP[0]<>ack.HPmax[0] then
 begin
 say(67,170,0,'H');
 for ycou:=1 to 40 do
  begin
    if ((40-ycou)/40)*ack.HPmax[0]>ack.HP[0] then



    meml[scrnl:(70*4)+scrnh[168+ycou]]:=$04040404 else
    meml[scrnl:(70*4)+scrnh[168+ycou]]:=$0a0a0a0a;
  end;
  shownHP:=true;
 end else
 if shownHP then begin
  say(67,170,0,' ');
  for ycou:=1 to 10 do
   for xcou:=0 to 3 do
    meml[scrnl:xcou+(70*4)+scrnh[168+ycou]]:=lo(TEXTC0);
  {blank it out}
  shownHP:=false;
 end;


 if ack.MP[0]<>ack.MPmax[0] then
  begin
   say(74,170,0,'E');
   for ycou:=1 to 10 do
    if ((11-ycou)/10)*ack.MPmax[0]>ack.MP[0] then
     meml[scrnl:(77*4)+scrnh[168+ycou]]:=$08080808 else
     meml[scrnl:(77*4)+scrnh[168+ycou]]:=$09090909;
   shownMP:=true;
  end else
  if shownMP then begin
   say(74,170,0,' ');
   for ycou:=1 to 10 do
    for xcou:=0 to 3 do
     meml[scrnl:xcou+(77*4)+scrnh[168+ycou]]:=lo(TEXTC0);
   {blank it out}
   shownMP:=false;
  end;

*)


 end;


procedure playerdeath;
begin
stopsound(0);
ack.hp[0]:=0;
graphHP;
writelog(0,'Player death');
if ack.deathmacro=0 then
begin
 delay2(3000);
 fadeoutpal(10);
 clearscreen;
 fixpalette;
 say(30,80,0,'THE END.');
 delay2(3000);
 bottomsay(0,'PRESS A KEY TO QUIT.');
 clear_keyboard_buffer;
 repeat until keypressed;clear_keyboard_buffer;
 halt;
end else
 run_macro(ack.deathmacro);
 resurrect:=true;
end;



var thingtaken:array[1..4] of byte;
procedure takething(xx,yy:byte);
var i:integer;
begin
 yy:=yy*4;
 for i:=yy+1 to yy+4 do
  thingtaken[i-yy]:=mem[scrnl:xx+scrnh[i]];
end;
procedure replacething(xx,yy:byte);
var i:integer;
begin
 yy:=yy*4;
 for i:=yy+1 to yy+4 do mem[scrnl:xx+scrnh[i]]:=thingtaken[i-yy];
end;



function distance(x1,y1,x2,y2:integer):byte;
 var dd:integer;
begin
 x2:=x2-x1;x2:=abs(x2);
 y2:=y2-y1;y2:=abs(y2);
 if x2>50 then x2:=50;
 if y2>50 then y2:=50;
 dd:=round(sqrt( sqr(x2) + sqr(y2) ));
 if dd>255 then dd:=255;
 if dd<0 then dd:=255;
 distance:=dd;
end;



procedure loadconfig;
var ackf:file of masterrec;i:byte;

begin
 loadmapcolors;
 writelog(0,'Loading config '+ADVNAME+MASTERFILE);
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then
  begin;say(1,1,0,'FILE NOT FOUND: '+ADVNAME+MASTERFILE);readln;halt;end;
 read(ackf,ack);
 close(ackf);

 for i:=2 to 254 do
  if ack.pinv[i]>0 then
   case obj^[i].t of
    6,7,8,9,11:begin end;
    else ack.pinv[i]:=0;
   end;
 if ack.ackversion<25 then
  begin
   ack.invisible:=0;
   ack.poison:=0;
   ack.fly:=false; ack.nomove_n:=false;
   ack.nomove_s:=false; ack.nomove_e:=false;
   ack.nomove_w:=false; ack.unused:=false;
   ack.splituse:=1;
   for i:=8 to 26 do ack.variableshi[i]:=0;
   ack.minviewdistance:=1;
   ack.torchduration:=0;
   ack.showclock:=0;
   ack.misssound:=97;
   ack.hitsound:=98;
   for i:=1 to 12 do ack.qtile[i]:=0;
   ack.hourmacro:=0;
   ack.music:=0;
   ack.darkforeground:=17;ack.darkbackground:=0;

  end;


end;

procedure saveconfig;
var ackf:file of masterrec;
begin
 writelog(0,'Saving config '+ADVNAME+MASTERFILE);

 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} rewrite(ackf); {$I+}
 if ioresult<>0 then exit;
 write(ackf,ack);
 close(ackf);
end;


procedure loadcreatures;
var cf:file of creaturerec;
    csf:file of word;
    i:byte;
begin
 writelog(0,'Loading creatures');
 assign(cf,ADVNAME+CREATUREFILE);
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to 64 do read(cf,crc^[i]);
  if not eof(cf) then
    for i:=65 to MAXCRCS do read(cf,crc^[i])
   else
    begin
	 for i:=65 to MAXCRCS do crc^[i].t:=0;
	end;
 close(cf);

 assign(csf,ADVNAME+CREATURESOUNDFILE);
 {$I-} reset(csf);
 if ioresult<>0 then
  begin
   for i:=1 to MAXCRCS do crcsounds[i]:=0;
   exit;
  end;
 for i:=1 to 64 do read(csf,crcsounds[i]);
  if not eof(csf) then
    for i:=65 to MAXCRCS do read(csf,crcsounds[i])
   else
    begin
	 for i:=65 to MAXCRCS do crcsounds[i]:=0;
	end;
 close(csf);
 {$I+}
end;


procedure loadobjs;
 var f:file of objectrec;
     fc:byte;
begin
 writelog(0,'Loading objects');
 assign(f,concat(ADVNAME,OBJECTFILE));
 {$I-} reset(f); {$I+}
 if IoResult<>0 then
  begin
   say(1,1,0,'FILE NOT FOUND: '+ADVNAME+OBJECTFILE);readln;halt;
  end;
 for fc:=1 to MAXOBJS do read(f,obj^[fc]);
 close(f);
end;

procedure savestrip;
{170-189}
begin
 if mouseon then hidemouse;
 move(mem[$a000:scrnh[170]],screenstrip^,6400);
 if mouseon then showmouse;
end;

procedure restorestrip;
begin
 if mouseon then hidemouse;
 move(screenstrip^,mem[$a000:scrnh[170]],6400);
 if mouseon then showmouse;
end;


procedure savepage;
var tempf:file;
begin
 if mouseon then hidemouse;
 { move(mem[$a000:0000],bank1^,64000); }
 assign(tempf,'SCREEN.TMP');
 rewrite(tempf,64000);
 blockwrite(tempf,mem[$a000:0000],1);
 close(tempf);
 if mouseon then showmouse;
end;

procedure restorepage;
var tempf:file;
begin
 if mouseon then hidemouse;
 { move(bank1^,mem[$a000:0000],64000); }
 assign(tempf,'SCREEN.TMP');
 reset(tempf,64000);
 blockread(tempf,mem[$a000:0000],1);
 close(tempf);
 if mouseon then showmouse;
end;




 procedure titlebars;
  begin
   if not starting_up_clearscreen then exit;
   clearscreen;
   {
   thickln(0,0,2,199,3);
   drawh(0,0,319,3);
   thickln(0,179,319,180,3);
   drawh(0,200,319,3);
   thickln(261,0,262,179,3);
   thickln(317,0,319,199,3);
   }
  end;


procedure player_inventory;
  var
   invlist:array[1..255,1..2] of byte;
   i,i1,i2,top:integer;
   done:boolean;
   j:char;
  begin
   for i:=1 to 255 do begin;invlist[i,1]:=0;invlist[i,2]:=0;end;
   i1:=0;

   for i2:=6 to 9 do
   for i:=2 to 254 do
    if obj^[i].t=i2 then
    if ACK.Pinv[i]<>0 then

    begin
	 if i1<255 then inc(i1);
	 invlist[i1,1]:=i; invlist[i1,2]:=0;
	 if obj^[i].t<10 then if obj^[i].d[14]<>0 then
	  begin  {item has an examine message}
	   if i1<255 then inc(i1);
	   invlist[i1,1]:=i; invlist[i1,2]:=obj^[i].d[14];
	   if i1<255 then inc(i1);
	   invlist[i1,1]:=i; invlist[i1,2]:=obj^[i].d[14];
	  end;
	  if (obj^[i].t>9) or (obj^[i].d[14]=0) then
	  begin {no examine message, leave space for icon}
	   if i1<255 then inc(i1);
	   invlist[i1,1]:=0; invlist[i1,2]:=255;
	  end;
	end;
	
	
   done:=false;top:=1;


  repeat
     clearscreen;
	 say(1,0,6,' INVENTORY Û1 [PgUp] [PgDn] [ESC]');

   for i:=0+top to 19+top do
    if i<256 then begin
	 if invlist[i,2]=0 then
	  begin {write item name}
	   if invlist[i,1]<>0 then
        begin	
		 if ack.pinv[invlist[i,1]]>1 then say(5,(i-top)*8+14,1,strnum(ack.pinv[invlist[i,1]])+'Û0 '+obj^[invlist[i,1]].n) else
		  say(5,(i-top)*8+14,0,obj^[invlist[i,1]].n);
		
		 if obj^[invlist[i,1]].t<10 then
		  putgrap(1,(i-top)*8+10,obj^[invlist[i,1]].d[1]);
		 case obj^[invlist[i,1]].t of
		  7,8:say(46,(i-top)*8+14,2,'DMG: '+strnum(obj^[invlist[i,1]].d[4]));
		  9:say(46,(i-top)*8+14,2,'AC: '+strnum(round(obj^[invlist[i,1]].d[5]* (obj^[invlist[i,1]].d[6]/100)) ));
		 end;
		
		end;
	  end else
	  if invlist[i,1]<>0 then begin {write short msg line}
	   load_shortmsgfile(invlist[i,2]);
	   if invlist[i-1,2]=invlist[i,2] then {this is the 2nd line}
	      for i1:=1 to 37 do
		   putletter(i1*2+4,(i-top)*8+14,ord(shortmsg.chars[2,i1]),1)
		 else {else write the first line}
	      for i1:=1 to 37 do
		   putletter(i1*2+4,(i-top)*8+14,ord(shortmsg.chars[1,i1]),1)
	  end;
  end;

  j:=readkey; if j=#0 then j:=readkey else
   if j<>#27 then j:=#32;
  case j of
   #27:done:=true;
   #73:begin {pgup}
        if top>20 then top:=top-20 else top:=1;
       end;
   #81:begin {pgdn}
        if top<240 then top:=top+20 else top:=240;
       end;
   #72:if top>1 then top:=top-1;
   #80:if top<240 then top:=top+1;	
   #71:top:=1;
  end; {case}
	
  until done;
   {show inventory}

  end;





procedure showplayerstatus;
 var
  j:char;
  my_inv:array[1..254] of byte;
  i,i1,top:integer;
  done:boolean;
  s:string;

begin
 savepage;
 titlebars;
 if (ack.playername<>'') and (ack.playername<>'UNUSED') then
  say(3,3,0,'NAME: Û1'+ack.playername);
 if ack.mpmax[0]<>0 then
  s:='Û0  ENERGY: Û1'+strnum(ack.mp[0])+'Û0/Û1'+strnum(ack.mpmax[0])
  else s:='';
 say(3,13,0,'HIT POINTS: Û1'+strnum(ack.hp[0])+'Û0/Û1'+strnum(ack.hpmax[0])+s);

 say(3,23,0,'STRENGTH: Û1'+strnum(ack.strength[0])+'    Û0MONEY: Û1'+strnum(ack.pcash));
if ack.intelligence[0]<>0 then
 say(3,33,0,'INTELLIGENCE: Û1'+strnum(ack.intelligence[0]));

 say(3,43,0,'WEAPON SKILL: Û1'+strnum(ack.weapskill[0]));
 say(3,53,0,'RANGED WEAPON SKILL: Û1'+strnum(ack.rweapskill[0]));
 say(3,63,0,'ENCUMBERANCE: Û1'+strnum(round(encumberance/4*100))+'% OF MAXIMUM');

 say(3,73,0,'DAYS ELAPSED: Û1'+strnum(ack.days));
 if ack.ackversion>24 then
  begin
   say(3,83,0,'LEVEL: Û1'+strnum(ack.level)+'Û0  EXPERIENCE: Û1'+strnum(ack.experience));
   if ack.level<10 then
    say(3,93,0,'EXP. FOR NEXT LEVEL: Û1'+strnum(ack.levelexp[ack.level+1]));

  end;
 if ack.pweapready=0 then s:='NONE' else s:=obj^[ack.pweapready].n;
 say(3,103,0,'WEAPON: Û1'+s);

 i1:=113;
 say(3,113,0,'ARMOR: ');
 for i:=1 to 7 do if ack.countarmor[i]=0 then if ack.parmor[i]<>0 then
  begin
    say(18,i1,1,obj^[ack.parmor[i]].n);
    i1:=i1+10;
  end;
 if i1=113 then
  say(18,113,1,'NONE');
 say(1,188,0,'PRESS Û6 I Û0 FOR INVENTORY OR Û6ESCÛ0 TO EXIT');
 helpindex:=48;
repeat
 j:=upcase(readkey);
 if j=#0 then if readkey=#59 then help;
until (j=#27) or (j='I');


 if upcase(j)='I' then
  player_inventory;


 restorepage;
 helpindex:=2;
end;


procedure boxx(x1,y1,x2,y2:byte);
 var xx:byte;
begin
 for xx:=x1 to x2 do
  begin
   putthing(xx,y1*4,3);
   putthing(xx,y2*4,3);
  end;
 for xx:=y1+1 to y2-1 do
  begin
   putthing(x1,xx*4,3);
   putthing(x2,xx*4,3);
  end;
 end;



procedure savewmap;
 var chf:file of chunkrec;
    c1,c2:byte;
    ch:chunkprec;
    vhf:file of vehrec;
begin
 writelog(0,'Saving worldmap');
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
 writelog(0,'Loading worldmap');
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


procedure savemap;
 var rgf:file of regionrec;
     lpf:file; { of locpointer; }
     lcf:file; { of loccontrec; }
     chf:file of chunkrec;
     vhf:file of vehrec;
     fc:word;
     aa,bb:byte;
	 rc:rcrcarray;
	
procedure copyrc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+64 do if i<255 then
  rc[i-start]:=rcrc^[i];
end;
	
begin
 writelog(0,'Saving map');
 modified[thisregion]:=true;
 assign(rgf,ADVNAME+REGIONFILE);
 {$I-} reset(rgf); {$I+}
 if ioresult<>0 then exit;
 seek(rgf,thisregion-1);
 write(rgf,region);
 close(rgf);
 assign(rcrcf,ADVNAME+MAPCFILE+strnum(thisregion));
 {$I-} rewrite(rcrcf); {$I+}
 if ioresult<>0 then exit;

 	 for fc:=(64 DIV 64)-1 to ((RCMAX+2) DIV 64)-1 do
	  begin
	   copyrc(64 * fc);
	   write(rcrcf,rc);
	  end;

 close(rcrcf);
 if region.rooms>20 then
   begin
     assign(vhf,ADVNAME+MAPBFILE+strnum(thisregion));
     {$I-} reset(vhf); {$I+}
     if ioresult<>0 then exit;
     write(vhf,veh);
     close(vhf);
   end
  else begin
    assign(lpf,ADVNAME+MAPAFILE+strnum(thisregion));
    assign(lcf,ADVNAME+MAPBFILE+strnum(thisregion));
    {$I-} rewrite(lpf,1);
    if ioresult<>0 then exit;
    rewrite(lcf,1);
    if ioresult<>0 then exit;
    {$I+}
    blockwrite(lpf,rmcnt^[1],6400);
    blockwrite(lcf,locnt^[1],locntsize*sizeof(loccontrec));
    close(lpf);close(lcf);
  end;
end;


procedure loadmap(n:byte);
 var rgf:file of regionrec;
     lpf:file; { of locpointer; }
     lcf:file; { of loccontrec; }
     lcf2:file of loccontrec; {to find size}
     chf:file of chunkrec;
     vhf:file of vehrec;
     fc:word;
     aa,bb:byte;
     tempf:file;
     wcf:file of wander_index_32;
	 wc:wander_index_32;
	 rc:rcrcarray;

procedure copywc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+32 do
  wander_index^[i]:=wc[i-start];


end;	
procedure copyrc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+64 do if i<255 then
  rcrc^[i]:=rc[i-start];
end;
	
begin

 assign(wcf,ADVNAME+MAPWFILE+strnum(n));
 {$I-} reset(wcf); {$I+}
 if ioresult<>0 then
  begin
   for fc:=1 to WANDERMAX do
     wander_index^[fc].x:=0;
  { rewrite(wcf);
   write(wcf,wander_index);
   close(wcf); }
  end else
    begin
   read(wcf,wc);
   copywc(0);
   if eof(wcf) then
	 for fc:=33 to WANDERMAX do
	  wander_index^[fc].x:=0
   else
    begin
	 for fc:=(32 DIV 32) to (WANDERMAX DIV 32)-1 do
	  begin
	   read(wcf,wc);
	   copywc(32 * fc);
	  end;
    end;	
   close(wcf);
  end;


 thisregion:=n;
 assign(rgf,ADVNAME+REGIONFILE);
 {$I-} reset(rgf); {$I+}
 if ioresult<>0 then
  begin
   say(1,1,0,'FILE NOT FOUND: '+ADVNAME+REGIONFILE);readln;exit;
   end;
 if filesize(rgf)<n then
  begin
  say(1,1,0,'INVALID REGION: '+strnum(n));readln;exit;
  end;
 seek(rgf,n-1);
 read(rgf,region);
 close(rgf);
 {check to see if temp file exists}
 assign(tempf,ADVNAME+MAPAFILE+strnum(n));
 {$I-} reset(tempf); {$I+}
 if ioresult=0 then close(tempf) else
  begin
   bytecopy(ADVNAME+'.X'+strnum(n),ADVNAME+'.1'+strnum(n));
   bytecopy(ADVNAME+'.Y'+strnum(n),ADVNAME+'.2'+strnum(n));
   bytecopy(ADVNAME+'.Z'+strnum(n),ADVNAME+'.3'+strnum(n));
   {temp file not present - copy it over}
  end;
 assign(rcrcf,ADVNAME+MAPCFILE+strnum(n));
 {$I-} reset(rcrcf); {$I+}
 if ioresult<>0 then exit;

    read(rcrcf,rc);
   copyrc(0);
   if eof(rcrcf) then
	 for fc:=65 to RCMAX do
          begin
           rcrc^[fc].crcsource:=0;
           rcrc^[fc].used:=false;
          end

   else
    begin
	 for fc:=(64 DIV 64) to (256 DIV 64)-1 do
	  begin
	   read(rcrcf,rc);
	   copyrc(64 * fc);
	  end;
    end;

 close(rcrcf);
 if region.rooms>20 then
   begin
     assign(vhf,ADVNAME+MAPBFILE+strnum(n));
     {$I-} reset(vhf); {$I+}
     if ioresult<>0 then exit;
     read(vhf,veh);
     close(vhf);
     {load worldmap}
   end
  else begin
    assign(lpf,ADVNAME+MAPAFILE+strnum(n));
    assign(lcf,ADVNAME+MAPBFILE+strnum(n)); {That's not a typo!}
    assign(lcf2,ADVNAME+MAPBFILE+strnum(n));
    {$I-}
    reset(lcf2);locntsize:=filesize(lcf2);close(lcf2);
    reset(lpf,1);
     if ioresult<>0 then exit;
     blockread(lpf,rmcnt^[1],6400);
    close(lpf);
    reset(lcf,1);
    if ioresult<>0 then exit;
    {$I+}
    blockread(lcf,locnt^[1],locntsize*sizeof(loccontrec));
   { for aa:=1 to 80 do for bb:=1 to 40 do
     read(lpf,rmcnt^[aa,bb]);
    fc:=0;
    while not eof(lcf) do
     begin
      inc(fc);
      read(lcf,locnt^[fc]);
     end;
    locntsize:=fc; }
   close(lcf);
  end;
end;

function selectinventory(cats:byte;comment:string):byte;
const
 XLOC=32;
 YLOC=10;
var
 something:boolean;
 jn:byte;j0:char;
 a:byte;
 zerovalue:byte;
 numobjs:byte; {number of objs in this catagory}
 currcat:byte; {current catagory}
 whatobj,whatobjold:byte; {what obj, 1..numobjs}
 topobj,topobjold:byte;
 objlist:array[1..255] of byte;
 done:boolean;
 redisplay_sidebar,thisready:boolean;
 i,i1:integer;
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
  199:begin
       case destcat of
      6:begin;ok:=true;comment:='<- ITEMS            ->';end;
      7:begin;ok:=true;comment:='<- MELEE WEAPONS    ->';end;
      8:begin;ok:=true;comment:='<- RANGED WEAPONS   ->';end;
      9:begin;ok:=true;comment:='<- ARMOR            ->';end;
     11:begin;ok:=true;comment:='<- ABILITIES        ->';end;

       end;

      end;
  196:if destcat=6 then ok:=true;
  204:case destcat of
      7,8,9:ok:=true;
      end;
  205:case destcat of
       6,7,8,9:ok:=true;
      end;
  111:if (destcat<>11) and (destcat>5) then ok:=true;
  112:if (destcat=6) or (destcat=11) then ok:=true;
 end; {case cats}
 incats:=ok;
end;

procedure makeobjlist;
var c:byte;
begin
 topobjold:=255;
 whatobjold:=255;
 blankbox(XLOC*4+10,YLOC+8,XLOC*4+183,YLOC+153);
 for c:=length(comment)+1 to 22 do comment:=comment+' ';
 say(XLOC+2,YLOC-8,4,comment);
 say(XLOC+2,YLOC,4,' SELECT:Û5…†Û4  EXIT:Û5ESCÛ4  ');
 numobjs:=0;
 whatobj:=1;
 topobj:=1;
 if (Ack.PCASH>0) and incats(12) then
   begin;inc(numobjs);objlist[numobjs]:=1;end;
 if cats=199 then
 begin
 for c:=2 to 254 do
  if (obj^[c].t=currcat) and (Ack.PINV[c]>0) then
   if (obj^[c].t <> 6) or (obj^[c].d[2]<>0) then
    begin;inc(numobjs);objlist[numobjs]:=c;end;

 end else
 if cats=196 then
  begin
   for c:=2 to 254 do
   if (obj^[c].t=currcat) and (Ack.PINV[c]>0) then
    if obj^[c].d[2]<>0 then
	 begin;inc(numobjs);objlist[numobjs]:=c;end;

  end else
 for c:=2 to 254 do
  if incats(obj^[c].t) then
   if (Ack.PINV[c]>0) and not( (obj^[c].d[9]*256+obj^[c].d[10] > 30000) and ((cats=111) or (cats=205))) then
    begin;inc(numobjs);objlist[numobjs]:=c;end;
end;


begin
 if mouseon then
  repeat
   trackmouse;
  until (mouseLB=false);
 zerovalue:=0;
 {savepage;}
 done:=false;
  currcat:=1;
  whatobjold:=1;
  while not incats(currcat) do
   begin
    cycle(currcat,1,12,+1);
    inc(whatobjold);
    if whatobjold>15 then exit;
   end;
 whatobjold:=255;
 blankbox(XLOC*4+5,YLOC-3,XLOC*4+187,YLOC+156);
 drawh(XLOC*4+6,YLOC-10,XLOC*4+186,3);
 drawh(XLOC*4+6,YLOC+155,XLOC*4+186,3);
 drawv(XLOC*4+6,YLOC-10,YLOC+155,3);
 drawv(XLOC*4+186,YLOC-10,YLOC+155,3);
  makeobjlist;
repeat
   if numobjs>9 then
    if whatobjold<>whatobj then
   begin
    for i:=1 to 18 do begin;say(XLOC+2,YLOC+i*8,5,'Œ');end;
    i:=trunc(whatobj/numobjs*17)+1;
    say(XLOC+2,YLOC+i*8,6,' ');           {Remember, whatobj is NOT 1..255}
   end;

if topobjold<>topobj then
  if numobjs=0 then say(XLOC+12,YLOC+8,0,'NONE.')
   else for i:=0 to 8 do
    begin
     if i+topobj<=numobjs then
     begin
       case currcat of
        1,3,5,6,7,8,9,10,12:
          putgrap(XLOC+8,YLOC+8+(16*i),obj^[objlist[topobj+i]].d[1]);
        2,4:if obj^[objlist[topobj+i]].d[1]=255 then
            say(XLOC+8,YLOC+8+(16*i),0,'?') else
             putgrap(XLOC+8,YLOC+8+(16*i),obj^[objlist[topobj+i]].d[1]);
       end;
       if (currcat=8) or (currcat=7) then
        begin
         thisready:=false;
          for i1:=1 to 7 do
          if ack.parmor[i1]=objlist[topobj+i] then thisready:=true;
         if objlist[topobj+i]=ack.pweapready then thisready:=true;
        if thisready then
         putgrap(XLOC+4,YLOC+8+(16*i),zerovalue+243) else
          putgrap(XLOC+4,YLOC+8+(16*i),zerovalue);
        end;
      say(XLOC+12,YLOC+16*(i+1),0,obj^[objlist[topobj+i]].n);
     if objlist[topobj+i]>1 then
      say(XLOC+12,YLOC+8+(16*i),0,'('+strnum(Ack.PINV[objlist[topobj+i]])+')  ')
     else
      say(XLOC+12,YLOC+8+(16*i),0,'('+strnum(Ack.PCASH)+')  ');
     end
     else begin
      say(XLOC+4,YLOC+8+(16*i),0,'                    ');
      say(XLOC+4,YLOC+16*(i+1),0,'                    ');
      end;
    end;
 if numobjs>0 then
  begin
   say(XLOC+12,YLOC+8+(16*(whatobj-topobj)),6,' ');
  end;
 topobjold:=topobj;
 whatobjold:=whatobj;

 something:=false;
 repeat
  if keypressed then begin;something:=true;j:=upcase(readkey);
    if j=#0 then j0:=readkey;end;
  if mouseon then trackmouse;

  if mousein(XLOC+2,YLOC,XLOC+44,YLOC+152) then
   begin

    jn:=0; j0:=#0;
    jn:=checkmouse(XLOC+2,YLOC+8,XLOC+3,YLOC+64,jn,1,j0,#100);
     {scroll up}
    jn:=checkmouse(XLOC+2,YLOC+80,XLOC+3,YLOC+152,jn,1,j0,#101);
     {scroll down}
    jn:=checkmouse(XLOC+26,YLOC,XLOC+42,YLOC+7,jn,1,j0,#102);
     {esc}

    for a:=0 to 8 do
     jn:=checkmouse(XLOC+4,YLOC+8+16*a,XLOC+44,YLOC+24+16*a,jn,1,j0,chr(a+1));
     {an item}


    something:=true;
    j:=#1;
   end;


 until something;

 if numobjs>0 then
  begin
   say(XLOC+12,YLOC+8+(16*(whatobj-topobj)),0,'(');
  end;
 if j=#1 then case j0 of
   #100:begin
         j:=#0;j0:='I';
         {scroll up}
        end;
   #101:begin
         j:=#0;j0:='Q';
         {scroll down}
        end;
   #102:begin
         j:=#27;
        end;
   #1..#9:begin
           if topobj+ord(j0)-1<=numobjs then
            begin;whatobj:=topobj+ord(j0)-1;j:=#13;end;

          end;
   end; {j0case}
 case j of
  #0:case j0 of
   #59:help;
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
   #75:if cats=199 then begin {left arrow}
        repeat
         cycle(currcat,6,11,-1);
        until incats(currcat);

        say(XLOC+2,YLOC-8,4,comment);
         makeobjlist;

       end;
   #77:if cats=199 then begin {right arrow}

        repeat
         cycle(currcat,6,11,+1);
        until incats(currcat);
         makeobjlist;
        say(XLOC+2,YLOC-8,4,comment);
       end;
  end; {0case}
  '~':done:=true;
  #32,#13:if ((currcat<>7) and (currcat<>8)) or (numobjs=0) then done:=true
      else begin
         i:=99;
         for i1:=1 to 7 do
          if ack.parmor[i1]=objlist[whatobj] then i:=i1;
         if objlist[whatobj]=ack.pweapready then i:=0;
        if i<>99 then
         begin
          if i=0 then ack.pweapready:=0 else
           ack.parmor[i]:=0;
         end else
         begin
          if obj^[objlist[whatobj]].t<9 then ack.pweapready:=objlist[whatobj]
           else
            ack.parmor[obj^[objlist[whatobj]].d[2]]:=objlist[whatobj];
         end;
         topobjold:=255;
       end;
  #27:begin;whatobj:=0;done:=true;end;
 end; {keycase}

until done;
 {restorepage;}
 if numobjs=0 then whatobj:=0;
 if whatobj<>0 then selectinventory:=objlist[whatobj]
 else selectinventory:=0;
 end;




procedure animation;
 var xc,yc,putgrapc,agrap:byte;
     h,m,s,s1:word;
     shiftcount,shift:byte;
     agrapset2:boolean;
     r:byte;
begin

 if resurrect then exit;
 if anim_wide=0 then
  for xc:=0 to 10 do for yc:=0 to 8 do
   if anim_screen[xc+1,yc+1].tb then
    begin
    if anim_screen[xc+1,yc+1].tb4<>true then
     begin
      if anim_phase_one then
       begin;agrap:=anim_screen[xc+1,yc+1].t1;agrapset2:=false;end else
        begin;agrap:=anim_screen[xc+1,yc+1].t2;agrapset2:=true;end;
     end else
      begin
       r:=random(4);
       case r of
        0:begin;agrap:=anim_screen[xc+1,yc+1].t1;agrapset2:=false;end;
        1:begin;agrap:=anim_screen[xc+1,yc+1].t2;agrapset2:=true;end;
        2:begin;agrap:=anim_screen[xc+1,yc+1].t3;agrapset2:=true;end;
        3:begin;agrap:=anim_screen[xc+1,yc+1].t4;agrapset2:=true;end;
       end;
       if agrap=0 then begin;agrap:=anim_screen[xc+1,yc+1].t1;agrapset2:=false;end;
      end;
     if agrapset2 then
       begin
         if anim_screen[xc+1,yc+1].lit=0 then putdarkgrap2(xc*4+11,yc*16+18,agrap,
            ack.darkforeground,ack.darkbackground)
           else
		    if anim_screen[xc+1,yc+1].under=0 then putgrap2(xc*4+11,yc*16+18,agrap)
			 else
			  begin
			   if obj^[anim_screen[xc+1,yc+1].under].t<6 then
			   if (obj^[anim_screen[xc+1,yc+1].under].d[6]<>0) and (not anim_phase_one) then
			   puttransgrap22(xc*4+11,yc*16+18,agrap,obj^[anim_screen[xc+1,yc+1].under].d[6])
			   else puttransgrap21(xc*4+11,yc*16+18,agrap,obj^[anim_screen[xc+1,yc+1].under].d[1]);
			  end;

       end else begin

         if anim_screen[xc+1,yc+1].lit=0 then putdarkgrap(xc*4+11,yc*16+18,agrap)
           else if anim_screen[xc+1,yc+1].under=0 then putgrap(xc*4+11,yc*16+18,agrap)
             else
			   if (obj^[anim_screen[xc+1,yc+1].under].d[6]<>0) and (not anim_phase_one) then
			   puttransgrap12(xc*4+11,yc*16+18,agrap,obj^[anim_screen[xc+1,yc+1].under].d[6])
			   else puttransgrap11(xc*4+11,yc*16+18,agrap,obj^[anim_screen[xc+1,yc+1].under].d[1]);

       end;



    end;
 if anim_wide<>0 then
  for xc:=1 to anim_wide do for yc:=1 to anim_tall do
   if anim_screen[xc,yc].tb then
    begin
    if anim_screen[xc,yc].tb4<>true then
     begin
      if anim_phase_one then
       begin;agrap:=anim_screen[xc,yc].t1;agrapset2:=false;end else
        begin;agrap:=anim_screen[xc,yc].t2;agrapset2:=true;end;
     end else
     begin
      r:=random(4);
      case r of
       0:begin;agrap:=anim_screen[xc,yc].t1;agrapset2:=false;end;
       1:begin;agrap:=anim_screen[xc,yc].t2;agrapset2:=true;end;
       2:begin;agrap:=anim_screen[xc,yc].t3;agrapset2:=true;end;
       3:begin;agrap:=anim_screen[xc,yc].t4;agrapset2:=true;end;
      end;
      if agrap=0 then begin;agrap:=anim_screen[xc,yc].t1;agrapset2:=false;end;
     end;
  if agrapset2 then
     begin
      if anim_screen[xc,yc].lit=0 then
         putdarkgrap2((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),
           agrap,ack.darkforeground,ack.darkbackground)
         else if anim_screen[xc,yc].under=0 then
		   putgrap2((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),agrap)
		   else
		
			  begin
			   if obj^[anim_screen[xc,yc].under].t<6 then
			   if (obj^[anim_screen[xc,yc].under].d[6]<>0) and (not anim_phase_one) then
			   puttransgrap22((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),
			      agrap,obj^[anim_screen[xc,yc].under].d[6])
			   else puttransgrap21((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),
			      agrap,obj^[anim_screen[xc,yc].under].d[1]);
			  end; 		
		
		
     end
   else
      begin
       if anim_screen[xc,yc].lit=0 then
       putdarkgrap((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),agrap)
	
	
           else if anim_screen[xc,yc].under=0 then putgrap((xc*4-3 +(32-(anim_wide*2))),
		     (yc*16-14 +(88-(anim_tall*8))),agrap)
             else
			   if (obj^[anim_screen[xc,yc].under].d[6]<>0) and (not anim_phase_one) then
			   puttransgrap12((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),
			    agrap,obj^[anim_screen[xc,yc].under].d[6])
			   else puttransgrap11((xc*4-3 +(32-(anim_wide*2))),(yc*16-14 +(88-(anim_tall*8))),
			    agrap,obj^[anim_screen[xc,yc].under].d[1]);

	
	
	

      end;
    end;

 nextanim:=supergetclock+(ack.anim_speed*10);
 anim_phase_one:=anim_phase_one XOR true;
end;


procedure anim_toggle;

 begin
  {if ack.hp[0]=0 then playerdeath;}

  if supergetclock>nextanim then
   begin;anim_phase_one:=anim_phase_one XOR true;
    nextanim:=supergetclock+(ack.anim_speed*10);end;


 end;








procedure fadeinpal(speed:byte);
var pal2:array[0..255,0..2] of byte;
    i0,i,i1,i2:byte;
begin
 writelog(0,'Fading palette');


 for i0:=1 to 5 do
 begin
  if speed<>0 then
   delay2(10*speed);
  for i:=0 to 255 do for i1:=0 to 2 do
   pal2[i,i1]:=trunc(pal1[i,i1]*i0/5);
  greg.ax:=$1012;
  greg.bx:=0;
  greg.cx:=256;
  greg.es:=seg(pal2[0,0]);
  greg.dx:=ofs(pal2[0,0]);
  intr($10,greg);
 end;

 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0,0]);
 greg.dx:=ofs(pal1[0,0]);
 intr($10,greg);
 writelog(0,'Palette fade done');

end;

procedure run_macro(n:byte);
 var macropointer:integer;
     invchange:boolean;
     macrodone:boolean;
     macroswitch:byte;
     thismacro:byte;
     i0,i,i1,i2,i3:integer; {dummy counter}
     j:char;
     llp:locpointer;
	 addslot,addslotc:word;
     escgoto:byte;
	 w1,w2,w3:word;
     tempxlo,tempylo,tempxch,tempych:integer;
	 temppoint:locpointer;


function delayk(delayms:word):boolean;
var
 h,m,s,ms,timenow,delayend:word;
 j:char;
begin
 delayk:=false;
 gettime(h,m,s,ms);
 if starting_h > h then h:=h+24;
 h:=h - starting_h;
 delayend := ((ms + delayms) DIV 100) +
              (s*10) + (m*600) + (h*36000);           		
 repeat
   gettime(h,m,s,ms);
   if starting_h > h then h:=h+24;
   h:=h - starting_h;
   timenow := ((ms) DIV 100) +
              (s*10) + (m*600) + (h*36000);
 until (timenow>=delayend) or keypressed;
 if keypressed then
  begin
   j:=readkey;
   if j=#27 then delayk:=true;
   if j=#0 then j:=readkey;
  end;
end;







procedure setquestflag(d,n:byte);
 var f: file of byte;
	
begin
 assign(f,ADVNAME+'.DQT');
 {$I-} reset(f); {$I+}
 if ioresult<>0 then exit;
 seek(f,d-1);
  write(f,n);
  close(f);
 end;

function getquestflag(d:byte):byte;
 var f: file of byte; n:byte;
	
begin
 assign(f,ADVNAME+'.DQT');
 {$I-} reset(f); {$I+}
 if ioresult<>0 then n:=0 else
 begin
  seek(f,d-1);
  read(f,n);
  close(f);
 end;
 getquestflag:=n;
 end;

function mac_var(ind:byte):word;
var x:byte;
begin
 with macro^[macropointer] do
  case data[ind,1] of
  35:mac_var:=lastmov;
  36:mac_var:=getquestflag(data[ind,2]);
  0:mac_var:=macro^[macropointer].data[ind,3]+
         (macro^[macropointer].data[ind,2]*256);
  1:if data[ind,2]>7 then mac_var:=ack.variables[data[ind,2]]+(256*ack.variableshi[data[ind,2]])
     else mac_var:=ack.variables[data[ind,2]];
 30:if data[ind,2]>7 then mac_var:=ack.variables2[data[ind,2]]+(256*ack.variables2hi[data[ind,2]])
     else mac_var:=ack.variables2[data[ind,2]];
  2:case data[ind,2] of
     0:mac_var:=ack.hp[0];
     1:mac_var:=ack.hpmax[0];
     2:mac_var:=ack.mp[0];
     3:mac_var:=ack.mpmax[0];
     4:mac_var:=ack.strength[0];
     5:mac_var:=ack.intelligence[0];
     6:mac_var:=ack.weapskill[0];
     7:mac_var:=ack.rweapskill[0];
     8:mac_var:=ack.alignment;
	 9:mac_var:=ack.criminal;
	 10:mac_var:=ack.regen_hp;
	 11:mac_var:=ack.regen_mp;
	 12:mac_var:=ack.poison;
    end; {case2}
  3:if data[ind,2]>1 then mac_var:=ack.Pinv[data[ind,2]] else mac_var:=ack.pcash;
  31:begin;mac_var:=0;for x:=1 to 7 do if ack.parmor[x]=data[ind,2] then mac_var:=1;end;
  32:mac_var:=ack.pweapready;
  4:mac_var:=global_region;
  5:mac_var:=global_room;
  6:if region.rooms>249 then mac_var:=global_xloc+((global_xchunk-1)*16)
     else mac_var:=global_xloc;
  7:if region.rooms>249 then mac_var:=global_yloc+((global_ychunk-1)*16)
     else mac_var:=global_yloc;
  8:mac_var:=ack.plvehicle;
  9:mac_var:=ack.viewdistance;
  10:mac_var:=ack.playericon;
  11:mac_var:=ack.pcash;
  12:mac_var:=random(data[ind,2]);
  13:mac_var:=ack.days;
  14:mac_var:=ack.hour;
  15:mac_var:=ack.minute;
  16:if keypressed then
   begin
    i:=ord(upcase(readkey));
    if i=0 then mac_var:=1 else mac_var:=i;
   end else mac_var:=0;
  17:mac_var:=ack.minviewdistance;
  18:mac_var:=escgoto;
  19:mac_var:=aggro;
  20:mac_var:=ack.torchduration;
  21:mac_var:=ack.level;
  22:mac_var:=ack.experience;
  23:mac_var:=macrosuccess;
  24:mac_var:=thisportal;
  25:if ack.fly=true then mac_var:=1 else mac_var:=0;
 { 27:if ack.autorun=true then mac_var:=1 else mac_var:=0;}
  28:mac_var:=ack.invisible;
  29:mac_var:=ack.invis_icon;
  33:mac_var:=region.room.wallgrap[5];
  34:mac_var:=region.room.wallgrap[6];
  end;
end;

procedure set_var(ind:byte;val:word);
 {set the value at index to val}
begin
 writelog(0,'setting system variable '+strnum(macro^[macropointer].data[ind,1])+
 ' ('+strnum(macro^[macropointer].data[ind,2])+') to '+strnum(val));
 with macro^[macropointer] do
  case data[ind,1] of
   36:setquestflag(data[ind,2],val);
   1:begin
       if data[ind,2]<8 then if val>255 then val:=255;
       ack.variables[data[ind,2]]:=val MOD 256;
       if data[ind,2]>7 then ack.variableshi[data[ind,2]]:=val DIV 256;

     end;
   30:begin
       if data[ind,2]<8 then if val>255 then val:=255;
       ack.variables2[data[ind,2]]:=val MOD 256;
       if data[ind,2]>7 then ack.variables2hi[data[ind,2]]:=val DIV 256;

     end;	
   2:begin
      if val>255 then val:=255;
     case data[ind,2] of
      0:ack.hp[0]:=val;
      1:ack.hpmax[0]:=val;
      2:ack.mp[0]:=val;
      3:ack.mpmax[0]:=val;
      4:ack.strength[0]:=val;
      5:ack.intelligence[0]:=val;
      6:ack.weapskill[0]:=val;
      7:ack.rweapskill[0]:=val;
      8:ack.alignment:=val;
	  9:ack.criminal:=val;
	  10:ack.regen_hp:=val;
	  11:ack.regen_mp:=val;
	  12:ack.poison:=val;
     end; {case2}
     end;
   3:begin
      if val>255 then val:=255;
      if data[ind,2]>1 then ack.Pinv[data[ind,2]]:=val else ack.pcash:=val;
      invchange:=true;
     end;
	
  31:begin

	   if obj^[data[ind,2]].t=9 then
       begin	
	    if val>0 then
	    begin
	     ack.parmor[obj^[data[ind,2]].d[2]]:=data[ind,2];
	     if ack.pinv[data[ind,2]]=0 then ack.pinv[data[ind,2]]:=1;
	    end;
	    if val=0 then
	     ack.parmor[obj^[data[ind,2]].d[2]]:=0;
	   end;
    end;

  32:begin;if val>255 then val:=255;ack.pweapready:=val;if val>0 then if ack.pinv[val]=0 then ack.pinv[val]:=1;end;
  33:region.room.wallgrap[5]:=val;
  34:region.room.wallgrap[6]:=val;
   4:begin;global_region:=val;macro_teleport:=true;end;
   5:begin;teleport_room:=val;global_room:=val;macro_teleport:=true;end;
   6:begin
      macro_teleport:=true;
      global_xloc:=(val-1) MOD 16 +1;
      global_xchunk:=(val-1) DIV 16 +1;
     end;
   7:begin
      macro_teleport:=true;
      global_yloc:=(val-1) MOD 16 +1;
      global_ychunk:=(val-1) DIV 16 +1;
     end;
   8:ack.plvehicle:=val;
   9:ack.viewdistance:=val;
   10:ack.playericon:=val;
   11:ack.pcash:=val;
   13:ack.days:=val;
   14:begin
       ack.hour:=val MOD 24;

      end;
   15:ack.minute:=val;
   17:ack.minviewdistance:=val;
   18:escgoto:=val;
   20:ack.torchduration:=val;
   21:if (val>0) and (val<11) then begin
       ack.level:=val;
       if val>1 then ack.experience:=ack.levelexp[val] else ack.experience:=0;

      end;
   22:ack.experience:=val;
   23:macrosuccess:=val;
   24:thisportal:=val;
   25:if val>0 then ack.fly:=true else ack.fly:=false;
   26:case data[ind,2] of
       1:ack.nomove_n:=(val>0);
       2:ack.nomove_s:=(val>0);
       3:ack.nomove_e:=(val>0);
       4:ack.nomove_w:=(val>0);
       else begin
              ack.nomove_n:=(val>0);
              ack.nomove_s:=(val>0);
              ack.nomove_e:=(val>0);
              ack.nomove_w:=(val>0);

            end;
      end; {case}
  { 27:if val>0 then ack.autorun:=true else ack.autorun:=false;}
   28:ack.invisible:=val;
   29:ack.invis_icon:=val;
  end;
end;

function arg_oper(val1:word;arg:byte;val2:word):word;
begin
 case arg of
  0:arg_oper:=val1;
  1:arg_oper:=val1+val2;
  2:if (val1-val2)<0 then arg_oper:=0 else arg_oper:=val1-val2;
  3:if val1=val2 then arg_oper:=1 else arg_oper:=0;
  6:arg_oper:=val1*val2;
  7:if val2<>0 then arg_oper:=round(val1/val2) else arg_oper:=0;
  9:arg_oper:=val1 AND val2;
  10:arg_oper:=val1 OR val2;
 end;
end;

type
 fourbytes=array[1..4] of byte;
var f4b:fourbytes; p4m:^masterrec absolute f4b;

procedure string4(fb:fourbytes;var s:string);
begin
 s:=concat(strnum(fb[1]),'-',strnum(fb[2]),'-',
                 strnum(fb[3]),'-',strnum(fb[4]));
end;




procedure execute(n:byte);
 var excf:file of excrec;
     exc:excrec;
     ss:string;
     sp:string;
     i,i1:integer;
     redisp,done:boolean;
     j:char;
begin

 assign(excf,ADVNAME+EXCFILE);
 {$I-} reset(excf); {$I+}
 if ioresult<>0 then exit;
 seek(excf,n);read(excf,exc);

  ss:=exc.prm;
  ack.PLregion:=global_region;
  ack.PLxloc:=global_xloc;
  ack.PLyloc:=global_yloc;
  ack.PLxch:=global_xchunk;
  ack.PLych:=global_ychunk;
  if region.rooms>240 then ack.PLych:=0;

 if exc.c1=1 then
  begin
   {non-swap}
   p4m:=@ack;
   string4(f4b,sp);ss:=exc.prm;
   i:=pos('%P',ss);
   if i<>0 then begin;delete(ss,i,2);insert(sp,ss,i);end;

   if exc.gmodein=1 then closegraph;
   exec(exc.fn,ss);
   if exc.gmodeout=1 then
    begin
     startupgraph;
     initmouse;
    end;
   swapinfo^.data[4]:=doserror;

  end else
  begin
   {swap}
   swapinfo^.execfile:=exc.fn;
   swapinfo^.execparam:=ss;
   swapinfo^.data[1]:=1;
   swapinfo^.data[2]:=exc.gmodein;
   swapinfo^.data[3]:=exc.gmodeout;
   swapinfo^.data[4]:=exc.c2;
   swapinfo^.data[5]:=macropointer;
   swapinfo^.data[6]:=thismacro;
   if swapinfo^.data[7]=0 then
    begin
     savemap;
     if region.rooms>99 then
      begin
       savewmap;
       ack.plxch:=global_xchunk;
       ack.plych:=global_ychunk;
       ack.plxloc:=global_xloc;
       ack.plyloc:=global_yloc;
      end else
      begin
       ack.PLxch:=global_room;
       ack.plxloc:=global_xloc;
       ack.plyloc:=global_yloc;
      end;
    end;

      ack.plregion:=global_region;

   saveconfig;

   shutdownsound;
   if exc.c4=1 then swapinfo^.data[10]:=1 else swapinfo^.data[10]:=0;
   halt;
         {hah! commands after the halt?  no...}

  end;

 if exc.gmodeout=1 then
  begin
   graphicsmode;
   titlebars;
  end;

(* say(1,1,6,exc.fn);
 say(1,10,6,ss);
 say(1,20,6,strnum(doserror));
 readln; *)
end;


var
 getadj_x, getadj_y, getadj_val: integer;

begin
 clear_keyboard_buffer;
 escgoto:=0;
 macrosuccess:=1;
 writelog(n,'-- Running macro');

invchange:=false;
hidemouse; pausemouse:=true;
while n<>0 do
begin
 thismacro:=n;

 if macroloaded<>n then loadmacro(n);
 macro^[0].next:=1;
 macropointer:=0;macrodone:=false;macroswitch:=0;
 if swapinfo^.data[1]=1 then
  begin
   macropointer:=swapinfo^.data[5];
   swapinfo^.data[1]:=0;
  end;
 repeat
  inc(macropointer);

  with macro^[macropointer] do
   begin
    writelog(thismacro,' macro line '+strnum(macropointer)+' command '+strnum(cmd));
    {writelog(macropointer,'cmd '+strnum(cmd)+' vars '+strnum(mac_var(1))+
    ' '+strnum(mac_var(2))+' '+strnum(mac_var(3))+' '+strnum(mac_var(4)));}
    case cmd of
	    49:begin {GETADJ}
		    clearbottom;
            say(7,188,0,'SELECT A DIRECTION');	
			
			getadj_val:=0;
		    repeat
			 j:=readkey;
			 case j of
			  #27:getadj_val:=27;
			  #0:case readkey of
			     {up} 'H':getadj_val:=1;
				 {down} 'P':getadj_val:=2;
				 {left} 'K':getadj_val:=3;
				 {right} 'M':getadj_val:=4;
				
			     end; {0}
		     end; {case}
			until getadj_val>0;
			clearbottom;
			if getadj_val=27 then
			begin
			 writelog(49,'GETADJ aborted');
			 i:=mac_var(3);
			 if i>0 then
			   macropointer:=i-1
			  else macrodone:=true;
			end else
			begin
			 if region.rooms>249 then
				 getadj_x:=global_xloc+((global_xchunk-1)*16)
                 else getadj_x:=global_xloc;
			 if region.rooms>249 then
				 getadj_y:=global_yloc+((global_ychunk-1)*16)
                 else getadj_y:=global_yloc;
			 writelog(49,'GETADJ '+strnum(getadj_val)+' from '+strnum(getadj_x)+','+strnum(getadj_y));				
			 case getadj_val of
			    1:{up}
                 if getadj_y>1 then dec(getadj_y);
				2:{down}
				 inc(getadj_y);
			    3:{left}
                 if getadj_x>1 then dec(getadj_x);
				4:{right}
				 inc(getadj_x);				
			 end; {case}
			 writelog(49,'GETADJ result loc: '+strnum(getadj_x)+','+strnum(getadj_y));
			 set_var(1,getadj_x);
			 set_var(2,getadj_y);
			end; {not 27}
		   end;
		50:begin {draw: x y to x y of color thickness}
            thickln2(mac_var(1),mac_var(2),mac_var(3),mac_var(4),mac_var(5),mac_var(6));
           end;
        33:fadeoutpal(mac_var(1));
        34:fadeinpal(mac_var(1));
        47:if (mac_var(2)>0) and (mac_var(2)<13) then
           begin
            ack.qtile[mac_var(2)]:=mac_var(1);
            quartertile(mac_var(2),mac_var(1));

           end;
        48:invertscr;
        46:begin
            for i:=1 to mac_var(1) DIV 60 do
             begin
              passtime(70);delay2(100);
              if ack.torchduration>40 then ack.torchduration:=ack.torchduration-40 else ack.torchduration:=0;
              {cycletime;}
             end;
             passtime( (mac_var(1) MOD 60) +10 );


           end;
 {set}  1:begin

            set_var(1,arg_oper(mac_var(3),data[4,1],mac_var(5)));
		  end;
 {goto} 2:macropointer:=mac_var(1)-1;
 {if}   3:begin
          w1:=mac_var(1); w2:=mac_var(3); w3:=mac_var(4);
		  i:=macropointer;
          case data[2,1] of
           3:begin;if w1 = w2 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'='+strnum(w2)+' then '+strnum(w3)+')');
		   end;
           4:begin;if w1 > w2 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'>'+strnum(w2)+' then '+strnum(w3)+')');
		   end;
           5:begin;if w1 < w2 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'<'+strnum(w2)+' then '+strnum(w3)+')');
		   end;
		   8:begin;if w1 <> w2 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'!'+strnum(w2)+' then '+strnum(w3)+')');
		   end;
		   9:begin;if (w1 AND w2)>0 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'&'+strnum(w2)+' then '+strnum(w3)+')');
		   end;
		   10:begin;if (w1 OR w2)>0 then macropointer:=w3-1;
		   writelog(macropointer,' (if '+strnum(w1)+'|'+strnum(w2)+' then '+strnum(w3)+')');
		   end;		
          end; {3case}
		
		  if macropointer=-1 then
		   begin {the condition was true}

		    macropointer:=i; {leaves macro pointer unchanged: this line (next line will be next)}
		   end else
		    if w3=0 then
			begin {the condition was false, skip past any more if0's, then skip one more line.}
			 i:=i+2; {sets macro pointer to line after next}
			 while ((macro^[i-1].cmd=3) and
			  ((macro^[i-1].data[4,1]=0) and (macro^[i-1].data[4,3]=0)))
			  do inc(i);
			 {if the next line is another if0, skip again}
			
			 macropointer:=i-1;
			end;
		
         end;
 {smsg} 4:if mac_var(1)<>0 then
          begin
           clearbottom;
           savestrip;
           load_shortmsgfile(mac_var(1));
           show_shortmsg;
           waitkey;
           restorestrip;
          end else internal_shortmsg;
 {bmsg} 28:if mac_Var(1)<>0 then
           begin
            load_shortmsgfile(mac_Var(1));
            clearbottom;
            for i:=1 to 37 do
             begin
              putletter(i*2+1,180,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
              putletter(i*2+1,188,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
             end;
			 erasebottom:=4;
           end else clearbottom;
 {fixpal}  36:begin
               fixpalette;
              end;
 {showbmp} 35:showbmp(mac_var(1),false);


 {lmsg} 5:begin
           load_longmsgfile(mac_var(1));
           show_longmsg;
          end;
 {picture} 42:picturemessage(mac_var(1));
 {qaction} 43:begin
               inc(queued_actions);
			   writelog(queued_actions,'queue-action '+strnum(mac_var(1))+' '+strnum(mac_var(2)));
               queued_action[queued_actions,1]:=mac_var(1);
               queued_action[queued_actions,2]:=mac_var(2);
              end;
  {tbmp}   44:showbmp(mac_var(1),true);
 {delayk} 45:begin
               clear_keyboard_buffer;
               if delayk(mac_var(1)*100) then
                if escgoto<>0 then macropointer:=escgoto-1;
             end;
 {clrscr} 6:clearscreen;

 {wkey} 7:waitkey;
 {gkey} 8:begin
           clear_keyboard_buffer;
           j:=upcase(readkey);set_var(1,ord(j));if j=#0 then
		    case readkey of
			     {up} 'H':set_var(1,128);
				 {down} 'P':set_var(1,129);
				 {left} 'K':set_var(1,130);
				 {right} 'M':set_var(1,131);
			
			end; {case}
          end;
 {exec} 29:begin
            execute(mac_var(1));
           end;
 {music}  39:if mac_var(1)=0 then stopsound(2) else soundeffect(mac_var(1),2);
 {ambient}  40:if mac_var(1)=0 then stopsound(3) else soundeffect(mac_var(1),3);
 {speech}  41:if mac_var(1)=0 then stopsound(4) else soundeffect(mac_var(1),4);

 {snd}  9:if mac_var(1)=0 then stopsound(0) else soundeffect(mac_var(1),1);

       12:if loadmosaic(mac_var(1)) then transparent_mosaic;

       32:restorepage;
     30:begin
         clearbottom;
         if region.rooms>249 then
          say(15,184,0,'YOU ARE AT ('+
           strnum(global_xloc+((global_xchunk-1)*16))+','+
           strnum(global_yloc+((global_ychunk-1)*16))+')')
          else say(15,184,0,'YOU ARE AT ('+strnum(global_xloc)+','+
           strnum(global_yloc)+')');

        end;
     31:begin
	     loadmapcolors;
         if region.rooms>249 then
         begin
          setcolor(15);line(5,148,5,197);
          line(5,148,54,148);line(54,148,54,197);
          line(5,197,54,197);
          for i:=1 to 3 do for i1:=1 to 3 do
           for i2:=1 to 16 do for i3:=1 to 16 do
		    putpixel(i*16+i2-11,i1*16+i3+132,mapcolors[map[i,i1,i2,i3].o])

         end else
         begin
          setcolor(15);line(5,156,5,197);
          line(5,156,54,156);line(54,156,54,197);
          line(5,197,54,197);
          i:=global_xloc+region.room.x1[global_xchunk]-1;
          i:=i-24;
          if i<1 then i:=1;
          if i>33 then i:=33;
          for i1:=i to i+47 do for i2:=1 to 40 do
           begin
            llp:=rmcnt^[i1,i2];
            if (llp=0)
             then putpixel(i1-i+6,156+i2,mapcolors[0]) else
             putpixel(i1-i+6,156+i2,mapcolors[locnt^[llp].obj]);
           end;

         end;
         say(15,188,0,'PRESS A KEY.');
         if region.rooms>249 then
          while not keypressed do
           putpixel(21+global_xloc,164+global_yloc,random(16)) else
          while not keypressed do
           putpixel(global_xloc+region.room.x1[global_xchunk]-i+5,
            155+global_yloc+region.room.y1[global_xchunk],random(16));
         clear_keyboard_buffer;
        end;
     13:ack.countarmor[mac_var(1)]:=0;
     14:ack.countarmor[mac_var(1)]:=1;
     15:case mac_var(3) of {sayval}
        1..22:say(mac_var(2)*2-1,mac_var(3)*8-6,0,strnum(mac_var(1)));
        23,24:say(mac_var(2)*2-1,(mac_var(3)-22)*8+163,0,strnum(mac_var(1)));
        25,26:say(mac_var(2)*2-1,(mac_var(3)-24)*8+172,0,strnum(mac_var(1)));
        end;
     16:begin {set portal}
         i:=mac_var(1); if i=0 then i:=255;
         region.port[i].region:=mac_var(2);
        if mac_var(3)<>0 then
         begin  {room - xc is the room number, yc is 0}
          region.port[i].rx:=mac_var(3);
          region.port[i].ry:=0;
          region.port[i].x:=mac_var(4);
          region.port[i].y:=mac_var(5);
         end else
         begin
          region.port[i].rx:=(mac_var(4)-1) DIV 16 +1;
          region.port[i].ry:=(mac_var(5)-1) DIV 16 +1;
          region.port[i].x:=(mac_var(4)-1) MOD 16 +1;
          region.port[i].y:=(mac_var(5)-1) MOD 16 +1;
         end;
        end;
     22:macrodone:=true;
     23:begin;shutdownsound;halt;end;
	 10,11,24..27:begin {'MAPADD','MAPTAKE','MAPSET','MAPSETD','MAPLOOK','MAPLOOKD'}
	     if cmd<=24 then begin
	      readkey_time:=0;
          if readkey_default<>#201 then readkey_default:=#255;  {trigger a map refresh after}
		 end;
	     if region.rooms>249 then
		  begin {world map}
			  tempxch:=2+ ( (((mac_var(1)-1) DIV 16)+1) - global_xchunk);
			  tempych:=2+ ( (((mac_var(2)-1) DIV 16)+1) - global_ychunk);
              tempxlo:= (mac_var(1)-1) MOD 16 +1;
              tempylo:= (mac_var(2)-1) MOD 16 +1;
			  writelog(cmd,' map: '+strnum(mac_var(1))+','+strnum(mac_var(2))+' --> '+
			   strnum(tempxch)+','+strnum(tempych)+','+strnum(tempxlo)+','+strnum(tempylo)+','+
			   ' (player at chunk '+strnum(global_xchunk)+','+strnum(global_ychunk)+')');

	(*	   if abs( global_xchunk - (((mac_var(1)-1) DIV 16)+1) ) < 2 then
		    if abs( global_ychunk - (((mac_var(2)-1) DIV 16)+1) ) < 2 then
	*)	
	       if (tempxch>0) and (tempxch<4) and (tempych>0) and (tempych<4) then
			 begin
			  {specified location is close enough -- do stuff.}
			  case cmd of
			   10:flopitem(((tempxch-1)*16)+tempxlo-1,((tempych-1)*16)+tempylo-1,mac_var(3),0);
			   11:if (obj^[map[tempxch,tempych,tempxlo,tempylo].o].t>5) or (map[tempxch,tempych,tempxlo,tempylo].o=255) then
			       if (mac_var(3)=0) or (mac_var(3)=map[tempxch,tempych,tempxlo,tempylo].o) then
				   begin
				    writelog(0,'maptake: '+strnum(map[tempxch,tempych,tempxlo,tempylo].o));
					
					if map[tempxch,tempych,tempxlo,tempylo].o=255 then
					begin
					 i:=map[tempxch,tempych,tempxlo,tempylo].d;
					 map[tempxch,tempych,tempxlo,tempylo].o:=rcrc^[i].obj;
					 map[tempxch,tempych,tempxlo,tempylo].d:=rcrc^[i].objdata;
					 rcrc^[i].show:=false;
					end else
					begin
				     i:=map[tempxch,tempych,tempxlo,tempylo].d;
					 map[tempxch,tempych,tempxlo,tempylo].o:=veh[i].obj;
					 map[tempxch,tempych,tempxlo,tempylo].d:=veh[i].objcode;
					 veh[i].used:=false;
                    end;
				   end else writelog(0,'maptake failed');
			   24:begin
			       i:=map[tempxch,tempych,tempxlo,tempylo].o;
				   i1:=mac_var(3);
			       if obj^[i1].t=5 then if obj^[i].t<>5 then map[tempxch,tempych,tempxlo,tempylo].d:=255;
					
			       map[tempxch,tempych,tempxlo,tempylo].o:=i1;
				
				  end;
			   25:map[tempxch,tempych,tempxlo,tempylo].d:=mac_var(3);
			   26:begin;set_var(3,map[tempxch,tempych,tempxlo,tempylo].o);
			       writelog(0,'maplook: '+strnum(map[tempxch,tempych,tempxlo,tempylo].o));
				   end;
			   27:set_var(3,map[tempxch,tempych,tempxlo,tempylo].d);
			
			  end; {case}
		
		     end else writelog(cmd,' map location not close enough'); {proximity}
		
		
		  end {world map} else
		  begin {room map}
		      tempxlo:=mac_var(1);
			  tempylo:=mac_var(2);
              tempxch:=region.room.x1[global_xchunk] + tempxlo -1;
              tempych:=region.room.y1[global_xchunk] + tempylo -1;
			  temppoint:=rmcnt^[tempxch,tempych];
			  writelog(cmd,' map editing: '+strnum(mac_var(1))+','+strnum(mac_var(2))+' --> '+
			   strnum(tempxch)+','+strnum(tempych)+':'+strnum(temppoint)+' room '+strnum(global_xchunk));

			
			  case cmd of
			   10:begin
			     addslot:=0;
                 if locntsize>5000 then for addslotc:=1 to locntsize do
                  if locnt^[addslotc].obj=0 then addslot:=addslotc;
                 if addslot=0 then if locntsize<LOCNTMAX then
                  begin;addslot:=locntsize+1;inc(locntsize);end;
				  writelog(0,'addslot: '+strnum(addslot));
                 if addslot<>0 then
				 begin
				  rmcnt^[tempxch,tempych]:=addslot;
				  locnt^[addslot].p:=temppoint;
				  locnt^[addslot].obj:=mac_var(3);
				  locnt^[addslot].objcode:=0;
				  map[2,2,tempxlo,tempylo].o:=mac_var(3);
				  map[2,2,tempxlo,tempylo].d:=0;
				 end;
			    end; {10}
			   11:if (mac_var(3)=0) or (mac_var(3)=map[2,2,tempxlo,tempylo].o) then
			     begin
			       rmcnt^[tempxch,tempych]:=locnt^[temppoint].p;
				   locnt^[temppoint].obj:=0;
				   temppoint:=rmcnt^[tempxch,tempych];
				   if temppoint<>0 then
				    begin
					 map[2,2,tempxlo,tempylo].o:=locnt^[temppoint].obj;
				     map[2,2,tempxlo,tempylo].d:=locnt^[temppoint].objcode;
					end else map[2,2,tempxlo,tempylo].o:=0;
			      end;
			   24:begin
			
			   		i:=map[2,2,tempxlo,tempylo].o;
				    i1:=mac_var(3);
			        if obj^[i1].t=5 then if obj^[i].t<>5 then
					 begin
					  map[2,2,tempxlo,tempylo].d:=255;
					  locnt^[temppoint].objcode:=255;
					 end;
					
			        map[2,2,tempxlo,tempylo].o:=i1;
					locnt^[temppoint].obj:=i1;
				  end;
			   25:begin;map[2,2,tempxlo,tempylo].d:=mac_var(3);locnt^[temppoint].objcode:=mac_var(3);end;
			   26:set_var(3,map[2,2,tempxlo,tempylo].o);
			   27:set_var(3,map[2,2,tempxlo,tempylo].d);
			
			  end; {case}		
		
		  end;
	
	    end;

		
     17:delay2(mac_var(1)*100);
     19:savepage;
     20:begin
         if loadmosaic(mac_var(1)) then showmosaic;
        end;
     21:begin
         macroswitch:=mac_var(1);
         macrodone:=true;
        end;
    end; {case cmd}
    if next=0 then macrodone:=true;
   end;
 until macrodone;
 n:=macroswitch;
 end; {while}
 if invchange then
  begin
   for n:=1 to 7 do if ack.parmor[n]<>0 then
    if ack.pinv[ack.parmor[n]]=0 then ack.parmor[n]:=0;
  end;
pausemouse:=false; showmouse;
 writelog(n,'-- Ending macro');
 clear_keyboard_buffer;
end;

(*
         macropointer:=0;loadmacro(mac_var(1));
         macro^[0].next:=1;macrodone:=false;
*)



{$I I_BYTCPY.PAS}


function bytecopybunch(ext,newext:char):word;
var
  sr:searchrec;
  newfn:string;
  count:word;
begin
   count:=0;
   findfirst(ADVNAME+'.'+ext+'*',anyfile,sr);
   while doserror=0 do
    begin
     inc(count);
     newfn:=sr.name;newfn[pos('.',newfn)+1]:=newext;
     bytecopy(sr.name,newfn);
     findnext(sr);
    end;
    bytecopybunch:=count;
end;

function countfiles(ext:string2):word;
var sr:searchrec;
    count:word;
begin
 count:=0;
 findfirst(ADVNAME+'.'+ext,anyfile,sr);
 while doserror=0 do
  begin
   inc(count);
   findnext(sr);
  end;
 countfiles:=count;
end;


function bytecopybunch2(ext,newext:char):word;
var
  sr:searchrec;
  newfn:string;
  count:word;
  s:string; i,ie:integer;
begin
   count:=0;
   findfirst(ADVNAME+'.'+ext+'*',anyfile,sr);
   while doserror=0 do
    begin
     newfn:=sr.name;newfn[pos('.',newfn)+1]:=newext;
     s:=copy(sr.name,pos('.',sr.name)+2,length(sr.name)-pos('.',sr.name)-1);
     val(s,i,ie);
     if (ie<>0) or (modified[i]) then
      begin;bytecopy(sr.name,newfn);inc(count);end;
     findnext(sr);
    end;
    bytecopybunch2:=count;
end;


function countfiles2(ext:string2):word;
var sr:searchrec;
    count:word;
    s:string;
    i,ie:integer;
begin
 count:=0;
 findfirst(ADVNAME+'.'+ext,anyfile,sr);
 while doserror=0 do
  begin
   s:=copy(sr.name,pos('.',sr.name)+2,length(sr.name)-pos('.',sr.name)-1);
   val(s,i,ie);
   if (ie<>0) or (modified[i]) then inc(count);
   findnext(sr);
  end;
 countfiles2:=count;
end;


procedure deletebunch(ext:string4);
var
  sr:searchrec;
  f:file;
begin
   findfirst(ADVNAME+'.'+ext,anyfile,sr);
   while doserror=0 do
    begin
     assign(f,sr.name);
     erase(f);
     findnext(sr);
    end;
end;

procedure fullgamesave;
 var t0:word;
begin
  t0:=(countfiles2('1*')*3+2);
  say(71,182,1,strnum(t0)+' ');
  dec(t0,bytecopybunch2('1','X'));
  say(71,182,1,strnum(t0)+' ');
  dec(t0,bytecopybunch2('2','Y'));  {Copy play temp files to save-backup}
  say(71,182,1,strnum(t0)+' ');
  dec(t0,bytecopybunch2('3','Z'));
  say(71,182,1,strnum(t0)+' ');
  bytecopy(ADVNAME+TEMPMASTERFILE,ADVNAME+PLAYMASTERFILE);
  bytecopy(ADVNAME+'.RGT',ADVNAME+'.RGX');
  deletebunch('DQS');
  if file_exists(ADVNAME+'.DQT')<>'' then bytecopy(ADVNAME+'.DQT',ADVNAME+'.DQS');
  say(71,182,0,'   ');
  for t0:=1 to 99 do modified[t0]:=false;
end;


var    hpregen_leftover, mpregen_leftover:real;

procedure cycletime;
 var c:byte; newhour:byte;
    hpregen:real; mpregen:integer;
begin
 writelog(0,'cycletime begin');


 hpregen:=(((ack.regen_hp*ack.strength[0]) / 2000) - (ack.poison / 10)) + hpregen_leftover;


 if hpregen>=0 then
  begin
   {regenerating}
   hpregen_leftover:=hpregen - trunc(hpregen);
   hpregen:=trunc(hpregen);
   if ack.hp[0]+hpregen>ack.hpmax[0] then ack.hp[0]:=ack.hpmax[0] else
    ack.hp[0]:=ack.hp[0]+trunc(hpregen);
  end else
  begin
   {poisoned}
   hpregen_leftover:= -1 * ( abs(hpregen) - trunc(abs(hpregen)));
   hpregen:= trunc(abs(hpregen));
   if ack.hp[0]-hpregen>0 then ack.hp[0]:=ack.hp[0]-trunc(hpregen) else
    ack.hp[0]:=0;
  end;



 mpregen:= trunc((ack.regen_mp*ack.intelligence[0]) / 2000);
 mpregen_leftover:= mpregen_leftover + ((ack.regen_mp*ack.intelligence[0]) / 2000) -
   trunc((ack.regen_mp*ack.intelligence[0]) / 2000);

 if mpregen_leftover>=1 then
  begin
   mpregen_leftover:=mpregen_leftover-1;
   mpregen:=mpregen+1;
  end;
 if ack.mp[0]+mpregen>ack.mpmax[0] then ack.mp[0]:=ack.mpmax[0] else
  ack.mp[0]:=ack.mp[0]+mpregen;


 if ack.ackversion>24 then
 begin
 if ack.hourmacro<>0 then
 if ack.hour<>oldhour then
  begin
    if oldhour>ack.hour then newhour:=ack.hour+24 else newhour:=ack.hour;
    for c:=oldhour+1 to newhour do
	 begin
	  writelog(c,'Running hour macro, '+strnum(oldhour+1)+'-'+strnum(newhour));
      run_macro(ack.hourmacro);
	 end;
    oldhour:=ack.hour;
  end;
 end;
 if ack.torchduration>0 then begin;dec(ack.torchduration);if ack.torchduration=0 then ack.minviewdistance:=1;end;
 if ack.invisible>0 then if ack.invisible<>255 then dec(ack.invisible);
 if region.shadow=1 then if ack.time_cycle<>0 then
 case ack.hour of
  7..17:ack.viewdistance:=17;
  6,18:ack.viewdistance:=4;

  4:ack.viewdistance:=2;
  5:ack.viewdistance:=3;

  19:ack.viewdistance:=3;
  20:ack.viewdistance:=2;

  else ack.viewdistance:=1;
 end;


 case ack.hour of
 4,5:timepic:=1;
 6,7:timepic:=2;
 8,9:timepic:=3;
 10..13:timepic:=4;
 14..16:timepic:=5;
 17,18:timepic:=6;
 19,20:timepic:=7;
 else timepic:=0;
 end;
 showtimepic;

end;





procedure showtimebmp(n:byte);
var bmpf:file;
    i,i2:integer;
    b,t:byte;
    line:array[0..319] of byte;
    name:string;
    header:array[1..54] of byte;

begin
               {first 54 bytes: header}
               {next 1024- bytes: pal in B-G-R-0}
               {next 64000 bytes: bitmap itself}

               {clear screen}
               {load new palette}

  name:=file_exists('TSKIN'+strnum(thisregion)+'.BMP');
  if name='' then name:=file_exists('TSKIN.BMP');
  if name='' then name:=bgi_dir+'SKINS\TSKIN.BMP';

  assign(bmpf,name);
  {$I-} reset(bmpf,1); {$I+}
  if ioresult=0 then

   begin
    writelog(n,'showtimebmp reading file '+name);
    BlockRead(bmpf,header,SizeOf(header));
    i2:=header[51];
    if i2=0 then i2:=256;
    seek(bmpf,54+(i2*4)+(n*3200));


    {seek(bmpf,1078+( n*3200 ) );}
    for i:=1 to 10 do
     begin
      blockread(bmpf,line[0],320);
      move(line[320-58],mem[scrnl:scrnh[10-i]+(320-58)],58);
     end;



    close(bmpf);

   end; {if ioresult=0}

   for i:=1 to 6 do
    if ack.qtile[i]<>0 then
     quartertile(i,ack.qtile[i]);

end;




procedure menuskinbmp;
var bmpf:file;
    i,i2:integer;
    b,t:byte;
    line:array[0..319] of byte;
    header:array[1..54] of byte;
    name:string;

begin
               {first 54 bytes: header}
               {next 1024- bytes: pal in B-G-R-0}
               {next 64000 bytes: bitmap itself}

               {clear screen}
               {load new palette}
  if region.rooms<20 then
   begin
    name:=file_exists('RMSKIN'+strnum(thisregion)+'.BMP');
    if name='' then name:=file_exists('RMSKIN.BMP');
    if name='' then name:=bgi_dir+'SKINS\RMSKIN.BMP';
   end else
   begin
    name:=file_exists('WMSKIN'+strnum(thisregion)+'.BMP');
    if name='' then name:=file_exists('WMSKIN.BMP');
    if name='' then name:=bgi_dir+'SKINS\WMSKIN.BMP';
   end;


  assign(bmpf,name);
  {$I-} reset(bmpf,1); {$I+}
  if ioresult=0 then

   begin
    BlockRead(bmpf,header,SizeOf(header));
    i2:=header[51];
    if i2=0 then i2:=256;
    seek(bmpf,54+(i2*4));

    for i:=0 to 199 do
      begin
       blockread(bmpf,line[0],320);
       {move(line[132],mem[scrnl:132+scrnh[i]],(199-132));}
       move(line[0],mem[scrnl:scrnh[199-i]],320);

     end;



    close(bmpf);

   end; {if ioresult=0}
  { for i:=1 to 12 do
    if ack.qtile[i]<>0 then
     quartertile(i,ack.qtile[i]); }

end;










procedure showtimepic;
var s:string[7];
    hh,mm:string[2];
begin



 if ack.ackversion<30 then exit;
 if ack.showclock=0 then
  begin
   for i:=1 to 6 do
    if ack.qtile[i]<>0 then
     quartertile(i,ack.qtile[i]);

  end;
 if ack.showclock=1 then
   begin
    {digital clock}
    hh:=strnum(ack.hour); if ack.hour<10 then hh:=' '+hh;
    mm:=strnum(ack.minute); if ack.minute<10 then mm:='0'+mm;

    case ack.hour of
     1..11:s:=hh+':'+mm+'AM';
     12:s:='12:'+mm+'PM';
     13..23:s:=strnum(ack.hour)+':'+mm+'PM';
     0:s:='12:'+mm+'AM';
    end;
    say(66,0,0,s);




   end;
if ack.showclock=2 then begin

 if region.shadow<>1 then
  begin
    if region.shadow=0 then
     begin
      if oldtimepic<>9 then
	  begin
      oldtimepic:=9;
      showtimebmp(9);
      end;

     end else
     begin
      if oldtimepic<>8 then
	  begin
      oldtimepic:=8;
      showtimebmp(8);
	  end;
     end;
  end;
 if region.shadow=1 then
  if oldtimepic<>timepic then
  begin

   showtimebmp(timepic);

   oldtimepic:=timepic;
  end;
end;


end;

procedure mutesoundmenu;
 var j:char;
begin
 clearbottom;

 {
 bottomsay(1,'MUTE: N:NOTHING M:MUSIC A:ALL');
 bottomsay(2,'PRESS A KEY OR ESC TO CANCEL');
 j:=upcase(readkey);
 case j of
  'N':begin;disable_sound:=false;disable_music:=false;end;
  'M':begin;disable_sound:=false;disable_music:=true;stopsound(2);end;
  'A':begin;disable_sound:=true;disable_music:=true;stopsound(0);end;
  end;
 }
 bottomsay(1,'ENTER VOLUME (0-5) OR PRESS M TO');
 bottomsay(2,'                    TOGGLE MUSIC');
 j:=upcase(readkey);
 case j of
  '0'..'5':setvolume((ord(j)-48)*3);
  'M':begin
      disable_music:=not(disable_music);
	  if disable_music then stopsound(2);
	  end;
 end;

 clearbottom;
end;

procedure levelup;
 var i:byte;
begin
 if ack.ackversion<25 then exit;
 if ack.level>9 then exit;
 for i:=ack.level+1 to 10 do
  if ack.experience>ack.levelexp[i] then
   begin
    run_macro(ack.levelmacro[i]);
    ack.level:=i;
   end;
end;

procedure passtime(settimestep:byte);
var timestep:byte;
begin
 if settimestep=255 then exit;
 if settimestep<11 then
  begin
   timestepsec:=timestepsec + ( (settimestep+1) * 5 );
   timestep:=timestepsec DIV 60;
   timestepsec:=timestepsec MOD 60;

  end else timestep:= settimestep-10;

 ack.hour:=ack.hour+((ack.minute+timestep) DIV 60);
 ack.minute:=(ack.minute+timestep) MOD 60;
 ack.days:=ack.days+(ack.hour DIV 24);
 if ack.days<>ack.old_days then if ack.day_macro<>0 then
  run_macro(ack.day_macro);
 ack.old_days:=ack.days;
 ack.hour:=ack.hour MOD 24;
end;

procedure initdelay;
var
 h,m,s,ms:word;
begin
 gettime(h,m,s,ms);
 starting_h:=h;
end;

begin
 initdelay;
 lastmov:=0;
 oldtimepic:=99;
 timepic:=99;
{ shownHP:=false;
 shownMP:=false;}
 nextanim:=0;
 oops_i_missed:=false;
{ greg.ax:=$1017;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(dpal[0,0]);
 greg.dx:=ofs(dpal[0,0]);
 intr($10,greg); }
 timestepsec:=0;
 hpregen_leftover:=0;
 mpregen_leftover:=0;
 newwmapload:=false;
 pausemouse:=false;
 brandnewgame:=false;
 teleport_room:=0;
 resurrect:=false;
end.
