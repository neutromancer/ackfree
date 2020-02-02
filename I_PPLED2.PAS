
procedure resetcreature(nn:byte);
 var nnn:byte;
begin
 with crc^[nn] do
  begin
   n:='NEW CREATURE';
   crcsounds[nn]:=0;

   t:=1;exphi:=1;g1:=1;g2:=0;g3:=0;g4:=0;t1:=1;h:=4;hm:=4;m:=2;mm:=2;touchm:=0;
   deathm:=0;ws:=25;rws:=25;exp:=10;fw:=0;fr:=0;ar:=0;veh:=0;
   for nnn:=1 to 3 do begin;inv[nnn]:=0;invn[nnn]:=0;end;

  end;
 end;


procedure initcreatures;
 var i:byte;
begin
 resetcreature(1);
 for i:=2 to MAXCRCS do
   crc^[i].t:=0;
end;


procedure savecreatures;
var cf:file of creaturerec;
    csf:file of word;
    i:byte;
begin
 assign(cf,ADVNAME+CREATUREFILE);
 {$I-} rewrite(cf); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to MAXCRCS do write(cf,crc^[i]);
 close(cf);
 assign(csf,ADVNAME+CREATURESOUNDFILE);
 {$I-} rewrite(csf); {$I+}
 if ioresult<>0 then exit;
 for i:=1 to MAXCRCS do write(csf,crcsounds[i]);
 close(csf);
end;


procedure loadcreatures;
var cf:file of creaturerec;
    csf:file of word;
    i:byte;
begin
 assign(cf,ADVNAME+CREATUREFILE);
 {$I-} reset(cf); {$I+}
 if ioresult<>0 then begin;initcreatures;savecreatures;exit;end;

 for i:=1 to 64 do read(cf,crc^[i]);
  if not eof(cf) then
    for i:=65 to MAXCRCS do read(cf,crc^[i])
   else
    begin
	 for i:=65 to MAXCRCS do crc^[i].t:=0;
	end;
 close(cf);
 assign(csf,ADVNAME+CREATURESOUNDFILE);
 {$I-} reset(csf); {$I+}
 if ioresult<>0 then
  begin;for i:=1 to MAXCRCS do crcsounds[i]:=0;exit;end;
 for i:=1 to 64 do read(csf,crcsounds[i]);
  if not eof(csf) then
    for i:=65 to MAXCRCS do read(csf,crcsounds[i])
   else
    begin
	 for i:=65 to MAXCRCS do crcsounds[i]:=0;
	end;
 close(csf);
end;



{$I I_PPLED1.PAS}


function updown(var numin:byte;minim,maxim:byte):byte;
var ud:byte;
begin
 ud:=0;
 case upcase_sync(readkey) of
  #0: case readkey of
     #59:help;
     'H','K':if numin>=maxim then numin:=minim else inc(numin);
     'M','P':if numin<=minim then numin:=maxim else dec(numin);
     'G':numin:=minim;
     'O':numin:=maxim;
     end;
  #32,#13:ud:=2;
  #27:ud:=1;
 end;
 updown:=ud;
end;


function hinyb(b:byte):byte;
begin
 hinyb:=b DIV 16;
end;
function lonyb(b:byte):byte;
begin
 lonyb:=b MOD 16;
end;
procedure sethinyb(var by:byte;nb:byte);
begin
 by:=lonyb(by)+(nb*16);
end;
procedure setlonyb(var by:byte;nb:byte);
begin
 by:=(hinyb(by)*16)+nb;
end;


function objnam(num:byte):string;
begin
 if num<>0 then objnam:=concat('#',strnum(num),' ',obj^[num].n)
 else objnam:='NOTHING';
end;





{$I I_SELECT.PAS}

{$I I_SNDNAM.PAS}
{$I I_SNDEFF.PAS}


procedure setupscreen;
begin
 clearscreen;
 drawh(0,181,319,3);
 say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
 say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
     say(0,2,6,    '    EDIT CREATURE                       ');
     say(67,2,5,' #'+strnum(whatcrc)+' ');
     say(1,12,0,  'GRAPHIC:    €5 G €0:');
     say(1,31,0,  'ANIMATION:  €5ÉÑG€0:');

	 {    say(1,22,0,  'SI€5 Z €0E:');}
     say(1,37+9,5,  ' N €0AME:');
     say(1,46+9,5,  ' A €0LIGN:          €5 T €0OUCH MACRO:');
     say(1,57+9,5,  ' H €0P:      €5ÉÑH€0P:');
     say(50,66,5,' E €0XP: ');
     say(1,66+9,5,  ' Y €0:FIGHT SOUND:');
     say(1,77+7,5,  ' Z €0:DEATH SOUND:');
     say(1,86+8,5,  ' W €0EAP.SKL:     €5 R €0NG.WP.SKL:');
     say(1,95+8,5,  ' V €0EHICLE:');
     say(5,106+8,5,    ' F €0IGHTS WITH:');
     say(9,115+8,5,     'ÉÑF€0  ...AND:');
     say(17,124+8,0,         'ARM€5 O €0R:');
     say(1,135+8,0, 'REMAINS           €5 D €0EATH MACRO:');
     say(1,144+8,5, ' 1 €0:');
     say(1,153+8,5, ' 2 €0:');
     say(1,162+8,5, ' 3 €0:');
 end;

