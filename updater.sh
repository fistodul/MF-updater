#!/bin/sh

# function arguments: $1 is the file to check the sum of
sha_cmd () {
  # executes the injected command or defaults to shasum
  eval "${SHA_CMD:-shasum -a 512 -c -s $1}"
}

# function arguments: $1 is the url and $2 the file to download
wget_cmd () {
  # executes the injected command or defaults to curl with -o
  eval "${WGET_CMD:-curl -sf \'$1/$2\' -o $2}"
}

# function arguments: $1 is the url to get the content of
curl_cmd () {
  # executes the injected command or defaults to curl
  eval "${CURL_CMD:-curl -sf $1}"
}

# function arguments: $1 is the pattern to find in stdin
grep_cmd () {
  # executes the injected command or defaults to grep
  eval "${GREP_CMD:-grep -oP '$1'}" < /dev/stdin
}

url='https://mf.nofisto.com/fast_download'

# Get the shasums.txt file, or recreate it
wget_cmd $url shasumss.txt ||
curl_cmd "${url}/?C=M;O=D" | grep_cmd '(?<=href=").+?\.sha256' |
  while read -r sha_file; do
    curl_cmd "${url}/${sha_file}"
  done > shasums.txt

if ! [ -f shasums.txt ]; then
  echo Failed to retrieve shasums.txt or recreate it
  exit 1
fi

# Check files
while read -r sha_file; do
  echo $sha_file
done < shasums.txt

checkIfFilesExist()
{
  for folder in System Maps Textures Physics Sounds Music;
  do
    if [[ ! -d "../$folder" ]]; then
      echo "Couldn't find $folder in parallel folders, can't continue";
      read -n 1;
      exit;
    fi
  done;

  if [[ ! -a "../System/UCC.exe" ]]; then
    echo "Couldn't find UCC.exe in System folder, can't continue";
    read -n 1;
    exit;
  fi
}

downloadShasums()
{
  echo "Trying to download shasums.txt";
  wget -q "https://mf.nofisto.com/fast_download/shasums.txt" -O "shasums.txt";
  if (( $? == 0 )); then
    echo "shasums.txt successfully downloaded";
  else
    echo "Failed to download shasums.txt";
    read -n 1;
    exit;
  fi
}

setInfo()
{
  if [[ -z $remoteHash ]]; then
    remoteHash=$word;
    return 1;
  elif [[ -z $filename ]]; then
    filename=$(echo $word | sed 's/.*\///');
    ext=$(echo $filename | sed 's/.*\.//');
  fi
}

clearInfo()
{
  unset remoteHash;
  unset filename;
}

recognizeExtension()
{
  case $ext in
    u)
      folder='System';
      textFile=0;;
    umf)
      folder='Maps';
      textFile=0;;
    int)
      folder='System';
      textFile=1;;
    utx | usx)
      folder='Textures';
      textFile=0;;
    uax)
      folder='Sounds';
      textFile=0;;
    umx)
      folder='Music';
      textFile=0;;
    COL | hnd2)
      folder='Physics';
      textFile=1;;
    *)
      echo Unknown extension. Aborting script.;
      exit;;
  esac;
}

setLocalHash()
{
  if [[ -a "../${folder}/${filename}" ]]; then
    localHash=$(sha256sum "../${folder}/${filename}" | sed 's/ .*//');
  elif [[ ! -z $localHash ]]; then
    unset localHash;
  fi
}

checkHashes()
{
  if [[ $localHash == $remoteHash ]]; then
    echo "$filename is up to date";
    clearInfo;
    return 0;
  elif [[ -z $localHash ]]; then
    echo "$filename is missing";
  else
    echo "$filename is mismatching";
    echo "Local file hash:  $localHash";
    echo "Remote file hash: $remoteHash";
  fi
  return 1;
}

getFile()
{
  if [[ $filename == 'Engine.u' || $filename == 'RageWeapons.u' ]]; then
    echo "$filename is assumed to be indecompressible";
    echo "Downloading $filename from the server";
    wget -q -c "https://mf.nofisto.com/fast_download/$filename" -O "$filename";
    mv "$filename" ../System;
  elif (( ! $textFile )); then
    echo "Downloading ${filename}.uz from the server";
    wget -q -c "https://mf.nofisto.com/fast_download/${filename}.uz" -O "${filename}.uz";
    echo "Decompressing ${filename}.uz";
    cd "../System";
    # ./UCC decompress "../Updater/${filename}.uz";
    wine UCC decompress "../Updater/${filename}.uz" 2> /dev/null;
    cd "../Updater";
    if [[ $folder != 'System' ]]; then
      mv "../System/$filename" "../$folder";
    fi
    rm ${filename}.uz;
  else
    echo "Downloading $filename from the server";
    wget -q -c "https://mf.nofisto.com/fast_download/$filename" -O "$filename";
    mv "$filename" "../$folder";
  fi
}

checkIfFilesExist;
downloadShasums;

for word in $(cat shasums.txt);
do
  setInfo;
  if (( $? == 1 )); then
    continue;
  fi
  recognizeExtension;
  setLocalHash;
  checkHashes;
  if (( $? == 0 )); then
    continue;
  fi
  getFile;
  clearInfo;
done;

echo 'Update finished';
read -n 1;

exit;
