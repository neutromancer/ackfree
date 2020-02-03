unit u_delay2;

interface

uses dos;

var delay_calibration:longint;

function getclock:word;
function supergetclock:longint;

procedure delay2(delayms:word);
procedure calibratedelay(path:string);

implementation

var starting_h:word;


function getclock:word;
var
 hh,mm,ss,ms:word;
begin
 gettime(hh,mm,ss,ms);
 if starting_h > hh then hh:=hh+24;
 getclock := ((ms) DIV 100) + (ss*10) + (mm*600) + (hh*36000);
end;

function supergetclock:longint;
var
 hh,mm,ss,ms:word;
begin
 gettime(hh,mm,ss,ms);
 if starting_h > hh then hh:=hh+24;
 supergetclock := ((ms) ) + (ss*1000) + (mm*60000) + (hh*3600000);

end;

(*

1 hour = 60 min = 3600 sec = 3600000 ms

3600000 = 3600000 = 3600000 = 3600000






procedure delay2(delayms:word);
var
 hh,mm,ss,ms,timenow,delayend:word;
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

*)
procedure delay2(delayms:word);
 var w,w2,w3,
  hh,mm,ss,ms,timenow,delayend:word;
begin
if (delayms<1000) and (delay_calibration<60000) then
begin
  w2:=round(delay_calibration * (delayms/1000));
  for w:=1 to w2 do w3:=round(0.01*w/2+sqrt(w));
end else
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

end;


procedure initdelay;
var
 hh,mm,ss,ms:word;

begin
 gettime(hh,mm,ss,ms);
 starting_h:=hh;
end;


procedure calibratedelay(path:string);

 {calibrate 1/20sec delay}
var
 w,w2:longint; w3:word;
 c,c2,c3:longint;
 f:file of longint;
 cal:array[1..3] of longint;
 i:byte;
begin

assign(f,path);
{$I-} reset(f);

if ioresult=0 then
begin
 read(f,delay_calibration);
 close(f);
end
else
begin
for i:=1 to 3 do
begin

repeat
 c:=supergetclock;
 w2:=6000;
 for w:=1 to w2 do w3:=round(0.01*w/2+sqrt(w));
 c2:=supergetclock;
 c3:=c2-c;
until c3>0;
  delay_calibration:=round(w2 * (1000 / c3) ); {1/50 of a sec}
{ writeln('Iterations: ',w2);
 writeln('Time required: ',c3);
 writeln('1 sec worth of iterations: ',delay_calibration); }
 cal[i]:=delay_calibration;

end;

if cal[1]>cal[2] then begin; c:=cal[2]; cal[2]:=cal[1]; cal[1]:=c; end;
if cal[2]>cal[3] then begin; c:=cal[3]; cal[3]:=cal[2]; cal[2]:=c; end;
if cal[1]>cal[2] then begin; c:=cal[2]; cal[2]:=cal[1]; cal[1]:=c; end;

{write('Possible calibration values: ');
for i:=1 to 3 do write(cal[i],' ');
writeln;
writeln('Using: ',cal[2]);}
delay_calibration:=cal[2];
rewrite(f);
write(f,delay_calibration);
close(f);
end;
{
readln;
for c3:=1 to 16 do
begin
 c:=supergetclock;
 write('Testing 0.1 sec delay...');
 w2:=delay_calibration DIV 10;

 for w:=1 to w2 do w3:=round(0.01*w/2+sqrt(w));
 c2:=supergetclock;
 writeln('Actual delay ',c2-c,' ms');
end;

for c3:=1 to 6 do
begin
 c:=supergetclock;
 write('Testing 1 sec delay...');
 w2:=delay_calibration;

 for w:=1 to w2 do w3:=round(0.01*w/2+sqrt(w));
 c2:=supergetclock;
 writeln('Actual delay ',c2-c,' ms');
end; }

end;

begin
 initdelay;

end.
