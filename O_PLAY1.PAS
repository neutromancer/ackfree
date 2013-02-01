{$O+}
{$F+}
unit o_play1;

 {This overlay contains little bits of junk that are seldom used by the
  ACK adventure.}

interface

uses xms,u_help,u_io,u_vars,
       graph,u_graph,u_adv,crt2,dos,u_fonts,u_graps,o_play0,o_play0a,u_sound,u_delay2;


procedure conversation(n:byte;var anger:byte);
procedure startlog;
procedure newplayer;
procedure read_documentation;
procedure game_selection;
procedure startup_sequence;
procedure check_requiredfiles;
procedure savegame_menu;
procedure loadgame_menu(var filefuture:byte);

implementation

var filefuture:byte;
    needpause:boolean;
	queries:array[1..12] of string[8];
	lastchatter:word;

type datetimetype = string[8];




var lasttalkblank:boolean;
    talkyloc:byte;

procedure talkscrollsay(s:string);
begin
  if s='                              ' then s:='';
  if ((s<>'') or ((s='') and (lasttalkblank=false))) then
  begin
  
  if talkyloc>169 then
  begin
   for i:=3 to 168 do move(mem[$a000:scrnh[i+9]+4],mem[$a000:scrnh[i]+4],256);
   for i:=169 to 177 do fillchar(mem[$a000:scrnh[i]+4],256,lo(TEXTC0));
   talksay(3,169,s);
  end else
  begin
   talksay(3,talkyloc,s);
   talkyloc:=talkyloc+8;

  end;  
   
  end;
  if s='' then lasttalkblank:=true else lasttalkblank:=false;
    
end;


var talk_done:boolean;
    say_goodbye:boolean;

(*
type vmrec = record
   v:byte; n:byte; p:word;
    end;


procedure varmerchant(s:string);
 const BLANK='                           ';
var
 i,i1:byte;done:boolean;j:char;ss:string[5];
 ie:integer;
 merch:array[1..4] of vmrec;
procedure scrset;
 var c:byte;
 s:string;
begin
 say(3,topic_yloc*8-7,0,BLANK);
 say(5,topic_yloc*8-7,0,'(PRESS NUMBER, OR Û6ESCÛ0)');
end;

begin
 for i:=1 to 4 do
  begin
   merch[i].v:=ord(s[14+i*4-3]);
   merch[i].n:=ord(s[14+i*4-2]);
   merch[i].p:=ord(s[14+i*4-1])*256 + ord(s[14+i*4]);
  end;
 scrset;
 done:=false;
 repeat
  j:=upcase(readkey);
  case j of
   #0:if readkey=#59 then help;
   '1'..'4':if merch[ord(j)-48].v<>0 then
            begin
             i:=ord(j)-48;
             say(3,topic_yloc*8-7,0,BLANK);
             say(3,topic_yloc*8-7,0,'PRICE: '+strnum(merch[i].p)+
              '.  PAY? [Y/N]');
             if upcase(readkey)='Y' then
              if ack.PCASH>=merch[i].p then
              begin
               ack.variables[merch[i].v]:=merch[i].n;
               ack.PCASH:=ack.PCASH-merch[i].p;
               say(3,topic_yloc*8-7,0,BLANK);
               say(3,topic_yloc*8-7,0,'PURCHASED!');
               delay2(1000);
              end else
              begin
               say(3,topic_yloc*8-7,0,BLANK);
               say(3,topic_yloc*8-7,0,'YOU CANNOT AFFORD IT!');
               delay2(1300);
              end;
              done:=true;
            end;
   #27:done:=true;
  end;
 until done;
 say(3,topic_yloc*8-7,0,BLANK);inc(topic_yloc);
end;

*)


procedure merchant(s:string);
var
 merch:array[1..16] of byte; {255 is empty, not 0}
 i,i1:byte;done:boolean;j:char;
 offer:word;
 buy,sell:byte;

procedure scrset;
 var c:byte;
begin
 clearscreen; 
 showbmp(65530,false);

 bottomsay(1,' PRESS Û5 A Û0..Û5 P Û0, TO PURCHASE,');
 bottomsay(2,' Û5 S Û0 TO SELL, OR Û5ESCÛ0 TO EXIT.');
 for c:=1 to 16 do
  if merch[c]<>255 then begin
   say(7,c*9,4,' '+chr(c+64)+' Û1:');
   say(16,c*9,0,obj^[merch[c]].n);
   offer:=obj^[merch[c]].d[11]*256+
    obj^[merch[c]].d[12];
             case sell of
              1:offer:=offer*4;
              2:offer:=offer*2;
              4:offer:=round(offer-(offer/5));
              5:offer:=round(offer-(offer/2));
             end;
   say(50,c*9,1,strnum(offer));
  end;
end;

