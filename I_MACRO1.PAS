
type string35=string[35];
const macronamefilesize = 255+255+255;
var macronametemp:string35;
    macronamefile:file of string35;


procedure openmacronamefile;
begin
 assign(macronamefile,ADVNAME+'.MDX');
 {$I-} reset(macronamefile); {$I+}
 if ioresult<>0 then
  begin
   rewrite(macronamefile);
   macronametemp:=' ';
   for i:=0 to macronamefilesize do
    begin
     write(macronamefile,macronametemp);
    end;
   close(macronamefile);
   reset(macronamefile);
  end;
end;

procedure closemacronamefile;
begin
 close(macronamefile);
end;


function execcomment(n:integer):string;
begin
 seek(macronamefile,0*256+n);
 read(macronamefile,macronametemp);
 execcomment:=macronametemp;
end;

function macrocomment(n:integer):string;
begin
 seek(macronamefile,1*256+n);
 read(macronamefile,macronametemp);
 macrocomment:=macronametemp;
end;

function macroname(n:integer):string;
begin
 seek(macronamefile,2*256+n);
 read(macronamefile,macronametemp);
 macroname:=macronametemp;
end;

procedure setexeccomment(n:integer;s:string);
begin
 seek(macronamefile,0*256+n);
 macronametemp:=s;
 write(macronamefile,macronametemp);
end;

procedure setmacrocomment(n:integer;s:string);
begin
 seek(macronamefile,1*256+n);
 macronametemp:=s;
 write(macronamefile,macronametemp);
end;

procedure setmacroname(n:integer;s:string);
begin
 seek(macronamefile,2*256+n);
 macronametemp:=s;
 write(macronamefile,macronametemp);
end;






function macrolinestring(m:macrorec):string;
 var sc,s:String[35];
begin
 s:='';
 with m do
 case cmd of
  46:s:=strvar(data[1,1],data[1,2],data[1,3]);
  47:s:=strvar(data[1,1],data[1,2],data[1,3]) + ' AT ' +strvar(data[2,1],data[2,2],data[2,3]);
  50:s:=strvar(data[1,1],data[1,2],data[1,3])+' '+
      strvar(data[2,1],data[2,2],data[2,3])+' TO '+
      strvar(data[3,1],data[3,2],data[3,3])+' '+
      strvar(data[4,1],data[4,2],data[4,3])+' OF '+
      strvar(data[5,1],data[5,2],data[5,3])+' '+
	  strvar(data[6,1],data[6,2],data[6,3]);
  1:begin
    s:=strvar(data[1,1],data[1,2],data[1,3]) +' = '+
    strvar(data[3,1],data[3,2],data[3,3]);
    if (data[4,1]>2) and (data[4,1]<6) then data[4,1]:=0;
    if data[4,1]<>0 then
     s:=s+macroargument[data[4,1]]+strvar(data[5,1],data[5,2],data[5,3]);
    end;
  29:begin
     s:=strvar(data[1,1],data[1,2],data[1,3]);
     if data[2,1]<>0 then
      s:=s+' '+strvar(data[2,1],data[2,2],data[2,3]);
     end;
  3:begin   {4,1 is 0 if number.  4,3 is line number!}
       if data[2,1]<3 then data[2,1]:=3;
       if data[2,1]>5 then if data[2,1]<8 then data[2,1]:=5;
       s:=strvar(data[1,1],data[1,2],data[1,3])+macroargument[data[2,1]]+
        strvar(data[3,1],data[3,2],data[3,3])+' THEN ';
	   if ((data[4,1]<>0) or (data[4,3]<>0)) then s:=s+strvar(data[4,1],data[4,2],data[4,3]);
     end;
  33..35,37..42,44,45,12,28,13,14,2,4,5,8,9,17,18,20,21:s:=strvar(data[1,1],data[1,2],data[1,3]);
  43:begin
      if data[1,1]=0 then s:=straction(data[1,3])
       else s:='ACTION # '+strvar(data[1,1],data[1,2],data[1,3]);
      while s[ length(s) ]=#32 do
      s:=copy(s,1,length(s)-1);
      if ((data[1,1]=0) and (data[2,1]=0)) then s:=s+': '+stractionp(data[1,3],data[2,3],true)
       else s:=s+': '+strvar(data[2,1],data[2,2],data[2,3]);
      if sync_app=11 then if length(s)>33 then s:=copy(s,1,33);
     end;
  15:s:=strvar(data[1,1],data[1,2],data[1,3])+' AT '+
      strvar(data[2,1],data[2,2],data[2,3])+' '+
      strvar(data[3,1],data[3,2],data[3,3]);

   25..27,49:s:=strvar(data[1,1],data[1,2],data[1,3])+' '+
        strvar(data[2,1],data[2,2],data[2,3])+' '+
        strvar(data[3,1],data[3,2],data[3,3]);
  10,11,24:if data[3,1]=0 then if data[3,3]<>0 then
	    s:=strvar(data[1,1],data[1,2],data[1,3])+' '+
        strvar(data[2,1],data[2,2],data[2,3])+' '+
		'#'+strnum(data[3,3])+'-'+obj^[data[3,3]].n
		else 
		s:=strvar(data[1,1],data[1,2],data[1,3])+' '+
        strvar(data[2,1],data[2,2],data[2,3])+' '+
        strvar(data[3,1],data[3,2],data[3,3]);
		
   16:begin
     s:=strvar(data[1,1],data[1,2],data[1,3])+' TO '+
      strvar(data[2,1],data[2,2],data[2,3])+' '+
      strvar(data[3,1],data[3,2],data[3,3])+' '+
      strvar(data[4,1],data[4,2],data[4,3])+' '+
      strvar(data[5,1],data[5,2],data[5,3]);
     end;
   14:s:='AT '+strvar(data[1,1],data[1,2],data[1,3])+' '+
        strvar(data[2,1],data[2,2],data[2,3])+' '+
        strvar(data[3,1],data[3,2],data[3,3])+' '+
        strvar(data[4,1],data[4,2],data[4,3]);


