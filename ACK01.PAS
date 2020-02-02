{ AckFinder, ConfigEdit}


{$m 32000,64000,264000}
uses u_io,u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_help,u_sound;

{$I I_MSTREC.PAS}
 {$I I_SNDEFF.PAS}

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
	mapcolors:array[0..255] of byte;

function upcase_sync(r: char): char;  forward;

function version(v:byte):ittystring;
var s:ittystring;
begin
 s:='V'+strnum(v DIV 10)+'.'+strnum(v MOD 10);
 version:=s;
end;


procedure loadcreatures;
var cf:file of creaturerec;
    i:byte;
begin
 assign(cf,ADVNAME+CREATUREFILE);
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to 64 do read(cf,crc^[i]);
  if not eof(cf) then
    for i:=65 to MAXCRCS do read(cf,crc^[i])
   else
    begin
	 for i:=65 to MAXCRCS do crc^[i].t:=0;
	end;
 close(cf);
end;



{$I I_MAPED2.PAS}
(*
procedure mixpalette;
 var
  j:char;
  done:boolean;
  i1,i2,i3,i4:byte;
  thiscolor,thisplane:byte;
{ procedure refreshcolors;
  var c:byte;
   begin
    with ack do for c:=5 to 10 do
     setrgbpalette(245+c,phasecolors[c,1],phasecolors[c,2],phasecolors[c,3]);
   end; }
begin
 helpindex:=57;
 clearscreen;
{ refreshcolors;  }
 for i1:=0 to 2 do for i2:=0 to 1 do
  for i3:=2 to 7 do for i4:=4 to 7 do
    begin
     putthing( i1*16+i3+4, i2*40+i4*4+20, 250+i2*3+i1 );
     say( i1*16+6, i2*40+27, 1, strnum(250+i2*3+i1) );
    end;
 done:=false;
 thiscolor:=5;thisplane:=1;
 say(40,158,4,'ESCÛ1 TO EXIT');
 repeat
  setrgbpalette(245+thiscolor,ack.phasecolors[thiscolor,1],
    ack.phasecolors[thiscolor,2],ack.phasecolors[thiscolor,3]);
  say(5,158,5,' - Û1 #'+strnum(thiscolor+245)+' Û5 + ');
  say(1,170,0,'  R  ');
  say(1,180,0,'  G  ');
  say(1,190,0,'  B  ');
  say(2,160+10*thisplane,4,'<');
  say(8,160+10*thisplane,4,'>');
  drawh(58,173,58+63,18);
  if ack.phasecolors[thiscolor,1]<>0 then
   drawh(58,173,58+ack.phasecolors[thiscolor,1],12);
  drawh(58,183,58+63,18);
  if ack.phasecolors[thiscolor,2]<>0 then
   drawh(58,183,58+ack.phasecolors[thiscolor,2],10);
  drawh(58,193,58+63,18);
  if ack.phasecolors[thiscolor,3]<>0 then
   drawh(58,193,58+ack.phasecolors[thiscolor,3],9);
  case upcase_sync(readkey) of
   '+':if thiscolor<10 then inc(thiscolor);
   '-':if thiscolor>5 then dec(thiscolor);
   #0:case readkey of
    #59:help;
    #71,#73:ack.phasecolors[thiscolor,thisplane]:=0;
    #72:if thisplane>1 then dec(thisplane);
    #75:if ack.phasecolors[thiscolor,thisplane]>0 then
       dec(ack.phasecolors[thiscolor,thisplane]);
    #77:if ack.phasecolors[thiscolor,thisplane]<63 then
       inc(ack.phasecolors[thiscolor,thisplane]);
    #79,#81:ack.phasecolors[thiscolor,thisplane]:=63;
    #80:if thisplane<3 then inc(thisplane);
   end;
  #27:done:=true;
  end; {case}
 until done;
 helpindex:=35;
end;
*)

{$I I_ACK01.PAS}

{$I I_SNDNAM.PAS}


procedure ScreenSetup(page:byte);

function no(w:word):string;
var s:string;
begin
 if w=0 then s:='NO ' else s:=strnum(w)+' ';
 no:=s;
end;

function noobjnam(b:byte):string;
begin
 if b=0 then noobjnam:='NONE' else noobjnam:=objnam(b);
end;

function noname(n:string):string;
begin
 if n='PROMPT' then noname:='(ASK PLAYER)' else noname:=n;
