{$O+}
{$F+}
unit o_maped1;

interface

uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_help,u_sound;


const BLANK='                                       '; {39 chars}

var creatureok:boolean;
    crc:^crcarray;
    printer:text;
    oh:byte;
    i:integer;
	save_the_maps:boolean;
	mapcolors:array[0..255] of byte;

{$I I_WANDC1.PAS}

procedure clear_keyboard_buffer;
procedure loadmapcolors;
function upcase_sync(r: char): char;
function selectcreature(start:byte):byte;

function loadobjs:boolean;
function selectobj(cats,start,esc:byte):byte;
function loadcreatures:boolean;
function hinyb(b:byte):byte;
function lonyb(b:byte):byte;
procedure sethinyb(var by:byte;nb:byte);
procedure setlonyb(var by:byte;nb:byte);
function objnam(num:byte):string;
procedure save_longmsgfile(mn:byte);
procedure clear_longmsg;
procedure create_longmsgfile;
procedure load_longmsgfile(mn:byte);
procedure show_longmsg;
function longmessageedit:integer; {1:save 0:ESC -1:del}
procedure show_shortmsg(yloc:byte);
function shortmessageedit(yloc:byte):integer; {1:save 0:ESC -1:del}
function updown(var numin:byte;minim,maxim:byte):byte;
function updowni(var numin:shortint;minim,maxim:integer):byte;
procedure messager(xc,yc:byte;var d:byte);
procedure longmessager(xc,yc:byte;var d:byte);
function grap_select_window(default:byte):byte;
function straction(actionnum:byte):string;
function soundname(snd:byte):string;
function stractionp(actionnum,actionparam:byte;endadd:boolean):string;
procedure editactionp(act,xloc,yloc:byte;var actp:byte);

implementation

procedure clear_keyboard_buffer;
 var regs:registers;
begin
 regs.ah:=$0c;regs.al:=$00;
 intr($21,regs);
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


function upcase_sync(r: char): char;

begin
 {search and replace and change all upcase (readkey) to upcase_sync (readkey) }
 if r=#9 then
 begin
  loadgraps;
  creatureok:=loadcreatures;
  if not loadobjs then exit;
  {save the map... if? how?}
  loadmapcolors;
  save_the_maps:=true;
  sound(500);delay(100);sound(1000);delay(100);nosound;
 end;
 upcase_sync:=upcase(r);
end;

{$I I_PPLED1.PAS}
{$I I_MAPED1.PAS}

begin
 save_the_maps:=false;
end.
