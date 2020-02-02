function obj_editobj:byte; {=exiting command}
var exchar:char;
    i,i1:integer;
    ss:string[40];
    ww,w:word;
    bb:byte;
procedure obj_getname;
 var i:integer;ss:string[16];
  begin;ss:=readlin(32,38,16,0);
   if ss<>#27 then obj^[wobj].n:=ss;
   for i:=length(obj^[wobj].n)+1 to 16 do
     obj^[wobj].n:=concat(obj^[wobj].n,' ');
   obj_filldata(wobj);
  end;

procedure selectmapcolor;
 var iee:integer; sc_x,sc_y,b,sc_this:byte; done2:boolean; j0:char;
begin








         done2:=false;
         sc_x:=mapcolors[wobj] MOD 16;sc_y:=mapcolors[wobj] DIV 16;
         for iee:=0 to 15 do
          for b:=0 to 15 do
           putthing(5+b,iee*4+110,b+(iee*16));
          say(1,183,0,'SELECT MAP COLOR FOR THIS OBJECT   ');
           say(1,191,0,'ä:ABORT                            ');

         repeat

          putthing(1,4,sc_x+(sc_y*16)); putthing(2,4,sc_x+(sc_y*16));

          iee:=0;
          repeat
           inc(iee);
           if iee=1 then
             putthing(5+sc_x,sc_y*4+110,00);
           if iee=200 then
             putthing(5+sc_x,sc_y*4+110,15);
           if iee=400 then
             putthing(5+sc_x,sc_y*4+110,sc_x+sc_y*16);
           if iee>2400 then iee:=0;
          until keypressed;
          putthing(5+sc_x,sc_y*4+110,sc_x+sc_y*16);
          j0:=upcase_sync(readkey);
          case j0 of
           #0:case readkey of

               #72:if sc_y>0 then dec(sc_y);
               #75:if sc_x>0 then dec(sc_x);
               #77:if sc_x<15 then inc(sc_x);
               #80:if sc_y<15 then inc(sc_y);


              end; {0}

            #32,#13,#27:done2:=true;
          end; {readkey}
         until done2;
         if j0<>#27 then mapcolors[wobj]:=sc_x+sc_y*16;
         obj_blowupobj(wobj);
         obj_filldata(wobj);









end;


begin
exchar:=#0;
obj_blowupobj(wobj);
obj_filldata(wobj);
with obj^[wobj] do begin
repeat
 case t of
  1..5:helpindex:=7;
  6,11,12:helpindex:=41;
  7,8:helpindex:=42;
  9:helpindex:=75;
  10:helpindex:=43;
 end;
 case t of

