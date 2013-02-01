{$IFNDEF MAPOVER}
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

{$I I_CRCREC.PAS}
{$I I_WANDC1.PAS}

var xinloc,yinloc:byte;
    xchunkloc,ychunkloc:integer;
    veh:vehrec;
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
{$ENDIF}

var lastgrap:byte;

procedure savewmap;
 var chf:file of chunkrec;
    c1,c2:byte;
    ch:chunkprec;
    vhf:file of vehrec;
begin
 ch:=chunk;
 assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
 {$I-} reset(chf); {$I+}
 if ioresult<>0 then exit;
 for c1:=1 to 3 do for c2:=1 to 3 do
  if ch[c1,c2]=chunk[2,2] then ch[c1,c2]:=0;
 ch[2,2]:=chunk[2,2];
 for c1:=1 to 3 do for c2:=1 to 3 do
  if ch[c1,c2]<>0 then
   if ch[c1,c2]<=filesize(chf) then
   begin
    seek(chf,ch[c1,c2]-1);
    write(chf,map[c1,c2]);
  end;
 close(chf);
 assign(vhf,ADVNAME+MAPBFILE+strnum(thisregion));
 {$I-} reset(vhf); {$I+}
 if ioresult<>0 then exit;
 write(vhf,veh);
 close(vhf);

end;


procedure loadwmap;
 var chf:file of chunkrec;
   cx,cy,c1,c2:byte;
   readcrc:boolean;
begin
 readcrc:=true;
 assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
 {$I-} reset(chf); {$I+}
 if ioresult<>0 then exit;
 for c1:=1 to 3 do for c2:=1 to 3 do
  if chunk[c1,c2]<>0 then begin
   if chunk[c1,c2]<=filesize(chf) then
   begin
    seek(chf,chunk[c1,c2]-1);
    read(chf,map[c1,c2]);
   end;
  end else
    for cx:=1 to 16 do for cy:=1 to 16 do
     begin
      map[c1,c2,cx,cy].o:=region.room.wallgrap[1];
      map[c1,c2,cx,cy].d:=region.room.wallgrap[2];
     end;
 close(chf);
end;



procedure loadmap(n:byte);
 var rgf:file of regionrec;
     lpf:file; { of locpointer; }
     lcf:file; { of loccontrec; }
     lcf2:file of loccontrec; {to find size}
     chf:file of chunkrec;
     vhf:file of vehrec;
     fc:word;
     aa,bb:byte;
     wcf:file of wander_index_32;
	 wc:wander_index_32;
	 rc:rcrcarray;

procedure copywc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+32 do
  wander_index^[i]:=wc[i-start];
end;
	
procedure copyrc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+64 do if i<255 then
  rcrc^[i]:=rc[i-start];
end;
	
