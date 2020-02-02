function ackchar(ch:byte):char;
begin
 case ch of
  1..65:ackchar:=chr(ch+31);
  66..69:ackchar:=chr(ch+57);
  81..106:ackchar:=chr(ch+16);
 end;
end;

function parsetalk(s:string):string;
var s2:string; i:byte;

function tchar(c:char):char;
begin
 if ord(c)>127 then tchar:=char(ord(c)-128)
  else tchar:=c;
end;

begin
 s2:='';
 for i:=1 to length(s) do
  if i=1 then
  begin
   if ord(s[1])>127 then s2:='['+tchar(s[1]) else s2:=s[1];
  end else if i=length(s) then
  begin
   if ord(s[i])>127 then s2:=s2+tchar(s[i])+']' else s2:=s2+s[i];
  end else
  begin
   if ord(s[i])>127 then
     if ord(s[i-1])<128 then s2:=s2+'[';
   s2:=s2+tchar(s[i]);
   if ord(s[i])>127 then
     if ord(s[i+1])<128 then s2:=s2+']';

  end;
 parsetalk:=s2;
end;


 function texist(n:word):boolean;
 var f:file of byte; s:string[12];
  begin
   s:='TALK'+strnum(n)+'.TXT';
   assign(f,s);
   {$I-} reset(f); {$I+}
   if ioresult=0 then begin;close(f);texist:=true;end
    else texist:=false;
  end;


procedure exportmessages;

 var f:text; i,i2,c,x,y:integer;
     lf:file of longmsgrec;
     sf:file of shortmsgrec;
     df:file of talkrec;
     talkbuff:talkrec;
     lmsg:longmsgrec;
     smsg:shortmsgrec;
     s:string;
     write_this_line:boolean;
     talkpointers:array[0..1001] of word;


