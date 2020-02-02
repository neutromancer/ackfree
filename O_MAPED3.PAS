{$O+}
{$F+}
unit o_maped3;
{$DEFINE MAPOVER}

interface

uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,
     u_graps,u_help,u_sound,o_maped2,o_maped1;

var i,i1:integer;
    s:string;
    quittime:boolean;
    layobj:array[1..5] of byte;
    lastportal_r,lastportal_n:byte;


procedure newmap(var n:byte);
procedure newchunk;
procedure savemap;
procedure newportal(var rr,xc,yc,xx,yy:byte);
procedure walkworldmap;
procedure addregion(mapnum:byte);
procedure previewcells(topx,topy:byte);
procedure cwmap_scrollbars;
procedure editroom(n:byte);
procedure sanitycheck;
procedure deleteroom(n:byte);
procedure regionreports(max:byte);

implementation


{$I I_MAPED3.PAS}
{$I I_RGNRPT.PAS}

begin
end.
