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
    menucmd:char;
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
{$I I_MODNUM.PAS}

 var ack:masterrec;
     p4ts:^swapinfo_rec absolute f4b;







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

  name:=systemdir+'\ACKDATA0.DAT';
  assign(bmpf,name);
  {$I-} reset(bmpf,1); {$I+}
  if ioresult=0 then

   begin
    BlockRead(bmpf,header,SizeOf(header));
    i2:=header[51];
    if i2=0 then i2:=256;
    seek(bmpf,54+(i2*4));

    for i:=0 to 32 do
      begin
       blockread(bmpf,line[0],320);
       {move(line[132],mem[scrnl:132+scrnh[i]],(199-132));}
       move(line[0],mem[scrnl:scrnh[i]],320);

     end;



    close(bmpf);

   end; {if ioresult=0}


end;






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

(*
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
*)

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
 end;
 *)
 loadbmppalette(ack.ackversion,ADVNAME,systemdir);


end;


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

procedure saveicons(fn:string);
var
 ifile:file of grap256unit;
 i:integer;
begin
 loadicons(fn);
 assign(ifile,systemdir+fn);
 {$I-} rewrite(ifile); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to 31 do
  write(ifile,icons^[i]);
 close(ifile);
end;

procedure puticon(xb,yy,bb:integer);
var i:integer;
begin
 if ((mouseon) and (mouseactive)) then hidemouse;
 for i:=1 to 16 do
  move(icons^[bb,i],mem[scrnl:(xb*4)+scrnh[yy+i]],16);
end;

procedure showoption(x,n:byte;mo:shortint);
begin
 if not ((x=1) or (x=12) or ((registration='none') and (x=11)) or
  ((x=2) and (ADVNAME<>'NONAME')) or ((ADVNAME<>'NONAME') and passwordok))
  then n:=n+mo;
case x of
 1:begin;say(8,57,n,'SELECT/CREATE');say(8,65,n,' ADVENTURE');end;
 2:say(48,57,n,'PLAY ADVENTURE');
 3:begin;say(8,81,n,'CONFIGURE');say(8,89,n,' ADVENTURE');end;
 4:begin;say(48,81,n,'IMPORT FILES,');say(48,89,n,'EXPORT REPORTS');end;
 5:say(8,105,n,'EDIT FONT');
 6:begin;say(48,105,n,'EDIT GRAPHIC');say(48,113,n,' TILES');end;
 7:begin;say(8,129,n,'EDIT OBJECTS,');say(8,137,n,'ITEMS, TERRAIN');end;
 8:begin;say(48,129,n,'EDIT MESSAGES');say(48,137,n,'AND DIALOGUE');end;
 9:begin;say(8,153,n,'EDIT MAPS AND');say(8,161,n,'REGIONS');end;
 10:begin;say(48,153,n,'EDIT PEOPLE');say(48,161,n,'AND CREATURES');end;

 11:if registration='none' then
  begin;say(8,177,n,'ORDERING');say(8,185,n,'INFORMATION');end
  else begin;say(8,177,n,'EDIT MACROS');say(8,185,n,'(ADVANCED)');end;

 12:begin;say(48,177,n,'QUIT');say(48,185,n,'EXIT TO DOS');end;
end;
end;

procedure redisplay;
 var ymlt:real;
     vs:string[6];
begin
 if u_graph.MONO then ymlt:=(3/2) else ymlt:=1;
 if advname<>'NONAME' then
  begin
   loadconfig;
   TEXTC0:=ack.textcolors[0];
   TEXTC1:=ack.textcolors[1];
   TEXTC2:=ack.textcolors[2];
   TEXTC4:=ack.textcolors[4];
   TEXTC5:=ack.textcolors[5];
   TEXTC6:=ack.textcolors[6];
  end;
 loadicons('ACKDATA1.ICO');
 for i:=1 to 31 do
  for i1:=1 to 16 do
   for i2:=1 to 16 do
    if icons^[i,i1,i2]=222 then icons^[i,i1,i2]:=lo(TEXTC0);
 clearscreen;
 {
 puticon(08,2,13);puticon(12,2,14);puticon(16,2,15);
 puticon(20,2,16);

 puticon(28,2,17);puticon(32,2,18);puticon(36,2,19);
 puticon(40,2,20);puticon(44,2,21);puticon(48,2,22);

 puticon(58,2,29);puticon(62,2,30);puticon(66,2,31);

 say(28,21,0,'VERSION '+version(ACKVERSION));
 }
 menuskinbmp;

 if ADVNAME<>'NONAME' then
 begin
  say(11,34,1,'CURRENT ADVENTURE: '+ADVNAME);
  if ack.ackversion<>ACKVERSION then
   say(15,42,1,'(CREATED WITH ACK '+version(ack.ACKVERSION)+')');
 end
  else say(20,40,1,'No Adventure loaded.');

 puticon(3, 57, 1);puticon(43, 57, 2);
 puticon(3, 81, 3);puticon(43, 81, 4);
 puticon(3,105, 5);puticon(43,105, 6);
 puticon(3,129, 7);puticon(43,129, 8);
 puticon(3,153, 9);puticon(43,153,10);
 if registration='none' then puticon(3,177,11) else puticon(3,177,28);
 puticon(43,177,12);
 for i:=1 to 12 do
  showoption(i,0,1)
