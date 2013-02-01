{$O+}
unit U_vars;

interface

uses u_adv;

const
 MAXOBJS = 254;  {255 is a creature, 0 is nil}
 MAXCRCS=128; {was 64, so there are now 64 more}


type objnamestype=array[1..12] of string[13];
const OBJNAMES:objnamestype = ('SPACE        ',
               'SPACE*       ','OBSTACLE     ','OBSTACLE*    ',
               'PORTAL       ','MISC. ITEM   ',
               'WEAPON       ','RANGED WEAPON','ARMOR        ',
               'VEHICLE      ','SPELL/SKILL  ','CURRENCY     ');

type

 LocPointer = word;
 LParray = array[1..80,1..40] of LocPointer;

 Objectrec = RECORD
  n:string[16];
  t:byte;
  d:array[1..14] of byte;
  END;
 Objectarray = array[0..0] of Objectrec;

 excrec = RECORD
  fn:string[12];
  prm:string[30];
  gmodein,gmodeout:byte;
  c1,c2,c3,c4:byte;
 end;

 creaturerec = record
      n:string[16];  {name}
      t:byte;        {type, or alignment}
      exphi,g1,g2,g3,g4,t1,h,hm,m,mm, {size, graphics(4), type subset,
                                    hitpoints, magicpoints}
      touchm,deathm,ws,rws,exp,veh,fw,fr,ar:byte;   {str, death macro, weapSk, RweapSk,
                                            experience, vehicle, weapon, rweapon,
                                            armor}
      inv:array[1..3] of byte;
      invn:array[1..3] of byte;
     end;
  crcarray=array[1..1] of creaturerec;




 Portdestrec = RECORD
  region,rx,ry,x,y:byte;  {rx is used for room}
  used:boolean;
  END;

 Roomsrec = RECORD
  case boolean of
   true:(
  Name: array[1..16] of string[20];
  x1,y1,x2,y2: array[1..16] of byte;
  wallgrap: array[1..16] of byte;
  wmap:array[1..32,1..32] of byte;
  cells:byte; {cells in wmap}
   )
  END;

 Regionrec = RECORD
  shadow:byte;
  Name: string[30];
  rooms:byte;  {255 for worldmap}
  room:roomsrec;
  port:array[1..255] of portdestrec; {portal destinations, 0 is a 2way door}
 END;

 Loccontrec = RECORD
  obj, objcode: byte;
  p:locpointer;
  END;
 LCRarray = array[1..1] of Loccontrec;

 Shortmsgrec = RECORD
  empty:boolean;
  chars:array[1..2] of string[40];
  attrs:array[1..2,1..37] of byte;
  END;

 Longmsgrec = RECORD
  empty:boolean;
  chars:array[1..22] of string[40];
  attrs:array[1..22,1..32] of byte;
  END;

 Talkrec = RECORD
  headertype:byte;
  header:string[8];
  datatype:byte;
  data:string[30];
  next:word;
  END;
 talkarray = array[1..1] of talkrec;
 mosaicrec = array[1..16,1..11] of byte;

var
 crcsounds:array[1..MAXCRCS] of word; {hi: hostile  lo: dying}
 shortmsg:shortmsgrec;
 longmsg:longmsgrec;
 talk:^talkarray;
 mosaic:mosaicrec;
 region:regionrec;
 rmcnt:^LParray;  { rmcnt^[10,10] := 1234;    }
 locnt:^LCRarray; { locnt^[187].obj := 12; }
 obj:^Objectarray;

procedure load_objs;
procedure save_shortmsgfile(mn:word);
procedure clear_shortmsg;
procedure load_shortmsgfile(mn:word);
procedure cycle(var v:byte;min,max:word;stepp:integer);
procedure getmem2(var varpointer:pointer;varsize:word);


implementation

procedure load_objs;
 var f:file of objectrec;
     fc:byte;
begin
 assign(f,concat(ADVNAME,OBJECTFILE));
 {$I-} reset(f); {$I+}
 if IoResult<>0 then exit;
 for fc:=1 to MAXOBJS do read(f,obj^[fc]);
 close(f);
end;


procedure save_shortmsgfile(mn:word);
 var f:file of shortmsgrec;
begin
 if mn>255 then
  begin
   mn:=mn-255;
   assign(f,ADVNAME+SHORTMSGFILE2);
  end
  else assign(f,ADVNAME+SHORTMSGFILE);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then exit;
 shortmsg.empty:=false;
 seek(f,mn-1);
 write(f,shortmsg);
 close(f);
end;

procedure clear_shortmsg;
var i1:integer;
begin
 shortmsg.empty:=true;
 shortmsg.chars[1]:='';
 for i1:=1 to 37 do
  begin
   shortmsg.attrs[1,i1]:=0;shortmsg.attrs[2,i1]:=0;
   shortmsg.chars[1]:=concat(shortmsg.chars[1],#1);
  end;
  shortmsg.chars[2]:=shortmsg.chars[1];
 end;


procedure create_shortmsgfile;
 var i,i1:byte;
  f:file of shortmsgrec;
begin
 assign(f,ADVNAME+SHORTMSGFILE);
 {$I-} rewrite(f); {$I+}
 if ioresult<>0 then exit;
  clear_shortmsg;
  write(f,shortmsg);
  close(f);
 end;

procedure create_shortmsgfile2;
 var i:word;
  f:file of shortmsgrec;
begin
 assign(f,ADVNAME+SHORTMSGFILE2);
 {$I-} rewrite(f); {$I+}
 {if ioresult<>0 then exit;}
  clear_shortmsg;
  for i:=1 to 745 do write(f,shortmsg);
  close(f);
 end; 
 

procedure load_shortmsgfile(mn:word);
 var f:file of shortmsgrec;
begin
 if (mn=0) or (mn>1000) then exit;
 if mn>255 then
  begin
   assign(f,ADVNAME+SHORTMSGFILE2);
   {$I-} reset(f); {$I+}
   if ioresult<>0 then begin;create_shortmsgfile2;exit;end;
   seek(f,mn-256);
  end else
 begin
  assign(f,ADVNAME+SHORTMSGFILE);
  {$I-} reset(f); {$I+}
  if ioresult<>0 then begin;create_shortmsgfile;exit;end;
  if filesize(f)>=mn then seek(f,mn-1);
 end; 

 read(f,shortmsg);
 close(f);
end;


procedure cycle;
begin
 v:=v+stepp;if v>max then v:=min;if v<min then v:=max;
end;


procedure getmem2;
 var ft:text;
begin
 if maxavail>=varsize then
  getmem(varpointer,varsize) else
   begin
    assign(ft,'CON');
    rewrite(ft);
    writeln('Not enough memory!');
    close(ft);
    halt;
   end;
end;

begin
 {each region gets one of these, in a file.  The file on disk
  is only as big as needs be.  The 2nd one may expand or contract
  during use, however.}
(*
 getmem(talk, 256 * sizeof (talkrec) );
 getmem(picture, sizeof(picturerec)+1 );
 getmem(rmcnt, 80*40 * sizeof( LocPointer ) );
 getmem(locnt, 2560 * sizeof( LocContRec ) );
 getmem(obj, MAXOBJS * sizeof ( Objectrec ) );
 *) {copy these into program as needed}
end.