@echo off
cls
:top
rem call tpc /$L- /$D- /L /m ack02.pas
rem  /$O+ /$E- /$S- /$G+
rem Copy either I_OVRDCF (fast) or I_OVRDCS (slow) to I_OVRDEC
echo.
echo Compiling ACK02...
..\tpc /m /l /ud:\tp;d:\tp\bgi /td:\tp /$F+ /$G+ /$S- /$E- /$L- /$D- /$O+ ack02.pas > ack02.log
if errorlevel 1 goto error
echo ACK02 compiled successfully.
copy ack02.exe ..\ack /y > nul
copy ack02.ovr ..\ack /y > nul
if not exist c:\ack goto end
copy ack02.exe c:\ack /y > nul
copy ack02.ovr c:\ack /y > nul
goto end
:error
type ack02.log
echo.
pause
goto top
:end
del ack02.log
copy /y ack02.exe ..\ackexe > nul
copy /y ack02.ovr ..\ackexe > nul
del ack02.exe > nul
del ack02.ovr > nul


