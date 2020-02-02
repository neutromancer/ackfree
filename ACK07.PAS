{ ObjectEdit }

{$M 32000,32000,200000}
uses u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_io,u_help,u_sound,u_ack04;

{$I I_MSTREC.PAS}
{$I I_SNDEFF.PAS}

var wobj:byte;

   crc:^crcarray;
   ack:masterrec;
   mapcolors:array[0..255] of byte;

procedure save_objs;
 var f:file of objectrec;fc:byte;
begin
 assign(f,concat(ADVNAME,OBJECTFILE));
 {$I-} rewrite(f); {$I+}
 if Ioresult<>0 then exit;
 for fc:=1 to MAXOBJS do write(f,obj^[fc]);
 close(f);
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

procedure savemapcolors;
var cf:file of byte;
    i:byte;
begin
 assign(cf,ADVNAME+'.MCO');
 {$I-} rewrite(cf); {$I+}
 if ioresult<>0 then exit;
 for i:=0 to 255 do write(cf,mapcolors[i]);
 close(cf);
end;

var sync_app: byte;
function upcase_sync(r: char): char;

begin
 {search and replace and change all upcase (readkey) to upcase_sync (readkey) }
 if r=#9 then
 begin
  loadgraps;
  save_objs;
  savemapcolors;
  if loadcreatures then begin end;
  sound(500);delay(100);sound(1000);delay(100);nosound;
 end;
 upcase_sync:=upcase(r);
end;


procedure loadmapcolors;
var cf:file of byte;
    i:byte;
begin
 assign(cf,ADVNAME+'.MCO');
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then
  begin
   mapcolors[i]:=0; mapcolors[255]:=0;
   for i:=1 to 254 do if obj^[i].t>5 then mapcolors[i]:=15 else mapcolors[i]:=i;
  end else
  begin
   for i:=0 to 255 do read(cf,mapcolors[i]);
   close(cf);
  end;
end;







procedure clearobj(o,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14:byte);
begin
 with obj^[o] do begin
  d[1]:=d1;
  d[2]:=d2;
  d[3]:=d3;
  d[4]:=d4;
  d[5]:=d5;
  d[6]:=d6;
  d[7]:=d7;
  d[8]:=d8;
  d[9]:=d9;
  d[10]:=d10;
  d[11]:=d11;
  d[12]:=d12;
  d[13]:=d13;
  d[14]:=d14;
 end;
end;


procedure initobjs;
var i,i1:integer;
begin
 i:=1;
  with obj^[i] do begin
   n:='DOLLAR';
   t:=12;
   clearobj(1, 1,00,00,00,00,00,00,00, 0, 0, 0, 1, 0, 0);
  end;
 for i:=2 to MAXOBJS do
  begin
   obj^[i].t:=0;
  end;
 end;

{$I I_PPLED1.PAS}
{$I I_SNDNAM.PAS}
{$I I_OBJED0.PAS}
{$I I_OBJED1.PAS}
{$I I_OBJED2.PAS}
{$I I_OBJED4.PAS}

var cmdch:char;

function presetaction(act:byte):byte;
 var b:byte;
begin
 case act of
  0..3,14,15,17..38:b:=0;
  4..13:b:=1;       {set the actionparam to its default}
  16:b:=6;
  39:b:=16;
 end;
presetaction:=b;
end;


function editactionp(act,xloc,yloc:byte;var actp:byte):boolean; {redisplay?}
 var newactp:byte;
     ss:string[6];
     i,i1:integer;
     redisp:boolean;
