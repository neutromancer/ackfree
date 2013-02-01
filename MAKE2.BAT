rem Do not run this batch file directly, it is called by MAKE.BAT.
echo Compiling %1.EXE+%1.OVR (%2)...
%compiler% /m /l /$F+ /$G+ /$S- /$E- /$L- /$D- /$O+ /B %1 > compile.log
if errorlevel 1 goto fail
goto end2
:fail
type %1 >> modules.log
type %1 >> errors.log
echo ----------- >> errors.log
type compile.log >> errors.log
echo. >> errors.log
:end2