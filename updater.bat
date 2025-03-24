@echo off

rem This script comes with the msys2-runtime and bash

set "SHA_CMD={ read head; read hash; } < <(certutil -hashfile $1 SHA512) && echo $hash"
set WGET_CMD=certutil -urlcache -f "$1/$2" $2
set WINE_CMD=$*

set MV_CMD=cmd //c move $1 $2
set RM_CMD=cmd //c del $1
set SLEEP_CMD=timeout $1 //NOBREAK

mkdir tmp 2> NUL
for %%I in (.) do set dirName=%%~nxI
cd ..

%dirName%\usr\bin\bash.exe -c "cd %dirName%; ./updater.sh"