end;
 var level:byte;
 var s:string;
   begin
     clearscreen;
     drawh(0,181,319,3);
     say(1,183,0,'Û5‡UpÛ0 Û5‡DnÛ0: SELECT PAGE (1-5)  Û5FÛ0: EXIT');
     say(1,191,0,'                                       ');
     {getdir(0,s);say(1,10,0,s+'\ '+ADVNAME);}
     {drawh(0,18,319,3);}
     case page of
      1:begin
       { say(0,2,6,   ' ADVENTURE CREATION KIT - CONFIGURATION '); }

         say(0,2,6,   ' PAGE 1: GAME BASICS.  INFO ON THIS PAGE');
         say(0,10,6,  ' DETERMINES HOW YOUR ADVENTURE STARTS.  ');



         say(1,28,5,'TITLE SEQUENCE (RUNS EVERY TIME)       ');
         say(2,38,5,  '1 Û0PICTURE:Û1'+no(ack.titlepic)+'Û52 Û0MESSAGE:Û1'+
           no(ack.titlemsg)+'Û53 Û0MACRO:Û1'+no(ack.titlemacro));

         say(1,58,5,'INTRO SEQUENCE (RUNS FOR NEW PLAYER)   ');
         say(2,68,5,  '4 Û0PICTURE:Û1'+no(ack.intropic)+'Û55 Û0MESSAGE:Û1'+
           no(ack.intromsg)+'Û56 Û0MACRO:Û1'+no(ack.intromacro));

         say(1,88,5,'PLAYER STARTING INFORMATION            ');
         say(2,98,5,' I Û0 ITEMS AND WEAPONS...');
         say(2,108,5,' M Û0 MONEY: Û1'+strnum(ack.pcash));
         say(2,118,5,' V Û0 VEHICLE: Û1'+noobjnam(ack.plvehicle));
         if ack.playername='UNUSED' then ack.playername:='';
         if ack.playername='ASK' then ack.playername:='PROMPT';
         if ack.playername='(ASK PLAYER)' then ack.playername:='PROMPT';
         say(2,128,5,' N Û0 NAME: Û1'+noname(ack.playername));
         s:=strnum(ack.minute);if length(s)=1 then s:='0'+s;
         s:=strnum(ack.hour)+':'+s;
         say(2,138,5,' T Û0 TIME: Û1'+s+' (24HR TIME)');
         say(2,148,5, ' L Û0 STARTING LOCATION:');
         with ack do begin
         if plregion=0 then s:='         ...NOT SET YET!' else
          begin
           if plych=255 then s:='        ' else s:='';
           s:=s+'REGION '+strnum(plregion);
           if PLych=255 then
            begin
             s:=s+', ROOM '+strnum(plxch);
             s:=s+', AT ('+strnum(plxloc)+','+strnum(plyloc)+')';
            end else
            begin
             s:=s+', AT ('+strnum((plxch-1)*16+plxloc)+
                      ','+strnum((plych-1)*16+plyloc)+')';
            end;
          end;
         end;
         say(6,158,1,'...'+s);

        end;
      2:begin

         say(0,2,6,   ' PAGE 2: PLAYER DATA.  INFO ON THIS PAGE');
         say(0,10,6,  ' DETERMINES STARTING ABILITY SCORES.    ');



        if ack.copytype<2 then begin
         say(1,191,0,  'SELECT SETS 1-3, TOGGLE ON/OFF WITH [T]');
         say(3,30,0,  '#1: Û5 N Û0AME:');
         say(61,30,6,' G Û0:');
         say(3,39,5,  ' H Û0P:      Û5ƒ„HÛ0P:      Û5 S Û0TR:');
         say(3,48,5,  ' M Û0P:      Û5ƒ„MÛ0P:      Û5 I Û0NT:');
         say(3,57,5,  ' W Û0P.SK:      Û5 R Û0W.SK:');
         say(3,66,5,  ' A Û0:     Û5 B Û0:     Û5 C Û0:     Û5 D Û0:    ');
     drawh(0,76,319,3);
         say(3,78,0,  '#2: Û5 N Û0AME:');
         say(61,78,6,' G Û0:');
         say(3,87,5,  ' H Û0P:      Û5ƒ„HÛ0P:      Û5 S Û0TR:');
         say(3,96,5,  ' M Û0P:      Û5ƒ„MÛ0P:      Û5 I Û0NT:');
         say(3,105,5,  ' W Û0P.SK:      Û5 R Û0W.SK:');
         say(3,114,5, ' A Û0:     Û5 B Û0:     Û5 C Û0:     Û5 D Û0:    ');
     drawh(0,124,319,3);
         say(3,126,0, '#3: Û5 N Û0AME:');
         say(61,126,6,' G Û0:');
         say(3,135,5, ' H Û0P:      Û5ƒ„HÛ0P:      Û5 S Û0TR:');
         say(3,144,5, ' M Û0P:      Û5ƒ„MÛ0P:      Û5 I Û0NT:');
         say(3,153,5, ' W Û0P.SK:      Û5 R Û0W.SK:');
         say(3,162,5, ' A Û0:     Û5 B Û0:     Û5 C Û0:     Û5 D Û0:    ');
         if pgsub=0 then pgsub:=1;
         case pgsub of
          1:say(3,30,6,'#1:');
          2:say(3,78,6,'#2:');
          3:say(3,126,6,'#3:');
         end;

        end {new player}
        else
        begin
         say(5,35,0,'EDITING SAVED GAME!');
         pgsub:=0;
     drawh(0,85,319,3);
         say(61,78,6,' G Û0:');
         say(3,87,5,  ' H Û0P:      Û5ƒ„HÛ0P:      Û5 S Û0TR:');
         say(3,96,5,  ' M Û0P:      Û5ƒ„MÛ0P:      Û5 I Û0NT:');
         say(3,105,5,  ' W Û0P.SK:      Û5 R Û0W.SK:');
         say(3,114,5, ' A Û0:     Û5 B Û0:     Û5 C Û0:     Û5 D Û0:    ');
     drawh(0,124,319,3);
        end; {game in progress}



        end;
      3:begin
         say(0,2,6,   ' PAGE 3: LEVEL SETUP.  INFO ON THIS PAGE');
         say(0,10,6,  ' DETERMINES HOW EXP AND LEVELS ARE USED.');

         if ack.ackversion>24 then
         begin
          say(0,38,0,  '       LEVEL       EXP      MACRO');
          for level:=2 to 10 do
          begin
           say(3,28+(level*10),5,' '+strnum(level MOD 10)+' ');
           say(18,28+(level*10),level MOD 2,strnum(level));
           say(36,28+(level*10),level MOD 2,strnum(ack.levelexp[level]));
           say(58,28+(level*10),level MOD 2,strnum(ack.levelmacro[level]));
          end;
         end else
         begin
          say(6,70,0,  'LEVELS AND EXPERIENCE CAN ONLY BE');
          say(6,80,0,  'USED IN AN ADVENTURE SET TO V3.0');
          say(6,90,0,  'OR HIGHER.  (SET THIS ON PAGE 5)');
         end;

         end;

      4:begin

         say(0,2,6,   ' PAGE 4: GAME SETUP.  INFO ON THIS PAGE ');
         say(0,10,6,  ' DETERMINES YOUR ADVENTURE DETAILS.     ');



         say(1,25,6, 'VIDEO OPTIONS    ');
      {   say(2,48,5, ' P Û0: MIX PALETTE COLORS...');  }
         if ack.time_cycle<>0 then s:='ON ' else s:='OFF';
         say(2,35,5, ' V Û0: DAY/NIGHT VIEW SIZING: Û1'+s);


         say(1,50,6, 'SOUND OPTIONS    ');
         say(2,60,5, ' B Û0: BUMP SOUND: Û1'+soundname(ack.bumpsound));
         say(2,70,5, ' S Û0: STEP SOUND: Û1'+soundname(ack.stepsound));
         if ack.ackversion>24 then
         begin
         say(2,80,5, ' T Û0: HIT SOUND: Û1'+soundname(ack.hitsound));
         say(2,90,5, ' I Û0: MISS SOUND: Û1'+soundname(ack.misssound));
         end else
          say(2,85,2,'(HIT/MISS SOUNDS REQUIRE V3.0)');

         if ack.ackversion<25 then ack.hourmacro:=0;
         say(1,105,6,'EVENT MACROS    ');
         say(2,115,5,' X Û0: DEATH: Û1'+no(ack.deathmacro)+'  Û5 M Û0: STEP: Û1'+no(ack.stepmacro));
		 if ack.ackversion>24 then
          say(2,125,5,' H Û0: HOURLY: Û1'+no(ack.hourmacro)+'  Û5 D Û0: MIDNIGHT: Û1'+no(ack.day_macro))
		 else say(2,125,5,' D Û0: MIDNIGHT: Û1'+no(ack.day_macro));

         if ack.extracommand[1]=#27 then
          begin
           ack.extracommand:='&CHSZ';
           ack.extracommand1:=0;
           ack.extracommand2:=0;
           ack.extracommand3:=0;
           ack.extracommand4:=0;
          end;
         if ack.extracommand[1]<>'&' then
          begin
           say(2,135,0,'LEGACY EXTRACOMMAND SETTINGS...');
           say(2,145,0,'PRESS ALT-E TO RESET THEM');
          end else
         begin
           say(2,135,5,' 1 Û0: KEY "'+ack.extracommand[2]+'": Û1'+no(ack.extracommand1)+
           '  Û5 2 Û0: KEY "'+ack.extracommand[3]+'": Û1'+no(ack.extracommand2));
           say(2,145,5,' 3 Û0: KEY "'+ack.extracommand[4]+'": Û1'+no(ack.extracommand3)+
           '  Û5 4 Û0: KEY "'+ack.extracommand[5]+'": Û1'+no(ack.extracommand4));
         end;
         if ack.ackversion>24 then
           if ack.splituse=0 then
             say(2,155,5,' U Û1: "USE" KEY ALSO READY/CAST')
        else say(2,155,5,' U Û1: SEPARATE USE/READY/CAST KEYS');

        end;
      5:with ack do begin

         say(0,2,6,   ' PAGE 5: ADVANCED.  INFO ON THIS PAGE   ');
         say(0,10,6,  ' LETS YOU ADJUST SPECIFIC GAME ELEMENTS.');
         say(2,28,0, 'TEXT COLORS: [0]Û1[1]Û2[2]Û4[4]Û5[5]Û6[6]');
         say(1,38,5,' D Û0: DARKNESS COLOR: Û1'+strnum(darkforeground));
		          fputthing(50,38,darkbackground);fputthing(51,38,darkforeground);
         fputthing(52,38,darkforeground);fputthing(53,38,darkbackground);

         say(1,48,5,' B Û0: DARKNESS BACKGROUND: Û1'+strnum(darkbackground));


         if ack.ackversion>24 then
         begin
         case showmenu of
           1:s:='YES';
          17:s:='YES';
          16:s:='NO';
          else s:='NO';
         end;
         say(1,58,5,' K Û0: BMP SKIN:Û1'+s); {70}
         case ack.showclock of
          1:s:='CLOCK';
          2:s:='SKIN ';
          else s:='NONE ';
         end;
         say(1,68,5,' T Û0: TIME DISPLAY: Û1'+s);
         end else
         say(1,60,2,'(SKIN SETTINGS REQUIRE V3.0+)');

         if anim_speed=0 then s:='(NO ANIMATION)'
         else
          begin
           s:=strnum(anim_speed DIV 10)+'.'+strnum(anim_speed MOD 10);
           s:=s+' SEC.';
          end;
        say(1,78,5,' V Û0: MODIFY VERSION Û1(NOW '+version(ackversion)+')');
        say(1,88,5,' A Û0: ANIMATION SPEED: Û1'+s);


         say(1,98,5, ' H Û0: HP REGEN SPEED: Û1'+strnum(regen_hp));
         say(1,108,5, ' M Û0: MP REGEN SPEED: Û1'+strnum(regen_mp));

         if ack.password=#27 then s:='NO PASSWORD.'
          else s:='"'+ack.password+'"';
         say(1,118,5, ' P Û0: PASSWORD: Û1'+s);

         say(1,128,5,' E Û0: DAYS ELAPSED: Û1'+strnum(days));

         case ack.cheat of
          99:s:='CHEAT MODE';
          123:s:='DEBUG MODE';
          else s:='DISABLED';
         end;
         say(1,138,5, ' C Û0: ENABLE CHEATS: Û1'+s);


         say(1,150,1,' USE THIS TO SWITCH THIS EDITOR TO   ');
         say(1,158,1,' EDIT THE SAVED GAME DATA INSTEAD... ');

         if CopyType=0 then s:='MASTER ('+MASTERFILE+')'
          else s:='SAVEGAME ('+MASTERFILE+')';
         say(1,168,5, ' G Û0: EDITING COPY: Û1'+s);


        end;
   end;
