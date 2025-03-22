@echo off

rem Git for Windows v2.46.2 which is the last version with Windows 7 support
rem https://github.com/git-for-windows/git/releases/tag/v2.46.2.windows.1

set SHA_CMD=certutil -hashfile $1 SHA512
set WGET_CMD=certutil -urlcache -f "$1/$2" $2
set WINE_CMD=start $*

bash.exe updater.sh
