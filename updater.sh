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

# function arguments: $1 is the url and $2 the file to download
wget_cmd () {
  # executes the injected command or defaults to curl with -o
  eval "${WGET_CMD:-curl -sf "$1/$2" -o $2}" > /dev/null
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

setInfo() {
  file=${1##*/}
  ext=${file##*.}
  echo $file $ext
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

checkHashes() {
  localHash=($(sha_cmd $3))

  if [ "$localHash" = "$2" ]; then
    echo "$1 is up to date"
    return 0
  elif [ -z "$localHash" ]; then
    echo "$1 is missing"
  else
    echo "$1 is mismatching"
  fi

  return 1
}

getFile() {
  if [[ $3 -eq 1 || "$1" == @(EffectsFix.u|Rage.u|Engine.u|RageWeapons.u) ]]; then
    echo "Downloading $1 from the server"
    wget_cmd $url $1
    mv_cmd $1 $2
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
  file=($(setInfo $filePath))

  if [[ "${skipFiles[@]}" == *"$file"* ]]; then
    echo "Skipping $file"
    continue
  fi

  checkHashes $file $hash $filePath
  if [ $? -eq 0 ]; then
    continue
  fi

  isTextFile ${file[1]}
  getFile $file $filePath $?
done < sha512.txt

echo Update finished
sleep_cmd 1