begin

 assign(wcf,ADVNAME+MAPWFILE+strnum(n));
 {$I-} reset(wcf); {$I+}
 if ioresult<>0 then
  begin
   for fc:=1 to 32 do
     wc[fc].x:=0;
   for fc:=1 to WANDERMAX do
     wander_index^[fc].x:=0;	 
   rewrite(wcf);
   write(wcf,wc);
   close(wcf);
  end else
  begin
   read(wcf,wc);
   copywc(0);
   if eof(wcf) then
	 for fc:=33 to WANDERMAX do
	  wander_index^[fc].x:=0
   else
    begin
	 for fc:=(32 DIV 32) to (WANDERMAX DIV 32)-1 do
	  begin
	   read(wcf,wc);
	   copywc(32 * fc);
	   
	  end;
    end;	
   close(wcf);
  end;

 thisregion:=n;
 assign(rgf,ADVNAME+REGIONFILE);
 {$I-} reset(rgf); {$I+}
 if ioresult<>0 then exit;
 if filesize(rgf)<n then exit;
 seek(rgf,n-1);
 read(rgf,region);
 close(rgf);
 assign(rcrcf,ADVNAME+MAPCFILE+strnum(n));
 {$I-} reset(rcrcf); {$I+}
 if ioresult<>0 then exit;
 
   read(rcrcf,rc);
   copyrc(0);
   if eof(rcrcf) then
	 for fc:=65 to RCMAX do
          begin
           rcrc^[fc].crcsource:=0;
           rcrc^[fc].used:=false;
          end

   else
    begin
	 for fc:=(64 DIV 64) to (256 DIV 64)-1 do
	  begin
	   read(rcrcf,rc);
	   copyrc(64 * fc);
	  end;
    end;
 
 
 close(rcrcf);
 if region.rooms>20 then
   begin
     assign(vhf,ADVNAME+MAPBFILE+strnum(n));
     {$I-} reset(vhf); {$I+}
     if ioresult<>0 then exit;
     read(vhf,veh);
     close(vhf);
     {load worldmap}
   end
  else begin
    assign(lpf,ADVNAME+MAPAFILE+strnum(n));
    assign(lcf,ADVNAME+MAPBFILE+strnum(n));
    assign(lcf2,ADVNAME+MAPBFILE+strnum(n));
    {$I-}
    reset(lcf2);locntsize:=filesize(lcf2);close(lcf2);
    reset(lpf,1);
     if ioresult<>0 then exit;
     blockread(lpf,rmcnt^[1],6400);
    close(lpf);
    reset(lcf,1);
    if ioresult<>0 then exit;
    {$I+}
    blockread(lcf,locnt^[1],locntsize*sizeof(loccontrec));
   { for aa:=1 to 80 do for bb:=1 to 40 do
     read(lpf,rmcnt^[aa,bb]);
    fc:=0;
    while not eof(lcf) do
     begin
      inc(fc);
      read(lcf,locnt^[fc]);
     end;
    locntsize:=fc; }
   close(lcf);
  end;
end;


{for corner chunk: scan to the side until it hits something, then scan up
 until it hits something, and that something will be it}

procedure numscan(var arg:integer;amt:integer);
begin
 arg:=arg+amt;
 if arg>32 then arg:=1;if arg<1 then arg:=32;
end;

procedure getchunks(chunkx,chunky:byte);
 var c1,c2,cc1,cc2,scanarg:integer;
