{  CreatureEdit }

{$m 63000,90000,129000}
uses u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_io,u_help,u_sound;


{$I I_MSTREC.PAS}

type argnamestype=array[1..7] of string[3];
const MACROARGUMENT:argnamestype = (' + ',' - ',' = ',' > ',' < ',' * ',' / ');
type cmdnamestype=array[1..41] of string[7];
const MACROCOMMAND:cmdnamestype = ('SET','GOTO','IF','SMSG','LMSG','CLRSCR',
'WAITKEY','GETKEY','SOUND','PUTOBJ','REMOBJ','TMOSAIC','USEARMR','OFFARMR',
'SAYVAL','SETPORT','PAUSE','TONE','SAVESCR','MOSAIC','MACRO','STOP',
'ENDGAME','SETOBJ','SETOBJD','GETOBJ','GETOBJD','BMSG','EXEC','SHOWLOC',
'SHOWMAP','LOADSCR','FADEOUT','FADEIN','SHOWBMP','FIXPAL','FSOUND','FMUSIC','MP3','WAV','OGG');
{showbmp is 35}
type
   macrorec = record
      cmd:byte;
      data:Array[1..6,1..3] of byte;
      next:word;
     end;
   macroarray=array[1..1] of macrorec;


var
    thisgame_dir:string;
    quittime:boolean;
    i,i1:integer;
    objok:boolean;
    macro:^macroarray;
    fe_whatchar:byte;
    ge_whatchar:byte;
    b:Byte;
    Ack:masterrec;
    passwordok:byte;
    ss:string;
    systemdir:string;
    crc:^crcarray;
    whatcrc:byte;
    opt:string[1];
(*
procedure savegraps;
var bf:file;
    i:integer;
    fn:string;
begin
 fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
 {$I-} rewrite(bf,256); {$I+}
 if ioresult<>0 then begin;sound(100);delay(100);nosound;exit;end;
 for i:=1 to GRAPS do blockwrite(bf,graphic^[i],1);
 close(bf);
end;
 *)
function upcase_sync(r: char): char;  forward;

{$I I_PPLED2.PAS}



{$I PTR_PORT.PAS}


procedure loadconfig;
var ackf:file of masterrec;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then begin;ADVNAME:='NONAME';chdir(systemdir);exit;end;
 read(ackf,ack);
 close(ackf);

end;

var sync_app: byte;
function upcase_sync(r: char): char;

begin
 {search and replace and change all upcase(readkey) to upcase_sync(readkey)}
 if r=#9 then
 begin
  case sync_app of

   10:begin {creature editor}
       loadgraps;loadfont;savecreatures;if not loadobjs then exit;
     end;

  end; {case}
  sound(500);delay(100);sound(1000);delay(100);nosound;
 end;
 upcase_sync:=upcase(r);
end;

begin
 getdir(0,thisgame_dir);
 if thisgame_dir[length(thisgame_dir)]<>'\' then
  thisgame_dir:=thisgame_dir+'\';
 if copy(paramstr(4),1,2)<>'CH' then
  begin;writeln('ACK v',(ACKVERSION DIV 10),'.',(ACKVERSION MOD 10),
   ' program file.');halt;end;
 usepointers;
 ss:=paramstr(1);
 i:=pos('*',ss);
 ADVNAME:=copy(ss,i+1,length(ss)-i);
 systemdir:=copy(ss,2,i-2);
 bgi_dir:=systemdir;
 u_graph_setup;
 helpfile:=systemdir+'\ACKDATA1.HLP';
 loadconfig;
  getmem(graphic2, (GRAPS+1) * 256 );
  loadgraps2(true);

 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
  blank0(ack.darkbackground);
 graphicsmode;
 initmouse;
 opt:=copy(paramstr(1),1,1);
 case opt[1] of

  'P':begin
      closemouse;
      pausemouse:=true;
      helpindex:=10;
      getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );
      getmem(crc, MAXCRCS * sizeof ( Creaturerec ) );
      objok:=LoadObjs;
      LoadCreatures;
      PeopleEdit;
      SaveCreatures;
      end;
  end;
  shutdownsound;
end.