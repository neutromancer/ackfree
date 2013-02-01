@echo off
if not exist z:\command.com goto nodosbox

set compiler=tpc6.exe

del errors.log > nul
del modules.log > nul
if not exist %compiler% goto nocompiler
if "%1"=="all" goto makeall
if "%1"=="player" goto makeplay
if "%1"=="editors" goto makeedit
echo.
echo MAKE all     - compile all modules
echo MAKE player  - compile only the play engine
echo MAKE editors - compile only the editing modules
echo.
goto end
echo Compiling play engine modules
:makeplay
call make2 ack02 playerengine
goto donecompiling

:makeedit
echo Compiling editor modules
echo.
call make1 ack00 mainmenu
call make1 ack01 filefinder/configedit
call make1 ack03 miniloader
call make1 ack04 importexport/macroedit
call make1 ack05 fontedit/tileedit
call make1 ack06 winlaunchernewgame
call make1 ack07 objecteditor
call make1 ack08 messageeditor
call make1 ack09 mapeditor
call make1 ack10 creatureeditor
goto donecompiling

:makeall
echo Compiling all modules
echo.
call make1 ack00 mainmenu
call make1 ack01 filefinder/configedit
call make2 ack02 playerengine
call make1 ack03 miniloader
call make1 ack04 importexport/macroedit
call make1 ack05 fontedit/tileedit
call make1 ack06 winlaunchernewgame
call make1 ack07 objecteditor
call make1 ack08 messageeditor
call make1 ack09 mapeditor
call make1 ack10 creatureeditor
goto donecompiling

:donecompiling
if exist errors.log goto errors
echo Modules compiled successfully.
echo.
echo You may now copy the compiled modules to your ACK folder.
goto end

:errors
echo.
echo There were compile errors in the following modules:
echo.
type modules.log
echo.
pause
echo.
echo ERRORS.LOG:
echo.
type errors.log


goto end

:nocompiler

echo MAKE cannot find the Turbo Pascal compiler.

goto end

:nodosbox

echo Turbo Pascal for DOS requires DOSBOX to compile all
echo modules properly.  Run MAKE from a DOSBOX session.
pause

:end


