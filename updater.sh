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

# function arguments: $1 is what to move and $2 is where
mv_cmd () {
  # executes the injected command or defaults to mv
  eval "${MV_CMD:-mv $1 $2}" &> /dev/null
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
      printf "Didn't find %s in parallel folders, can't continue\n" $folder
      sleep_cmd 2
      exit 1
    fi
  done
}

downloadShasums() {
  printf "Trying to download sha512.txt\n"
  wget_cmd $url sha512.txt

  if [ $? -ne 0 ]; then
    printf "Failed to download sha512.txt\n"
    sleep_cmd 2
    exit 1
  fi

  printf "sha512.txt successfully downloaded\n"
}

fixCase() {
  name="${1,,}/${2,,}"

  for f in $1/*; do
    if [ "${f,,}" = "$name" ]; then
      mv_cmd $f $1/$2
      return 0
    fi
  done

  printf "%s is missing\n" "$2"
  return 1
}

checkHashes() {
  localHash=($(sha_cmd $3))

  if [ "$localHash" = "$2" ]; then
    printf "%s is up to date\n" "$1"
    return 0
  else
    printf "%s is mismatching\n" "$1"
    return 1
  fi
}

getFile() {
  printf "Downloading %s from the server\n" "$1"
  wget_cmd $url $1 $2
}

checkIfFilesExist
downloadShasums

while read hash filePath; do
  file=${filePath##*/}

  if [[ " ${skipFiles[*]} " == *" $file "* ]]; then
    printf "Skipping %s\n" "$file"
    continue
  fi

  if fixCase ${filePath%/*} $file && checkHashes $file $hash $filePath; then
    continue
  fi

  getFile $file $filePath
done < sha512.txt

printf "Update finished\n"
sleep_cmd 1