end;

var regno:string[24];


procedure checkregistration;
 var f:text;
     ind:byte;checksum,checksum2:byte;
     encrypt:byte;
begin
 registration:='REGISTERED';
end;

{$I I_DISCL.PAS}

(*
procedure disclaimer;
var s:string;
begin
{ checkregistration; }
 helpfile:=systemdir+'ACKDATA1.HLP';
 helpindex:=16;
 i_marquis;
{ if registration<>'none' then
  writec(wherex,wherey,14,'Registered to: '+registration+regno+']')
  else writec(wherex,wherey,14+128,'(Unregistered)');    }
 textattr:=7;
 writeln;
 i_discl;
 if readkey=#27 then
  begin
   writeln;
   writeln('Aborted.');
   halt;
  end;
 clrscr;
end;
*)




var damngd,damngm:integer;
    oldvector:pointer;
    paramcount2:byte;
begin

 startlog;
 checking:=false;
 getdir(0,systemdir);
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

 paramcount2:=paramcount;
 if (paramstr(paramcount)='-exit') or (paramstr(paramcount)='-EXIT') then
  dec(paramcount2); 
 disablemouse:=true;
 if (paramstr(paramcount2)='-mouse') or (paramstr(paramcount2)='-MOUSE') then
  begin; disablemouse:=false; initmouse; showmouse; dec(paramcount2); end;


 getmem(graphic,(GRAPS+1+4)*sizeof(grap256unit));
 getmem(icons,(33)*sizeof(grap256unit));
 getmem(swapinfo,sizeof(swapinfo_rec)); {@}
 ADVNAME:='ACKDATA1';
 loadfont;
 say(30,60,0,'Loading...');
 loadbmppalette(ACKVERSION,'PALETTE2',systemdir);

 lastcfgload:='NONAME';
 ADVNAME:='NONAME';
{if paramcount2<>0 then tryfile(paramstr(1));}
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
 if paramcount2<>0 then
  begin
   daughter:=paramstr(paramcount2);
   if daughter[1]<>'-' then
    begin
     say(10,60,0,'Loading Adventure...');
     advname:=paramstr(paramcount2);
     d_s:='N ';
     daughter:=concat(advname,d_c,paramstr(paramcount2),' ',d_s,strnum(PALETTE));
     if not SPACEMONO then daughter:=daughter+' F';
       i1:=2;graphic^[i1,1,1]:=255;
       {exec(systemdir+'ACK01.EXE','F'+systemdir+'*'+daughter);}
	   if disablemouse=false then exec2(systemdir+'ACK01.EXE','F'+systemdir+'*'+daughter)
             else exec2(systemdir+'ACK01.EXE','f'+systemdir+'*'+daughter);
       checkexec(doserror,1);
       i1:=2;if graphic^[i1,1,1]<>255 then
        begin
         i1:=1;hres:='';
         for i:=1 to graphic^[i1,1,1] do
          hres:=concat(hres,chr(graphic^[i1,i+1,1]));
        i1:=2;if graphic^[i1,1,1]=1 then passwordok:=false;
         if graphic^[i1,1,1]=2 then passwordok:=true;
        ADVNAME:=hres;
         if ADVNAME<>'NONAME' then begin;loadfont;loadgraps;end
         else
         begin;ADVNAME:=systemdir+'ACKDATA1';loadfont;ADVNAME:='NONAME';end;
       end else
   begin;chdir(systemdir+'.');ADVNAME:='ACKDATA1';loadfont;ADVNAME:='NONAME';end;
    end;
  end;
initmouse;
 redisplay;