procedure fillscreen;
 var s:String[25]; iii:byte;
begin;
with crc^[whatcrc] do begin
 putgrap(35,11,g1);
 if g2<>0 then putgrap2(35,30,g2) else putgrap(35,30,0);
 if g3<>0 then putgrap2(40,30,g3) else putgrap(40,30,0);
 if g4<>0 then putgrap2(45,30,g4) else putgrap(45,30,0);
{ if sz>1 then begin;putgrap(37,11,g2);putgrap(33,27,g3);putgrap(37,27,g4);end;
 case sz of
  0:begin;s:='SMALL';drawh(33*4-2,28,33*4+17,3);
    drawv(33*4-2,10,28,3);drawv(33*4+17,10,28,3);end;
  1:begin;s:='NORMAL';drawh(33*4-2,28,33*4+17,3);
    drawv(33*4-2,10,28,3);drawv(33*4+17,10,28,3);end;
  else begin;s:='LARGE';drawh(33*4-2,44,33*4+33,3);
    drawv(33*4-2,10,44,3);drawv(33*4+33,10,44,3);end;
  end;
 say(17,22,1,s);  size
 }
 say(16,46,1,n); {name}
 case t of
  1:s:='GOOD';
  2:s:='EVIL';
  3:s:='NEUTRAL';
  4:s:='ANIMAL';
 end;
 say(19,55,1,s); {align}
 if deathm=0 then s:='NONE' else s:='#'+strnum(deathm);
 say(67,143,1,s);
 if touchm=0 then s:='NONE' else s:='#'+strnum(touchm);
 say(67,55,1,s);
 case t1 of
  0:s:='STOP';
  1:s:='WAIT';
  2:s:='ROAM';
{ 3:s:='RABID';
  4:s:='GUARD';
  5:s:='SNIPER'; }
 end;
{ say(59,55,1,s); bhvr}
if hm<>0 then
 say(12,66,1,strnum(hm)) else
  say(12,66,1,'INVULNERABLE.');
if hm<>0 then
 say(34,66,1,strnum(h));
{ say(34,75,1,strnum(m));
 say(12,75,1,strnum(mm));
 say(58,66,1,strnum(st));
 say(58,75,1,strnum(iq)); }
 say(24,94,1,strnum(ws));
 say(68,94,1,strnum(rws));
 say(66,66,0, strnum((exphi-1)*256 + exp)+'   ' );
 say(34,75,1,soundname(hi(crcsounds[whatcrc])));
 say(34,84,1,soundname(lo(crcsounds[whatcrc])));
 if objok then
  begin
   case veh of
    0..254:say(23,103,1,objnam(veh));
	255:say(23,103,1,'FLY');
	end;
   say(34,114,1,objnam(fw));
   say(34,123,1,objnam(fr));
   say(34,132,1,objnam(ar));

   for iii:=1 to 3 do
    begin
   if inv[iii]=0 then s:='NOTHING'
   else case obj^[inv[iii]].t of
    1..5:begin;s:=objnam(inv[iii]);if invn[iii]<>0 then s:=s+' /'+strnum(invn[iii]);end;
	6..11:s:=objnam(inv[iii])+' '+strnum(invn[iii])+'%';
	12:s:=strnum(invn[iii]*10)+' OF '+objnam(inv[iii]);
	end;
   say(10,143+(iii*9),1,s);
    end;


  end;
end;
end;


procedure PeopleEdit;
 var done:boolean;
     j,j0:char;
     i,i1:integer;
     w:word;
     yy:byte;
     s:string[25];
