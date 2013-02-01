{       SMIX is Copyright 1995 by Ethan Brodsky.  All rights reserved.       }
program MixTest;
  uses
    CRT,

    u_SMix;
  const
    XMSRequired   = 200;    {XMS memory required to load the sounds (KBytes) }
    SharedEMB     = true;
      {TRUE:   All sounds will be stored in a shared EMB}
      {FALSE:  Each sound will be stored in a separate EMB}
    NumSounds = 6;
  var
    BaseIO: word; IRQ, DMA, DMA16: byte;
    Sound: PSound;
    OldExitProc: pointer;
	ignore:boolean;


  function HexW(W: word): string; {Word}
    const
      HexChars: array [0..$F] of Char = '0123456789ABCDEF';
    begin
      HexW :=
{        HexChars[(W and $F000) shr 12] +}
        HexChars[(W and $0F00) shr 8]  +
        HexChars[(W and $00F0) shr 4]  +
        HexChars[(W and $000F)];
    end;



  procedure ReadySounds;
    var
      i: integer;
    begin
      if not(InitXMS)
        then
          begin
            writeln('Error initializing extended memory');

            Halt(3); {XMS driver not installed}
          end
        else
          begin
            writeln('Extended memory succesfully initialized');
            write('Free XMS memory:  ', GetFreeXMS, 'k  ');
            if GetFreeXMS < XMSRequired
              then
                begin
                  writeln('Insufficient extended memory');

                  Halt(4); {Insufficient XMS memory}
                end
              else
                begin
                  writeln('Loading sounds');
                  if SharedEMB then InitSharing;

(*
                  if not(OpenSoundResourceFile('MIXTEST.SND'))
                    then
                      begin
                        writeln('Error loading sound resource file');
                        Halt(5); {Sound resource file does not exist}
                      end;


                  ignore:=LoadSound(Sound[0], 'JET');
                  ignore:=LoadSound(Sound[0], 'SINE');
                  ignore:=LoadSound(Sound[1], 'GUN');
                  ignore:=LoadSound(Sound[2], 'CRASH');
                  ignore:=LoadSound(Sound[3], 'CANNON');
                  ignore:=LoadSound(Sound[4], 'LASER');
                  ignore:=LoadSound(Sound[5], 'GLASS');

                  CloseSoundResourceFile;

                  OldExitProc := ExitProc;
                  ExitProc := @OurExitProc;
*)

				  
                end
          end;
    end;



  procedure Init;
    begin
      writeln;
      writeln('-------------------------------------------');
      writeln('Sound Mixing Library v1.30 by Ethan Brodsky');
      if not(GetSettings(BaseIO, IRQ, DMA, DMA16))
        then
          begin
            writeln('Error initializing:  Invalid or non-existant BLASTER environment variable');
            Halt(1); {BLASTER environment variable invalid or non-existant}
          end;

      if not(InitSB(BaseIO, IRQ, DMA, 0))
        then
          begin
            writeln('Error initializing sound card');
            writeln('Incorrect base IO address, sound card not installed, or broken');
            Halt(2); {Sound card could not be initialized}
          end;

      writeln('BaseIO=', HexW(BaseIO), 'h     IRQ', IRQ, '     DMA8=', DMA, '     DMA16=', DMA16);
      write('DSP version ', DSPVersion shr 8, '.', DSPVersion and $FF, ':  ');

      if SixteenBit
        then write('16-bit, ')
        else write('8-bit, ');
      if AutoInit
        then writeln('Auto-initialized')
        else writeln('Single-cycle');

      InitMixing;
      writeln;
    end;

  procedure Shutdown;
    begin
      ShutdownMixing;
      ShutdownSB;

      writeln;
    end;

  var
    Counter: LongInt;
    InKey: char;
    Stop: boolean;
    Num: byte;
    Temp: integer;
    Jet: boolean;
    RandSounds: boolean;
    Rate: word;
  begin
    Randomize;

    Init;

    ReadySounds;

	ignore:=LoadSound(Sound, 'TEST.RAW');
	
	ignore:=StartSound(Sound, 1, false);
	
	readln;
	
    StopSound(0);

    Shutdown;

    FreeSound(Sound);
	
	Shutdownsharing;
  end.
