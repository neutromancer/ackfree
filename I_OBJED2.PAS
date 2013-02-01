
procedure obj_filldata(objnum:byte);
 var s:string[15];
 w:word;
function objnam(n:byte):string;
 var s:string;
begin
 s:='#'+strnum(n)+' '+obj^[n].n+'      ';
 s:=copy(s,1,9);
 objnam:=s;
end;

begin
  say(32,38,1,obj^[objnum].n+' ');
  say(72,2,4,'#'+strnum(objnum));
  putthing(1,4,mapcolors[objnum]);  putthing(2,4,mapcolors[objnum]);

 case obj^[objnum].t of
 1,2:with obj^[objnum] do begin
     if d[4]>127 then
       say(21,13,0,'OPAQUE     ') else say(21,13,1,'TRANSPARENT');
     if (d[4] AND 64)=64 then say(71,13,0,'YES') else say(71,13,1,'NO ');


     if d[1]<241 then 
	  begin
	   putgrap(32,22,d[1]);
	   if d[6]<>0 then putgrap2(48,22,d[6]) else putgrap(48,22,0);
      end else say(32,22,0,'SET ON EACH USE');

     {if d[6]=d[1] then say(38,20,0,'<');}
     case d[13] of
      0:say(66,22,0,'ICON');
      1..240:putgrap(66,22,d[13]);
      255:begin;if d[1]<>255 then putgrap(66,22,d[1]);say(66,23,0,'<');end;
      end;
     say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3], ((d[1]=255) OR (t=1)) ));
     say(42,65,1,strtrigger(d[9]));
     say(42,74,1,strtriggerp(d[9],d[10]));
     say(40,84,1,strpassable(d[4]));
     say(40,93,1,strpassablep(d[4],d[5]));
 {    if d[6]<>0 then say(51,101,1,concat('#',strnum(d[6]),'  '))
      else say(51,101,1,'NONE');
     display pass message }
     if d[7]<>0 then say(53,115,1,concat('#',strnum(d[7]),'  '))
      else say(53,115,1,'NONE');
     {display blocked message}
     if d[14]<>0 then say(55,130,1,concat('#',strnum(d[14]),'  '))
      else say(55,130,1,'NONE');
     {display examine message}
     say(36,151,1,strdisappear(d[8]));
     if d[11]=0 then
      say(56,161,1,'N/A') else
      say(56,161,1,concat(strnum(d[11]),'  '));
     say(70,169,0,'  ');
     if d[12]=0 then
      say(32,169,1,'(ELIMINATE)          ') else
      say(32,169,1,concat('#',strnum(d[12]),' ',obj^[d[12]].n));
    end; {with}
  3,4:with obj^[objnum] do begin
     if d[4]>127 then
       say(21,13,0,'OPAQUE     ') else say(21,13,1,'TRANSPARENT');
     if (d[4] AND 64)=64 then say(71,13,0,'YES') else say(71,13,1,'NO ');
     if d[1]<241 then 
	  begin
	   putgrap(32,22,d[1]);
	   if d[6]<>0 then putgrap2(48,22,d[6]) else putgrap(48,22,0);
      end else say(32,22,0,'SET ON EACH USE');	 
     {if d[6]=d[1] then say(38,20,0,'<');}
     say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3], ((d[1]=255) OR (t=3)) ));
     say(42,65,1,strtrigger(d[9]));
     say(42,74,1,strtriggerp(d[9],d[10]));
     if d[7]<>0 then say(53,106,1,concat('#',strnum(d[7]),'  '))
      else say(53,106,1,'NONE');
     {display blocked message}
     if d[14]<>0 then say(55,126,1,concat('#',strnum(d[14]),'  '))
      else say(55,126,1,'NONE');
     {display examine message}
     say(36,148,1,strdisappear(d[8]));
     if d[11]=0 then
      say(56,158,1,'N/A') else
      say(56,158,1,concat(strnum(d[11]),'  '));
     say(70,166,0,'  ');
     if d[12]=0 then
      say(32,166,1,'(ELIMINATE)          ') else
      say(32,166,1,concat('#',strnum(d[12]),' ',obj^[d[12]].n));
     end; {with}
   5:with obj^[objnum] do begin
      if d[4]>127 then
       say(21,13,0,'OPAQUE     ') else say(21,13,1,'TRANSPARENT');
     if (d[4] AND 64)=64 then say(71,13,0,'YES') else say(71,13,1,'NO ');
     putgrap(32,22,d[1]);
     if d[6]<>0 then putgrap2(48,22,d[6]) else putgrap(48,22,0);
     {if d[6]=d[1] then say(38,20,0,'<');}
     if d[6]=d[1] then say(46,20,0,'<');
     say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3],true));
     say(42,65,1,strtrigger(d[9]));
     say(42,74,1,strtriggerp(d[9],d[10]));
     say(40,84,1,strpassable(d[4]));
     say(40,93,1,strpassablep(d[4],d[5]));
     if d[13]<>0 then say(51,101,1,concat('#',strnum(d[13]),'  '))
      else say(51,101,1,'NONE');
     {display pass message}
     if d[7]<>0 then say(53,115,1,concat('#',strnum(d[7]),'  '))
      else say(53,115,1,'NONE');
     {display blocked message}
     if d[14]<>0 then say(55,130,1,concat('#',strnum(d[14]),'  '))
      else say(55,130,1,'NONE');
     {display examine message}
     say(36,151,1,strdisappear(d[8]));
     if d[11]=0 then
      say(56,161,1,'N/A') else
      say(56,161,1,concat(strnum(d[11]),'  '));
     say(70,169,0,'  ');
     if d[12]=0 then
      say(32,169,1,'(ELIMINATE)          ') else
      say(32,169,1,concat('#',strnum(d[12]),' ',obj^[d[12]].n));
    end; {with}
   6:with obj^[objnum] do begin
     putgrap(32,22,d[1]);
     say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3],true));
     if d[4]<>0 then say(42,65,1,objnam(d[4])) else
      if d[4]<>255 then say(42,65,1,'NOTHING') else
       say(42,65,1,'ENERGY:');
     if d[4]=255 then
      say(42,74,1,strnum(d[5])+' M.P.     ') else
      if d[4]<>0 then
       say(42,74,1,concat(strnum(d[5]),'%    '))
       else say(42,74,0,'    ');
     if d[7]<>0 then say(50,84,1,concat('#',strnum(d[7]),'  '))
      else say(50,84,1,'NONE');
     {display used message}
     if d[8]<>0 then say(61,98,1,concat('#',strnum(d[8]),'  '))
      else say(61,98,1,'NONE');
     {display out of fuel message}
     if d[14]<>0 then say(55,113,1,concat('#',strnum(d[14]),'  '))
      else say(55,113,1,'NONE');
     {display examine message}
     if d[6]<>0 then say(36,134,1,'YES') else say(36,134,1,'NO ');
     w:=(d[9]*256)+d[10];
	 if w>30000 then say(30,144,1,'NO DROP')
	  else say(30,144,1,strnum( w ));
     say(30,154,1,strnum( (d[11]*256)+d[12] ));
    end;
   7:with obj^[objnum] do begin
     putgrap(32,22,d[1]);
     case d[13] of
      0:say(48,22,0,'ICON');
      1..240:putgrap(48,22,d[13]);
      255:begin;if d[1]<>255 then putgrap(48,22,d[1]);say(48,23,0,'<');end;
      end;

   {  say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3],true));
     if d[5]<>0 then say(50,65,1,concat('#',strnum(d[5]),'  '))
      else say(50,65,1,'NONE'); }

     if d[14]<>0 then say(55,77,1,concat('#',strnum(d[14]),'  '))
      else say(55,77,1,'NONE');
     {display examine message}
     say(40,91,1,strnum(d[4]));
     say(42,120,1,soundname(d[2]));

	 
     w:=(d[9]*256)+d[10];
	 if w>30000 then say(30,101,1,'NO DROP')
	  else say(30,101,1,strnum( w ));	 
	 
     say(30,111,1,strnum( (d[11]*256)+d[12] ));
    end;
   8:with obj^[objnum] do begin
     putgrap(32,22,d[1]);
     case d[13] of
      0:say(48,22,0,'ICON');
      1..240:putgrap(48,22,d[13]);
      255:begin;if d[1]<>255 then putgrap(48,22,d[1]);say(48,23,0,'<');end;
      end;
     if d[6]=255 then say(40,48,1,'ENERGY:') else
      if d[6]<>0 then say(40,48,1,objnam(d[6])) else
       say(40,48,1,'NOTHING');
     if d[6]=255 then
      say(40,57,1,strnum(d[7])+' M.P.     ') else
      if d[6]<>0 then
       say(40,57,1,concat(strnum(d[7]),'%    '))
       else say(40,57,0,'    ');
     if d[8]<>0 then say(61,65,1,concat('#',strnum(d[8]),'  '))
      else say(61,65,1,'NONE');
     {display out of ammo message}
     if d[14]<>0 then say(55,77,1,concat('#',strnum(d[14]),'  '))
      else say(55,77,1,'NONE');
     {display examine message}
     say(40,91,1,strnum(d[4]));
     say(28,101,1,strnum(lonyb(d[5])+1));
     say(28,110,1,strblastradius(hinyb(d[5])));
     case d[3] of
      0:say(26,128,1,'NONE');
      1..240:putgrap(26,128,d[3]);
      241:say(26,128,1,'DOT');
      242:say(26,128,1,'LINE');
      243:say(26,128,1,'BALL');
      244:say(26,128,1,'BEAM');
     end;
     say(42,120,1,soundname(d[2]));
	 
     w:=(d[9]*256)+d[10];
	 if w>30000 then say(30,148,1,'NO DROP')
	  else say(30,148,1,strnum( w ));	 
	 
     say(30,158,1,strnum( (d[11]*256)+d[12] ));
    end;
   9:with obj^[objnum] do begin
     if d[2]=1 then
       case d[13] of
        0:say(48,22,0,'ICON');
        1..240:putgrap(48,22,d[13]);
        255:begin;if d[1]<>255 then putgrap(48,22,d[1]);say(48,23,0,'<');
            end;
       end;
     putgrap(32,22,d[1]);
     say(38,48,1,'AREA '+strnum(d[2]));
     say(46,57,1,strnum(d[6])+'%   ');
     {if d[4]<>0 then say(48,68,1,objnam(d[4])) else say(48,68,1,'NONE');}
     say(48,78,1,strnum(d[5]));
	 
     w:=(d[9]*256)+d[10];
	 if w>30000 then say(30,88,1,'NO DROP')
	  else say(30,88,1,strnum( w ));	 
	 
     say(30,98,1,strnum( (d[11]*256)+d[12] ));
     if d[14]<>0 then say(55,108,1,concat('#',strnum(d[14]),'  '))
      else say(55,108,1,'NONE');
     {display examine message}
    end;
   10:with obj^[objnum] do begin
     putgrap(32,22,d[1]);
     case d[13] of
      0:say(48,22,0,'ICON');
      1..240:putgrap(48,22,d[13]);
      255:begin;if d[1]<>255 then putgrap(48,22,d[1]);say(48,23,0,'<');end;
      end;
     if d[4]<>0 then say(48,48,1,objnam(d[4])) else say(48,48,1,'NONE');
     if d[2]<>0 then say(36,58,1,objnam(d[2])) else say(36,58,1,'ITSELF');
     if d[3]=0 then say(36,67,1,'WHERE USER CAN')
      else say(36,67,1,'ONLY WHERE NEEDED');
{     say(52,77,1,strnum(d[5]));}
     if d[6]<>0 then say(40,87,1,objnam(d[6])) else
      if d[6]<>255 then say(40,87,1,'NOTHING') else
       say(40,87,1,'ENERGY:');
     if d[6]=255 then
      say(40,96,1,strnum(d[7])+' M.P.     ') else
      if d[6]<>0 then
       say(40,96,1,concat(strnum(d[7]),'%    '))
       else say(40,96,0,'    ');
     if d[11]<>0 then say(55,119,1,concat('#',strnum(d[11]),'  '))
      else say(55,119,1,'NONE');
     {display boarding message}
     if d[8]<>0 then say(61,104,1,concat('#',strnum(d[8]),'  '))
      else say(61,104,1,'NONE');
     {display out of fuel message}
     if d[14]<>0 then say(55,132,1,concat('#',strnum(d[14]),'  '))
      else say(55,132,1,'NONE');
     {display examine message}
	 
	 
     say(46,141,1,strnum( (d[9]*256)+d[10] ));



     if d[5]=0 then say(41,151,1,'NONE   ') else say(41,151,1,strnum(d[5])+'   ');
     if d[12]=0 then say(33,161,1,'NONE   ') else say(33,161,1,strnum(d[12])+'   ');


    end;
  11:with obj^[objnum] do begin
     say(30,48,1,straction(d[2]));
     say(30,57,1,stractionp(d[2],d[3],true));

     say(30,67,1,straction(d[9]));
     say(30,76,1,stractionp(d[9],d[10],true));


     if d[4]<>0 then say(42,85,1,objnam(d[4])) else say(42,85,1,'NOTHING');
     if d[4]<>0 then say(42,94,1,strnum(d[5])+'%  ')
       else say(42,94,0,'    ');

     if d[7]<>0 then say(50,104,1,concat('#',strnum(d[7]),'  '))
      else say(50,104,1,'NONE');
     {display used message}
     if d[8]<>0 then say(61,128,1,concat('#',strnum(d[8]),'  '))
      else say(61,128,1,'NONE');
     {display out of fuel message}
     if d[6]<>0 then say(36,154,1,'YES') else say(36,154,1,'NO ');
     say(50,164,1,strnum(d[11]));
    end;
  12:with obj^[objnum] do begin
     putgrap(32,22,d[1]);
     say(30,48,1,strnum( (d[9]*256)+d[10] ));
     if d[14]<>0 then say(55,68,1,concat('#',strnum(d[14]),'  '))
      else say(55,68,1,'NONE');
     {display examine message}
    end;
  else begin end;
  end; {case}
