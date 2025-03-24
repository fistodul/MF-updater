# MF-updater

Mobile Forces updater written in Bash with wrapper versions in Batch and PowerShell for Windows that use the MSYS2 Bash package

It is assumed that files can be downloaded from https://mf.nofisto.com/fast_download. You can paste the link into the address bar of your web browser and try to open the page. If the page doesn't open up (the server is down/doesn't exist) then you shouldn't launch the updater or you should edit the script so that you can download the files from elsewhere

As of 2024-05-03 msys2-runtime was updated to Cygwin 3.5 which dropped support for Windows 7, due to backwards compatiblity reasons we have sticked to msys2-runtime-3.4, more info here: https://www.msys2.org/docs/windows_support/

## Setup instructions

Before updating, keep in mind to backup the game in case you will want to revert back since the script will overwrite any mismatching file

First download this repo and extract it inside the main Mobile Forces game folder in which System, Texture, Maps and other such folders reside

```
wget https://github.com/fistodul/MF-updater/archive/refs/heads/main.zip
unzip main.zip
```

The folder should come with a .dll, .exe and other files in it

To begin the update process, launch the script for your OS (table below). You may wait until script finishes or you may close the window if you wish to no longer continue the execution. If you choose to cancel the execution, a file called "sha512.txt" should remain in the updater folder. You may delete or keep it, script will overwrite it on the next updare procedure

| OS          | Script      | Note
| ----------- | ----------- | ------------------------------------------- |
| Linux / Mac | updater.sh  | Just have Bash installed                    |
| Windows 10  | updater.ps1 | Maybe needs to have running scripts enabled |
| Windows 7   | updater.bat | Maybe needs an exclusion in your antivirus  |

If you use the script to download modded game files (the ones from Update.zip) of the System folder then sha512.txt has to be set up on the server so that some of the files are downloaded before the others, otherwise there might be problems with UCC decompress command. As of 2024-06-30, the priority is this: EffectsFix.u, Rage.u, Engine.u, RageWeapons.u and the rest of the files. Not sure if there is a way to decompress a compressed version of Engine.u by using game's own UCC, instead script just downloads an uncompressed version of Engine.u. Also, it downloads other files uncompressed for which we noted problems with their decompression as well

## Back story

This Script was first made by Gregaras and then improved by Filip

> Looking for info at forums like StackOverflow and similar helped me write the first version of the script (was longer, had 21 loops). Also, one documentation I think helped me: https://en.wikibooks.org/wiki/Windows_Batch_Scripting

The script had a lot to improve and still does, it originally used files from Git for Windows v2.43.0 - v2.46.2 and now an updater with a GUI somehow could be made maybe

We thought that it could be rewritten in something like PowerShell but went with Bash since we were Linux users and most experienced in it

> I tried to make most of the code POSIX and follow best practices from https://mywiki.wooledge.org/BashFAQ and not include features of Bash 4+ to be compatible with Apple's Bash 3.2.57 version

## Thanks to

msys2-runtime-3.4 and bash packages which were obtained from here:

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
