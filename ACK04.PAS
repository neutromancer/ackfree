{ FileCopy,  MacroEdit }

{$m 63000,90000,129000}
uses u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_io,u_mio,u_help,u_sound,u_ack04;


{$I I_MSTREC.PAS}

type string3=string[3];
type argnamestype=array[1..10] of string[3];
const MACROARGUMENT:argnamestype = (' + ',' - ',' = ',' > ',' < ',' * ',' / ',' ! ',' & ',' | ');
const MACROMAX:byte = 50;
type cmdnamestype=array[1..50] of string[7];
const MACROCOMMAND:cmdnamestype = ('SET','GOTO','IF','SMSG','LMSG','CLRSCR',
{7} 'WAITKEY','GETKEY','SOUND','MAPADD','MAPTAKE','TMOSAIC','USEARMR','OFFARMR',
{15} 'SAYVAL','SETPORT','PAUSE','TONE','SAVESCR','MOSAIC','MACRO','STOP',
{23} 'ENDGAME','MAPSET','MAPSETD','MAPCHK','MAPCHKD','BMSG','EXEC','SHOWLOC',
{31} 'SHOWMAP','LOADSCR','FADEOUT','FADEIN','SHOWBMP','FIXPAL','FSOUND','FMUSIC',
{39} 'MUSIC','AMBIENT','SPEECH','PICTURE','QA','TBMP','PAUSEK','ADVTIME','QTILE',
{48} 'INVERT','GETADJ','DRAW');


{
 other places that need to be edited for macro vars/commands:
 
 u_ack04: strvar
 i_macro1: compile
 o_play0:run_macro,mac_var, set_var
 
 
 
}


type
   macrorec = record
      cmd:byte;
      data:Array[1..6,1..3] of byte;
      next:word;
     end;
   macroarray=array[1..1] of macrorec;



var sync_app: byte;
    thisgame_dir:string;
    quittime:boolean;
    i,i1:integer;
    objok:boolean;
    macro:^macroarray;
	clipboard:macrorec;
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

procedure savegraps;
var bf:file;
    i:integer;
    fn:string;
begin
 fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
 {$I-} rewrite(bf,256); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to GRAPS do blockwrite(bf,graphic^[i],1);
 close(bf);
end;

function upcase_sync(r: char): char;  forward;


 {$I I_SNDNAM.PAS}
{$I I_OBJED0.PAS}
 {$I I_SELECT.PAS}
{$I I_MACRO1.PAS}
{$I PTR_PORT.PAS}
{$I I_FCOPY1.PAS}

procedure loadconfig;
var ackf:file of masterrec;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then begin;ADVNAME:='NONAME';chdir(systemdir);exit;end;
 read(ackf,ack);
 close(ackf);

end;


function upcase_sync(r: char): char;

begin
(* {search and replace and change all upcase(readkey) to upcase_sync(readkey)}
 if r=#9 then
 begin
  case sync_app of


   11,4:begin {macro}
       loadfont;
       {nothing to do here, macros and execs save themselves when you close them}
     end;
  end; {case}
  sound(500);delay(100);sound(1000);delay(100);nosound;
 end; *)
 upcase_sync:=upcase(r);
end;

begin
 clipboard.cmd:=0;
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
 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
 graphicsmode;
 initmouse;
 opt:=copy(paramstr(1),1,1);
 case opt[1] of
  'C':begin; closemouse;
              pausemouse:=true;
              sync_app:=4;
              helpindex:=4;
              getmem(talk, 256 * sizeof (talkrec) );
              getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );
              getmem(crc, MAXCRCS * sizeof ( Creaturerec ) );

              filemover;end;

  'M':begin
       closemouse;
        pausemouse:=true;
      sync_app:=11;
      helpindex:=73;
      getmem(macro, 100 * sizeof (macrorec) );
      getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );	  
	  if loadobjs=false then sync_app:=11; {ignore value}
      MacroMainMenu;
      end;

  end;
  shutdownsound;
end.