begin
 whatcrc:=1;done:=false;
 setupscreen;
 fillscreen;
 repeat
  j:=upcase_sync(readkey);
  if j=#0 then j0:=readkey;
  case j of
   #0:case j0 of
     #59:help;
	
        #34:with crc^[whatcrc] do begin
               loadgraps2(false);
              say(1,183,0,'SELECT UP TO 3 GRAPHIC TILES TO USE');
              say(1,191,0,'FOR ANIMATION (PRESS [ESC] TO STOP)');

              if g2=0 then g2:=g1;
              g2:=grap_select_window(g2,0);

              if g2=0 then begin; g3:=0; g4:=0; end else

              begin
               say(27,183,0,'2');
               if g3=0 then g3:=g2;
               g3:=grap_select_window(g3,0);

               if g3=0 then begin; g4:=g2; end else
                 begin
                   say(27,183,0,'1');
                   if g4=0 then g4:=g3;
                   g4:=grap_select_window(g4,0);


                 end;

              end;

               loadgraps;
               setupscreen;fillscreen;
             end;	
	
     #60:begin;whatcrc:=selectcreature(whatcrc);if whatcrc=0 then whatcrc:=1;
         setupscreen;fillscreen;end;
     #61:begin
      whatcrc:=0;
      for i:=MAXCRCS downto 2 do
       if crc^[i].t=0 then whatcrc:=i;
        if whatcrc=0 then
         begin
          say(1,183,0,'THERE ARE NO EMPTY SLOTS LEFT.     ');
          say(1,191,0,'PRESS A KEY TO CONTINUE.           ');
          if readkey=#0 then if readkey=#59 then help;
          whatcrc:=1;
         end else
        begin;resetcreature(whatcrc);setupscreen;fillscreen;end;
      end;
     #66:begin;yy:=selectcreature(0);if yy>1 then crc^[yy].t:=0;
         if whatcrc=yy then whatcrc:=1;setupscreen;fillscreen;end;
     #68:done:=true;
        #35:if crc^[whatcrc].hm<>0 then
            with crc^[whatcrc] do begin;s:=readlin(34,66,3,1);val(s,i,i1);
            if i1=0 then begin;h:=i;end;
            say(34,66,0,'    ');
            say(34,66,1,strnum(h));end;
{        #50:with crc^[whatcrc] do begin;s:=readlin(34,75,3,1);val(s,i,i1);
            if i1=0 then begin;m:=i;end;
            say(34,75,0,'    ');
            say(34,75,1,strnum(m));end;   }
        #33:if objok then with crc^[whatcrc] do begin
            fr:=selectobj(8,0);setupscreen;fillscreen;end;
    end; {case j0}
        '1'..'3':if objok then with crc^[whatcrc] do begin
            invn[ord(j)-48]:=0;
            inv[ord(j)-48]:=selectobj(105,0);
            if inv[ord(j)-48]<>0 then

            begin
               case j of
                '1':yy:=152;
                '2':yy:=161;
                '3':yy:=170;
               end;
            setupscreen;fillscreen;
			case obj^[inv[ord(j)-48]].t of
			  1..5:say(38,yy,0,' PARAMETER:');
			 6..11:say(38,yy,0,'    % ODDS:');
			    12:say(38,yy,0,'AMOUNT x10:');
				end;
            s:=readlin(62,yy,4,1);
            if s='' then s:=#27;
            val(s,i,i1);if i1=0 then invn[ord(j)-48]:=i;
            end;

            setupscreen;fillscreen;
           end;
{        'Z':with crc^[whatcrc] do begin
               say(15,22,2,'à');
               repeat
                case sz of
                 0:s:='SMALL ';
                 1:s:='NORMAL';
                 2:s:='LARGE ';
                end;
                say(17,22,0,s);
               until updown(sz,0,2)>0;
               setupscreen;fillscreen;
              end;  }
        'Y':with crc^[whatcrc] do
             begin
              say(32,75,2,'à');
              yy:=hi(crcsounds[whatcrc]);
              repeat
               say(34,75,0,soundname(yy));
              until updown(yy,0,NUMSOUNDS)>0;
              w:=yy;
              soundeffect(w,1);
              crcsounds[whatcrc]:=lo(crcsounds[whatcrc]) OR (w*$100);
              setupscreen;fillscreen;
             end;
        'E':with crc^[whatcrc] do
             begin
               {say(50,66,5,' E €0XP: '); }
                say(66,66,0,'     ');
                s:=readlin(66,66,4,1);
                val(s,w,i1);
                if s='' then s:=#27;
                if i1=0 then if s<>#27 then
                 begin
                  exp:=w MOD 256;
                  exphi:= (w DIV 256) +1;
                 end;
                say(66,66,0, strnum((exphi-1)*256 + exp)+'   ' );

             end;
        'Z':with crc^[whatcrc] do
             begin
              say(32,84,2,'à');
              yy:=lo(crcsounds[whatcrc]);
              repeat
               say(34,84,0,soundname(yy));
              until updown(yy,0,NUMSOUNDS)>0;
              w:=yy;
              soundeffect(w,1);
              crcsounds[whatcrc]:=(hi(crcsounds[whatcrc])*$100) OR w;
              setupscreen;fillscreen;
             end;
        'D':with crc^[whatcrc] do
             begin
              say(1,183,0,'SELECT MACRO THAT IS TRIGGERED WHEN');
              say(1,191,0,'THIS CREATURE IS KILLED IN COMBAT. ');
              say(67,143,0,'    ');
              s:=readlin(67,143,3,1);
              val(s,deathm,i1);
              setupscreen;fillscreen;
             end;
        'T':with crc^[whatcrc] do
             begin
              say(1,183,0,'SELECT MACRO THAT IS TRIGGERED WHEN');
              say(1,191,0,'THIS CREATURE TOUCHES THE PLAYER.  ');
              say(67,55,0,'    ');
              s:=readlin(67,55,3,1);
              val(s,touchm,i1);
			  if s='000' then for i1:=1 to MAXCRCS do crc^[i1].touchm:=0;
              setupscreen;fillscreen;
             end;			
        'G':with crc^[whatcrc] do begin
              say(1,183,0,'SELECT A GRAPHIC TILE TO REPRESENT ');
              say(1,191,0,'THIS CREATURE.                     ');

              g1:=grap_select_window(g1,g1);

               loadgraps;
               setupscreen;fillscreen;
             end;

        'V':if objok then with crc^[whatcrc] do begin
             say(1,183,0,'SELECT ITEM FOR "PASSABLE IF HOLDING" ');
             say(1,191,0,'OR A TERRAIN TO CONSTRAIN CREATURE TO.');
             veh:=selectobj(106,0);setupscreen;fillscreen;end;
        'A':with crc^[whatcrc] do begin
               say(17,55,2,'à');
               repeat
                case t of
                 1:s:='GOOD   ';
                 2:s:='EVIL   ';
                 3:s:='NEUTRAL';
                 4:s:='ANIMAL ';
                end;
                say(19,55,0,s);
               until updown(t,1,4)>0;
               say(17,55,1,' '+s);
              end;