end;
if m.cmd<>0 then s:=macrocommand[m.cmd]+' '+s;

macrolinestring:=s;

end;





procedure makemacrolist;
var f:text; i,c:byte; w:word; df:file of macrorec; macbuff:macrorec; excf:file of excrec; exc:excrec; macronametemp:string;
begin

  if macrolistheader(f) then begin

   
   

   assign(df,ADVNAME+MACROFILE);
    {$I-} reset(df); {$I+}
   if ioresult=0 then begin
   for i:=1 to 250 do
     begin
      seek(df,i);
      read(df,macbuff);
      macronametemp:=macroname(i);
      if (macbuff.next<>0) or (macbuff.cmd<>0) then
       begin
        write(f,'Macro '+strnum(i)+': '+macronametemp);
        macronametemp:=macrocomment(i);
        if macronametemp<>' ' then writeln(f,'  ('+macronametemp+')') else writeln(f,' ');

        c:=2;
        writeln(f,'        1: '+macrolinestring(macbuff));
         while (macbuff.next<>0) and (c<100) do begin
          seek(df,macbuff.next);
		  w:=macbuff.next;
          read(df,macbuff);
          writeln(f,'        '+strnum(c)+': '+macrolinestring(macbuff));
          inc(c);
         end;

       end;
    end;  {i loop}
   close(df);
   end; {macro}
   (*
   writeln(f,' ');
   writeln(f,' ');
   writeln(f,'Raw macro file dump:');   
   reset(df);
   w:=0;
   while not eof(df) do
    begin
	 read(df,macbuff);
	 writeln(f,strnum(w)+': '+macrolinestring(macbuff)+' --> '+strnum(macbuff.next));
	 w:=w+1;
	end;
   close(df);
   *)
 (*  
   writeln(f,' ');
   writeln(f,' ');
   writeln(f,'Exec table:');
   writeln(f,' ');

   assign(excf,ADVNAME+EXCFILE);
   {$I-} reset(excf); {$I+}
   if ioresult=0 then begin
   for i:=1 to filesize(excf)-1 do
     begin
       seek(excf,i);
       read(excf,exc);
       if exc.fn<>'' then
       begin
        writeln(f,'Exec '+strnum(i)+': '+execcomment(i));
        write(f,'        '+exc.fn+' '+exc.prm);
        if exc.c1=0 then write(f,' (swap)');
        if exc.gmodein=1 then write(f,' (shutdown graphics)');
        if exc.gmodeout=1 then write(f,' (re-init graphics)');
        writeln(f,' ');
       end;
   end; {for i}
   close(excf);
   end; {exc}*)
   writeln(f,'');
   writeln(f,'Export completed successfully.');
   close(f);
  end;
