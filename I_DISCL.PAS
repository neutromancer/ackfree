(*
procedure i_marquis;
 var s:string;
begin
 clrscr;writeln;
 for i:=1 to 7 do
 begin
  writec(0,i+1,16,'≤≤≤±±±∞∞∞                                                              ∞∞∞±±±≤≤≤');
 end;
 writec(20,3,16+12,'‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹');

 writec(20,4,4*16+12,'›');

 s:='    Adventure Creation Kit, v'+strnum(ACKVERSION DIV 10)+'.'+
                             strnum(ACKVERSION MOD 10)+' ';
 for i:=length(s) to 36 do s:=s+' ';
 writec(21,4,4*16+15,s);

 writec(wherex,4,4*16+12,'ﬁ');
 writec(wherex,4,16,'€');
 writec(20,5,4*16+12,'›');
 writec(21,5,4*16+15,'Copyright(c) 1992-95 by Chris Hopkins');
 writec(wherex,5,4*16+12,'ﬁ');
 writec(wherex,5,16,'€');
 writec(20,wherey+1,12+16,'ﬂ');
 writec(wherex,wherey,12,'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ');
 writec(wherex,wherey,16,'€');

 gotoxy(1,12);
end;

procedure i_discl;
 var i:longint;
     gd,gm:integer;
     s:string;
     mm:word;
begin
 writeln;
 writeln(' Checking system...');
 i:=diskfree(0) DIV 1024;
 exec('ACK00.EXE','&MEM');
 mm:=lo(dosexitcode)*2;
 if mm<>0 then mm:=mm+157+bigger;
 initmouse;
 if mouseon then write('  Mouse: Yes') else write('  Mouse: No ');
 if disablemouse then writeln('(disabled)') else writeln;
 closemouse;
 write('  Hard drive space: ');
 if i<1024 then write(i,' KB ') else
  write(i/1000:2:2,' MB ');
 if i>800 then writeln('(Good)') else
  if i>300 then writeln('(Low)') else writeln('(Too low!)');
 write('  Memory: ');
 if mm=0 then writeln('??') else
  begin
   write(strnum(mm-13)+' KB');
   if mm>500 then writeln(' (Good)') else
    if mm<490 then writeln(' (Too low!)') else writeln(' (Low)');
  end;
 write('  Video card: ');
 detectgraph(gd,gm);
  case gd of
   1:s:='CGA';
   2:s:='MCGA';
   3,4,5:s:='EGA';
   6,9:begin;s:='VGA';gd:=9;end;
   else s:='UNKNOWN';
  end;
 if (gd=9) or (gd=2) then s:=s+' (Good)' else s:=s+' (VGA required!)';
 writeln(s);
 if (mm<490) or (i<700) or ((gd<>9) and (gd<>2)) then
  begin
   writeln;
   writeln(' PROBLEMS - Press a key to continue');
   repeat until readkey<>#0;
   clrscr;
   writeln;
   for gm:=1 to 3 do
   begin
    textattr:=16;
    writec(0,gm+1,16,'≤≤≤±±±∞∞∞                                                              ∞∞∞±±±≤≤≤');
   end;
   writec(26,3,15+4*16,'  Adventure Creation Kit  ');
   gotoxy(1,6);
   textattr:=7;
   writeln(' Suggested actions:');
   writeln;
   if mm<490 then
    begin
     writeln('  * Try removing any Memory-Resident utilities or device drivers');
     writeln('    that you do not need.  If your system has less than 640K,');
     writeln('    consider getting a memory upgrade.');
     writeln;
    end;
   if i<700 then
    begin
     writeln('  * ACK adventures average 300K in size, and can grow during play.');
     writeln('    If the system runs out of disk space, ACK will halt with a run-');
     writeln('    time error.  Always try to have at least 2MB free when you');
     writeln('    use ACK.  If you have less than 500K free, do not try to "CREATE"');
     writeln('    anything.');
     writeln;
    end;
   if ((gd<>9) and (gd<>2)) then
    begin
     writeln('  * If you do not have a VGA or MCGA graphics card, ACK will NOT work');
     writeln('    on this system.  If you DO have a VGA or MCGA graphics card, and');
     writeln('    ACK insists that you do not, contact the author of ACK.');
     writeln;
    end;
   writeln;
   writeln(' Warning: ACK might not perform correctly on this system.');
   writeln(' Press ESC to exit this program, or any other key to attempt');
   writeln(' to run ACK.');
  end else
  begin
   writeln;
   writeln(' System O.K. - Press a key to continue.');
   end;
end;
procedure begscreen;
begin

end;
*)
var checking:boolean;

procedure nomem;
 var oh:byte;
begin
 oh:=helpindex;
 clearscreen;
 say(10,80,0,'YOU DO NOT HAVE ENOUGH MEMORY');
 say(10,90,0,'    TO RUN THIS MODULE.');
 say(12,100,1,' PRESS A KEY TO CONTINUE.');
 helpindex:=14;
 if readkey=#0 then if readkey=#59 then help;
 helpindex:=oh;
end;
procedure noacknn(n:byte);
 var oh:byte;
begin
 oh:=helpindex;
 clearscreen;
 say(10,80,0,'WARNING: THE MODULE "'+modulenum(n)+'"');
 say(10,90,0,'      WAS NOT FOUND.');
 say(14,100,1,'PRESS A KEY TO CONTINUE.');
 helpindex:=14;
 if readkey=#0 then if readkey=#59 then help;
 helpindex:=oh;
end;


procedure startlog;
var f:text;
begin
 assign(f,'ACK.LOG');
 rewrite(f);
 writeln(f,'Starting ACK log');
 close(f);
 end;

procedure exec2(s1,s2:string);
var f:text;
begin
 assign(f,'ACK.LOG');
 {$I-} append(f);{$I+}
 if ioresult<>0 then rewrite(f);
 writeln(f,'Exec: '+s1);
 writeln(f,'Parameters: '+s2);
 close(f);
 exec(s1,s2);
end;

procedure checkexec(i,n:byte);
var f:text;
begin
 {if checking then repeat until keypressed;}
 assign(f,'ACK.LOG');
 {$I-} append(f);{$I+}
 if ioresult<>0 then rewrite(f);
 write(f,'Result: ');
 write(f,i);write(f,' ');writeln(f,n);
 close(f);

 if i=8 then nomem else
 if (i=3) or (i=2) then noacknn(n);
 initmouse;
end;
