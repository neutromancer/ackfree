
procedure showmosaic;
var x,y:byte;
begin
 for x:=1 to 16 do for y:=1 to 11 do
   putgrap(x*4-3,y*16-14,mosaic[x,y]);
end;

procedure clearmosaic;
var x,y:byte;
begin
 for x:=1 to 16 do for y:=1 to 11 do mosaic[x,y]:=0;
end;

procedure createmosaicfile;
 var mf:file of mosaicrec;
 i:integer;
begin
 clearmosaic;
 assign(mf,ADVNAME+MOSAICFILE);
 {$I-} rewrite(mf); {$I+}
 if ioresult<>0 then exit;
 write(mf,mosaic);
 close(mf);
end;

function maxmosaic:byte;
var mf:file of mosaicrec;
begin
 assign(mf,ADVNAME+MOSAICFILE);
 {$I-} reset(mf); {$I+}
 if ioresult<>0 then begin;maxmosaic:=1;createmosaicfile;exit;end;
 maxmosaic:=filesize(mf);
 close(mf);
end;

function loadmosaic(n:byte):boolean;
var mf:file of mosaicrec;
begin
 assign(mf,ADVNAME+MOSAICFILE);
 {$I-} reset(mf); {$I+}
 if ioresult<>0 then begin;createmosaicfile;exit;end;
 if n>filesize(mf)+1 then begin;loadmosaic:=false;exit;end;
 if n=filesize(mf)+1 then
  begin
   seek(mf,n-2);
   read(mf,mosaic);
   clearmosaic;
   write(mf,mosaic);
   close(mf);
   exit;
  end;
 seek(mf,n-1);
 read(mf,mosaic);
 close(mf);
end;


procedure savemosaic(n:byte);
var mf:file of mosaicrec;
begin
 assign(mf,ADVNAME+MOSAICFILE);
 {$I-} reset(mf); {$I+}
 if ioresult<>0 then begin;createmosaicfile;exit;end;
 seek(mf,n-1);
 write(mf,mosaic);
 close(mf);
end;

var tiles:array[1..7] of byte;

procedure mosaicedit(n:byte);
 var xloc,yloc:byte;
     j:char;
     ptc:byte;
     done:boolean;


procedure showbottom;
 var i:byte;
begin
 clearscreen;
 say(66,11,0,'MOSAIC');
 say(69,20,0,'#'+strnum(n));
 say(67,45,5,'AÛ0..Û5GÛ0:');
 say(66,54,0,'PUT TL');
 say(66,68,5,'ƒ„AÛ0-Û5GÛ0:');
 say(66,77,0,'SET TL');
 say(67,91,5,'ESCÛ0:');
 say(67,100,0,'EXIT');
 say(1,186,0,'A:   B:   C:   D:   E:   F:   G:');
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,199,319,3);
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3);
 showmosaic;
 for i:=1 to 7 do
  begin
   if tiles[i]>240 then tiles[i]:=240;

   putgrap((i*10)-5,182,tiles[i]);
  end;
end;


