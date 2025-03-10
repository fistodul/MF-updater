@echo off

rem Git for Windows v2.46.2 which is the last version with Windows 7 support
rem https://github.com/git-for-windows/git/releases/tag/v2.46.2.windows.1

set SHA_CMD=certutil -hashfile $1 SHA512
set WGET_CMD=certutil -urlcache -f "$1/$2" $2

set CURL_CMD=powershell -Command "(Invoke-WebRequest -Uri $1/$2 | Out-Host)"
set GREP_CMD=powershell -Command {$input | ForEach-Object { [regex]::Matches($_, '(?<=href=")[^"]*\.sha256') | ForEach-Object { $_.Value } }}
set GREP_CMD=powershell -Command {$input | Select-String -Pattern '(?<=href=").*?\.sha256' -AllMatches | ForEach-Object { $_.Matches.Value }}

set WINE_CMD=start
sh.exe updater.sh