begin
(*  writeln(printer,'Start of getchunks():');
  for c1:=1 to 3 do writeln(printer,strnum(chunk[1,c1])+
     ' '+strnum(chunk[2,c1])+' '+strnum(chunk[3,c1])); *)

 for c1:=1 to 3 do for c2:=1 to 3 do chunk[c1,c2]:=0;
 for c1:=chunkx-1 to chunkx+1 do
  for c2:=chunky-1 to chunky+1 do
   begin
    cc1:=chunkx;cc2:=chunky;
    scanarg:=(c1-chunkx+2)*10+(c2-chunky+2);
    if region.room.wallgrap[1]=0 then
    case scanarg of
     21:repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
     12:repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
     23:repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
     32:repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
     11:begin
         repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
        end;
     31:begin
         repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,-1) until region.room.wmap[cc1,cc2]<>0;
        end;
     13:begin
         repeat numscan(cc1,-1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
        end;
     33:begin
         repeat numscan(cc1,1) until region.room.wmap[cc1,cc2]<>0;
         repeat numscan(cc2,1) until region.room.wmap[cc1,cc2]<>0;
        end;
     end else
      begin
       cc1:=c1;cc2:=c2;
      end;
      if (cc1>=1) and (cc1<=32) and (cc2>=1) and (cc2<=32) then
      chunk[c1-chunkx+2,c2-chunky+2]:=region.room.wmap[cc1,cc2]
       else chunk[c1-chunkx+2,c2-chunky+2]:=0;
 end;
(*  writeln(printer,'End of getchunks():');
  for c1:=1 to 3 do writeln(printer,strnum(chunk[1,c1])+
     ' '+strnum(chunk[2,c1])+' '+strnum(chunk[3,c1])); *)
 loadwmap;
end;


procedure chunkmove(dir:byte);
 var wrap:boolean;
begin
 if region.room.wallgrap[1]=0 then wrap:=true else wrap:=false;
 if onlycell then exit;
 case dir of
  NORTH:
        if wrap then begin
         repeat
          numscan(ychunkloc,-1);
         until region.room.wmap[xchunkloc,ychunkloc]<>0;
         yinloc:=16;
        end else begin
         dec(ychunkloc);
         yinloc:=16;
        end;
  SOUTH:
        if wrap then begin
         repeat
          numscan(ychunkloc,1);
         until region.room.wmap[xchunkloc,ychunkloc]<>0;
        yinloc:=1;
        end else begin
         yinloc:=1;
         inc(ychunkloc);
        end;
  EAST:
       if wrap then begin
        repeat
         numscan(xchunkloc,1);
        until region.room.wmap[xchunkloc,ychunkloc]<>0;
        xinloc:=1;
       end else begin
        xinloc:=1;
        inc(xchunkloc);
       end;
  WEST:
       if wrap then begin
        repeat
         numscan(xchunkloc,-1);
        until region.room.wmap[xchunkloc,ychunkloc]<>0;
        xinloc:=16;
        end else begin
         xinloc:=16;
         dec(xchunkloc);
       end;
 end; {case}
 if CHUNKSAVE then savewmap;
 getchunks(xchunkloc,ychunkloc);
end;



function roomloc(r,x,y:byte):locpointer;
begin
 with region.room do
  roomloc:=rmcnt^[x1[r]-1+x,y1[r]-1+y];
end;

procedure getroom(n:byte);
 var c1,c2:byte;
     b1,b2:byte;
     point:locpointer;
begin
 if n>region.rooms then exit;
 with region.room do
  begin
   roomwide:=x2[n]-x1[n]+1;roomtall:=y2[n]-y1[n]+1;
   for c1:=x1[n] to x2[n] do for c2:=y1[n] to y2[n] do
    begin
     point:=roomloc(n,c1-x1[n]+1,c2-y1[n]+1);
     if point=0 then b1:=0 else
      begin
       b1:=locnt^[point].obj;
       b2:=locnt^[point].objcode;
      end;
     map[2,2,c1-x1[n]+1,c2-y1[n]+1].o:=b1;
     map[2,2,c1-x1[n]+1,c2-y1[n]+1].d:=b2;
    end;
  end;
end;


procedure showroom(room:byte);
var x,y:byte;
begin
 clearscreen;
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
{ drawh(0,200,319,3);}
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3);
 for x:=1 to roomwide do for y:=1 to roomtall do
 begin
  if map[2,2,x,y].o<>255 then
  begin
  if obj^[map[2,2,x,y].o].d[1]>240 then
   putgrap2(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     map[2,2,x,y].d)
   else
   putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     obj^[map[2,2,x,y].o].d[1]);
  end else
   begin
    putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     crc^[rcrc^[map[2,2,x,y].d].crcsource].g1);
    if rcrc^[map[2,2,x,y].d].show=false then
     say(x*4-2 +(32-(roomwide*2)) ,y*16-10 +(88-(roomtall*8)),0,'?');
   end;


 end;

  for i:=1 to WANDERMAX do
   if (wander_index^[i].x=room) 
     then
      say(wander_index^[i].xin*4-2 +(32-(roomwide*2)) ,wander_index^[i].yin*16-10 +(88-(roomtall*8)),0,'W');


 drawv((33-(roomwide*2))*4 -2, (90-(roomtall*8)) -2, (90+(roomtall*8)) +2,3);
 drawv((33+(roomwide*2))*4 +2, (90-(roomtall*8)) -2, (90+(roomtall*8)) +2,3);
 drawh((33-(roomwide*2))*4 -2, (90-(roomtall*8)) -2, (33+(roomwide*2))*4 +2,3);
 drawh((33-(roomwide*2))*4 -2, (90+(roomtall*8)) +2, (33+(roomwide*2))*4 +2,3);
 if roomtall<>11 then
  say(3,2,5,' N Û0: '+region.room.name[room]);
