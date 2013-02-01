unit u_help;

interface

 uses u_graph,crt2,graph;

var
 screenbank:array[0..7999] of byte;
 remember:array[0..2880] of byte;

 helpindex:byte;
 helpfile:string;

procedure help;

implementation

var crossreference:array[1..9] of byte;

procedure loadhelpindex(n:byte);
  var ft:text;
      strn:string[4];
      instring:string[80];
      crosscount,ierr:integer;
begin
 if n=0 then exit;
 textattr:=7;
 clrscr;
 textattr:=16*7;gotoxy(1,1);clreol;
 writeln(' Adventure Creation Kit HELP - Press ESC to exit.');
 gotoxy(1,2);textattr:=7;
 assign(ft,helpfile);
 {$I-} reset(ft); {$I+}
 if ioresult<>0 then exit;
 str(n,strn);
 repeat
  readln(ft,instring);
 until (eof(ft)) or (instring='*INDEX='+strn+'*');
 instring:='';
 while ((eof(ft)) or (pos('*INDEX=',instring)<>0)
  or (pos('*SEE ALSO*',instring)<>0))=false do
 begin
  writeln(instring);
  readln(ft,instring);
 end;
 if (pos('*SEE ALSO*',instring)<>0) then
 begin
  readln(ft,instring);
  for crosscount:=1 to 9 do crossreference[crosscount]:=0;
  crosscount:=0;
  while ((eof(ft)) or (pos('*INDEX=',instring)<>0) or (crosscount=9))=false
   do begin
    inc(crosscount);
    val(instring,crossreference[crosscount],ierr);
    readln(ft,instring);
   end;
 end;

 close(ft);
end;

(*
procedure help;
 var helpdone:boolean;
     j:char;
begin
 if u_graph.MONO then
  begin
   move(mem[$b000:0000],bank1^,7830);
   move(mem[$b000:8192],bank2^,7830);
   move(mem[$b000:16384],bank3^,7830);
   move(mem[$b000:24576],bank4^,7830);
  end
  else begin
   move(mem[$b800:0000],bank1^,8000);
   move(mem[$b800:8192],bank2^,8000);
  end;
 closegraph;
 helpdone:=false;
 delay(500);
 loadhelpindex(helpindex);
 repeat
  j:=readkey;
  case j of
   #27:helpdone:=true;
   '1'..'9':
    loadhelpindex(crossreference[ord(j)-48]);
   '0':loadhelpindex(helpindex);
  end;
 until helpdone;
 graphicsmode;
 if u_graph.MONO then
  begin
   move(bank1^,mem[$b000:0000],7830);
   move(bank2^,mem[$b000:8192],7830);
   move(bank3^,mem[$b000:16384],7830);
   move(bank4^,mem[$b000:24576],7830);
  end
  else begin
   move(bank1^,mem[$b800:0000],8000);
   move(bank2^,mem[$b800:8192],8000);
  end;
end;
 *)

procedure help;
 {screenbank, remember:2880}
 var i:word;
     fns:string;
     f:file;
begin
 sound(800);delay(100);nosound;
 exit;
 for i:= 0 to 7999 do
  begin
   screenbank[i]:=0;
   if mem[$a000:(i*8)+0]<>0 then
     screenbank[i]:=screenbank[i] OR 128;
   if mem[$a000:(i*8)+1]<>0 then
     screenbank[i]:=screenbank[i] OR 64;
   if mem[$a000:(i*8)+2]<>0 then
     screenbank[i]:=screenbank[i] OR 32;
   if mem[$a000:(i*8)+3]<>0 then
     screenbank[i]:=screenbank[i] OR 16;
   if mem[$a000:(i*8)+4]<>0 then
     screenbank[i]:=screenbank[i] OR 8;
   if mem[$a000:(i*8)+5]<>0 then
     screenbank[i]:=screenbank[i] OR 4;
   if mem[$a000:(i*8)+6]<>0 then
     screenbank[i]:=screenbank[i] OR 2;
   if mem[$a000:(i*8)+7]<>0 then
     screenbank[i]:=screenbank[i] OR 1;
  end;
  move(mem[$a000:0000],remember[1],2880);
  sound(500);delay(200);nosound;
  readln(fns);

  assign(f,fns);
  rewrite(f,8000);
  blockwrite(f,screenbank[0],1);
  close(f);

  move(remember[1],mem[$a000:0000],2880);


end;

begin
(*
 if u_graph.MONO then
  begin
   getmem(pointer(bank1),7830);getmem(pointer(bank2),7830);
   getmem(pointer(bank3),7830);getmem(pointer(bank4),7830);
  end else
  begin
   getmem(pointer(bank1),8000);getmem(pointer(bank2),8000);
  end;
  *)
end.