end;

procedure ScreenFilldata(page:byte);
 var s:string[25];
     pty,pt1,pt2,ptc:byte;

begin
     case page of

      2:begin
         if ack.copytype<2 then begin;pt1:=1;pt2:=3;end
          else begin;pt1:=0;pt2:=0;end;
        for ptc:=pt1 to pt2 do
        begin
        if ptc=0 then pty:=1 else
         if ack.race[ptc]<>#255 then pty:=1 else pty:=0;
        with ack do if pty=1 then
        begin
         case ptc of
          1:pty:=30;
          2,0:pty:=78;
          3:pty:=126;
         end;
         if ptc=0 then say(26,pty,1,playername)
          else say(26,pty,1,race[ptc]);
         if ptc<>0 then putgrap(70,pty,Icon[ptc])
          else putgrap(70,pty,playericon);
         say(14,pty+9,1,strnum(hpmax[ptc]));
         say(36,pty+9,1,strnum(hp[ptc]));
         say(60,pty+9,1,strnum(strength[ptc]));
         say(14,pty+18,1,strnum(mpmax[ptc]));
         say(36,pty+18,1,strnum(mp[ptc]));
         say(60,pty+18,1,strnum(intelligence[ptc]));
         say(20,pty+27,1,strnum(weapskill[ptc]));
         say(48,pty+27,1,strnum(rweapskill[ptc]));
         if ptc<>0 then
          begin
           say(12,pty+36,1,strnum(vara[ptc]));
           say(30,pty+36,1,strnum(varb[ptc]));
           say(48,pty+36,1,strnum(varc[ptc]));
           say(66,pty+36,1,strnum(vard[ptc]));
          end else
          begin
           say(12,pty+36,1,strnum(variables[1]));
           say(30,pty+36,1,strnum(variables[2]));
           say(48,pty+36,1,strnum(variables[3]));
           say(66,pty+36,1,strnum(variables[4]));
          end;
        end;
       end;
       end;

   end;
end;



procedure startlocation(var rr,xc,yc,xx,yy:byte);
 var old_rr:byte;
begin
 old_rr:=rr;
 gotolocation:=true;
 if rr=0 then begin;rr:=1;gotolocation:=false;end;
 rr:=menuselectregion(rr);
 if rr=0 then exit;
 if rr<>old_rr then gotolocation:=false;
 thisregion:=rr;loadmap(rr);
 if region.rooms>20 then
  begin
   if (xc>32) or (yc>32) or (xc<1) or (yc<1) then gotolocation:=false
    else if region.room.wmap[xc,yc]=0 then gotolocation:=false;
   otherwalkworldmap(xc,yc,xx,yy);
  end
  else if region.rooms>0 then
   begin
    if xc>20 then gotolocation:=false;
    if region.rooms<xc then gotolocation:=false else
    begin
     if region.room.x2[xc]-region.room.x1[xc]+1<xx then gotolocation:=false;
     if region.room.y2[xc]-region.room.y1[xc]+1<xx then gotolocation:=false;
    end;
    otherwalkroom(xc,xx,yy);yc:=255;
   end;
end;


procedure clearbottom;
begin
 say(0,183,0,'                                        ');
 say(0,191,0,'                                        ');
end;

procedure CfgEdit;
 var pg:byte;
     done:boolean;
     j,j0:char;
     s:string;
     b,b1:byte;
     sr:searchrec;
     i,i1:integer;
     w,w1:word;
     exkey:char;
     yp2:array[0..3] of byte; {y-coords for pg 2}

procedure settext(n:byte);
begin
   if n=3 then n:=0;
   clearbottom;
   say(13,183,0,'TEXT COLOR '+strnum(n)+': FG='+strnum(hi(ack.textcolors[n]))+
      ', BKG='+strnum(lo(ack.textcolors[n])));
    say(13,191,0,'NEW FOREGROUND COLOR:');
     s:=readlin(56,191,3,1);
    val(s,i,i1);if (i1=0) and (s<>'') then
     ack.textcolors[n]:=(ack.textcolors[n] AND $ff) + i*256;
    say(13,183,0,'TEXT COLOR '+strnum(n)+': FG='+strnum(hi(ack.textcolors[n]))+
     ', BKG='+strnum(lo(ack.textcolors[n])));
    say(13,191,0,'NEW BACKGROUND COLOR:');
     s:=readlin(56,191,3,1);
    val(s,i,i1);if (i1=0) and (s<>'') then
      ack.textcolors[n]:=(ack.textcolors[n] AND $ff00) + i;
end;