end;



procedure previewrooms;
var c1,c2:integer;
   px,py:byte;
begin
 clearscreen;
 for c1:=1 to region.rooms do
   with region.room do
    if x1[c1]<>0 then 
	 begin
	  boxx(x1[c1]-1,y1[c1],x2[c1]-1,y2[c1]);
	  {draw contents of room}

	  for px:=x1[c1]+1 to x2[c1]-1 do for py:=y1[c1]+1 to y2[c1]-1 do
	   if rmcnt^[px,py]=0 then
	   putthing(px-1,py*4,mapcolors[0])
	   else putthing(px-1,py*4,mapcolors[locnt^[rmcnt^[px,py]].obj]);
	   
	 end; 
 for c1:=1 to region.rooms do
   with region.room do
   if x1[c1]<>0 then say(region.room.x1[c1]-1,region.room.y1[c1]*4,6,chr(64+c1));
end;

procedure takething(xx,yy:byte);  { these are acceptable in either mode }
var i:integer;
begin
 xx:=xx*4;
 for i:=yy+1 to yy+4 do
  thingtaken[i-yy]:=mem[scrnl:xx+scrnh[i]];
end;
procedure replacething(xx,yy:byte);
var i:integer;
begin
 xx:=xx*4;
 for i:=yy+1 to yy+4 do mem[scrnl:xx+scrnh[i]]:=thingtaken[i-yy];
end;


function chooseroom(s2:string):byte;
var s:string;
    j:char;
    j2:integer;
 begin
   s:='                                        ';
   say(2,173,0,s);say(2,182,0,s);say(2,191,0,s);
   say(1,182,0, 'PRESS THE KEY OF THE ROOM TO '+s2);
   j:=upcase_sync(readkey);
   say(1,182,0,s);
   j2:=ord(j)-64;
   if (j2<1) or (j2>region.rooms) then j2:=0;
   chooseroom:=j2;
 end;



procedure otherwalkroom(var room,x,y:byte);
 var j:char;
     done:boolean;
     xorx,xory:integer;
     n,xloc,yloc:byte;

procedure maponly;
var x,y:byte;
begin
 for x:=1 to roomwide do for y:=1 to roomtall do
 begin
  if map[2,2,x,y].o<>255 then
  begin
  if obj^[map[2,2,x,y].o].d[1]>240 then
   putgrap2(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     map[2,2,x,y].d)
   else
   putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     obj^[map[2,2,x,y].o].d[1]);
  end  
  else
   begin
    putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     crc^[rcrc^[map[2,2,x,y].d].crcsource].g1);
    if rcrc^[map[2,2,x,y].d].show=false then
     say(x*4-2 +(32-(roomwide*2)) ,y*16-10 +(88-(roomtall*8)),0,'?');
   end;
  end;
end;

procedure erset;  {show stuff after showroom; }
 var layc:byte;
begin
 say(66,10,5,' …† ');
 say(67,20,0,'SELECT');
 say(66,35,5,' Š ');
 say(67,45,0,'ABORT');
 say(66,60,5,' Z ');
 say(67,70,0,'ZOOM');
 say(68,78,0,'OUT');
end;

procedure getlocation;
begin
 previewrooms;
 n:=chooseroom('USE');
 if n=0 then n:=1;
 getroom(n);
 showroom(n);xloc:=roomwide DIV 2;yloc:=roomtall DIV 2;
 erset;
end;

begin
 done:=false;
 if gotolocation then
 begin
  getroom(room);
  n:=room;
  xloc:=x;yloc:=y;
  showroom(room);erset;
 end else getlocation;
