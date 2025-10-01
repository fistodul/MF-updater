#!/usr/bin/python3
"""Updater script for Mobile Forces written in Python.

Below the imports the url to connect to is set alongside the skipFiles array
there's a few commented files that you may want to enable by removing "# "
"""

import os
from hashlib import sha512
from time import sleep
from urllib.request import urlopen

url = 'https://mf.nofisto.com/fast_download'

skipFiles = [
    # 'Announcer.uax',
    # 'RagePlayerVoice.uax',
    'Core.int',
    'D3DDrv.int',
    'Editor.int',
    'Engine.int',
    'Galaxy.int',
    'IpDrv.int',
    'IpServer.int',
    'License.int',
    'Manifest.int',
    'MobileForcesEd.int',
    'MobileForces.int',
    'RageBrowser.int',
    'RageGame.int',
    'RageGfx.int',
    'Rage.int',
    'RageMenu.int',
    'RageWeapons.int',
    'Setup.int',
    'Startup.int',
    'UBrowser.int',
    'Window.int',
    'WinDrv.int',
    # 'rage_warehouse.utx',
    'MobileForceFonts.utx',
]


def checkIfFilesExist() -> None:
    src = '../maps'
    dst = '../Maps'

    if os.path.isdir(src) and not os.path.isdir(dst):
        os.rename(src, dst)

    for folder in ['Maps', 'Music', 'Physics', 'Sounds', 'System', 'Textures']:
        src = f'../{folder}'
        if not os.path.isdir(src):
            print(f"Didn't find {folder} in parallel folders, can't continue")
            sleep(2)
            raise SystemExit()


def downloadShasums() -> None:
    print('Trying to download sha512.txt')

    try:
        res = urlopen(f'{url}/sha512.txt')
        with open('sha512.txt', 'wb') as f:
            f.write(res.read())
    except Exception:
        print('Failed to download sha512.txt')
        sleep(2)
        raise SystemExit()

    print('sha512.txt successfully downloaded')


def fixCase(folder: str, file: str) -> bool:
    name = file.lower()

    for f in os.listdir(folder):
        if f.lower() == name:
            if f != file:
                os.rename(f'{folder}/{f}', f'{folder}/{file}')
            return True

    print(f'{file} is missing')
    return False


def checkHashes(file: str, hashed: str, filePath: str) -> bool:
    with open(filePath, 'rb') as f:
        if sha512(f.read()).hexdigest() == hashed:
            print(f'{file} is up to date')
            return True
        else:
            print(f'{file} is mismatching')
            return False


def getFile(file: str, filePath: str) -> None:
    print(f'Downloading {file} from the server')
    res = urlopen(f'{url}/sha512.txt')

    with open(filePath, 'wb') as f:
        f.write(res.read())


checkIfFilesExist()
downloadShasums()

with open('sha512.txt') as f:
    for line in f:
        line = line.rstrip('\n')
        hashed, filePath = line.split(maxsplit=1)

        file = os.path.basename(filePath)
        folder = os.path.dirname(filePath)

        if file in skipFiles:
            print(f'Skipping {file}')
            continue

        if fixCase(folder, file) and checkHashes(file, hashed, filePath):
            continue

        getFile(file, filePath)

print('Update finished')
sleep(1)