{********** SPACE ***********}

  1,2:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
        {G}#34:begin
               say(1,183,0,'SELECT ANIMATION GRAPHIC TILE OR   ');
               say(1,191,0,'PRESS [ESC] TO NOT ANIMATE.        ');
               loadgraps2(false);
               d[6]:=grap_select_window(d[6],0);
               loadgraps;
               obj_blowupobj(wobj);
               obj_filldata(wobj);end;
        {A}#30:begin
                helpindex:=44;
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],((d[1]=255) OR (t=1))));
               end;
        {T}#20:begin
                if edittriggerp(d[9],42,74,d[10]) then
               begin;obj_blowupobj(wobj);obj_filldata(wobj);end
               else say(42,74,1,strtriggerp(d[9],d[10]));
               end;
        {P}#25:begin
                helpindex:=46;
                if editpassp(d[4] AND 63,40,93,d[5]) then
               begin;obj_blowupobj(wobj);obj_filldata(wobj);end
               else say(40,93,1,strpassablep(d[4],d[5]));
               end;
           end; {case exchar}
         end; {#0}
        'I':begin
               say(1,183,0,'SELECT THE TILE SHOWN WHEN THE USER');
               say(1,191,0,'IS HERE.                      ä:N/A');
               d[13]:=grap_select_window(0,0);obj_blowupobj(wobj);
               obj_filldata(wobj);end;
		 'V':begin
          d[4]:=d[4] XOR 128;
          obj_filldata(wobj);
          end;
      'L':begin
          d[4]:=d[4] XOR 64;
          obj_filldata(wobj);
          end;

      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
          if t=1 then
		   say(1,191,0,'ESC:ABORT              P:SET ON USE') else
		   say(1,191,0,'ESC:ABORT                          ');
          d[1]:=grap_select_window(d[1],d[1]);
          if (d[1]=255) then d[1]:=0;

          obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'A':begin
           helpindex:=44;
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,ACTMAX)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(30,48,1,straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3], ((d[1]=255) OR (t=1)) ));
          end;
      'T':begin
           say(40,65,2,'à');
           say(42,74,0,'                     ');
           repeat
            say(42,65,0,strtrigger(d[9]));
           until updown(d[9],0,TRIGMAX)>0;
           say(40,65,0,' ');
           d[10]:=0;
           say(42,65,1,strtrigger(d[9]));
           say(42,74,1,strtriggerp(d[9],d[10]));
          end;
      'P':begin
           helpindex:=46;
           i:=d[4] AND 128;
           d[4]:=d[4] AND 63;
           say(38,84,2,'à');
           say(40,93,0,'                     ');
           repeat
            say(40,84,0,strpassable(d[4]));
           until updown(d[4],0,PASSMAX)>0;
           say(38,84,0,' ');
           if d[4]>4 then d[5]:=6 else d[5]:=0;
		   if d[4]>23 then d[5]:=1;
           say(40,84,1,strpassable(d[4]));
           say(40,93,1,strpassablep(d[4],d[5]));
           d[4]:=d[4] OR i;
          end;
      'D':begin
           say(34,151,2,'à');
           repeat
		    if d[8]>3 then say(36,151,0,'USE MACRO...     ') else
            say(36,151,0,strdisappear(d[8]));
           until updown(d[8],0,4)>0;
		   if d[8]=4 then
		    begin
             say(1,183,0,'ENTER MACRO NUMBER TO RUN IF THIS  ');
             say(1,191,0,'TERRAIN IS DESTROYED:              ');			
			 ss:=readlin(45,191,3,1);
             if ss<>#27 then
              begin;val(ss,d[8],i);d[8]:=d[8]+5;end else d[8]:=0;
			
			end;
           say(34,151,0,' ');
           say(36,151,1,strdisappear(d[8]));
           obj_blowupobj(wobj);
           obj_filldata(wobj);		
          end;
       'R':begin
             say(1,183,0,'SELECT THE OBJECT THAT WILL REPLACE');
             say(1,191,0,'THIS IF DESTROYED.   (ä:ELIMINATE) ');
             d[12]:=selectobj(111,0);
             obj_blowupobj(wobj);
             obj_filldata(wobj);
            end;
        'S':begin
             ss:=readlin(56,161,3,1);
             if ss<>#27 then
              val(ss,d[11],i);
             if d[11]=0 then
              say(56,161,1,'N/A') else
              say(56,161,1,concat(strnum(d[11]),'  '));
            end;
        'X':messager(55,130,d[14]);
{        'M':messager(51,101,d[6]); }
        'B':messager(53,115,d[7]);
      end; {case 1,2 case}