repeat
 xorx:=xloc*4-3+(32-(roomwide*2));
 xory:=yloc*16-14+(88-(roomtall*8));
    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory);
 j:=upcase_sync(readkey);
    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory);
 case j of
  #0: case readkey of
   #59:help;
  'H':if yloc>1 then dec(yloc);
  'K':if xloc>1 then dec(xloc);
  'M':if xloc<roomwide then inc(xloc);
  'P':if yloc<roomtall then inc(yloc);
  end;
 'Z':getlocation;
 #27:begin;x:=0;done:=true;end;
 #13:done:=true;
 #13:begin
     if ((xchunkloc>=1) and (xchunkloc<=32) and
      (ychunkloc>=1) and (ychunkloc<=32))
    then if region.room.wmap[xchunkloc,ychunkloc]<>0 then
      done:=true;
     if not done then begin;sound(500);delay(200);end;
    end;
 end;
until done;
 x:=xloc;y:=yloc;room:=n;
end;






procedure otherwalkworldmap(var xchunk,ychunk,x,y:byte);
 var j:char;
     done:boolean;
     putgrapc:byte;
     visimap:array[0..10,0..8] of byte;
     xsc,ysc:byte;
     vehhere:boolean;
     vehcount:byte;
     old_xch,old_ych,old_yin,old_xin:byte;
     old_region:byte;
     old_onlycell:boolean;

procedure showwalk;
 var layc:byte;
begin
 clearscreen;
 say(52,10,5,' …† Û0 TO SELECT');
 say(52,30,5,'ESCÛ0 TO EXIT');
 say(52,50,5,' Z Û0: ZOOM OUT');
 boxx(1,1,48,39);
 boxx(8,39,41,42);
end;

procedure getlocation;
 var
  wmaph,wmapw:byte;
  topx,topy,cellx,celly:byte;
  done2:boolean;
  j2:char;
  i:integer;
  chf:file of chunkrec;
  map22:chunkrec;
  pointx,pointy:byte;
  newx1,newx2,newy1,newy2:byte;
