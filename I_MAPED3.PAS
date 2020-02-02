
{  Each region gets a .An and a .Bn file.
   For room-type maps: The .An file is locpointer. (2 bytes)
                       The .Bn file is loccontents. (2+2bytes)

   For world-maps: The .Bn file is the vehicle table.
                   The .An file is a record of the 16x16 'chunks'.
}


const CELLSIZE = 512;  {size of a wmap cell, in bytes}
var 	lastgrap:byte;

{$IFNDEF MAPOVER}
var i,i1:integer;
    s:string;
    quittime:boolean;
    layobj:array[1..5] of byte;
    lastportal_r,lastportal_n:byte;


{$I I_MAPED2.PAS}
{$ENDIF}


procedure newmap(var n:byte);
 var rgf:file of regionrec;
     lpf:file; {of locpointer;}
     lcf:file   of loccontrec;
     chf:file of chunkrec;
     vhf:file of vehrec;
     fc:word;
     dr:regionrec;
     aa,bb:byte;
	 rc:rcrcarray;
begin
 region.shadow:=1;

 for fc:=1 to 15 do region.room.wallgrap[fc]:=0;
 region.room.wallgrap[16]:=1;
 for fc:=1 to 255 do
   begin;region.port[fc].used:=false;end;
 assign(rgf,ADVNAME+REGIONFILE);
 {$I-} reset(rgf); {$I+}
 if ioresult<>0 then begin;rewrite(rgf);write(rgf,region);n:=1;end;
 if n<=filesize(rgf) then seek(rgf,n-1)
  else begin
   seek(rgf,filesize(rgf)-1);
   read(rgf,dr);
   n:=filesize(rgf)+1;
  end;
 write(rgf,region);
 close(rgf);
     for fc:=1 to 64 do with rc[fc] do
      begin
        crcsource:=0;
        used:=false;
      end;
     for fc:=1 to RCMAX do with rcrc^[fc] do
      begin
        crcsource:=0;
        used:=false;
      end;	
     assign(rcrcf,ADVNAME+MAPCFILE+strnum(n));
     {$I-} rewrite(rcrcf); {$I+}
     if ioresult<>0 then exit;
     write(rcrcf,rc);
     close(rcrcf);
 if region.rooms>250 then
   begin
     for fc:=1 to 255 do
      begin
       veh[fc].obj:=0;veh[fc].objcode:=0;
       veh[fc].used:=false;
      end;
     assign(vhf,ADVNAME+MAPBFILE+strnum(n));
     {$I-} rewrite(vhf); {$I+}
     if ioresult<>0 then exit;
     write(vhf,veh);
     close(vhf);
     for aa:=1 to 16 do for bb:=1 to 16 do
      map[2,2,aa,bb].o:=0;
     assign(chf,ADVNAME+MAPAFILE+strnum(n));
     {$I-} rewrite(chf); {$I+}
     if ioresult<>0 then exit;
     for fc:=1 to region.room.cells do write(chf,map[2,2]);
     close(chf);
   end
  else begin
    locntsize:=1;
    assign(lpf,ADVNAME+MAPAFILE+strnum(n));
    assign(lcf,ADVNAME+MAPBFILE+strnum(n));
    {$I-} rewrite(lpf, 1);
    if ioresult<>0 then exit;
    rewrite(lcf);
    if ioresult<>0 then exit;
    {$I+}

   for aa:=1 to 80 do for bb:=1 to 40 do
     begin
      rmcnt^[aa,bb]:=0;
      {write(lpf,rmcnt^[aa,bb]);}
     end;
    blockwrite(lpf,rmcnt^[1],6400);
    write(lcf,locnt^[1]);
    close(lpf);close(lcf);
  end;
end;

procedure newchunk;
 var chf:file of chunkrec;
     xi,yi:byte;
begin
 if region.room.cells>254 then exit;
 assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
 reset(chf);
 seek(chf,filesize(chf)-1);
 read(chf,map[1,1]);
 for xi:=1 to 16 do for yi:=1 to 16 do map[1,1,xi,yi].o:=0;
 write(chf,map[1,1]);
 region.room.cells:=filesize(chf);
 close(chf);
end;

procedure savemap;
 var rgf:file of regionrec;
     lpf:file; { of locpointer; }
     lcf:file; { of loccontrec; }
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
  wc[i-start]:=wander_index^[i];
end;	
procedure copyrc(start:byte);
var i:byte;
begin
 for i:=start+1 to start+64 do if i<255 then
  rc[i-start]:=rcrc^[i];
end;		
	
begin

 assign(wcf,ADVNAME+MAPWFILE+strnum(thisregion));
 rewrite(wcf);

	 for fc:=(32 DIV 32)-1 to (WANDERMAX DIV 32)-1 do
	  begin
	   copywc(32 * fc);
	   write(wcf,wc);
	  end;


 close(wcf);

 assign(rgf,ADVNAME+REGIONFILE);
 {$I-} reset(rgf); {$I+}
 if ioresult<>0 then exit;
 seek(rgf,thisregion-1);
 write(rgf,region);
 close(rgf);
 assign(rcrcf,ADVNAME+MAPCFILE+strnum(thisregion));
 {$I-} rewrite(rcrcf); {$I+}
 if ioresult<>0 then exit;

	 for fc:=(64 DIV 64)-1 to ((RCMAX+2) DIV 64)-1 do
	  begin
	   copyrc(64 * fc);
	   write(rcrcf,rc);
	  end;


 close(rcrcf);
 if region.rooms>20 then
   begin
     assign(vhf,ADVNAME+MAPBFILE+strnum(thisregion));
     {$I-} reset(vhf); {$I+}
     if ioresult<>0 then exit;
     write(vhf,veh);
     close(vhf);
   end
  else begin
    assign(lpf,ADVNAME+MAPAFILE+strnum(thisregion));
    assign(lcf,ADVNAME+MAPBFILE+strnum(thisregion));
    {$I-} rewrite(lpf,1);
    if ioresult<>0 then exit;
    rewrite(lcf,1);
    if ioresult<>0 then exit;
    {$I+}
    blockwrite(lpf,rmcnt^[1],6400);
    blockwrite(lcf,locnt^[1],locntsize*sizeof(loccontrec));
    {for aa:=1 to 80 do for bb:=1 to 40 do
     write(lpf,rmcnt^[aa,bb]);}
   { fc:=0;
    while (fc<locntsize) do
     begin
      inc(fc);
      write(lcf,locnt^[fc]);
     end;
    locntsize:=fc;}
    close(lpf);close(lcf);
  end;
end;


procedure newportal(var rr,xc,yc,xx,yy:byte);
{
 Portdestrec = RECORD
  region,rx,ry,x,y:byte;  rx is used for room
  used:boolean;
  END;
}
 var oldregion:byte;
     old_xch,old_ych,old_yin,old_xin:integer;
     old_onlycell:boolean;
     oh:byte;

begin
 oh:=helpindex;helpindex:=66;
 gotolocation:=false;
 xx:=0;
 oldregion:=thisregion;
 rr:=menuselectregion(thisregion+128);
 if rr=0 then exit;
 if rr=202 then exit;
 savemap;
 if region.rooms>20 then
  begin
   savewmap;
   old_xch:=xchunkloc;old_ych:=ychunkloc;
   old_xin:=xinloc;old_yin:=yinloc;
   old_onlycell:=onlycell;
  end;
 thisregion:=rr;loadmap(rr);
 if region.rooms>20 then otherwalkworldmap(xc,yc,xx,yy)
  else if region.rooms>0 then begin;otherwalkroom(xc,xx,yy);yc:=255;end;
 thisregion:=oldregion;loadmap(oldregion);
 if region.rooms>20 then
  begin
   xchunkloc:=old_xch;ychunkloc:=old_ych;
   xinloc:=old_xin;yinloc:=old_yin;
   onlycell:=old_onlycell;
   CHUNKSAVE:=true;
  end;
{ getchunks(xchunkloc,ychunkloc); }
  helpindex:=oh;
