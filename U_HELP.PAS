{$O+}
unit u_help;

interface

 uses u_graph,crt2,graph,u_adv;

var
 helpindex:byte;
 helpfile:string;

procedure help;

implementation

var crossreference:array[0..9] of byte;
var nexthelp:byte;


function helpf(n:byte):string;
 var strn:string[4];
begin
 str(n DIV 30+1,strn);
 helpf:=copy(helpfile,1,length(helpfile)-5)+strn+'.HLP'
end;


procedure loadhelpindex2(n:byte);
  var ft:text;
      strn:string[4];
      instring:string[80];
      crosscount,ierr:integer;

begin
 if n=0 then exit;
 nexthelp:=0;
 for crosscount:=0 to 9 do crossreference[crosscount]:=0;
 textattr:=16+14;
 clrscr;
 textattr:=(16+3);gotoxy(1,1);clreol;
 write('Adventure Creation Kit HELP - [ESC] to exit, [F1] for options ');
 gotoxy(1,2);textattr:=16+14;
 assign(ft,helpf(n));
 {$I-} reset(ft); {$I+}
 if ioresult<>0 then exit;
 str(n,strn);
 repeat
  readln(ft,instring);
 until (eof(ft)) or (instring='*INDEX='+strn+'*');
 instring:=' ';
 while ((eof(ft)) or (pos('*INDEX=',instring)<>0)
  or (pos('*SEE ALSO*',instring)<>0) or (pos('*WAIT*',instring)<>0) or
   (pos('*GOTO*',instring)<>0))=false
 do begin
  writeln(instring);
  instring:=' ';
  readln(ft,instring);
 end;
 if (pos('*SEE ALSO*',instring)<>0) then
 begin
  readln(ft,instring);
  crosscount:=0;
  while ((eof(ft)) or (pos('*INDEX=',instring)<>0) or (crosscount=9))=false
   do begin
    inc(crosscount);
    val(instring,crossreference[crosscount],ierr);
    readln(ft,instring);
   end;
 end;
 if (pos('*WAIT*',instring)<>0) then  {or if wherey>18}
  begin
   textattr:=(16+3);gotoxy(1,1);clreol;
   write('Adventure Creation Kit HELP.  MORE: Press a key to continue.  ');

   gotoxy(70,22);textattr:=16+7;write('Ý Þ');textattr:=16+7+128;
   write(#8#8+''+#8);textattr:=17;

   repeat until readkey<>#0;
   clrscr;
   textattr:=(16+3);gotoxy(1,1);clreol;
   write('Adventure Creation Kit HELP - [ESC] to exit, [F1] for options ');
   gotoxy(1,2);textattr:=16+14;
  end;
 if (pos('*GOTO*',instring)<>0) then
 begin
  readln(ft,instring);
  val(instring,nexthelp,ierr);
 end;
 close(ft);
end;

procedure loadhelpindex(n:byte);
begin
 repeat
  loadhelpindex2(n);
  if nexthelp<>0 then
   begin
   gotoxy(70,22);textattr:=16+7;write('Ý Þ');textattr:=16+7+128;
   write(#8#8+''+#8);textattr:=17;
   repeat until readkey<>#0;n:=nexthelp;end;
 until nexthelp=0;
 textattr:=17;
end;

procedure help;
 var helpdone:boolean;
     j:char;
     tempf:file;
     i:integer;
begin
 closemouse;
 nexthelp:=0;
 assign(tempf,copy(helpfile,1,length(helpfile)-12)+'ACKDATA0.TMP');
 rewrite(tempf,64000);
 blockwrite(tempf,mem[$a000:0000],1);
 close(tempf);
 closegraph;
 initmouse;
 window(1,1,80,25);
 textattr:=16*7+1;clrscr;
 window(4,3,78,24);textattr:=8;clrscr;
 for i:=0 to 1999 do mem[$b800:i*2]:=176;
 window(3,2,77,23);
 textattr:=14+16;
 clrscr; (*
 window(1,1,80,25);
 for i:=4 to 76 do
  begin
   gotoxy(i,2);write('Í');
   gotoxy(i,23);write('Í');
  end;
 for i:=3 to 22 do
  begin
   gotoxy(3,i);write('º');
   gotoxy(77,i);write('º');
  end;
 gotoxy(3,2);write('É');
 gotoxy(3,23);write('È');
 gotoxy(77,2);write('»');
 gotoxy(77,23);write('¼'); *)
 window(4,2,77,23);
 helpdone:=false;
 delay(500);
 loadhelpindex(helpindex);
 repeat
  j:=readkey;
  case j of
   #27:helpdone:=true;
   #0:case readkey of
     #59:loadhelpindex(20);
     #60:begin;clrscr;writeln('MemAvail = ',memavail);end;
     #68:helpdone:=true;
     #71:loadhelpindex(helpindex);
     end;
   '0'..'9':
     loadhelpindex(crossreference[ord(j)-48]);
  end;
 until helpdone;
 initgraph;
 {loadpalette;}

 setvisualpage(1);
 setactivepage(0);
 assign(tempf,copy(helpfile,1,length(helpfile)-12)+'ACKDATA0.TMP');
 {$I-} reset(tempf,320); {$I+}
 if ioresult<>0 then halt;
 for i:=0 to 199 do
  blockread(tempf,mem[$a000:i*320],1);
 close(tempf);
 setvisualpage(0);
 initmouse;
end;

begin
end.
