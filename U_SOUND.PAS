unit u_sound;

interface

{uses voctool,cmftool,u_graph;}
uses u_smix;

var
  disable_music:boolean;
  disable_sound:boolean;

procedure setvolume(volume:byte);
procedure shutdownsound;
procedure playsound(soundname:string; channel:byte);
procedure stopsound(channel:byte);
procedure stopmusic;
function musicstatus:byte;
procedure allowmix;

implementation

procedure setvolume;
begin
 smixsetvolume(volume);
end;

procedure shutdownsound;

begin
 shutdownsmix;
end;

procedure playsound;

begin
 if (disable_music and (channel=2)) then exit;
 if disable_sound then exit;
 smixplay(channel,soundname);
end;

procedure stopsound;
begin
 smixstop(channel);
end;

procedure stopmusic;
begin
 smixstop(2);
end;

function musicstatus:byte;
begin
 musicstatus:=smixplaying(2);


end;

procedure allowmix;
begin
 smixmixing:=true;
end;

begin
  disable_sound:=false;disable_music:=false;
  startupsmix;

end.