{********* OBSTACLE *********}

  3,4:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
        {T}#20:begin
                if edittriggerp(d[9],42,74,d[10]) then
               begin;obj_blowupobj(wobj);obj_filldata(wobj);end
               else say(42,74,1,strtriggerp(d[9],d[10]));
               end;
        {G}#34:begin
               say(1,183,0,'SELECT ANIMATION GRAPHIC TILE OR   ');
               say(1,191,0,'PRESS [ESC] TO NOT ANIMATE.     ');
               loadgraps2(false);
               d[6]:=grap_select_window(d[6],0);
               loadgraps;
               obj_blowupobj(wobj);
               obj_filldata(wobj);end;			
        {A}#30:begin
                helpindex:=44;
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],((d[1]=255) OR (t=3))));
               end;
           end; {case exchar}
         end; {#0}
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
          if t=3 then
		   say(1,191,0,'ESC:ABORT              P:SET ON USE') else
		   say(1,191,0,'ESC:ABORT                          ');
          d[1]:=grap_select_window(d[1],d[1]);
          if (d[1]=255) or (d[1]=0) then d[1]:=240;
          obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'V':begin
          d[4]:=d[4] XOR 128;
          obj_filldata(wobj);
          end;
      'L':begin
          d[4]:=d[4] XOR 64;
          obj_filldata(wobj);
          end;

      'A':begin
           helpindex:=44;
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,ACTMAX)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(30,48,1,straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3], ((d[1]=255) OR (t=3)) ));
          end;
      'D':begin
           say(34,151,2,'à');
           repeat
		    if d[8]>1 then say(36,151,0,'USE MACRO...     ') else
            say(36,151,0,strdisappear(d[8]));
           until updown(d[8],0,2)>0;
		   if d[8]=2 then
		    begin
             say(1,183,0,'ENTER MACRO NUMBER TO RUN IF THIS  ');
             say(1,191,0,'TERRAIN IS DESTROYED:              ');			
			 ss:=readlin(45,191,3,1);
             if ss<>#27 then
              begin;val(ss,d[8],i);d[8]:=d[8]+5;end else d[8]:=0;
			
			end;
           say(34,151,0,' ');
           say(36,151,1,strdisappear(d[8]));
           obj_blowupobj(wobj);
           obj_filldata(wobj);		
          end;

       'R':begin
             say(1,183,0,'SELECT THE OBJECT THAT WILL REPLACE');
             say(1,191,0,'THIS IF DESTROYED.   (ä:ELIMINATE) ');
             d[12]:=selectobj(111,0);
             obj_blowupobj(wobj);
             obj_filldata(wobj);
            end;
        'S':begin
             ss:=readlin(56,158,3,1);
             if ss<>#27 then
              val(ss,d[11],i);
             if d[11]=0 then
              say(56,158,1,'N/A') else
              say(56,158,1,concat(strnum(d[11]),'  '));
            end;
       'T':begin
            say(40,65,2,'à');
            say(42,74,0,'                     ');
            repeat
             say(42,65,0,strtrigger(d[9]));
            until updown(d[9],O_TRIGMIN,O_TRIGMAX)>0;
            say(40,65,0,' ');
            d[10]:=0;
            say(42,65,1,strtrigger(d[9]));
            say(42,74,1,strtriggerp(d[9],d[10]));
           end;
        'X':messager(55,126,d[14]);
        'B':messager(53,106,d[7]);
      end; {case 3,4 case}

{********** PORTAL ***********}

   5:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
		  {A}#30:begin
                helpindex:=44;
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],true));
               end;
        {G}#34:begin
               say(1,183,0,'SELECT ANIMATION GRAPHIC TILE OR   ');
               say(1,191,0,'PRESS [ESC] TO NOT ANIMATE.     ');
               loadgraps2(false);
               d[6]:=grap_select_window(d[6],0);
               loadgraps;
               obj_blowupobj(wobj);
               obj_filldata(wobj);end;			
        {T}#20:begin
                if edittriggerp(d[9],42,74,d[10]) then
               begin;obj_blowupobj(wobj);obj_filldata(wobj);end
               else say(40,74,1,' '+strtriggerp(d[9],d[10]));
               end;
        {P}#25:begin
                helpindex:=46;
                if editpassp(d[4] AND 63,40,93,d[5]) then
               begin;obj_blowupobj(wobj);obj_filldata(wobj);end
               else say(38,93,1,' '+strpassablep(d[4],d[5]));
               end;
           end; {case exchar}
         end; {#0}
      'V':begin
          d[4]:=d[4] XOR 128;
          obj_filldata(wobj);
          end;
      'L':begin
          d[4]:=d[4] XOR 64;
          obj_filldata(wobj);
          end;

      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
          say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);
          if (d[1]=255) or (d[1]=0) then d[1]:=240;
          obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'A':begin
           helpindex:=44;
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,ACTMAX)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(30,48,1,straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3],true));
          end;
      'T':begin
           say(40,65,2,'à');
           say(42,74,0,'                     ');
           repeat
            say(42,65,0,strtrigger(d[9]));
           until updown(d[9],0,TRIGMAX)>0;
           say(40,65,0,' ');
           d[10]:=0;
           say(42,65,1,strtrigger(d[9]));
           say(42,74,1,strtriggerp(d[9],d[10]));
          end;
      'P':begin
           helpindex:=46;
           i:=d[4] AND 128;
           d[4]:=d[4] AND 63;
           say(38,84,2,'à');
           say(40,93,0,'                     ');
           repeat
            say(40,84,0,strpassable(d[4]));
           until updown(d[4],0,PASSMAX)>0;
           say(38,84,0,' ');
           if d[4]>4 then d[5]:=6 else d[5]:=0;
           say(40,84,1,strpassable(d[4]));
           say(40,93,1,strpassablep(d[4],d[5]));
           d[4]:=d[4] OR i;
          end;
      'D':begin
           say(34,151,2,'à');
           repeat
            say(36,151,0,strdisappear(d[8]));
           until updown(d[8],0,3)>0;
           say(34,151,0,' ');
           say(36,151,1,strdisappear(d[8]));
          end;
       'R':begin
             if d[8]=3 then
              begin
               say(1,183,0,'SELECT THE TERRAIN THAT WILL       ');
               say(1,191,0,'APPEAR WHILE PORTAL IS IMPASSABLE. ');
               d[12]:=selectobj(105,wobj);
              end else
              begin
               say(1,183,0,'SELECT THE PORTAL THAT WILL REPLACE');
               say(1,191,0,'THIS IF DESTROYED.                 ');
               d[12]:=selectobj(5,wobj);
              end;


             obj_blowupobj(wobj);
             obj_filldata(wobj);
            end;
        'S':begin
             ss:=readlin(56,161,3,1);
             if ss<>#27 then
              val(ss,d[11],i);
             if d[11]=0 then
              say(56,161,1,'N/A') else
              say(56,161,1,concat(strnum(d[11]),'  '));
            end;
        'X':messager(55,130,d[14]);
        'M':messager(51,101,d[13]);
        'B':messager(53,115,d[7]);
      end; {case 5 case}

