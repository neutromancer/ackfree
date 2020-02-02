{ FontEdit, GrpEdit }

{$m 63000,90000,129000}
uses u_vars,u_graph,graph,u_adv,crt2,dos,u_fonts,u_graps,u_io,u_help,u_sound;


{$I I_MSTREC.PAS}


{$I I_BYTCPY.PAS}

var sr:searchrec;
  i,fc:integer;
  files:array[0..18] of string;
  j:char;
  s,ext:string;
begin
 if paramcount>0 then if paramstr(1)='CH' then
  begin
   u_graph_setup;
   graphicsmode;
   clearscreen;
   getdir(0,bgi_dir);
   getmem(block,(BLOCKS+1)*sizeof(grpblock));
   ADVNAME:='ACKDATA7';
   loadfont;
   say(1,1,0,'Create a new ACK Adventure');
   chdir('KITS');
   fc:=0;
   findfirst('*.',16,sr);
   while (doserror=0) and (fc<18) do
    begin
     if sr.name[1]<>'.' then if sr.name<>'EMPTY' then
      begin;inc(fc);files[fc]:=sr.name;end;
     findnext(sr);
   end;
   files[0]:='EMPTY';
   say(3,16,6,' A Û1: Create empty adventure folder');
   say(3,26,1,'  (You can always import a kit later)');
   say(3,36,0,'   Or, create from a kit:');
   for i:=1 to fc do
    say(3,36+(i*10),6,' '+chr(65+i)+' Û1: '+files[i]);

   j:=upcase(readkey);
   i:=ord(j)-65;
   if (i>=0) and (i<=fc) then
     begin
	  if i=0 then say(3,16,5,' A ') else say(3,36+(i*10),5,' '+chr(65+i)+' ');
      say(8,180,0,'Enter a name for your adventure.');
	  s:=readlin(30,190,8,0);
      if ((s<>'') and (s<>#27)) then
	   begin
	    chdir(bgi_dir+'\games');
		{$I-}mkdir(s);{$I+}
		if ioresult<>0 then
		  begin
		    say(8,180,2,'   An adventure by this name    ');
			say(8,190,2,'   already exists!  Aborting.   ');
			j:=readkey; if j=#0 then j:=readkey; halt;
		  end;
		chdir(s);
		{say(1,150,0,bgi_dir+'\kits\'+files[i]+'\*.*');readln;}
		findfirst(bgi_dir+'\kits\'+files[i]+'\*.*',anyfile,sr);
        while doserror=0 do
         begin
		  ext:=copy(sr.name,pos('.',sr.name),length(sr.name)-pos('.',sr.name)+1);
		
		
          if sr.name[1]<>'.' then
		  begin
		   if pos(files[i],sr.name)=1 then
		    begin
		     if pos('.KIT',sr.name)<>0 then
			  bytecopy(bgi_dir+'\kits\'+files[i]+'\'+sr.name,s+'.MST')
			  else bytecopy(bgi_dir+'\kits\'+files[i]+'\'+sr.name,s+ext)
			end
		   else
            bytecopy(bgi_dir+'\kits\'+files[i]+'\'+sr.name,sr.name);
          end;
          {say(1,160,0,ext);
          say(1,170,0,sr.name);
		  readln;}
          findnext(sr);
         end;
	    say(8,180,0,'                                ');
	    say(8,190,0,'                                ');
		if i=0 then
		 begin
		  say(4,180,0,s+' has been created as an empty');
		  say(4,190,0,'adventure. Press any key to exit.');
		 end else
		 begin
	      say(4,180,0,s+' has been created with the');
		  say(4,190,0,files[i]+' kit. Press any key to exit.');
		 end;
		j:=readkey; if j=#0 then j:=readkey;
	
	   end;
     end;
  end else
  writeln('ACK Program File.');
end.
