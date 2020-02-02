var palcolor:array[0..9] of byte;
    zero:byte;
    lastbmp:string;
    using_animtiles:boolean;
	tmask:integer;
	tmask1,tmask2:byte;

procedure putcheckeredthing(xx,yy,ty1,ty2:integer);
var i:integer;
    tyy:byte;
begin

 xx:=xx*4;
 fillchar(mem[scrnl:xx+scrnh[yy+1]],2,ty1);fillchar(mem[scrnl:xx+2+scrnh[yy+1]],2,ty2);
 fillchar(mem[scrnl:xx+scrnh[yy+2]],2,ty1);fillchar(mem[scrnl:xx+2+scrnh[yy+2]],2,ty2);
 fillchar(mem[scrnl:xx+scrnh[yy+3]],2,ty2);fillchar(mem[scrnl:xx+2+scrnh[yy+3]],2,ty1);
 fillchar(mem[scrnl:xx+scrnh[yy+4]],2,ty2);fillchar(mem[scrnl:xx+2+scrnh[yy+4]],2,ty1);

end;	
	
(*	
procedure puthalfthing(xx,yy,ty1,ty2:integer);
var i:integer;          { This service is NOT used by EGA. }
    tyy1,tyy2:byte;
begin
 if mouseon then hidemouse;
 case ty1 of
  0,4:tyy1:=0;
  1,2,3,5,6,7:tyy1:=240;
 end;
 if ty1>3 then tyy1:=tyy1 XOR 160;
 case ty2 of
  0,4:tyy2:=0;
  1,2,3,5,6,7:tyy2:=15;
 end;
 if ty2>3 then tyy2:=tyy2 XOR 10;
 for i:=yy+1 to yy+4 do mem[scrnl:xx+scrnh[i]]:=tyy1+tyy2;
  if mouseon then showmouse;
end;
*)

procedure initgraps;
var i,i1,i2:integer;
begin
 for i:=1 to GRAPS do
  for i1:=1 to 16 do
   for i2:=1 to 16 do
    graphic^[i,i2,i1]:=0;
 end;


procedure savegraps;
var bf:file;
    i:integer;
    fn:string;
begin
 if using_animtiles then fn:=concat(ADVNAME,'.GR2') else fn:=concat(ADVNAME,GRAPHICSFILE);
 assign(bf,fn);
 {$I-} rewrite(bf,256); {$I+}
 if ioresult<>0 then begin;sound(100);delay(100);nosound;exit;end;
 for i:=1 to GRAPS do blockwrite(bf,graphic^[i],1);
 close(bf);
end;


procedure importbmpgrap(thisgrap:byte);

var name:string;
    cursorx,cursory:integer;
    done:boolean;
    j:char;
    dpal:array[0..255,0..2] of byte;
    i:byte;

function displaybmp:boolean;
var bmpf:file;
    i,i2:integer;
    b,t:byte;
    pal2:array[0..255,0..2] of byte;
    header:Array[1..54] of byte;
begin
               {first 54 bytes: header}
               {next 1024- bytes: pal in B-G-R-0}
               {next 64000 bytes: bitmap itself}

               {clear screen}
               {load new palette}

              assign(bmpf,name);
              {$I-} reset(bmpf,1); {$I+}
              if ioresult=0 then

             begin

              BlockRead(bmpf,header,SizeOf(header));
              {load and discard header}

              i2:=header[51];
              if i2=0 then i2:=256;
              for i:=0 to i2-1 do
               begin
                blockread(bmpf,pal2[i,2],1);
                blockread(bmpf,pal2[i,1],1);
                blockread(bmpf,pal2[i,0],1);
                blockread(bmpf,i1,1);
               end;
              {load palette off disk}

              for i:=0 to 255 do for i2:=0 to 2 do
               pal2[i,i2]:=pal2[i,i2] SHR 2;
              clearscreen;
              {clear screen}

              {load palette into video}
              greg.ax:=$1012;
              greg.bx:=0;
              greg.cx:=256;
              greg.es:=seg(pal2[0,0]);
              greg.dx:=ofs(pal2[0,0]);
              intr($10,greg);


              {load and display picture}

              for i:=199 downto 0 do
               BlockRead(bmpf,mem[$A000:i*320],320);


              close(bmpf);
              displaybmp:=true;
              end else displaybmp:=false; {if ioresult=0}
end; {displaybmp}

procedure placecursor(m:byte);
var x,y:integer;

procedure draw;
begin
  if (x>=0) and (y>=0) and (x<320) and (y<200) then
   mem[scrnl:x+scrnh[y]]:=mem[scrnl:x+scrnh[y]] XOR m;
end;

begin

x:=cursorx-1;for y:=cursory to cursory+15 do draw;

y:=cursory-1;for x:=cursorx-1 to cursorx+16 do draw;

x:=cursorx+16;for y:=cursory to cursory+15 do draw;

y:=cursory+16;for x:=cursorx-1 to cursorx+16 do draw;

end;


{$I I_GETIMP.PAS}





