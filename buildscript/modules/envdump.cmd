@setlocal
@IF NOT EXIST %devroot%\mesa-dist-win\buildinfo md %devroot%\mesa-dist-win\buildinfo
@set /p enableenvdump=Do you want to dump build environment information to a text file (y/n):
@echo.
@IF /I NOT "%enableenvdump%"=="y" GOTO skipenvdump
@echo Dumping build environment information. This will take a short while...
@echo.
@IF %toolchain%==gcc echo Build environment>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo ----------------->>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==msvc echo Build environment>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo ----------------->>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump Windows version
@FOR /F "USEBACKQ tokens=2 delims=[" %%a IN (`ver`) DO @set winver=%%a
@set winver=%winver:~0,-1%
@FOR /F "USEBACKQ tokens=2 delims= " %%a IN (`echo %winver%`) DO @set winver=%%a
@FOR /F "USEBACKQ tokens=1-3 delims=." %%a IN (`echo %winver%`) DO @set winver=%%a.%%b.%%c
@IF %toolchain%==gcc echo Windows %winver%>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==msvc echo Windows %winver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump Resource Hacker version
@IF %rhstate%==1 SET PATH=%devroot%\resource-hacker\;%PATH%
@IF %rhstate% GTR 0 FOR /F "USEBACKQ tokens=*" %%a IN (`where ResourceHacker.exe`) do @set rhloc="%%a"
@IF %rhstate% GTR 0 ResourceHacker.exe -open %rhloc% -action extract -mask VERSIONINFO,, -save %devroot%\mesa-dist-win\buildscript\assets\temp.rc -log NUL
@IF %rhstate% GTR 0 set exitloop=1&FOR /F "tokens=2 skip=2 USEBACKQ" %%a IN (`type %devroot%\mesa-dist-win\buildscript\assets\temp.rc`) do @IF defined exitloop set "exitloop="&set rhver=%%a
@IF %rhstate% GTR 0 IF %toolchain%==gcc echo Ressource Hacker %rhver:,=.%>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %rhstate% GTR 0 IF %toolchain%==msvc echo Ressource Hacker %rhver:,=.%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump 7-Zip version and compression level
@IF EXIST %devroot%\mesa-dist-win\buildscript\assets\sevenzip.txt set /p sevenzipver=<%devroot%\mesa-dist-win\buildscript\assets\sevenzip.txt
@IF %toolchain%==gcc IF defined sevenzipver echo 7-Zip %sevenzipver% ultra compression>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==msvc IF defined sevenzipver echo 7-Zip %sevenzipver% ultra compression>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get Git version
@IF NOT %gitstate%==0 FOR /F "USEBACKQ tokens=3" %%a IN (`git --version`) do @set gitver=%%a
@IF NOT %gitstate%==0 set "gitver=%gitver:.windows=%"
@IF defined gitver IF %toolchain%==gcc echo Git %gitver%>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF defined gitver IF %toolchain%==msvc echo Git %gitver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump MSYS2 environment
@IF %toolchain%==gcc echo.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo MSYS2 environment>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo ----------------->>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc %msysloc%\usr\bin\bash --login -c "/usr/bin/pacman -Q">>%devroot%\mesa-dist-win\buildinfo\mingw.txt