begin
 redisp:=false;
 newactp:=actp;
        case act of
          0:exit;
          1:messager(xloc,yloc,actp);
          2:longmessager(xloc,yloc,actp);
          3,37:begin;
                  if act=37 then xloc:=xloc+10 else xloc:=xloc+14;
                  say(xloc,yloc,0,'#    ');
                  ss:=readlin(xloc+2,yloc,3,1);
                  val(ss,i,i1);if i1<>0 then i:=0;
                  if ss<>#27 then actp:=i;
                  if actp<>0 then say(xloc,yloc,1,'#'+strnum(actp)+'   ')
                   else say(xloc,yloc,1,'NONE ');
                 end;
         4:begin
           say(xloc-2,yloc,2,'ˆ');
           repeat
            say(xloc,yloc,0,stractionp(act,actp,true));
           until updown(actp,0,NUMSOUNDS)>0;
           soundeffect(actp,1);
           redisp:=true;
          end;
        40:begin
            actp:=grap_select_window(actp,actp);
            redisp:=true;
           end;
        13,41:begin
            say(xloc,yloc,2,'G,E,N,A?');
            case upcase_sync(readkey) of
             'E':actp:=2;
             'N':actp:=3;
             'A':actp:=4;
             else actp:=1;
            end;
            redisp:=true;
           end;
        5,7:begin
             say(xloc-2,yloc,2,'ˆ');
             repeat
              if shortint(actp)<0 then ss:=strnum(shortint(actp))
              else ss:=concat('+',strnum(shortint(actp)));
              if actp=0 then ss:='NORMAL' else ss:=ss+'    ';
              say(xloc,yloc,0,ss);
             until updowni(shortint(actp),-100,100)>0;
            end;
        6,8..12:begin
             say(xloc-2,yloc,2,'ˆ');
             repeat
              if shortint(actp)<0 then ss:=strnum(shortint(actp))
              else ss:=concat('+',strnum(shortint(actp)));
              say(xloc,yloc,0,ss+'   ');
             until updowni(shortint(actp),-100,100)>0;
            end;
        14,15,17:begin
               say(1,183,0,'SELECT THE ITEM.                   ');
               say(1,191,0,'                                   ');
              actp:=selectobj(103,actp);
              redisp:=true;
              end;
        16:begin
           say(xloc-2,yloc,2,'ˆ');
           repeat
            say(xloc,yloc,0,objnames[actp]);
           until updown(actp,6,12)>0;
           redisp:=true;
          end;
        18,19,20:begin
                say(1,183,0,'SELECT THE OBJECT.                 ');
                say(1,191,0,'                                   ');
                if act=19 then i:=111 else i:=0;
                actp:=selectobj(i,actp);
                redisp:=true;
               end;
         22,23:begin
                say(1,183,0,'SELECT THE WEAPON TO BE USED.      ');
                say(1,191,0,'                                   ');
                actp:=selectobj(104,actp);
                redisp:=true;
               end;
          24:if creatureok then begin
                say(1,183,0,'SELECT THE CREATURE TO BE SUMMONED.');
                say(1,191,0,'                                   ');
                actp:=selectcreature(actp);
                redisp:=true;
               end;
          42,43:begin
                 ss:=readlin(xloc,yloc,4,1);
                 val(ss,i,i1);
                 if i1=0 then case i of
                  1..9:actp:=240+i;
                  10..255:actp:=i DIV 10;
                  else actp:=0;
                 end;
                end;
          25..36,39,44..47:begin
                  ss:=readlin(xloc,yloc,3,1);
                  val(ss,i,i1);
                  if i1=0 then if (i>=0) and (i<=255) then actp:=i;
                 end;
          38: begin
               say(xloc-2,yloc,2,'ˆ');
               newactp:=hinyb(actp);
               repeat
                case readkey of
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
        editactionp:=redisp;
      end; {editactionp}

function edittriggerp(trig,xloc,yloc:byte;var trigp:byte):boolean; {redisplay?}
 var newtrigp:byte;
     ss:string[4];
     i,i1:integer;
     redisp:boolean;
begin
 redisp:=false;
 newtrigp:=trigp;
        case trig of
         14:messager(xloc,yloc,trigp);
         2..5,8..12:begin
            say(1,183,0,'SELECT THE ITEM.                   ');
            say(1,191,0,'                                   ');
            if trig=11 then
             trigp:=selectobj(104,0)
            else if trig<>12 then
             trigp:=selectobj(103,trigp)
             else trigp:=selectobj(103,0);
            redisp:=true;
           end;
        end; {case}
        edittriggerp:=redisp;
      end; {edittriggerp}