end;


 {to run this procedure, you must preset x/ychunkloc, chunksave,onlycell}
procedure walkworldmap;
 var j,j2:char;
     coordview:boolean;
     sin,s4:string[4];
     s60:string[60];
     done:boolean;
     putgrapc:byte;
     creatureslot,creatureslott:byte;
     visimap,nowmap,clipboardmap:array[0..10,0..8] of byte;
     xsc,ysc:byte;
     layportal,vehhere:boolean;
     laycreature,vehcount,howmuch:integer;
     newportx,newporty,newportxc,newportyc,newportrg:byte;
     newportalnum,seekportalcount:byte;
     {noshow:array[0..10,0..8] of boolean;}
     llr,llr2:byte;
     paws:integer;
     w:word;
	 was_here:byte;

procedure showwalk;
 var layc:byte;
     s14:string[14];
begin
 clearscreen;
{ thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,199,319,3);
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3); }
 {write messages in the x50-80 area, or allX after 160}
 say(50,2,0,'ƒ„A-D TO CHANGE');
 say(52,10,0,'[ESC] TO EXIT');
for layc:=1 to 4 do begin
 say(50,30*layc-2,5,' '+chr(layc+64)+' ');
 if layobj[layc]<>0 then
 begin
  s14:=obj^[layobj[layc]].n;
  say(51,30*layc+15,2,s14);
 end
  else say(51,30*layc+15,1,'(NONE)');
 putgrap(58,30*layc-2,obj^[layobj[layc]].d[1]);
end;
 say(50,175,5,' W Û1: WANDERING');
 say(50,183,1,'      LIFE');
 say(50,166,5,' L Û1: LIFE');
 say(50,157,5,' F Û1: FILL');
 say(50,148,5,' E Û1: ERASE');
  boxx(1,1,48,39);
{ if region.rooms=254 then }
  boxx(8,39,41,42); {else boxx(11,39,38,42);}
end;

begin
 lastgrap:=1;
 helpindex:=64;
 coordview:=false;
 for xsc:=1 to 4 do
  if (obj^[layobj[xsc]].t>5) and (obj^[layobj[xsc]].t<>10) then
   layobj[xsc]:=0;
 showwalk;
 getchunks(xchunkloc,ychunkloc);
if onlycell then
 for xsc:=1 to 3 do for ysc:=1 to 3 do
  if (xsc*ysc<>4) then
   begin
    for xinloc:=1 to 16 do for yinloc:=1 to 16 do
     map[xsc,ysc,xinloc,yinloc].o:=0;  {make all but map[2,2] empty}
     chunk[xsc,ysc]:=0;
   end;
 xinloc:=8;yinloc:=8;
 done:=false;
repeat
 for xsc:=0 to 10 do for ysc:=0 to 8 do
   begin
    {noshow[xsc,ysc]:=false;
    if chunk[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1]<>0 then
	for i:=1 to WANDERMAX do if wander_index^[i].x=chunk[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1] then
     if wander_index^[i].xin=((xinloc+xsc+10) MOD 16)+1 then
      if wander_index^[i].yin=((yinloc+ysc+11) MOD 16)+1 then
        noshow[xsc,ysc]:=true;}

    nowmap[xsc,ysc]:=
     map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].o;
	visimap[xsc,ysc]:=nowmap[xsc,ysc];
	if nowmap[xsc,ysc]=255 then nowmap[xsc,ysc]:=0;
	if nowmap[xsc,ysc]<>0 then if (obj^[nowmap[xsc,ysc]].t<>1) and (obj^[nowmap[xsc,ysc]].t<>3)
	 then nowmap[xsc,ysc]:=0;
    if visimap[xsc,ysc]<>255 then
       visimap[xsc,ysc]:=obj^[visimap[xsc,ysc]].d[1] else
   begin
    creatureslot:=map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].d;
    if ((obj^[rcrc^[creatureslot].obj].t<3)
     and (obj^[rcrc^[creatureslot].obj].d[13]<>0))
    then visimap[xsc,ysc]:=obj^[rcrc^[creatureslot].obj].d[13]
     else visimap[xsc,ysc]:=crc^[rcrc^[creatureslot].crcsource].g1;
      {all that mess is to take care of creatures sitting on chairs, etc}



    {if rcrc^[creatureslot].show=false then noshow[xsc,ysc]:=true;}
   end;
  end;
 for xsc:=0 to 10 do for ysc:=0 to 8 do
  begin


  if visimap[xsc,ysc]>240 then
   putgrap2(xsc*4+3,ysc*16+10,map[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1,
      ((xinloc+xsc+10) MOD 16)+1, ((yinloc+ysc+11) MOD 16)+1].d)
   else putgrap(xsc*4+3,ysc*16+10,visimap[xsc,ysc]);

   {if noshow[xsc,ysc] then say(xsc*4+4,ysc*16+14,0,'W');}

  { if ( metadata AND 128 ) say(xsc*4+4,ysc*16+14,0,'I'); }
  end;
   {putgrap(xsc*4+10,ysc*16+18,visimap[xsc,ysc]);}

  if coordview then
   say(9,160,0,'['+strnum(xchunkloc)+','+strnum(ychunkloc)+'] ('+
         strnum(xinloc)+','+strnum(yinloc)+') ') else
   say(9,160,0,'('+strnum((xchunkloc-1)*16+xinloc)+','+
         strnum((ychunkloc-1)*16+yinloc)+') ');
 xorthing(23,74);xorthing(26,86);xorthing(23,86);xorthing(26,74);
 xorthing(23,78);xorthing(26,78);xorthing(24,86);xorthing(24,74);
 xorthing(23,82);xorthing(26,82);xorthing(25,86);xorthing(25,74);

 paws:=0;

while not keypressed do
begin
 if paws<10000 then inc(paws);
 if paws=8990 then
