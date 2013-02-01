(*
 To-Do list:
  Add creature-placement
  Write the docs
  Put the other..() routines into macroedit? and configedit.
*)

{when placing 1way door allow placing return door}

{ MapEdit }

{$m 50000,200000,300000}
uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,
     u_help,u_sound,o_maped1,o_maped2,o_maped3;

(*
function getmetadata(r,c,x,y:byte):byte;
var f:file;w:word;
begin
 if (r>0) and (c>0) then begin

 assign(f,ADVNAME+'.D'+strnum(r));
 {$I-} reset(f); {$I+}
 if ioresult<>0 then
 begin
  {create metadata file}
   rewrite(f);
   for i:=1 to 65280 do write(f,0);
   c:=0;
   close(f);
  end else
  begin
   seek( (256*(c-1)) + (16*(y-1)) + (x-1) );
   read(f,c);
   close(f);
  end;
 end else c:=0;

 getmetadata:=c;
end;

procedure setmetadata(r,c,x,y,v:byte);
var f:file;
begin
 if (r=0) or (c=0) then exit;
 assign(f,ADVNAME+'.D'+strnum(r));
 {$I-} reset(f); {$I+}
 if ioresult<>0 then exit;
 seek( (256*(c-1)) + (16*(y-1)) + (x-1) );
 write(f,v);
 close(f);
end;
*)

{$I I_MSTREC.PAS}
{.I I_PPLED1.PAS}
{.I I_MAPED1.PAS}
{.I I_MAPED3.PAS}

var ack:masterrec;



procedure deleteregion(max:byte);
 var target:byte;
     j:char;
     s:string;
     f:file;
     rgf:file of regionrec;
procedure delfiles(c:char);
 begin
  {$I-}
  assign(f,ADVNAME+'.'+c+strnum(target));
  erase(f);
  {$I+}
 end;

begin
 target:=menuselectregion(max);
 if target=0 then exit;
 loadmap(target);
 clearscreen;
 say(1,1,6,' WARNING: ');
 say(3,11,0,'ANY PORTALS STILL POINTING TO');
 say(3,21,0,'THIS REGION WILL HAVE TO BE');
 say(3,31,0,'FIXED MANUALLY.  ARE YOU SURE');
 say(3,41,0,'YOU WANT TO DELETE THIS REGION?');
 say(3,51,0,'PRESS Û5 Y Û0 OR Û5 N Û0.');
 say(3,170,0,'REGION #'+strnum(target)+': '+region.name);
 case region.rooms of
  0..19:s:='ROOM-TYPE, '+strnum(region.rooms)+' ROOMS';
  20..253,255:s:='STANDARD WORLDMAP';
  254:s:='CUSTOM WORLDMAP';
 end;
 say(3,180,0,'TYPE: '+s);
 repeat
  j:=upcase_sync(readkey);
  if j=#0 then if readkey=#59 then help;
  if j=#27 then j:='N';
 until (j='Y') or (j='N');
 if j='Y' then
  begin
   assign(rgf,ADVNAME+REGIONFILE);
   {$I-} reset(rgf); {$I+}
   if ioresult=0 then
    begin
     region.name:='(DELETED)';
     seek(rgf,target-1);
     {$I-} write(rgf,region); {$I+}
     if ioresult=0 then
      begin
       delfiles(MAPAFILE[2]);
       delfiles(MAPBFILE[2]);
       delfiles(MAPCFILE[2]);
       delfiles('W');
      end;
     close(rgf);
    end;
  end;
 clearscreen;
end;




procedure editregion(num:byte);
 var done,done2:boolean;
    sc1,sc2:word;
    sin:string;
    v1,v2:byte;
    j,j2:char;
    takething_buffer:array[1..80] of byte;
    tbc:byte;
    pointx,pointy,pointx1,pointy1:byte;pointmode:byte;
    maxpx,maxpy,minpx,minpy:byte;
    topx,topy,cellx,celly:byte;
    redispmenu:boolean;
    wmaph,wmapw:integer;  {not for custom}
    layportal:boolean;
    newportrg,newportxc,newportyc,newportx,newporty:byte;
    seekportalcount,layobj,newportalnum:byte;
    chf:file of chunkrec;
    oldh:byte;

var
  drawingphase: byte;  {1: first corner, 2: second corner, 3: done}
  newx1,newx2,newy1,newy2: byte;
  newroomnum: byte;
  loopx1, loopx2, loopy1, loopy2, loopx, loopy, buffercount: byte;
  loopbuffer:array[0..176] of byte;
  
 
	
	
	
function getthing(xx,yy:integer):byte;
var i,i2:integer;
begin
 for i:=yy+1 to yy+4 do 
  for i2:=0 to 3 do
   getthing:=mem[scrnl:(xx*4)+i2+scrnh[i]];
end;	
	
	
procedure noto;
begin
  putthing(1+round(56*((topx-1)/23)+10),1,2);
  putthing(6,round(106*((topy-1)/23)+16),2);