(*        'B':with crc^[whatcrc] do begin
               say(57,55,2,'à');
               repeat
                case t1 of
                 0:s:='';
                 1:s:='';
                 2:s:='';
                {3:s:='RABID  ';
                 4:s:='GUARD  ';
                 5:s:='SNIPER ';}
                end;
                say(59,55,0,s);
               until updown(t1,0,2)>0;
               say(57,55,1,' '+s);
              end;  *)
        'F':if objok then with crc^[whatcrc] do begin
             fw:=selectobj(7,0);setupscreen;fillscreen;end;
        'O':if objok then with crc^[whatcrc] do begin
             ar:=selectobj(9,0);setupscreen;fillscreen;end;
        'N':with crc^[whatcrc] do begin;s:=readlin(16,46,16,0);if s<>#27 then
            n:=s;say(16,46,0,'                 ');
            say(16,46,1,n);end;
        'H':with crc^[whatcrc] do begin;s:=readlin(12,66,3,1);val(s,i,i1);
            if i1=0 then begin;hm:=i;h:=i;end;
            say(12,66,0,'    ');
            say(34,66,0,'    ');
            say(12,66,1,strnum(hm));
            say(34,66,1,strnum(h));end;
{        'M':with crc^[whatcrc] do begin;s:=readlin(12,75,3,1);val(s,i,i1);
            if i1=0 then begin;mm:=i;m:=i;end;
            say(12,75,0,'    ');
            say(34,75,0,'    ');
            say(12,75,1,strnum(mm));
            say(34,75,1,strnum(m));end;
        'I':with crc^[whatcrc] do begin;s:=readlin(58,75,3,1);val(s,i,i1);
            if i1=0 then begin;iq:=i;end;
            say(58,75,0,'    ');
            say(58,75,1,strnum(iq));end;
        'S':with crc^[whatcrc] do begin;s:=readlin(58,66,3,1);val(s,i,i1);
            if i1=0 then begin;st:=i;end;
            say(58,66,0,'    ');
            say(58,66,1,strnum(st));end;
}       'W':with crc^[whatcrc] do begin;s:=readlin(24,94,3,1);val(s,i,i1);
            if i1=0 then begin;ws:=i;end;
            say(24,94,0,'    ');
            say(24,94,1,strnum(ws));end;
        'R':with crc^[whatcrc] do begin;s:=readlin(68,94,3,1);val(s,i,i1);
            if i1=0 then begin;rws:=i;end;
            say(68,94,0,'    ');
            say(68,94,1,strnum(rws));end;
(*        'P':with crc^[whatcrc] do begin;s:=readlin(14,103,3,1);val(s,i,i1);
            if i1=0 then begin;spd:=i;end;
            say(14,103,0,'    ');
            say(14,103,1,strnum(spd));end;
*)
  end; {case j}
 until done;
end;