{********** MISC ITEM ***********}

  6:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
		  {R}#19:if d[4]<>0 then
          begin
           if d[4]=255 then
            begin
             say(1,183,0,'ENTER THE AMOUNT OF ENERGY THAT EACH');
             say(1,191,0,'USAGE WILL DRAIN FROM THE PLAYER.   ');
             say(42,74,0,'     M.P.');
            end else
            begin
             say(1,183,0,'ENTER THE ODDS OF THE REQUIRED ITEM');
             say(1,191,0,'BEING DELETED FOR EACH USAGE.      ');
             say(42,74,0,'    %');
            end;
             ss:=readlin(42,74,3,1);
             if ss<>#27 then
              val(ss,d[5],i);
              if (d[5]>100) and (d[4]<>255) then d[5]:=100;
              if d[4]<>255 then
               say(42,74,1,concat(strnum(d[5]),'%    ')) else
               say(42,74,1,strnum(d[5])+' M.P.     ');
              say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
              say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
               end;
        {A}#30:begin
                helpindex:=44;
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],true));
               end;
           end; {case exchar}
         end; {#0}
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
           say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);
          obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'R':begin
           say(1,183,0,'SELECT THE ITEM THAT USAGE REQUIRES.');
           say(1,191,0,'(ÉÑC: ENERGY, ä: NOTHING)           ');
          d[4]:=selectobj(102,0);
          obj_blowupobj(wobj);
          obj_filldata(wobj);
         end;
      'A':begin
           helpindex:=44;
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,ACTMAX)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(30,48,1,straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3],true));
          end;
      'D':begin
           say(34,134,2,'à');
           repeat
            if d[6]<>0 then say(36,134,0,'AFTER USE') else
                            say(36,134,0,'NO.      ');
           until updown(d[6],0,1)>0;
            if d[6]<>0 then say(34,134,1,' AFTER USE') else
                            say(34,134,1,' NO.      ');
          end;
        'X':messager(55,113,d[14]);
        'M':messager(50,84,d[7]);
        'I':messager(61,98,d[8]);
        'W':begin
             ss:=readlin(30,144,5,1);
			 if ss='00' then ss:='30001';			
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;
			
			  w:=(d[9]*256)+d[10];
	          if w>30000 then say(30,144,1,'NO DROP  ')
	           else say(30,144,1,strnum( w )+'        ');

               end;
        'P':begin
             ss:=readlin(30,154,5,1);

             if ss<>#27 then
              begin;val(ss,ww,i);d[11]:=hi(ww);d[12]:=lo(ww);end;
              say(30,154,1,strnum( (d[11]*256)+d[12])+'     ');
               end;
     end; {case 6 case}

