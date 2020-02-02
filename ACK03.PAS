{...DEFINE ICONS}  {compiler directive}

{$M 8192, 94000, 94000}

uses u_vars,u_graph,u_adv,graph,crt2,dos,u_fonts,u_graps,u_io,u_help;

const bigger=4;

type swapinfo_rec = record
      execfile:string[12];
      execparam:string[40];
      data:array[1..10] of byte; {@}
     end;

var quittime:boolean;
    swapinfo:^swapinfo_rec;
    menucmd:string[1];
    daughter:string;  {parameter to give to child processes}
    d_s,d_c,hres:string;
    icons:^graparray256;
    whatopt:shortint;
    oldwhatopt:shortint;
    i,i1,i2:integer;
    systemdir:string;
    PassWordOk:boolean;
    reg:registers;
    registration:string[20];

{$I PTR_PORT.PAS}
{$I I_MSTREC.PAS}

 var ack:masterrec;
     p4ts:^swapinfo_rec absolute f4b;



procedure clear_keyboard_buffer;
 var regs:registers;
begin
 regs.ah:=$0c;regs.al:=$00;
 intr($21,regs);
end;



var
    shiftcount,shift:byte;
    timertick:byte;
    shifting:boolean;
(*
{$F+}
procedure shiftproc; interrupt;
begin
 if timertick>12 then
 begin
  timertick:=0;
  for shiftcount:=1 to 2 do
   begin {scrolls colors around}
    move(ack.phasecolors[shiftcount,0,1],
         ack.phasecolors[shiftcount,1,1],
         12);
    move(ack.phasecolors[shiftcount,4,1],
         ack.phasecolors[shiftcount,0,1],
         3);
    for shift:=0 to 3 do
      begin
       setrgbpalette( ((shiftcount-1)*4)+shift+  246  ,
          ack.phasecolors[shiftcount,shift,1],
          ack.phasecolors[shiftcount,shift,2],
          ack.phasecolors[shiftcount,shift,3]);
      end;
   end;
  end else inc(timertick);
end;

{$F-}
*)

function version(v:byte):ittystring;
var s:ittystring;
begin
 s:='V'+strnum(v DIV 10)+'.'+strnum(v MOD 10);
 version:=s;
end;



{
procedure createoldpal;
var palf:file of paletterec;
    paltemps:array[0..255] of paletterec;
    i:byte;
begin
 greg.ax:=$1017;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(paltemps[0]);
 greg.dx:=ofs(paltemps[0]);
 intr($10,greg);
 assign(palf,systemdir+'ACKDATA1.PAL');
 rewrite(palf);
 for i:=0 to 255 do
  write(palf,paltemps[i]);
 close(palf);
end;
}

procedure loadoldpalette;
var palf:file of paletterec;
    paltemp:paletterec;
    i:byte;
    pal1:array[0..255] of paletterec;
begin
 assign(palf,systemdir+'ACKDATA1.PAL');
 {$I-} reset(palf); {$I+}
 if ioresult<>0 then exit;
 for i:=0 to 255 do
   begin
    if not eof(palf) then read(palf,pal1[i]);
   end;
 close(palf);
 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0]);
 greg.dx:=ofs(pal1[0]);
 intr($10,greg);

end;


