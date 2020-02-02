 type string12= string[12];
  type string3= string[3];

 function fexist(n:word;c:char):string12;
 var f:file of byte; s:string12;
  begin
   s:=ADVNAME+'.'+c+strnum(n);
   assign(f,s);
   {$I-} reset(f); {$I+}
   if ioresult=0 then begin;close(f);fexist:=s;end
    else fexist:='';
  end;

 function file_exists(s:string):string;
 var dirinfo: searchrec;
 begin
    FindFirst(s, AnyFile, dirinfo);
    if doserror=0 then file_exists:=dirinfo.name else file_exists:='';
 end;



 function custom_content_exists(n:word;ext:string3):string12;
 var dirinfo: searchrec;
     f:file of byte;
 begin

    assign(f,strnum(n)+'.'+ext);
	{$I-} reset(f); {$I+}
    if ioresult=0 then
	 begin
	  custom_content_exists:=strnum(n)+'.'+ext;
	  close(f);
	 end else

    begin

    FindFirst(strnum(n)+'-*.'+ext, AnyFile, dirinfo);
    if doserror=0 then custom_content_exists:=dirinfo.name else

    begin
     custom_content_exists:='';
     if n<100 then
       if ext='BMP' then custom_content_exists:=fexist(n,'P');
    end;
    end;
  end;




procedure soundeffect(snd:word; channel:byte);
 var s:string;

function stock_sound_exists(n:word):string;
 var dirinfo: searchrec;
begin
 FindFirst(bgi_dir+'sounds\default\ack'+strnum(n)+'.RAW', AnyFile, dirinfo);
 if doserror=0 then stock_sound_exists:=bgi_dir+'sounds\default\'+dirinfo.name else
  stock_sound_exists:='';
end;

 begin

  if snd=65530 then
    begin
      stopsound(1);

    end else
	if snd<>0 then begin
	 s:=custom_content_exists(snd,'RAW');
	 if s='' then s:=stock_sound_exists(snd);
	 if s<>'' then playsound(s,channel);
    end;

end;