begin

 xloc:=8;yloc:=5;done:=false;
 showbottom;
 repeat
  for ptc:=0 to 3 do
   begin
    putthing(xloc*4-3+ptc,yloc*16-14,3);
    putthing(xloc*4-3+ptc,yloc*16-2,3);
   end;
 putthing(xloc*4-3,yloc*16-10,3);
 putthing(xloc*4-3,yloc*16-6,3);
 putthing(xloc*4,yloc*16-10,3);
 putthing(xloc*4,yloc*16-6,3);

 j:=upcase_sync(readkey);
 putgrap(xloc*4-3,yloc*16-14,mosaic[xloc,yloc]);
 case j of
  #0:case readkey of
    #59:help;
    'H':if yloc>1 then dec(yloc);
    'P':if yloc<11 then inc(yloc);
    'K':if xloc>1 then dec(xloc);
    'M':if xloc<16 then inc(xloc);
	#132:if n>1 then begin {control-pageup}
	      savemosaic(n);savemosaic(n-1);dec(n);showbottom;
		 end; 
	

		 
	#118:if n<250 then begin {control-pagedown}
	      savemosaic(n);savemosaic(n+1);inc(n);showbottom;
	     end;
	#73:if n>1 then begin
		 savemosaic(n);dec(n);if loadmosaic(n) then showbottom else exit;
		 end;
    #81:if n<maxmosaic then begin
		 savemosaic(n);inc(n);if loadmosaic(n) then showbottom else exit;
		 end;
	
    #83:begin
             mosaic[xloc,yloc]:=0;
             putgrap(xloc*4-3,yloc*16-14,mosaic[xloc,yloc]);
            end;

    #30:begin;tiles[1]:=grap_select_window(tiles[1]);showbottom;end;
    #48:begin;tiles[2]:=grap_select_window(tiles[2]);showbottom;end;
    #46:begin;tiles[3]:=grap_select_window(tiles[3]);showbottom;end;
    #32:begin;tiles[4]:=grap_select_window(tiles[4]);showbottom;end;
    #18:begin;tiles[5]:=grap_select_window(tiles[5]);showbottom;end;
    #33:begin;tiles[6]:=grap_select_window(tiles[6]);showbottom;end;
    #34:begin;tiles[7]:=grap_select_window(tiles[7]);showbottom;end;
     end;
    #127:begin;clearmosaic;showmosaic;end; {control-backspace}
	
   'A'..'G':begin
             mosaic[xloc,yloc]:=tiles[ord(j)-64];
             putgrap(xloc*4-3,yloc*16-14,mosaic[xloc,yloc]);
            end;
        #32:begin
             mosaic[xloc,yloc]:=0;
             putgrap(xloc*4-3,yloc*16-14,mosaic[xloc,yloc]);
            end;
     #27:done:=true;
  end;

 until done;
 savemosaic(n);
end;


(*
procedure PictureEdit(n:byte);

 var xloc,yloc,xlc,ylc:byte;
  done:boolean;
  b:byte;
 j:char;
 xlocmax,ylocmax:byte;
 savepic:boolean;

begin
savepic:=true;
xloc:=32;yloc:=22;xlocmax:=64;ylocmax:=44;
 say(69,21,0,'PIC');
 say(69,30,0,'#'+strnum(n));
 say(1,182,2,'0-3, ƒ„0-3, ESC:EXIT');
 say(1,190,2,'ƒ„V TO VIEW REDUCED IMAGE');
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,199,319,3);
 thickln(261,0,262,179,3);
 thickln(317,0,319,199,3);
showpicture;
repeat
 done:=false;