function editpassp(pass,xloc,yloc:byte;var passp:byte):boolean; {redisplay?}
 var newpassp:byte;
     ss:string[4];
     i,i1:integer;
     redisp:boolean;
begin
 redisp:=false;
 newpassp:=passp;
        case pass of
         0,1,20:exit;
         19:begin
             say(xloc,yloc,0,'DRAIN:');
             ss:=readlin(xloc+13,yloc,3,1);
             val(ss,i,i1);
             if i1=0 then if (i>=0) and (i<=255) then passp:=i;
            end;
		 24,25:begin
             say(1,183,0,'PRESS A LETTER TO SELECT A VARIABLE');
             say(1,191,0,'OR PRESS "2" TO USE A SET-2 VAR.   ');
             passp:=ord(upcase(readkey));
			 case passp of
			  65..90:passp:=passp-64;
			  50:begin
			      say(1,183,0,'USING A SET-2 VAR...               ');
                  say(1,191,0,'PRESS THE LETTER OF THE VAR TO USE ');

			      passp:=ord(upcase(readkey));
				  if (passp>=65) and (passp<=90) then
				   passp:=(passp-64) +26
				   else passp:=0;
			     end;
			  else passp:=0;
             end; {case}			
             redisp:=true;
             end;		
         2,3,4:begin
             say(1,183,0,'SELECT THE ITEM.                   ');
             say(1,191,0,'                                   ');
             passp:=selectobj(103,passp);
             redisp:=true;
             end;
         5:begin
           say(xloc-2,yloc,2,'ˆ');
           repeat
            say(xloc,yloc,0,objnames[passp]);
           until updown(passp,6,12)>0;
          end;
        6..18:begin
            say(xloc,yloc,0,'        ');
            ss:=readlin(xloc,yloc,3,1);
            val(ss,i,i1);
            if i1=0 then if (i>=0) and (i<=255) then passp:=i;
           end;
        end; {case}
        editpassp:=redisp;
      end; {editpassp}

{$I I_OBJED3.PAS}


var killobj:byte;


procedure createobj;
 const
  XLOC=22;
  YLOC=60;
 var whatcat,whatobj:byte;
 i:byte;
 done:boolean;
 j:char;


begin
 done:=false;
 whatobj:=0;
 blankbox(XLOC*4-3,YLOC-3,XLOC*4+123,YLOC+108);
  drawh(XLOC*4-2,YLOC-2,XLOC*4+122,3);
  drawh(XLOC*4-2,YLOC+107,XLOC*4+122,3);
  drawv(XLOC*4-2,YLOC-2,YLOC+107,3);
  drawv(XLOC*4+122,YLOC-2,YLOC+107,3);
 for i:=254 downto 2 do
  if obj^[i].t=0 then whatobj:=i;
 if whatobj=0 then
   begin
    say(1,183,0,'THERE ARE NO EMPTY SLOTS LEFT.     ');
    say(1,191,0,'PRESS A KEY TO CONTINUE.           ');
    if readkey=#0 then if readkey=#59 then help;
    wobj:=1;exit;
   end;
 say(1,183,0,'SELECT A CATAGORY FOR THE NEW      ');
 say(1,191,0,'OBJECT, OR PRESS ESC TO ABORT.     ');
 say(XLOC,YLOC,2,'ADDING #'+strnum(whatobj));
 for i:=1 to 11 do say(XLOC+1,YLOC+i*8+4,0,OBJNAMES[i]);
 whatcat:=1;