end;
begin
 done:=false;
{ say(34,42,0,': #');
 s:=readlin(40,42,3,0);
 val(s,i,i1);
 if (i1<>0) or (i>num) then exit;
 num:=i; }
 num:=menuselectregion(1);
 if num=0 then exit;
 loadmap(num);
 if region.rooms>250 then
  begin
   topx:=1;topy:=1;cellx:=0;celly:=0;
   clearscreen;
   if region.rooms=254 then
     begin;cwmap_scrollbars;previewcells(topx,topy);end else
	  begin
	            wmapw:=1;wmaph:=1;
                for topx:=1 to 32 do for topy:=1 to 32 do
                 if region.room.wmap[topx,topy]<>0 then 
				  begin
				   if topx>wmapw then wmapw:=topx;
				   if topy>wmaph then wmaph:=topy;
				  end;
	   end;	
     redispmenu:=true;
  repeat
   if region.rooms=254 then helpindex:=63 else helpindex:=61;
 if redispmenu then begin
   say(2,155,5,' N Û0: NAME: '+region.name);
 {  if region.shadow then s:='ON ' else s:='OFF'; }
{   say(2,164,5,' S Û0HADOWING: '+s); }
if region.rooms=254 then
 say(2,164,5,'ƒ„VÛ0:VIEW  Û5ƒ„OÛ0:OPTIONS  Û5ESCÛ0:EXIT')
 else say(22,164,5,'ESCÛ0 TO EXIT.');
   say(2,173,5,' E Û0:EDIT MAP      Û5 P Û0:EDIT MAP EDGE');
   if region.rooms=254 then
    begin
   say(2,182,5,' …† Û0 TO CHANGE NUMBER   Û5 A Û0:ADD CELL');
   say(2,191,5,' C Û0 TO EDIT ONE CELL     (CELLS='
       +strnum(region.room.cells)+')  ');
    end else
     begin
      say(2,182,5,' V Û0 VIEW MAP   Û5 O Û0 OPTIONS');
      {boxx((40-((wmapw+2) DIV 2)),(16-((wmaph+2) DIV 2)),
                  (40-((wmapw+2) DIV 2))+wmapw+1,(16-((wmaph+2) DIV 2))+wmaph+1);}
				  
		{newx1:=	(40-((wmapw+2) DIV 2)) *4;
		newy1:= (16-((wmaph+2) DIV 2));
		newx2:= ((40-((wmapw+2) DIV 2))+wmapw+1) *4;
		newy2:= (16-((wmaph+2) DIV 2))+wmaph+1;}
		
		newx1:= 161 - (wmapw*2);
		newx2:= 162 + (wmapw*2);
		
		newy1:= 65 - (wmaph*2);
		newy2:= 66 + (wmaph*2);
		
		sketchline(newx1,newy1,newx1,newy2,hi(TEXTC0)); {left}
		sketchline(newx1,newy1,newx2,newy1,hi(TEXTC0)); {top}
		sketchline(newx2,newy1,newx2,newy2,hi(TEXTC0)); {right}
		sketchline(newx1,newy2,newx2,newy2,hi(TEXTC0)); {bottom}
				  
				  
        say(36-(wmapw DIV 2)-length(strnum(wmaph*16)),64,0,strnum(wmaph*16));
        say(38,68+((wmaph*4) DIV 2),0,strnum(wmapw*16));
		{display mini map preview}
          {128,33 for 256x256}

          assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
          {$I-} reset(chf); {$I+}
          if region.rooms<>254 then begin;topx:=1;topy:=1;end;
          if ioresult=0 then
 

          begin
           for xchunkloc:=1 to wmapw do
            for ychunkloc:=1 to wmaph do
			 begin
			 
			  topx:=(162 - (wmapw*2)) + ((xchunkloc-1)*4);
			  topy:=(66 - (wmaph*2)) + ((ychunkloc-1)*4);
			 
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
               read(chf,map[2,2]);
               {$I+}
               for pointx:=0 to 3 do for pointy:=0 to 3 do
                putpixel(topx+pointx,topy+pointy,mapcolors[map[2,2,pointx*4+2,pointy*4+2].o]);
              end;
             end;
          end;
 
         {$I-} close(chf); {$I+}
 











		
		
     end;

  end;redispmenu:=false;
  if region.rooms=254 then
   begin
    putthing(cellx*8+9,celly*16+10,TEXTC0 DIV 256);
    putthing(cellx*8+16,celly*16+10,TEXTC0 DIV 256);
    putthing(cellx*8+9,celly*16+14,TEXTC0 DIV 256);
    putthing(cellx*8+16,celly*16+14,TEXTC0 DIV 256);
   end;
   j:=upcase_sync(readkey);
  if region.rooms=254 then
   begin
    putthing(cellx*8+9,celly*16+10,TEXTC0 MOD 256);
    putthing(cellx*8+16,celly*16+10,TEXTC0 MOD 256);
    putthing(cellx*8+9,celly*16+14,TEXTC0 MOD 256);
    putthing(cellx*8+16,celly*16+14,TEXTC0 MOD 256);
   end;
   case j of
    #0:case readkey of
     #59:help;
     #68:begin;done:=true;quittime:=true;end;
     'H':if region.rooms=254 then
         begin
          if celly>0 then dec(celly) else
          if topy>1 then begin;noto;dec(topy);previewcells(topx,topy);end;
		  end;
     'P':if region.rooms=254 then
         begin
          if celly<7 then inc(celly) else
          if topy<25 then begin;noto;inc(topy);previewcells(topx,topy);end;
		  end;
     'K':if region.rooms=254 then
         begin
          if cellx>0 then dec(cellx) else
          if topx>1 then begin;noto;dec(topx);previewcells(topx,topy);end;
		  end;
     'M':if region.rooms=254 then
         begin
          if cellx<7 then inc(cellx) else
          if topx<25 then begin;noto;inc(topx);previewcells(topx,topy);end;
		  end;
     'G':if region.rooms=254 then
          begin;noto;cellx:=4;celly:=4;topx:=1;topy:=1;
          previewcells(topx,topy);end;
     'O':if region.rooms=254 then
          begin;noto;cellx:=4;celly:=4;topx:=1;topy:=25;
          previewcells(topx,topy);end;
     'I':if region.rooms=254 then
          begin;noto;cellx:=4;celly:=4;topx:=25;topy:=1;
          previewcells(topx,topy);end;
     'Q':if region.rooms=254 then
          begin;noto;cellx:=4;celly:=4;topx:=25;topy:=25;
          previewcells(topx,topy);end;

	 #17:if region.rooms=254 then
          begin {alt-W}
           oldh:=helpindex; helpindex:=60;
           say(10,150,6,' CHANGE THIS MAP TO ');
           say(10,158,6,' A NORMAL WORLDMAP? ');
           say(10,166,6,'       [Y/N]        ');
           redispmenu:=true;done2:=false;
          repeat
           case upcase_sync(readkey) of
           'Y':begin
                region.rooms:=255;clearscreen;
			    wmapw:=1;wmaph:=1;
                for topx:=1 to 32 do for topy:=1 to 32 do
                 if region.room.wmap[topx,topy]<>0 then 
				  begin
				   if topx>wmapw then wmapw:=topx;
				   if topy>wmaph then wmaph:=topy;
				  end;
                done2:=true;
               end;
           'N':done2:=true;
           #0:if readkey=#59 then help;
           end;
          until done2;
           helpindex:=oldh;
          end;	 
     #46:if region.rooms<>254 then
          begin {alt-C}
           oldh:=helpindex; helpindex:=60;
           say(10,150,6,' CHANGE THIS MAP TO ');
           say(10,158,6,' A CUSTOM WORLDMAP? ');
           say(10,166,6,'       [Y/N]        ');
           redispmenu:=true;done2:=false;
          repeat
           case upcase_sync(readkey) of
           'Y':begin
                region.rooms:=254;clearscreen;
                cellx:=1;celly:=1;topx:=1;topy:=1;
                cwmap_scrollbars;previewcells(topx,topy);
                done2:=true;
               end;
           'N':done2:=true;
           #0:if readkey=#59 then help;
           end;
          until done2;
           helpindex:=oldh;
          end else
          begin
           blankbox(1,155,319,199);
           say(3,170,0,'COPY CELL      TO');
           s:=readlin(23,170,3,0);
           val(s,i,i1);
           if (i<>0) and (i1=0) then
            begin
             pointx:=i;
             s:=readlin(39,170,3,0);
             val(s,i,i1);
             if (i<>0) and (i1=0) then
              begin
               assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
               {$I-} reset(chf); {$I+}
               if ioresult=0 then
                begin
                 seek(chf,pointx-1);
                 read(chf,map[2,2]);
                 {$I-} seek(chf,i-1);
                 if ioresult=0 then
                  write(chf,map[2,2]);
                 close(chf);
                 {$I+}
                 {copy cell}
                end;
              end;
            end;
            clearscreen;
            redispmenu:=true;
            cwmap_scrollbars;
            previewcells(topx,topy);
          end;
		  
    end; {case}		  
		  
     'O':begin 
          redispmenu:=true;
          done2:=false;
          oldh:=helpindex;helpindex:=78;
         repeat
          clearscreen;
          say(1,1,6,' OTHER OPTIONS ');

          if region.room.wallgrap[16]=0 then s:='NO ' else
           if region.room.wallgrap[16]=1 then s:='GLOBAL SETTING' else
            s:='YES, #'+strnum(region.room.wallgrap[16]-1);

          say(5,10,5,' S Û0: USE STEPMACRO? '+s);

          i:= region.room.wallgrap[15];
          case i of
           0..10:s:=strnum((i+1)*5)+' SEC';
           255:s:='TIME DOES NOT PASS';
           else s:=strnum(i-10)+' MIN';
           end;
          say(5,22,5,' T Û0: STEP TIME: '+s);

         { if region.shadow then s:='ON ' else s:='OFF';}
          case region.shadow of
           0:s:='TOTAL (NEVER DARK)';
           1:s:='OUTDOOR (DAY/NIGHT)';
           255:s:='TOTAL (SEE THROUGH OPAQUE TERRAIN)';
           else s:='INDOOR (RANGE '+strnum(region.shadow-1)+')';
           end;
          say(5,34,5,' V Û0: VISIBILITY:');
          say(10,42,0,s);


          if region.room.wallgrap[3]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[3]);
          say(5,52,5,' E Û0: ENTRANCE MACRO: '+s);

          if region.room.wallgrap[4]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[4]);
          say(5,62,5,' X Û0: EXIT MACRO: '+s);

          if region.room.wallgrap[5]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[5]);
		  {s:='#'+strnum(region.room.wallgrap[5]);}
          say(5,72,5,' W Û0: WALKING MUSIC: '+s);

          if region.room.wallgrap[6]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[6]);
          say(5,82,5,' C Û0: COMBAT MUSIC: '+s);

		  if region.room.wallgrap[7]=0 then s:='NO' else s:='YES';
          say(5,92,5,' D Û0: DISABLE "DROP" COMMAND: '+s);


          say(5,102,5,'ESCÛ0: EXIT');
          case upcase_sync(readkey) of
           #0:if readkey=#59 then help;
           'M':if region.room.wallgrap[16]=0 then region.room.wallgrap[16]:=1
                else region.room.wallgrap[16]:=0;
           'S':begin
                say(2,150,0,'ENTER ''N'' TO USE NO MACRO');
                say(2,160,0,'ENTER ''Y'' TO USE THE GLOBAL STEPMACRO');
                say(2,170,0,'ENTER 1-254 TO USE UNIQUE STEPMACRO');
                say(2,180,0,'  FOR THIS REGION');
                say(45,10,0,'           ');
                s:=readlin(45,10,3,0);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[16]:=i+1;
                if upcase(s[1])='Y' then region.room.wallgrap[16]:=1;
                if upcase(s[1])='N' then region.room.wallgrap[16]:=0;

               end;
		   'D':begin
		        if region.room.wallgrap[7]=0 then region.room.wallgrap[7]:=1 else region.room.wallgrap[7]:=0;
			   end;	
           'W':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MUSIC');
                say(49,72,0,'         ');
                s:=readlin(45,72,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[5]:=i;
               end;
           'C':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MUSIC');
                say(49,82,0,'         ');
                s:=readlin(43,82,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[6]:=i;
               end;

           'E':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MACRO');
                say(47,52,0,'         ');
                s:=readlin(47,52,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[3]:=i;
               end;
           'X':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MACRO');
                say(39,62,0,'         ');
                s:=readlin(39,62,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[4]:=i;
               end;


           'V':begin
                 say(2,130,0,'PRESS [D] FOR OUTDOOR DAY/NIGHT');
                 say(2,140,0,'PRESS [F] FOR FULL RANGE');
                 say(2,150,0,'PRESS [X] FOR FULL RANGE WITH');
                 say(2,160,0,' OPAQUE TILES MADE TRANSPARENT');
                 say(2,170,0,'PRESS [1]-[9] FOR INDOOR WITH');
                 say(2,180,0,' LIMITED LIGHT LEVEL');
                 j2:=upcase_sync(readkey);
                 case j2 of
                  'F':region.shadow:=0;
                  'D':region.shadow:=1;
                  'X':region.shadow:=255;
                  '1'..'9':region.shadow:=ord(j2)-47;
                 end;

               end;
           'T':begin
                say(2,150,0,'ENTER NUMBER OF MINUTES TAKEN BY EACH');
                say(2,160,0,'STEP.  ENTER SECONDS WITH A COLON');
                say(2,170,0,'(FOR EXAMPLE '':30'' FOR 30 SECONDS)');

                say(37,22,0,'           ');
                s:=readlin(37,22,3,0);
                if length(s)>0 then j2:=s[1] else j2:='0';
                if j2=':' then s:=copy(s,2,2);
                val(s,i,i1);
                if i1=0 then
                 begin
                  if j2=':' then region.room.wallgrap[15]:=(i DIV 5)-1
                   else region.room.wallgrap[15]:=i+10;
                 end;
                 if i=0 then region.room.wallgrap[15]:=255;
               end;

           #27:done2:=true;
           end;
          until done2;
          helpindex:=oldh;
          clearscreen;
          if region.rooms=254 then
           begin
            cwmap_Scrollbars;
            previewcells(topx,topy);
           end;
         end;

     'V':begin 
         redispmenu:=true;
         done2:=false;
          assign(chf,ADVNAME+MAPAFILE+strnum(thisregion));
          {$I-} reset(chf); {$I+}
          if region.rooms<>254 then begin;topx:=1;topy:=1;end;
          if ioresult=0 then
         repeat
          clearscreen;
          begin
           for xchunkloc:=topx to topx+19 do
            for ychunkloc:=topy to topy+11 do
             if (xchunkloc<=32) and (ychunkloc<=32) then
              if region.room.wmap[xchunkloc,ychunkloc]<>0 then
             begin
              {$I-}
              seek(chf,region.room.wmap[xchunkloc,ychunkloc]-1);
              read(chf,map[2,2]);
              {$I+}
              for pointx:=0 to 15 do for pointy:=0 to 15 do
               putpixel(pointx+(xchunkloc-topx)*16,
                        pointy+(ychunkloc-topy)*16,
                        mapcolors[map[2,2,pointx+1,pointy+1].o]);
             end;

          end;
          pointmode:=0;
          say(2,191,0,'ESC:EXIT   ARROW KEYS:MOVE');
          repeat
           case upcase_sync(readkey) of
            #27:begin;done2:=true;pointmode:=1;end;
            #0:case readkey of
                'H':begin;if topy>1 then dec(topy);pointmode:=1;end;
                'K':begin;if topx>1 then dec(topx);pointmode:=1;end;
                'P':begin;if topy<20 then inc(topy);pointmode:=1;end;
                'M':begin;if topx<12 then inc(topx);pointmode:=1;end;
                'G':begin;topx:=1;topy:=1;pointmode:=1;end;
               end;
           end;

          until pointmode=1;
         until done2;
         {$I-} close(chf); {$I+}
         clearscreen;
        if region.rooms=254 then
         begin
          cwmap_scrollbars;
          previewcells(topx,topy);
         end;
         end;

   'C':if region.rooms=254 then
       begin
         xchunkloc:=topx+cellx;ychunkloc:=topy+celly;
         chunksave:=true;onlycell:=true;
         if region.room.wmap[xchunkloc,ychunkloc]<>0 then walkworldmap;
         clearscreen;cwmap_scrollbars;
         previewcells(topx,topy);
         redispmenu:=true;
       end;
   'P':begin
     redispmenu:=true;
     clearscreen;
     say(3,10,6,' EDIT WORLDMAP EDGE   ');
     say(5,22,2,'SELECT THE OPTION YOU WISH');
     say(5,31,2,'TO USE FOR THE MAP EDGE.');
     say(10,45,1,'W) WRAP-AROUND');
     say(10,53,1,'T) ENDLESS TERRAIN');
     say(10,61,1,'X) PORTAL TO OTHER REGION');
     say(10,79,1,'ESC) ABORT');
     if region.room.wallgrap[1]=0 then s:='WRAP-AROUND' else
     if obj^[region.room.wallgrap[1]].t=5
      then s:='PORTAL: '+obj^[region.room.wallgrap[1]].n else
     s:='TERRAIN: '+obj^[region.room.wallgrap[1]].n;
     say(5,109,2,'CURRENT SETTING: ');
     say(7,119,1,s);
     layobj:=0;
     oh:=helpindex;
     helpindex:=76;
     repeat
      case upcase_sync(readkey) of
      #0:if readkey=#59 then help;
      'W':layobj:=255;
      'T':layobj:=105;
      'X':layobj:=5;
      #27:layobj:=1;
      end;
     until layobj<>0;
     helpindex:=oh;
    if layobj<>1 then
    begin
     region.room.wallgrap[1]:=0;
     if layobj=255 then
      begin
       layobj:=0;
       say(10,139,0,'NOTE: WRAP-AROUND MAPS MAY');
       say(10,149,0,'ACT STRANGELY WITH MAPS');
       say(10,159,0,'SMALLER THAN 48 UNITS IN');
       say(10,169,0,'EITHER DIRECTION.');
       say(10,179,1,' (PRESS A KEY TO CONTINUE) ');
       repeat until readkey<>#0;
      end else
      layobj:=selectobj(layobj,0,0);
    if layobj<>0 then begin
     clearscreen;
     thickln(0,0,2,199,3);
     drawh(0,0,319,3);
     thickln(0,179,319,180,3);
     thickln(261,0,262,179,3);
     thickln(317,0,319,199,3);
     layportal:=false;newportx:=0;newportalnum:=0;
      if obj^[layobj].t=5 then
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
        if region.rooms>20 then savewmap; savemap;
        newportal(newportrg,newportxc,newportyc,newportx,newporty);
       end;
     if (layportal) AND (newportx<>0) then
      begin
      with region.port[newportalnum] do begin
       used:=true;region:=newportrg;rx:=newportxc;ry:=newportyc;
       x:=newportx;y:=newporty;
       end;
       region.room.wallgrap[2]:=newportalnum;
      end;
     if (layportal) XOR (newportx=0) then
     region.room.wallgrap[1]:=layobj;
     if layobj<>0 then
      if (obj^[layobj].t=2) or (obj^[layobj].t=4)
       then begin
        region.room.wallgrap[2]:=0;
        say(1,174,0,straction(obj^[layobj].d[2])+':');
        editactionp(obj^[layobj].d[2],
         length(straction(obj^[layobj].d[2]))*2+3,174,
           region.room.wallgrap[2]);
        end;
       end;
         clearscreen;
        if region.rooms=254 then
         begin
          cwmap_scrollbars;
          previewcells(topx,topy);
         end;
        end;
         redispmenu:=true;
      end;
   'A':if region.rooms=254 then
       begin
        newchunk;
        say(52,191,0,'(CELLS='+strnum(region.room.cells)+')  ');
       end;
   #13:if region.rooms=254 then
       begin
        sin:=readlin(cellx*8+10,celly*16+10,3,1);
        val(sin,region.room.wmap[topx+cellx,topy+celly],i);
        if region.room.wmap[topx+cellx,topy+celly]>region.room.cells then
          region.room.wmap[topx+cellx,topy+celly]:=0;
        say(cellx*8+10,celly*16+10,0,'    ');
        previewcells(topx,topy);
       end;
   'N':begin
        region.name:=readlin(24,155,26,0);
        if (region.name='') or (region.name=#27) then region.name:=' ';
        say(24,155,0,'                           ');redispmenu:=true;
       end;
   'E':begin
         say(1,1,0,'START EDITING WHERE?');
          if region.rooms=254 then
           begin;xchunkloc:=topx+cellx;ychunkloc:=topy+celly;end else
           if (wmaph=1) and (wmapw=1) then
            begin;xchunkloc:=1;ychunkloc:=1;end else
            begin
			 
             cellx:=1;celly:=1;
             repeat
              done2:=false;
			  topx:=(162 - (wmapw*2)) + ((cellx-1)*4);
			  topy:=(66 - (wmaph*2)) + ((celly-1)*4) -1;			  
              xorthing2(topx,topy);
              j2:=upcase_sync(readkey);
              xorthing2(topx,topy);              

             case j2 of
              #0:case readkey of
                  #59:help;
                  'H':if celly>1 then dec(celly);
                  'P':if celly<wmaph then inc(celly);
                  'K':if cellx>1 then dec(cellx);
                  'M':if cellx<wmapw then inc(cellx);
                 end;
              #27:begin;cellx:=32;celly:=32;done2:=true;end;
              #13,#32:begin;done2:=true;putthing(topx+cellx,topy+celly,1);end;
             end;
             until done2;
            xchunkloc:=cellx;ychunkloc:=celly;
           end;
         chunksave:=true;onlycell:=false;
         if region.room.wmap[xchunkloc,ychunkloc]<>0 then walkworldmap;
         clearscreen;
         if region.rooms=254 then
           begin;cwmap_scrollbars;previewcells(topx,topy);end;
         redispmenu:=true;
       end;
   #27:done:=true;
  end;
  until done;
  end
  else begin
  previewrooms;
  repeat
   helpindex:=62;
   say(2,173,5,' N Û0: NAME: '+region.name);
   say(2,182,5,' A Û0:DD, Û5 D Û0:ELETE, Û5 E Û0:DIT ROOM.');
 {  if region.shadow then s:='ON ' else s:='OFF'; }
{   say(2,191,5,' S Û0HADOWING: '+s); }
   say(2,191,5,' O Û0:OPTIONS     Û5ESCÛ0:EXIT');
   case upcase_sync(readkey) of






     'O':begin 
          redispmenu:=true;
          done2:=false;
          oldh:=helpindex;helpindex:=78;

          repeat
          clearscreen;
          say(1,1,6,' OTHER OPTIONS ');
          if region.room.wallgrap[16]=0 then s:='NO ' else
           if region.room.wallgrap[16]=1 then s:='GLOBAL SETTING' else
            s:='YES, #'+strnum(region.room.wallgrap[16]-1);
          say(5,10,5,' S Û0: USE STEPMACRO: '+s);

          i:= region.room.wallgrap[15];
          case i of
           0..10:s:=strnum((i+1)*5)+' SEC';
           255:s:='TIME DOES NOT PASS';
           else s:=strnum(i-10)+' MIN';
           end;
          say(5,22,5,' T Û0: STEP TIME: '+s);
         { if region.shadow then s:='ON ' else s:='OFF';}
          case region.shadow of
           0:s:='TOTAL (NEVER DARK)';
           1:s:='OUTDOOR (DAY/NIGHT)';
           255:s:='TOTAL (SEE THROUGH OPAQUE TERRAIN)';
           else s:='INDOOR (RANGE '+strnum(region.shadow-1)+')';
           end;
          say(5,34,5,' V Û0: VISIBILITY:');
          say(10,42,0,s);

          if region.room.wallgrap[3]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[3]);
          say(5,52,5,' E Û0: ENTRANCE MACRO: '+s);

          if region.room.wallgrap[4]=0 then s:='NONE' else s:='#'+strnum(region.room.wallgrap[4]);
          say(5,62,5,' X Û0: EXIT MACRO: '+s);
          if region.room.wallgrap[5]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[5]);
          say(5,72,5,' W Û0: WALKING MUSIC: '+s);

          if region.room.wallgrap[6]=0 then s:='NONE' else s:=soundname(region.room.wallgrap[6]);
          say(5,82,5,' C Û0: COMBAT MUSIC: '+s);

		  if region.room.wallgrap[7]=0 then s:='NO' else s:='YES';
          say(5,92,5,' D Û0: DISABLE "DROP" COMMAND: '+s);
	  
		  
          say(5,102,5,'ESCÛ0: EXIT');
          case upcase_sync(readkey) of
           #0:case readkey of
		       #59:help;
              { #99:exportmap(thisregion);
			   #99:importmap(thisregion);}

			   
			   
			   end; {case}
		   'D':begin
		        if region.room.wallgrap[7]=0 then region.room.wallgrap[7]:=1 else region.room.wallgrap[7]:=0;
			   end;		
           'S':begin
                say(2,150,0,'ENTER ''N'' TO USE NO MACRO');
                say(2,160,0,'ENTER ''Y'' TO USE THE GLOBAL STEPMACRO');
                say(2,170,0,'ENTER 1-254 TO USE UNIQUE STEPMACRO');
                say(2,180,0,'  FOR THIS REGION');
                say(45,10,0,'           ');
                s:=readlin(45,10,3,0);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[16]:=i+1;
                if upcase(s[1])='Y' then region.room.wallgrap[16]:=1;
                if upcase(s[1])='N' then region.room.wallgrap[16]:=0;

               end;
           'W':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MUSIC');
                say(49,72,0,'         ');
                s:=readlin(45,72,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[5]:=i;
               end;
           'C':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MUSIC');
                say(49,82,0,'         ');
                s:=readlin(43,82,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[6]:=i;
               end;


           'E':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MACRO');
                say(47,52,0,'         ');
                s:=readlin(47,52,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[3]:=i;
               end;
           'X':begin
                say(2,150,0,'ENTER ''0'' TO USE NO MACRO');
                say(39,62,0,'         ');
                s:=readlin(39,62,3,1);
                val(s,i,i1);
                if i1=0 then region.room.wallgrap[4]:=i;
               end;


           'V':begin
                 say(2,130,0,'PRESS [D] FOR OUTDOOR DAY/NIGHT');
                 say(2,140,0,'PRESS [F] FOR FULL RANGE');
                 say(2,150,0,'PRESS [X] FOR FULL RANGE WITH');
                 say(2,160,0,' OPAQUE TILES MADE TRANSPARENT');
                 say(2,170,0,'PRESS [1]-[9] FOR INDOOR WITH');
                 say(2,180,0,' LIMITED LIGHT LEVEL');
                 j2:=upcase_sync(readkey);
                 case j2 of
                  'F':region.shadow:=0;
                  'D':region.shadow:=1;
                  'X':region.shadow:=255;
                  '1'..'9':region.shadow:=ord(j2)-47;
                 end;

               end;
           'T':begin
                say(2,150,0,'ENTER NUMBER OF MINUTES TAKEN BY EACH');
                say(2,160,0,'STEP.  ENTER SECONDS WITH A COLON');
                say(2,170,0,'(FOR EXAMPLE '':30'' FOR 30 SECONDS)');


                say(37,22,0,'           ');
                s:=readlin(37,22,3,0);
                if length(s)>0 then j2:=s[1] else j2:='0';
                if j2=':' then s:=copy(s,2,2);
                val(s,i,i1);
                if i1=0 then
                 begin
                  if j2=':' then region.room.wallgrap[15]:=(i DIV 5)-1
                   else region.room.wallgrap[15]:=i+10;
                 end;
                 if i=0 then region.room.wallgrap[15]:=255;
               end;
           #27:done2:=true;
           end; {case}
          until done2;


          clearscreen;
          previewrooms;
          helpindex:=oldh;
         end;
    #0:case readkey of		 
     #59:help;
     #68:begin;done:=true;quittime:=true;end;
    end;



   'N':begin
        region.name:=readlin(24,173,26,0);
        if (region.name='') or (region.name=#27) then region.name:='NO NAME';
        say(24,173,0,'                           ');
       end;
   'E':begin
        editroom(chooseroom('EDIT'));
        previewrooms;
       end;
   'D':begin
        sanitycheck;
        deleteroom(chooseroom('DELETE'));
        previewrooms;
       end; 
	   
	   


 
  
  
   'A':begin
   
   
        
        {make sure there is room for the room}
		if region.rooms<16 then newroomnum:=region.rooms+1 else
		 newroomnum:=0;
		for buffercount:=region.rooms downto 1 do
		 if region.room.x1[buffercount]=0 then 
		  newroomnum:=buffercount;
		
		if newroomnum<>0 then
		
		
		begin
		
   
        drawingphase:=1;
        s:='                                        ';
        say(2,173,0,s);say(2,182,0,s);say(2,191,0,s);
		say(16,173,0,'CREATING ROOM "'+chr(64+newroomnum)+'"');
        say(12,182,5, ' SELECT FIRST CORNER. ');	
        pointx:=40; pointy:=20;
		
		repeat
		
		  if drawingphase=2 then
			  {draw box}		  
		    begin
			
			  buffercount:=0;
			  
			  if pointx>newx1 then 
			   begin; loopx1:=newx1; loopx2:=pointx; end
			   else begin; loopx1:=pointx; loopx2:=newx1; end;
			   
			  if pointy>newy1 then 
			   begin; loopy1:=newy1; loopy2:=pointy; end
			   else begin; loopy1:=pointy; loopy2:=newy1; end;			   
			   
			  for loopx:=loopx1 to loopx2 do
			   for loopy:=loopy1 to loopy2 do			  
			    if (loopx=loopx1) or (loopx=loopx2)
				 or (loopy=loopy1) or (loopy=loopy2)
				 then
				 begin
			    inc(buffercount);
				loopbuffer[buffercount]:=getthing(loopx-1,loopy*4);
				putthing(loopx-1,loopy*4,TEXTC0 DIV 256);
				
			   end;

			  say(15,191,0,'WIDTH: '+strnum(loopx2-loopx1+1)+' ');
			  say(45,191,0,'HEIGHT: '+strnum(loopy2-loopy1+1)+' ');
			   
			end;

			
			
		  {draw pointer}		
          loopbuffer[0]:=getthing(pointx-1,pointy*4);
		  putthing(pointx-1,pointy*4,TEXTC2 DIV 256);
			
			
			
		  {get keypress}
		  j:=upcase_sync(readkey);
		   


	      {un-draw pointer}
		  putthing(pointx-1,pointy*4,loopbuffer[0]);
		  

		  if drawingphase=2 then
          {un-draw box}
		    begin
              buffercount:=0;
			  for loopx:=loopx1 to loopx2 do
			   for loopy:=loopy1 to loopy2 do	
			    if (loopx=loopx1) or (loopx=loopx2)
				 or (loopy=loopy1) or (loopy=loopy2)
				 then			   
			   begin
			    inc(buffercount);
				putthing(loopx-1,loopy*4,loopbuffer[buffercount]);
			   end;			
			
			end;		   

			
			
          {process keypress}
		  case j of
		  #0: if drawingphase=1 then
		       case readkey of
		       'H':if pointy>1 then dec(pointy);
               'P':if pointy<40 then inc(pointy);
               'K':if pointx>1 then dec(pointx);
               'M':if pointx<80 then inc(pointx);
			   end {0 case}
			   else {drawingphase=2}
		       case readkey of
		       'H':if (pointy>1) and (abs((pointy-1)-newy1)<=10) then dec(pointy);
               'P':if (pointy<40) and (abs((pointy+1)-newy1)<=10) then inc(pointy);
               'K':if (pointx>1) and (abs((pointx-1)-newx1)<=15) then dec(pointx);
               'M':if (pointx<80) and (abs((pointx+1)-newx1)<=15) then inc(pointx);
			   end; {0 case}	
		   #27:drawingphase:=27;	   
		   #32,#13: if drawingphase=1 then
		       begin
			     {user selected first corner}
				 drawingphase:=2;
                 say(12,182,5, ' SELECT OPPOSITE CORNER. ');
				 newx1:=pointx; newy1:=pointy;

			   end else
			   if (abs(pointx-newx1)>1) and (abs(pointy-newy1)>1) then
                begin
			     {user selected final corner}
                 drawingphase:=3;
				 
				 if pointx>newx1 then newx2:=pointx else
				  begin;newx2:=newx1;newx1:=pointx;end;
				  
				 if pointy>newy1 then newy2:=pointy else
				  begin;newy2:=newy1;newy1:=pointy;end;				  
				 
                end;			   
		    end; {case}
			

			
		until drawingphase>2;
		
        s:='';
        if drawingphase=3 then

         {sanity check: loop from x1+1 to x2-1,  etc, make sure there is no overlap}
	     for loopx:=newx1+1 to newx2-1 do
		  for loopy:=newy1+1 to newy2-1 do
		  
		   for buffercount:=region.rooms downto 1 do
		    if region.room.x1[buffercount]<>0 then

			  if (loopx<=region.room.x2[buffercount]) and
			   (loopx>=region.room.x1[buffercount]) and
			   (loopy<=region.room.y2[buffercount]) and
			   (loopy>=region.room.y1[buffercount])
			    then 
				 begin
 				  drawingphase:=4;
				 end; 
			 

		{if sanity check passed, create room}
		if drawingphase=3 then
		begin
		 if newroomnum>region.rooms then inc(region.rooms);
		 region.room.x1[newroomnum]:=newx1;
		 region.room.x2[newroomnum]:=newx2;
		 region.room.y1[newroomnum]:=newy1;
		 region.room.y2[newroomnum]:=newy2;		 
         region.room.name[newroomnum]:='NEW ROOM';		
		end; {create room}
		
		previewrooms;
		
		if drawingphase=4 then say(3,0,0,'COULD NOT ADD - TOO MUCH OVERLAP');
		
	   end; {available room check}
		
	   end; {'A'}
	   
	   
(*	   
   'A':begin
        sc2:=0;minpx:=1;minpy:=1;maxpx:=80;maxpy:=40;
        for sc1:=region.rooms downto 1 do
         if region.room.x1[sc1]=0 then sc2:=sc1;
        if sc2=0 then if region.rooms<16 then sc2:=region.rooms+1;
        if sc2>0 then
         begin
          s:='                                        ';
          say(2,173,0,s);say(2,182,0,s);say(2,191,0,s);
          say(12,182,5, ' SELECT TOP-LEFT CORNER. ');
          pointmode:=0;pointx:=40;pointy:=20;
           repeat
            say(65,191,0,strnum(pointx)+','+strnum(pointy)+'  ');
            takething(pointx-1,pointy*4);
            layobj:=thingtaken[1];
            if pointmode=1 then
             begin
			  say(50,191,0,strnum(pointx1)+','+strnum(pointy1)+'  ');
              if pointx1>pointx then
               begin;v1:=pointx;v2:=pointx1;end else
               begin;v1:=pointx1;v2:=pointx;end;
                for tbc:=v1 to v2 do
                 begin
                  takething(tbc-1,4*pointy);
                  takething_buffer[tbc-v1+1]:=thingtaken[1];
                  putthing(tbc-1,4*pointy,8);
                  if pointy<>pointy1 then
                  begin
                   takething(tbc-1,4*pointy1);
                   takething_buffer[tbc-v1+18]:=thingtaken[1];
                   putthing(tbc-1,4*pointy1,8);
                  end;
                 end;
              if pointy1>pointy then
               begin;v1:=pointy;v2:=pointy1;end else
               begin;v1:=pointy1;v2:=pointy;end;
                for tbc:=v1+1 to v2-1 do
                 begin
                  takething(pointx-1,tbc*4);
                  takething_buffer[tbc-v1+35]:=thingtaken[1];
                  putthing(pointx-1,tbc*4,8);
                  if pointx<>pointx1 then
                  begin
                   takething(pointx1-1,tbc*4);
                   takething_buffer[tbc-v1+47]:=thingtaken[1];
                   putthing(pointx1-1,tbc*4,8);
                  end;
                 end;
             end;


            putthing(pointx-1,pointy*4,15);
            j:=upcase_sync(readkey);
            putthing(pointx-1,pointy*4,layobj);

            if pointmode=1 then
             begin
              if pointx1>pointx then
               begin;v1:=pointx;v2:=pointx1;end else
               begin;v1:=pointx1;v2:=pointx;end;
                for tbc:=v1 to v2 do
                 begin
                  putthing(tbc-1,4*pointy,takething_buffer[tbc-v1+1]);
                  if pointy<>pointy1 then
                   putthing(tbc-1,4*pointy1,takething_buffer[tbc-v1+18]);
                 end;
              if pointy1>pointy then
               begin;v1:=pointy;v2:=pointy1;end else
               begin;v1:=pointy1;v2:=pointy;end;
                for tbc:=v1+1 to v2-1 do
                 begin
                  putthing(pointx-1,tbc*4,takething_buffer[tbc-v1+35]);
                  if pointx<>pointx1 then
                   putthing(pointx1-1,tbc*4,takething_buffer[tbc-v1+47]);
                 end;
             end;
            case j of
             #0:case readkey of
               #59:help;
               'H':if pointy>minpy then dec(pointy);
               'P':if pointy<maxpy then inc(pointy);
               'K':if pointx>minpx then dec(pointx);
               'M':if pointx<maxpx then inc(pointx);
               end;
             #27:begin;region.room.x1[sc2]:=0;pointmode:=27;end;
             #13,#32:begin
                      if pointmode=1 then
                       begin
                        pointmode:=100;
                        if pointx>pointx1 then
                         begin
                          region.room.x2[sc2]:=pointx;
                          region.room.x1[sc2]:=pointx1;
                          pointx:=pointx1;
                         end else begin
                          region.room.x2[sc2]:=pointx1;
                          region.room.x1[sc2]:=pointx;
                         end;
                        if pointy>pointy1 then
                         begin
                          region.room.y2[sc2]:=pointy;
                          region.room.y1[sc2]:=pointy1;
                          pointy:=pointy1;
                         end else begin
                          region.room.y2[sc2]:=pointy1;
                          region.room.y1[sc2]:=pointy;
                         end;
                        putthing(pointx-1,pointy*4,7);
                       end;
                      if pointmode=0 then
                       begin
                        region.room.x1[sc2]:=pointx;
                        pointx1:=pointx;
                        region.room.y1[sc2]:=pointy;
                        pointy1:=pointy;
                        putthing(pointx-1,pointy*4,7);
                      if (pointx-15)>1 then minpx:=pointx-15 else minpx:=1;
                      if (pointy-10)>1 then minpy:=pointy-10 else minpy:=1;
                      if (pointx+15)<80 then maxpx:=pointx+15 else maxpx:=80;
                      if (pointy+10)<40 then maxpy:=pointy+10 else maxpy:=40;
                        pointmode:=1;
                        say(12,182,5, 'SELECT BOTTOM-RIGHT CORNER. ');
                       end;
                      end;
            end; {case}
           until pointmode>10;
          if pointmode<>27 then
           begin
            for maxpx:=minpx+1 to pointx-1 do
             for maxpy:=minpy+1 to pointy-1 do
              begin
               takething(maxpx-1,maxpy);
               {if thingtaken[2]<>0 then pointmode:=27;}
              end;
             if (pointx<minpx) or (pointy<minpy) then pointmode:=27;
             end;
           if pointmode<>27 then
         begin
          if sc2>region.rooms then inc(region.rooms);
          region.room.name[sc2]:='NEW ROOM';
          {adds room onto end of list}
         end;
         end;
        previewrooms;
      end;
*)	  
	  
	  
	  
	  
   #27:done:=true;
  end;
  until done;
  end;
  savemap;
end;



procedure mapedit;
 var r:byte;
     rgf:file of regionrec;
     curredit:byte;
     sr:searchrec;
     openslot:byte;
     osc:byte;
begin
 curredit:=0;
 quittime:=false;
 repeat
 clearscreen;
  r:=0;openslot:=0;
  assign(rgf,ADVNAME+REGIONFILE);
  {$I-} reset(rgf); {$I+}
  if ioresult=0 then
   begin
    r:=filesize(rgf);
    for osc:=0 to r-1 do
     begin;read(rgf,region);if region.name='(DELETED)' then
      openslot:=osc+1;end;
    close(rgf);
   end;
 if openslot=0 then openslot:=r+1;
 say(1,2,6,' MAP EDITOR      ');
 say(4,15,1,'REGIONS: '+strnum(r));
 say(2,30,5,' A Û0: ADD REGION');
 say(2,42,5,' E Û0: EDIT REGION');
 say(2,54,5,' D Û0: DELETE REGION');
 say(2,66,5,' C Û0: CURRENTLY EDITING:');
  if curredit=0 then
   say(49,66,1,'DEFAULT MAPS') else
   say(49,66,2,'IN-PLAY MAPS');
 say(2,100,5,'F10Û0: EXIT');
 say(2,78,5,' X Û0: EXPORT REGIONS.TXT');
 case upcase_sync(readkey) of
  #0:case readkey of
    #59:help;
    #68:quittime:=true;
    end;
  'A':addregion(openslot);
  'E':editregion(r);
  'D':deleteregion(r);
  'X':regionreports(r);
  'C':if curredit=0 then
           begin
            findfirst(ADVNAME+PLAYMASTERFILE,anyfile,sr);
            if doserror=0 then begin
              MASTERFILE:=PLAYMASTERFILE;
              MAPAFILE:='.X';
              MAPBFILE:='.Y';
              MAPCFILE:='.Z';
              REGIONFILE:='.RGX';
              curredit:=2;
             end;
            end else
            begin
              MASTERFILE:='.MST';
              MAPAFILE:='.A';
              MAPBFILE:='.B';
              MAPCFILE:='.C';
              REGIONFILE:='.RGN';
              curredit:=0;
            end;


 end;
 until quittime;
end;


{$I PTR_PORT.PAS}

var ss,systemdir:string[60];
    gd:integer;

procedure loadconfig;
var ackf:file of masterrec;
begin
 assign(ackf,ADVNAME+MASTERFILE);
 {$I-} reset(ackf); {$I+}
 if ioresult<>0 then begin;ADVNAME:='NONAME';chdir(systemdir);exit;end;
 read(ackf,ack);
 close(ackf);

end;


{$F+}
function detectvga256d:integer;
begin
 detectvga256d:=0;
end;
{$F-}




begin
 for i:=1 to 4 do layobj[i]:=0;
 getmem(rmcnt, 6400);
 getmem(locnt, LOCNTMAX * sizeof(loccontrec));
 getmem(obj, (MAXOBJS+2) * sizeof(objectrec));obj^[0].d[1]:=0;
 getmem(talk, 1001 * sizeof (talkrec) );
 getmem(graphic2, (GRAPS+1)*256 ); 
 getmem(wander_index, (WANDERMAX+1) * sizeof(wander_record));
 getmem(rcrc, (RCMAX+1) * sizeof(rregioncreature)); 
 i:=0;
  obj^[i+255].t:=3;
 getmem(crc, MAXCRCS * sizeof(creaturerec));
 if copy(paramstr(4),1,2)<>'CH' then
  begin;writeln('ACK v',(ACKVERSION DIV 10),'.',
   (ACKVERSION MOD 10),' program file.');
   for i:=0 to paramcount do writeln(paramstr(i));writeln;readln;halt;end;
 usepointers;
 ss:=paramstr(1);
 i:=pos('*',ss);
 ADVNAME:=copy(ss,i+1,length(ss)-i);
 systemdir:=copy(ss,2,i-2);
 bgi_dir:=systemdir;
{ gd:=installuserdriver('SVGA256',@detectvga256d);
 gd:=graphresult;
 if gd<>grok then begin;writeln('Def:'+grapherrormsg(gd));readln;halt;end;
 }

 helpfile:=systemdir+'\ACKDATA1.HLP';
 if not loadobjs then halt;
 creatureok:=loadcreatures;
 graphicsmode;
 initmouse;
 helpindex:=9;
 loadconfig;
 loadmapcolors;
 loadgraps2(true); 
 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
  blank0(ack.darkbackground);
{ assign(printer,'PRN');
 rewrite(printer);}
 closemouse;
 pausemouse:=true;

 MapEdit;
 shutdownsound;
end.