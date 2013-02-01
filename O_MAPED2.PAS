{$O+}
{$F+}
unit o_maped2;
{$DEFINE MAPOVER}

interface

uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,
     u_graps,u_help,u_sound,o_maped1;


const
      LOCNTMAX=6400;


type chunkprec = array[1..3,1..3] of byte;
     locrec = record
         o,d:byte;
         end;
     chunkrec = array[1..16,1..16] of locrec;

type vehrec = array[1..255] of
       record
        obj,objcode:byte;
        xchunk,ychunk:byte;  { make sure this ch#n is the right one }
        used:boolean;
        howmany:byte;
       end;
const objok = true;

{$I I_CRCREC.PAS}

var xinloc,yinloc:byte;
    xchunkloc,ychunkloc:integer;
    veh:vehrec;
    i1:integer;
    thisregion:byte;
    chunk:chunkprec;
    gotolocation,chunksave:boolean;
    locntsize:word;
    roomwide,roomtall:byte;
    map:array[1..3,1..3] of chunkrec;

const
 NORTH=1;SOUTH=2;EAST=3;WEST=4;
var onlycell:boolean;
var thingtaken:array[1..4] of byte;

procedure savewmap;
procedure loadwmap;
procedure loadmap(n:byte);
procedure numscan(var arg:integer;amt:integer);
procedure getchunks(chunkx,chunky:byte);
procedure chunkmove(dir:byte);
function roomloc(r,x,y:byte):locpointer;
procedure getroom(n:byte);
procedure showroom(room:byte);
procedure previewrooms;
procedure takething(xx,yy:byte);  { these are acceptable in either mode }
procedure replacething(xx,yy:byte);
function chooseroom(s2:string):byte;
procedure otherwalkroom(var room,x,y:byte);
procedure otherwalkworldmap(var xchunk,ychunk,x,y:byte);
function menuselectregion(def:byte):byte;
function dialogue_title(n:byte):string;
function selectdialogue:byte;


implementation


{$I I_MAPED2.PAS}

begin
end.