putthing(xloc,yloc*4-2,
 (picture^[yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3 +4);
j:=upcase_sync(readkey);
putthing(xloc,yloc*4-2,
 (picture^[yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3);

  case j of
   #0:case readkey of
    #59:help;
    'H':if yloc>1 then dec(yloc);
    'P':if yloc<ylocmax then inc(yloc);
    'K':if xloc>1 then dec(xloc);
    'M':if xloc<xlocmax then inc(xloc);
    #47:begin;showminipicture(30,140);xlc:=ord(readkey);showpicture;end;
    #129:begin
      for ylc:=1 to ylocmax do for xlc:=1 to (xlocmax DIV 4) do
        picture^[ylc,xlc]:=0;
      showpicture;
     end;
    #120:begin
      for ylc:=1 to ylocmax do for xlc:=1 to (xlocmax DIV 4) do
        picture^[ylc,xlc]:=85;
      showpicture;
     end;
    #121:begin
      for ylc:=1 to ylocmax do for xlc:=1 to (xlocmax DIV 4) do
       picture^[ylc,xlc]:=170;
      showpicture;
     end;
    #122:begin
      for ylc:=1 to ylocmax do for xlc:=1 to (xlocmax DIV 4) do
       picture^[ylc,xlc]:=255;
      showpicture;
     end;
    #68:begin;done:=true;quittime:=true;end;
    end;
   '0'..'3':begin
  b:=(picture^[yloc,(xloc+3) DIV 4] SHR ( (4-(((xloc-1) MOD 4)+1))*2 ) ) AND 3;
  b:=b SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  picture^[yloc,(xloc+3) DIV 4]:=picture^[yloc,(xloc+3) DIV 4] XOR b;
  b:=(ord(j)-48) SHL ( (4-(((xloc-1) MOD 4)+1))*2 );
  picture^[yloc,(xloc+3) DIV 4]:=picture^[yloc,(xloc+3) DIV 4] OR b;
   end;
   #27:done:=true;
   end;
   until done;
end;
 *)

procedure show_shortmsg(yloc:byte);
var i:integer;
begin
 for i:=1 to 37 do
   begin
   putletter(i*2+1,yloc,ord(shortmsg.chars[1,i]),shortmsg.attrs[1,i]);
   putletter(i*2+1,yloc+8,ord(shortmsg.chars[2,i]),shortmsg.attrs[2,i]);
  end;
  say(1,yloc,5,' ');
  say(1,yloc+8,5,' ');
  say(77,yloc,5,' ');
  say(77,yloc+8,5,' ');
end;

function shortmessageedit(yloc:byte):integer; {1:save 0:ESC -1:del}
var
 xl,yl:byte;
 attr:byte;
 j,j1:char;
 thischar:byte;
 result:integer;
begin
 xl:=1;yl:=1;attr:=0;
 show_shortmsg(yloc);
repeat
 thischar:=0;
 result:=7;
while not keypressed do
 begin
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),6);
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),0);
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
  end;
 putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
 j:=(readkey);  {can't process tab key for sync here.}
 case j of
  #0:begin
      j1:=readkey;
     case j1 of
      #59:help;
      #32:result:=-1;
      #120..#125:attr:=ord(j1)-119;
      #129:attr:=0;
      'H','P':if yl=1 then yl:=2 else yl:=1;
      'K':if xl>1 then dec(xl);
      'M':if xl<37 then inc(xl);
      #71:xl:=1;
     end;end;
    #8:if xl>1 then begin;dec(xl);shortmsg.chars[yl,xl]:=#1;
       shortmsg.attrs[yl,xl]:=0;end;
    #9:if xl<29 then inc(xl,8) else xl:=37;
    #32..#96:thischar:=ord(j)-31;
    #123..#126:thischar:=ord(j)-57;
    #97..#122:thischar:=ord(j)-16;
    #27:result:=1;
    #13:begin;xl:=1;if yl=1 then yl:=2 else yl:=1;end;
   end; {case}
  if thischar<>0 then begin
   shortmsg.chars[yl,xl]:=chr(thischar);
   shortmsg.attrs[yl,xl]:=attr;
   putletter(xl*2+1,yloc+((yl-1)*8),ord(shortmsg.chars[yl,xl]),shortmsg.attrs[yl,xl]);
   if xl<37 then inc(xl) else begin;xl:=1;if yl=1 then yl:=2 else yl:=1;end;
  end;
 until result<>7;
 if result=-1 then shortmsg.empty:=true else shortmsg.empty:=false;
 shortmessageedit:=result;
end;


procedure messager(xc,yc:byte);
 var f:file of shortmsgrec;
     filesz:word;
     i,i1:integer;
     ss:string[40];
           begin
            assign(f,ADVNAME+SHORTMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_shortmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,shortmsg);
                 if shortmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else
               begin
                val(ss,i1,i);
                if i<>0 then i1:=0;
                if i1<256 then if i1-1>filesz+1 then i1:=0;
               end;

              if i1<>0 then
               begin
                say(xc,yc,0,'#'+strnum(i1)+'   ');
                say(1,183,0,'EDIT MESSAGE:  ESC:QUIT/SAVE       ');
                say(1,191,0,'ƒ„0-ƒ„6:SET COLOR,  ƒ„D:DELETE MSG.');
				if i1>255 then
				begin
				 close(f);
				 if i1>1000 then i1:=1000;
				 load_shortmsgfile(i1);
				 i:=shortmessageedit(yc+8);
				 if i<>0 then save_shortmsgfile(i1);
				 
				end else
				begin
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,shortmsg);end
                 else
                  begin;seek(f,i1-2);read(f,shortmsg);clear_shortmsg;end;
                i:=shortmessageedit(yc+8);
                if i<>0 then
                    begin
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,shortmsg);
                    end;
					close(f);
				end;	
					
					
               end;
             end;

            end;

{**************************}

procedure save_longmsgfile(mn:byte);
 var f:file of longmsgrec;
begin
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} rewrite(f); {$I+}
 if ioresult<>0 then exit;
 longmsg.empty:=false;
 seek(f,mn-1);
 write(f,longmsg);
 close(f);
end;