end;

procedure createmacrofile;
 var df:file of macrorec;
   macbuff:macrorec;
   i:integer;
begin
 assign(df,ADVNAME+MACROFILE);
 rewrite(df);
 write(df,macbuff);
for i:=1 to 255 do
 begin
  macbuff.cmd:=0;
  macbuff.next:=0;
  write(df,macbuff);
 end;
 close(df);
end;

procedure clearmacro;
var i:integer;
begin
 for i:=1 to 99 do
  begin
   macro^[i].cmd:=0;
   macro^[i].next:=0;
  end;
 end;

var lines:byte;

procedure loadmacro(n:byte);
var df:file of macrorec;
    macbuff:macrorec;
    i:integer;
begin
 assign(df,ADVNAME+MACROFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then begin;createmacrofile;reset(df);end;
 seek(df,n);
 read(df,macbuff);
 clearmacro;macro^[1]:=macbuff;
 i:=2;
while (macbuff.next<>0) and (i<100) do
begin
 seek(df,macbuff.next);
 read(df,macbuff);
 macro^[i]:=macbuff;
 inc(i);
end;
 lines:=i-1;
 close(df);
end;

procedure savemacro(n:byte);
var df:file of macrorec;
begin
 assign(df,ADVNAME+MACROFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then begin;createmacrofile;reset(df);end;
 seek(df,n);
 write(df,macro^[1]);
 i:=2;
repeat
  seek(df,macro^[i-1].next);
  write(df,macro^[i]);
  inc(i);
until (macro^[i-1].next=0) or (i>99);
close(df);
end;



function mfreespace:word; {makes a new index and returns that value}
var df:file of macrorec;
    macbuff:macrorec;
    id:word;
begin
 assign(df,ADVNAME+MACROFILE);
 {$I-} reset(df); {$I+}
 if ioresult<>0 then exit;
 seek(df,filesize(df)-1);
 read(df,macbuff);
 write(df,macbuff);
 id:=filesize(df)-1;
 close(df);
 mfreespace:=id;
end;



procedure minsertline(n:integer);  {inserts a line after line N}
 var
  macbuff:macrorec;
  i:integer;
  w:word;
 begin
  for i:=98 downto n do macro^[i+1]:=macro^[i];
  with macro^[n+1] do
   begin
    cmd:=0;
   end;
  macro^[n+1].next:=macro^[n].next;
  macro^[n].next:=mfreespace;
  inc(lines);
 for i:=1 to lines do
  case macro^[i].cmd of
   2:if macro^[i].data[1,1]=0 then
      begin
       w:=macro^[i].data[1,2]*256+macro^[i].data[1,3];
       if w>=n then inc(w);
       macro^[i].data[1,2]:=w DIV 256;
       macro^[i].data[1,3]:=w MOD 256;
      end;
   3:if macro^[i].data[4,1]=0 then
      begin
       w:=macro^[i].data[4,2]*256+macro^[i].data[4,3];
       if w>=n then inc(w);
       macro^[i].data[4,2]:=w DIV 256;
       macro^[i].data[4,3]:=w MOD 256;
      end;
  end;
 end;



procedure mdeleteline(n:integer);  {deletes line N}
var i:integer;w:word;
begin
 for i:=n to 98 do macro^[i]:=macro^[i+1];
 dec(lines);
 for i:=1 to lines do
  case macro^[i].cmd of
   2:if macro^[i].data[1,1]=0 then
      begin
       w:=macro^[i].data[1,2]*256+macro^[i].data[1,3];
       if w>=n then dec(w);
       macro^[i].data[1,2]:=w DIV 256;
       macro^[i].data[1,3]:=w MOD 256;
      end;
   3:if macro^[i].data[4,1]=0 then
      begin
       w:=macro^[i].data[4,2]*256+macro^[i].data[4,3];
       if w>=n then dec(w);
       macro^[i].data[4,2]:=w DIV 256;
       macro^[i].data[4,3]:=w MOD 256;
      end;
  end;
end;





procedure compile(n,c:byte;s:String);
 var sub:array[1..6] of string[10];
  i,i1:integer;
  w:word;

begin
 if (pos('#',s)>7) and (pos('-',s)>pos('#',s)) then
  begin
   s:=copy(s,1,pos('-',s)-1);
   delete(s,pos('#',s),1);
   s:=s+' ';

  end;


 if pos('THEN',s)>7 then delete(s,pos('THEN',s)-1,5);
 if pos('AT',s)>7 then delete(s,pos('AT',s)-1,3);
 if pos('OF',s)>7 then delete(s,pos('OF',s)-1,3);
 if pos('TO',s)>7 then delete(s,pos('TO',s)-1,3);
 if pos('+',s)>4 then
   begin;insert(' ARG',s,pos('+',s));insert(' ',s,pos('+',s)+1);end;
 if pos('-',s)>4 then
   begin;insert(' ARG',s,pos('-',s));insert(' ',s,pos('-',s)+1);end;
 if pos('*',s)>4 then
   begin;insert(' ARG',s,pos('*',s));insert(' ',s,pos('*',s)+1);end;
 if pos('/',s)>4 then
   begin;insert(' ARG',s,pos('/',s));insert(' ',s,pos('/',s)+1);end;
 if pos('=',s)>4 then
   begin;insert(' ARG',s,pos('=',s));insert(' ',s,pos('=',s)+1);end;
 if pos('>',s)>4 then
   begin;insert(' ARG',s,pos('>',s));insert(' ',s,pos('>',s)+1);end;
 if pos('<',s)>4 then
   begin;insert(' ARG',s,pos('<',s));insert(' ',s,pos('<',s)+1);end;
 if pos('!',s)>4 then
   begin;insert(' ARG',s,pos('!',s));insert(' ',s,pos('!',s)+1);end;   
 if pos('&',s)>4 then
   begin;insert(' ARG',s,pos('&',s));insert(' ',s,pos('&',s)+1);end;  
 if pos('|',s)>4 then
   begin;insert(' ARG',s,pos('|',s));insert(' ',s,pos('|',s)+1);end;     
 while pos('  ',s)<>0 do
  delete(s,pos('  ',s),1);
 for i:=1 to 6 do sub[i]:='';
 for i:=1 to 7 do if pos(' ',s)<>0 then s[pos(' ',s)]:=chr(i+200);
 for i:=1 to 6 do if pos(chr(i+201),s)<>0 then
   sub[i]:=copy(s,pos(chr(i+200),s)+1,pos(chr(i+201),s)-pos(chr(i+200),s)-1);
 with macro^[n] do begin
 cmd:=c;
 for i:=1 to 6 do
  if sub[i]='' then begin;data[i,1]:=0;data[i,2]:=0;data[i,3]:=0;end
 else
 begin
  val(sub[i],w,i1);if i1=0 then
      begin;data[i,1]:=0;data[i,2]:=hi(w);data[i,3]:=lo(w);end
      else
      begin
       data[i,1]:=0;data[i,2]:=0;data[i,2]:=0;
       if sub[i]='ARG+' then data[i,1]:=1;
       if sub[i]='ARG-' then data[i,1]:=2;
       if sub[i]='ARG*' then data[i,1]:=6;
       if sub[i]='ARG/' then data[i,1]:=7;
       if sub[i]='ARG=' then data[i,1]:=3;
       if sub[i]='ARG>' then data[i,1]:=4;
       if sub[i]='ARG<' then data[i,1]:=5;
	   if sub[i]='ARG!' then data[i,1]:=8;
	   if sub[i]='ARG&' then data[i,1]:=9;
	   if sub[i]='ARG|' then data[i,1]:=10;	   
       if length(sub[i])=1 then
        if (sub[i,1]>='A') and (sub[i,1]<='Z') then
         begin;data[i,1]:=1;data[i,2]:=ord(sub[i,1])-64;end;
	   if length(sub[i])=2 then if sub[i,2]='2' then
        if (sub[i,1]>='A') and (sub[i,1]<='Z') then
         begin;data[i,1]:=30;data[i,2]:=ord(sub[i,1])-64;end;	   
       if sub[i]='HP' then begin;data[i,1]:=2;data[i,2]:=0;end;
       if sub[i]='HPMAX' then begin;data[i,1]:=2;data[i,2]:=1;end;
       if sub[i]='MP' then begin;data[i,1]:=2;data[i,2]:=2;end;
       if sub[i]='MPMAX' then begin;data[i,1]:=2;data[i,2]:=3;end;
       if sub[i]='STR' then begin;data[i,1]:=2;data[i,2]:=4;end;
       if sub[i]='INT' then begin;data[i,1]:=2;data[i,2]:=5;end;
       if sub[i]='WSK' then begin;data[i,1]:=2;data[i,2]:=6;end;
       if sub[i]='RWSK' then begin;data[i,1]:=2;data[i,2]:=7;end;
       if sub[i]='ALIGN' then begin;data[i,1]:=2;data[i,2]:=8;end;
	   if sub[i]='CRIM' then begin;data[i,1]:=2;data[i,2]:=9;end;
	   if sub[i]='HREGEN' then begin;data[i,1]:=2;data[i,2]:=10;end;
	   if sub[i]='MREGEN' then begin;data[i,1]:=2;data[i,2]:=11;end;
	   if sub[i]='POISON' then begin;data[i,1]:=2;data[i,2]:=12;end;
       if pos('INV[',sub[i])<>0 then
        begin;val( copy(sub[i],5,length(sub[i])-5), data[i,2],i1);
         data[i,1]:=3;end;
       if pos('WORN[',sub[i])<>0 then
        begin;val( copy(sub[i],6,length(sub[i])-6), data[i,2],i1);
         data[i,1]:=31;end;	
       if sub[i]='WEAPON' then data[i,1]:=32;	 
       if sub[i]='LOC[RG]' then data[i,1]:=4;
       if sub[i]='LOC[RM]' then data[i,1]:=5;
       if sub[i]='LOC[X]' then data[i,1]:=6;
       if sub[i]='LOC[Y]' then data[i,1]:=7;
       if sub[i]='VEH' then data[i,1]:=8;
       if sub[i]='VIEW' then data[i,1]:=9;
       if sub[i]='ICON' then data[i,1]:=10;
       if sub[i]='MONEY' then data[i,1]:=11;
       if sub[i]='DAYS' then data[i,1]:=13;
       if sub[i]='HOUR' then data[i,1]:=14;
       if sub[i]='MINUTE' then data[i,1]:=15;
       if sub[i]='KEYPRESS' then data[i,1]:=16;
       if sub[i]='TORCHL' then data[i,1]:=17;
       if sub[i]='ESCKEY' then data[i,1]:=18;
       if sub[i]='AGGRO' then data[i,1]:=19;
       if sub[i]='TORCHD' then data[i,1]:=20;
       if sub[i]='LEVEL' then data[i,1]:=21;
       if sub[i]='EXP' then data[i,1]:=22;
       if sub[i]='SUCCESS' then data[i,1]:=23;
	   if sub[i]='FLY' then data[i,1]:=25;
	  { if sub[i]='AUTORUN' then data[i,1]:=27;}
	   if sub[i]='INVISDUR' then data[i,1]:=28;
	   if sub[i]='INVISICO' then data[i,1]:=29;
	   
	   if sub[i]='WMUSIC' then data[i,1]:=33;
	   if sub[i]='CMUSIC' then data[i,1]:=34;
	   if sub[i]='LASTMOV' then data[i,1]:=35;   

       if pos('HELLO[',sub[i])<>0 then
        begin;val( copy(sub[i],7,length(sub[i])-7), data[i,2],i1);
         data[i,1]:=36;end;		 
	   
	   	   
	   if pos('NOMOVE(',sub[i])<>0 then
	     begin
		  data[i,1]:=26;
		  case sub[i,8] of
		   'N':data[i,2]:=1;
		   'S':data[i,2]:=2;
		   'E':data[i,2]:=3;
		   'W':data[i,2]:=4;
		   else data[i,2]:=0;
		  end;
		 end;
	if sub[i]='PORTAL' then data[i,1]:=24;
       if pos('RND(',sub[i])<>0 then
        begin;val( copy(sub[i],5,length(sub[i])-5), data[i,2],i1);
         data[i,1]:=12;end;
      end;
    end;
 end;
end;

procedure macroedit(n:byte);
 var
  topline:byte;
  thisline:byte;
  done:boolean;
  j:char;
  i:integer;
  ss:string;



procedure writeline(y,n:byte);
 var s:String;
begin
 s:=macrolinestring(macro^[n]);

 say(1,y,0,strnum(n)+':');
if macro^[n].cmd<>0 then
 say(8,y,0,s);
end;

procedure showlines;
 var c:byte;
begin
 clearscreen;
 say(1,1,6,' MACRO #'+strnum(n));
 say(1,10,5,'ƒ„NÛ0AME:'+macroname(n));
 say(1,19,5,'ƒ„CÛ0OMMENT:'+macrocomment(n));
 for c:=topline to topline+15 do
  if c<=lines then writeline((c-topline)*8+30,c);
end;



begin
 loadmacro(n);topline:=1;thisline:=1;done:=false;
 showlines;
 repeat
  say(1,(thisline-topline)*8+30,6,strnum(thisline)+':');
  j:=upcase_sync(readkey);
  say(1,(thisline-topline)*8+30,0,strnum(thisline)+':');
  case j of
   #0:case readkey of
     #46:begin {alt-C}
          macronametemp:=readlin(21,20,28,0);
          if macronametemp<>#27 then setmacrocomment(n,macronametemp);
          showlines;
         end;

     #49:begin {alt-N}
          macronametemp:=readlin(15,10,30,0);
          if macronametemp<>#27 then setmacroname(n,macronametemp);
          showlines;
         end;

     #59:help;
    { #68:begin;done:=true;quittime:=true;end; }
     'H':if thisline>topline then dec(thisline) else
          if topline>1 then begin;dec(thisline);dec(topline);showlines;end;
     'P':if (thisline<topline+15) and (thisline<lines) then
          inc(thisline) else
          if topline+15<lines then
            begin;inc(topline);inc(thisline);showlines;end;
      #23:begin
          minsertline(thisline);
          if (thisline<topline+15) and (thisline<lines) then
          inc(thisline) else
          if topline+15<lines then
            begin;inc(topline);inc(thisline);end;
          showlines;
          end;
      #32:if lines>1 then
	      begin;mdeleteline(thisline);
          if thisline>lines then thisline:=lines;showlines;end;
	  #83:begin
	        macro^[thisline].cmd:=0;
			say(8,(thisline-topline)*8+30,0,blankspace);
		  end;

      end;
	#3:clipboard:=macro^[thisline];
    #22:begin
	     clipboard.next:=macro^[thisline].next;
	     macro^[thisline]:=clipboard;
         say(8,(thisline-topline)*8+30,0,blankspace);
         writeline((thisline-topline)*8+30,thisline);
		end; 
	#24:begin
	     clipboard:=macro^[thisline];
	     macro^[thisline].cmd:=0;
		 say(8,(thisline-topline)*8+30,0,blankspace);
	
	    end;
   #13:begin
            ss:=macroreadlin(8,(thisline-topline)*8+30,32,0,macrolinestring(macro^[thisline]))+' ';
            if (ss=' ') then
              macro^[thisline].cmd:=0 else
            for i:=1 to MACROMAX do
             if copy(ss,1,pos(' ',ss)-1)=macrocommand[i] then
              compile(thisline,i,ss);
       say(8,(thisline-topline)*8+30,0,blankspace);
            writeline((thisline-topline)*8+30,thisline);
			
			if (thisline<topline+15) and (thisline<lines) then
          inc(thisline) else
          if topline+15<lines then
            begin;inc(topline);inc(thisline);showlines;end;
           end;
   #27:done:=true;
  end;
 until done;
 savemacro(n);
end;


procedure execedit;
 var excf:file of excrec;
     exc:excrec;
     excn:byte;
     ss:string;
     i,i1:integer;
     redisp,done:boolean;
     j:char;
begin
 assign(excf,ADVNAME+EXCFILE);
 {$I-} reset(excf); {$I+}
 if ioresult<>0 then
  begin
   {$I-} rewrite(excf); {$I+}
   if ioresult<>0 then exit;
   write(excf,exc);
   close(excf);reset(excf);
  end;
 say(6,81,1,'ENTER THE EXEC NUMBER TO EDIT.');
 say(6,90,1,'[1 TO '+strnum(filesize(excf))+']:');
 ss:=readlin(29,90,3,1);
 val(ss,i,i1);if i1=0 then if (i>0) and (i<256) then
  begin
   if i=filesize(excf) then
    begin
     seek(excf,i-1);read(excf,exc);
     exc.fn:=' ';
     exc.prm:=' ';
     exc.gmodein:=1;
     exc.gmodeout:=1; {re-init coming back}
     exc.c1:=0;exc.c2:=0;exc.c3:=0;exc.c4:=0;
      {c1: used for swap.  c2: required.}
     write(excf,exc);
    end;
   if i<filesize(excf) then
    begin
     seek(excf,i);read(excf,exc);
     close(excf);
     excn:=i;redisp:=true;done:=false;
      clearscreen;
	  execeditmenu;
      say(50,1,4,' #'+strnum(excn)+' ');
     repeat
      if redisp then
        begin
         say(33,30,0,'             ');
         say(35,40,0,'                      ');
         say(33,30,2,exc.fn);
         say(35,40,2,exc.prm);
         case exc.gmodein of
          0:ss:='NO CHANGE         ';
          1:ss:='SHUT DOWN GRAPHICS';
          end;
         say(22,65,2,ss);
         case exc.gmodeout of
          0:ss:='NO CHANGE       ';
          1:ss:='RE-INIT GRAPHICS';
          end;
         say(24,75,2,ss);
         case exc.c1 of
          0:ss:='YES';
          1:ss:='NO ';
          end;
         say(39,100,2,ss);
     {    case exc.c4 of
          0:ss:='NO ';
          1:ss:='YES';
          end;
         if exc.c1=0 then say(49,110,2,ss); }
         say(26,125,2,execcomment(excn));
        end;redisp:=false;
      j:=upcase_sync(readkey);
      case j of
       'S':begin;redisp:=true;if exc.c1=0 then exc.c1:=1 else
            exc.c1:=0;end;
       'F':begin
           exc.fn:=readlin(33,30,12,0);redisp:=true;
           if (exc.fn='') or (exc.fn=#27) then exc.fn:=' ';
           end;
       'K':begin
           if exc.c4=0 then exc.c4:=1 else exc.c4:=0;redisp:=true;
           end;
       'C':begin
            macronametemp:=readlin(26,125,25,0);
            setexeccomment(excn,macronametemp);
            redisp:=true;
            say(26,125,0,'                          ');
           end;
       'P':begin
           exc.prm:=readlin(35,40,21,0);redisp:=true;
           if (exc.prm='') or (exc.prm=#27) then exc.prm:=' ';
           end;
       'I':begin
           if exc.gmodein=0 then exc.gmodein:=1 else exc.gmodein:=0;
           redisp:=true;end;
       'O':begin
           if exc.gmodeout=0 then exc.gmodeout:=1 else exc.gmodeout:=0;
           redisp:=true;end;
       #27:done:=true;
      end;
     until done;
     reset(excf);seek(excf,excn);write(excf,exc);close(excf);
    end;
  end;
end;


procedure MacroMainMenu;
 var ss:string[4];
     i,i1,i2:integer;
     j:char;
     filesz:integer;

begin
 openmacronamefile;
 repeat
  clearscreen;
  if j='X' then say(6,180,0,'EXPORT COMPLETED');
  if j='D' then say(6,180,0,'DEFRAG COMPLETED');
  
  quittime:=false;
macroeditmenu;
 j:=upcase_sync(readkey);
  case j of
   #0:case readkey of
       #59:help;
       #68:quittime:=true;
       end;
   'M':begin
        say(6,130,1,'ENTER THE MACRO NUMBER TO EDIT.');
        say(6,140,1,'[1 TO 255]:');
        ss:=readlin(29,140,3,1);
        val(ss,i,i1);if i1=0 then if (i>0) and (i<256) then macroedit(i);
       end;
    'E':execedit;
    'X':makemacrolist;
{	'D':macrodefrag(ADVNAME,MACROFILE); }
    end; {case}

 until quittime;

 closemacronamefile;

end;