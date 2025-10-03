#!/usr/bin/python3
"""Updater script for Mobile Forces written in Python.

Below the imports the url to connect to is set alongside the skipFiles array
there's a few commented files that you may want to enable by removing "# "
"""

from hashlib import sha512
from os import listdir, path, rename
from time import sleep
from urllib.request import urlopen

url = 'https://mf.nofisto.com/fast_download'

skip_files = [
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


def check_files_exist() -> None:
    src = '../maps'
    dst = '../Maps'

    if path.isdir(src) and not path.isdir(dst):
        rename(src, dst)

    for folder in ['Maps', 'Music', 'Physics', 'Sounds', 'System', 'Textures']:
        src = f'../{folder}'
        if not path.isdir(src):
            print(f"Didn't find {folder} in parallel folders, can't continue")
            sleep(2)
            raise SystemExit(1)


def download_shasums() -> list:
    print('Trying to download sha512.txt')

    try:
        res = urlopen(f'{url}/sha512.txt')
    except Exception:
        print('Failed to download sha512.txt')
        sleep(2)
        raise SystemExit(1)

    print('sha512.txt successfully downloaded')
    return res.read().decode().splitlines()


def fix_case(folder: str, file: str) -> bool:
    name = file.lower()

    for f in listdir(folder):
        if f.lower() == name:
            if f != file:
                rename(f'{folder}/{f}', f'{folder}/{file}')
            return True

    print(f'{file} is missing')
    return False


def check_hashes(file: str, hashed: str, file_path: str) -> bool:
    with open(file_path, 'rb') as f:
        if sha512(f.read()).hexdigest() == hashed:
            print(f'{file} is up to date')
            return True
        else:
            print(f'{file} is mismatching')
            return False


def get_file(file: str, file_path: str) -> None:
    print(f'Downloading {file} from the server')
    res = urlopen(f'{url}/{file}')

    with open(file_path, 'wb') as f:
        f.write(res.read())


check_files_exist()
for line in download_shasums():
    hashed, file_path = line.split(maxsplit=1)
    file = path.basename(file_path)
    folder = path.dirname(file_path)

    if file in skip_files:
        print(f'Skipping {file}')
        continue

    if fix_case(folder, file) and check_hashes(file, hashed, file_path):
        continue

    get_file(file, file_path)

print('Update finished')
sleep(1)