begin
  clearscreen;

  {I think this saves the palette}
  greg.ax:=$1017;
  greg.bx:=0;
  greg.cx:=256;
  greg.es:=seg(dpal[0,0]);
  greg.dx:=ofs(dpal[0,0]);
  intr($10,greg);

  name:='';
  cursorx:=152;cursory:=88;


  name:=getimportfilename(true,lastbmp);

{

  say(1,34,0,'ENTER THE PATH AND NAME OF A BMP FILE');
  say(1,44,0,'IN THE ACK\IMPORT FOLDER TO USE.');
  say(1,54,0,'PRESS [ESC] TO ABORT, OR PRESS [ENTER]');
  say(1,64,0,'TO USE THE MOST RECENT BMP AGAIN.');

  name:=readlin(1,94,38,0);
  if name='' then name:=lastbmp; }


  if (name='') or (name=#27) then exit;
  if displaybmp then
   begin
     lastbmp:=name;
     done:=false;

     repeat
       repeat
        placecursor(2);
        placecursor(2);
        placecursor(1);
        placecursor(1);
       until keypressed;
       j:=readkey;
       case j of
         #32,#13:begin
                  done:=true;
                  for i:=0 to 15 do
                   move(mem[scrnl:cursorx+scrnh[cursory+i]],graphic^[thisgrap,i+1],16);
                 end;
         #27:done:=true;
         #0:case readkey of
              #72:if cursory>0 then dec(cursory);
              #80:if cursory<199 then inc(cursory);
              #75:if cursorx>0 then dec(cursorx);
              #77:if cursorx<319 then inc(cursorx);
              #115:if cursorx>15 then cursorx:=cursorx-16;
              #116:if cursorx<304 then cursorx:=cursorx+16;
              #73:if cursory>15 then cursory:=cursory-16;
              #81:if cursory<183 then cursory:=cursory+16;
            end; {0case}
       end; {case}

     until done;
      {I think this reloads the palette}
      greg.ax:=$1012;
      greg.bx:=0;
      greg.cx:=256;
      greg.es:=seg(dpal[0,0]);
      greg.dx:=ofs(dpal[0,0]);
      intr($10,greg);

   end;
end; {import}



procedure grpedit_setupscreen;
begin
{graphicsmode;}
ge_whatchar:=1;
{loadgraps;}
{loadfont;}
clearscreen;
setcolor(getmaxcolor);
(*line(114*xmlt,106,114*xmlt,173);line(114*xmlt,106,181*xmlt,106);
line(181*xmlt,173,181*xmlt,106);line(181*xmlt,173,114*xmlt,173);
{border for selection area}
line(14*xmlt,0,209*xmlt,0);line(14*xmlt,0,14*xmlt,57);
line(209*xmlt,57,209*xmlt,0);line(209*xmlt,57,14*xmlt,57);*)
end;

procedure showallgraps;
var page,i:integer;
begin
 case ge_whatchar of
  1..24:page:=1;
  25..48:page:=25;
  49..72:page:=49;
  73..96:page:=73;
  97..120:page:=97;
  121..144:page:=121;
  145..168:page:=145;
  169..192:page:=169;
  193..216:page:=193;
  217..240:page:=217;
  end;
 for i:=page to page+7 do
   putgrap((i-page+1)*6,2,i);
 for i:=page+8 to page+15 do
   putgrap((i-page-8+1)*6,21,i);
 for i:=page+16 to page+23 do
   putgrap((i-page-16+1)*6,40,i);
end;

(*
procedure hiresdispblock(bb:byte);
var updown,bytes,bits:integer;
   n,nn1,nn2:byte;
begin
 if mouseon then hidemouse;
 for updown:=1 to 16 do
  for bytes:=1 to 4 do
    begin
     n:=graphic^[bb,updown,bytes];
     for bits:=4 DOWNTO 1 do
      begin
       nn1:=n AND 1;
       n:=n SHR 1;
       nn2:=n AND 1;
       n:=n SHR 1;
       puthalfthing(25+(bytes*4)+(bits),(updown*4)+104,nn2,nn1);
      end;
     end;
  if mouseon then showmouse;
 end;
*)

procedure dispblock(bb:byte);
var updown,bytes,bits:integer;
   n,nn:byte;
begin
 if mouseon then hidemouse;
{ if HIRES then begin;hiresdispblock(bb);exit;end; }
 for updown:=1 to 16 do
  for bytes:=1 to 16 do
     begin
      n:=graphic^[bb,updown,bytes];
      if n<>tmask then
	   putthing(29+(bytes),(updown*4)+103,n)
	   else putcheckeredthing(29+(bytes),(updown*4)+103,tmask1,tmask2);
     end;
  if mouseon then showmouse;
 end;



procedure grpedit_showdemo(bb:byte);
begin
 putgrap(52,110,bb);
 putgrap(52,134,bb);
 putgrap(56,134,bb);
 putgrap(56,150,bb);
 putgrap(52,150,bb);
end;

{
procedure getforeignpalette;
var f:file of byte;
    i:byte;
	pal:array[0..255,0..2] of byte;
begin
 assign(f,'\PALETTE.DAT');
 reset(f);
 for i:=0 to 255 do
  begin
   read(f,pal[i,0]);
   read(f,pal[i,1]);
   read(f,pal[i,2]);

  end;

 greg.ax:=$1012;
 greg.bx:=0;
 greg.cx:=256;
 greg.es:=seg(pal[0,0]);
 greg.dx:=ofs(pal[0,0]);
 intr($10,greg);



end;
}

procedure grpedit_selectchar;
var
   done:boolean;
   whatbefore:byte;
   i,i1,i2:integer;
   pg:byte;
  s:string;
  j:char;
begin
  say(1,108,3,'  EDIT  ');
  say(55,4,6,'  SELECT  ');
  say(1,118,1,'             ');
  say(1,128,1,'              ');
  say(1,138,1,'             ');
  say(1,148,1,'             ');
  say(1,158,1,'             ');
  say(1,168,1,'             ');

  say(55,14,1,'…†:EDIT ');
  say(55,24,1,'‡ˆ:NEW PAGE ');
  say(55,34,1,'ˆ‰ TO MOVE ');
  say(55,44,1,'T: TILESET');
  say(55,54,1,'F TO EXIT ');
  if using_animtiles then say(16,61,1,'(SECONDARY TILES)') else say(16,61,1,' (NORMAL TILES)  ');
  drawh(30*4-2,106,46*4+1,7);

  drawh(30*4-2,173,46*4+1,7);

  drawv(30*4-2,106,173,7);

  drawv(46*4+1,106,173,7);

 whatbefore:=ge_whatchar;
 showallgraps;
 repeat

 done:=false;
 case ge_whatchar of
  1..24:pg:=1;
  25..48:pg:=25;
  49..72:pg:=49;
  73..96:pg:=73;
  97..120:pg:=97;
  121..144:pg:=121;
  145..168:pg:=145;
  169..192:pg:=169;
  193..216:pg:=193;
  217..240:pg:=217;
  end;
i:=ge_whatchar-pg+1;
case i of
 1..8:i1:=2;
 9..16:i1:=21;
 17..24:i1:=40;
 end;
i:=((i-1) MOD 8)+1;

putthing(i*6-1,i1,3);
putthing(i*6-1,i1+4,3);
putthing(i*6-1,i1+8,3);
putthing(i*6-1,i1+12,3);
putthing(i*6+4,i1,3);
putthing(i*6+4,i1+4,3);
putthing(i*6+4,i1+8,3);
putthing(i*6+4,i1+12,3);

str(ge_whatchar,s);
s:=concat(s,'  ');
say(3,61,3,s);

dispblock(ge_whatchar);
grpedit_showdemo(ge_whatchar);

  j:=upcase_sync(readkey);

i2:=TEXTC0 MOD 256;
putthing(i*6-1,i1,i2);
putthing(i*6-1,i1+4,i2);
putthing(i*6-1,i1+8,i2);
putthing(i*6-1,i1+12,i2);

putthing(i*6+4,i1,i2);
putthing(i*6+4,i1+4,i2);
putthing(i*6+4,i1+8,i2);
putthing(i*6+4,i1+12,i2);


 case j of
  #0:case readkey of
   #59:help;
   #48:begin {alt-b}
       importbmpgrap(ge_whatchar);
       clearscreen;
       showallgraps;
       done:=true;
       putgrap(72,155,0);
       drawh(30*4-2,106,46*4+1,7);
       drawh(30*4-2,173,46*4+1,7);
       drawv(30*4-2,106,173,7);
       drawv(46*4+1,106,173,7);
       end;
   'K':if ge_whatchar>pg then dec(ge_whatchar) else ge_whatchar:=pg+23;
   'M':if ge_whatchar<pg+23 then inc(ge_whatchar) else ge_whatchar:=pg;
   'H':if (ge_whatchar-8)>=pg then ge_whatchar:=ge_whatchar-8;
   'P':if (ge_whatchar+8)<=pg+23 then ge_whatchar:=ge_whatchar+8;
   #68:begin;done:=true;savegraps;quittime:=true;end;
   'I':begin;if ge_whatchar>24 then ge_whatchar:=ge_whatchar-24
       else ge_whatchar:=(GRAPS-23);
           showallgraps;end;
   'Q':begin;if ge_whatchar<(GRAPS-23) then ge_whatchar:=ge_whatchar+24
       else ge_whatchar:=1;
           showallgraps;end;
   end;
 'T':begin
      savegraps;
      using_animtiles:=(not using_animtiles);
      if using_animtiles then loadgraps2(false) else loadgraps;
      showallgraps;
      if using_animtiles then say(16,61,1,'(SECONDARY TILES)') else say(16,61,1,' (NORMAL TILES)  ');

     end;
{ '&':begin
      getforeignpalette;

     end; }
 #13:done:=true;
 #3:begin;move(graphic^[ge_whatchar],graphic^[0],256);
       putgrap(72,155,0);end;
 #22,#16:begin;move(graphic^[0],graphic^[ge_whatchar],256);
       dispblock(ge_whatchar);showallgraps;end;
 end;
 until done;
end;


procedure grpedit_blowupchar(bb:byte);

 var xloc,yloc,xlc,ylc:byte;
  done,done2:boolean;
  b:byte;
  iee:integer;
 j,j0:char;
 newcolor:string[5];
 xlocmax:byte;
 sc_new,sc_this,sc_x,sc_y:byte;
 tf:text;




procedure showsection(n:byte); {for browsing VGA colors set}
var nc:byte;
begin
 putthing(54,190,n);
 putthing(55,190,n);
 putthing(54,194,n);
 putthing(55,194,n);
for nc:=1 to 3 do
begin
 if (n-nc)>0 then putthing(54-nc,192,n-nc) else putthing(54-nc,192,0);
 if (n+nc)<256 then putthing(55+nc,192,n+nc) else putthing(55+nc,192,0);
end;
 say(43,190,0,'   ');
 say(43,190,2,strnum(n));
end;

procedure menupart;
 var i:byte;
begin
  say(1,108,6,'  EDIT  ');
  say(55,4,3,'  SELECT  ');
  say(1,118,4,'0Û1-Û49Û1 PUTCOLOR');
  say(1,128,4,'S Û1ET COLORS');
  say(1,138,4,'F Û1ILL W/COLOR');
  say(1,148,4,'^CÛ1OPY, Û4^PÛ1ASTE');
  say(1,158,4,'I Û1MAGE MENU  ');
  say(1,168,4,' Š Û1SELECT NEW');
  for i:=1 to 9 do
   putthing(i*2+27,98,palcolor[i]);
end;

begin
  sc_this:=1;
  menupart;
  say(55,14,0,'       ');
  say(55,24,0,'           ');
  say(55,34,0,'          ');
  say(55,44,0,'           ');
  say(55,54,0,'           ');
{  if bb=240 then
   begin
    say(55,14,0,'WARNING:');
    say(55,24,0,'TILE 240 IS');
    say(55,34,0,'USED AS A ');
    say(55,44,0,'BLANK TILE.');
   end; }
dispblock(bb);
if HIRES then
 begin;xloc:=15;yloc:=7;xlocmax:=32;end
else begin;xloc:=7;yloc:=7;xlocmax:=16;end;
 repeat
  done:=false;
grpedit_showdemo(ge_whatchar);
iee:=0;
while not keypressed do
begin
 if iee=1 then putthing(xloc+29,yloc*4+103,15);
 if iee=2500 then putthing(xloc+29,yloc*4+103,0);
 if iee=5000 then putthing(xloc+29,yloc*4+103,(graphic^[bb,yloc,xloc]));
 inc(iee);
 if iee>7500 then iee:=0;
end;
j:=upcase_sync(readkey);
if graphic^[bb,yloc,xloc]=tmask then
 putcheckeredthing(xloc+29,yloc*4+103,tmask1,tmask2)
 else putthing(xloc+29,yloc*4+103,graphic^[bb,yloc,xloc]);
  case upcase(j) of
   #0:begin
   j0:=readkey;
   case j0 of
    #59:help;

    'H':if yloc>1 then dec(yloc);
    'P':if yloc<16 then inc(yloc);
    'K':if xloc>1 then dec(xloc);
    'M':if xloc<xlocmax then inc(xloc);
    #18:if tmask>=0 then begin
	
         say(5,190,0,'EDGE WITH WHAT COLOR? [0..9]');
         j0:=upcase_sync(readkey);
         case j0 of
         '0'..'9':for ylc:=1 to 16 do for xlc:=1 to 16 do
		          if graphic^[bb,ylc,xlc]=tmask then
				  begin
				   if ylc>1 then
				     if (graphic^[bb,ylc-1,xlc]<>tmask) and
 					  (graphic^[bb,ylc-1,xlc]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];
				   if xlc>1 then
				     if (graphic^[bb,ylc,xlc-1]<>tmask) and
 					  (graphic^[bb,ylc,xlc-1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];				
				   if ylc<16 then
				     if (graphic^[bb,ylc+1,xlc]<>tmask) and
 					  (graphic^[bb,ylc+1,xlc]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];
				   if xlc<16 then
				     if (graphic^[bb,ylc,xlc+1]<>tmask) and
 					  (graphic^[bb,ylc,xlc+1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];	

				   if (ylc>1) and (xlc>1) then
				     if (graphic^[bb,ylc-1,xlc-1]<>tmask) and
 					  (graphic^[bb,ylc-1,xlc-1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];
					
				   if (ylc>1) and (xlc<16) then
				     if (graphic^[bb,ylc-1,xlc+1]<>tmask) and
 					  (graphic^[bb,ylc-1,xlc+1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];

				   if (ylc<16) and (xlc>1) then
				     if (graphic^[bb,ylc+1,xlc-1]<>tmask) and
 					  (graphic^[bb,ylc+1,xlc-1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];

				   if (ylc<16) and (xlc<16) then
				     if (graphic^[bb,ylc+1,xlc+1]<>tmask) and
 					  (graphic^[bb,ylc+1,xlc+1]<>palcolor[ord(j0)-48]) then
					  graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];					
					
				  end;
         end;
         say(5,190,0,'                            ');
         dispblock(bb);	
	
	
	    end; {alt-E}
    #120..#128:begin
      say(5,190,0,concat('COLOR ',strnum(ord(j0)-119),' VALUE ='));
      newcolor:=readlin(37,190,3,1);
      val(newcolor,palcolor[ord(j0)-119],iee);
      {set 1..9 color}
      say(5,190,0,'                         ');
      menupart;
     end;
     end;
    end;
    'I':begin
         helpindex:=39;
         say(1,118,5,' IMAGE...  Û0 ');
         say(1,128,4,'X Û1,Û4Y Û1 FLIP ');
         say(1,138,4,'R Û1OTATE      ');
         say(1,148,4,'ˆ‰Û1 MOVE      ');
         say(1,158,0,'             ');
         say(1,168,4,' Š Û1PREV. MENU');
         zero:=0;

         repeat
          grpedit_showdemo(ge_whatchar);
          dispblock(bb);
          j0:=upcase_sync(readkey);
          case j0 of
           #0:case readkey of
               #59:help;

               #77:begin
                     for ylc:=1 to 16 do for xlc:=1 to 16 do
                      graphic^[zero+241,ylc,1+xlc MOD 16]:=
                       graphic^[bb,ylc,xlc];
                     graphic^[bb]:=graphic^[zero+241];
                   end;
               #75:begin
                     for ylc:=1 to 16 do for xlc:=1 to 16 do
                      graphic^[zero+241,ylc,xlc]:=
                       graphic^[bb,ylc,1+xlc MOD 16];
                     graphic^[bb]:=graphic^[zero+241];
                   end;
               #80:begin
                     for ylc:=1 to 16 do for xlc:=1 to 16 do
                      graphic^[zero+241,1+ylc MOD 16,xlc]:=
                       graphic^[bb,ylc,xlc];
                     graphic^[bb]:=graphic^[zero+241];
                   end;
               #72:begin
                     for ylc:=1 to 16 do for xlc:=1 to 16 do
                      graphic^[zero+241,ylc,xlc]:=
                       graphic^[bb,1+ylc MOD 16,xlc];
                     graphic^[bb]:=graphic^[zero+241];
                   end;
              end;
           'R':begin
                for ylc:=1 to 16 do for xlc:=1 to 16 do
                 graphic^[zero+241,ylc,xlc]:=
                  graphic^[bb,xlc,ylc];
                for ylc:=1 to 16 do for xlc:=1 to 16 do
                 graphic^[bb,ylc,xlc]:=
                  graphic^[zero+241,ylc,17-xlc];
               end;
           'Y':begin
                graphic^[zero+241]:=graphic^[bb];
                for ylc:=1 to 16 do for xlc:=1 to 16 do
                 graphic^[bb,ylc,xlc]:=
                  graphic^[zero+241,17-ylc,xlc];
               end;
           'X':begin
                graphic^[zero+241]:=graphic^[bb];
                for ylc:=1 to 16 do for xlc:=1 to 16 do
                 graphic^[bb,ylc,xlc]:=
                  graphic^[zero+241,ylc,17-xlc];
               end;
          end;
         until j0=#27;

         menupart;
         helpindex:=6;

        end;
    'F':begin
         say(5,190,0,'FILL WITH WHAT COLOR? [0..9]');
         j0:=upcase_sync(readkey);
         case j0 of
         '0'..'9':for ylc:=1 to 16 do for xlc:=1 to 16 do
                   graphic^[bb,ylc,xlc]:=palcolor[ord(j0)-48];
         end;
         say(5,190,0,'                            ');
         dispblock(bb);
        end;
(*   'B':begin
        say(5,190,0,'BROWSING COLORS:  #   [    ]');
        xlc:=1;
        repeat
         j0:=readkey;
         case j0 of
          #0:case readkey of
              'H','K':if xlc>0 then dec(xlc);
              'M','P':if xlc<255 then inc(xlc);
             end;
         end;
         showsection(xlc);
        until j0=#27;
        say(5,190,0,'                              ');
       end; *)
   'S':begin
        helpindex:=40;
        for iee:=1 to 7 do
         say(1,iee*10+98,0,'              ');
         say(1,100,6,' SELECT COLOR ');
         done2:=false;
         sc_x:=palcolor[sc_this] MOD 16;sc_y:=palcolor[sc_this] DIV 16;
         for iee:=0 to 15 do
          for b:=0 to 15 do
           putthing(5+b,iee*4+110,b+(iee*16));
          say(7,180,0,strnum(sc_this));
          say(7,190,4,'UÛ1: >C Û4RÛ1:C>');
{     u :   > c   f :   < c  }
          putthing(12,192,graphic^[bb,yloc,xloc]);
          putthing(27,192,graphic^[bb,yloc,xloc]);

         repeat
          putthing(sc_this*2+27,98,sc_x+sc_y*16);
          putthing(10,180,sc_x+(sc_y*16));
          putthing(10,184,sc_x+(sc_y*16));
          say(12,180,1,strnum(sc_x+(sc_y*16))+'  ');
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
               #59:help;
               #72:if sc_y>0 then dec(sc_y);
               #75:if sc_x>0 then dec(sc_x);
               #77:if sc_x<15 then inc(sc_x);
               #80:if sc_y<15 then inc(sc_y);
			   #20:begin
			        say(32,191,0,'TRANSPARENCY?[Y/N]   ');
					if upcase(readkey)='Y' then
					begin
			        assign(tf,'TMASK.TXT');
					{$I-} rewrite(tf);
                    writeln(tf,sc_x+sc_y*16);
					close(tf);
					{$I+}
                    say(32,191,0,' TRANSPARENCY ENABLED');
					putthing(32,194,sc_x+sc_y*16);
					tmask:=sc_x+sc_y*16;
                    tmask1:=lo(TEXTC0);
					if tmask=lo(TEXTC0) then tmask2:=ack.darkforeground
					 else tmask2:=tmask; 		
                    dispblock(bb);					
					end else
					begin
					assign(tf,'TMASK.TXT');
					{$I-} erase(tf); {$I+}
					tmask:=-1;
                    say(32,191,0,'TRANSPARENCY DISABLED');	
					dispblock(bb);
					end;
			
			
			       end;
               #71:begin
                    sc_x:=palcolor[sc_this] MOD 16;
                    sc_y:=palcolor[sc_this] DIV 16;
                   end;
               #19:begin
                 iee:=graphic^[bb,yloc,xloc];
                 for helpindex:=1 to 240 do
                 for xlc:=1 to 16 do for ylc:=1 to 16 do
                  if graphic^[helpindex,ylc,xlc]=iee then
                   graphic^[helpindex,ylc,xlc]:=sc_x+sc_y*16;
                 grpedit_showdemo(ge_whatchar);
                 dispblock(bb);
                 putthing(12,192,graphic^[bb,yloc,xloc]);
                 putthing(24,192,graphic^[bb,yloc,xloc]);
                 showallgraps; helpindex:=40;
                   end;
              end; {0}
           '1'..'9':begin
                     palcolor[sc_this]:=sc_x+sc_y*16;
                     sc_this:=ord(j0)-48;
                     sc_x:=palcolor[sc_this] MOD 16;
                     sc_y:=palcolor[sc_this] DIV 16;
                     say(7,180,0,strnum(sc_this));
                    end;
            'U':begin
                 palcolor[sc_this]:=graphic^[bb,yloc,xloc];
                 sc_x:=palcolor[sc_this] MOD 16;
                 sc_y:=palcolor[sc_this] DIV 16;
                end;
            'R':begin
                 iee:=graphic^[bb,yloc,xloc];
                 for xlc:=1 to 16 do for ylc:=1 to 16 do
                  if graphic^[bb,ylc,xlc]=iee then
                   graphic^[bb,ylc,xlc]:=sc_x+sc_y*16;
                 grpedit_showdemo(ge_whatchar);
                 dispblock(bb);
                 putthing(12,192,graphic^[bb,yloc,xloc]);
                 putthing(24,192,graphic^[bb,yloc,xloc]);
                end;
            #32,#13,#27:done2:=true;
          end; {readkey}
         until done2;
		 say(32,191,0,'                     ');
         palcolor[sc_this]:=sc_x+sc_y*16;
         for iee:=0 to 11 do
          say(1,iee*8+100,0,'              ');
          say(1,190,0,'                ');
          helpindex:=6;
         menupart;
       end; {setcolors}
   #3:begin;move(graphic^[bb],graphic^[0],256);dispblock(bb);
       putgrap(72,155,0);end;
   #22,#16:begin;move(graphic^[0],graphic^[bb],256);dispblock(bb);end;
   'P':begin;graphic^[bb,yloc,xloc] := graphic^[0,yloc,xloc];end;
   '0'..'9':graphic^[bb,yloc,xloc]:=palcolor[ord(j)-48];
   #32:graphic^[bb,yloc,xloc]:=graphic^[bb*0+240,1,1];
(*
   '0'..'3':if not HIRES then begin
  b:=(graphic^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3;
  b:=b SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  graphic^[bb,yloc,(xloc+3) DIV 4]:=graphic^[bb,yloc,(xloc+3) DIV 4] XOR b;
  b:=(ord(j)-48) SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  graphic^[bb,yloc,(xloc+3) DIV 4]:=graphic^[bb,yloc,(xloc+3) DIV 4] OR b;
   end else
   begin
  b:=(graphic^[bb,yloc,(xloc+7) DIV 8] SHR ( (8-(((xloc-1) MOD 8)+1)))) AND 1;
  b:=b SHL ( (8-(((xloc-1) MOD 8)+1)));
  graphic^[bb,yloc,(xloc+7) DIV 8]:=graphic^[bb,yloc,(xloc+7) DIV 8] XOR b;
  b:=(ord(j) DIV 49) SHL ( (8-(((xloc-1) MOD 8)+1)));
  graphic^[bb,yloc,(xloc+7) DIV 8]:=graphic^[bb,yloc,(xloc+7) DIV 8] OR b;
   end;
*)



   #27:done:=true;
   end;
   until done;
end;


procedure GraphicEdit;
var f:text; s:string[4]; i,ie:integer;
begin
  palcolor[0]:=lo(TEXTC0);
  palcolor[1]:=1;
  palcolor[2]:=2;
  palcolor[3]:=4;
  palcolor[4]:=7;
  palcolor[5]:=8;
  palcolor[6]:=10;
  palcolor[7]:=11;
  palcolor[8]:=12;
  palcolor[9]:=15;
  quittime:=false;
  assign(f,'TMASK.TXT');
  {$I-} reset(f); {$I+}
  if ioresult<>0 then tmask:=-1 else
   begin
    read(f,s);
    val(s,i,ie);
    if (ie<>0) or (ioresult<>0) or (i>255) or (i<0) then tmask:=-1 else tmask:=i;
	close(f);
   end;	
  tmask1:=lo(TEXTC0);if tmask=lo(TEXTC0) then tmask2:=ack.darkforeground else tmask2:=tmask;
  using_animtiles:=false;
  grpedit_setupscreen;
   repeat
    grpedit_selectchar;
    if not quittime then grpedit_blowupchar(ge_whatchar);
   until quittime;
   using_animtiles:=false;
   loadgraps;
  end;


procedure hiresdispchar(bb:byte);
var updown,bytes,bits:integer;
   n,nn:byte;
begin
 for updown:=1 to 8 do
  for bytes:=1 to 2 do
    begin
     n:=block^[bb,updown,bytes];
     for bits:=8 DOWNTO 1 do
      begin
       nn:=n AND 1;
       n:=n SHR 1;
       fputthing(21+(bytes*8)+(bits),(updown*8)+100,nn*3);
      end;
     end;
 end;


procedure dispchar(bb:byte);
var updown,bytes,bits:integer;
   n,nn:byte;
begin
 if HIRES then begin;hiresdispchar(bb);exit;end;
 for updown:=1 to 8 do
  for bytes:=1 to 2 do
    begin
     n:=block^[bb,updown,bytes];
     for bits:=4 DOWNTO 1 do
      begin
       nn:=n AND 3;
       n:=n SHR 2;
       fputthing(20+(bytes*8)+(bits*2),(updown*8)+100,nn);
       fputthing(20+(bytes*8)+(bits*2)+1,(updown*8)+100,nn);
      end;
     end;
 end;




procedure saveblocks;
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


procedure fontedit_setupscreen;
begin
{graphicsmode;}
fe_whatchar:=1;
{loadfont;}
clearscreen;
setcolor(getmaxcolor);
{line(114*xmlt,106,114*xmlt,173);line(114*xmlt,106,181*xmlt,106);
line(181*xmlt,173,181*xmlt,106);line(181*xmlt,173,114*xmlt,173);}
end;

procedure fontedit_showallchars;
begin
 say(2,8,0,' !"#$%&''()*+,-./');
 say(2,16,0,'0123456789');
 say(2,24,0,':;<=>?@');
 say(2,32,0,'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
 say(2,40,0,'abcdefghijklmnopqrstuvwxyz');
 say(2,48,0,'[\]^_`{|}~');
 say(2,56,0,'ƒ„…†‡ˆ‰Š‹Œ');
end;


procedure fontedit_selectchar;
var
   done:boolean;
   i,i1,i2:integer;
   j:char;
begin
  say(1,108,3,'  EDIT  ');
  say(55,4,6,'  SELECT  ');
  say(1,116,1,'    ');
  say(3,124,1,'           ');
  say(1,132,1,'        ');
  say(3,140,1,'          ');
  say(1,148,1,'    ');
  say(3,156,1,'          ');

  say(55,12,1,'…†:EDIT CHAR');
  say(55,28,1,'ˆ‰ TO MOVE');
  say(55,44,1,'F TO EXIT');

  drawh(30*4-2,106,46*4+1,3);
  drawh(30*4-2,173,46*4+1,3);
  drawv(30*4-2,106,173,3);
  drawv(46*4+1,106,173,3);

 fontedit_showallchars;
 repeat
 done:=false;
 if fe_whatchar=0 then fe_whatchar:=BLOCKS;
 if fe_whatchar>BLOCKS then fe_whatchar:=1;

{hilite current char}
dispchar(fe_whatchar);
  putletter(50,110,fe_whatchar,0);
  putletter(50,130,fe_whatchar,1);
  putletter(52,130,fe_whatchar,2);
  putletter(54,130,fe_whatchar,3);
  putletter(50,138,fe_whatchar,4);
  putletter(52,138,fe_whatchar,5);
  putletter(54,138,fe_whatchar,6);
case fe_whatchar of
 1..16:begin;i1:=8;i:=0;end;
 17..26:begin;i1:=16;i:=16;end;
 27..33:begin;i1:=24;i:=26;end;
 34..59:begin;i1:=32;i:=33;end;
 81..106:begin;i1:=40;i:=80;end;
 60..69:begin;i1:=48;i:=59;end;
 70..80:begin;i1:=56;i:=69;end;
 end;
i:=(fe_whatchar-i)*2;
putletter(i,i1,fe_whatchar,6);

  j:=upcase_sync(readkey);

putletter(i,i1,fe_whatchar,0);

 case j of
  #0:case readkey of
   #59:help;
   'K','H':if fe_whatchar=1 then fe_whatchar:=80 else
      if fe_whatchar=81 then fe_whatchar:=59 else
      if fe_whatchar=60 then fe_whatchar:=106 else dec(fe_whatchar);
   'M','P':if fe_whatchar=80 then fe_whatchar:=1 else
      if fe_whatchar=106 then fe_whatchar:=60 else
      if fe_whatchar=59 then fe_whatchar:=81 else inc(fe_whatchar);
   #68:begin;done:=true;saveblocks;quittime:=true;end;
   end;
 #13:done:=true;
 end;
 until done;
end;


procedure fontedit_blowupchar(bb:byte);

 var xloc,yloc,xlc,ylc:byte;
  done:boolean;
  b:byte;
  j:char;
  xmaxloc:byte;

begin
  if HIRES then xmaxloc:=16 else xmaxloc:=8;
  say(1,108,6,'  EDIT  ');
  say(55,4,3,'  SELECT  ');
  say(1,116,1,'0,1:');
  say(3,124,1,'PIXEL COLOR');
  say(1,132,1,'ƒ„0,1:');
  say(3,140,1,'CLEAR CHAR');
  say(1,148,1,'Š:');
  say(3,156,1,'SELECT NEW');

  say(55,12,1,'            ');
  say(55,44,1,'          ');


dispchar(bb);
xloc:=3;yloc:=3;
 repeat
if HIRES then
 begin
  putletter(50,110,bb,0);
  putletter(50,138,bb,6);
 end else
 begin
putletter(50,110,bb,0);
putletter(50,130,bb,1);
putletter(52,130,bb,2);
putletter(54,130,bb,3);
putletter(50,138,bb,4);
putletter(52,138,bb,5);
putletter(54,138,bb,6);
 end;
  done:=false;
if HIRES then
 begin
  fputthing(xloc+29,yloc*8+100,
   (block^[bb,yloc,(xloc+7) DIV 8] SHR ( (8-(((xloc-1) MOD 8)+1)) ) ) AND 3 +6);
 end else
 begin
  fputthing(xloc*2+28,yloc*8+100,
   (block^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3 +4);
  fputthing(xloc*2+29,yloc*8+100,
   (block^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3 +4);
  end;
j:=upcase_sync(readkey);
if HIRES then
 begin
  fputthing(xloc+29,yloc*8+100,
   ((block^[bb,yloc,(xloc+7) DIV 8] SHR ( (8-(((xloc-1) MOD 8)+1)) ) ) AND 1)*3);
 end else
 begin
  fputthing(xloc*2+28,yloc*8+100,
   (block^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3);
  fputthing(xloc*2+29,yloc*8+100,
   (block^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3);
  end;
  case j of
   #0:case readkey of
    #59:help;
    'H':if yloc>1 then dec(yloc);
    'P':if yloc<8 then inc(yloc);
    'K':if xloc>1 then dec(xloc);
    'M':if xloc<XMAXLOC then inc(xloc);
    #129:begin
      for ylc:=1 to 8 do for xlc:=1 to 2 do block^[bb,ylc,xlc]:=0;
     dispchar(bb);
     end;
    #120..#128:begin
      for ylc:=1 to 8 do for xlc:=1 to 2 do block^[bb,ylc,xlc]:=255;
     dispchar(bb);
     end;
    end;
   '0'..'9',#32:if not HIRES then
   begin
   if (j='0') or (j=#32) then ylc:=0 else ylc:=3;
  b:=(block^[bb,yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3;
  b:=b SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  block^[bb,yloc,(xloc+3) DIV 4]:=block^[bb,yloc,(xloc+3) DIV 4] XOR b;
  b:=(ylc) SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  block^[bb,yloc,(xloc+3) DIV 4]:=block^[bb,yloc,(xloc+3) DIV 4] OR b;
   end else
   begin
  b:=(block^[bb,yloc,(xloc+7) DIV 8] SHR ( (8-(((xloc-1) MOD 8)+1)))) AND 1;
  b:=b SHL ( (8-(((xloc-1) MOD 8)+1)));
  block^[bb,yloc,(xloc+7) DIV 8]:=block^[bb,yloc,(xloc+7) DIV 8] XOR b;
  b:=(ord(j) DIV 49) SHL ( (8-(((xloc-1) MOD 8)+1)));
  block^[bb,yloc,(xloc+7) DIV 8]:=block^[bb,yloc,(xloc+7) DIV 8] OR b;
   end;

   #27:done:=true;
   end;
   until done;
end;


procedure fontedit;
begin
  HIRES:=false;
  quittime:=false;
  fontedit_setupscreen;
   repeat
    fontedit_showallchars;
    fontedit_selectchar;
    if not quittime then fontedit_blowupchar(fe_whatchar);
   until quittime;
  end;
