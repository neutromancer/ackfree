const NUMSOUNDS=99; {determines updown -- see below, "if snd>89" for actual number of default sounds}

function soundname(snd:byte):string;
var s,s2:string;
    f:text;
    i,ie:integer;
	
	 function rawexists(n:word):string;
       var dirinfo: searchrec;
      begin
       FindFirst(strnum(n)+'-*.RAW', AnyFile, dirinfo);
       if doserror=0 then rawexists:=dirinfo.name else

       begin

        FindFirst(strnum(n)+'.RAW', AnyFile, dirinfo);
        if doserror=0 then rawexists:=dirinfo.name else


         rawexists:='';


       end;
      end;
	
begin
   s:=rawexists(snd);
   if s='' then
    begin
	 {stock content}
	 if snd>89 then
	  begin
	   {sound out of range}
	   soundname:=strnum(snd)+'-???';
	  end else
	  begin
	 assign(f,bgi_dir+'\SOUNDS\DEFAULT\SOUNDS.TXT');
	 {$I-} reset(f); {$I+}
	 if ioresult=0 then
	  begin
	
	     for i:=0 to snd do readln(f,s);
         readln(f,s);
         close(f);
	  end else s:='SOUND '+strnum(snd);
	 soundname:=s;
	end;
	end else
   begin
    {custom content}
 	  soundname:=s;

	
   end;	





(*   case snd of
      0:s:='(NONE)     ';
      1:s:='LOW BEEP   ';
      2:s:='OB.WHISTLE ';
      3:s:='DOOM BELL  ';
      4:s:='EXPLOSION  ';
      5:s:='LASER BEAM ';
      6:s:='SPLASH     ';
      7:s:='CAR START  ';
      8:s:='APPLAUSE   ';
      9:s:='AFTERBURNER';
     10:s:='CREAKY DOOR';
     11:s:='DOOR SLAM  ';
     12:s:='GUNSHOT    ';
     13:s:='DOOR CLICK ';
     14:s:='PKOII      ';
     15:s:='SCRAPE     ';
     16:s:='THUD       ';
     17:s:='METALLIC   ';
     18:s:='POWER SAW  ';

     19:s:='CHAIN SAW  '; {}
     20:s:='SHOTGUN    '; {}
     21:s:='PISTOL     '; {}

     22:s:='SPIRIT WAIL';
     23:s:='DOG BARK   ';
     24:s:='SHATTER    ';
     25:s:='KNOCKING   ';
     26:s:='TRASH CRASH';
     27:s:='ROCKET LNCH';
     28:s:='EVIL LAUGH1';
     29:s:='EVIL LAUGH2';
     30:s:='CRAZY LAUGH';


     31:s:='DOH!       ';
     32:s:='BELCH      ';
     33:s:='DYING 1    ';
     34:s:='DYING 2    ';
     35:s:='DYING 3    ';
     36:s:='GROWLING 1 ';
     37:s:='GROWLING 2 ';
     38:s:='GROWLING 3 ';


     39:s:='FALL SCREAM';
     40:s:='SHE SCREAM1';
     41:s:='SHE SCREAM2';

     42:s:='HE SCREAM 1';
     43:s:='HE SCREAM 2';
     44:s:='CRUSH YOU  ';
     45:s:='GOTTA HURT ';
     46:s:='GROOVY     ';
     47:s:='SWALLW SOUL';
     48:s:='YOU SHL DIE';
     49:s:='HORSE 1    ';
     50:s:='HORSE 2    ';
     51:s:='HORSE 3    ';

     52:s:='^ADAGIO    ';
     53:s:='^AVE MARIA ';
     54:s:='^B.SYMPH #5';
     55:s:='^BUMBLEBEE ';
     56:s:='^CANON IN D';
     57:s:='^CONCERTO3 ';
     58:s:='^CRYSTAL   ';
     59:s:='^DMACABRE  ';
     60:s:='^DOXOLOGY  ';
     61:s:='^EGYPT     ';
     62:s:='^ENEMYWIN  ';
     63:s:='^MLT. MARCH';
     64:s:='^MOONL.SNT.';
     65:s:='^PEANUTS TH';
     66:s:='^POLONAIS  ';
     67:s:='^RACHMAN1  ';
     68:s:='^SWANLAKE  ';
     69:s:='^SYMPHONY40';
     70:s:='^TURK.MARCH';



     71:s:='(STOP SND) ';

    end;


    soundname:=strnum(snd)+'-'+s;
    *)

    for i:=length(s) to 13 do s:=s+' ';

    soundname:=s;

  end;

