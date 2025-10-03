#!/bin/bash

url='https://mf.nofisto.com/fast_download'

skip_files=(
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
  eval "${SHA_CMD:-sha512sum "$1"}" 2> /dev/null
}

check_files_exist() {
  mv ../maps ../Maps 2> /dev/null

  for folder in Maps Music Physics Sounds System Textures; do
    if ! [ -d "../$folder" ]; then
      printf "Didn't find %s in parallel folders, can't continue\n" "$folder"
      sleep 2
      exit 1
    fi
  done
}

download_shasums() {
  printf "Trying to download sha512.txt\n"

  if ! curl -sf "$url/sha512.txt" -o sha512.txt; then
    printf "Failed to download sha512.txt\n"
    sleep 2
    exit 1
  fi

  printf "sha512.txt successfully downloaded\n"
}

fix_case() {
  name="${1,,}/${2,,}"

  for f in "$1"/*; do
    if [ "${f,,}" = "$name" ]; then
      if [ "$f" != "$1/$2" ]; then
        mv "$f" "$1/$2"
      fi
      return 0
    fi
  done

  printf "%s is missing\n" "$2"
  return 1
}

check_hashes() {
  local_hash=$(sha_cmd "$3")

  if [ "${local_hash%% *}" = "$2" ]; then
    printf "%s is up to date\n" "$1"
    return 0
  else
    printf "%s is mismatching\n" "$1"
    return 1
  fi
}

get_file() {
  printf "Downloading %s from the server\n" "$1"
  curl -sf "$url/$1" -o "$2"
}

check_files_exist
download_shasums

while read -r hash file_path; do
  file="${file_path##*/}"

  if [[ " ${skip_files[*]} " == *" $file "* ]]; then
    printf "Skipping %s\n" "$file"
    continue
  fi

  if fix_case "${file_path%/*}" "$file" && check_hashes "$file" "$hash" "$file_path"; then
    continue
  fi

  get_file "$file" "$file_path"
done < sha512.txt

printf "Update finished\n"
sleep 1