procedure clear_longmsg;
var i,i1:integer;
begin
 longmsg.empty:=true;
 longmsg.chars[1]:=#1;
 for i1:=1 to 32 do
  begin
   for i:=1 to 22 do
    longmsg.attrs[i,i1]:=0;
    longmsg.chars[1]:=concat(longmsg.chars[1],#1);
  end;
 for i:=2 to 22 do
  longmsg.chars[i]:=longmsg.chars[1];
 end;


procedure create_longmsgfile;
 var i,i1:byte;
  f:file of longmsgrec;
begin
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} rewrite(f); {$I+}
 if ioresult<>0 then exit;
  clear_longmsg;
  write(f,longmsg);
  close(f);
 end;


procedure load_longmsgfile(mn:byte);
 var f:file of longmsgrec;
begin
 if mn=0 then exit;
 assign(f,ADVNAME+LONGMSGFILE);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then begin;create_longmsgfile;exit;end;
 seek(f,mn-1);
 read(f,longmsg);
 close(f);
end;



procedure show_longmsg;
var i,i1:integer;
begin
 for i1:=1 to 22 do
  for i:=1 to 32 do
   putletter(i*2-1,2+(i1-1)*8,ord(longmsg.chars[i1,i]),longmsg.attrs[i1,i]);
end;

function longmessageedit:integer; {1:save 0:ESC -1:del}
var
 ii,i2:byte;
 xl,yl:byte;
 attr:byte;
 j,j1:char;
 thischar:byte;
 result:integer;
 yloc:byte;
begin
 yloc:=2;
 xl:=1;yl:=1;attr:=0;
 thickln(317,0,319,199,3);
 thickln(0,0,2,199,3);
 drawh(0,0,319,3);
 thickln(0,179,319,180,3);
 drawh(0,199,319,3);
 thickln(261,0,262,179,3);
 show_longmsg;
repeat
 thischar:=0;
 result:=7;
while not keypressed do
 begin
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),6);
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),0);
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
  end;
 putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
 j:=(readkey);
 case j of
  #0:begin
      j1:=readkey;
     case j1 of
      #59:help;
      #82:begin
           for ii:=31 downto xl do
            begin
             longmsg.chars[yl,ii+1]:=longmsg.chars[yl,ii];
             longmsg.attrs[yl,ii+1]:=longmsg.attrs[yl,ii];
            end;
            longmsg.chars[yl,xl]:=#1;
            longmsg.attrs[yl,xl]:=0;
            show_longmsg;
          end;
      #83:begin
           for ii:=xl+1 to 32 do
            begin
             longmsg.chars[yl,ii-1]:=longmsg.chars[yl,ii];
             longmsg.attrs[yl,ii-1]:=longmsg.attrs[yl,ii];
            end;
            longmsg.chars[yl,32]:=#1;
            longmsg.attrs[yl,32]:=0;
            show_longmsg;
          end;
	  #23:if yl<22 then
	      begin {alt-I}
           for ii:=21 downto yl do
		    for i2:=1 to 32 do
			 begin
			  longmsg.chars[ii+1,i2]:=longmsg.chars[ii,i2];
              longmsg.attrs[ii+1,i2]:=longmsg.attrs[ii,i2];
			 end;
		   for i2:=1 to 32 do
			 begin
			  longmsg.chars[yl,i2]:=#1;
              longmsg.attrs[yl,i2]:=0;
			 end;  
           show_longmsg;			 
          end;	  
	  #32:if yl<22 then
	      begin {alt-D}
           for ii:=yl+1 to 22 do
		    for i2:=1 to 32 do
			 begin
			  longmsg.chars[ii-1,i2]:=longmsg.chars[ii,i2];
              longmsg.attrs[ii-1,i2]:=longmsg.attrs[ii,i2];
			 end;
		   for i2:=1 to 32 do
			 begin
			  longmsg.chars[22,i2]:=#1;
              longmsg.attrs[22,i2]:=0;
			 end;          			
           show_longmsg;
          end else
          begin
		   for i2:=1 to 32 do
			 begin
			  longmsg.chars[22,i2]:=#1;
              longmsg.attrs[22,i2]:=0;
			 end;          			
           show_longmsg;
          end;		  
      #18:result:=-1;
      #46:begin;clear_longmsg;show_longmsg;end;
      #120..#125:attr:=ord(j1)-119;
      #129:attr:=0;
      'H':if yl>1 then dec(yl);
      'P':if yl<22 then inc(yl);
      'K':if xl>1 then dec(xl);
      'M':if xl<32 then inc(xl);
      #71:begin;xl:=1;yl:=1;end;
      #79:begin;xl:=1;yl:=22;end;
     end;end;
    #8:if xl>1 then begin;dec(xl);longmsg.chars[yl,xl]:=#1;
       longmsg.attrs[yl,xl]:=0;end;
    #9:if xl<29 then inc(xl,8) else xl:=32;
    #32..#96:thischar:=ord(j)-31;
    #123..#126:thischar:=ord(j)-57;
    #97..#122:thischar:=ord(j)-16;
    #27:result:=1;
    #13:begin;xl:=1;if yl<22 then inc(yl);end;
   end; {case}
  if thischar<>0 then begin
   longmsg.chars[yl,xl]:=chr(thischar);
   longmsg.attrs[yl,xl]:=attr;
   putletter(xl*2-1,yloc+((yl-1)*8),ord(longmsg.chars[yl,xl]),longmsg.attrs[yl,xl]);
   if xl<32 then inc(xl) else begin;xl:=1;if yl>1 then dec(yl);end;
  end;
 until result<>7;
 if result=-1 then longmsg.empty:=true else longmsg.empty:=false;
 longmessageedit:=result;
