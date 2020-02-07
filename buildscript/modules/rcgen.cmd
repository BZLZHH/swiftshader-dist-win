@setlocal
@rem Required parameters
@rem %1 - description
@rem %2 - filename
@rem %3 - arch
@rem %4 - version
@rem %5 - vendor

@set descriptionfield=%1
@IF NOT %3==null set descriptionfield=%descriptionfield:~0,-1% (%3)"
@set prodaver=%4

@(echo.
echo 1 VERSIONINFO
echo FILEVERSION %prodver:.=,%,0
echo PRODUCTVERSION %prodver:.=,%,0
echo FILEOS 0x40004
echo FILETYPE 0x0
echo {
echo BLOCK "StringFileInfo"
echo {
echo BLOCK "040904b0"
echo {
echo VALUE "CompanyName", %5
echo VALUE "FileDescription", %descriptionfield%
echo VALUE "FileVersion", "%prodver%.0"
echo VALUE "InternalName", "%~n2.dll"
echo VALUE "LegalCopyright", "Copyright (C) 2020"
echo VALUE "OriginalFilename", "%~n2.dll"
echo VALUE "ProductName", "Google SwiftShader"
echo VALUE "ProductVersion", "%prodver%.0"
echo }
echo }
echo BLOCK "VarFileInfo"
echo {
echo VALUE "Translation", 0x0409 0x04B0
echo }
echo })>%devroot%\vk-swiftshader-dist\buildscript\assets\temp.rc
@IF EXIST %2 ResourceHacker.exe -open %devroot%\vk-swiftshader-dist\buildscript\assets\temp.rc -save %devroot%\vk-swiftshader-dist\buildscript\assets\temp.res -action compile -log NUL
@IF EXIST %2 ResourceHacker.exe -open %2 -save %2 -action addoverwrite -resource %devroot%\vk-swiftshader-dist\buildscript\assets\temp.res -log NUL
@endlocal