(*

procedure loadpalette;
 var x,y:byte;
  pal1:array[0..255] of paletterec;

procedure readyrgbpalette(cc,rr,gg,bb:byte);
begin
{ setrgbpalette(cc,rr,bb,gg);}
 pal1[cc,1]:=rr;
 pal1[cc,2]:=gg;
 pal1[cc,3]:=bb;
end;

begin
 greg.ax:=$1017;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0]);
 greg.dx:=ofs(pal1[0]);
 intr($10,greg);

 {greens}
 for x:=0 to 7 do
  readyrgbpalette(x+32,0,round(63*((x+3)/10)),0);
 for x:=8 to 15 do
  readyrgbpalette(x+32,round(40/(20-x)),round(230/(20-x)),round(120/(20-x)));
 {browns}
 readyrgbpalette(15*16+0,62 SHR 2,34 SHR 2,15 SHR 2);
 readyrgbpalette(15*16+1,86 SHR 2,47 SHR 2,21 SHR 2);
 readyrgbpalette(15*16+2,101 SHR 2,55 SHR 2,25 SHR 2);
 readyrgbpalette(15*16+3,121 SHR 2,66 SHR 2,30 SHR 2);
 readyrgbpalette(15*16+4,155 SHR 2,85 SHR 2,38 SHR 2);
 readyrgbpalette(15*16+5,189 SHR 2,103 SHR 2,47 SHR 2);


 for x:=0 to 4 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*(x/4)),0,round(63*((y-2)/3)));
 for x:=5 to 10 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*((10-x)/5)),18,round(63*((y-2)/3)));
 for x:=11 to 15 do for y:=3 to 5 do
  readyrgbpalette(x+y*16,round(63*((x-11)/4)),20,round(63*((y-2)/3)));

 for x:=0 to 4 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*(x/4)),22,round(63*((5-y)/3)));
 for x:=5 to 10 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*((10-x)/5)),35,round(63*((5-y)/3)));
 for x:=11 to 15 do for y:=2 to 4 do
  readyrgbpalette(x+(y+4)*16,round(63*((x-11)/4)),37,round(63*((5-y)/3)));

 for x:=0 to 4 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*(x/4)),40,round(63*((y-2)/3)));
 for x:=5 to 10 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*((10-x)/5)),52,round(63*((y-2)/3)));
 for x:=11 to 15 do for y:=3 to 5 do
  readyrgbpalette(x+(y+6)*16,round(63*((x-11)/4)),63,round(63*((y-2)/3)));

 for x:=0 to 4 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*(x/4)) DIV 2,10 DIV 2,round(63*((5-y)/3)) DIV 2);
 for x:=5 to 10 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*((10-x)/5)) DIV 2,35 DIV 2,round(63*((5-y)/3)) DIV 2);
 for x:=11 to 15 do for y:=2 to 4 do
  readyrgbpalette(x+(y+10)*16,round(63*((x-11)/4)) DIV 2,50 DIV 2,round(63*((5-y)/3)) DIV 2);
 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal1[0]);
 greg.dx:=ofs(pal1[0]);
 intr($10,greg);

end;

*)

var lastcfgload:string[8];
procedure loadconfig;
var ackf:file of masterrec;
    palf:file of paletterec;
    paltemp:paletterec;
    i:byte;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then begin;ADVNAME:='NONAME';chdir(systemdir);exit;end;
 read(ackf,ack);
 close(ackf);


(*
 if (lastcfgload<>ADVNAME) then
 begin
  assign(palf,ADVNAME+'.PAL');
  {$I-} reset(palf); {$I+}
  if ioresult<>0 then
    begin
     if ack.ackversion<20 then
      begin;loadoldpalette;lastcfgload:=ADVNAME;end else
      if lastcfgload<>'NONAME' then loadpalette;
    end
  else
  begin
   for i:=0 to 255 do
   begin
    if not eof(palf) then read(palf,paltemp);
    setrgbpalette(i,paltemp[1],paltemp[3],paltemp[2]); {R G B}
   end;
   close(palf);
  end;
  lastcfgload:=ADVNAME;
 end;   *)
  loadbmppalette(ack.ackversion,ADVNAME,systemdir);

end;

{$I I_MODNUM.PAS}

procedure loadicons(fn:string);
var
 ifile:file of grap256unit;
 i:integer;
begin
 assign(ifile,systemdir+fn);
 {$I-} reset(ifile); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to 31 do
  if not eof(ifile) then read(ifile,icons^[i]);
 close(ifile);
end;
{
function lookformst: string;
var d: searchrec; i: byte; s:string[8];
begin
   findfirst('*.MST', AnyFile, d);
   s:='';
   if doserror=0 then
    begin
      i:=1;
      repeat
       s:=s+d.name[i];
       inc(i);
      until (d.name[i]='.') or (i>8);
      lookformst:=s;
    end else lookformst:='NONAME';
end;
}
var damngd,damngm:integer;
    oldvector:pointer;
    adv_to_load:string[8];
    mod_to_load:string[2];
    paramcountnum:byte;