end;


procedure longmessager(xc,yc:byte);
 var f:file of longmsgrec;
     filesz:word;
     i,i1:integer;
     ss:string[40];
           begin
            assign(f,ADVNAME+LONGMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_longmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,longmsg);
                 if longmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else
               begin
                val(ss,i1,i);
                if i<>0 then i1:=0;
                if i1-1>filesz+1 then i1:=0;
               end;

              if i1<>0 then
               begin
                clearscreen;
                say(69,21,4,'MSG');
                say(69,30,4,'#'+strnum(i1));
                say(1,182,0,'ƒ„C:CLEAR MSG,  ESC:QUIT/SAVE      ');
                say(1,190,0,'ƒ„0-ƒ„6:SET COLOR,  ƒ„E:ERASE MSG.');
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,longmsg);end
                 else
                  begin;seek(f,i1-2);read(f,longmsg);clear_longmsg;end;
                i:=longmessageedit;
                if i<>0 then
                    begin
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,longmsg);
                    end;
               end;
             end;
              close(f);
            end;
{********************}

(*
procedure clear_picture;
var x,y:byte;
begin
 for x:=1 to 16 do for y:=1 to 44 do picture^[y,x]:=0;
end;


procedure load_picturefile(pn:byte);
var fp:file of picturerec;
begin
 assign(fp,ADVNAME+PICTUREMSGFILE);
 {$I-} reset(fp); {$I+}
 if ioresult<>0 then
   begin;clear_picture;rewrite(fp);write(fp,picture^);close(fp);exit;end;
 if pn>filesize(fp) then exit;
 seek(fp,pn-1);
 read(fp,picture^);
 close(fp);
end;

procedure save_picturefile(pn:byte);
var fp:file of picturerec;
    pb:picturerec;  {stupid thing!}
begin
 assign(fp,ADVNAME+PICTUREMSGFILE);
 {$I-} reset(fp); {$I+}
 if ioresult<>0 then
   begin;clear_picture;rewrite(fp);write(fp,picture^);close(fp);exit;end;
 if pn>filesize(fp)+1 then exit;
 if pn>filesize(fp) then
   begin;seek(fp,pn-2);read(fp,pb);end else seek(fp,pn-1);
 write(fp,picture^);
 close(fp);
end;

*)

