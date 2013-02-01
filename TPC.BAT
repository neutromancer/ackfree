@echo off
echo.
echo Compiling %1...
..\tpc /m /uc:\tp;c:\tp\bgi /tc:\tp /$F+ /$G+ %1 %2 %3 %4 %5 %6 %7 %8 %9 > %1.log
if errorlevel 1 goto error
echo %1 compiled successfully.
copy %1.exe ..\ack /y > nul
if exist c:\ack copy %1.exe c:\ack /y > nul
goto end
:error
type %1.log
echo.
pause
:end
del %1.log
copy /y %1.exe ..\ackexe > nul
del %1.exe > nul