begin
  showwalk;
  say(52,50,0,'             ');
  say(12,160,0,'ZOOM VIEW');
  
  
  wmapw:=1;wmaph:=1;
  for topx:=1 to 32 do for topy:=1 to 32 do
   if region.room.wmap[topx,topy]<>0 then 
	begin
	if topx>wmapw then wmapw:=topx;
	if topy>wmaph then wmaph:=topy;
	end;
  

  
  
  
          assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
          {$I-} reset(chf); {$I+}
          if region.rooms<>254 then begin;topx:=1;topy:=1;end;
          if ioresult=0 then
 

          begin
           for xchunkloc:=1 to wmapw do
            for ychunkloc:=1 to wmaph do
			 begin
			 
			  topx:=(94 - (wmapw*2)) + ((xchunkloc-1)*4);
			  topy:=(81 - (wmaph*2)) + ((ychunkloc-1)*4);
			 
       		  {topx:=160-((wmapw DIV 2) *4)+((xchunkloc -1)*4);
			  topy:=65-((wmaph DIV 2) *4)+((ychunkloc -1)*4);}
              if region.room.wmap[xchunkloc,ychunkloc]=0 then
			  begin
			   for pointx:=0 to 3 do for pointy:=0 to 3 do
                putpixel(topx+pointx,topy+pointy,0);
			  end else
              begin
               {$I-}
               seek(chf,region.room.wmap[xchunkloc,ychunkloc]-1);
               read(chf,map22);
               {$I+}
               for pointx:=0 to 3 do for pointy:=0 to 3 do
                putpixel(topx+pointx,topy+pointy,mapcolors[map22[pointx*4+2,pointy*4+2].o]);
              end;
             end;
          end;
 
         {$I-} close(chf); {$I+}
 
  
 		newx1:= 161 - (wmapw*2) -66;
		newx2:= 162 + (wmapw*2) -66;
		
		newy1:= 65 - (wmaph*2) +15;
		newy2:= 66 + (wmaph*2) +15;
		
		sketchline(newx1,newy1,newx1,newy2,hi(TEXTC0)); {left}
		sketchline(newx1,newy1,newx2,newy1,hi(TEXTC0)); {top}
		sketchline(newx2,newy1,newx2,newy2,hi(TEXTC0)); {right}
		sketchline(newx1,newy2,newx2,newy2,hi(TEXTC0)); {bottom} 
  
	 
	 
	 
  if (wmaph=1) and (wmapw=1) then
   begin;xchunkloc:=1;ychunkloc:=1;end else
   begin

   { boxx((24-(wmapw DIV 2)),(20-(wmaph DIV 2)),
     (24-(wmapw DIV 2))+wmapw-1,(20-(wmaph DIV 2))+wmaph-1);}

  {  if region.rooms=254 then
     for cellx:=1 to 32 do for celly:=1 to 32 do
      if region.room.wmap[cellx,celly]<>0 then
       putthing(7+cellx,(3+celly)*4,2) else
       putthing(7+cellx,(3+celly)*4,8);}


    cellx:=1;celly:=1;
    repeat
     done2:=false;
   {  if region.room.wmap[cellx,celly]=0 then
      putthing(topx+cellx,4*(topy+celly),4) else
       putthing(topx+cellx,4*(topy+celly),5); }
	topx:=(162 - (wmapw*2)) + ((cellx-1)*4) -66;
	topy:=(66 - (wmaph*2)) + ((celly-1)*4) +14;
	xorthing2(topx,topy);	  
			  
    j2:=upcase_sync(readkey);
	xorthing2(topx,topy);
  {  if region.rooms=254 then
     begin
      if region.room.wmap[cellx,celly]<>0 then
       putthing(topx+cellx,4*(topy+celly),2) else
       putthing(topx+cellx,4*(topy+celly),8);
     end else

     if (cellx=1) or (cellx=wmapw) or (celly=1) or (celly=wmaph)
      then putthing(topx+cellx,4*(topy+celly),3)
      else putthing(topx+cellx,4*(topy+celly),0); }
	  
    case j2 of
     #0:case readkey of
         #59:help;
         'H':if celly>1 then dec(celly);
         'P':if celly<wmaph then inc(celly);
         'K':if cellx>1 then dec(cellx);
         'M':if cellx<wmapw then inc(cellx);
        end;
     #27:begin;cellx:=32;celly:=32;done2:=true;end;
     #13:begin;done2:=true;putthing(topx+cellx,topy+celly,1);end;
    end;
    until done2;
   xchunkloc:=cellx;ychunkloc:=celly;
  end;
 if region.room.wmap[xchunkloc,ychunkloc]=0 then
  begin;xchunkloc:=1;ychunkloc:=1;end;
 getchunks(xchunkloc,ychunkloc);
 xinloc:=8;yinloc:=8;
 showwalk;
end;

begin
 lastgrap:=1;
 old_onlycell:=onlycell;
 CHUNKSAVE:=false;
 onlycell:=false;
 if gotolocation then
  begin
   xchunkloc:=xchunk;ychunkloc:=ychunk;xinloc:=x;yinloc:=y;
   getchunks(xchunkloc,ychunkloc);
   showwalk;
  end else getlocation;
 done:=false;