begin {what's under me?}
 {say if wanderer here}
 {if wander_index^[1].x<>0 then}
  begin
   for i:=1 to WANDERMAX do
   begin
    if wander_index^[i].x=chunk[2,2] then
    if wander_index^[i].xin=xinloc then
     if wander_index^[i].yin=yinloc then
      begin
       say(1,174,0,'W'+strnum(i)+': '+strnum(wander_index^[i].odds)+
        '% '+crc^[wander_index^[i].creature].n);
      end;
	end;
	
   for xsc:=0 to 10 do for ysc:=0 to 8 do
     if chunk[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1]<>0 then
	  for i:=1 to WANDERMAX do if wander_index^[i].x=chunk[((xinloc+xsc+10) DIV 16)+1,((yinloc+ysc+11) DIV 16)+1] then
     if wander_index^[i].xin=((xinloc+xsc+10) MOD 16)+1 then
      if wander_index^[i].yin=((yinloc+ysc+11) MOD 16)+1 then
        say(xsc*4+4,ysc*16+14,0,'W');
	
	

  end;
 llr:=map[2,2,xinloc,yinloc].o; llr2:=map[2,2,xinloc,yinloc].d;
 if llr=255 then
  begin
   say(4,183,0,crc^[rcrc^[llr2].crcsource].n);
   say(8,191,0,dialogue_title(rcrc^[llr2].talk));
  end
 else
 if llr>1 then say(4,183,0,objnam(llr))
  else if llr=1 then say(4,183,0,objnam(llr)+' ('+
     strnum(veh[llr2].howmany*10)+')  ');
   if (llr<>0) and (llr<>255) then
   begin
    if (obj^[llr].t=2) or (obj^[llr].t=4) then
     say(4,191,2,straction(obj^[llr].d[2])+' '+
      stractionp(obj^[llr].d[2],llr2,false));
    if (obj^[llr].t=5) then
     with region.port[llr2] do
      if ry>32 then
        say(2,191,1,'PORTAL '+strnum(llr2)+' TO '+
        strnum(region)+' '+strnum(rx)+' '+strnum(x) +' '+  strnum(y))
      else say(2,191,1,'PORTAL '+strnum(llr2)+' TO '+
        strnum(region)+' 0 '+strnum((rx-1)*16 +x) +' '+  strnum((ry-1)*16 + y));

   end;
end;
end;
 {clear_keyboard_buffer;}
 j:=upcase_sync(readkey);
 {if j<>#0 then say(1,1,0,j) else say(1,1,0,' ');}
 if save_the_maps then
  begin; savewmap; savemap; save_the_maps:=false; end;

 if paws>=8990 then blankbox(1,174,198,199);

 case j of
  #0: case readkey of
   #59:help;
  'H':if yinloc>1 then dec(yinloc) else chunkmove(NORTH);
  'K':if xinloc>1 then dec(xinloc) else chunkmove(WEST);
  'M':if xinloc<16 then inc(xinloc) else chunkmove(EAST);
  'P':if yinloc<16 then inc(yinloc) else chunkmove(SOUTH);
  #30:begin;layobj[1]:=selectobj(111,map[2,2,xinloc,yinloc].o,layobj[1]);showwalk;end;
  #48:begin;layobj[2]:=selectobj(111,map[2,2,xinloc,yinloc].o,layobj[2]);showwalk;end;
  #46:begin;layobj[3]:=selectobj(111,map[2,2,xinloc,yinloc].o,layobj[3]);showwalk;end;
  #32:begin;layobj[4]:=selectobj(111,map[2,2,xinloc,yinloc].o,layobj[4]);showwalk;end;
 (* #24:begin {alt-O}
       {shell to object editor}
       s4:='07';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='O';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showwalk;
      end;
  #25:begin {alt-P}
       {shell to people editor}
       s4:='10';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='P';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showwalk;
      end;
  #34:begin {alt-G}
       {shell to people editor}
       s4:='05';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='G';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showwalk;
      end; *)
  #33:begin
      CHUNKSAVE:=true;
      say(1,185,0,'FLUSH VIEW WITH WHAT? [A-E,ESC]');
      j2:=upcase_sync(readkey);
      say(1,185,0,'                               ');
      if (j2>='A') and (j2<='E') then
       begin
        for xsc:=(15+xinloc)-5 to (15+xinloc)+5 do
         for ysc:=(15+yinloc)-4 to (15+yinloc)+4 do
          if chunk[xsc DIV 16+1,ysc DIV 16+1]<>0 then
           if map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o<>255
            then
             if (obj^[map[xsc DIV 16+1,ysc DIV 16+1,
              xsc MOD 16+1,ysc MOD 16+1].o].t<6) or
               (map[xsc DIV 16+1,ysc DIV 16+1,
                xsc MOD 16+1,ysc MOD 16+1].o=0) then
          begin
           if j2='E' then map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o:=0
		   else map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o:=
            layobj[ord(j2)-64];
           map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].d:=0;
          end;
       end;
     end;
  #47:begin {alt-V} {3,10}
       for i:=10 to 154 do fillchar(mem[$a000:scrnh[i]+12],176,0);
       for xsc:=0 to 47 do for ysc:=0 to 47 do
        begin
         putpixel(xsc+30,ysc+30,mapcolors[map[xsc DIV 16+1,ysc DIV 16+1,
          xsc MOD 16+1,ysc MOD 16+1].o]);
        end;
       repeat until readkey<>#0;
       showwalk;
      end;
  end;
 #8:begin
      coordview:=not coordview;
      say(9,160,0,'               ');
     end;
 'W':if creatureok then begin
      i1:=0;
      for i:=1 to WANDERMAX do
       if (wander_index^[i].x=chunk[2,2]) and (wander_index^[i].xin=xinloc)
        and (wander_index^[i].yin=yinloc) then
          begin
           {remove wanderer}
           wander_index^[i].x:=0;
           i1:=1;
          end;
     if i1=0 then
      begin
      {create wanderer}
      for i:=WANDERMAX downto 1 do
       if wander_index^[i].x=0 then i1:=i;
      if i1=0 then
       begin
        {no empty slots}
       end else
       begin
        i:=i1;
        {wandering creature at position i1}
        laycreature:=selectcreature(0);
        wander_index^[i].creatureparam:=0;
        wander_index^[i].creature:=laycreature;
        wander_index^[i].x:=chunk[2,2];
        wander_index^[i].y:=0;
        wander_index^[i].xin:=xinloc;
        wander_index^[i].yin:=yinloc;
        {pick odds}
        blankbox(70,80,290,120);
        drawh(70,80,290,15);
        drawh(70,120,290,15);
        drawv(70,80,120,15);
        drawv(290,80,120,15);
        say(19,90,0,'ENTER ODDS OF APPEARING:');
        say(19,100,0,'(1%-100%)');
        say(59,100,0,'%');
        s4:=readlin(49,100,3,1);
        val(s4,w,i1);
        if w>100 then w:=100;
        if w<1 then w:=1;
        wander_index^[i].odds:=w;
       end;
      end; {create wanderer}
       showwalk;
     end;
 'L':if creatureok then begin
      creatureslot:=0;creatureslott:=0;
      repeat
       inc(creatureslot);
       if creatureslot>RCMAX then creatureslott:=255
        else if rcrc^[creatureslot].used=false then
         creatureslott:=creatureslot;
      until creatureslott<>0;
      if creatureslott<>255 then
      with rcrc^[creatureslott] do begin
       laycreature:=selectcreature(0);
       if laycreature<>0 then
        begin
         rcrc^[creatureslott].xchunk:=xchunkloc;
         rcrc^[creatureslott].ychunk:=ychunkloc;
         used:=true;show:=true;
         obj:=map[2,2,xinloc,yinloc].o;
         objdata:=map[2,2,xinloc,yinloc].d;
         crcsource:=laycreature;
         hp:=crc^[laycreature].hm;
         mp:=crc^[laycreature].mm;
         recurring:=false;odds:=100;
(*
         say(3,190,0,'PERMANENT? (Û5YÛ0ES/Û5NÛ0O)');
         repeat
          j2:=upcase_sync(readkey);
          if j2=#0 then if readkey=#59 then help;
         until (j2='Y') or (j2='N') or (j2=#13);
         if upcase_sync(readkey)='Y' then recurring:=true;
         say(3,190,0,'WANDERING? (Û51Û00%-Û59Û00%/Û5NÛ0O)  ');
         repeat
          j2:=upcase_sync(readkey);
         until ((ord(j2)>48) and (ord(j2)<58)) or (j2='N') or (j2=#13);
         if (ord(j2)>48) and (ord(j2)<58) then odds:=(ord(j2)-48)*10;
*)
         say(3,190,0,'MOTIVE? (Û5SÛ0TOP/Û5MÛ0OVE/Û5WÛ0AIT)  ');
         repeat
          j2:=upcase_sync(readkey);
          if j2=#0 then if readkey=#59 then help;
         until (j2='S') or (j2='W') or (j2='M') or (j2=#13);
         case j2 of
          'S':motive:=2;
          'W':motive:=1;
          else motive:=0;
          end;
          anger:=0;
          if crc^[laycreature].t=2 then anger:=1;
          if crc^[laycreature].t=4 then anger:=6;
          if crc^[laycreature].t=1 then anger:=2;
         talk:=0;
         say(3,190,0,'DIALOGUE? [Y/N]          ');
         repeat
          case upcase_sync(readkey) of
           #0:if readkey=#59 then help;
           'Y':talk:=1;
           'N':talk:=2;
          end;
         until talk<>0;
          if talk=1 then
           begin
            say(3,190,0,'SELECT DIALOGUE...');
            talk:=selectdialogue;
           end else talk:=0;
         map[2,2,xinloc,yinloc].d:=creatureslott;
         map[2,2,xinloc,yinloc].o:=255;
        end;
       showwalk;
      end else
       say(3,190,0,'NO ROOM TO ADD CREATURE IN LIST.');
     end else say(3,190,0,'NO CREATURE FILE FOUND.');
 '?':begin
      say(1,182,0,'OBJ:'+strnum(map[2,2,xinloc,yinloc].o)+
          ' OBJD:'+strnum(map[2,2,xinloc,yinloc].d)+
          ' XIN:'+strnum(xinloc)+' YIN:'+strnum(yinloc)+
          ' XCH:'+strnum(xchunkloc)+' YCH:'+strnum(ychunkloc));
      repeat until readkey<>#0;
     end;
 'F':begin
      CHUNKSAVE:=true;
      say(1,185,0,'FILL HERE WITH WHAT? [A-D,ESC]');
      j2:=upcase_sync(readkey);
      say(1,185,0,'                              ');
	  was_here:=map[2,2,xinloc,yinloc].o;
      if (j2>='A') and (j2<='D') then
       begin
        for xsc:=(15+xinloc)-5 to (15+xinloc)+5 do
         for ysc:=(15+yinloc)-4 to (15+yinloc)+4 do
          if chunk[xsc DIV 16+1,ysc DIV 16+1]<>0 then
           if map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o<>255
            then
             if (obj^[map[xsc DIV 16+1,ysc DIV 16+1,
              xsc MOD 16+1,ysc MOD 16+1].o].t<6) or
               (map[xsc DIV 16+1,ysc DIV 16+1,
                xsc MOD 16+1,ysc MOD 16+1].o=0) then
          if map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o =
		    was_here then
		  begin
           map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].o:=
            layobj[ord(j2)-64];
           map[xsc DIV 16+1,ysc DIV 16+1,xsc MOD 16+1,ysc MOD 16+1].d:=0;
          end;
       end;
     end;
 'A'..'D':if map[xsc DIV 16+1,ysc DIV 16+1,
              xsc MOD 16+1,ysc MOD 16+1].o<>255 then
     if ((xchunkloc>=1) and (xchunkloc<=32) and
      (ychunkloc>=1) and (ychunkloc<=32))
    then if region.room.wmap[xchunkloc,ychunkloc]<>0 then
   if layobj[ord(j)-64]<>0 then
    if obj^[layobj[ord(j)-64]].t>5 then
     begin
      vehhere:=false; {set to true, to prevent stacking.}
      if map[2,2,xinloc,yinloc].o=0 then vehhere:=false;
      if vehhere then
        if obj^[map[2,2,xinloc,yinloc].o].t<6 then vehhere:=false;
      if not vehhere then
       begin
        vehcount:=1;
        repeat
         if veh[vehcount].used then inc(vehcount) else inc(vehcount,1000);
        until vehcount>255;
        if vehcount<300 then
         begin;say(1,182,0,'TOO MANY ITEMS');delay(500);
               say(1,182,0,'              ');end;
        if vehcount>300 then
         begin
          dec(vehcount,1000);
          if layobj[ord(j)-64]<>1 then veh[vehcount].howmany:=1 else
           begin
            {find out how much money}
            say(3,185,0,'HOW MUCH?       ');
            sin:=readlin(23,185,4,1);
            val(sin,howmuch,laycreature);
            if (sin='') or (laycreature<>0) then howmuch:=random(50)+50;
            if howmuch>2550 then howmuch:=2550;
            veh[vehcount].howmany:=howmuch DIV 10;
            say(23,185,0,strnum(veh[vehcount].howmany * 10)+'   ');
           end;
          veh[vehcount].used:=true;
          veh[vehcount].obj:=map[2,2,xinloc,yinloc].o;
          veh[vehcount].objcode:=map[2,2,xinloc,yinloc].d;
          veh[vehcount].xchunk:=xchunkloc;
          veh[vehcount].ychunk:=ychunkloc;
          map[2,2,xinloc,yinloc].o:=layobj[ord(j)-64];
          map[2,2,xinloc,yinloc].d:=vehcount;
         end;
       end;
     end else
    begin
      vehhere:=true;
      if map[2,2,xinloc,yinloc].o=0 then vehhere:=false;
      if vehhere then
        if obj^[map[2,2,xinloc,yinloc].o].t<6 then vehhere:=false;

    if not vehhere then
    begin
     layportal:=false;newportx:=0;newportalnum:=0;
      if obj^[layobj[ord(j)-64]].t=5 then
       begin
        seekportalcount:=0;
        repeat
         inc(seekportalcount);
         if region.port[seekportalcount].used = false then
           newportalnum:=seekportalcount;
        until (newportalnum<>0) OR (seekportalcount>=255);
       end;
      if newportalnum<>0 then begin
        savewmap;
        say(1,185,0,'SELECT THE DESTINATION FOR THE PORTAL.');
        layportal:=true;
        newportal(newportrg,newportxc,newportyc,newportx,newporty);
        if newportrg=202 then layportal:=false;
        getchunks(xchunkloc,ychunkloc);
        showwalk;
       end;
     if (layportal) AND (newportx<>0) then
      with region.port[newportalnum] do begin
       used:=true;region:=newportrg;rx:=newportxc;ry:=newportyc;
       x:=newportx;y:=newporty;
       map[2,2,xinloc,yinloc].d:=newportalnum;
       lastportal_n:=newportalnum;
       lastportal_r:=thisregion;
      end;
     if newportrg=202 then if thisregion=lastportal_r then
      begin
       newportalnum:=lastportal_n;
       map[2,2,xinloc,yinloc].d:=newportalnum;
       layportal:=true;newportx:=1;
      end;

     if (layportal) XOR (newportx=0) then
      map[2,2,xinloc,yinloc].o:=layobj[ord(j)-64];
     if layobj[ord(j)-64]<>0 then
      if (obj^[layobj[ord(j)-64]].t=2) or (obj^[layobj[ord(j)-64]].t=4)
       then begin
        map[2,2,xinloc,yinloc].d:=0;
        say(1,174,0,straction(obj^[layobj[ord(j)-64]].d[2])+':');
        editactionp(obj^[layobj[ord(j)-64]].d[2],
         length(straction(obj^[layobj[ord(j)-64]].d[2]))*2+3,174,
           map[2,2,xinloc,yinloc].d);
        showwalk;
       end;
	 if layobj[ord(j)-64]<>0 then if (obj^[layobj[ord(j)-64]].t<5)
	  then if obj^[layobj[ord(j)-64]].d[1]>240 then
	   begin
	    loadgraps2(false);
	    map[2,2,xinloc,yinloc].d:=grap_select_window(lastgrap);
		lastgrap:=map[2,2,xinloc,yinloc].d;
		loadgraps;
		showwalk;
	   end;	
    end;
   end;
  'E':if map[2,2,xinloc,yinloc].o<>0 then
       if map[2,2,xinloc,yinloc].o=255 then
        begin
         rcrc^[map[2,2,xinloc,yinloc].d].used:=false;
         map[2,2,xinloc,yinloc].o:=rcrc^[map[2,2,xinloc,yinloc].d].obj;
         map[2,2,xinloc,yinloc].d:=rcrc^[map[2,2,xinloc,yinloc].d].objdata;
        end else
       begin
        if obj^[map[2,2,xinloc,yinloc].o].t>5 then
         begin
          vehcount:=map[2,2,xinloc,yinloc].d;
          map[2,2,xinloc,yinloc].o:=veh[vehcount].obj;
          map[2,2,xinloc,yinloc].d:=veh[vehcount].objcode;
          veh[vehcount].used:=false;
         end
          else
         begin
          if obj^[map[2,2,xinloc,yinloc].o].t=5 then
           region.port[map[2,2,xinloc,yinloc].d].used:=false;
          map[2,2,xinloc,yinloc].o:=0;
         end;
       end;
 #27:done:=true;
 end;
until done;
 if CHUNKSAVE then savewmap;
end;



procedure addregion(mapnum:byte);
 var wide,tall:integer;
      li:longint;
      done:boolean;
      oh:byte;
begin
 done:=false;
repeat
 clearscreen;
 say(1,2,6,' ADD REGION      ');
 say(2,30,5,' R Û0: ROOM-TYPE');
 say(2,42,5,' W Û0: WORLDMAP-TYPE');
 say(2,54,5,' C Û0: CUSTOM WORLDMAP');
 say(2,66,5,'ESCÛ0: ABORT');
 case upcase_sync(readkey) of
  #0:if readkey=#59 then help;
  #27:done:=true;
  'R':begin
       oh:=helpindex;helpindex:=59;
       clearscreen;
       say(1,2,6,' STANDARD ROOM-MAP ');
       say(3,20,1,'THIS IS THE EASIEST MAP TYPE,');
       say(3,30,1,'ALLOWING STACKING OF ALL OBJECTS,');
       say(3,40,1,'AND EASY PREVIEWING.');
       say(3,55,0,'CREATE MAP? [Y/N]');
           repeat
            s:=upcase_sync(readkey);
            if s=#0 then if readkey=#59 then help;
           until (s='Y') or (s='N') or (s=#27);
           if s='Y' then
            begin
             with region do begin
              rooms:=0;
              name:='NEW ROOMS';
              for i:=1 to 255 do
               begin
                port[i].region:=0;
               end;
             end;
           newmap(mapnum);
           done:=true;
           end;
        helpindex:=oh;
      end;
  'W':begin
       helpindex:=58;
       clearscreen;
       say(1,2,6,' STANDARD WORLDMAP ');
       say(3,30,1,'THIS IS THE STANDARD RECTANGULAR');
       say(3,40,1,'SCROLLING MAP.');
       say(3,50,1,'ENTER DIMENSIONS IN MULTIPLES OF 16.');
       say(3,75,0,'MAP WIDTH:');
       s:=readlin(24,75,3,1);
       val(s,i,i1);
       say(24,75,0,s+'    ');
       if (i1=0) and (s<>'') and (s<>#27) then
        wide:=(i+8) DIV 16 else wide:=0;
       say(3,85,0,'MAP HEIGHT:');
       s:=readlin(26,85,3,1);
       say(26,85,0,s+'    ');
       val(s,i,i1);
       if (i1=0) and (s<>'') and (s<>#27) then
        tall:=(i+8) DIV 16 else tall:=0;
       i:=wide*tall;
       if (i>256) or ((i=256) and ((wide<>16) or (tall<>16))) then
         begin
           say(4,100,2,'THIS MAP IS TOO LARGE FOR A STANDARD');
           say(4,110,2,'ACK WORLD MAP.  TRY A SMALLER MAP, OR');
           say(4,120,2,'A CUSTOM-WORLDMAP.');
           say(4,130,0,'PRESS A KEY.');
           if readkey=#0 then if readkey=#59 then help;
         end else
        if i<>0 then
          begin
           if (wide<3) or (tall<3) then
            begin
             say(1,100,2,'NOTE: WRAP-AROUND MAP EDGES');
             say(1,110,2,'ACT STRANGE WITH MAPS SMALLER');
             say(1,120,2,'THAN 48 X 48.  YOU MAY WISH');
             say(1,130,2,'TO CHANGE THE "MAP EDGE" SETTING.');
            end;
            if i=256 then
             begin
              say(1,100,2,'THIS MAP CAN BE CREATED AT');
              say(1,110,2,'256 X 256, BUT WILL HAVE A');
              say(1,120,2,'16 X 16 EMPTY NOTCH IN THE');
              say(1,130,2,'NORTHWEST CORNER.');
             end;
           li:=i;
           str((li*CELLSIZE) DIV 1024,s);
           if s='0' then s:='1/2';
{           say(4,150,0,'THIS MAP WILL BE PRESET WITH');
           say(4,160,0,strnum(i)+' CELLS.'); }
           say(4,180,0,'CREATE MAP? [Y/N]');
           repeat
            s:=upcase_sync(readkey);
            if s=#0 then if readkey=#59 then help;
           until (s='Y') or (s='N') or (s=#27);
           if s='Y' then
            begin
             with region do begin
              rooms:=255;
              if wide*tall=256 then room.cells:=255 else room.cells:=wide*tall;
              for i:=1 to 32 do for i1:=1 to 32 do
               room.wmap[i,i1]:=0;
              for i:=1 to wide do for i1:=1 to tall do
               if (i+(i1-1)*wide)<256 then
                room.wmap[(wide-i)+1,(tall-i1)+1]:=i+(i1-1)*wide;
              name:='NEW WORLDMAP';
              for i:=1 to 255 do
               begin
                port[i].region:=0;
               end;
             end;
           newmap(mapnum);
           done:=true;
          end;
         end;
        helpindex:=9;
      end;
  'C':begin
        helpindex:=60;
        clearscreen;
        say(1,2,6,' CUSTOM WORLDMAP ');
        say(3,20,1,'PRESS Û5F1Û1 FOR HELP.');
        say(3,40,0,'CREATE MAP? [Y/N]');
           repeat
            s:=upcase_sync(readkey);
            if s=#0 then if readkey=#59 then help;
           until (s='Y') or (s='N') or (s=#27);
           if s='Y' then
           begin
             with region do begin
              rooms:=254;
              room.cells:=1;
              for i:=1 to 32 do for i1:=1 to 32 do
               room.wmap[i,i1]:=0;
              room.wmap[1,1]:=1;
              name:='NEW WORLDMAP';
              for i:=1 to 255 do
               begin
                port[i].region:=0;
               end;
             end;
           newmap(mapnum);
           done:=true;
          end;
        helpindex:=9;
      end;
 end;
 until done;
end;


procedure previewcells(topx,topy:byte);
 var xco,yco:byte;
begin
 for xco:=0 to 7 do for yco:=0 to 7 do
  begin
   s:=strnum(region.room.wmap[xco+topx,yco+topy]);
   if s='0' then s:=' . ' else
   if length(s)=1 then s:=' '+s+' '
    else if length(s)=2 then s:=' '+s;
   say(xco*8+10,yco*16+10,0,s);
  end;
  putthing(1+round(56*((topx-1)/23)+10),1,3);
  putthing(6,round(106*((topy-1)/23)+16),3);
end;
procedure cwmap_scrollbars;
 var cou:byte;
begin
for cou:=0 to 28 do
 putthing(6,15+4*cou,2);
for cou:=1 to 59 do
 putthing(10+cou,1,2);
end;

procedure editroom(n:byte);
 var j,j2:char;
     paws:integer;
     oh:byte;
     laycreature,creatureslott,creatureslot:byte;
     dri,dri1:integer;
     layportal,done:boolean;
     looklevel,xorx,xory:integer;
     xloc,yloc:byte;
     s4:string[4];
     s60:string[60];
     llcmax,llc,llr,llr2:byte;
     llp,llpprev,addslot,addslotc:locpointer;
     s_bar:array[1..3] of byte;  {scroll bar for looklevel}
     newportx,newporty,newportxc,newportyc,newportrg:byte;
     newportalnum,seekportalcount:byte;
     w:word;

procedure maponly;
var x,y:byte;
begin
 for x:=1 to roomwide do for y:=1 to roomtall do
 begin
  if map[2,2,x,y].o<>255 then
   begin
    if obj^[map[2,2,x,y].o].d[1]<=240 then
    putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     obj^[map[2,2,x,y].o].d[1])
	else
	 begin
	  loadgraps2(false);
	  putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
       map[2,2,x,y].d);
	  loadgraps;
	 end;
   end	
  else
   begin
    putgrap(x*4-3 +(32-(roomwide*2)) ,y*16-14 +(88-(roomtall*8)),
     crc^[rcrc^[map[2,2,x,y].d].crcsource].g1);
    if rcrc^[map[2,2,x,y].d].show=false then
     say(x*4-2 +(32-(roomwide*2)) ,y*16-10 +(88-(roomtall*8)),0,'?');
   end;
  end;
 if roomtall<>11 then
  say(3,2,5,' N Û0: '+region.room.name[n]);
  for i:=1 to WANDERMAX do
   if (wander_index^[i].x=n)
     then
      say(wander_index^[i].xin*4-2 +(32-(roomwide*2)) ,wander_index^[i].yin*16-10 +(88-(roomtall*8)),0,'W');

end;

procedure erset;  {show stuff after showroom; }
 var layc:byte;
begin
for layc:=1 to 4 do begin
 say(66,32*layc-20,5,' '+chr(layc+64)+' ');
 if layobj[layc]<>0 then
  begin
   putgrap(68,32*layc-10,obj^[layobj[layc]].d[1]);
   say(73,32*layc-6,0,strnum(layobj[layc]));
  end
   else say(66,32*layc-10,1,'(NONE)');
end;

 say(66,140,5,'EÛ1RASE');
 say(66,150,5,'LÛ1IFE');
 say(66,160,5,'WÛ1ANDER');
 say(66,168,1,' LIFE');
end;

begin
 paws:=0;
 helpindex:=65;
 if n=0 then exit;
 looklevel:=1;
 getroom(n);
 showroom(n);xloc:=roomwide DIV 2;yloc:=roomtall DIV 2;done:=false;
 erset;
repeat
 xorx:=xloc*4-3+(32-(roomwide*2));
 xory:=yloc*16-14+(88-(roomtall*8));
    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory);xorthing(xorx,xory+4);xorthing(xorx+3,xory+4);
    xorthing(xorx+1,xory+12);xorthing(xorx+1,xory);xorthing(xorx,xory+8);
    xorthing(xorx+3,xory+8);xorthing(xorx+2,xory+12);xorthing(xorx+2,xory);
    s_bar[1]:=1;s_bar[2]:=1;s_bar[3]:=1;
 if roomloc(n,xloc,yloc)=0 then begin;llr:=0;llp:=0;end
 else
 begin   {DIG}
  llp:=roomloc(n,xloc,yloc);llpprev:=0;
  llcmax:=looklevel;
  for llc:=2 to llcmax do
   if locnt^[llp].p<>0 then begin;llpprev:=llp;llp:=locnt^[llp].p;end
    else if looklevel=llcmax then looklevel:=llc-2;
  if looklevel>100 then looklevel:=100;
  if looklevel<1 then looklevel:=1;
  llr:=locnt^[llp].obj;
  llr2:=locnt^[llp].objcode;
  if looklevel=1 then s_bar[1]:=3;
  if locnt^[llp].p=0 then s_bar[3]:=3 else if looklevel<>1 then s_bar[2]:=3;
  if (s_bar[1]=3) and (s_bar[3]=3) then s_bar[2]:=3;
 end;
 say(67,1,0,'     ');
 say(67,1,0,strnum(xloc)+','+strnum(yloc));

 repeat
 if paws<10000 then inc(paws);
 if paws=9990 then
 begin
    if llr=255 then   { ROOM EDITOR &&& }
     begin
      say(4,183,0,crc^[rcrc^[llr2].crcsource].n);
      say(8,191,0,dialogue_title(rcrc^[llr2].talk));
     end else
    if llr>1 then say(4,183,0,objnam(llr))
     else if llr=1 then say(4,183,0,objnam(llr)+' ('+strnum(llr2*10)+')  ');
    if s_bar[1]+s_bar[2]+s_bar[3]=5 then
      begin;if s_bar[1]=1 then say(66,181,5,'PgUp');
            if s_bar[3]=1 then say(66,190,5,'PgDn');end;
    if (llr<>0) and (llr<>255) then
     if (obj^[llr].t=2) or (obj^[llr].t=4) then
      say(4,191,2,straction(obj^[llr].d[2])+' '+
           stractionp(obj^[llr].d[2],llr2,false)) else
      if (obj^[llr].t=5) then
       begin


     with region.port[llr2] do
      if ry>32 then
        say(2,191,1,'PORTAL '+strnum(llr2)+' TO '+
        strnum(region)+' '+strnum(rx)+' '+strnum(x) +' '+  strnum(y))
      else say(2,191,1,'PORTAL '+strnum(llr2)+' TO '+
        strnum(region)+' 0 '+strnum((rx-1)*16 +x) +' '+  strnum((ry-1)*16 + y));


       end;

   for i:=1 to WANDERMAX do if wander_index^[i].x=n then
    if wander_index^[i].xin=xloc then
     if wander_index^[i].yin=yloc then
      begin
       say(48,183,0,'WANDER: '+strnum(wander_index^[i].odds)+'%');
       say(48,191,1,crc^[wander_index^[i].creature].n);
      end;


    putthing(2,185,s_bar[1]);
    putthing(2,189,s_bar[2]);
    putthing(2,193,s_bar[3]);
  end;
 until keypressed;
 j:=upcase_sync(readkey);

  if save_the_maps then
  begin; savemap; save_the_maps:=false; end;

 if paws>=9990 then blankbox(3,183,316,200);
 paws:=0;
    xorthing(xorx,xory);xorthing(xorx+3,xory+12);xorthing(xorx,xory+12);
    xorthing(xorx+3,xory);xorthing(xorx,xory+4);xorthing(xorx+3,xory+4);
    xorthing(xorx+1,xory+12);xorthing(xorx+1,xory);xorthing(xorx,xory+8);
    xorthing(xorx+3,xory+8);xorthing(xorx+2,xory+12);xorthing(xorx+2,xory);
 case j of
  #0: case readkey of
  #59:help;
  'H':if yloc>1 then dec(yloc);
  'K':if xloc>1 then dec(xloc);
  'M':if xloc<roomwide then inc(xloc);
  'P':if yloc<roomtall then inc(yloc);
  'I':begin;if looklevel>1 then dec(looklevel);paws:=9989;end;
  'Q':begin;inc(looklevel);paws:=9989;end;
  #30:begin;layobj[1]:=selectobj(111,llr,layobj[1]);showroom(n);erset;looklevel:=1;end;
  #48:begin;layobj[2]:=selectobj(111,llr,layobj[2]);showroom(n);erset;looklevel:=1;end;
  #46:begin;layobj[3]:=selectobj(111,llr,layobj[3]);showroom(n);erset;looklevel:=1;end;
  #32:begin;layobj[4]:=selectobj(111,llr,layobj[4]);showroom(n);erset;looklevel:=1;end;
  #24:begin {alt-O}
       {shell to object editor}
       s4:='07';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='O';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showroom(n);
       erset;
      end;
  #25:begin {alt-P}
       {shell to people editor}
       s4:='10';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='P';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showroom(n);
       erset;
      end;
  #34:begin {alt-G}
       {shell to people editor}
       s4:='05';
       s60:='';
       for i:=1 to paramcount do
       begin
        s60:=s60+paramstr(i);
        if i<paramcount then s60:=s60+' ';
       end;
       s60[1]:='G';
       exec(bgi_dir+'ACK'+s4+'.EXE',s60);
       showroom(n);
       erset;
      end;

  end;
 'L':if creatureok then begin
    addslot:=0;
    if locntsize>5000 then
     begin
      {search for empty slot}
      for addslotc:=1 to locntsize do
       if locnt^[addslotc].obj=0 then addslot:=addslotc;
     end;
     if addslot=0 then if locntsize<LOCNTMAX then
       begin;addslot:=locntsize+1;inc(locntsize);end;
     if addslot<>0 then
     begin
      say(1,182,0,BLANK);
      say(1,190,0,BLANK);
      creatureslot:=0;creatureslott:=0;
      repeat
       inc(creatureslot);
       if creatureslot>RCMAX then creatureslott:=255
        else if rcrc^[creatureslot].used=false then
         creatureslott:=creatureslot;
      until creatureslott<>0;
      if creatureslott<>255 then
      with rcrc^[creatureslott] do begin
       laycreature:=selectcreature(0);
       if laycreature<>0 then
        begin
         rcrc^[creatureslott].xchunk:=0;
         rcrc^[creatureslott].ychunk:=0;
         used:=true;show:=true;
         obj:=0;
         objdata:=0;
         crcsource:=laycreature;
         hp:=crc^[laycreature].hm;
         {mp:=crc^[laycreature].mm;}
         recurring:=false;odds:=100;
(*
         say(3,190,0,'PERMANENT? (Û5YÛ0ES/Û5NÛ0O)');
         repeat
          j2:=upcase_sync(readkey);
         until (j2='Y') or (j2='N') or (j2=#13);
         if upcase_sync(readkey)='Y' then recurring:=true;
         say(3,190,0,'WANDERING? (Û51Û00%-Û59Û00%/Û5NÛ0O)  ');
         repeat
          j2:=upcase_sync(readkey);
         until ((ord(j2)>48) and (ord(j2)<58)) or (j2='N') or (j2=#13);
         if (ord(j2)>48) and (ord(j2)<58) then odds:=(ord(j2)-48)*10;
*)
         say(3,190,0,'MOTIVE? (Û5SÛ0TOP/Û5MÛ0OVE/Û5WÛ0AIT)  ');
         repeat
          j2:=upcase_sync(readkey);
          if j2=#0 then if readkey=#59 then help;
         until (j2='S') or (j2='W') or (j2='M') or (j2=#13);
         case j2 of
          'S':motive:=2;
          'W':motive:=1;
          else motive:=0;
          end;
          anger:=0;
          if crc^[laycreature].t=2 then anger:=1;
          if crc^[laycreature].t=4 then anger:=6;
          if crc^[laycreature].t=1 then anger:=2;
         talk:=0;
         say(3,190,0,'DIALOGUE? [Y/N]          ');
         repeat
          case upcase_sync(readkey) of
           #0:if readkey=#59 then help;
           'Y':talk:=1;
           'N':talk:=2;
          end;
         until talk<>0;
          if talk=1 then
           begin
            say(3,190,0,'SELECT DIALOGUE...');
            talk:=selectdialogue;
           end else talk:=0;
         locnt^[addslot].p:=
           rmcnt^[xloc+region.room.x1[n]-1,yloc+region.room.y1[n]-1];
         rmcnt^[xloc+region.room.x1[n]-1,yloc+region.room.y1[n]-1]:=addslot;
         locnt^[addslot].obj:=255;
         locnt^[addslot].objcode:=creatureslott;
        end;
       getroom(n);
       showroom(n);
       erset;
      end else
       begin
        say(3,190,0,'NO ROOM LEFT IN CREATURE LIST.');
        delay(1000);
        say(1,190,0,BLANK);
       end;
     end else
      begin
       say(3,190,0,'NO ROOM LEFT IN MAP FILE.');
       delay(1000);
       say(1,190,0,BLANK);
      end;end else
      begin
       say(3,190,0,'NO CREATURE FILE FOUND.');
       delay(1000);
       say(1,190,0,BLANK);
      end;
 'N':if roomtall<>11 then
     begin
      region.room.name[n]:=readlin(13,2,20,0);
      say(13,2,0,'                     ');
      say(13,2,0,region.room.name[n]);
      if region.room.name[n]=#27 then region.room.name[n]:=' ';
     end;
 'W':if creatureok then begin
      i1:=0;
      for i:=1 to WANDERMAX do
       if (wander_index^[i].x=n) and (wander_index^[i].xin=xloc)
        and (wander_index^[i].yin=yloc) then
          begin
           {remove wanderer}
           wander_index^[i].x:=0;
           i1:=1;
          end;
     if i1=0 then
      begin
      {create wanderer}
      for i:=WANDERMAX downto 1 do
       if wander_index^[i].x=0 then i1:=i;
      if i1=0 then
       begin
        {no empty slots}
       end else
       begin
        i:=i1;
        {wandering creature at position i1}
        laycreature:=selectcreature(0);
        wander_index^[i].creatureparam:=0;
        wander_index^[i].creature:=laycreature;
        wander_index^[i].x:=n;
        wander_index^[i].y:=0;
        wander_index^[i].xin:=xloc;
        wander_index^[i].yin:=yloc;
        {pick odds}
        blankbox(70,80,290,120);
        drawh(70,80,290,15);
        drawh(70,120,290,15);
        drawv(70,80,120,15);
        drawv(290,80,120,15);
        say(19,90,0,'ENTER ODDS OF APPEARING:');
        say(19,100,0,'(1%-100%)');
        say(59,100,0,'%');
        s4:=readlin(49,100,3,1);
        val(s4,w,i1);
        if w>100 then w:=100;
        if w<1 then w:=1;
        wander_index^[i].odds:=w;
       end;
      end; {create wanderer}
       showroom(n);erset;
     end;



 'A'..'D':if layobj[ord(j)-64]<>0 then begin


    addslot:=0;
    if locntsize>5000 then
     begin
      {search for empty slot}
      for addslotc:=1 to locntsize do
       if locnt^[addslotc].obj=0 then addslot:=addslotc;
     end;
     if addslot=0 then if locntsize<(LOCNTMAX-1) then
       begin;addslot:=locntsize+1;inc(locntsize);end;
     if addslot<>0 then
     begin
      layportal:=false;newportx:=0;newportalnum:=0;
   if obj^[layobj[ord(j)-64]].t=5 then
       begin
        seekportalcount:=0;
        repeat
         inc(seekportalcount);
         if region.port[seekportalcount].used = false then
           newportalnum:=seekportalcount;
        until (newportalnum<>0) OR (seekportalcount>=255);
       end;
      if newportalnum<>0 then begin
        say(1,185,0,'SELECT THE DESTINATION FOR THE PORTAL.');
        layportal:=true;
        newportal(newportrg,newportxc,newportyc,newportx,newporty);
        if newportrg=202 then layportal:=false;
        getroom(n);showroom(n);erset;
       end;
     if (layportal) AND (newportx<>0) then
      with region.port[newportalnum] do begin
       used:=true;region:=newportrg;rx:=newportxc;ry:=newportyc;
       x:=newportx;y:=newporty;
       locnt^[addslot].objcode:=newportalnum;
      end;
     if newportrg=202 then if thisregion=lastportal_r then
      begin
       newportalnum:=lastportal_n;
       locnt^[addslot].objcode:=newportalnum;
       layportal:=true;newportx:=1;
      end;
     if (layportal) XOR (newportx=0) then
      begin
       locnt^[addslot].p:=
         rmcnt^[xloc+region.room.x1[n]-1,yloc+region.room.y1[n]-1];
       rmcnt^[xloc+region.room.x1[n]-1,yloc+region.room.y1[n]-1]:=addslot;
       locnt^[addslot].obj:=layobj[ord(j)-64];
      end;
      if layobj[ord(j)-64]<>0 then
       if (obj^[layobj[ord(j)-64]].t=2) or (obj^[layobj[ord(j)-64]].t=4)
        then begin
         locnt^[addslot].objcode:=0;
         say(4,188,0,straction(obj^[layobj[ord(j)-64]].d[2])+':');
         editactionp(obj^[layobj[ord(j)-64]].d[2],
          length(straction(obj^[layobj[ord(j)-64]].d[2]))*2+3,188,
            locnt^[addslot].objcode);
         showroom(n);erset;
        end;
      end;
      if obj^[layobj[ord(j)-64]].t=12 then
       begin
         say(3,183,0,'PLACE HOW MUCH?  Û1(10-2500)');
         say(3,191,1,'AMOUNT:');
         val(readlin(18,191,3,1),dri,dri1);
         say(3,183,0,BLANK);
         say(3,191,0,BLANK);
          if (dri1=0) and (dri<2551) and (dri>1) then
           begin;dri:=dri DIV 10;locnt^[addslot].objcode:=dri;end;
       end;
      if layobj[ord(j)-64]<>0 then if (obj^[layobj[ord(j)-64]].t<5)
	  then if obj^[layobj[ord(j)-64]].d[1]>240 then
	   begin
	    loadgraps2(false);
	    locnt^[addslot].objcode:=grap_select_window(lastgrap);
		lastgrap:=locnt^[addslot].objcode;
		loadgraps;
		showroom(n);erset;
	   end;		
      getroom(n);
      maponly;
     end;
  'E':if llp<>0 then begin
      addslot:=locnt^[llp].obj;
      if addslot=255 then
       begin
        rcrc^[locnt^[llp].objcode].used:=false;
       end else
      if addslot<>0 then
       if obj^[addslot].t=5 then
        begin
         region.port[locnt^[llp].objcode].used:=false;
        end;
	 if addslot<>0 then
      begin {no point in erasing nothing}	
       if looklevel=1 then begin
        locnt^[llp].obj:=0;
        rmcnt^[xloc+region.room.x1[n]-1,yloc+region.room.y1[n]-1]:=locnt^[llp].p;
       if llp=locntsize then dec(locntsize);
       end else begin
        locnt^[llpprev].p:=locnt^[llp].p;
        locnt^[llp].obj:=0;
        if llp=locntsize then dec(locntsize);
       end;
	  getroom(n);
      maponly;
	  end;
    end;
 #27:done:=true;
 end;
until done;
end;


procedure sanitycheck;
 var sanity:array[0..LOCNTMAX] of word;
  f:text;
  xc,yc,xc2,yc2:byte; p:word;
  errors:word;
  j:char;
begin
 errors:=0;
 assign(f,'REGION'+strnum(thisregion)+'.LOG');
 {$I-} append(f); {$I+}
 if ioresult<>0 then rewrite(f);
 say(2,173,0,'** CHECKING REGION FOR DATA ERRORS **');
 say(2,182,0,'**         PLEASE WAIT...          **');
 say(2,191,0,'**                                 **');
 writeln(f,'Error checking for region #'+strnum(thisregion)+' "'+region.name+'"');
 writeln(f,'Region size: '+strnum(locntsize)+'/6400');
 writeln(f,' ');
 writeln(f,'Performing surface scan...');
 {scan for gross pointer problems -- shared pointers at rmcnt level}
 for xc:=1 to 80 do
  for yc:=1 to 40 do
   begin
    p:=rmcnt^[xc,yc];

    for xc2:=1 to 80 do
	 for yc2:=1 to 40 do
	  if (xc<>xc2) or (yc<>yc2) then
	   if p=rmcnt^[xc2,yc2] then
	    if p<>0 then
		 begin
		  inc(errors);
		  say(25,191,0,'ERRORS FOUND: '+strnum(errors));
		  write(f,'Duplicate pointer found: '+strnum(xc)+','+strnum(yc)+
		   ' and '+strnum(xc2)+','+strnum(yc2)+' pointer: @'+strnum(p));
		  write(f,' next: @'+strnum(locnt^[p].p)+' OBJ# '+strnum(locnt^[p].obj));
		  if (locnt^[p].obj<>0) and (locnt^[p].obj<>255) then
		  writeln(f,' '+obj^[locnt^[p].obj].n) else writeln(f,' ');
          rmcnt^[xc2,yc2]:=0;
		
		
         {uh-oh, duplicate pointer}


        end;
	end;

 writeln(f,'Surface scan finished.');
 writeln(f,' ');
 writeln(f,'Performing deep scan...');

 for p:=1 to LOCNTMAX-1 do
  sanity[p]:=0;
 for xc:=1 to 80 do
  for yc:=1 to 40 do
    begin
	 p:=rmcnt^[xc,yc];
	 while p<>0 do
	  begin
	   if sanity[p]=0 then sanity[p]:=xc*256 + yc
	    else
		 begin
		  inc(errors);
		  say(25,191,0,'ERRORS FOUND: '+strnum(errors));		
		  writeln(f,'Duplicate pointer found: '+strnum(xc)+','+strnum(yc)+
		   ' and '+strnum(sanity[p] DIV 256)+','+strnum(sanity[p] MOD 256)+' pointer: @'+strnum(p)+
		   ' next: @'+strnum(locnt^[p].p));
          rmcnt^[xc,yc]:=0;		
		 end;
	   if p=locnt^[p].p then
	    begin
		  inc(errors);
		  say(25,191,0,'ERRORS FOUND: '+strnum(errors));	
		 writeln(f,'Pointer @'+strnum(p)+' points to itself!');
		 locnt^[p].p:=0;
		 p:=0;
		end else
	   p:=locnt^[p].p;
	
	  end; {while}

	
	end;
	




 writeln(f,'Deep scan finished.');
 if errors=0 then writeln(f,'No errors found.');
 writeln(f,' '); writeln(f,' '); writeln(f,' ');
 close(f);
 if errors>0 then
  begin
   say(10,182,0,strnum(errors)+' ERRORS FOUND AND REPAIRED.');
   say(20,191,0,'    PRESS A KEY.    ');
   j:=readkey; if j=#0 then j:=readkey;
  end;
end;

procedure deleteroom(n:byte);
 var xc,yc:byte;

	 here_loop,here_next:word;
	
function notshared(r,x,y:byte):boolean;
{returns true if no other rooms share this space}
var i:byte;

begin
 notshared:=true;
 for i:=1 to 16 do
  if i<>r then
   if region.room.x1[i]<>0 then
    begin
     if (region.room.x1[i]<=x) and (region.room.x2[i]>=x)
      and (region.room.y1[i]<=y) and (region.room.y2[i]>=y)
       then notshared:=false;	
    end;

end; {notshared}	
	
begin
 if n=0 then exit;
 getroom(n);
 showroom(n);
 say(15,182,6,'  DELETE THIS ROOM?  [Y/N]  ');
 if upcase_sync(readkey)<>'Y' then exit;
 for xc:=region.room.x1[n] to region.room.x2[n] do
  for yc:=region.room.y1[n] to region.room.y2[n] do
   if notshared(n,xc,yc) then
   begin

    here_loop:=rmcnt^[xc,yc]; rmcnt^[xc,yc]:=0;

    while here_loop<>0 do
	   begin
	    here_next:=locnt^[here_loop].p;

		if locnt^[here_loop].obj<>0 then
		begin
         if locnt^[here_loop].obj=255 then
          begin
           rcrc^[locnt^[here_loop].objcode].used:=false;
          end else
          if obj^[locnt^[here_loop].obj].t=5 then
           begin
            region.port[locnt^[here_loop].objcode].used:=false;
           end;

	     locnt^[here_loop].obj:=0; locnt^[here_loop].objcode:=0;
         locnt^[here_loop].p:=0;		
		 here_loop:=here_next;
		end {obj<>0}
		 else
		begin {obj=0}
	     locnt^[here_loop].obj:=0; locnt^[here_loop].objcode:=0;
         locnt^[here_loop].p:=0;		
		 here_loop:=0;
		end; {obj=0}
		
	   end; {while}
   end; {loop}

 here_loop:=locntsize;
 while (locnt^[here_loop].obj=0) and (here_loop>5) do
  begin;dec(here_loop);dec(locntsize);end;
 region.room.x1[n]:=0;
 if n=region.rooms then dec(region.rooms);
 say(15,182,5,' ROOM DELETED - PRESS A KEY ');
 repeat until readkey<>#0;
end;
