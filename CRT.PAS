unit crt;

interface

uses dos;

procedure delay(delayms:word);

implementation;

var starting_h:word;

procedure delay;
var
 hh,mh,ss,ms,timenow,delayend:word;


begin
 gettime(hh,mm,ss,ms);

 if starting_h > hh then hh:=hh+24;

 hh:=hh - starting_h;

 delayend := ((ms + delayms) DIV 100) +
              (ss*10) + (mm*600) + (hh*36000);
			
 repeat
   gettime(hh,mm,ss,ms);
   if starting_h > hh then hh:=hh+24;
   hh:=hh - starting_h;
   timenow := ((ms) DIV 100) +
              (ss*10) + (mm*600) + (hh*36000);
 until timenow>=delayend;
end;

procedure initdelay;
var
 hh,mm,ss,ms:word;
begin
 gettime(hh,mm,ss,ms);
 starting_h:=hh;
end;

begin
 initdelay;
end.