begin
 pg:=1;done:=false;pgsub:=1;



 yp2[0]:=78;yp2[1]:=30;yp2[2]:=78;yp2[3]:=126;
 screensetup(pg);screenfilldata(pg);
 repeat
  case pg of
   1:helpindex:=3;
   2:helpindex:=34;
   3:helpindex:=35;
   4:helpindex:=79;
   5:helpindex:=3;
  end;
  j:=upcase_sync(readkey);
  if j=#0 then begin;j0:=readkey;
     case j0 of
      #59:help;
      #120..#124:begin;pg:=ord(j0)-119;screensetup(pg);screenfilldata(pg);end;
      #75,#73:if pg>1 then begin;dec(pg);screensetup(pg);screenfilldata(pg);end;
      #77,#81:if pg<5 then begin;inc(pg);screensetup(pg);screenfilldata(pg);end;

      #68:done:=true;
     end;end;
   case pg of
    1:case j of
    (*  'C':begin;if ack.copytype=1 then ack.copytype:=0 else
           if ack.copytype=0 then ack.copytype:=1;
           if ack.copytype>1 then
            begin
             say(1,174,0,' MAPS WILL NOT BE CHANGED.          ');
             say(1,182,0,' ONLY PLAYER RECORD WILL BE ERASED. ');
             say(1,190,0,' PRESS [Y] TO PROCEED.              ');
             j0:=upcase(readkey);
             if j0='Y' then ack.copytype:=1;
             screensetup(pg);screenfilldata(pg);
            end;
           case ack.CopyType of
              0:s:='MASTER COPY  ';
              1:s:='READY TO PLAY';
           else s:='GAME IN PROGRESS';
           end;say(32,42,1,s);
           end; {c}
           *)
         '1':begin
             clearbottom;
             say(1,183,0,'ENTER THE TITLE PICTURE (BMP) NUMBER');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.titlepic:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         '2':begin
             clearbottom;
             say(1,183,0,'ENTER THE TITLE LONG-MESSAGE NUMBER');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.titlemsg:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         '3':begin
             clearbottom;
             say(1,183,0,'ENTER THE TITLE MACRO NUMBER');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.titlemacro:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         '4':begin
             clearbottom;
             say(1,183,0,'ENTER THE NEW-PLAYER INTRO PICTURE #');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.intropic:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         '5':begin
             clearbottom;
             say(1,183,0,'ENTER THE NEW-PLAYER INTRO MESSAGE #');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.intromsg:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         '6':begin
             clearbottom;
             say(1,183,0,'ENTER THE NEW-PLAYER INTRO MACRO #');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.intromacro:=i;
             screensetup(pg);screenfilldata(pg);
             end;

        'I':begin
              clearbottom;
              say(1,181,0,' EDIT PLAYER INVENTORY');
              say(1,189,0,' CHANGE WITH [+] AND [-], [ESC] TO EXIT');
              i:=selectobj(123,0,0);
              screensetup(pg);screenfilldata(pg);
            end;

         'M':begin
             clearbottom;
             say(1,183,0,'ENTER THE MONEY THE PLAYER STARTS WITH');
             say(42,191,0,'#');
             s:=readlin(44,191,5,1);
             val(s,w,i1);if i1<>0 then w:=0;
             if s<>#27 then ack.pcash:=w;
             screensetup(pg);screenfilldata(pg);
             end;

        'V':begin
              clearbottom;
              say(1,183,0,'SELECT THE VEHICLE THE PLAYER STARTS');
              say(1,191,0,'WITH, OR [ESC] FOR NO VEHICLE');
              ack.plvehicle:=selectobj(10,ack.plvehicle,0);
              screensetup(pg);screenfilldata(pg);
            end;

         'N':begin
              clearbottom;
              say(1,183,0,'ENTER THE PLAYER NAME, OR "PROMPT"');
              say(1,191,0,'TO HAVE THE GAME ASK:');
              s:=readlin(43,191,11,0);
              ack.playername:=s;

              screensetup(pg);
              screenfilldata(pg);
             end;

         'T':begin
              clearbottom;
              say(1,183,0,'ENTER THE STARTING ACK CLOCK TIME');
              say(10,191,0,'HOUR [0-23]:');
              s:=readlin(38,191,2,1);
              val(s,i,i1);if i1=0 then ack.hour:=i;
              say(10,191,0,'MINUTE [0-59]:           ');
              s:=readlin(42,191,2,1);
              val(s,i,i1);if i1=0 then ack.minute:=i;
              screensetup(pg); screenfilldata(pg);
             end;

        'L':with Ack do begin
             startlocation(PLregion,PLxch,PLych,PLxloc,PLyloc);
             if PLxloc=0 then PLregion:=0;
             screensetup(pg);screenfilldata(pg);
            end;


         end; {j case}
     2:case j of
        #0:case j0 of
         'H':if pgsub<>0 then
           begin;if pgsub>1 then dec(pgsub);
          say(3,30,0,'#1:');
          say(3,78,0,'#2:');
          say(3,126,0,'#3:');
         case pgsub of
          1:say(3,30,6,'#1:');
          2:say(3,78,6,'#2:');
          3:say(3,126,6,'#3:');
         end;end;
         'P':if pgsub<>0 then
         begin;if pgsub<>0 then if pgsub<3 then inc(pgsub);
          say(3,30,0,'#1:');
          say(3,78,0,'#2:');
          say(3,126,0,'#3:');
         case pgsub of
          1:say(3,30,6,'#1:');
          2:say(3,78,6,'#2:');
          3:say(3,126,6,'#3:');
         end;end;
        #35:with ack do begin;s:=readlin(36,yp2[pgsub]+9,3,1);val(s,i,i1);
            if i1=0 then begin;hp[pgsub]:=i;end;
            say(36,yp2[pgsub]+9,1,'    ');
            say(36,yp2[pgsub]+9,1,strnum(hp[pgsub]));end;
        #50:with ack do begin;s:=readlin(36,yp2[pgsub]+18,3,1);val(s,i,i1);
            if i1=0 then begin;mp[pgsub]:=i;end;
            say(36,yp2[pgsub]+18,1,'    ');
            say(36,yp2[pgsub]+18,1,strnum(mp[pgsub]));end;
         end;
        '1'..'3':if pgsub<>0 then
         begin;if pgsub<>0 then pgsub:=ord(j)-48;
          say(3,30,0,'#1:');
          say(3,78,0,'#2:');
          say(3,126,0,'#3:');
         case pgsub of
          1:say(3,30,6,'#1:');
          2:say(3,78,6,'#2:');
          3:say(3,126,6,'#3:');
         end;end;
        'T':if pgsub>1 then
             begin
              if ack.race[pgsub]=#255 then
               ack.race[pgsub]:='CHARACTER CLASS'
               else ack.race[pgsub]:=#255;
              screensetup(pg);
              screenfilldata(pg);
             end;
        'N':begin;s:=readlin(26,yp2[pgsub],16,0);if s<>#27 then
            ack.race[pgsub]:=s;say(26,yp2[pgsub],0,'                 ');
            say(26,yp2[pgsub],1,ack.race[pgsub]);end;
        'H':with ack do begin;s:=readlin(14,yp2[pgsub]+9,3,1);val(s,i,i1);
            if i1=0 then begin;hpmax[pgsub]:=i;hp[pgsub]:=i;end;
            say(14,yp2[pgsub]+9,1,'    ');
            say(36,yp2[pgsub]+9,1,'    ');
            say(14,yp2[pgsub]+9,1,strnum(hpmax[pgsub]));
            say(36,yp2[pgsub]+9,1,strnum(hp[pgsub]));end;
        'M':with ack do begin;s:=readlin(14,yp2[pgsub]+18,3,1);val(s,i,i1);
            if i1=0 then begin;mpmax[pgsub]:=i;mp[pgsub]:=i;end;
            say(14,yp2[pgsub]+18,1,'    ');
            say(36,yp2[pgsub]+18,1,'    ');
            say(14,yp2[pgsub]+18,1,strnum(mpmax[pgsub]));
            say(36,yp2[pgsub]+18,1,strnum(mp[pgsub]));end;
        'I':with ack do begin;s:=readlin(60,yp2[pgsub]+18,3,1);val(s,i,i1);
            if i1=0 then begin;intelligence[pgsub]:=i;end;
            say(60,yp2[pgsub]+18,1,'    ');
            say(60,yp2[pgsub]+18,1,strnum(intelligence[pgsub]));end;
        'S':with ack do begin;s:=readlin(60,yp2[pgsub]+9,3,1);val(s,i,i1);
            if i1=0 then begin;strength[pgsub]:=i;end;
            say(60,yp2[pgsub]+9,1,'    ');
            say(60,yp2[pgsub]+9,1,strnum(strength[pgsub]));end;
        'W':with ack do begin;s:=readlin(20,yp2[pgsub]+27,3,1);val(s,i,i1);
            if i1=0 then begin;weapskill[pgsub]:=i;end;
            say(20,yp2[pgsub]+27,1,'    ');
            say(20,yp2[pgsub]+27,1,strnum(weapskill[pgsub]));end;
        'R':with ack do begin;s:=readlin(48,yp2[pgsub]+27,3,1);val(s,i,i1);
            if i1=0 then begin;rweapskill[pgsub]:=i;end;
            say(48,yp2[pgsub]+27,1,'    ');
            say(48,yp2[pgsub]+27,1,strnum(rweapskill[pgsub]));end;
        'G':with ack do begin;icon[pgsub]:=grap_select_window(icon[pgsub]);
            if (icon[pgsub]>240) or (icon[pgsub]<1) then icon[pgsub]:=1;
            screensetup(pg);screenfilldata(pg);
            if pgsub=0 then playericon:=icon[pgsub];
            end;
        'A'..'D':with ack do begin
            s:=readlin((18*(ord(j)-64))-6,yp2[pgsub]+36,3,1);val(s,i,i1);
            if i1=0 then if pgsub=0 then variables[ord(j)-64]:=i
             else case j of
              'A':vara[pgsub]:=i;
              'B':varb[pgsub]:=i;
              'C':varc[pgsub]:=i;
              'D':vard[pgsub]:=i;
             end;
            say((18*(ord(j)-64))-6,yp2[pgsub]+36,1,'    ');
            say((18*(ord(j)-64))-6,yp2[pgsub]+36,1,strnum(i));end;
       end; {j case}
     3:case j of
        '0','2'..'9':
          begin
           if j='0' then i:=10 else i:=ord(j)-48;
           i1:=28+(i*10);
           say(3,i1,6,' '+strnum(i MOD 10)+' ');

             clearbottom;
             say(1,183,0,'ENTER THE EXP REQUIRED FOR LEVEL');
             say(1,191,0,'(PRESS ESC TO LEAVE VALUE ALONE)');
             s:=readlin(36,i1,5,1);
             if s='' then s:=#27;
             val(s,w,i1);if i1<>0 then w:=0;
             if w<100 then w:=100;
             if i>2 then if w<=ack.levelexp[i-1] then w:=ack.levelexp[i-1]+1;
             if s<>#27 then ack.levelexp[i]:=w;

             i1:=28+(i*10);
             clearbottom;
             say(1,183,0,'ENTER THE MACRO TO RUN AT LEVEL UP');
             say(1,191,0,'(ENTER ''0'' TO RUN NO MACRO');
             s:=readlin(58,i1,3,1);
             if s='' then s:=#27;
             val(s,w,i1);if i1<>0 then w:=0;
             if s<>#27 then ack.levelmacro[i]:=w;

             screensetup(pg);screenfilldata(pg);


          end;




       end; {case, 3}
     4:case j of
          #0:if j0=#18 then
               begin
                  ack.extracommand:='&'+ack.extracommand[1]+'2HS';
                  ack.extracommand3:=0;
                  ack.extracommand4:=0;
                  screensetup(pg);screenfilldata(pg);
               end;

        'U':begin
              if ack.splituse=0 then ack.splituse:=1 else ack.splituse:=0;
              screensetup(pg);screenfilldata(pg);
            end;
        'B':begin
             clearbottom;
             say(1,183,0,'SELECT THE "BUMP" SOUND EFFECT');
             repeat
               say(10,191,2,'ˆ'+soundname(ack.bumpsound)+'          ');
             until updown(ack.bumpsound,0,NUMSOUNDS)>0;
             soundeffect(ack.bumpsound,1);
             screensetup(pg);screenfilldata(pg);
            end;
        'S':begin
             clearbottom;
             say(1,183,0,'SELECT THE "STEP" SOUND EFFECT');
             repeat
               say(10,191,2,'ˆ'+soundname(ack.stepsound)+'          ');
             until updown(ack.stepsound,0,NUMSOUNDS)>0;
             soundeffect(ack.stepsound,1);
             screensetup(pg);screenfilldata(pg);
            end;
        'T':begin
             clearbottom;
             say(1,183,0,'SELECT THE "HIT" SOUND EFFECT');
             repeat
               say(10,191,2,'ˆ'+soundname(ack.hitsound)+'          ');
             until updown(ack.hitsound,0,NUMSOUNDS)>0;
             soundeffect(ack.hitsound,1);
             screensetup(pg);screenfilldata(pg);
            end;
          'I':begin
             clearbottom;
             say(1,183,0,'SELECT THE "MISS" SOUND EFFECT');
             repeat
               say(10,191,2,'ˆ'+soundname(ack.misssound)+'          ');
             until updown(ack.misssound,0,NUMSOUNDS)>0;
             soundeffect(ack.misssound,1);
             screensetup(pg);screenfilldata(pg);
            end;
         '1':begin
             clearbottom;
             say(1,183,0,'PRESS A KEY FOR EXTRA COMMAND 1');
             exkey:=upcase(readkey); if exkey=#0 then
               begin;exkey:=readkey;exkey:=#27;end;
             if exkey<>#27 then
              begin
             clearbottom;
             say(1,183,0,'KEY "'+exkey+'", ENTER A MACRO# FOR THIS KEY');
             say(42,191,0,'#');
             s:=readlin(37,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then
                begin
                 ack.extracommand1:=i;
                 ack.extracommand[2]:=exkey;
                end;
              end;
             screensetup(pg);screenfilldata(pg);
            end;
         '2':begin
             clearbottom;
             say(1,183,0,'PRESS A KEY FOR EXTRA COMMAND 2');
             exkey:=upcase(readkey); if exkey=#0 then
               begin;exkey:=readkey;exkey:=#27;end;
             if exkey<>#27 then
              begin
             clearbottom;
             say(1,183,0,'KEY "'+exkey+'", ENTER A MACRO# FOR THIS KEY');
             say(42,191,0,'#');
             s:=readlin(37,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then
                begin
                 ack.extracommand2:=i;
                 ack.extracommand[3]:=exkey;
                end;
              end;
             screensetup(pg);screenfilldata(pg);
            end;
         '3':begin
             clearbottom;
             say(1,183,0,'PRESS A KEY FOR EXTRA COMMAND 3');
             exkey:=upcase(readkey); if exkey=#0 then
               begin;exkey:=readkey;exkey:=#27;end;
             if exkey<>#27 then
              begin
             clearbottom;
             say(1,183,0,'KEY "'+exkey+'", ENTER A MACRO# FOR THIS KEY');
             say(42,191,0,'#');
             s:=readlin(37,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then
                begin
                 ack.extracommand3:=i;
                 ack.extracommand[4]:=exkey;
                end;
              end;
             screensetup(pg);screenfilldata(pg);
            end;
         '4':begin
             clearbottom;
             say(1,183,0,'PRESS A KEY FOR EXTRA COMMAND 4');
             exkey:=upcase(readkey); if exkey=#0 then
               begin;exkey:=readkey;exkey:=#27;end;
             if exkey<>#27 then
              begin
             clearbottom;
             say(1,183,0,'KEY "'+exkey+'", ENTER A MACRO# FOR THIS KEY');
             say(42,191,0,'#');
             s:=readlin(37,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then
                begin
                 ack.extracommand4:=i;
                 ack.extracommand[5]:=exkey;
                end;
              end;
             screensetup(pg);screenfilldata(pg);
            end;

         'H':begin
             clearbottom;
             say(1,183,0,'ENTER A MACRO# TO RUN EVERY HOUR');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.hourmacro:=i;
             screensetup(pg);screenfilldata(pg);
            end;
         'X':begin
             clearbottom;
             say(1,183,0,'ENTER A MACRO# TO RUN ON DEATH');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.deathmacro:=i;
             screensetup(pg);screenfilldata(pg);
            end;			
           'M':begin
             clearbottom;
             say(1,183,0,'ENTER A MACRO# TO RUN ON EVERY STEP');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.stepmacro:=i;
             screensetup(pg);screenfilldata(pg);
             end;
           'D':begin
             clearbottom;
             say(1,183,0,'ENTER A MACRO# TO RUN ONCE PER DAY');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.day_macro:=i;
             screensetup(pg);screenfilldata(pg);
             end;
         'V':begin
              if ack.time_cycle=0 then ack.time_cycle:=1
               else ack.time_cycle:=0;
              screensetup(pg);screenfilldata(pg);
             end;


       end; {j case}
      5:case j of
          '0'..'6':begin
            settext(ord(j)-48);
            TEXTC0:=ack.textcolors[0];
            TEXTC1:=ack.textcolors[1];
            TEXTC2:=ack.textcolors[2];
            TEXTC4:=ack.textcolors[4];
            TEXTC5:=ack.textcolors[5];
            TEXTC6:=ack.textcolors[6];
            screensetup(pg);screenfilldata(pg);
           end; {g}

         'H':begin
             clearbottom;
             say(1,183,0,'ENTER THE HP REGEN (SEE MANUAL)');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.regen_hp:=i;
             screensetup(pg);screenfilldata(pg);
            end;
         'H':begin
             clearbottom;
             say(1,183,0,'ENTER THE MP REGEN (SEE MANUAL)');
             say(42,191,0,'#');
             s:=readlin(44,191,3,1);
             val(s,i,i1);if i1<>0 then i:=0;
             if s<>#27 then ack.regen_mp:=i;
             screensetup(pg);screenfilldata(pg);
            end;


          'T':begin;ack.showclock:=ack.showclock+1;if ack.showclock>2 then ack.showclock:=0;
                screensetup(pg);screenfilldata(pg);end;
        'C':begin
             case ack.cheat of
              5:ack.cheat:=99;
              99:ack.cheat:=123;
              else ack.cheat:=5;
             end;
             screensetup(pg);screenfilldata(pg);
            end;
       'P':begin
           clearbottom;
           say(0,183,0,'CREATE A PASSWORD IF YOU WANT TO DISABLE');
           say(0,191,0,'EDITORS:');
           ack.password:=readlin(40,191,8,0);
           if ack.password='' then ack.password:=#27;
              screensetup(pg);screenfilldata(pg);

           end; {p}

      'G':begin
         if ack.copytype=0 then
           begin
            findfirst(ADVNAME+PLAYMASTERFILE,anyfile,sr);
            if doserror=0 then begin
              saveconfig;
              MASTERFILE:=PLAYMASTERFILE;
              MAPAFILE:='.X';
              MAPBFILE:='.Y';
              MAPCFILE:='.Z';
              REGIONFILE:='.RGX';
              loadconfig;
              ack.copytype:=2;
             end;
            end else
            begin
              saveconfig;
              MASTERFILE:='.MST';
              MAPAFILE:='.A';
              MAPBFILE:='.B';
              MAPCFILE:='.C';
              REGIONFILE:='.RGN';
              loadconfig;
              ack.copytype:=0;
            end;
           screensetup(pg);screenfilldata(pg);
          end;

        'K':begin
             case ack.showmenu of
              0:ack.showmenu:=1;
              else ack.showmenu:=0;
             end;
            screensetup(pg);screenfilldata(pg);
            end;
         'A':with ack do begin
              clearbottom;

             say(1,183,0,'SET ANIMATION SPEED (0 TO DISABLE)');

             repeat
              if ack.anim_speed=0 then s:='(NONE)  '
               else
                begin
                 s:=strnum(ack.anim_speed DIV 10)+'.'+strnum(ack.anim_speed MOD 10);
                 s:=s+' SEC.';
                end;
              say(44,191,1,'ˆ'+s);
             until updown(ack.anim_speed,0,50)>0;
              screensetup(pg);screenfilldata(pg);

            end;

         'V':begin
              clearbottom;
              say(1,183,0,'SET THE RECOMMENDED ACK VERSION FOR');
              say(1,191,0,'THIS GAME.');
              i:=ack.ackversion;
              repeat
                if ack.ackversion=25 then ack.ackversion:=30;
     if ack.ackversion=29 then ack.ackversion:=24;
    if ack.ackversion<12 then ack.ackversion:=12;
                if ack.ackversion=16 then ack.ackversion:=20;
     if ack.ackversion=19 then ack.ackversion:=15;

               s:=strnum(ack.ackversion DIV 10)+'.'+strnum(ack.ackversion MOD 10);
               say(44,191,1,'ˆ'+s);
              until updown(ack.ackversion,0,ACKVERSION)>0;
              if (i<25) and (ack.ackversion>24) then
               with ack do begin
                {perform some resetting for new 2.5 features}
                   level:=1;
                   experience:=0;
                   showclock:=0;

                   hitsound:=0;
                   misssound:=0;
		fly:=false; nomove_n:=false;
		nomove_s:=false; nomove_e:=false;
		nomove_w:=false; unused:=false;
                   levelexp[2]:=1000;
                   levelexp[3]:=2000;
                   for i:=4 to 10 do
                    levelexp[i]:=levelexp[i-1]+levelexp[i-2];
                   for i:=2 to 10 do levelmacro[i]:=0;
                   for i:=8 to 26 do variableshi[i]:=0;
                   for i:=1 to 12 do qtile[i]:=0;
                   minviewdistance:=0;
                   hourmacro:=0;
				   poison:=0;
                   extracommand2:=0;
                   extracommand3:=0;
                   extracommand4:=0;
                   torchduration:=0;
                   viewdistance:=17;
                   showclock:=0;
                   darkforeground:=17;darkbackground:=0;

               end;
              screensetup(pg);
              screenfilldata(pg);
             end;
         'E':begin

              clearbottom;
              say(1,183,0,'IF YOU DON''T WANT "ELAPSED DAYS" TO BE');
              say(1,191,0,'ZERO, SET IT HERE.');

              s:=readlin(44,191,5,1);
              val(s,ack.days,i1);if s<>#27 then ack.old_days:=ack.days;
              screensetup(pg);screenfilldata(pg);
             end;
         'D':begin

              clearbottom;
              say(1,183,0,'ENTER THE FOREGROUND COLOR FOR THE DARK');
              say(1,191,0,'(NIGHT,ETC) TILES.');

              s:=readlin(50,191,3,1);
              val(s,ack.darkforeground,i1);
              screensetup(pg);screenfilldata(pg);
             end;
         'B':begin

              clearbottom;
              say(1,183,0,'ENTER THE BACKGROUND COLOR FOR THE DARK');
              say(1,191,0,'(NIGHT,ETC) TILES.');

              s:=readlin(50,191,3,1);
              val(s,ack.darkbackground,i1);
              screensetup(pg);screenfilldata(pg);
             end;


(*       #0:case j0 of
         end; {j0case} *)
        end; {j case}

   end; {pg case}

 until done;
end;



function strnum(n:integer):string;
var s:string;
begin
 str(n,s);
 strnum:=s;
end;

procedure newfont;
var bf:file of grpblock;
    i:integer;
    fn:string;
begin
 fn:=concat(ADVNAME,FONTFILE);
 assign(bf,fn);
 rewrite(bf);
 for i:=1 to BLOCKS do write(bf,block^[i]);
 close(bf);
end;

procedure newgraps;
var bf:file of grap256unit;
    fn:string;
    i,i1,i2:integer;
begin
 for i:=1 to GRAPS do
  for i1:=1 to 16 do
   for i2:=1 to 16 do
    graphic^[i,i2,i1]:=0;
 fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
 {$I-} rewrite(bf); {$I+}
 if ioresult<>0 then begin;sound(1000);delay(100);nosound;exit;end;
 for i:=1 to GRAPS do write(bf,graphic^[i]);
 close(bf);
end;


procedure initconfig;
var i:byte;
begin
 ack.ackversion:=ACKVERSION;

 with ack do begin
  deathmacro:=0;
  hour:=12; minute:=0;
  time_cycle:=0;
  day_macro:=0;
  days:=0;old_days:=0;
  regen_hp:=1;
  regen_mp:=1;
  {for i:=1 to BLANKSPACE_SIZE do blankspace[i]:=0;}
  criminal:=0;
  cheat:=5;
  poison:=0;
{  modules[4]:=5;
  modules[5]:=5;
  modules[6]:=5;
  modules[7]:=7;
  modules[8]:=8;
  modules[9]:=9;
  modules[10]:=5;
  modules[11]:=5;
  modules[12]:=255; }
  level:=1;
  experience:=0;
  levelexp[2]:=1000;
  levelexp[3]:=2000;
  for i:=4 to 10 do
     levelexp[i]:=levelexp[i-1]+levelexp[i-2];
  for i:=2 to 10 do levelmacro[i]:=0;

  fly:=false; nomove_n:=false;
  nomove_s:=false; nomove_e:=false;
  nomove_w:=false; unused:=false;

  textcolors[0]:=15*256 + 0;
  textcolors[1]:=8*256 + 0;
  textcolors[2]:=7*256 + 0;
  textcolors[3]:=ack.textcolors[0];
  textcolors[4]:=0 + 8;
  textcolors[5]:=0 + 7;
  textcolors[6]:=0 + 15;
  viewdistance:=17;
  minviewdistance:=0;
  torchduration:=0;
  anim_speed:=10;


  stepmacro:=0;
  extracommand1:=0;
  extracommand2:=0;
  extracommand3:=0;
  extracommand4:=0;
  darkforeground:=18;darkbackground:=0;

  extracommand:=#27;
  bumpsound:=0;
  stepsound:=0;

  for i:=8 to 26 do ack.variableshi[i]:=0;
  for i:=1 to 12 do ack.qtile[i]:=0;
  ack.showclock:=0;
  ack.misssound:=97;
  ack.hitsound:=98;

  copytype:=0;
  password:=#27;
  playericon:=1;
  plregion:=0;
  plxch:=0;plych:=0;
  plxloc:=0;plyloc:=0;
  plvehicle:=0;
  pweapready:=0;
  for i:=2 to 254 do pinv[i]:=0;
  pcash:=0;
  playername:=' ';
  race[1]:='HUMAN';
  race[2]:='DWARF';
  race[3]:='ELF';
  HP[1]:=10;HP[2]:=12;HP[3]:=8;HP[0]:=0;
  for i:=0 to 3 do HPmax[i]:=HP[i];
  MP[1]:=12;MP[2]:=4;MP[3]:=10;MP[0]:=0;
  for i:=0 to 3 do MPmax[i]:=MP[i];
  strength[1]:=10;strength[2]:=14;strength[3]:=8;strength[0]:=0;
  intelligence[1]:=14;intelligence[2]:=7;
  intelligence[3]:=13;intelligence[0]:=0;
  weapskill[1]:=30;weapskill[2]:=50;weapskill[3]:=25;weapskill[0]:=0;
  rweapskill[1]:=40;rweapskill[2]:=15;rweapskill[3]:=60;rweapskill[0]:=0;
  for i:=0 to 3 do icon[i]:=1;
  for i:=1 to 3 do begin;vara[i]:=0;varb[i]:=0;varc[i]:=0;vard[i]:=0;end;
  for i:=1 to 26 do variables[i]:=0;
  playername:='';
  titlepic:=0;titlemsg:=0;
  intropic:=0;intromsg:=0;
  intromacro:=0;titlemacro:=0;
 end;
 end;


procedure checkpw;
     begin
       loadconfig;
       passwordok:=2;
       if ADVNAME='NONAME' then exit;
       if ack.password<>#27 then
        begin
         clearscreen;
         say(10,50,0,'PLEASE ENTER PASSWORD, OR');
         say(10,60,0,'PRESS Û5 …† Û0 IF YOU DO NOT');
         say(10,70,0,'WISH TO EDIT THIS ADVENTURE.');
         ss:=readlin(30,82,8,0);
         if ss='' then ss:=#27;
         if ss=ack.password then passwordok:=2 else passwordok:=1;
         if (passwordok=1) and (ss<>#27) then
          begin
           clearscreen;
           say(25,65,5,' *** INCORRECT *** ');
           delay(1000);
          end;
        end;
      end;


procedure tryfile(fn:string);
 var f:file of byte;
    ior:word;
    i,i1:integer;
    dn:string;
    an:string;
begin
 an:='NONAME';dn:='.';
 if pos('.',fn)<>0 then exit;
 assign(f,fn+MASTERFILE);
 {$I-} reset(f);ior:=ioresult;if ior=0 then close(f); {$I+}

 if ior<>0 then
 begin
  if (pos('\',fn)=0) and (pos(':',fn)=0) then
   begin
    {file not found, no path given.  look in default places}
    assign(f,'GAMES\'+fn+MASTERFILE);
    {$I-} reset(f); {$I+}
    if ioresult=0 then begin;ior:=0;dn:='GAMES';an:=fn;end;
    if ior<>0 then
     begin
      assign(f,'GAMES\DEMOS\'+fn+MASTERFILE);
      {$I-} reset(f); {$I+}
      if ioresult=0 then begin;ior:=0;dn:='GAMES\DEMOS';an:=fn;end;
      if ior<>0 then
       begin
        {$I-}
        assign(f,'GAMES\'+fn+'\'+fn+MASTERFILE);
        reset(f); {$I+}
        if ioresult=0 then begin;ior:=0;dn:='GAMES\'+fn;an:=fn;end;
       end;
     end;
    end;
    if ior=0 then close(f);
   end else

 if ior=0 then
   begin
    ior:=length(fn);
    i:=0;
    repeat
    dec(ior);
    if fn[ior]='\' then
     begin;dn:=copy(fn,1,ior)+'.';an:=copy(fn,ior+1,length(fn)-ior);i:=1;end;
    if (ior<2) and (i=0) then begin;i:=1;an:=fn;end;
    until i<>0;
    ior:=0;
   end;
    for i:=1 to length(an) do an[i]:=upcase(an[i]);
   ADVNAME:=an;
  {$I-}
   chdir(dn);
  {$I+}
   if (ioresult<>0) or (ior<>0) then ADVNAME:='NONAME';
   if ADVNAME='NONAME' then say(10,60,2,'ADVENTURE NOT FOUND.')
   else begin
     checkpw;
     i:=2;
     graphic^[i,1,1]:=passwordok;
   end;
end;


procedure AckFinder(prefile:string);
 var
 files:array[1..42] of string[10];
 fcolors:array[1..42] of byte;
 sr:searchrec;
 fc:byte;
 done:boolean;
 whatf:byte;
 j:char;
 startdir:string;
 x,y:byte;
 pf:boolean;

procedure showdirs;
begin
 whatf:=1;
 clearscreen;
 say(2,2,6,' LOAD OR CREATE ADVENTURE ');
 getdir(0,ss);if length(ss)<20 then ss:='CURRENT DIRECTORY: '+ss;
 if length(ss)>39 then ss:='‰'+copy(ss,length(ss)-37,38);
 say(1,15,0,ss);
 say(1,155,0,'SELECT A FILE TO LOAD AND PRESS Û6 …† Û0.');
 say(1,164,0,'SUBDIRECTORIES APPEAR IN BRACKETS.');
 say(2,173,1,'PRESS Û4 F3 Û1 TO CREATE A NEW GAME');
 say(2,182,2,'ALL NEW GAMES SHOULD BE CREATED IN THE');
 say(2,191,2,'\ACK\GAMES DIRECTORY.  Û0(Û6ESCÛ0 TO ABORT)');
 fc:=1;
 files[1]:='{DRIVE}';fcolors[1]:=1;
 findfirst('*.',16,sr);
 while doserror=0 do
  begin
   if sr.name<>'.' then
    begin;inc(fc);fcolors[fc]:=2;files[fc]:='['+sr.name+']';end;
   findnext(sr);
  end;
 findfirst('*'+MASTERFILE,0,sr);
 while doserror=0 do
  begin
   inc(fc);
   with sr do
    files[fc]:=copy(name,1,length(name)-4);
   fcolors[fc]:=0;
   findnext(sr);
  end;
 if fc<=14 then i1:=fc else i1:=14;
 for i:=1 to i1 do
  say(5,25+(i*8),fcolors[i],files[i]);
 if fc<=28 then i1:=fc else i1:=28;
 for i:=15 to i1 do
  say(30,25+(i-14)*8,fcolors[i],files[i]);
 for i:=29 to fc do
  say(55,25+(i-28)*8,fcolors[i],files[i]);
end;

procedure showfn(c,n:byte);
 var x,y:byte;
begin
 if n>28 then begin;x:=55;y:=25+(n-28)*8;end else
 if n>14 then begin;x:=30;y:=25+(n-14)*8;end else
 begin;x:=5;y:=25+(n*8);end;
 say(x,y,c,files[n]);
end;

begin
 if copy(prefile,1,2)<>'CH' then
  begin
   tryfile(copy(prefile,3,length(prefile)-2));
   exit;
  end;

 getdir(0,startdir);
 {$I-} chdir('GAMES'); {$I+}
 fc:=ioresult;
 showdirs;
 repeat
  done:=false;
  showfn(6,whatf);
  j:=#1;
  repeat
   if keypressed then j:=upcase_sync(readkey);
   if mouseon then
   begin
    trackmouse;
    for i:=1 to fc do
     begin {check each spot for mouse click}
      if (i>=1) and (1<=14) then
       if mousein(5,25+(i*8),24,33+(i*8)) then
        if i<=fc then begin;whatf:=i;j:=#32;end;
      if (i>=15) and (i<=28) then
       if mousein(30,25+((i-14)*8),49,33+((i-14)*8)) then
        if i<=fc then begin;whatf:=i;j:=#32;end;
      if (i>29) then
       if mousein(55,25+((i-28)*8),74,33+((i-28)*8)) then
        if i<=fc then begin;whatf:=i;j:=#32;end;
     end; {for i=1 to fc}
   end; {if mouseon}
  until (j<>#1);
  showfn(fcolors[whatf],whatf);
  case j of
   #0:case readkey of
       #59:help;
       #61:if fc<42 then begin  {create new adv}
             inc(fc);
             if fc>28 then begin;x:=55;y:=25+(fc-28)*8;end else
             if fc>14 then begin;x:=30;y:=25+(fc-14)*8;end else
             begin;x:=5;y:=25+(fc*8);end;whatf:=fc;
             files[whatf]:=readlin(x,y,8,2);fcolors[whatf]:=2;
             if (files[whatf]<>'') and (files[whatf]<>#27) then
             begin
             {$I-}
              mkdir(files[whatf]);
              chdir(files[whatf]);
             {$I+}
             end;
             helpindex:=29;
             done:=true;
             if (files[whatf]<>#27) and (files[whatf]<>'')
              then begin
               ADVNAME:=files[whatf];
               clearscreen;
                x:=1;
                say(9,35,0,'CREATING ADVENTURE: '+ADVNAME);
                say(9,60,2,'IF YOU WOULD LIKE TO BUILD THIS');
                say(9,70,2,'ADVENTURE FROM AN EXISTING KIT,');
                say(9,80,2,'USE THE ''IMPORT FILES'' OPTION');
                say(9,90,2,'FROM THE MAIN MENU.');
                initconfig;
                saveconfig;
                newfont;newgraps;

                say(9,154,1,' (PRESS A KEY TO CONTINUE)');
                if readkey=#0 then if readkey=#59 then help;
                helpindex:=1;
               end
              else begin;done:=false;showdirs;end;
            end;
       #65:if fc<42 then begin {create new dir}
             inc(fc);
             if fc>28 then begin;x:=55;y:=25+(fc-28)*8;end else
             if fc>14 then begin;x:=30;y:=25+(fc-14)*8;end else
             begin;x:=5;y:=25+(fc*8);end;whatf:=fc;
             files[whatf]:='['+readlin(x,y,8,2)+']';fcolors[whatf]:=2;
             if (files[whatf]<>'') and (files[whatf]<>#27) then
             begin
             {$I-}
              mkdir(copy(files[whatf],2,length(files[whatf])-2));
              chdir(copy(files[whatf],2,length(files[whatf])-2));
             {$I+}
             end;
             showdirs;
            end;
       'H':if whatf>1 then dec(whatf) else whatf:=fc;
       'P':if whatf<fc then inc(whatf) else whatf:=1;
       'K':if whatf-14>=1 then dec(whatf,14);
       'M':if whatf+14<=fc then inc(whatf,14);
       'G','I':whatf:=1;
       'O','Q':whatf:=fc;
      end;
   #32,#13:if (files[whatf,1]='[') and (files[whatf,length(files[whatf])]=']')
           then begin
            {$I-}
            chdir(copy(files[whatf],2,length(files[whatf])-2));
            {$I+}
            showdirs;
           end else if whatf=1 then
            begin
             say(5,33,0,'DRIVE? [A-Z]');
             repeat
              i:=ord(upcase_sync(readkey));
              case chr(i) of
               'A'..'Z':begin;{$I-}chdir(chr(i)+':');{$I+}done:=true;end;
              end;
             until done;
             say(5,33,0,'            ');
             done:=false;
            end else done:=true;

   #27:begin;whatf:=0;done:=true;end;
   end;
 until done;
 if whatf=0 then {$I-} chdir(startdir) {$I+}
 else
  begin
   ADVNAME:=files[whatf];
   helpindex:=30;
   checkpw;
   helpindex:=1;
  end;
end;


{I I_MSGED1.PAS}
{$I PTR_PORT.PAS}

var opt:string[1];


var sync_app: byte;
function upcase_sync(r: char): char;

begin
 {search and replace and change all upcase(readkey) to upcase_sync(readkey)}
 if r=#9 then
 begin
  case sync_app of
   1:begin      { ackfinder file loader.  Not sure what to sync here, if anything }
      loadfont;

     end;
   3:begin    { config edit }
      loadgraps;loadfont;if not loadobjs then exit;saveconfig;
     end;

  end; {case}
  sound(500);delay(100);sound(1000);delay(100);nosound;
 end;
 upcase_sync:=upcase(r);
end;

procedure checkackexe;
var dirinfo:searchrec; problem:boolean; j:char;
begin
  problem:=false;
  FindFirst(systemdir+'\ACK.EXE', AnyFile, dirinfo);
  if doserror=0 then problem:=true;
  FindFirst(systemdir+'\ACKMOD.EXE', AnyFile, dirinfo);
  if doserror=0 then problem:=true;


  if problem then begin
      clearscreen;
      say(0,10,6,' ACK LAUNCHER IS FROM AN OLD VERSION!   ');
      say(3,30,0,'YOU HAVE THE "ACKMOD.EXE" AND ');
      say(3,40,0,'"ACK.EXE" FILES LEFT OVER FROM');
      say(3,50,0,'A PREVIOUS VERSION OF ACK.');
      say(3,70,0,'PLEASE QUIT ACK, THEN DELETE THESE');
      say(3,80,0,'TWO FILES TO CLEAR THIS WARNING.');
      say(3,100,0,'(USE ACK.BAT AND ACKMOD.BAT TO');
      say(3,110,0,' LAUNCH ACK INSTEAD)');

      say(3,130,0,'YOU WON''T BE ABLE TO LOAD ADVENTURES');
      say(3,140,0,'UNTIL THIS PROBLEM IS CORRECTED.');
      say(3,180,1,'PRESS A KEY TO CONTINUE');
      if readkey=#0 then j:=readkey;
      halt;
   end;

end;

procedure loadmapcolors;
var cf:file of byte;
    i:byte;
begin
 assign(cf,ADVNAME+'.MCO');
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then
  begin
   mapcolors[i]:=0; mapcolors[255]:=0;
   for i:=1 to 254 do if obj^[i].t>5 then mapcolors[i]:=15 else mapcolors[i]:=i;
  end else
  begin
   for i:=0 to 255 do read(cf,mapcolors[i]);
   close(cf);
  end;
end;

begin


 savedexitproc:=exitproc;   {Set up for custom exit routine}
 exitproc:=@CustomExit;
 {if copy(paramstr(4),1,2)<>'CH' then
  if copy(paramstr(4),1,2)<>'LO' then
   begin;writeln('ACK v',(ACKVERSION DIV 10),'.',(ACKVERSION MOD 10),' program file.');halt;end;}
 usepointers;
 ss:=paramstr(1);
 i:=pos('*',ss);
 ADVNAME:=copy(ss,i+1,length(ss)-i);
 systemdir:=copy(ss,2,i-2);
 bgi_dir:=systemdir;
 u_graph_setup;
 helpfile:=systemdir+'\ACKDATA1.HLP';
 graphicsmode;
 checkackexe;
 opt:=copy(paramstr(1),1,1);
 if opt[1]<>upcase(opt[1]) then disablemouse:=true;

 initmouse;

 case upcase(opt[1]) of
 'F':begin

  helpindex:=1;
  sync_app:=1;
 passwordok:=0;
 AckFinder(paramstr(4));
 ss:=ADVNAME;
 b:=length(ss);
 i1:=1;graphic^[i1,1,1]:=b;
 for i:=1 to b do
  graphic^[i1,i+1,1]:=ord(ss[i]);
 i1:=2;graphic^[i1,1,1]:=passwordok;
 end;

 'C':begin
 closemouse;
 pausemouse:=true;
 helpindex:=3;
 for sync_app:=0 to 255 do mapcolors[sync_app]:=sync_app;
 sync_app:=3;
 getmem(obj, (MAXOBJS+1) * sizeof ( Objectrec ) );obj^[0].d[1]:=0;
 getmem(rmcnt, 6400);
 getmem(locnt, LOCNTMAX * sizeof(loccontrec));
 getmem(crc, MAXCRCS * sizeof(creaturerec));
 getmem(graphic2, (GRAPS+1)*256 );
 getmem(wander_index, (WANDERMAX+1) * sizeof(wander_record));
 getmem(rcrc, (RCMAX+1) * sizeof(rregioncreature));

 LoadConfig;if not LoadObjs then ack.plvehicle:=0;
 loadgraps2(true);
 ack.copytype:=0;
 TEXTC0:=ack.textcolors[0];
 TEXTC1:=ack.textcolors[1];
 TEXTC2:=ack.textcolors[2];
 TEXTC4:=ack.textcolors[4];
 TEXTC5:=ack.textcolors[5];
 TEXTC6:=ack.textcolors[6];
 loadcreatures;
 loadmapcolors;
 CfgEdit;
 SaveConfig;
 end;
   end;

end.
