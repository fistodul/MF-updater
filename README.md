Readme written by Gregaras

You should have received a folder with .dll, .exe and other files in it. The folder should be called 'Updater'. You should place the folder inside the main Mobile Forces game folder in which System, Texture, Maps and other such folders reside.

It is assumed that files can be downloaded from https://mf.nofisto.com/fast_download. You can paste the link into the address bar of your web browser and try to open the page. If the page doesn't open up (the server is down/doesn't exist) then you shouldn't launch the updater or you should edit the script so that you can download the files from elsewhere.

Before updating, keep in mind to backup the game in case you will want to revert back since the script will overwrite any mismatching file.

To begin the update process, launch script.bat. You may wait until script finishes or you may close the window If you wish to no longer continue the execution. If you choose to cancel the execution, a file called "shasums" should remain in the Updater folder. You may delete or keep it, script will overwrite it on the next updare procedure.

If you use the script to download modded game files (the ones from Update.zip) of the System folder then shasums.txt has to be set up on the server so that some of the files are downloaded before the others, otherwise there might be problems with UCC decompress command. As of 2024-06-30, the priority is this: EffectsFix.u, RageWeapons.u, Rage.u, Engine.u and the rest of the files. Not sure if there is a way to decompress a compressed version of Engine.u by using game's own UCC, instead script just downloads an uncompressed version of Engine.u. Also, there has been a problem with RageWeapons.u decompression once, so this file is downloaded uncompressed as well.


*****

Script made by Gregaras

Looking for info at forums like StackOverflow and similar helped me write the first version of the script (was longer, had 21 loops instead of 6). Also, one documentation I think helped me:

https://en.wikibooks.org/wiki/Windows_Batch_Scripting

The script still probably could be improved a lot, maybe It could be rewritten in something like PowerShell or maybe an updater with a GUI somehow could be made.

*****

There is software which was obtained from here:

https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/PortableGit-2.43.0-64-bit.7z.exe

The page that included the link:

https://git-scm.com/download/win

Link to the GitHub release page:

https://github.com/git-for-windows/git/releases/tag/v2.43.0.windows.1 

List of the files:

sha256sum.exe
sed.exe
msys-pcre-1.dll
msys-intl-8.dll
msys-iconv-2.dll
msys-2.0.dll
grep.exe

As of 2024-04-24 there is a version 2.44 that seems to have differing versions of aforementioned files. Although, I'm not sure If it is worth including them since msys-2.0.dll now takes up 19 megabytes instead of 3 and no internet access operations are done with these programs (they are not even able to do that I suppose, not the executables at least).


wget.exe was obtained from there:

https://eternallybored.org/misc/wget/1.21.4/32/wget.exe

These pages get you to the download link of wget.exe:

https://www.gnu.org/software/wget/
http://wget.addictivecode.org/FrequentlyAskedQuestions.html#download
https://eternallybored.org/misc/wget/