{
 shifting:=true;
 timertick:=0;
 for shiftcount:=1 to 2 do
    for shift:=0 to 3 do
      begin
       setrgbpalette( ((shiftcount-1)*4)+shift+  246  ,
          ack.phasecolors[shiftcount,shift,1],
          ack.phasecolors[shiftcount,shift,2],
          ack.phasecolors[shiftcount,shift,3]);
      end;
}
 whatopt:=1;
 { for shiftcount:=1 to 10 do
   setrgbpalette(shiftcount+245,ack.phasecolors[shiftcount,1],
     ack.phasecolors[shiftcount,2],ack.phasecolors[shiftcount,3]); }
repeat
 checking:=true;
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
 d_s:='N ';
 daughter:=concat(advname,d_c,d_s,strnum(PALETTE));
 if not SPACEMONO then daughter:=daughter+' F';
 {say(1,190,0,systemdir+'*'+daughter+'   ');}
 showoption(whatopt,6,-2);
 menucmd:=#1;
 oldwhatopt:=whatopt;
 repeat
  if keypressed then menucmd:=readkey;
    if mouseon then trackmouse;
 { say(1,1,0,strnum(mousex)+'/'+strnum(mousey)+') '); }

  if mousein(4,57,33,73) then { select/create }
    begin
      whatopt:=1;
      menucmd:=#13;
    end;
 if mouseon then
 begin
  whatopt:=checkmouse(3,57,33,73,whatopt,1,menucmd,#13);
  whatopt:=checkmouse(3,81,27,97,whatopt,3,menucmd,#13);
  whatopt:=checkmouse(3,105,25,121,whatopt,5,menucmd,#13);
  whatopt:=checkmouse(3,129,35,145,whatopt,7,menucmd,#13);
  whatopt:=checkmouse(3,153,33,169,whatopt,9,menucmd,#13);
  whatopt:=checkmouse(3,177,29,193,whatopt,11,menucmd,#13);

  whatopt:=checkmouse(43,57,75,73,whatopt,2,menucmd,#13);
  whatopt:=checkmouse(43,81,75,97,whatopt,4,menucmd,#13);
  whatopt:=checkmouse(43,105,71,121,whatopt,6,menucmd,#13);
  whatopt:=checkmouse(43,129,73,145,whatopt,8,menucmd,#13);
  whatopt:=checkmouse(43,153,73,169,whatopt,10,menucmd,#13);
  whatopt:=checkmouse(43,177,69,193,whatopt,12,menucmd,#13);
 end;

 until (menucmd <> #1);
 showoption(oldwhatopt,0,1);
 case upcase(menucmd) of

  #0:case readkey of
    #68:quittime:=true;
    #59:begin
         showoption(whatopt,6,-2);
         help;
        end;
  {  #60:saveicons('ACKDATA1.ICO'); }
    'H':begin;dec(whatopt,2);if whatopt<1 then inc(whatopt,12);end;
    'P':begin;inc(whatopt,2);if whatopt>12 then dec(whatopt,12);end;
    'K':begin;dec(whatopt);if whatopt<1 then whatopt:=12;end;
    'M':begin;inc(whatopt);if whatopt>12 then whatopt:=1;end;
    'G':whatopt:=1;
    'Q':whatopt:=12-whatopt MOD 2;
    'O':whatopt:=12;
    'I':whatopt:=2-whatopt MOD 2;

       #50:begin
       if disablemouse then
        begin
          disablemouse:=false;
          initmouse;
		  showmouse;
        end else
        begin
		  disablemouse:=false;
		  hidemouse;
          closemouse;
          disablemouse:=true;
        end;
      end;
    end;
#13,#32:if (ADVNAME<>'NONAME') or (whatopt=1) or (whatopt>10) then
     begin;showoption(whatopt,5,0);
      (*
       for shiftcount:=1 to 10 do
        setrgbpalette(shiftcount+245,ack.phasecolors[shiftcount,1],
          ack.phasecolors[shiftcount,2],ack.phasecolors[shiftcount,3]);
          *)
        case whatopt of
         1:begin
        {$I-}
            ADVNAME:=systemdir+'ACKDATA1';loadfont;ADVNAME:='NONAME';
            i1:=2;graphic^[i1,1,1]:=255;
            closemouse;
            if disablemouse=false then exec2(systemdir+'ACK01.EXE','F'+systemdir+'*'+daughter)
             else exec2(systemdir+'ACK01.EXE','f'+systemdir+'*'+daughter);
            checkexec(doserror,1);
            i1:=2;if graphic^[i1,1,1]<>255 then
           begin
            i:=dosexitcode;

            i1:=1;hres:='';
            for i:=1 to graphic^[i1,1,1] do
             hres:=concat(hres,chr(graphic^[i1,i+1,1]));
            i1:=2;if graphic^[i1,1,1]=1 then passwordok:=false;
            if graphic^[i1,1,1]=2 then passwordok:=true;
            ADVNAME:=hres;
            if ADVNAME<>'NONAME' then begin;loadfont;loadgraps;end
            else
            begin;ADVNAME:=systemdir+'ACKDATA1';loadfont;ADVNAME:='NONAME';end;
           end else
    begin;chdir(systemdir);ADVNAME:='ACKDATA1';loadfont;ADVNAME:='NONAME';end;
           {$I+}
           end;
         3:if passwordok then begin
            exec2(systemdir+modulenum(3),'C'+systemdir+'*'+daughter);
            checkexec(doserror,3);
            i:=dosexitcode;

           end;
         2:begin
              i:=0;
              graphic^[i+241]:=icons^[i+25];
              graphic^[i+242]:=icons^[i+26];
              graphic^[i+243]:=icons^[i+27];
              swapinfo^.data[1]:=0;
              swapinfo^.data[7]:=0;
             repeat                     {2 .}
              if disablemouse then exec2(systemdir+modulenum(2),','+systemdir+'*'+daughter) else
                exec2(systemdir+modulenum(2),'.'+systemdir+'*'+daughter);
              i:=doserror;
              if swapinfo^.data[1]=1 then
               begin
                {execute external program}
                if swapinfo^.data[2]=1 then closegraph;

                if swapinfo^.data[10]=1 then exec2(systemdir+swapinfo^.execfile,swapinfo^.execparam) else
                exec2(swapinfo^.execfile,swapinfo^.execparam);



                {graphicsmode;}
                swapinfo^.data[2]:=lo(dosexitcode);
                swapinfo^.data[4]:=doserror;
               end;
             until (swapinfo^.data[1]=0) or (i<>0);

              checkexec(i,2);

              i:=0;
              graphic^[i+241]:=icons^[i+23];
              graphic^[i+242]:=icons^[i+9];
              graphic^[i+243]:=icons^[i+24];
           end;
         4:if passwordok then
             begin
               exec2(systemdir+modulenum(4),'C'+systemdir+'*'+daughter);
               checkexec(doserror,4);
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
               exec2(systemdir+modulenum(5),'F'+systemdir+'*'+daughter);
               checkexec(doserror,5);
              end;
         6:begin
{            getintvec($1C,oldvector);
            setintvec($1C,@shiftproc); }
           if passwordok then
              begin
               exec2(systemdir+modulenum(6),'G'+systemdir+'*'+daughter);
               checkexec(doserror,6);
              end;
{            setintvec($1C,oldvector); }
             i:=0;
             graphic^[i+241]:=icons^[i+23];
             graphic^[i+242]:=icons^[i+9];
             graphic^[i+243]:=icons^[i+24];
           end;
         7:if passwordok then
             begin
               exec2(systemdir+modulenum(7),'O'+systemdir+'*'+daughter);
               checkexec(doserror,7);
             end;
         8:if passwordok then
              begin
               exec2(systemdir+modulenum(8),'8'+systemdir+'*'+daughter);
               checkexec(doserror,8);
              end;
         9:if passwordok then
              begin
               i:=0;
               graphic^[i+241]:=icons^[i+23];
               graphic^[i+242]:=icons^[i+9];
               graphic^[i+243]:=icons^[i+24];
               exec2(systemdir+modulenum(9),'!'+systemdir+'*'+daughter);
               checkexec(doserror,9);
              end;
        10:if passwordok then
             begin
               exec2(systemdir+modulenum(10),'P'+systemdir+'*'+daughter);
               checkexec(doserror,10);
             end;
        11:if (passwordok) and (ADVNAME<>'NONAME') then
              begin
               exec2(systemdir+modulenum(11),'M'+systemdir+'*'+daughter);
               checkexec(doserror,11);
              end;
        12:quittime:=true;
        end; {case}
        if not quittime then redisplay;
        clear_keyboard_buffer;
        end;
 end; {case}


until quittime;
shutdowngraph;
(*reg.ah:=0;
if u_graph.MONO then reg.al:=7 else reg.al:=2;
intr($10,reg);*)
textmode(co80);textattr:=7;
clrscr;
chdir(systemdir+'.');
end.