begin
  assign(f,'MESSAGES.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult=0 then begin
  writeln(f,'Adventure name: '+ADVNAME);
  msgexptext(f,1);
  msgexptext(f,2);

   assign(sf,ADVNAME+SHORTMSGFILE);
   {$I-} reset(sf); {$I+}
   if ioresult=0 then
   begin
   say(5,150,0,'SHORT MESSAGES...');
   writeln(f,' ');
   writeln(f,'Short messages:');
   for i:=1 to filesize(sf) do
   begin
     read(sf,smsg);
     if smsg.empty=false then
     begin
     writeln(f,strnum(i)+':');
     for y:=1 to 2 do
     begin
      write_this_line:=false; s:='   |';
      for x:=1 to 37 do
       begin
        c:=ord(smsg.chars[y,x]);
        s:=s+ackchar(c);
        if c<>1 then write_this_line:=true;
      end; {x}
      if write_this_line then writeln(f,s+'|');
     end; {y}
     end; {not empty}
    end; {shortmessage loop}
   close(sf);
   end; {short msg section}


   assign(sf,ADVNAME+SHORTMSGFILE2);
   {$I-} reset(sf); {$I+}
   if ioresult=0 then
   begin
   for i:=1 to filesize(sf) do
   begin
     read(sf,smsg);
     if smsg.empty=false then
     begin
     writeln(f,strnum(i+255)+':');
     for y:=1 to 2 do
     begin
      write_this_line:=false; s:='   |';
      for x:=1 to 37 do
       begin
        c:=ord(smsg.chars[y,x]);
        s:=s+ackchar(c);
        if c<>1 then write_this_line:=true;
      end; {x}
      if write_this_line then writeln(f,s+'|');
     end; {y}
     end; {not empty}
    end; {shortmessage loop}
   close(sf);
   end; {short msg section}


    assign(lf,ADVNAME+LONGMSGFILE);
    {$I-} reset(lf); {$I+}
    if ioresult=0 then
    begin
     say(5,150,0,'LONG MESSAGES... ');
     writeln(f,' ');
     writeln(f,'Long messages:');
     for i:=1 to filesize(lf) do
      begin
       read(lf,lmsg);
       if lmsg.empty=false then begin
        writeln(f,strnum(i)+':');
        for y:=1 to 22 do begin
         s:='   |';write_this_line:=false;
         for x:=1 to 32 do begin
           c:=ord(lmsg.chars[y,x]);
           if c<>1 then write_this_line:=true;
           s:=s+ackchar(c);
          end;
         if write_this_line then writeln(f,s+'|');
        end;
       end;
      end;
     close(lf);
    end; {longmsg file op}

   writeln(f,'');
   writeln(f,'Export completed successfully.');
   close(f);
   end;

   assign(f,'DIALOGUE.TXT');
 {$I-} rewrite(f); {$I+}
 if IOresult=0 then begin
  writeln(f,'Adventure name: '+ADVNAME);
  msgexptext(f,3);
  msgexptext(f,4);

   assign(df,ADVNAME+DIALOGUEFILE);
   {$I-} reset(df); {$I+}
   if ioresult=0 then
   begin
    say(5,150,0,'DIALOGUE DATA... ');
    writeln(f,' ');
    writeln(f,'Dialogues:');
    read(df,talkbuff);
    for i:=1 to 255 do
    if texist(i) then
	begin
	     writeln(f,'');
         writeln(f,'___________________________________________');
         writeln(f,'#'+strnum(i)+': File TALK'+strnum(i)+'.TXT');
    end else
    begin	
	
     say(5,160,0,strnum(i));
     seek(df,i);
     read(df,talkbuff);
     {if (talkbuff.data)<>('DIALOGUE '+strnum(i)) then}
      begin


        {clear out the conversation array}
        for i2:=1 to 1000 do
        begin
        talk^[i].headertype:=0;
        talk^[i].header:=' ';
        talk^[i].datatype:=0;
        talk^[i].data:=' ';
        talk^[i].next:=0;
        end;

       {start with the record just loaded,}
       talk^[1]:=talkbuff;
       i2:=2;

       {and load the rest of the conversation}
       while (talkbuff.next<>0) and (i2<1001) do
       begin
		talkpointers[i2]:=talkbuff.next;	
        seek(df,talkbuff.next);
        read(df,talkbuff);
        talk^[i2]:=talkbuff;

        inc(i2);
       end;
       {current dialogue is now loaded into talk[] array}




         writeln(f,'');
         writeln(f,'___________________________________________');
         writeln(f,'#'+strnum(i)+': '+talk^[1].data);
         write_this_line:=true;
         for i2:=1 to 1000 do
         if write_this_line then
         begin
         if talk^[i2].next=0 then write_this_line:=false;
         if (talk^[i2].headertype=1)
         then begin
           writeln(f,'');
           writeln(f,'  Topic: '+talk^[i2].header);

         end;
         {write(f,' ',talkpointers[i2],'\ ');}
           case talk^[i2].headertype of
           2:write(f,'  [?]-');
           3:write(f,'  [Y]-');
           4:write(f,'  [N]-');
        else write(f,'      ');
           end;
           if talk^[i2].datatype=0 then
            begin
             if i2>1 then writeln(f,parsetalk(talk^[i2].data));
			end
            else
              begin
               writeln(f,'*----------'+talk^[i2].data);
              end;

         end;




      end;
    end;
	(*
	seek(df,0);
	i:=0;
	while not eof(df) do
	 begin
	  read(df,talkbuff);
	  write(f,i,': ',talkbuff.headertype,'/',talkbuff.header,'/',talkbuff.datatype,'/',talkbuff.data);
	  writeln(f,' --> ',talkbuff.next);
	  inc(i);
	 end;
	  *)
    close(df);
   end; {dialogue file op}
   writeln(f,'');
   writeln(f,'Export completed successfully.');
   close(f);
  end; {export file op}
  say(5,150,0,'                  ');
  say(5,160,0,'   ');

end;




procedure defragtalkfile;
 var df,df2:file of talkrec;
    talkbuff:talkrec;
	indexnext:array[1..255] of word;
	i:integer;
	realnext,nextwrite:word;
begin
   assign(df,ADVNAME+DIALOGUEFILE);
   {$I-} reset(df); {$I+}
   if ioresult=0 then
   begin

    assign(df2,'talk.tmp');
	rewrite(df2);

    talkbuff.headertype:=255;
    talkbuff.data:='DIALOGUE FILE';
    talkbuff.header:=#26;
    talkbuff.datatype:=0;
    talkbuff.next:=0;
    write(df2,talkbuff);

	
	for i:=1 to 255 do
	 begin
	  seek(df,i);
	  read(df,talkbuff);
      write(df2,talkbuff);	  	
	 end;
	  {the talkbuff.next from df2 are wrong, but we'll fix them later}
	
	nextwrite:=256;
	
	for i:=1 to 255 do
     begin
	  seek(df,i);
	  read(df,talkbuff);
	  if talkbuff.next=0 then indexnext[i]:=0
       else	  indexnext[i]:=nextwrite;
	  while talkbuff.next<>0 do
	   begin
	    seek(df,talkbuff.next);
		read(df,talkbuff);
		realnext:=talkbuff.next;
		if talkbuff.next<>0 then talkbuff.next:=nextwrite+1;
		write(df2,talkbuff);
		inc(nextwrite);
		talkbuff.next:=realnext;
		
	   end; {while}
	


     end;	{i}
	
	close(df);
	close(df2);
	reset(df2);
	for i:=1 to 255 do
	 begin
	  seek(df2,i);
	  read(df2,talkbuff);
	  talkbuff.next:=indexnext[i];
	  seek(df2,i);
	  write(df2,talkbuff);
	 end;

    close(df2);	
	
   end;
end;