repeat
 for xsc:=0 to 10 do for ysc:=0 to 8 do
  if map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].o<>255 then
   visimap[xsc,ysc]:=
     obj^[map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].o].d[1]
   else
    begin
     visimap[xsc,ysc]:=crc^[rcrc^[map[((xinloc+xsc+10) DIV 16)+1,
      ((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1,
      ((yinloc+ysc+11) MOD 16)+1].d].crcsource].g1;
    end;
 for xsc:=0 to 10 do for ysc:=0 to 8 do
  if visimap[xsc,ysc]>240 then
   putgrap2(xsc*4+3,ysc*16+10,map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].d)
  else putgrap(xsc*4+3,ysc*16+10,visimap[xsc,ysc]);
   say(12,160,0,'('+strnum((xchunkloc-1)*16+xinloc)+','+
      strnum((ychunkloc-1)*16+yinloc)+') ');
 xorthing(23,74);xorthing(26,86);xorthing(23,86);xorthing(26,74);
 j:=upcase_sync(readkey);
 case j of
  #0: case readkey of
  #59:help;
  'H':if yinloc>1 then dec(yinloc) else chunkmove(NORTH);
  'K':if xinloc>1 then dec(xinloc) else chunkmove(WEST);
  'M':if xinloc<16 then inc(xinloc) else chunkmove(EAST);
  'P':if yinloc<16 then inc(yinloc) else chunkmove(SOUTH);
  end;
 'Z':getlocation;
 #27:begin;done:=true;xinloc:=0;end;
 #13:begin
     if ((xchunkloc>=1) and (xchunkloc<=32) and
      (ychunkloc>=1) and (ychunkloc<=32))
    then if region.room.wmap[xchunkloc,ychunkloc]<>0 then
      done:=true;
     if not done then begin;sound(500);delay(200);end;
    end;
 end;
until done;
 xchunk:=xchunkloc;ychunk:=ychunkloc;
 x:=xinloc;y:=yinloc;
 onlycell:=old_onlycell;
end;



function menuselectregion(def:byte):byte;
const
 XLOC=4;
 YLOC=25;
var
 portalb:byte;
 numobjs:byte; {number of objs in this catagory}
 whatobj,whatobjold:byte; {what obj, 1..numobjs}
 topobj,topobjold:integer;
 objlist:array[1..99] of string[20];
 done:boolean;
 redisplay_sidebar:boolean;
 i:integer;
 j:char;
 rtype:array[1..99] of byte;

procedure makeobjlist;
var c:byte;
   listregion:regionrec;
   lrgf:file of regionrec;
begin
 topobjold:=255;
 whatobjold:=255;
{ blankbox(XLOC*4,YLOC+8,(XLOC+21)*4,YLOC+153); }
 say(XLOC+6,YLOC,1,'SELECT REGION');
 numobjs:=0;
 whatobj:=def;
 topobj:=def-3;if topobj<1 then topobj:=1;
 assign(lrgf,ADVNAME+REGIONFILE);
 {$I-} reset(lrgf); {$I+}
 if ioresult<>0 then exit;
 for c:=1 to filesize(lrgf) do
   if filesize(lrgf) >= c then
    begin
     read(lrgf,listregion);
     objlist[c]:=listregion.name;
     case listregion.rooms of
      0..20:rtype[c]:=241;
      254:rtype[c]:=243;
      else rtype[c]:=242;
     end;
     if listregion.name='(DELETED)' then rtype[c]:=0;
    end;
 numobjs:=filesize(lrgf);
 if numobjs<=9 then topobj:=1;
 close(lrgf);
end;


begin
 portalb:=def DIV 128;
 def:=def MOD 128;
 done:=false;
 whatobjold:=255;
 blankbox(XLOC*4+4,YLOC-3,(64+XLOC)*4,YLOC+156);
 drawh(XLOC*4+5,YLOC-2,(63+XLOC)*4+2,3);
 drawh(XLOC*4+5,YLOC+155,(63+XLOC)*4+2,3);
 drawv(XLOC*4+5,YLOC-2,YLOC+155,3);
 drawv((63+XLOC)*4+2,YLOC-2,YLOC+155,3);
 makeobjlist;
repeat
   if numobjs>9 then
    if whatobjold<>whatobj then
   begin
    for i:=1 to 18 do begin;say(XLOC,YLOC+i*8,5,'Œ');end;
    i:=trunc(whatobj/numobjs*18);
    say(XLOC,YLOC+i*8,6,' ');           {Remember, whatobj is NOT 1..255}
   end;

if topobjold<>topobj then
  if numobjs=0 then
   begin
    say(XLOC+12,YLOC+8,0,'NO REGIONS AVAILABLE.');
    say(XLOC+12,YLOC+18,0,'PRESS Û5 ESC ');
   end
   else for i:=0 to 8 do
    begin
     if i+topobj<=numobjs then
     begin
      putgrap(XLOC+6,YLOC+8+(16*i),rtype[topobj+i]);
      say(XLOC+12,YLOC+8+(16*i),0,'                 ');
      say(XLOC+12,YLOC+16*(i+1),0,'                 ');
      say(XLOC+12,YLOC+16*(i+1),0,objlist[topobj+i]);
      say(XLOC+12,YLOC+8+(16*i),0,'#'+strnum(topobj+i)+'  ');
     end
     else begin
      say(XLOC+6,YLOC+8+(16*i),0,'                    ');
      say(XLOC+6,YLOC+16*(i+1),0,'                    ');
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
  'L':if portalb>0 then begin;whatobj:=202;done:=true;end;
  #32,#13:if objlist[whatobj]<>'(DELETED)' then done:=true;
  #27:begin;whatobj:=0;done:=true;end;
 end; {keycase}

until done;
 if numobjs=0 then whatobj:=0;
 if whatobj<>0 then menuselectregion:=whatobj
 else menuselectregion:=0;
 end;


{const objok = true;}
{$IFDEF MAPOVER}
{$I I_DLGED1}

function dialogue_title(n:byte):string;
 var df:file of talkrec;
     talkbuff:talkrec;
     s:string[32];
begin
  if n=0 then s:='(NONE)' else
 begin
  assign(df,ADVNAME+DIALOGUEFILE);
  {$I-} reset(df); {$I+}
  if ioresult<>0 then s:='*ERROR*' else
  begin
   seek(df,n);
   read(df,talkbuff);
   close(df);
  end;
  s:=talkbuff.data;
 end;
 s:='DLG: '+s;
 dialogue_title:=s;
end;


function selectdialogue:byte;
var thisd,topd:byte;
    s:string;done:boolean;
    j:char;
    tc:byte;i,i1:byte;
    changed:boolean;
    titles:array[1..255] of string[16];

procedure load_dialogue_titles;
var df:file of talkrec;
    talkbuff:talkrec;
    i:integer;
begin
 assign(df,ADVNAME+DIALOGUEFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then exit;
 read(df,talkbuff);
 for i:=1 to 255 do
 begin
  read(df,talkbuff);
  titles[i]:=talkbuff.data;
 end;
 close(df);
end;

begin
 blankbox(12,10,191,156);boxx(1,1,48,39);
 say(8,2,6,'SELECT DIALOGUE');

 for i:=1 to 255 do titles[i]:='NO DIALOGUE FILE';
 load_dialogue_titles;
 done:=false;changed:=true;
 topd:=1;thisd:=1;
 repeat
  if changed then
   for tc:=topd to topd+15 do
    begin
     s:=strnum(tc);
     i1:=length(s);for i:=i1 to 2 do s:=' '+s;
     s:=s+'  '+titles[tc];
     i1:=length(s);for i:=i1 to 21 do s:=s+' ';
     say(4,(tc-topd)*9+12,0,s);
     changed:=false;
    end;

  say(11,(thisd-1)*9+12,6,' ');
  j:=upcase_sync(readkey);
  say(11,(thisd-1)*9+12,0,' ');

  case upcase(j) of
   #0:case readkey of
       #59:help;
       'G':begin;topd:=1;thisd:=1;changed:=true;end;
       'H':if thisd>1 then
            dec(thisd) else
           if topd>1 then begin;dec(topd);changed:=true;end;
       'P':if thisd<16 then
            inc(thisd) else
           if topd<240 then begin;inc(topd);changed:=true;end;
       'I':if topd>16 then begin;dec(topd,16);changed:=true;end
            else begin;topd:=1;changed:=true;end;
       'Q':if topd<225 then begin;inc(topd,16);changed:=true;end
            else begin;topd:=240;changed:=true;end;
       'O':begin;topd:=240;changed:=true;end;
      end;
   #27:begin;done:=true;thisd:=0;topd:=1;end;
   #32,#13:done:=true;
  end;
 until done;
 talkedit(thisd+topd-1);
 selectdialogue:=thisd+topd-1;
end;

{$ENDIF}