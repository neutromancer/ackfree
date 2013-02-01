
function selectcreature(start:byte):byte;
const
 XLOC=20;
 YLOC=20;
var
 numobjs:byte; {number of objs in this catagory}
 currcat:byte; {current catagory}
 whatobj,whatobjold:byte; {what obj, 1..numobjs}
 topobj,topobjold:byte;
 objlist:array[1..MAXCRCS] of byte;
 done:boolean;
 redisplay_sidebar:boolean;
 i:integer;
 j:char;

procedure makecrclist;
var c:byte;s:string[18];
begin
 topobjold:=255;
 whatobjold:=255;
 blankbox(XLOC*4,YLOC+8,XLOC*4+183,YLOC+153);
 case currcat of
  1:s:='LAWFUL PEOPLE   ';
  2:s:='EVIL PEOPLE     ';
  3:s:='NEUTRAL PEOPLE  ';
  4:s:='ANIMALS/MONSTERS';
 end;
 say(XLOC+2,YLOC,6,s);
 numobjs:=0;
 whatobj:=1;
 topobj:=1;
 for c:=1 to MAXCRCS do
  if crc^[c].t=currcat then
    begin;inc(numobjs);objlist[numobjs]:=c;end;
end;


begin
 done:=false;
 if start<>0 then
  currcat:=crc^[start].t
  else currcat:=1;
  whatobjold:=1;
 whatobjold:=255;
 blankbox(XLOC*4-3,YLOC-3,XLOC*4+187,YLOC+156);
 drawh(XLOC*4-2,YLOC-2,XLOC*4+186,3);
 drawh(XLOC*4-2,YLOC+155,XLOC*4+186,3);
 drawv(XLOC*4-2,YLOC-2,YLOC+155,3);
 drawv(XLOC*4+186,YLOC-2,YLOC+155,3);
  makecrclist;
repeat
   if numobjs>9 then
    if whatobjold<>whatobj then
   begin
    for i:=1 to 18 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
    i:=trunc(whatobj/numobjs*18);
    say(XLOC,YLOC+i*8,6,' ');           {Remember, whatobj is NOT 1..255}
   end;

if topobjold<>topobj then
  if numobjs=0 then say(XLOC+12,YLOC+8,0,'NONE.')
   else for i:=0 to 8 do
    begin
     if i+topobj<=numobjs then
     begin
      putgrap(XLOC+6,YLOC+8+(16*i),crc^[objlist[topobj+i]].g1);
      say(XLOC+12,YLOC+8+(16*i),0,'                ');
      say(XLOC+12,YLOC+16*(i+1),0,'                ');
      say(XLOC+12,YLOC+16*(i+1),0,crc^[objlist[topobj+i]].n);
      say(XLOC+12,YLOC+8+(16*i),0,'#'+strnum(objlist[topobj+i])+'  ');
     end
     else begin
      say(XLOC+6,YLOC+8+(16*i),0,'                   ');
      say(XLOC+6,YLOC+16*(i+1),0,'                   ');
      end;
    end;
 if numobjs>0 then
  begin
   say(XLOC+10,YLOC+8+(16*(whatobj-topobj)),6,' ');
   say(XLOC+10,YLOC+(16*(whatobj-topobj+1)),6,' ');
  end;
 topobjold:=topobj;
 whatobjold:=whatobj;
 j:=upcase_sync(readkey);
  say(XLOC+10,YLOC+8+(16*(whatobj-topobj)),0,' ');
  say(XLOC+10,YLOC+(16*(whatobj-topobj+1)),0,' ');
 case j of
  #0:case readkey of
   #59:help;
   'K':begin;cycle(currcat,1,4,-1);
       makecrclist;end;
   'M':begin;cycle(currcat,1,4,+1);
       makecrclist;end;
   'H':if whatobj>topobj then dec(whatobj)
       else if topobj>9 then begin;dec(topobj,9);dec(whatobj);end
       else begin;topobj:=1;whatobj:=1;end;
   'P':if whatobj<numobjs then
        if whatobj<topobj+8 then inc(whatobj)
        else begin;topobj:=whatobj+1;inc(whatobj);end;
   'I':if topobj>9 then begin;dec(topobj,9);whatobj:=topobj;end
       else begin;topobj:=1;whatobj:=1;end;
   'Q':if topobj+9<=numobjs then begin;inc(topobj,9);whatobj:=topobj;end
       else begin;topobj:=numobjs;whatobj:=numobjs;end;
   'G':begin;topobj:=1;whatobj:=1;end;
   'O':begin;topobj:=numobjs;whatobj:=numobjs;end;
  end; {0case}
  #32,#13:done:=true;
  #27:begin;whatobj:=0;done:=true;end;
 end; {keycase}

until done;
 if numobjs=0 then whatobj:=0;
 if whatobj<>0 then selectcreature:=objlist[whatobj]
 else selectcreature:=start;
 end;