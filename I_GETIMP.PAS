

function getimportfilename(findbmp:boolean; defaultname:string):string;

var
 fc:byte;
 sr:searchrec;
 j:char;
 files:array[1..26] of string[12];

procedure buildfilelist;
 var i:byte;
begin

   clearscreen;
   fc:=0;
   findfirst('..\..\IMPORT\*.*',16,sr);

   while (doserror=0) and (fc<26) do
    begin
     if sr.name[1]<>'.' then
      if findbmp xor (pos('.BMP',sr.name)=0) then 
      begin
	   inc(fc);
	   files[fc]:=sr.name;
	  end;
     findnext(sr);
    end;
   
   if fc=0 then
    begin
	 {say sorry, you have nothing in your import folder}
	 
	 say(4,50,0,'NO FILES FOUND TO IMPORT FROM.');
	 say(4,60,0,'PLEASE PUT THE FILE IN YOUR');
	 say(4,70,0,'ACK\IMPORT FOLDER, RESTART THIS');
	 say(4,80,0,'EDITOR, AND TRY AGAIN.');
	 say(4,100,0,'PRESS [ESC] TO CANCEL.');


	 
	
	end else
	begin
	 {select an import file}
	 
	 say(2,3,0,'CONTENTS OF ACK\IMPORT FOLDER:');
	 
	 for i:=1 to fc do
	  say(((i-1) MOD 2)*40 +2,((i-1) DIV 2)*9+20,5,' '+chr(64+i)+' Û1: '+files[i]);
     
	 say(2, ((fc+4) DIV 2)*9+20,0,'SELECT FILE, OR ESC TO ABORT');
	end; 
    if defaultname<>'' then say(1,180,1,'PRESS ENTER TO USE THE SAME FILE AGAIN');
    say(2,190,1,'PRESS CTRL-F4 THEN F5 TO REFRESH LIST');
end; 
 
begin
     buildfilelist;
	 repeat
	  j:=upcase(readkey);
	  if j=#0 then if readkey=#63 then buildfilelist;
	 until (j=#27) or (j=#13) or ( (j>='A') and (j<=chr(64+fc)) );

	 if j=#27 then getimportfilename:='' else
	 if j=#13 then getimportfilename:=defaultname else
	 getimportfilename:='..\..\IMPORT\'+files[ord(j)-64];
	 if fc=0 then getimportfilename:='';	 
	{ say(3,180,0,strnum(ord(j)-64));
	 say(40,180,0,files[ord(j)-64]);
	 readln;
}
	
end; {function}	
	