repeat
 say(XLOC+1,YLOC+whatcat*8+4,4,OBJNAMES[whatcat]);
 j:=readkey;
 say(XLOC+1,YLOC+whatcat*8+4,0,OBJNAMES[whatcat]);
 case j of
  #0:case readkey of
      #59:help;
      'H':cycle(whatcat,1,11,-1);
      'P':cycle(whatcat,1,11,+1);
      'G','I':whatcat:=1;
      'O','Q':whatcat:=11;
     end;
  #32,#13:done:=true;
  #27:begin;whatcat:=0;done:=true;end;
  end;
until done;
 if whatcat>11 then whatcat:=0;
 if whatcat>0 then
  begin
   obj^[whatobj].t:=whatcat;
   obj^[whatobj].n:='NEW OBJECT      ';
    case whatcat of
     1,2:clearobj(whatobj, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0,0);
     3,4:clearobj(whatobj, 1, 0, 0,00,00, 0, 0, 0, 7, 0, 0, 0,00,0);
     5:clearobj(whatobj, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0,whatobj,00,0);
     6:clearobj(whatobj, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00,0);
     7:clearobj(whatobj, 1, 0, 0, 1, 0, 0,00,00, 0, 0, 0, 0,00,0);
     8:clearobj(whatobj, 1, 0,241, 1, 2, 0, 0, 0, 0, 0, 0, 0,00,0);
     9:clearobj(whatobj, 1, 1, 0, 0, 1, 1,00,00, 0, 0, 0, 0,00,0);
    10:clearobj(whatobj, 1, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0,00, 0,0);
    11:clearobj(whatobj,00, 0, 0, 0, 0, 0, 0, 0,00,00, 0,00,00,0);
    12:clearobj(whatobj, 1,00,00,00,00,00,00,00, 0, 0, 0, 1, 0,0);
    end; {case}
  end;
 if whatcat>0 then wobj:=whatobj else wobj:=1;
end;

procedure ObjectEdit;
begin
 initobjs;
 load_objs;
 loadmapcolors;
 wobj:=1;
repeat
 cmdch:=chr(obj_editobj);
 case cmdch of
  #61:createobj;
  #60:begin
      say(1,183,0,'SELECT AN OBJECT TO EDIT/VIEW.     ');
      say(1,191,0,'Š:ABORT                            ');
      wobj:=selectobj(0,wobj);
      end;
  #66:begin
      say(1,183,0,'SELECT THE OBJECT TO BE DELETED.   ');
      say(1,191,0,'Š:ABORT                            ');
      killobj:=selectobj(0,wobj);if killobj>1 then obj^[killobj].t:=0;
      if wobj=killobj then wobj:=1;end;
 end;
until cmdch=#68; {f10}
 save_objs;
end; {procedure}

{$I PTR_PORT.PAS}

var ss,systemdir:string[60];
    i:integer;


procedure loadconfig;
var ackf:file of masterrec;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then begin;ADVNAME:='NONAME';chdir(systemdir);exit;end;
 read(ackf,ack);
 close(ackf);

end;




begin
 if copy(paramstr(4),1,2)<>'CH' then
  begin;writeln('ACK v',(ACKVERSION DIV 10),'.',
   (ACKVERSION MOD 10),' program file.');
   for i:=0 to paramcount do writeln(paramstr(i));writeln;readln;halt;end;

 usepointers;
 getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );
 getmem(crc, MAXCRCS * sizeof ( Creaturerec ) );
 getmem(graphic2, (GRAPS+1) * 256 );
 ss:=paramstr(1);
 i:=pos('*',ss);
 ADVNAME:=copy(ss,i+1,length(ss)-i);
 systemdir:=copy(ss,2,i-2);
 bgi_dir:=systemdir;
 u_graph_setup;
 graphicsmode;
 initmouse;

 helpfile:=systemdir+'\ACKDATA1.HLP';
 creatureok:=loadcreatures;
 helpindex:=7;
 sync_app:=7;
 loadconfig;
 loadgraps2(true);

 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
  blank0(ack.darkbackground);
 closemouse;
 pausemouse:=true;
 ObjectEdit;
 savemapcolors;
 shutdownsound;
end.
