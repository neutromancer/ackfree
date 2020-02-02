
procedure createdialoguefile;
 var df:file of talkrec;
   talkbuff:talkrec;
   i:integer;
begin
 assign(df,ADVNAME+DIALOGUEFILE);
 rewrite(df);
 write(df,talkbuff);
for i:=1 to 255 do
 begin
  talkbuff.headertype:=255;
  talkbuff.data:='DIALOGUE '+strnum(i);
  talkbuff.header:=#26;
  talkbuff.datatype:=0;
  talkbuff.next:=0;
  write(df,talkbuff);
 end;
 close(df);
end;

procedure cleardialogue;
var i:integer;
begin
 for i:=1 to 1000 do
  begin
   talk^[i].headertype:=0;
   talk^[i].header:=' ';
   talk^[i].datatype:=0;
   talk^[i].data:=' ';
   talk^[i].next:=0;
  end;
 end;

procedure loaddialogue(n:byte);
var df:file of talkrec;
    talkbuff:talkrec;
    i:integer;

begin
 assign(df,ADVNAME+DIALOGUEFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then begin;createdialoguefile;reset(df);end;
 seek(df,n);
 read(df,talkbuff);
 cleardialogue;talk^[1]:=talkbuff;
 i:=2;

while (talkbuff.next<>0) and (i<1000) do
begin

 seek(df,talkbuff.next);
 read(df,talkbuff);
 talk^[i]:=talkbuff;

 inc(i);
end;
 close(df);

end;

procedure savedialogue(n:byte);
var df:file of talkrec;
    i:integer;
begin
 assign(df,ADVNAME+DIALOGUEFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then begin;createdialoguefile;reset(df);end;
 seek(df,n);
 write(df,talk^[1]);
 i:=2;
repeat
  seek(df,talk^[i-1].next);
  write(df,talk^[i]);
  inc(i);
until (talk^[i-1].next=0) or (i>997);
close(df);
end;

function freespace:word; {makes a new index and returns that value}
var df:file of talkrec;
    talkbuff:talkrec;
    id:word;
begin
 assign(df,ADVNAME+DIALOGUEFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then exit;
 seek(df,filesize(df)-1);
 read(df,talkbuff);
 write(df,talkbuff);
 id:=filesize(df)-1;
 close(df);
 freespace:=id;
end;

procedure clear_keyboard_buffer;
 var regs:registers;
begin
 regs.ah:=$0c;regs.al:=$00;
 intr($21,regs);
end;

procedure insertline(n:integer);  {inserts a line after line N}
 var
  talkbuff:talkrec;
  i:integer;
 begin
  for i:=999 downto n do talk^[i+1]:=talk^[i];
  with talk^[n+1] do
   begin
    headertype:=10;header:=' ';datatype:=0;data:=' ';
   end;
  talk^[n+1].next:=talk^[n].next;
  talk^[n].next:=freespace;
 end;



procedure deleteline(topicat,n:integer);  {deletes line N}
var i:integer;
begin
 if n=topicat then talk^[i+1].header:=talk^[i].header;
 for i:=n to 999 do talk^[i]:=talk^[i+1];
end;


procedure topic_edit(topicat:word);
var
 i2,i3:integer;
 done:boolean;
 j,j0:char;
 row,column:word;
 lines:word;morelines:word;
 newt:byte;
 s:string;
 top:word;
 newtop:boolean;


procedure showresponse;
var i:word; ii,iie:integer;
begin
 clearscreen;
 say(0,1,6,' EDIT CONVERSATION TOPIC               ');
 say(2,11,0,'TOPIC: '+talk^[topicat].header);
 say(2,24,0,'RESPONSE:');
 say(1,170,5,'ƒ„IÛ0:INS LINE Û5ƒ„DÛ0:DEL LINE Û5F5Û0:HIGHLIGHT');
 say(1,180,5,'ƒ„TÛ0/Û5ƒ„CÛ0:CHG TO TEXT/CMD  Û5ESCÛ0:SAVE/EXIT');
 say(1,190,5,'ƒ„QÛ0:QUESTION  Û5ƒ„RÛ0:RENAME  Û5ƒ„AÛ0:APPEND');
 i:=topicat+top;
 if top<>0 then say(70,33,1,strnum(top));

 repeat
  if talk^[i].datatype=0 then
    talksay(8,34+(i-topicat-top)*8,talk^[i].data)
   else
    begin
	 say(8,34+(i-topicat-top)*8,1,copy(talk^[i].data,1,10));
	 if talk^[i].data[5]='-' then
	  if talk^[i].data[1]='C' then
	   say(28,34+(i-topicat-top)*8,1,copy(talk^[i].data,12,4))
	   else
	    begin
		 val(copy(talk^[i].data,12,3),ii,iie);
		 say(26,34+(i-topicat-top)*8,1,'#'+strnum(ii)+' '+obj^[ii].n);
		end;
    end;	
  case talk^[i].headertype of
   2:say(0,34+(i-topicat-top)*8,2,'[?]-');
   3:say(0,34+(i-topicat-top)*8,2,'[Y]-');
   4:say(0,34+(i-topicat-top)*8,2,'[N]-');
  end;
  inc(i);
 until (talk^[i].headertype<2) or (i-(topicat+top)>=16);

 lines:=i-(topicat+top);
 morelines:=0;
 if lines=16 then
  while talk^[i].headertype>=2 do
   begin
    inc(i);
    inc(morelines);
   end;

 drawv(30,34,34+lines*8,3);
 drawv(274,34,34+lines*8,3);
 if lines=16 then begin
  if (morelines=0) then drawh(30,163,274,3);
  if (top=0) then drawh(30,33,274,3);
 end else
 begin
  drawh(30,33,274,3);
  drawh(30,35+lines*8,274,3);
 end;

 if morelines<>0 then say(70,155,1,strnum(morelines));
 clear_keyboard_buffer;
end;

procedure checklength;
var i,i1:integer;
begin
 for i:=topicat to topicat+top+lines-1 do
  for i1:=length(talk^[i].data) to 29 do
   talk^[i].data:=talk^[i].data+' ';
end;

type vmrec = record
   v:byte; n:byte; p:word;
    end;

procedure getvarmerchant(var s:string);
var
 i,i1:byte;done:boolean;j:char;ss:string[5];
 ie:integer;
 merch:array[1..4] of vmrec;
procedure scrset;
 var c:byte;
 s:string;
begin
 clearscreen;
 for c:=1 to 4 do
 if merch[c].v<>0 then
  say(8,10+c*20,6,' '+chr(c+48)+' Û0 SET '+chr(merch[c].v+64)+' TO '+
     strnum(merch[c].n)+' FOR $'+strnum(merch[c].p))
  else say(8,10+C*20,6,' '+chr(c+48)+' Û1 (NOT SET)');
 say(3,165,0,'SET-VARIABLE MERCHANT  [F1] FOR HELP');
 say(3,175,0,'PRESS [1]..[4] TO EDIT, [ESC] TO EXIT');
end;

begin
 if s[4]='-' then
  begin
   for i:=1 to 4 do
   begin
    merch[i].v:=ord(s[14+i*4-3]);
    merch[i].n:=ord(s[14+i*4-2]);
    merch[i].p:=ord(s[14+i*4-1])*256 + ord(s[14+i*4]);
   end;
  end else
  begin
   for i:=1 to 4 do
    begin;merch[i].v:=0;merch[i].n:=0;merch[i].p:=0;end;
  end;
 scrset;
 done:=false;
 repeat
  j:=upcase(readkey);
  case j of
   #0:if readkey=#59 then help;
   '1'..'4':begin
             i:=ord(j)-48;
             say(3,145,0,'VARIABLE? (A-D,ESC)');
             i1:=ord(upcase(readkey))-64;
             if (i1>0) and (i1<5) then
              begin
               merch[i].v:=i1;
               say(3,145,0,'SET VARIABLE TO:       ');
               ss:=readlin(37,145,3,1);
               val(ss,i1,ie);
               merch[i].n:=i1;
               say(3,145,0,'PRICE:                 ');
               ss:=readlin(37,145,5,1);
               val(ss,merch[i].p,ie);
               scrset;
              end else begin;merch[i].v:=0;end;
            end;
  #27:done:=true;
  end;
 until done;
 s:='VAR-MENU                       ';
 for i:=1 to 4 do
  begin
   s[14+i*4-3]:=chr(merch[i].v);
   s[14+i*4-2]:=chr(merch[i].n);
   s[14+i*4-1]:=chr(merch[i].p DIV 256);
   s[14+i*4]:=chr(merch[i].p MOD 256);
  end;

end;


procedure getmerchant(var s:string);
var
 merch:array[1..16] of byte; {255 is empty, not 0}
 buy,sell:byte;
 i,i1:byte;done:boolean;j:char;
procedure scrset;
 var c:byte;
 s:string;
begin
 clearscreen;
 say(0,1,6,' EDIT MERCHANT INVENTORY              ');
 say(1,165,0,'PRESS Û5 A Û0..Û5 P Û0, OR Û5ESCÛ0 TO EXIT');
 case sell of
  1:s:='RIPOFF! ';
  2:s:='HIGH    ';
  4:s:='LOWER   ';
  5:s:='BARGAIN!';
  else s:='NORMAL  ';
 end;
 say(1,175,5,' S Û0: SELLING PRICES: '+s);
 case buy of
  1:s:='RIPOFF! ';
  2:s:='UNFAIR  ';
  4:s:='GOOD    ';
  5:s:='V.HIGH! ';
  else s:='NORMAL  ';
 end;
 say(1,185,5,' R Û0: REFUNDING RATE: '+s);
 for c:=1 to 16 do
  begin
   say(10,c*8+20,0,chr(c+64)+':');
   if merch[c]<>255 then say(15,c*8+20,0,objnam(merch[c]));
  end;
end;

begin
 if not objok then exit;
 if s[5]='H' then
  begin
   for i:=1 to 16 do merch[i]:=ord(s[14+i]);
   buy:=ord(s[13]);
   sell:=ord(s[14]);
  end   else
   begin
    for i:=1 to 16 do merch[i]:=255;
	buy:=0;
	sell:=0;
   end;	

 {get the items for the merchant and store them in indexes 15 thru 30}
 scrset;
 done:=false;
 repeat
  j:=upcase(readkey);
  case j of
   #0:if readkey=#59 then help;
   'A'..'P':begin
             i:=selectobj(102,0,0);
             if i<>0 then merch[ord(j)-64]:=i else merch[ord(j)-64]:=255;
             scrset;
            end;
   'S':begin
        repeat
         case sell of
          1:s:='RIPOFF! ';
          2:s:='HIGH    ';
          4:s:='LOWER   ';
          5:s:='BARGAIN!';
          else s:='NORMAL  ';
         end;
         say(43,175,2,'ˆ'+s);
        until updown(sell,1,5)>0;
        scrset;
       end;
   'R':begin
        repeat
         case buy of
          1:s:='RIPOFF! ';
          2:s:='UNFAIR  ';
          4:s:='GOOD    ';
          5:s:='V.HIGH! ';
          else s:='NORMAL  ';
         end;
         say(43,185,2,'ˆ'+s);
        until updown(buy,1,5)>0;
        scrset;
       end;
   #27:done:=true;
  end;
 until done;

 s:='MERCHANT    '+chr(buy)+chr(sell);
 for i:=1 to 16 do if merch[i]=26 then merch[i]:=1;
 for i:=1 to 16 do s:=concat(s,chr(merch[i]));
end;

begin
 newtop:=false;
 top:=0;
 showresponse;
 checklength;
  {16 row display, top line is top+}
 row:=1;column:=1; {the current char is talk^[topicat+top+row-1].data[column]}
repeat
 done:=false;
 if newtop then begin;showresponse;checklength;newtop:=false;end;
 with talk^[topicat+top+row-1] do
  if (datatype=0) then
     say(6+column*2,26+row*8,6,data[column])
  else say(6+column*2,26+row*8,6,'*');

 j:=readkey; if j=#0 then j0:=readkey;
 with talk^[topicat+top+row-1] do
  if (datatype=0) then
    talksay(6+column*2,26+row*8,data[column])
  else if (column<11) then
   say(6+column*2,26+row*8,datatype,data[column])
  else say(6+column*2,26+row*8,1,' ');

 case j of
  #13:begin;column:=1;if row<lines then inc(row);end;

  #0:case j0 of
     #59:help;
     'H':begin
          if row>1 then dec(row) else
            if top>0 then
            begin
             dec(top);
             newtop:=true;
            end;
         end;
     'P':begin
          if row<lines then inc(row) else
            if ((lines=16) and (morelines>0)) then
           begin
            inc(top);
            newtop:=true;
           end;
         end;
     'K':if column>1 then dec(column);
     'M':if column<30 then inc(column);
     'G':column:=1;
     'O':column:=30;
     'I':row:=1;
     'Q':row:=lines;
     #63:if talk^[topicat+top+row-1].datatype=0 then
         begin
          talk^[topicat+top+row-1].data[column]:=chr(ord(talk^[topicat+top+row-1].data[column]) XOR 128);
          with talk^[topicat+top+row-1] do
           talksay(6+column*2,26+row*8,data[column]);
          if column<30 then inc(column) else
             begin;column:=1;if row<lines then inc(row);end;	
	     end;
     #32:begin {alt D}
          deleteline(topicat,topicat+top+row-1);
          showresponse;
         end;
     #23:if top+row>1 then begin {alt I}
          insertline(topicat+top+row-2);
          talk^[topicat+top+row-1].datatype:=0;
          talk^[topicat+top+row-1].data:=' ';
          talk^[topicat+top+row-1].headertype:=10;
          showresponse;
          checklength;
         end else
          begin
           insertline(topicat+top+row-1);
           talk^[topicat+top+row].datatype:=0;
           talk^[topicat+top+row].data:=' ';
           talk^[topicat+top+row].headertype:=10;

           showresponse;
           checklength;

          end;
		
     #30:begin {alt I}
          insertline(lines+1);
          showresponse;
          checklength;
         end;

		
      #20:if talk^[topicat+top+row-1].datatype<>0 then begin {alt t}
           talk^[topicat+top+row-1].datatype:=0;
           talk^[topicat+top+row-1].data:=' ';
           showresponse;checklength;
          end;
      #46:begin {alt c}
          if talk^[topicat+top+row-1].datatype=0 then
          begin
           talk^[topicat+top+row-1].datatype:=1;
           talk^[topicat+top+row-1].data:='     ';
          end;
           say(8,26+row*8,1,'ˆ');
           case talk^[topicat+top+row-1].data[5] of
            'O':newt:=2;
            'C':newt:=3;
            'H':newt:=1;
            'I':newt:=5;
            'G':newt:=6;
            '*':newt:=7;
            '-':newt:=8;
            ':':newt:=9;
	        '#':newt:=10;
	        'K':newt:=11;
			'D':newt:=12;
			'.':newt:=13;
			'N':newt:=14;
			'U':newt:=15;
            else newt:=4; {T}
           end;
               repeat
                case newt of
                 1:s:='MERCHANT  ';
                 2:s:='MACRO     ';
                 3:s:='ATTACK    ';
                 4:s:='END TOPIC ';
                 5:s:='TERMINATE ';
                 6:s:='ITEMGIVE  ';
                 7:s:='GOTO*     ';
                 8:s:='ITEM-TAKE ';
                 9:s:='SETV:     ';
				10:s:='SKIN#     ';
				11:s:='WAITKEY   ';	{20}
				12:s:='SOUND     ';
				13:s:='SONG.     ';
				14:s:='BEGINQUEST';
				15:s:='ENDQUEST  ';
                end;
                say(10,26+row*8,0,s);
               until updown(newt,1,15)>0;
              case newt of
               9:begin
                  i2:=helpindex;
                  helpindex:=77;
                  say(30,26+row*8,2,'[A-Z]?');
                  s:=upcase(readkey);
                  if (s[1]>='A') and (s[1]<='Z') then
                   begin
                    talk^[topicat+top+row-1].data:='SETV:'+s;
                    say(26,26+row*8,2,'VALUE:');
                    s:=readlin(38,26+row*8,3,1);
                    val(s,i,i1);
                    if i1<>0 then i:=0;
                    s:=strnum(i);
                    for i3:=length(s) to 2 do s:='0'+s;
                    talk^[topicat+top+row-1].data:=
                     talk^[topicat+top+row-1].data+'='+s;
                   end;
                  helpindex:=i2;
                 end;
               8:begin
                  i:=selectobj(102,0,0);i:=i+1000;
				  if i<>1001 then
				   begin
                    talk^[topicat+top+row-1].data:='ITEM-TAKE '+strnum(i);
				   end else
                   begin
                    say(26,26+row*8,2,'AMOUNT:');
                    s:=readlin(42,26+row*8,4,1);
					val(s,i,i1);
                    if i1<>0 then i:=0;
					i:=i+10000;
					talk^[topicat+top+row-1].data:='CASH-TAKE '+strnum(i);
                   end;	
				   talk^[topicat+top+row-1].data[11]:=' ';
                 end;
               7:begin
                  i2:=helpindex;
                  helpindex:=77;
                  say(1,170,1,'THIS COMMAND WILL JUMP TO A NEW TOPIC.');
                  say(1,180,1,'THE NEW TOPIC WILL HAVE A NAME FROM   ');
                  say(1,190,1,'"*0" TO "*255".  PRESS F1 FOR HELP.   ');
                  say(8,26+row*8,1,'GOTO *');
                  s:=readlin(20,26+row*8,3,0);
                  val(s,i,i1);if i1<>0 then
                   if length(s)=1 then
                    case s[1] of
                     'A'..'Z':i1:=0;
                    end;
                  if i>255 then i:=255;
                  if i<0 then s:='0';
                  if i1<>0 then s:='0';
                  s:='GOTO*'+s+'  ';
                  talk^[topicat+top+row-1].data:=s;
                  helpindex:=i2;
                 end;
               1:begin
                  s:=talk^[topicat+top+row-1].data;
                  helpindex:=53;
                  getmerchant(s);
                  helpindex:=51;
                  talk^[topicat+top+row-1].data:=s;
                 end;
				 10:begin
                  say(8,26+row*8,1,'SKIN#  ');
                  s:=readlin(22,26+row*8,3,1);
                  val(s,i,i1);if i1<>0 then i:=0;
                  say(22,26+row*8,1,strnum(i)+'    ');
                  talk^[topicat+top+row-1].data:='SKIN# '+strnum(i)+'.';
                 end;
				 12:begin
                  say(8,26+row*8,1,'SOUND#   ');
                  s:=readlin(22,26+row*8,3,1);
                  val(s,i,i1);if i1<>0 then i:=0;
                  say(22,26+row*8,1,strnum(i)+'    ');
                  talk^[topicat+top+row-1].data:='SOUND '+strnum(i)+'.';
                 end;
				 13:begin
                  say(8,26+row*8,1,'SOUND#   ');
                  s:=readlin(22,26+row*8,3,1);
                  val(s,i,i1);if i1<>0 then i:=0;
                  say(22,26+row*8,1,strnum(i)+'    ');
                  talk^[topicat+top+row-1].data:='SONG. '+strnum(i)+'.';
                 end;
				 2:begin
                  say(8,26+row*8,1,'MACRO #');
                  s:=readlin(22,26+row*8,3,1);
                  val(s,i,i1);if i1<>0 then i:=0;
                  say(22,26+row*8,1,strnum(i)+'    ');
                  talk^[topicat+top+row-1].data:='MACRO #'+strnum(i);
                 end;
               6:begin
                  i:=selectobj(102,0,0);i:=i+1000;
                  talk^[topicat+top+row-1].data:='ITEMGIVE  '+strnum(i);
                 end;
               3:begin
                  say(8,26+row*8,1,
                   'ATTACK: Û5GÛ1D/Û5EÛ1V/Û5NÛ1U/Û5AÛ1N/Û5PÛ1LR/AÛ5LÛ1L');
                  case upcase(readkey) of
                   'G':s:='ATTACK GD  ';
                   'E':s:='ATTACK EV  ';
                   'N':s:='ATTACK NU  ';
                   'A':s:='ATTACK AN  ';
                   'L':s:='ATTACK ALL ';
                   '0':s:='ATTACK 0   ';
                  else s:='ATTACK P.  ';
                  end;
                  talk^[topicat+top+row-1].data:=s;
                 end;
               4,5,11,14,15:talk^[topicat+top+row-1].data:=s;
               end;
           showresponse;checklength;
          end;
      #16:begin {alt q}
           insertline(topicat+top+row-1);
           talk^[topicat+top+row].datatype:=0;
           talk^[topicat+top+row].data:=' ';
           talk^[topicat+top+row].headertype:=4;
           insertline(topicat+top+row-1);
           talk^[topicat+top+row].datatype:=0;
           talk^[topicat+top+row].data:=' ';
           talk^[topicat+top+row].headertype:=3;
           insertline(topicat+top+row-1);
           talk^[topicat+top+row].datatype:=0;
           talk^[topicat+top+row].data:=' ';
           talk^[topicat+top+row].headertype:=2;
           showresponse;
           checklength;
          end;
      #19:begin {alt r}
           s:=readlin(16,11,8,0);
           if (s<>#27) and (s<>'') then talk^[topicat].header:=s;
           say(16,11,0,talk^[topicat].header+'         ');
          end;
    end; {case 0}
  #32..#126:if talk^[topicat+top+row-1].datatype=0 then
         begin
          talk^[topicat+top+row-1].data[column]:=j;
          with talk^[topicat+top+row-1] do
           talksay(6+column*2,26+row*8,data[column]);
          if column<30 then inc(column) else
             begin;column:=1;if row<lines then inc(row);end;
          end;
  #8:if talk^[topicat+top+row-1].datatype=0 then
        if column>1 then begin
         talk^[topicat+top+row-1].data[column-1]:=#32;
         dec(column);
        end else
        if row>1 then begin;dec(row);column:=30;end;
  #27:done:=true;
 end; {j case}
until done;
end;

procedure talkedit(whatt:byte);
 var
  topic:array[1..42] of string[10];
  topicn:array[1..42] of word;
  fc,whatf,x,y:byte;
  j:char;
  done:boolean;
  i1:integer;


procedure showtopics;
 var i:integer;

  function texist(n:word):boolean;
 var f:file of byte; s:string[12];
  begin
   s:='TALK'+strnum(n)+'.TXT';
   assign(f,s);
   {$I-} reset(f); {$I+}
   if ioresult=0 then begin;close(f);texist:=true;end
    else texist:=false;
  end;

begin
 clearscreen;
 if texist(whatt) then
  begin
   say(1,1,0,'GAME WILL USE TALK'+strnum(whatt)+'.TXT INSTEAD!');

  end else
  begin
   say(0,1,6,' EDIT DIALOGUE                         ');
   say(66,1,4,' #'+strnum(whatt)+' ');

  end;
 say(5,11,5,' F Û0ILE: '+talk^[1].data);
 say(1,23,0,'CURRENT TOPICS:');
 say(1,180,0,'PRESS Û5 F3 Û0 TO CREATE A TOPIC,');
 say(1,190,0,'Û5 …† Û0 TO EDIT A TOPIC, Û5ESCÛ0 TO EXIT.');
 whatf:=1;
 fc:=3;
 topic[1]:='(INTRO)';
 topic[2]:='(BYE)';
 topic[3]:='(?)';
 for i:=2 to 999 do if (talk^[i].headertype=1)

 and
  (talk^[i].header<>'(INTRO)')
  and
  (talk^[i].header<>'(BYE)')
   and
  (talk^[i].header<>'(?)')

  then begin
   inc(fc);
   topic[fc]:=talk^[i].header;
   topicn[fc]:=i-1;
  end;
 if fc<=14 then i1:=fc else i1:=14;
 for i:=1 to i1 do
  say(5,25+(i*8),0,topic[i]);
 if fc<=28 then i1:=fc else i1:=28;
 for i:=15 to i1 do
  say(30,25+(i-14)*8,0,topic[i]);
 for i:=29 to fc do
  say(55,25+(i-28)*8,0,topic[i]);
end;

procedure showtopic(c,n:byte);
 var x,y:byte;
begin
 if n>28 then begin;x:=55;y:=25+(n-28)*8;end else
 if n>14 then begin;x:=30;y:=25+(n-14)*8;end else
 begin;x:=5;y:=25+(n*8);end;
 say(x,y,c,topic[n]);
end;


begin
 loaddialogue(whatt);
 showtopics;
 repeat
  done:=false;
  showtopic(6,whatf);
  j:=upcase(readkey);
  showtopic(0,whatf);
  case j of
   #0:case readkey of
       #59:help;
       #61:if fc<42 then begin  {create new topic}
             inc(fc);
             if fc>28 then begin;x:=55;y:=25+(fc-28)*8;end else
             if fc>14 then begin;x:=30;y:=25+(fc-14)*8;end else
             begin;x:=5;y:=25+(fc*8);end;whatf:=fc;
             topic[whatf]:=readlin(x,y,8,0);
             y:=1;
             if (topic[whatf]<>#27) and (topic[whatf]<>'')
                {and (topic[whatf,1]<>'(')}
              then begin
               begin
                 y:=4;
                 insertline(1);x:=2;
                 with talk^[x] do begin
                   headertype:=1;
                   header:=topic[whatf];
                   datatype:=0;
                   data:=' ';
                  end;
                end;
              end;
             showtopics;whatf:=y;
            end;
       'H':if whatf>1 then dec(whatf) else whatf:=fc;
       'P':if whatf<fc then inc(whatf) else whatf:=1;
       'K':if whatf-14>=1 then dec(whatf,14);
       'M':if whatf+14<=fc then inc(whatf,14);
       'G','I':whatf:=1;
       'O','Q':whatf:=fc;
      end;
   'F':begin
        talk^[1].data:=readlin(21,11,16,0);
        for i1:=1 to 17 do say(19+i1*2,11,0,' ');
        if talk^[1].data=#27 then
          talk^[1].data:=concat('DIALOGUE '+strnum(whatt));
        say(21,11,0,talk^[1].data);
       end;
   #32,#13:begin
            if (topic[whatf,1]='(') then
             begin
               for i1:=2 to 998 do if talk^[i1].header=topic[whatf]
                then begin;done:=true;topicn[whatf]:=i1-1;end;
               if not done then
                begin
                 insertline(1);
                 i1:=2;
                 topicn[whatf]:=1;
                 with talk^[i1] do
                  begin
                   headertype:=1;
                   header:=topic[whatf];
                   datatype:=0;
                   data:=' ';
                  end;
                 end;
               done:=false;
             end;
            helpindex:=51;
            topic_edit(topicn[whatf]+1);
            helpindex:=50;
            y:=whatf;
            showtopics;
            whatf:=y;
           end;
   #27:begin;whatf:=0;done:=true;end;
   end;
 until done;

 savedialogue(whatt);
end;