end; {procedure}


procedure obj_blowupobj(objnum:byte);
begin
 clearscreen;
 drawh(0,181,319,3);
 say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
 say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
 case obj^[objnum].t of
  1,2:begin  {space}
     if obj^[objnum].t=1 then
     say(0,2,6,    '    EDIT TERRAIN (PRESET SPACE)         ') else
     say(0,2,6,    '    EDIT TERRAIN (CUSTOM SPACE)         ');
     say(1,13,5,  'V€0IEW-THRU:             €5L€0IGHTSOURCE:');
     say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:     €5 I €0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ACTION:  €5 A €0:');
     say(15,57,0,        '  €5ÉÑA€0:');
     say(1,65,0,  'TRIGGERED BY:  €5 T €0:');
     say(1,74,0,  '               €5ÉÑT€0:');
     say(1,84,0,  'PASSABLE TO:  €5 P €0:');
     say(1,93,0,  '              €5ÉÑP€0:');
     say(1,115,0, 'MESSAGE WHEN BLOCKED: €5 B ');
     say(1,130,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,151,0, 'DISAPPEAR?  €5 D €0:');
     say(1,161,0, 'STRUCTURAL STRENGTH:  €5 S €0:');
     say(1,169,0, 'REPLACED: €5 R €0:');
    end;
  3,4:begin {obstacle}
     if obj^[objnum].t=3 then
     say(0,2,6,    '    EDIT TERRAIN (PRESET OBSTACLE)      ') else
     say(0,2,6,    '    EDIT TERRAIN (CUSTOM OBSTACLE)      ');
     say(1,13,5,  'V€0IEW-THRU:             €5L€0IGHTSOURCE:');
     say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ACTION:  €5 A €0:');
     say(15,57,0,        '  €5ÉÑA€0:');
     say(1,65,0,  'TRIGGERED BY:  €5 T €0:');
     say(1,74,0,  '               €5ÉÑT€0:');
     say(1,84,0,  'PASSABLE TO: NOTHING.');
     say(1,106,0, 'MESSAGE WHEN BLOCKED: €5 B ');
     say(1,126,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,148,0, 'DISAPPEAR?  €5 D €0:');
     say(1,158,0, 'STRUCTURAL STRENGTH:  €5 S €0:');
     say(1,166,0, 'REPLACED: €5 R €0:');
   end;
   5:begin {portal}
     say(1,13,5,  'V€0IEW-THRU:             €5L€0IGHTSOURCE:');
     say(0,2,6,    '    EDIT TERRAIN (PORTAL)               ');
     say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ACTION:  €5 A €0:');
     say(15,57,0,        '  €5ÉÑA€0:');
     say(1,65,0,  'TRIGGERED BY:  €5 T €0:');
     say(1,74,0,  '               €5ÉÑT€0:');
     say(1,84,0,  'PASSABLE TO:  €5 P €0:');
     say(1,93,0,  '              €5ÉÑP€0:');
     say(1,101,0,  'MESSAGE WHEN PASSED: €5 M ');
     say(1,115,0, 'MESSAGE WHEN BLOCKED: €5 B ');
     say(1,130,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,151,0, 'DISAPPEAR?  €5 D €0:');
     say(1,161,0, 'STRUCTURAL STRENGTH:  €5 S €0:');
     say(1,169,0, 'REPLACED: €5 R €0:');
   end;
  6:begin {misc item}
     say(0,2,6,    '    EDIT ITEM (MISC.)                   ');
     say(1,22,0,   'GRAPHIC:   €5 G €0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ACTION:  €5 A €0:');
     say(15,57,0,        '  €5ÉÑA€0:');
     say(1,65,0,  'USAGE REQUIRES €5 R €0:');
     say(1,74,0,  '%CONSUMED      €5ÉÑR€0:');
     say(1,84,0,  'MESSAGE WHEN USED: €5 M ');
     say(1,98,0,  'MESSAGE WHEN INOPERATIVE: €5 I ');
     say(1,113,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,134,0, 'DISAPPEAR?  €5 D €0:');
     say(1,144,0, 'WEIGHT:  €5 W €0:');
     say(1,154,0, 'PRICE:   €5 P €0:');
    end;
  7:begin {melee weap}
     say(0,2,6,    '    EDIT ITEM (WEAPON)                  ');
     say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:'); {2nd is player-using grp}
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,77,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,91,0,  'MAX. DAMAGE:  €5 D €0:');
     say(1,101,0, 'WEIGHT:  €5 W €0:');
     say(1,111,0, 'PRICE:   €5 P €0:');
     say(1,120,0,  'SOUND EFFECT:  €5 S €0:'); 
   end;
  8:begin {missile weap}
     say(0,2,6,    '    EDIT ITEM (RANGED WEAPON)           ');
     say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'AMMO REQUIRED  €5 A €0:');
     say(1,57,0,  '%CONSUMED      €5ÉÑA€0:');
     say(1,65,0,  'MESSAGE WHEN OUT OF AMMO: €5 M ');
     say(1,77,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,91,0,  'MAX. DAMAGE:  €5 D €0:');
     say(1,101,0,  'RANGE:  €5 R €0:');
     say(1,110,0, '        €5ÉÑR€0:');
     say(1,120,0,  'SOUND EFFECT:  €5 S €0:');
     say(1,128,0,  'ICON:  €5 I €0:');  {sound and icon are same byte}
     say(1,148,0, 'WEIGHT:  €5 W €0:');
     say(1,158,0, 'PRICE:   €5 P €0:');
   end;
  9:begin {armor}
     say(0,2,6,    '    EDIT ITEM (ARMOR)                   ');
     if obj^[objnum].d[2]=1 then
      say(1,22,0,  'GRAPHIC:   €5 G €0:    €5ÉÑG€0:') else
       say(1,22,0,   'GRAPHIC:   €5 G €0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ARMOR TYPE:  €5 T €0:'); {0..255 i.e. bodyarmor,shield,etc}
     say(1,58,0,  'ARMOR COVERAGE:  €5 C €0:');
 {    say(1,68,0,  'BUILT-IN WEAPON:  €5 I €0:'); }
     say(1,78,0,  'DAMAGE ABSORBED:  €5 D €0:');
     say(1,88,0, 'WEIGHT:  €5 W €0:');
     say(1,98,0, 'PRICE:   €5 P €0:');
     say(1,108,0, 'MESSAGE WHEN EXAMINED: €5 X ');
   end;
 10:begin {vehicle}
     say(0,2,6,    '    EDIT ITEM (VEHICLE)                 ');
     say(1,22,0,   'GRAPHIC:   €5 G €0:    €5ÉÑG€0:');  {<same as 1st graphic}
     say(1,38,0,  'NAME:      €5 N €0:');              {select new graphic }
     say(1,48,0,  'BUILT-IN WEAPON:  €5 I €0:');
     say(1,58,0,  'COUNTS AS:  €5 C €0:');
     say(1,67,0,  '   CAN GO:  €5ÉÑC€0:');
     {say(1,77,0,  'MOVEMENT SPEED IS:  €5 S €0:');}
     say(1,87,0,  'FUEL REQUIRED  €5 F €0:');
     say(1,96,0,  '%CONSUMED      €5ÉÑF€0:');
     say(1,104,0,  'MESSAGE WHEN OUT OF FUEL: €5 M ');
     say(1,119,0, 'MESSAGE WHEN BOARDING: €5 B ');
     say(1,132,0, 'MESSAGE WHEN EXAMINED: €5 X ');
     say(1,141,0, 'WEIGHT CAPACITY:  €5 W €0:');
     say(1,151,5,'ÉÑB€0 BOARDING MACRO: ');
     say(1,161,5,'ÉÑX€0 EXIT MACRO: ');
   end;
 11:begin {spell}
     say(0,2,6,    '    EDIT ITEM (SPELL/SKILL)             ');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0,  'ACTION:  €5 A €0:');
     say(15,57,0,        '  €5ÉÑA€0:');
     say(1,67,0,  'ACTION2: €5 2 €0:');
     say(15,76,0,        '  €5ÉÑ2€0:');
     say(1,85,0,  'USAGE REQUIRES €5 R €0:');
     say(1,94,0,  '%CONSUMED      €5ÉÑR€0:');
     say(1,104,0,  'MESSAGE WHEN USED: €5 M ');
     say(1,128,0,  'MESSAGE WHEN OUT OF ITEM: €5 I ');
     say(1,154,0, 'DISAPPEAR?  €5 D €0:');
     say(1,164,0,  'MAGIC POINTS USED: €5 P €0:');
   end;
 12:begin  {currency}
     say(0,2,6,    '    EDIT ITEM (CURRENCY)                ');
     say(1,22,0,   'GRAPHIC:   €5 G €0:');
     say(1,38,0,  'NAME:      €5 N €0:');
     say(1,48,0, 'WEIGHT:  €5 W €0:');
     say(1,68,0, 'MESSAGE WHEN EXAMINED: €5 X ');
    end;
 end; {objtype case}
end; {procedure}