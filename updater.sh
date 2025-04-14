#!/bin/bash

url='https://mf.nofisto.com/fast_download'

skipFiles=(
  #'Announcer.uax'
  #'RagePlayerVoice.uax'
  'Core.int'
  'D3DDrv.int'
  'Editor.int'
  'Engine.int'
  'Galaxy.int'
  'IpDrv.int'
  'IpServer.int'
  'License.int'
  'Manifest.int'
  'MobileForcesEd.int'
  'MobileForces.int'
  'RageBrowser.int'
  'RageGame.int'
  'RageGfx.int'
  'Rage.int'
  'RageMenu.int'
  'RageWeapons.int'
  'Setup.int'
  'Startup.int'
  'UBrowser.int'
  'Window.int'
  'WinDrv.int'
  #'rage_warehouse.utx'
  'MobileForceFonts.utx'
)

# function arguments: $1 is the file to check the sum of
sha_cmd () {
  # executes the injected command or defaults to sha512sum
  eval "${SHA_CMD:-sha512sum $1}" 2> /dev/null
}

# function arguments: $1 is the url, $2 the file to download and $3 is where
wget_cmd () {
  target=${3:-$2}
  # executes the injected command or defaults to curl with -o
  eval "${WGET_CMD:-curl -sf $1/$2 -o $target}" > /dev/null
}

# function arguments: $* is the program to start with arguments
wine_cmd () {
  # executes the injected command or defaults to wine
  eval "${WINE_CMD:-wine $*}" 2> /dev/null
}

# function arguments: $1 is what to move and $2 is where
mv_cmd () {
  # executes the injected command or defaults to mv
  eval "${MV_CMD:-mv $1 $2}" &> /dev/null
}

# function arguments: $1 is file to delete
rm_cmd () {
  # executes the injected command or defaults to rm
  eval "${RM_CMD:-rm $1}"
}

# function arguments: $1 is the amount of seconds to sleep
sleep_cmd () {
  # executes the injected command or defaults to sleep
  eval "${SLEEP_CMD:-sleep $1}" > /dev/null
}

checkIfFilesExist() {
  mv_cmd ../maps ../Maps

  for folder in Maps Music Physics Sounds System Textures; do
    if ! [ -d "../$folder" ]; then
      echo "Couldn't find $folder in parallel folders, can't continue"
      sleep_cmd 2
      exit 1
    fi
  done

  if ! [ -f '../System/UCC.exe' ]; then
    echo "Couldn't find UCC.exe in System folder, can't continue"
    sleep_cmd 2
    exit 1
  fi

  if [[ "$PWD" == *' '* ]]; then
    echo "The directory path must not contain spaces, can't continue"
    sleep_cmd 2
    exit 1
  fi
}

downloadShasums() {
  echo Trying to download sha512.txt
  wget_cmd $url sha512.txt

  if [ $? -ne 0 ]; then
    echo Failed to download sha512.txt
    sleep_cmd 2
    exit 1
  fi

   echo sha512.txt successfully downloaded
}

isTextFile() {
  case $1 in
    umf | umx | uax | u | utx)
      return 0;;
    COL | hnd2 | int)
      return 1;;
    *)
      echo "Unknown extension $1"
      return 2;;
  esac
}

fixCase() {
  name="${1,,}/${2,,}"

  for f in $1/*; do
    if [ "${f,,}" = "$name" ]; then
      mv_cmd $f $1/$2
      return 0
    fi
  done

  echo "$2 is missing"
  return 1
}

checkHashes() {
  localHash=($(sha_cmd $3))

  if [ "$localHash" = "$2" ]; then
    echo "$1 is up to date"
    return 0
  else
    echo "$1 is mismatching"
    return 1
  fi
}

getFile() {
  if [[ $3 -eq 1 || "$1" == @(EffectsFix.u|Rage.u|Engine.u|RageWeapons.u) ]]; then
    echo "Downloading $1 from the server"
    wget_cmd $url $1 $2
  elif [ $3 -eq 0 ]; then
    echo "Downloading $1.uz from the server"
    wget_cmd $url "$1.uz"
    echo "Decompressing $1.uz"

    wine_cmd ../System/UCC.exe decompress "$PWD/$1.uz"
    mv_cmd "../System/$1" $2
    rm_cmd "$1.uz"
  fi
}

checkIfFilesExist
downloadShasums

while read hash filePath; do
  file=${filePath##*/}

  if [[ "${skipFiles[@]}" == *"$file"* ]]; then
    echo "Skipping $file"
    continue
  fi

  if fixCase ${filePath%/*} $file && checkHashes $file $hash $filePath; then
    continue
  fi

  isTextFile ${file##*.}
  getFile $file $filePath $?
done < sha512.txt

echo Update finished
sleep_cmd 1