begin

 paramcountnum:=paramcount;
 if (paramstr(paramcount)='-exit') or (paramstr(paramcount)='-EXIT') then
  dec(paramcountnum);
 disablemouse:=true;
 if (paramstr(paramcountnum)='-mouse') or (paramstr(paramcountnum)='-MOUSE') then
  begin; dec(paramcountnum); disablemouse:=false; end;
 getdir(0,systemdir); adv_to_load:='NONAME'; mod_to_load:='-?';

 if paramcountnum=2 then adv_to_load:=paramstr(2);
 if paramcountnum>0 then mod_to_load:=paramstr(1);
 (*
 if ((adv_to_load='NONAME') and (mod_to_load='-r')) then
  begin
    { no command line arguments.  Check to see if it's being called as a standalone game launch }
    { search for a .MST file.  If found, use that for the adventure name. }
    adv_to_load:=lookformst;
  end;
 *)



 if adv_to_load='NONAME' then if ((mod_to_load<>'-?') and (mod_to_load<>'-n')) then
   begin
    {prompt for adventure name}
    clrscr;
    gotoxy(20,10);textattr:=15;
    writeln('Enter the name of the adventure to load.');
    gotoxy(20,12);
    write(systemdir+'\GAMES\');textattr:=7;
    readln(adv_to_load);

    clrscr;
   end;

 if ((adv_to_load='') or (mod_to_load='-?')) then
  begin
   writeln;
 {  writeln('If part of an ACK user-made game distribution, ACKPLAY will play that game.');
   writeln;
   writeln('  ACKPLAY [-nomouse]            ...run (play) adventure in current folder');
   writeln;
   writeln;
   writeln('If part of a full ACK install, ACKPLAY will load an adventure from your');
   writeln('GAMES folder and then run an editor or play the game:'); }

   writeln('ACKMOD will load an adventure from your GAMES folder (or prompt for a name,');
   writeln('if none is specified) and will run the specified module.');
   writeln;
   writeln('  ACKMOD -n                      ...create new adventure');
   writeln('  ACKMOD -r [advname] [-mouse]   ...run (play) adventure');
   writeln('  ACKMOD -c [advname]            ...edit config');
   writeln('  ACKMOD -i [advname]            ...import kit');
   writeln('  ACKMOD -f [advname]            ...font editor');
   writeln('  ACKMOD -g [advname]            ...graphic tile editor');
   writeln('  ACKMOD -o [advname]            ...object editor');
   writeln('  ACKMOD -t [advname]            ...text (message) editor');
   writeln('  ACKMOD -m [advname]            ...map editor');
   writeln('  ACKMOD -p [advname]            ...people/creature editor');
   writeln('  ACKMOD -x [advname]            ...macro editor');
   writeln;
   halt;
  end;





 if systemdir[length(systemdir)]<>'\' then
  systemdir:=concat(systemdir,'\');
 registration:='registered';
 passwordok:=true;
 getmem(block,(BLOCKS+1)*sizeof(grpblock));
 bgi_dir:=systemdir;
 u_graph_setup;

 startupgraph;
 graphicsmode;
{ createoldpal;}

if upcase(mod_to_load[2])='N' then
begin
 exec('ack06.exe','CH');
shutdowngraph;
(*reg.ah:=0;
if u_graph.MONO then reg.al:=7 else reg.al:=2;
intr($10,reg);*)
textmode(co80);textattr:=7;
clrscr;


end;

 getmem(graphic,(GRAPS+1+4)*sizeof(grap256unit));
 getmem(icons,(33)*sizeof(grap256unit));
  getmem(swapinfo,sizeof(swapinfo_rec)); {@}
 ADVNAME:='ACKDATA1';
 loadfont;
 say(30,60,0,'Loading...');
 loadbmppalette(ACKVERSION,ADVNAME,systemdir);
 lastcfgload:='NONAME';
 ADVNAME:='NONAME';
{if paramcount<>0 then tryfile(paramstr(1));}
 if ADVNAME<>'NONAME' then begin;loadfont;loadgraps;end;
 loadicons('ACKDATA1.ICO');
 i:=0;
 graphic^[i+241]:=icons^[i+23];
 graphic^[i+242]:=icons^[i+9];
 graphic^[i+243]:=icons^[i+24];
 graphic^[i+244]:=icons^[i+11];

 {saveicons('ACKDATA1.ICO');}

 clearscreen;



 p4tf:=@block^;
 string4(f4b,d_s);
 d_c:=concat(' ',d_s);
 p4tg:=@graphic^;
 string4(f4b,d_s);
 d_c:=concat(d_c,' ',d_s,' LO');

  begin


     daughter:=adv_to_load;

     say(10,60,0,'Loading Adventure...');
     advname:=adv_to_load;
     if HIRES then d_s:='H ' else d_s:='N ';
     daughter:=concat(advname,d_c,adv_to_load,' ',d_s,strnum(PALETTE));
     if not SPACEMONO then daughter:=daughter+' F';
       i1:=2;graphic^[i1,1,1]:=255;
       {exec(systemdir+'ACK01.EXE','F'+systemdir+'*'+daughter);}

	   if disablemouse=false then exec(systemdir+'ACK01.EXE','F'+systemdir+'*'+daughter)
             else exec(systemdir+'ACK01.EXE','f'+systemdir+'*'+daughter);
	
       i1:=2;if graphic^[i1,1,1]<>255 then
        begin
         i1:=1;hres:='';
         for i:=1 to graphic^[i1,1,1] do
          hres:=concat(hres,chr(graphic^[i1,i+1,1]));
        i1:=2;if graphic^[i1,1,1]=1 then passwordok:=false;
         if graphic^[i1,1,1]=2 then passwordok:=true;
        ADVNAME:=hres;
         if ADVNAME<>'NONAME' then
           begin
            loadfont;loadgraps;

             loadconfig;
             TEXTC0:=ack.textcolors[0];
             TEXTC1:=ack.textcolors[1];
             TEXTC2:=ack.textcolors[2];
             TEXTC4:=ack.textcolors[4];
             TEXTC5:=ack.textcolors[5];
             TEXTC6:=ack.textcolors[6];

           end
         else
         begin;ADVNAME:=systemdir+'ACKDATA1';loadfont;ADVNAME:='NONAME';end;
       end else
   begin;chdir(systemdir+'.');ADVNAME:='ACKDATA1';loadfont;ADVNAME:='NONAME';end;

  end;
initmouse;



 whatopt:=12;


 p4tf:=@block^;
 string4(f4b,d_s);
 d_c:=concat(' ',d_s);
 p4tg:=@graphic^;
 string4(f4b,d_s);
 d_c:=concat(d_c,' ',d_s,' CH');
 p4ts:=@swapinfo^;
 string4(f4b,d_s);
 d_c:=concat(d_c,d_s,' ');
 quittime:=false;
 if HIRES then d_s:='H ' else d_s:='N ';
 daughter:=concat(advname,d_c,d_s,strnum(PALETTE));
 if not SPACEMONO then daughter:=daughter+' F';
 menucmd:=copy(paramstr(1),2,1);
 case upcase(menucmd[1]) of
  'N':whatopt:=1; {create}
  'R':whatopt:=2; {run-play}
  'C':whatopt:=3; {config}
  'I':whatopt:=4; {import}
  'F':whatopt:=5; {font}
  'G':whatopt:=6; {graphics}
  'O':whatopt:=7; {objects}
  'T':whatopt:=8; {text-messages}
  'M':whatopt:=9; {map-regions}
  'P':whatopt:=10; {creatures}
  'X':whatopt:=11; {macros}
  '!':whatopt:=12;
  end;




        case whatopt of
         1:begin

		
		    exec(systemdir+'ACK06.EXE','CH');
		
           end;
         3:if passwordok then begin
            exec(systemdir+modulenum(3),'C'+systemdir+'*'+daughter);

            i:=dosexitcode;
             case i of
              1:HIRES:=true;
              2:begin;HIRES:=false;PALETTE:=0;end;
              3:begin;HIRES:=false;PALETTE:=1;end;
              16:begin;HIRES:=false;PALETTE:=16;end;
              32:begin;HIRES:=false;PALETTE:=32;end;
             end;
           end;
         2,12:begin
              i:=0;
              graphic^[i+241]:=icons^[i+25];
              graphic^[i+242]:=icons^[i+26];
              graphic^[i+243]:=icons^[i+27];
              swapinfo^.data[1]:=0;
              swapinfo^.data[7]:=0;
             repeat
              if whatopt=12 then
               begin
shutdowngraph;
textmode(co80);textattr:=7;
clrscr;
end;

              if disablemouse then exec(systemdir+modulenum(2),','+systemdir+'*'+daughter) else
                exec(systemdir+modulenum(2),'.'+systemdir+'*'+daughter);
              i:=doserror;
              if swapinfo^.data[1]=1 then
               begin
                {execute external program}
                if swapinfo^.data[2]=1 then closegraph;

                if swapinfo^.data[10]=1 then exec(systemdir+swapinfo^.execfile,swapinfo^.execparam) else
                exec(swapinfo^.execfile,swapinfo^.execparam);



                {graphicsmode;}
                swapinfo^.data[2]:=lo(dosexitcode);
                swapinfo^.data[4]:=doserror;
               end;
             until (swapinfo^.data[1]=0) or (i<>0);



              i:=0;
              graphic^[i+241]:=icons^[i+23];
              graphic^[i+242]:=icons^[i+9];
              graphic^[i+243]:=icons^[i+24];
           end;
         4:if passwordok then
             begin
               exec(systemdir+modulenum(4),'C'+systemdir+'*'+daughter);

               if dosexitcode=99 then
                begin
                 ADVNAME:='ACKDATA1';
                 chdir(systemdir+'.');
                 loadfont;
                 ADVNAME:='NONAME';
                end;
             end;
         5:if passwordok then
              begin
               exec(systemdir+modulenum(5),'F'+systemdir+'*'+daughter);

              end;
         6:begin
{            getintvec($1C,oldvector);
            setintvec($1C,@shiftproc); }
           if passwordok then
              begin
               exec(systemdir+modulenum(6),'G'+systemdir+'*'+daughter);

              end;
{            setintvec($1C,oldvector); }
             i:=0;
             graphic^[i+241]:=icons^[i+23];
             graphic^[i+242]:=icons^[i+9];
             graphic^[i+243]:=icons^[i+24];
           end;
         7:if passwordok then
             begin
               exec(systemdir+modulenum(7),'O'+systemdir+'*'+daughter);

             end;
         8:if passwordok then
              begin
               exec(systemdir+modulenum(8),'8'+systemdir+'*'+daughter);

              end;
         9:if passwordok then
              begin
               i:=0;
               graphic^[i+241]:=icons^[i+23];
               graphic^[i+242]:=icons^[i+9];
               graphic^[i+243]:=icons^[i+24];
               exec(systemdir+modulenum(9),'!'+systemdir+'*'+daughter);

              end;
        10:if passwordok then
             begin
               exec(systemdir+modulenum(10),'P'+systemdir+'*'+daughter);

             end;
        11:if (passwordok) and (ADVNAME<>'NONAME') then
              begin
               exec(systemdir+modulenum(11),'M'+systemdir+'*'+daughter);

              end;
        12:quittime:=true;
        end; {case}

shutdowngraph;
(*reg.ah:=0;
if u_graph.MONO then reg.al:=7 else reg.al:=2;
intr($10,reg);*)
textmode(co80);textattr:=7;
clrscr;
chdir(systemdir+'.');
writeln;

end.
