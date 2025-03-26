# MF-updater

Mobile Forces updater written in Bash with wrapper versions in Batch and PowerShell for Windows that use the MSYS2 Bash package.

It is assumed that files can be downloaded from https://mf.nofisto.com/fast_download. You can paste the link into the address bar of your web browser and try to open the page. If the page doesn't open up (the server is down/doesn't exist) then you shouldn't launch the updater or you should edit the script so that you can download the files from elsewhere.

## Setup instructions

First download this [archive file](https://github.com/fistodul/MF-updater/archive/refs/heads/main.zip) and extract it inside the main Mobile Forces game folder in which System, Texture, Maps and other such folders reside.

Before updating, keep in mind to backup the game in case you will want to revert back since the script will overwrite any mismatching file.

To begin the update process, launch the script for your OS:
| OS         | Script      | Note
| ---------- | ----------- | ------------------------------------------ |
| Linux      | updater.sh  | Just have Bash installed                   |
| Windows 10 | updater.ps1 | Maybe needs to enable running scripts      |
| Windows 7  | updater.bat | Maybe needs an exclusion in your antivirus |
| Mac        | updater.sh  | Run as `SHA_CMD='shasum -a 512 $1' bash updater.sh` or install sha512sum |

## Instructions for server hosts

A text file with a list of sha512 hashes and paths has to be made. Example of sha512.txt file:

```
b72da50395d4d57e87324127118112e81f43d5e2e50b9cc09ec565b30397bf651e9aa34c077311bb6cc0b5d68668291cebe2844b4342da020334189a6381a02c  ../Maps/mf-dockyard.umf
d1065deb87d3dc0adc54609cf88dbeb5cef5b4aead0bcce676711d46f16c5e8efad8155f7bb60917b09daa74aececd7bf561229f2ca86823f67866bab91676f8  ../Maps/mf-Rail_Quarry.umf
1d11c84b41cf7e21cd4fb7ae14286ab0399fe3365f79f4df3f5827b1187ddb064d800866b67c94511075c7cccae2b6509abb5585f60acfa6866ceed45f29da01  ../Maps/mf-sawmill.umf
6d38767b894fce28b1f59d2449467fe8065acd570accd379bd1c2d6fc83a2e05a7dea3cb5b6cdac0f5a69e3759b063f3abec553f48dabaf8fbc1d429a9127c73  ../Maps/mf-warehouse.umf
0324e4bdb205a9fd8a04e492c864d0ef5f963ba6c0ed723cb20694260d88c17627d9854542e6d40dda4a40fd5f6df57756a7e19775c4b34f34504f85a4efe709  ../Maps/mf-waterfront.umf
5b4488096c83b0cab8e688dd4ea42649765735310040683d07e65d6d31645bafc68ce63b9f8c0e502713a6469479bf01c5b6eb849f63a9db560a4038726e3a96  ../Maps/mf-western.umf
```

The file has to has to include all the game files that you want your clients to update.

If base files/game code packages (Rage.u, RageWeapons.u, Engine.u, etc.) are **not** being downloaded then the list can be freely sorted, although it is recommended to sort them by modified date so that whenever new files are put to the server, clients can download them at the beginning stage of the script. 

If base files/game code packages **are** being downloaded then the list has to be different. For example, in case of downloading [modded game files](https://mf.nofisto.com/download/Update.zip), the list has to be in this order:
```
EffectsFix.u
Rage.u
Engine.u
RageWeapons.u
Other files
```
Otherwise, UCC decompress command might act up and the updater script might not work as intended. Although, the ultimate solution might be not to attempt to decompress any of the game code packages and instead download the uncompressed versions of them. Maybe such feature will soon be implemented.

## Back story

This Script was first made by Gregaras and then improved by Filip.

> Looking for info at forums like StackOverflow and similar helped me write the first version of the script (was longer, had 21 loops). Also, one documentation I think helped me: https://en.wikibooks.org/wiki/Windows_Batch_Scripting

The script had a lot to improve and still does, it originally used files from Git for Windows v2.43.0 - v2.46.2.

We thought that it could be rewritten in PowerShell but went with Bash since we were Linux users and most experienced in it.

> I tried to make most of the code POSIX and follow best practices from https://mywiki.wooledge.org/BashFAQ and not include features of Bash 4+ to be compatible with Apple's Bash 3.2.57 version

As of 2024-05-03 msys2-runtime was updated to Cygwin 3.5 which dropped support for Windows 7, due to backwards compatiblity reasons we have sticked to msys2-runtime-3.4, more info here: https://www.msys2.org/docs/windows_support/

## Binaries used in the repository

Binaries were taken from msys2-runtime-3.4 and bash packages which were obtained from here:

https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.4-3.4.10-3-x86_64.pkg.tar.zst

https://mirror.msys2.org/msys/x86_64/bash-5.2.037-2-x86_64.pkg.tar.zst

The pages that included the links:

https://packages.msys2.org/packages/bash?variant=x86_64

https://packages.msys2.org/packages/msys2-runtime-3.4?variant=x86_64

List of the files:

```
usr/bin/msys-2.0.dll
usr/bin/bash.exe
```