procedure MsgEditMainMenu;
 var ss:string[4];
     i,i1,i2:integer;

     j:char;
     filesz:integer;
 (*
procedure copypic;
begin
        assign(fp,ADVNAME+PICTUREMSGFILE);
        {$I-} reset(fp); {$I+}
        ss:=' ';
        if ioresult<>0 then
          exit else begin;filesz:=filesize(fp);close(fp);
        say(6,152,1,'ENTER THE PICTURE NUMBER, UP TO '+strnum(filesz)+',');
        say(6,160,1,'THAT YOU WANT TO COPY, OR PRESS ESC.');
        say(6,168,1,'COPY WHAT PICTURE?');
        ss:=readlin(44,168,3,1);end;
        if ss=#27 then exit;
        if ss<>#27 then
        begin
         if ss='' then exit
         else begin;val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;end;
         if i1<>0 then
            begin
             clearscreen;
             load_picturefile(i1);
             thickln(0,0,2,199,3);
             drawh(0,0,319,3);
             thickln(0,179,319,180,3);
             drawh(0,199,319,3);
             thickln(261,0,262,179,3);
             thickln(317,0,319,199,3);
             showpicture;
            end; {i1}
        end; {27}
        assign(fp,ADVNAME+PICTUREMSGFILE);
        {$I-} reset(fp); {$I+}
        ss:=' ';
        if ioresult<>0 then
          exit;
        filesz:=filesize(fp);close(fp);
        say(6,182,1,'ENTER THE NEW NUMBER, UP TO '+strnum(filesz)+'.');
        say(6,190,1,'OR PRESS Û5ESCÛ0.');
         say(67,21,4,'COPY');
         say(67,30,4,'#'+strnum(i1));
         say(67,39,4,'TO');
         say(67,48,1,'#');
         ss:=readlin(69,48,3,1);

        if ss<>#27 then
        begin
         if ss='' then
          begin;clear_picture;i1:=filesz+1;end
         else begin;val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;end;
         if i1<>0 then
            begin
             clearscreen;
             save_picturefile(i1);
            end; {i1}
        end; {27}
end;

 *)

{$I I_DLGED1.PAS}




{$I I_MSGEXP.PAS}






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
  if texist(i) then titles[i]:=titles[i]+'*';
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

  case j of
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
 selectdialogue:=thisd+topd-1;
end;



