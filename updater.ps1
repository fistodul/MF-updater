# This script comes with the msys2-runtime and bash

$Env:SHA_CMD = 'powershell -Command "(Get-FileHash -Algorithm SHA512 $1).Hash.ToLower()"'
$Env:WGET_CMD = 'powershell -Command "Invoke-WebRequest "$1/$2" -OutFile $2"'
$Env:WINE_CMD = '$*'

$Env:MV_CMD = 'powershell -Command "Move-Item -Path $1 -Destination $2" -Force'
$Env:RM_CMD = 'powershell -Command "Remove-Item $1"'
$Env:SLEEP_CMD = 'powershell -Command "Start-Sleep -Seconds $1"'

New-Item -ItemType Directory -Path tmp -Force | Out-Null
$dirName = Split-Path -Leaf $pwd.Path
Set-Location ..

& $dirName\usr\bin\bash.exe -c "cd $dirName; ./updater.sh"
