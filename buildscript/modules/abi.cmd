@setlocal
@set abi=x86
@set /p x64=Do you want to build for x64? (y/n) Otherwise build for x86:
@echo.
@if /I "%x64%"=="y" set abi=x64
@set TITLE=%TITLE% %abi%
@TITLE %TITLE%
@set longabi=%abi%
@if %abi%==x64 set longabi=x86_64
@endlocal&set abi=%abi%&set TITLE=%TITLE%&set longabi=%longabi%