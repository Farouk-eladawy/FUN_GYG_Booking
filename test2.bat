@echo off
call :MyFunc "Test1"
call :MyFunc "Test2"
echo Done.
exit /b 0

:MyFunc
echo In func %~1
exit /b 0

