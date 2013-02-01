procedure regionreports(max:byte);

var log:text;
    x,y,xc,yc:byte;
	w,freeloc:word;
	i:integer;
	thisregion,ch:byte;
	s,s1:string;
	something:boolean;
    count,xmax:byte;
	warnings,creaturespace:byte;
   
begin
 warnings:=0;
 clearscreen;
 say(10,60,0,'CREATING REGIONS.TXT REPORT...');
 assign(log,'REGIONS.TXT');
 rewrite(log);

 
 for thisregion:=1 to max do
  begin {region}
   loadmap(thisregion);
   say(38,70,0,strnum(thisregion));

   write(log,'----------- #',thisregion,': ',region.name,' ');
   for x:=1 to 30 do write(log,'-');
   writeln(log);writeln(log);
   if region.rooms>20 then 
    begin {interpret worldmap}
	 writeln(log,' Worldmap, ',region.room.cells,' cells'); writeln(log);
	 writeln(log,' Chunk layout (each chunk is 16x16 tiles):');
	 xmax:=1;
	 for y:=1 to 32 do
	  for x:=1 to 32 do
	   if region.room.wmap[x,y]<>0 then
	    if x>xmax then xmax:=x;
	   
	 
	 for y:=1 to 32 do 
	  begin
	   something:=false; s:='';
	   for x:=1 to xmax do
	    begin
		 ch:=region.room.wmap[x,y];
		 if ch<>0 then something:=true;
		 case ch of
		  0:s1:='  . ';
		  1..9:s1:='  '+strnum(ch)+' ';
		  10..99:s1:=' '+strnum(ch)+' ';
		  else s1:=' '+strnum(ch);
		  end; {case}
		 s:=s+s1;
		end; {x}
       if something then writeln(log,'   '+s);
	  end; {y}
      writeln(log);
	  write(log,' Edge type:');
	 
    if region.room.wallgrap[1]=0 then s:='WRAP-AROUND' else
     if obj^[region.room.wallgrap[1]].t=5
      then s:='PORTAL: #'+strnum(region.room.wallgrap[1])+'-'+obj^[region.room.wallgrap[1]].n+
	   ' (portal index #'+strnum(region.room.wallgrap[2])+')' else
     s:='TERRAIN: '+obj^[region.room.wallgrap[1]].n;	 
     writeln(log,s);
	 
		  
	 
	 end {wmap} else
	begin {interpret roommap}
	  write(log,' Room map, ',region.rooms,' rooms'); 

	  freeloc:=0;
	  for w:=1 to LOCNTMAX do if locnt^[w].obj=0 then inc(freeloc);
	  writeln(log,'  Free space: ',freeloc);
	  if freeloc<200 then
	    begin
		 inc(warnings);
		 writeln(log);
		 writeln(log,'  WARNING: You are running very low on map table space for this region.');   
		 writeln(log,'   Check to make sure you are not stacking things unnecessarily!');
		end; 
	   
	  writeln(log);
	  writeln(log,' Room list:');
	  for x:=1 to region.rooms do if region.room.x1[x]<>0 then
	   begin
	    write(log,'  #',x,' - ',region.room.name[x]);
		write(log,'  (',region.room.x1[x],',',region.room.y1[x],')  ');
		with region.room do
		 writeln(log,'w: ',x2[x]-x1[x]+1,' h: ',y2[x]-y1[x]+1);
	   end; 

	  end; {rmap}   
           writeln(log);
   
           if region.room.wallgrap[16]=0 then s:='NO ' else
           if region.room.wallgrap[16]=1 then s:='GLOBAL SETTING' else
            s:='YES, #'+strnum(region.room.wallgrap[16]-1);
		   writeln(log,'  Step macro: ',s);	
  
           i:= region.room.wallgrap[15];
          case i of
           0..10:s:=strnum((i+1)*5)+' SEC';
           255:s:='TIME DOES NOT PASS';
           else s:=strnum(i-10)+' MIN';
           end;
		   writeln(log,'  Step time: ',s);
		   
		   case region.shadow of
           0:s:='TOTAL (NEVER DARK)';
           1:s:='OUTDOOR (DAY/NIGHT)';
           255:s:='TOTAL (SEE THROUGH OPAQUE TERRAIN)';
           else s:='INDOOR (RANGE '+strnum(region.shadow-1)+')';
           end;
		   writeln(log,'  Visibility: ',s);
		   
          if region.room.wallgrap[3]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[3]);
          writeln(log,'  Entrance macro: '+s);

          if region.room.wallgrap[4]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[4]);
          writeln(log,'  Exit macro: '+s);

          if region.room.wallgrap[5]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[5]);
		  {s:='#'+strnum(region.room.wallgrap[5]);}
          writeln(log,'  Walking music: '+s);

          if region.room.wallgrap[6]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[6]);
          writeln(log,'  Combat music: '+s);

		  if region.room.wallgrap[7]=0 then s:='NO' else s:='YES';
          writeln(log,'  Disable "drop" command: '+s);
		   
    writeln(log);
	
	writeln(log,' Portal table:');
	count:=0;
	for x:=1 to 255 do
	 begin {portals}
	  if region.port[x].used then 
	      begin
		   if region.port[x].ry=255 then
		     writeln(log,'  ',x,': to Region ',
	         region.port[x].region,', Room ',region.port[x].rx,', Loc ',
		     region.port[x].x,',',region.port[x].y)
		   else
		  writeln(log,'  ',x,': to Region ',
	      region.port[x].region,', Loc ', (region.port[x].rx-1)*16 + region.port[x].x, ',',
		   (region.port[x].ry-1)*16 + region.port[x].y, '  (raw data:',
		  region.port[x].rx,',',region.port[x].ry,',',
		  region.port[x].x,',',region.port[x].y,')');
		  inc(count);
		  end;
	 end; {portals}
	writeln(log,' Total portals: ',count,'  Max allowed: 255');
    writeln(log);
	
	writeln(log,' Creature table:'); count:=0;
	for x:=1 to RCMAX do
	 if rcrc^[x].used then
	 with rcrc^[x] do
	 begin {creatures}
	   inc(count);
	   writeln(log,'  ',x,': #',crcsource,'-'+crc^[crcsource].n,' talk=',talk,
	   ' move=',motive,' anger=',anger,' hp=',hp,'/',crc^[crcsource].hm); 
	 end; {creatures}
	 
	writeln(log,' Total creatures: ',count,'  Max allowed: ',RCMAX);	 
      if RCMAX-count>0 then writeln(log,'  You have room to add ',RCMAX-count,' more active creatures.')
       else writeln(log,'  You have no more room to add active creatures.');	 
    creaturespace:=RCMAX-count;	   
    writeln(log);
	
	writeln(log,' Wander table:');	 count:=0;

	 for i:=1 to WANDERMAX do
	  if wander_index^[i].x<>0 then
	  with wander_index^[i] do
	  begin 
	   inc(count);
	   write(log,'  ',i,': #',creature,'-'+crc^[creature].n,' odds=',odds,'% ');
	   if region.rooms>20 then 
	    begin
		 write(log,'at');
		 for xc:=1 to 32 do for yc:=1 to 32 do if 
		  region.room.wmap[xc,yc]=x then
		   write(log,' ',(xc-1)*32+xin,',',(yc-1)*32+yin,' ');
		 writeln(log,' (raw data:',x,',',xin,',',yin,')');
		end else write(log,'in room ',x,' at ',xin,',',yin);

	  end; {wander}
	writeln(log,' Total wanderers: ',count,'  Max allowed: ',WANDERMAX);	
      if WANDERMAX-count>0 then writeln(log,'  You have room to add ',WANDERMAX-count,' more wandering creatures.')
       else writeln(log,'  You have no more room to add wandering creatures.');	 	
	  if count>creaturespace then 
	    begin
		 inc(warnings);
		 writeln(log);
		 writeln(log,'  WARNING: You do not have enough room in the active creature table for all of these wanderers.');   
		 writeln(log,'   Some of them may be prevented from spawning until other creatures are killed during play.');
		end; 
    if region.rooms>20 then
     begin	
	  count:=0;
      writeln(log);
	  writeln(log,' Stacking table (used by items and vehicles)');	 count:=0;
	  for i:=1 to 255 do if veh[i].used then
	    begin
		 writeln(log,'  ',i,': o=',veh[i].obj,' d=',veh[i].objcode,
		 ' q=',veh[i].howmany,' x=',veh[i].xchunk,' y=',veh[i].ychunk);
		 inc(count);
		end;
	  writeln(log,' Total entries: ',count,'  Max allowed: 255');
      if 255-count>0 then writeln(log,'  You have room to add ',255-count,' more items or vehicles.')
       else writeln(log,'  You have no more room to add items or vehicles.');	  
	  if 255-count<20 then
        begin
		 inc(warnings);
		 writeln(log);
		 writeln(log,'  WARNING: Your space in this table is very low!  The player may be unable to drop items,');
		 writeln(log,'   dismount vehicles, trigger "put item here" actions, or get dropped loot from creatures!');
        end;		
	 end;
	
 
    for x:=1 to 3 do writeln(log);
	 
  end; {region}
 close(log);
 say(35,140,0,'DONE.');
 if warnings>0 then 
  begin
   say(2,150,0,'NOTE: '+strnum(warnings)+' WERE LOGGED. (SEARCH THE');
   say(2,160,0,' REPORT FOR THE WORD "WARNING".');
  end;
 say(30,190,0,'PRESS A KEY.'); 
 count:=ord(readkey); if count=0 then count:=ord(readkey);
 clearscreen;
  
 end; {procedure}