@rem Dump Visual Studio environment
@IF %toolchain%==msvc echo %msvcname% v%msvcver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc call %vsenv% %vsabi%>nul 2>&1
@IF %toolchain%==msvc echo Windows SDK %WindowsSDKVersion:~0,-1%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump Python environment
@IF %toolchain%==msvc echo Python %pythonver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo Python packages>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo --------------->>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc FOR /F "USEBACKQ skip=2 tokens=*" %%a IN (`%pythonloc% -W ignore -m pip list --disable-pip-version-check`) do @echo %%a>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get CMake version
@IF %toolchain%==msvc IF "%cmakestate%"=="1" set PATH=%devroot%\cmake\bin\;%PATH%
@IF %toolchain%==msvc IF NOT "%cmakestate%"=="0" IF NOT "%cmakestate%"=="" set exitloop=1&for /f "tokens=3 USEBACKQ" %%a IN (`cmake --version`) do @if defined exitloop set "exitloop="&echo CMake %%a>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get Ninja version
@IF %toolchain%==msvc IF "%ninjastate%"=="1" set PATH=%devroot%\ninja\;%PATH%
@IF %toolchain%==msvc IF NOT "%ninjastate%"=="0" IF NOT "%ninjastate%"=="" for /f "USEBACKQ" %%a IN (`ninja --version`) do @echo Ninja %%a>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get LLVM version
@IF %toolchain%==msvc IF EXIST %devroot%\llvm\%abi%\bin\llvm-config.exe FOR /F "USEBACKQ" %%a IN (`%devroot%\llvm\%abi%\bin\llvm-config.exe --version`) do @set llvmver=%%a
@IF %toolchain%==msvc IF EXIST %devroot%\llvm\%abi%\bin\llvm-config.exe echo LLVM %llvmver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get flex and bison version
@IF %toolchain%==msvc IF "%flexstate%"=="1" set PATH=%devroot%\flexbison\;%PATH%
@IF %toolchain%==msvc IF NOT "%flexstate%"=="0" IF NOT "%flexstate%"=="" set exitloop=1&for /f "tokens=* USEBACKQ" %%a IN (`where changelog.md`) do @for /f "tokens=3 skip=6 USEBACKQ" %%b IN (`type %%a`) do @if defined exitloop set "exitloop="&echo Winflexbison package %%b>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc IF NOT "%flexstate%"=="0" IF NOT "%flexstate%"=="" for /f "tokens=2 USEBACKQ" %%a IN (`win_flex --version`) do @echo flex %%a>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc IF NOT "%flexstate%"=="0" IF NOT "%flexstate%"=="" set exitloop=1&for /f "tokens=4 USEBACKQ" %%a IN (`win_bison --version`) do @if defined exitloop set "exitloop="&echo Bison %%a>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Get pkgconf/pkg-config version
@set pkgconfigver=null
@IF %toolchain%==msvc IF %mesabldsys%==meson IF %pkgconfigstate% GTR 0 FOR /F "USEBACKQ" %%a IN (`%pkgconfigloc%\pkg-config.exe --version`) do @set pkgconfigver=%%a
@IF NOT "%pkgconfigver%"=="null" IF %pkgconfigver:~0,1%==0 set pkgconfigver=pkg-config %pkgconfigver%
@IF NOT "%pkgconfigver%"=="null" IF NOT %pkgconfigver:~0,1%==0 set pkgconfigver=pkgconf %pkgconfigver%
@IF NOT "%pkgconfigver%"=="null" echo %pkgconfigver%>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Build comands
@IF %toolchain%==gcc echo.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo Build commands>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo -------------->>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==msvc echo.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo Build commands>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo -------------->>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@IF %toolchain%==gcc echo [2] scons build=release platform=windows machine=x86 toolchain=mingw libgl-gdi osmesa graw-gdi>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo [3] scons build=release platform=windows machine=x86_64 toolchain=mingw libgl-gdi osmesa graw-gdi>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo Notes>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo ----->>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo [0] Apply mesa-dist-win\patches\msys2-mingw_w64-fixes.patch before building Mesa.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo [1] Apply mesa-dist-win\patches\s3tc.patch to enable S3TC texture cache.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo [2] Navigate to Mesa3D source code in a MSYS2 MINGW32 shell and execute this command.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo [3] Navigate to Mesa3D source code in a MSYS2 MINGW64 shell and execute this command.>>%devroot%\mesa-dist-win\buildinfo\mingw.txt

@IF %toolchain%==msvc echo [1] md buildsys-x86^&cd buildsys-x86^&cmake -G "Ninja" -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_RTTI=1 -DLLVM_ENABLE_TERMINFO=OFF -DCMAKE_INSTALL_PREFIX=../x86 ..>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [2] md buildsys-x64^&cd buildsys-x64^&cmake -G "Ninja" -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_RTTI=1 -DLLVM_ENABLE_TERMINFO=OFF -DCMAKE_INSTALL_PREFIX=../x64 ..>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [3] ninja install>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [4] scons build=release platform=windows machine=x86 openmp=1 libgl-gdi osmesa graw-gdi>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [4] scons build=release platform=windows machine=x86_64 swr=1 openmp=1 libgl-gdi osmesa graw-gdi>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo Notes>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo ----->>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [0] Apply mesa-dist-win\patches\s3tc.patch to enable S3TC texture cache.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [1] Natigate to LLVM source code in a Visual Studio x64_x86 Cross Tools Command Prompt and execute this command.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [2] Natigate to LLVM source code in a Visual Studio x64 Native Tools Command Prompt and execute this command.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [3] Execute this command after [1] and [2] respectively on same Visual Studio command line console.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo [4] Navigate to Mesa3D source code in a standard Windows Command Prompt and execute any or both these commands.>>%devroot%\mesa-dist-win\buildinfo\msvc.txt

@rem Finished environment information dump.
@echo Done.
@IF %toolchain%==gcc echo Environment information has been written to %devroot%\mesa-dist-win\buildinfo\mingw.txt.
@IF %toolchain%==msvc echo Environment information has been written to %devroot%\mesa-dist-win\buildinfo\msvc.txt.
@echo.

:skipenvdump
@endlocal