begin
  for i:=1 to 7 do tiles[i]:=i;
 repeat
  clearscreen;
  quittime:=false;
  say(4,19,4,' MESSAGE AND DIALOGUE EDITOR ');
  say(5,30,5,' S Û0: EDIT SHORT MESSAGE');
  say(5,40,5,' L Û0: EDIT LONG MESSAGE');
  say(5,50,5,' D Û0: EDIT DIALOGUE');
  say(5,60,5,' M Û0: EDIT MOSAIC');
 { say(5,71,5,' P Û0: EDIT PICTURE');
  say(5,81,5,'ƒ„PÛ0: COPY PICTURE'); }
  say(5,70,5,'ƒ„MÛ0: COPY MOSAIC');
{ say(5,102,5,' V Û0: VIEW PICTURE SLIDESHOW'); }
 {say(5,80,5,' V Û0: VIEW MOSAIC SLIDESHOW');}
 say(5,100,5,' X Û0: EXPORT MESSAGES.TXT');
 say(5,120,5,'F10Û0: QUIT');
 j:=upcase_sync(readkey);
  case j of
   #0:case readkey of
       #59:help;
      (* #25:copypic; *)
       #68:quittime:=true;
	   #32:begin {alt-D}
	        say(5,160,0,'PROCESSING...');
	        defragtalkfile;
			say(5,170,0,'DONE.');
	       end;
       #47:begin {alt-v}
        say(6,152,1,'ENTER THE MOSAIC NUMBERS, UP TO '+strnum(maxmosaic)+',');
        say(6,168,1,'STARTING FRAME:');
        say(6,178,1,'  ENDING FRAME:');
        ss:=readlin(36,168,3,1);say(36,168,0,ss+'    ');
        val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;
        ss:=readlin(36,178,3,1);say(36,178,0,ss+'    ');
        val(ss,i2,i);if i<>0 then i2:=0;if i2>255 then i2:=0;
        if i2<i1 then i2:=i1;
        if i1>maxmosaic then i1:=maxmosaic;
        if i2>maxmosaic then i2:=maxmosaic;
        for i:=i1 to i2 do
         begin
          if loadmosaic(i) then showmosaic;
          if readkey=#0 then ss:=readkey;
         end;
        end; {v}
       #50:begin {alt-m}
            say(6,152,1,'ENTER THE MOSAIC NUMBER YOU');
            say(6,160,1,'WANT TO COPY (UP TO '+strnum(maxmosaic)+')');
            ss:=readlin(6,168,3,1);say(6,168,0,ss+'  ');
            val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;
            if i1<>0 then
            if loadmosaic(i1) then
             begin
              showmosaic;i2:=i1;
              say(3,181,1,'ENTER THE MOSAIC NUMBER YOU WANT TO');
              say(3,190,1,'COPY THIS TO (MAX.'+strnum(maxmosaic+1)+'):');
              ss:=readlin(60,190,3,1);
              val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;
              if i1<>0 then
               if loadmosaic(i1) then
                {copy i2 to i1}
                 if loadmosaic(i2) then savemosaic(i1);
             end;
            end;


       end;
   'X':exportmessages;
   'D':begin
        i:=selectdialogue;
        helpindex:=50;
        if i<>0 then talkedit(i);
        helpindex:=8;
       end;
   'M':begin
        say(6,152,1,'ENTER THE MOSAIC NUMBER TO EDIT.');
        say(6,160,1,'[1 TO '+strnum(maxmosaic+1)+']:');
        ss:=readlin(29,160,3,1);
        helpindex:=54;
        val(ss,i,i1);if i1=0 then if (i>0) and (i<256) then
         if loadmosaic(i) then mosaicedit(i);
        helpindex:=8;
       end;
    (*'V':begin
        say(6,152,1,'ENTER THE MOSAIC NUMBERS, UP TO '+strnum(maxmosaic)+',');
        say(6,168,1,'STARTING FRAME:');
        say(6,178,1,'  ENDING FRAME:');
        ss:=readlin(36,168,3,1);say(36,168,0,ss+'    ');
        val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;
        ss:=readlin(36,178,3,1);say(36,178,0,ss+'    ');
        val(ss,i2,i);if i<>0 then i2:=0;if i2>255 then i2:=0;
        if i2<i1 then i2:=i1;
        if i1>maxmosaic then i1:=maxmosaic;
        if i2>maxmosaic then i2:=maxmosaic;
        for i:=i1 to i2 do
         begin
          if loadmosaic(i) then showmosaic;
          if readkey=#0 then ss:=readkey;
         end;
        end; {v}   *)
  (* 'P':begin
        assign(fp,ADVNAME+PICTUREMSGFILE);
        {$I-} reset(fp); {$I+}
        ss:=' ';
        if ioresult<>0 then
          filesz:=0 else begin;filesz:=filesize(fp);close(fp);
        say(6,152,1,'ENTER THE PICTURE NUMBER, UP TO '+strnum(filesz)+',');
        say(6,160,1,'OR PRESS Û5 …† Û1 TO MAKE A NEW ONE.');
        say(6,168,1,'EDIT WHAT PICTURE?');
        ss:=readlin(44,168,3,1);end;
        if ss<>#27 then
        begin
         if ss='' then
          begin;clear_picture;i1:=filesz+1;end
         else begin;val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;end;
         if i1<>0 then
            begin
             clearscreen;
             load_picturefile(i1);
             helpindex:=55;
             PictureEdit(i1);
             helpindex:=8;
             save_picturefile(i1);
            end; {i1}
        end; {27}
       end; {P}
   'V':begin
        assign(fp,ADVNAME+PICTUREMSGFILE);
        {$I-} reset(fp); {$I+}
        ss:=' ';
        if ioresult<>0 then
          filesz:=0 else begin;filesz:=filesize(fp);close(fp);
        say(6,152,1,'ENTER THE PICTURE NUMBERS, UP TO '+strnum(filesz)+',');
        say(6,168,1,'STARTING FRAME:');
        say(6,178,1,'  ENDING FRAME:');
        ss:=readlin(36,168,3,1);say(36,168,0,ss+'    ');
        val(ss,i1,i);if i<>0 then i1:=0;if i1>255 then i1:=0;
        ss:=readlin(36,178,3,1);say(36,178,0,ss+'    ');
        val(ss,i2,i);if i<>0 then i2:=0;if i2>255 then i2:=0;
        if i2<i1 then i2:=i1;
        if i1>filesz then i1:=filesz;
        if i2>filesz then i2:=filesz;
        for i:=i1 to i2 do
         begin
          load_picturefile(i);
          showpicture;
          showminipicture(52,20);
          if readkey=#0 then ss:=readkey;
         end;
        end; {ioresult}
      end;  *)

     'S':begin
          say(6,152,1,'SHORT MESSAGE');
          helpindex:=49;
          messager(34,152);
          helpindex:=8;
         end; {S}
     'L':begin
          say(8,152,1,'LONG MESSAGE');
          helpindex:=49;
          longmessager(34,152);
          helpindex:=8;
         end; {L}
    end; {case}

 until quittime;
end;