{********** WEAPON ***********}

  7:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
		  {G}#34:begin
               say(1,183,0,'SELECT THE TILE SHOWN WHEN THE USER');
               say(1,191,0,'IS HOLDING WEAPON.    ä:NORMAL ICON');
               d[13]:=grap_select_window(d[13],0);obj_blowupobj(wobj);
               obj_filldata(wobj);end;
  (*      {A}#30:begin
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],true));
               end;          *)
           end; {case exchar}
         end; {#0}
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
          say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'D':begin
             ss:=readlin(40,91,3,1);
             if ss<>#27 then
              val(ss,d[4],i);
              say(40,91,1,strnum(d[4])+'   ');
               end;
(*      'A':begin
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,37)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(28,48,1,' '+straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3],true));
          end;  *)
      'X':messager(55,77,d[14]);
      'M':messager(50,65,d[5]);
           'S':begin
             say(40,120,2,'à');
             repeat
              say(42,120,0,soundname(d[2]));
             until updown(d[2],0,NUMSOUNDS)>0;
             say(40,120,1,' '+soundname(d[2]));
             soundeffect(d[2],1);
            end;
        'W':begin
             ss:=readlin(30,101,5,1);
			 if ss='00' then ss:='30001';			
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;
			  w:=(d[9]*256)+d[10];
	          if w>30000 then say(30,101,1,'NO DROP  ')
	           else say(30,101,1,strnum( w )+'        ');

               end;
        'P':begin
             ss:=readlin(30,111,5,1);
             if ss<>#27 then
              begin;val(ss,ww,i);d[11]:=hi(ww);d[12]:=lo(ww);end;
              say(30,111,1,strnum( (d[11]*256)+d[12])+'     ');
               end;
      end; {case 7 case}