begin
 talkyloc:=17;
 for i:=1 to 16 do merch[i]:=ord(s[14+i]);
 for i:=1 to 16 do if merch[i]=1 then merch[i]:=26;
 buy:=ord(s[13]);sell:=ord(s[14]);
 {get the items for the merchant and store them in indexes 15 thru 30}
 scrset;
 done:=false;
 repeat
  j:=upcase(readkey);
  case j of
   #0:if readkey=#59 then help;
   'A'..'P':if merch[ord(j)-64]<>255 then begin
             offer:=obj^[merch[ord(j)-64]].d[11]*256+
               obj^[merch[ord(j)-64]].d[12];
             case sell of
              1:offer:=offer*4;
              2:offer:=offer*2;
              4:offer:=round(offer-(offer/5));
              5:offer:=round(offer-(offer/2));
             end;
             clearbottom;
             s:=obj^[merch[ord(j)-64]].n;
             bottomsay(1,'ITEM:'+s+' PRICE:'+
              strnum(offer));
             bottomsay(2,'FUNDS: '+strnum(ack.PCASH)+
              '   PURCHASE ITEM? [Y/N]');
             i:=0;
             if obj^[merch[ord(j)-64]].t<>11 then
              putgrap(72,180,obj^[merch[ord(j)-64]].d[1]);
             repeat
              case upcase(readkey) of
               'Y':i:=1;
               #27,'N':i:=2;
              end;
             until i<>0;
             if i=1 then
              if ACK.PCASH>=offer then
              begin
               if ack.PINV[merch[ord(j)-64]]<255 then
                begin
                 clearbottom;bottomsay(0,'ITEM PURCHASED.');
                 dec(ack.PCASH,offer);
                 inc(ack.PINV[merch[ord(j)-64]]);
                end else begin;clearbottom;
                 bottomsay(0,'YOU CAN ONLY CARRY 255 OF THIS.');end;
              end else begin;clearbottom;
               bottomsay(0,'NOT ENOUGH MONEY!');end;
             if i=1 then delay2(500);
             clearbottom;
             bottomsay(1,' PRESS Û5 A Û0..Û5 P Û0, TO PURCHASE,');
             bottomsay(2,' Û5 S Û0 TO SELL, OR Û5ESCÛ0 TO EXIT.');
            end;
   'S':begin
        clearbottom;
        bottomsay(1,'SELECT THE ITEM YOU WISH TO');
        bottomsay(2,'SELL, OR PRESS Û5ESCÛ0 TO ABORT.');
        i:=selectinventory(205,' SELL ITEM');
        if (i<>0) and (i<>255) then
         begin
          clearbottom;
          offer:=obj^[i].d[11]*256+obj^[i].d[12];
	  
          s:='NO';
          for i1:=1 to 16 do if merch[i1]=i then s:='YES';
		  if s='YES' then
            case sell of
              4:offer:=round(offer-(offer/5));
              5:offer:=round(offer-(offer/2));
             end;		

          i1:=ack.intelligence[0];
          if i1<3 then i1:=3;
          if i1>20 then i1:=20+(i1 DIV 40);
          offer:=round(offer * (i1/26));
		  
          {"offer" is now the base price, modified for your INT, further modified to reflect
            the selling price IF it's something he sells}
			
          case buy of
           1:offer:=offer DIV 8;
           2:offer:=offer DIV 3;
		   3:offer:=offer DIV 2;
           4:if s<>'YES' then offer:=offer+(offer DIV 3);
           5:if s<>'YES' then offer:=offer*2;
          end;
 
          say(2,180,0,'OFFERED: '+strnum(offer));
          say(34,180,0,'ITEM: '+obj^[i].n);
          bottomsay(2,'ACCEPT OFFER? [Y/N]');
          i1:=0;
          repeat
           case upcase(readkey) of
            'Y':i1:=1;
            'N',#27:i1:=2;
           end;
          until i1<>0;
          if i1=1 then
           begin
            dec(ack.PINV[i]);
            inc(ack.PCASH,offer);
            clearbottom;bottomsay(0,'ITEM SOLD!');delay2(500);
           end;
         end;
        scrset;
       end;
   #27:done:=true;
  end;
 until done;
  clearscreen; 
 showbmp(65530,false);

end;


 var
  query_found:boolean;
  query:string;
  accept_query:boolean;
  music_changed:boolean;


function get_query:string;
var s:string;

function talkreadlin(xat,yat:integer;maxchars,typeofchars:byte):string;

type setos=set of char;
     setosa=array[0..2] of setos;
{0: any chars, 1: number only, 2: filename chars}

const allowedchars:setosa=( [#32..#126] , ['1'..'9','0'] ,
   ['A'..'Z','-','!','&','1'..'9','0','_'] );

var cp:byte;
    inkey:char;
    s:string;
    showstr:string;
    blankstr:string;
    insmode,done:boolean;
    c:byte;
    lengths:byte;
	upcount:byte;

begin
upcount:=0;
hidemouse;
pausemouse:=true;
blankstr:='';
for cp:=1 to maxchars do blankstr:=concat(blankstr,' ');
cp:=1;
s:='';
insmode:=true;
done:=false;
repeat
if ord(s[0])>maxchars then s[0]:=chr(maxchars);

showstr:=blankstr;
move(s[1],showstr[1],length(s));
say(xat,yat,barcolor,showstr+'Û0 ');

say(xat+( (cp-1)*2 ),yat,6,' ');

inkey:=upcase(readkey);
case inkey of
 #32..#126:if (inkey in allowedchars[typeofchars]) then
          if length(s)<=maxchars then
            begin {string can grow}
              if cp<=maxchars then
              begin
                if insmode then s:=concat(s,s[length(s)]);
                if insmode then move(s[cp],s[cp+1],length(s)-cp);
                s[cp]:=inkey;inc(cp);
				upcount:=0;
               end;
            end
           else
           begin {string can NOT grow}
             if cp<length(s) then
              begin
                if insmode then move(s[cp],s[cp+1],length(s)-cp+1);
                s[cp]:=inkey;inc(cp);
				upcount:=0;
              end;

            end;
    #8:if cp>1 then begin;dec(cp);
       move(s[cp+1],s[cp],length(s)-cp);dec(s[0]);end;
    #0:case readkey of
        #59:help;
		'H':if upcount<12 then
		    if queries[upcount+1]<>'' then
			begin {up arrow}
			 inc(upcount);
			 s:=queries[upcount];
			 cp:=length(s)+1;
		    end; 
		'P':if upcount>1 then
		    begin {down arrow}
			 dec(upcount);
			 s:=queries[upcount];
			 cp:=length(s)+1;		    
		    end else
			begin
			 s:='';cp:=1;
			 {blank line}
			end; 
        #75:if cp>1 then dec(cp);
        #77:if cp<length(s) then inc(cp) else
          if length(s)<maxchars then begin;inc(cp);s:=concat(s,' ');end;
        {#82:if insmode=true then insmode:=false else insmode:=true;}
        #83:if cp<=length(s) then
        begin;move(s[cp+1],s[cp],length(s)-cp);dec(s[0]);end;
       end; {0case}
     #13:done:=true;
     #27:begin;s:=#27;done:=true;end;
     end; {case}
until done;
talkreadlin:=s;
if s<>#27 then
  for cp:=11 downto 1 do
   queries[cp+1]:=queries[cp];
   queries[1]:=s;
 

pausemouse:=false;
showmouse;
end;


begin
 talkscrollsay('');
 bottomsay(2,'Û2YOU SAY:');
 repeat
  s:=talkreadlin(18,188,12,0);
 until s<>'';
 if length(s)>8 then s:=copy(s,1,8);
 bottomsay(2,'                         ');
 if s[1]='*' then s[1]:='?';
 if s[1]='(' then s[1]:='?';
 get_query:=s;
   for i:=3 to 178 do fillchar(mem[$a000:scrnh[i]+4],256,lo(TEXTC0));
   talkyloc:=17;
end;

function yes_or_no:boolean;
 var done:boolean;
begin
 done:=false;
 repeat
  case upcase(readkey) of
   'Y':begin;done:=true;yes_or_no:=true;end;
   'N':begin;done:=true;yes_or_no:=false;end;
  end;
 until done;
end;

procedure savetalkscreen;
var tempf:file;
begin
 if mouseon then hidemouse;
 { move(mem[$a000:0000],bank1^,64000); }
 assign(tempf,'SCREEN2.TMP');
 rewrite(tempf,256);
 for i:=3 to 178 do blockwrite(tempf,mem[$a000:scrnh[i]+4],1);
 close(tempf);
 if mouseon then showmouse;
end;

procedure restoretalkscreen;
var tempf:file;
begin
 if mouseon then hidemouse;
 { move(bank1^,mem[$a000:0000],64000); }
 assign(tempf,'SCREEN2.TMP');
 reset(tempf,256);

  for i:=3 to 178 do blockread(tempf,mem[$a000:scrnh[i]+4],1);

 close(tempf);
 if mouseon then showmouse;
end;


function alreadytalked(n:byte):byte;
var f: file of byte;
    b,b0,b1: byte;
	
begin
 b0:=0; b1:=1;
 assign(f,ADVNAME+'.DQT');
 {$I-} reset(f); {$I+}
 if ioresult<>0 then
   begin
    rewrite(f);
    for b:=1 to 255 do
	 if b<>n then write(f,b0) else write(f,b1);
	alreadytalked:=0;
    close(f);
    exit;	
   end;
  seek(f,n-1);
  read(f,b);
  if b=0 then 
   begin
    alreadytalked:=0;
    b:=1;
    seek(f,n-1);
    write(f,b);
   end	

	else alreadytalked:=b;

  
  close(f);
 end; 

 procedure setquestflag(d,n:byte);
 var f: file of byte;
	
begin
 assign(f,ADVNAME+'.DQT');
 {$I-} reset(f); {$I+}
 if ioresult<>0 then exit;
 seek(f,d-1);
  write(f,n);  
  close(f);
 end; 
 

procedure show_response(topicat:word;var anger:byte;n:byte);
 var i:integer;
    topic_done:boolean;
    topic_yloc:byte;
    replysearch:byte;
    reply_ok:boolean;
    dummy_s:string;
    ii,iie,ii2:integer;
	takingitem,itemtaken:boolean;
	waitk:char;
	
procedure topicdone(reason:string);
begin
 writelog(0,reason);	
 topic_done:=true;
end;
 
begin
 stopsound(4);
 replysearch:=0;
 lasttalkblank:=false;
 topic_done:=false;i:=topicat;topic_yloc:=4;
 reply_ok:=true;
 takingitem:=false;

 repeat
  if (replysearch<>0) and (talk^[i].headertype>2)
   and (talk^[i].headertype<5)
   then
    begin
     if talk^[i].headertype=replysearch then reply_ok:=true
                                        else reply_ok:=false;
    end;
 if reply_ok then
  if talk^[i].datatype=0 then
    talkscrollsay(talk^[i].data)
   else case talk^[i].data[5] of
    'K':begin
	     bottomsay(2,'Û2MORE -- PRESS A KEY');
		 talkscrollsay('');
		 waitk:=readkey; if waitk=#0 then waitk:=readkey;
		 bottomsay(2,'                   ');
		end;
	'#':begin
	     for ii:=7 to 13 do if talk^[i].data[ii]='.' then iie:=ii;
         val(copy(talk^[i].data,7,iie-7),ii,iie);
         if iie<>0 then ii:=0;        {fhjkdsgfajsdhgfjsdhjnmgadyf}
         if ii=0 then ii:=n;
		 bmpskinname:='TALK'+strnum(ii)+'.BMP';

		 savetalkscreen;
		 showbmp(65530,false);
         restoretalkscreen;	 
		 {say(70,160,0,copy(talk^[i].data,7,1));}
	     {say(60,170,0,copy(talk^[i].data,8,pos('  ',talk^[i].data)-8));}
	    end;
	'D':begin
	     for ii:=7 to 13 do if talk^[i].data[ii]='.' then iie:=ii;
         val(copy(talk^[i].data,7,iie-7),ii,iie);
         if iie<>0 then ii:=0;     
         if ii=0 then stopsound(4)
		  else soundeffect(ii,4);

	    end;
	'.':begin
	     for ii:=7 to 13 do if talk^[i].data[ii]='.' then iie:=ii;
         val(copy(talk^[i].data,7,iie-7),ii,iie);
         if iie<>0 then ii:=0;     
         if ii=0 then stopsound(2)
		  else soundeffect(ii,2);
		 music_changed:=true; 

	    end;		
    'I':begin;talk_done:=true;say_goodbye:=false;end;
    'T':topicdone('end topic');
    ':':begin
         val(copy(talk^[i].data,8,3),ii,iie);
		 iie:=ii DIV 256; ii:=ii AND 255;
         ack.variables[ord(talk^[i].data[6])-64]:=ii;
		 if (ord(talk^[i].data[6])-64)>7 then ack.variableshi[ord(talk^[i].data[6])-64]:=iie;
        end;
    '*':begin
         topicdone('goto');accept_query:=false;
         query:='*'+copy(talk^[i].data,6,pos(' ',talk^[i].data)-6);
         case query[2] of
          'A'..'Z':query:='*'+strnum(ack.variables[ord(query[2])-64]);
         end;
        end;
    'H':begin
	     merchant(talk^[i].data);  
		 bmpskinname:='TALK'+strnum(n)+'.BMP';
		 showbmp(65530,false);
     	end;
    'G':begin
         val(copy(talk^[i].data,12,3),ii,iie);
		 writelog(n,'ItemGive: '+strnum(ii));
         if (iie=0) and (ii<>0) and (ii<>255) then
          if (obj^[ii].t>5) and (obj^[ii].t<>10) then
           if ii=1 then
            inc(ack.pcash,10) else
            if ack.pinv[ii]<255 then inc(ack.pinv[ii]);
        end;
	'-':begin
	     takingitem:=true;
		 itemtaken:=false;
		 if talk^[i].data[1]='C' then
		  begin
		   val(copy(talk^[i].data,12,4),ii2,iie);
		   ii:=1;
		  end else
           val(copy(talk^[i].data,12,3),ii,iie);
		 writelog(n,'Item-Take: '+strnum(ii));
         if (iie=0) and (ii<>0) and (ii<>255) then
          if (obj^[ii].t>5) and (obj^[ii].t<>10) then
           if ii=1 then
            begin
			 writelog(n,'Item-Take: Item is cash, $'+strnum(ii2)+', player has '+strnum(ack.pcash));
			 if ack.pcash>=ii2 then 
			   begin
			    writelog(n,'Item-Take: Successful');
			    ack.pcash:=ack.pcash-ii2;
				itemtaken:=true;
			   end;
			 
			end else
			begin
			 writelog(n,'Item-Take: Item is object, '+obj^[ii].n);
			 if ack.pinv[ii]>0 then
			  begin
			   ack.pinv[ii]:=ack.pinv[ii]-1;
			   writelog(n,'Item-Take: Successful');
			   itemtaken:=true;
			  end;
             
			end; 
	       if itemtaken=false then writelog(n,'Item-Take: Player did not have item');
        end;	
    {'M':varmerchant(talk^[i].data);}
	
	'N':begin
	     setquestflag(n,2);
	    end; {beginquest}
     'U':begin
	      setquestflag(n,3);	 
	     end; {endquest}
		 
    'O':begin
        val(copy(talk^[i].data,8,pos('  ',talk^[i].data)-8),ii,iie);
        if iie<>0 then ii:=0;        {fhjkdsgfajsdhgfjsdhjnmgadyf}
		writelog(n,'Conversation launching macro: '+strnum(ii));
        if ii<>0 then run_macro(ii);
{        say(1,1,0,'Macro:'+copy(talk^[i].data,8,pos('  ',talk^[i].data)-8)+
         ','+strnum(ii));
}        if macro_teleport then
         begin;topicdone('macro teleport');talk_done:=true;say_goodbye:=false;end;
        end;
    'C':begin
        {attaCk dvunl.}
         case talk^[i].data[9] of
          'D':anger:=1;
          'V':anger:=2;
          'U':anger:=3;
          'N':anger:=4;
          '.':anger:=5;
          'L':anger:=6;
          else anger:=0;
         end;
        end;
    end; {case}
  if talk^[i].headertype=2 then
    begin
     talkscrollsay('');
	 if takingitem=false then
	  begin
       bottomsay(2,'Û2YOU RESPOND: [Y/N]');
       if yes_or_no then replysearch:=3 else replysearch:=4;
     {if replysearch=3 then
      say(2,183,0,'YES.       ') else
      say(2,183,0,'NO.        '); }
       if replysearch=3 then
	    bottomsay(1,'Û1(YOU SAID "YES")    ') else
     	 bottomsay(1,'Û1(YOU SAID "NO")    ');
	  end else
       if itemtaken then replysearch:=3 else replysearch:=4;	  
       {say(1,topic_yloc*8-7,1,'(YOU SAY YES)') else
                    say(1,topic_yloc*8-7,1,'(YOU SAY NO)');}


    end;
  writelog(i,talk^[i].data+'  next:'+strnum(talk^[i].next));	
  if talk^[i].next<>0 then inc(i) else topicdone('EOF');
  if (talk^[i].headertype<2) 
   then topicdone('topic end');
 until topic_done;
end;


procedure loaddialogue(n:byte);
var df:file of talkrec;
    talkbuff:talkrec;
    i:integer;
begin
 assign(df,ADVNAME+DIALOGUEFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then exit;
 seek(df,n);
 read(df,talkbuff);
 talk^[1]:=talkbuff;
 i:=2;
while (talkbuff.next<>0) and (i<1000) do
begin
 seek(df,talkbuff.next);
 read(df,talkbuff);
 talk^[i]:=talkbuff;
 inc(i);
end;
 writelog(0,'Loaded dialogue '+strnum(n)+', size='+strnum(i));
 close(df);
end;


procedure conversation(n:byte;var anger:byte);

function chatter:boolean;
 var f: text;
     i,i2,i3: integer;
	 s: string;
begin
 chatter:=false;
 assign(f,'talk'+strnum(n)+'.txt');
 {$I-} reset(f); {$I+}
 if ioresult=0 then
  begin

   i:=0;
   while not eof(f) do
   begin
    readln(f,s);
	if s<>'' then inc(i);
   end;
   if i<>0 then
    begin
     chatter:=true;
	 i2:=random(i)+1;
	 close(f);
	 reset(f);
	 if lastchatter=i2 then i2:=random(i)+1;
	 if lastchatter=i2 then i2:=random(i)+1;
	 lastchatter:=i2;
	 for i3:=1 to i2 do readln(f,s);
	 writelog(i2,'Small talk '+strnum(n)+', '+strnum(i2)+' of '+strnum(i)+': '+s);
	 if pos('/',s)>0 then
	  begin
	   scrollsay(copy(s,1,pos('/',s)-1));
	   scrollsay(copy(s,pos('/',s)+1, length(s)-pos('/',s)));
	  end else scrollsay(s);
	 delay2(200);
	end;
   close(f);
  end; {chatting instead of loading dialogue}
 


end;

begin
 music_changed:=false;
 if chatter then exit;
 savepage;
 hidemouse; pausemouse:=true;
 for i:=1 to 12 do queries[i]:='';
 helpindex:=33;
 talkyloc:=17;
 loaddialogue(n);
 bmpskinname:='TALK'+strnum(n)+'.BMP';
 clearscreen; 
 showbmp(65530,false);
 talk_done:=false;say_goodbye:=true;
 accept_query:=false;
 i:=alreadytalked(n);
 case i of
  1:query:='(HELLO)';
  2:query:='(BEGINQ)';
  3:query:='(ENDQ)';
  4..255:query:='(H'+strnum(i)+')';
  else query:='(INTRO)';
 end; 
  
 repeat
   if accept_query then 
    query:=get_query
	else accept_query:=true;
   query_found:=false;i:=0;
   if (query=#27) or (query='BYE') or (query='GOODBYE') then query:='(BYE)';
   
   if query='(BYE)' then talk_done:=true;
   {if (query<>'BYE') and (query<>'') then}
   repeat
    inc(i);
    if talk^[i].headertype=1 then
     if talk^[i].header=query then
       query_found:=true;
   until (query_found) or (talk^[i].next=0) or (i=999);
   if (not query_found) and 
     ((query='(HELLO)') or (query='(BEGINQ)') or (query='(ENDQ)')    )
	 then
      begin;query:='(INTRO)';accept_query:=false;end;
    
{     if say_goodbye then
      begin;query:='(BYE)';accept_query:=false;end
       else talk_done:=true; }
   if query_found then
    begin
     clearbottom;
     if (query[1]<>'(') and (query[1]<>'*')
       then bottomsay(1,'Û1(YOU SAID "'+query+'")       ');
	  writelog(n,'Player said "'+query+'"'); 
	 writelog(n,'response is at line '+strnum(i)); 
     show_response(i,anger,n);
    end else
   if query[1]='*' then
    begin
     if query<>'*?' then begin;query:='*?';accept_query:=false;end;
    end else
   if query[1]<>'(' then
    begin;query:='(?)';accept_query:=false;end;
 until talk_done;
  {clearbottom;}

  waitkey;
  loadbmppalette(ack.ackversion,ADVNAME,bgi_dir);
  helpindex:=2;
  stopsound(4);
  pausemouse:=false; showmouse;
  restorepage;
  if music_changed then stopsound(2);
  readkey_time:=0;
  readkey_default:=#255;
end;




 function file_exists(s:string):string;
 var dirinfo: searchrec;
 
 begin
     FindFirst(s, AnyFile, dirinfo);
    if doserror=0 then file_exists:=dirinfo.name else file_exists:='';
 end;


procedure startlog;

function date: datetimetype;
  { returns current date in form '08/31/84'. }

var reg:     registers;
    y,m,d,w: datetimetype;
    i:       integer;

begin
  reg.ax:=$2A00;
  intr($21,reg);
  str(reg.cx:4,y);
  delete(y,1,2);
  str(hi(reg.dx):2,m);
  str(lo(reg.dx):2,d);
  w:=m + '/' + d + '/' + y;
  for i:=1 to length(w) do if w[i]=' ' then w[i]:='0';
  date:=w;
end;

function time: datetimetype;
  { returns current time in form '08:13:59'. }

var reg:     registers;
    h,m,s,w: datetimetype;
    i:       integer;

begin
  reg.ax:=$2C00;
  intr($21,reg);
  str(hi(reg.cx):2,h);
  str(lo(reg.cx):2,m);
  str(hi(reg.dx):2,s);
  w:=h + ':' + m + ':' + s;
  for i:=i to length(w) do if w[i]=' ' then w[i]:='0';
  time:=w;
end;

begin
 deletebunch('LOG');
 writelog(0,' ');
 writelog(0,' ');
 writelog(0,'Play session started at '+time+' on '+date);
 writelog(0,' ');

end;


procedure cleartitlebottom;
var b:byte;
begin
  {51,114  to 260,163 - width 210 (char width 25, say start 14) (char height 5, char start 118)}
  for b:=114 to 163 do fillchar(mem[$a000:51+scrnh[b]],210,lo(TEXTC0));

end;




procedure newplayer;
var
    i,i1:integer;
    selectrace:byte;
    j:char;

  begin
   newwmapload:=true;
   helpindex:=31;
   selectrace:=0;
   if (ack.race[2]=#255) and (ack.race[3]=#255) then selectrace:=1;
   cleartitlebottom;
   if selectrace=0 then
    begin

      say(19,122,4,' 1 Û0    '+ack.race[1]);
      putgrap(14,114,ack.icon[1]);
     if ack.race[2]<>#255 then
      begin
       say(19,138,4,' 2 Û0    '+ack.race[2]);
       putgrap(14,130,ack.icon[2]);
      end;
     if ack.race[3]<>#255 then
      begin
       say(19,154,4,' 3 Û0    '+ack.race[3]);
       putgrap(14,146,ack.icon[3]);
      end;
     repeat
      j:='0';
      repeat
       if keypressed then j:=readkey;
       if mouseon then trackmouse;
       i:=checkmouse(14,114,30,114+16,i,0,j,'1');
       i:=checkmouse(14,130,30,130+16,i,0,j,'2');
       i:=checkmouse(14,146,30,146+16,i,0,j,'3');

      until j<>'0';
      case j of
       #0:if readkey=#59 then help;
       '1'..'3':if ack.race[ord(j)-48]<>#255 then
          selectrace:=ord(j)-48;
        end;
     until selectrace<>0;
     if selectrace=1 then say(19,122,6,' 1 ');
     if selectrace=2 then say(19,138,6,' 2 ');
     if selectrace=3 then say(19,154,6,' 3 ');
    end;
   if ack.playername='UNUSED' then ack.playername:='';
   if (ack.playername='PROMPT') then
   begin
    case selectrace of
     1:i:=114;
     2:i:=130;
     3:i:=146;
     end;
    say(19,i,0,'NAME:');
    ack.playername:=readlin(29,i,11,0);
    say(29,i,0,'               ');
    say(29,i,2,ack.playername);

   end;

   {equip weapon/armor}
   for i:=1 to 7 do Ack.Parmor[i]:=0;
   Ack.Pweapready:=0;
   for i:=1 to 12 do ack.qtile[i]:=0;
   for i:=2 to 254 do if ack.PINV[i]>0 then
    begin
     if obj^[i].t=7 then ack.pweapready:=i;
     if obj^[i].t=9 then ack.parmor[obj^[i].d[2]]:=i;
    end;
   if ack.pweapready=0 then for i:=2 to 254 do if ack.PINV[i]>0 then if obj^[i].t=8 then ack.pweapready:=i;
   brandnewgame:=true;
   with Ack do begin
    criminal:=0;
    alignment:=1;
    level:=1;
    experience:=0;
    music:=0;
    fly:=false; nomove_n:=false;
	invisible:=0;
    nomove_s:=false; nomove_e:=false;
    nomove_w:=false; 
	poison:=0;
    HP[0]:=HP[selectrace];
    HPmax[0]:=HPmax[selectrace];
    MP[0]:=MP[selectrace];
    MPmax[0]:=MPmax[selectrace];
    Strength[0]:=Strength[selectrace];
    Intelligence[0]:=Intelligence[selectrace];
    Weapskill[0]:=Weapskill[selectrace];
    RWeapskill[0]:=RWeapskill[selectrace];
    playericon:=Icon[selectrace];
    variables[1]:=VarA[selectrace];
    variables[2]:=VarB[selectrace];
    variables[3]:=VarC[selectrace];
    variables[4]:=VarD[selectrace];
    minviewdistance:=1;torchduration:=0;
    for i:=5 to 26 do variables[i]:=0;
    for i:=8 to 26 do variableshi[i]:=0;
   end;
   ack.copytype:=2;

  { for i:=2 to 254 do ack.PINV[i]:=0; }

   helpindex:=2;
   needpause:=false;

if swapinfo^.data[7]<2 then
begin
   if Ack.intropic<>0 then
    begin

     picturemessage(Ack.intropic);

    end;
   if Ack.intromsg<>0 then
    begin
     clearscreen;
     titlebars;
     load_longmsgfile(ack.intromsg);
     show_longmsg;
     clear_keyboard_buffer;
     begin;waitkey;clearbottom;end;
    end;
   swapinfo^.data[7]:=2;
   if ack.intromacro<>0 then
    run_macro(ack.intromacro);
end;


   clearscreen;
   titlebars;
  end;



(*
procedure read_documentation;
 var
  f:text;
  thisline:word;
  i:word;
  done:boolean;
  s:string;
begin
 savepage;
 closegraph;
 thisline:=1;done:=false;
 textattr:=16+14;clrscr;
 gotoxy(1,25);write('  '+#24+' '+#25+' PgUp PgDn ESC');
 textattr:=16+14;
 assign(f,ADVNAME+'.DOC');
 {$I-}
 reset(f);
 repeat
  close(f);reset(f);gotoxy(1,1);
  for i:=2 to thisline do if not eof(f) then readln(f,s);
  for i:=1 to 24 do
   if not eof(f) then begin;readln(f,s);clreol;writeln(s);end;
  case readkey of
   #0:case readkey of
    #71:thisline:=1;
    #72:if thisline>1 then dec(thisline);
    #73:if thisline>23 then dec(thisline,23);
    #81:if not eof(f) then inc(thisline,23);
    #80:if not eof(f) then inc(thisline);
   end;
   #27:done:=true;
   end;
  until done;
 close(f);
 initgraph;
 initmouse;
 loadbmppalette(ack.ackversion,ADVNAME,bgi_dir);
 restorepage;
end;
*)

procedure read_documentation;
begin
 savepage;
 picturemessage(65529);
 restorepage;
end;



type string13=string[13];

procedure startskinbmp(tryname:string13);
var bmpf:file;
    i,i2:integer;
    b,t:byte;
    line:array[0..319] of byte;
    header:array[1..54] of byte;
    name:string;

begin

  name:=file_exists(tryname);
  if name='' then name:=bgi_dir+'SKINS\'+tryname;
  assign(bmpf,name);
  {$I-} reset(bmpf,1); {$I+}
  if ioresult=0 then

   begin
    BlockRead(bmpf,header,SizeOf(header));
    i2:=header[51];
    if i2=0 then i2:=256;
    seek(bmpf,54+(i2*4));

    for i:=0 to 199 do
      begin
       blockread(bmpf,line[0],320);
       {move(line[132],mem[scrnl:132+scrnh[i]],(199-132));}
       move(line[0],mem[scrnl:scrnh[199-i]],320);

     end;



    close(bmpf);

   end; {if ioresult=0}


end;




procedure game_selection;
 var
  sr:searchrec;
  j:char;
  t0,t00:word;
  opt2,opt3,done:boolean;

begin
 hidemouse;


 helpindex:=32;
 opt2:=false;opt3:=false;done:=false;
 findfirst(ADVNAME+PLAYMASTERFILE,anyfile,sr);
 if doserror=0 then opt2:=true;
 findfirst('ABOUT.BMP',anyfile,sr);
 if doserror=0 then opt3:=true;
 repeat
   cleartitlebottom;
  {51,114  to 260,163 - width 210 (char width 25, say start 14) (char height 5, char start 118)}
{ if dosbox<>0 then begin
  say(14,155,2,'SOUND PROBLEM - PRESS Û5F1');
  case dosbox of
   2:helpindex:=37;
   3:helpindex:=55;
   end;
 end;}



if opt2 then begin;say(14,126,5, ' …† ');say(23,126,0,'CONTINUE A SAVED GAME');end;
 say(14,136,5, ' C Û0 CREATE NEW CHARACTER');
if opt3 then say(14,146,5,' ? Û0 ABOUT THIS GAME');
showmouse;
  mousekey:=#1;
  repeat
   if keypressed then mousekey:=upcase(readkey);
   if mouseon then
    begin
     trackmouse;
     nonum:=checkmouse(14,126,64,126+8,nonum,0,mousekey,#13);
     nonum:=checkmouse(14,136,64,136+8,nonum,0,mousekey,'C');
     nonum:=checkmouse(14,146,64,146+8,nonum,0,mousekey,'?');
    end;
  until mousekey<>#1;

  case mousekey of
   #27:halt;
   #0:case readkey of
      #68:halt;
      #59:begin
           help;
          end;
      end;
   'C':begin
       if opt2 then
        begin
         cleartitlebottom;
		 hidemouse;
         say(14,118,0,  '   THERE IS ALREADY A    ');
         say(14,126,0,  '    GAME IN PROGRESS.');
         say(14,134,0,  'ARE YOU SURE YOU WANT TO ');
         say(14,142,0,  '   START A NEW GAME?  ');
         say(14,150,0,  '         [Y/N]');
         repeat
          j:=upcase(readkey);
          if j=#0 then if readkey=#59 then help;
         until ((j=#27) or (j='Y') or (j='N'));
		 cleartitlebottom;
         if j='Y' then opt2:=false;
         showmouse;
        end;
       if not opt2 then
        begin {file copying}
         done:=true;
         filefuture:=1; {copying new player save files}
        end;
       end;
   #13,#32:if opt2 then begin
        done:=true;
        newwmapload:=false;
        filefuture:=2; {resuming current game}
       end;
   '?':if opt3 then read_documentation;
  end;
until done;
helpindex:=2;
end;


procedure do_filefuture;
var
  j:char;
  t0,t00:word;
begin

 if filefuture=2 then loadgame_menu(filefuture);
 case filefuture of
     2:begin
     {   say(8,183,0,'RESUMING THE GAME IN PROGRESS...');}
(*        t0:=(countfiles('X*')*3+2);
        say(40,156,1,strnum(t0)+'  ');
        dec(t0,bytecopybunch('X','1'));
        say(40,156,1,strnum(t0)+'  ');
        dec(t0,bytecopybunch('Y','2'));  {Copy save-backup to play temp files}
        say(40,156,1,strnum(t0)+'  ');
        dec(t0,bytecopybunch('Z','3'));
        say(40,156,1,strnum(t0)+'  '); *)

		MASTERFILE:=PLAYMASTERFILE;
		loadconfig;
		MASTERFILE:=TEMPMASTERFILE;
		saveconfig;
		writelog(0,'Resuming game in progress (copied '+PLAYMASTERFILE+' to '+TEMPMASTERFILE+')');
        {bytecopy(ADVNAME+PLAYMASTERFILE,ADVNAME+TEMPMASTERFILE);}
        bytecopy(ADVNAME+'.RGX',ADVNAME+'.RGT');
		deletebunch('DQT');
        if file_exists(ADVNAME+'.DQS')<>'' then bytecopy(ADVNAME+'.DQS',ADVNAME+'.DQT');		
        deletebunch('1*');
        deletebunch('2*');
        deletebunch('3*');
(*        say(38,156,1,'DONE');    *)
        MASTERFILE:=TEMPMASTERFILE;
        MAPAFILE:='.1';
        MAPBFILE:='.2';
        MAPCFILE:='.3';
        REGIONFILE:='.RGT';
        filefuture:=0;
       end;
       1:begin
      {   say(8,183,0,'CREATING NEW PLAYER SAVE FILES'); }
         t0:=(countfiles('A*')*3+2); {say(40,191,1,strnum(t0)+'  ');}
         dec(t0,bytecopybunch('A','X'));
       {  say(40,191,1,strnum(t0)+'  ');}
         dec(t0,bytecopybunch('B','Y'));  {Copy defaults to save-backup}
        { say(40,191,1,strnum(t0)+'  ');  }
         dec(t0,bytecopybunch('C','Z'));
       {  say(40,191,1,strnum(t0)+'  ');   }
         bytecopy(ADVNAME+MASTERFILE,ADVNAME+PLAYMASTERFILE);
         bytecopy(ADVNAME+REGIONFILE,ADVNAME+'.RGX');
(*         say(40,191,1,strnum(t0)+'  ');
         dec(t0,bytecopybunch('A','1'));
         say(40,191,1,strnum(t0)+'  ');
         dec(t0,bytecopybunch('B','2'));  {Copy defaults to player temp files}
         say(40,191,1,strnum(t0)+'  ');
         dec(t0,bytecopybunch('C','3'));
         say(40,191,1,strnum(t0)+'  '); *)
		 writelog(0,'Creating new game');
         bytecopy(ADVNAME+MASTERFILE,ADVNAME+TEMPMASTERFILE);
         bytecopy(ADVNAME+REGIONFILE,ADVNAME+'.RGT');
         deletebunch('1*');
         deletebunch('2*');
         deletebunch('3*');
		 deletebunch('DQT');
		 deletebunch('DQS');		 
{         say(38,191,4,'DONE');     }
         MASTERFILE:=TEMPMASTERFILE;
         MAPAFILE:='.1';
         MAPBFILE:='.2';
         MAPCFILE:='.3';
         REGIONFILE:='.RGT';
         filefuture:=0;
        end;
      else writelog(0,'Error, not loading or creating savegame'); 
	  end;{case}
end;


procedure startup_sequence;
begin
 needpause:=false;
 titlebars;

if swapinfo^.data[7]=0 then
begin
 startlog;
 clearscreen;


 if Ack.titlepic<>0 then picturemessage(ack.titlepic);
 if Ack.titlemsg<>0 then
  begin


   titlebars;
   load_longmsgfile(ack.titlemsg);
   show_longmsg;
   begin;waitkey;clearscreen;end;

  end;

 { say(2,190,0,strnum(ack.titlemacro)); }

  swapinfo^.data[7]:=1;
  swapinfo^.data[8]:=filefuture;

  if Ack.titlemacro<>0 then
   run_macro(ack.titlemacro);
   
  startskinbmp('START.BMP');
  game_selection;

end else filefuture:=swapinfo^.data[8];


  if filefuture<>1 then
   begin
    clearbottom;do_filefuture;loadconfig;writelog(0,'cash='+strnum(ack.pcash));
    if needpause then begin;clearbottom;waitkey;end;
    needpause:=false;
    {if ack.copytype<2 then newplayer;}
   end else do_filefuture;
 clearscreen;
 if ack.copytype<2 then
  begin
   {do_filefuture;}
   {titlebars;}
   newplayer;
   saveconfig;
   bytecopy(ADVNAME+TEMPMASTERFILE,ADVNAME+PLAYMASTERFILE);
  end;
end;


procedure check_requiredfiles;
 var rbad, ibad, pbad: boolean;
begin
 rbad:=false; ibad:=false; pbad:=false;
 if file_exists(ADVNAME+'.RGN')='' then rbad:=true;
 if file_exists(ADVNAME+'.ITM')='' then ibad:=true;
 if file_exists(ADVNAME+'.PPL')='' then pbad:=true;
 
 if (ibad or rbad or pbad) then
  begin
   startskinbmp('START.BMP');
   if ibad then say(16,120,0,'NO OBJECT DATA FOUND!');
   if pbad then say(16,130,0,'NO CREATURE DATA FOUND!');
   if rbad then say(16,140,0,'NO MAP DATA FOUND!');
   waitkey;
   halt;
  end;

end;

CONST SAVEX=6;
      SAVEY=70;

procedure bytecopyall(frompath,ext,topath:string);
var sr:searchrec;
begin
  findfirst(frompath+'*.'+ext,anyfile,sr);
  while doserror=0 do
   begin
    if sr.name[1]<>'.' then bytecopy(frompath+sr.name,topath+sr.name);
    findnext(sr);
   end;
end;	  
	  
procedure savegame_menu;
var
valid:array[0..9] of boolean;
    s:string[30];
    f:text;	
	j:char;
	done:boolean;
begin
 savepage;
 startskinbmp('SAVEGAME.BMP');
 valid[0]:=true;
  for i:=1 to 9 do
  begin
   valid[i]:=false;
   s:=file_exists('SAVED'+strnum(i)+'\SAVENAME.TXT');
   if s<>'' then
    begin
	 valid[i]:=true;
	 assign(f,'SAVED'+strnum(i)+'\'+s);
	 reset(f);
	 readln(f,s);
	 close(f);
	end; 
   say(SAVEX,SAVEY+(i*10),5,' '+strnum(i)+' Û0 '+s);
  end;
 say(SAVEX,SAVEY,5,' 0 Û1 (QUICKSAVE ONLY)');
 done:=false;
 repeat
  j:=readkey;
  if j=#27 then j:='0';
  case j of
   '0'..'9':begin;i:=ord(j)-48;done:=true;end;
   end; 
 until done;
 if i<>0 then
  begin
   {prompt for a game name}
   s:=readlin(SAVEX+8,SAVEY+(i*10),29,0);
   if (s='') or (s=#27) then s:='(NO NAME)';
   if not valid[i] then
    begin
	 {create folder}
	 mkdir('SAVED'+strnum(i));
	end; 
	
   assign(f,'SAVED'+strnum(i)+'\SAVENAME.TXT');
   rewrite(f);
   writeln(f,s);
   close(f);
   
   {copy saved game from game folder to savedX folder}
   bytecopyall('','X*','SAVED'+strnum(i)+'\');
   bytecopyall('','Y*','SAVED'+strnum(i)+'\');
   bytecopyall('','Z*','SAVED'+strnum(i)+'\');
   bytecopyall('','PLY','SAVED'+strnum(i)+'\');  
   bytecopyall('','DQS','SAVED'+strnum(i)+'\');   
   bytecopyall('','RGX','SAVED'+strnum(i)+'\');    
  end; 
  restorepage;
end;

procedure loadgame_menu(var filefuture:byte);
var
valid:array[0..9] of boolean;
    s:string[30];
    f:text;	
	j:char;
	done:boolean;
begin

 startskinbmp('LOADGAME.BMP');
 valid[0]:=true;
 for i:=1 to 9 do
  begin
   valid[i]:=false;
   s:=file_exists('SAVED'+strnum(i)+'\SAVENAME.TXT');
   if s<>'' then
    begin
	 valid[i]:=true;
	 assign(f,'SAVED'+strnum(i)+'\'+s);
	 reset(f);
	 readln(f,s);
	 close(f);
	 say(SAVEX,SAVEY+(i*10),5,' '+strnum(i)+' Û0 '+s);
	end; 
  end;
 say(SAVEX,SAVEY,5,' 0 Û1 (USE MOST RECENT QUICKSAVE)');
 say(SAVEX,SAVEY+100,5,' C Û1 CREATE A NEW GAME');
 done:=false;
 repeat
  j:=upcase(readkey);
  case j of
   '0'..'9':if valid[ord(j)-48] then begin;i:=ord(j)-48;done:=true;end;
   'C':begin;i:=0;filefuture:=1;done:=true;end;
   #27:halt;
   end; 
 until done;
 if i<>0 then
  begin
   {copy saved game i to game folder}
   bytecopyall('SAVED'+strnum(i)+'\','*','');
  end; 
 clearscreen;
end;  
  
begin
 lastchatter:=0;
end.