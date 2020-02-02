{ MsgEdit }


{$m 32000,128000,128000}
uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_help,u_ack04;

{$I I_MSTREC.PAS}

const NUMSOUNDS=19;

var i,i1:integer;
    ss:string;
    crc:^crcarray;
    b:Byte;
    savedexitproc:pointer;
    quittime:boolean;
    objok:boolean;
    Ack:masterrec;
    passwordok:byte;
    systemdir:String;
    pgsub:byte; {1..3 for page 2}


function upcase_sync(r: char): char; forward;

{$I I_ACK01.PAS}
{$I I_MSGED1.PAS}
{$I PTR_PORT.PAS}

var opt:string[1];





function upcase_sync(r: char): char;
begin
 {search and replace and change all upcase (readkey) to upcase_sync (readkey) }
 if r=#9 then
 begin

  loadgraps;
  loadfont;


  sound(500);delay(100);sound(1000);delay(100);nosound;
 end;
 upcase_sync:=upcase(r);
end;

begin
 savedexitproc:=exitproc;   {Set up for custom exit routine}
 exitproc:=@CustomExit;
 if copy(paramstr(4),1,2)<>'CH' then
   begin;writeln('ACK v',(ACKVERSION DIV 10),'.',(ACKVERSION MOD 10),' program file.');
   for i:=0 to paramcount do writeln(paramstr(i));writeln;readln;halt;end;
 usepointers;
 ss:=paramstr(1);
 i:=pos('*',ss);
 ADVNAME:=copy(ss,i+1,length(ss)-i);
 systemdir:=copy(ss,2,i-2);
 bgi_dir:=systemdir;
 u_graph_setup;
 helpfile:=systemdir+'\ACKDATA1.HLP';
 graphicsmode;
 initmouse;
 opt:=copy(paramstr(1),1,1);
 case opt[1] of
   '8':begin
       closemouse;
       pausemouse:=true;

       loadconfig;
       ack.copytype:=0;
       TEXTC0:=ack.textcolors[0];
       TEXTC1:=ack.textcolors[1];
       TEXTC2:=ack.textcolors[2];
       TEXTC4:=ack.textcolors[4];
       TEXTC5:=ack.textcolors[5];
       TEXTC6:=ack.textcolors[6];
         blank0(ack.darkbackground);
       helpindex:=8;
       getmem(talk, 1001 * sizeof (talkrec) );
    {   getmem(picture, sizeof(picturerec)+1 ); }
       getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );
       objok:=loadobjs;
       MsgEditMainMenu;

       end;
   end;

end.