{********** RANGED WEAPON ***********}

  8:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
		  {A}#30:if d[6]<>0 then begin
           if d[6]=255 then
            begin
             say(1,183,0,'ENTER THE AMOUNT OF ENERGY THAT EACH');
             say(1,191,0,'USAGE WILL DRAIN FROM THE PLAYER.   ');
             say(40,57,0,'     M.P.');
            end else
            begin
             say(1,183,0,'ENTER THE ODDS OF THE REQUIRED ITEM');
             say(1,191,0,'BEING DELETED FOR EACH USAGE.      ');
             say(40,57,0,'    %');
            end;
             ss:=readlin(40,57,3,1);
             if ss<>#27 then
              val(ss,d[7],i);
              if (d[7]>100) and (d[6]<>255) then d[7]:=100;
              if d[6]<>255 then
               say(40,57,1,concat(strnum(d[7]),'%    ')) else
               say(40,57,1,strnum(d[7])+' M.P.     ');
              if d[7]>100 then d[7]:=100;
              say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
              say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
               end;
        {R}#19:begin
                say(1,183,0,'SELECT THE PROJECTILE TYPE.        ');
                say(1,191,0,'PINPOINT, BLAST RADIUS, OR CONE.   ');
                bb:=hinyb(d[5]);
                say(26,110,2,'à');
                repeat
                 say(28,110,0,strblastradius(bb));
                until updown(bb,0,12)>0;
                say(26,110,1,' '+strblastradius(bb));
                sethinyb(d[5],bb);
               say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
               say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
               end;
        {G}#34:begin
               say(1,183,0,'SELECT THE TILE SHOWN WHEN THE USER');
               say(1,191,0,'IS HOLDING WEAPON.    ä:NORMAL ICON');
               d[13]:=grap_select_window(d[13],0);obj_blowupobj(wobj);
               obj_filldata(wobj);end;
           end; {case exchar}
         end; {#0}
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
           say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'D':begin
             ss:=readlin(40,91,3,1);
             if ss<>#27 then
              val(ss,d[4],i);
              say(40,91,1,strnum(d[4])+'   ');
               end;
      'A':begin
           say(1,183,0,'SELECT THE AMMO THAT USAGE REQUIRES.');
           say(1,191,0,'(ÉÑE = ENERGY, ä: NOTHING REQUIRED) ');
          d[6]:=selectobj(102,0);
          obj_blowupobj(wobj);
          obj_filldata(wobj);
         end;
        'X':messager(55,77,d[14]);
        'M':messager(61,65,d[8]);
        'R':begin
               bb:=lonyb(d[5]);
               say(26,101,2,'à');
               repeat
                say(28,101,0,strnum(bb+1)+' ');
               until updown(bb,0,15)>0;
               say(26,101,1,' '+strnum(bb+1));
               setlonyb(d[5],bb);
              end;
        'S':begin
             say(40,120,2,'à');
             repeat
              say(42,120,0,soundname(d[2]));
             until updown(d[2],0,NUMSOUNDS)>0;
             say(40,120,1,' '+soundname(d[2]));
             soundeffect(d[2],1);
            end;
        'I':begin
             say(1,183,0,'SELECT THE GRAPHICS USED TO SHOW   ');
             say(1,191,0,'THE PROJECTILE.                    ');
             say(24,128,2,'à');
             case d[3] of
              0:d[3]:=246;
              1..240:d[3]:=245;
             end;
             say(26,136,0,'  ');
             repeat
              case d[3] of
               241:ss:='DOT   ';
               242:ss:='LINE  ';
               243:ss:='BALL  ';
               244:ss:='BEAM  ';
               245:ss:='(TILE)';
               246:ss:='NONE  ';
              end;
             say(26,128,0,ss);
            until updown(d[3],241,246)>0;
            if d[3]=246 then d[3]:=0;
            if d[3]=245 then
              d[3]:=grap_select_window(0,0);
              obj_blowupobj(wobj);
              obj_filldata(wobj);
             end;
        'W':begin
             ss:=readlin(30,148,5,1);
			 if ss='00' then ss:='30001';			
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;
			  w:=(d[9]*256)+d[10];
	          if w>30000 then say(30,148,1,'NO DROP  ')
	           else say(30,148,1,strnum( w )+'        ');

               end;
        'P':begin
             ss:=readlin(30,158,5,1);
             if ss<>#27 then
              begin;val(ss,ww,i);d[11]:=hi(ww);d[12]:=lo(ww);end;
              say(30,158,1,strnum( (d[11]*256)+d[12])+'     ');
               end;
     end; {case 8 case}

{********* ARMOR *********}

  9:case upcase_sync(readkey) of
      #0:begin
         exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
        {G}#34:if d[2]=1 then
              begin
               say(1,183,0,'SELECT THE TILE SHOWN WHEN THE USER');
               say(1,191,0,'IS WEARING ARMOR.     ä:NORMAL ICON');
               d[13]:=grap_select_window(d[13],0);obj_blowupobj(wobj);
               obj_filldata(wobj);
              end else
              begin
               say(1,183,0,'ONLY TYPE-1 ARMOR MAY HAVE THE     ');
               say(1,191,0,'IN-USE GRAPHIC TILE.  PRESS A KEY. ');
               if readkey=#0 then if readkey=#59 then help;
              end;
          end;
         end;
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
          say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'D':begin
             ss:=readlin(48,78,3,1);
             if ss<>#27 then
              val(ss,d[5],i);
              say(48,78,1,strnum(d[5])+'   ');
               end;
      'T':begin
             ss:=readlin(48,48,2,1);
             if ss<>#27 then
              val(ss,d[2],i);
              if d[2]>7 then d[2]:=7;
              say(48,48,1,strnum(d[2])+'   ');
               end;
        'C':begin
             say(46,57,0,'    %');
             ss:=readlin(46,57,3,1);
             if ss<>#27 then
              val(ss,d[6],i);
              if d[6]>100 then d[6]:=100;
              say(46,57,1,concat(strnum(d[6]),'%    '));
               end;
    (*   'I':begin
             say(1,183,0,'SELECT THE WEAPON THAT IS BUILT    ');
             say(1,191,0,'INTO THIS ARMOR.      (ä:NOTHING)  ');
             d[4]:=selectobj(104,0);
             obj_blowupobj(wobj);
             obj_filldata(wobj);
          end; *)
        'X':messager(55,108,d[14]);
        'W':begin
             ss:=readlin(30,88,5,1);
			 if ss='00' then ss:='30001';			
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;

			  w:=(d[9]*256)+d[10];
	          if w>30000 then say(30,88,1,'NO DROP  ')
	           else say(30,88,1,strnum( w )+'        ');
               end;
        'P':begin
             ss:=readlin(30,98,5,1);
             if ss<>#27 then
              begin;val(ss,ww,i);d[11]:=hi(ww);d[12]:=lo(ww);end;
              say(30,98,1,strnum( (d[11]*256)+d[12])+'     ');
               end;
      end; {case 9 case}

{********** VEHICLE ***********}

  10:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
		{M}#50:selectmapcolor;
        {F}#33:if d[6]<>0 then begin
           if d[6]=255 then
            begin
             say(1,183,0,'ENTER THE AMOUNT OF ENERGY THAT EACH');
             say(1,191,0,'USAGE WILL DRAIN FROM THE PLAYER.   ');
             say(40,96,0,'    M.P.');
            end else
            begin
             say(1,183,0,'ENTER THE ODDS OF THE REQUIRED ITEM');
             say(1,191,0,'BEING DELETED FOR EACH USAGE.      ');
             say(40,96,0,'    %');
            end;
             ss:=readlin(40,96,3,1);
             if ss<>#27 then
              val(ss,d[7],i);
              if (d[7]>100) and (d[6]<>255) then d[7]:=100;
              if d[6]<>255 then
               say(40,96,1,concat(strnum(d[7]),'%    ')) else
               say(40,96,1,strnum(d[7])+' M.P.     ');
           say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
           say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
               end;
        {G}#34:begin
               say(1,183,0,'SELECT THE TILE SHOWN WHEN THE USER');
               say(1,191,0,'IS USING VEHICLE.     ä:NORMAL ICON');
               d[13]:=grap_select_window(d[13],0);obj_blowupobj(wobj);
               obj_filldata(wobj);end;
         {C}#46:begin
           say(34,67,2,'à');
           repeat
            if d[3]<>0 then say(36,67,0,'ONLY WHERE NEEDED ')
            else say(36,67,0,'WHERE USER CAN    ');
           until updown(d[3],0,1)>0;
            if d[3]<>0 then say(34,67,1,' ONLY WHERE NEEDED ')
            else say(34,67,1,' WHERE USER CAN    ');
                end;
        {alt-B} #48:begin

             say(1,183,0,'ENTER A MACRO TO RUN WHEN THE      ');
             say(1,191,0,'PLAYER TRIES TO BOARD.             ');
             say(41,151,0,'     ');
             ss:=readlin(41,151,3,1);
             if ss<>#27 then
              val(ss,d[5],i);
             obj_blowupobj(wobj);
             obj_filldata(wobj);


                end;
        {alt-X} #45:begin

             say(1,183,0,'ENTER A MACRO TO RUN WHEN THE      ');
             say(1,191,0,'PLAYER EXITS THE VEHICLE.          ');
             say(33,161,0,'     ');
             ss:=readlin(33,161,3,1);
             if ss<>#27 then
              val(ss,d[12],i);
             obj_blowupobj(wobj);
             obj_filldata(wobj);

                end;

           end; {case exchar}
         end; {#0}
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
           say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
      'F':begin
           say(1,183,0,'SELECT THE FUEL THAT USAGE REQUIRES.');
           say(1,191,0,'(ÉÑC: ENERGY, ä: NOTHING)           ');
          d[6]:=selectobj(102,0);
          obj_blowupobj(wobj);
          obj_filldata(wobj);
         end;
(*      'S':begin
           say(50,77,2,'à');
           repeat
            say(52,77,0,strnum(d[5])+' ');
           until updown(d[5],1,50)>0;
            say(50,77,1,' '+strnum(d[5])+' ');
          end;
  *)    'X':messager(55,132,d[14]);
        'M':messager(61,104,d[8]);
        'B':messager(55,119,d[11]);
        'I':begin
             say(1,183,0,'SELECT THE WEAPON THAT IS BUILT    ');
             say(1,191,0,'INTO THIS VEHICLE.    (ä:NOTHING)  ');
             d[4]:=selectobj(104,0);
             obj_blowupobj(wobj);
             obj_filldata(wobj);
          end;
        'C':begin
             say(1,175,0,'WHAT DOES THIS VEHICLE COUNT AS FOR');
             say(1,183,0,'"PASSABLE ONLY TO ___" SITUATIONS? ');
             say(1,191,0,'(ä:VEHICLE COUNTS AS ITSELF.)      ');
             d[2]:=selectobj(103,0);
             obj_blowupobj(wobj);
             obj_filldata(wobj);
            end;
        'W':begin
             ss:=readlin(46,141,5,1);
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;
              say(46,141,1,strnum( (d[9]*256)+d[10])+'     ');
               end;

     end; {case 10 case}

{********** SPELL/SKILL ***********}

  11:case upcase_sync(readkey) of
      #0:begin
          exchar:=readkey;
          case exchar of
         {alt-2} #121:if d[9]<>0 then begin
                       helpindex:=44;
                       if editactionp(d[9],30,76,d[10]) then
                        begin
                           obj_blowupobj(wobj);
                           obj_filldata(wobj);
                        end else say(28,76,1,' '+stractionp(d[9],d[10],true));


                      end;
        {R}#19:if d[4]<>0 then begin
             say(1,183,0,'ENTER THE ODDS OF THE REQUIRED ITEM');
             say(1,191,0,'BEING DELETED FOR EACH USAGE.      ');
             say(42,94,0,'    %');
             ss:=readlin(42,94,3,1);
             if ss<>#27 then
              val(ss,d[5],i);
              if d[5]>100 then d[5]:=100;
              say(42,94,1,concat(strnum(d[5]),'%    '));
           say(1,183,0,' €6 F2 €0       €6 F3 €0      €6 F8 €0     €6 Fç ');
           say(1,191,0,'SELECT     CREATE    DELETE    EXIT');
               end;
        {A}#30:begin
                helpindex:=44;
                if editactionp(d[2],30,57,d[3]) then
               begin
                obj_blowupobj(wobj);
                obj_filldata(wobj);
             end else say(28,57,1,' '+stractionp(d[2],d[3],true));
               end;
           end; {case exchar}
         end; {#0}
      'N':obj_getname;
      'R':begin
             say(1,183,0,'SELECT THE ITEM THAT CASTING OF    ');
             say(1,191,0,'THIS SPELL REQUIRES.  (ä:NOTHING)  ');
          d[4]:=selectobj(102,0);
          obj_blowupobj(wobj);
          obj_filldata(wobj);
         end;
      'A':begin
           helpindex:=44;
           say(28,48,2,'à');
           say(30,57,0,'                     ');
           repeat
            say(30,48,0,straction(d[2]));
           until updown(d[2],0,ACTMAX)>0;
           say(28,48,0,' ');
           d[3]:=presetaction(d[2]);
           say(30,48,1,straction(d[2]));
           say(30,57,1,stractionp(d[2],d[3],true));
          end;
     '2':begin
           helpindex:=44;
           say(28,67,2,'à');
           say(30,76,0,'                     ');
           repeat
            say(30,67,0,straction(d[9]));
           until updown(d[9],0,ACTMAX)>0;
           say(28,67,0,' ');
           d[10]:=presetaction(d[9]);
           say(30,67,1,straction(d[9]));
           say(30,76,1,stractionp(d[9],d[10],true));
          end;
      'D':begin
           say(34,154,2,'à');
           repeat
            if d[6]<>0 then say(36,154,0,'AFTER USE') else
                            say(36,154,0,'NO.      ');
           until updown(d[6],0,1)>0;
            if d[6]<>0 then say(34,154,1,' AFTER USE') else
                            say(34,154,1,' NO.      ');
          end;
        'M':messager(50,104,d[7]);
        'I':messager(61,128,d[8]);
        'P':begin
             ss:=readlin(50,164,3,1);
             if ss<>#27 then
              val(ss,d[11],i);
             say(50,164,1,strnum(d[11])+'  ');
               end;
     end; {case 11 case}

{********** CURRENCY ***********}

  12:case upcase_sync(readkey) of
      #0:begin
	      exchar:=readkey;
		  if exchar=#50 then selectmapcolor;
		 end;
	
      'G':begin
          say(1,183,0,'SELECT GRAPHIC TILE FOR THIS OBJECT');
           say(1,191,0,'ä:ABORT                            ');
          d[1]:=grap_select_window(d[1],d[1]);obj_blowupobj(wobj);
          obj_filldata(wobj);end;
      'N':obj_getname;
        'X':messager(55,68,d[14]);
        'W':begin
             ss:=readlin(30,48,5,1);
             if ss<>#27 then
              begin;val(ss,ww,i);d[9]:=hi(ww);d[10]:=lo(ww);end;
              say(30,48,1,strnum( (d[9]*256)+d[10])+'     ');
               end;
     end; {case 12 case}
    else case upcase_sync(readkey) of
          #0:begin
             exchar:=readkey;
             {case exchar}
             end;
          {case char}
       end; {case else case}
end; {CASE}
 case exchar of
  #60,#61,#66,#68:begin end;
  #59:begin;help;exchar:=#0;end;
   else exchar:=#0;end;   {68=f10}
until exchar<>#0;
obj_editobj:=ord(exchar);
end; {with do}
end; {procedure}
