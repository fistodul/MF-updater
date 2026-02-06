#!/bin/bash

url='https://raw.githubusercontent.com/fistodul/MF-updater/refs/heads/files'

skip_files=(
  #'rage_warehouse.utx'
)

# function arguments: $1 is the file to check the sum of
sha_cmd () {
  # executes the injected command or defaults to sha512sum
  eval "${SHA_CMD:-sha512sum '$1'}" 2> /dev/null
}

check_files_exist() {
  mv ../maps ../Maps 2> /dev/null

  for folder in Maps Music Physics Sounds System Textures; do
    if ! [ -d "../$folder" ]; then
      echo "Didn't find $folder in parallel folders, can't continue"
      sleep 5
      exit 1
    fi
  done
}

download_shasums() {
  echo 'Trying to download sha512.txt'

  if ! curl -sSf "$url/sha512.txt" -o sha512.txt; then
    echo 'Failed to download sha512.txt'
    sleep 5
    exit 1
  fi

  echo 'sha512.txt successfully downloaded'
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

  echo "$2 is missing"
  return 1
}

check_hash() {
  local_hash=$(sha_cmd "$3")

  if [ "${local_hash%% *}" = "$2" ]; then
    echo "$1 is up to date"
    return 0
  else
    echo "$1 is mismatching"
    return 1
  fi
}

get_file() {
  echo "Downloading $1 from the server"
  curl -sSf "$url/$1" -o "$2"
}

cd "$(dirname "$0")" || exit 1
check_files_exist
download_shasums

while read -r hashed file_path; do
  file="${file_path##*/}"

  if [[ " ${skip_files[*]} " == *" $file "* ]]; then
    echo "Skipping $file"
    continue
  fi

  if fix_case "${file_path%/*}" "$file" && check_hash "$file" "$hashed" "$file_path"; then
    continue
  fi

  get_file "$file" "$file_path"
done < sha512.txt

echo 'Update finished'
sleep 2
