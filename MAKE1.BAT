rem Do not run this batch file directly, it is called by MAKE.BAT.
echo Compiling %1.EXE (%2)...
%compiler% /m $F+ $G- /B %1 > compile.log
if errorlevel 1 goto fail
goto end2
:fail
echo %1 (%2) >> modules.log
echo %1 (%2) >> errors.log
echo ----------- >> errors.log
type compile.log >> errors.log
echo. >> errors.log
:end2