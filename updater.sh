#!/bin/sh

url='https://mf.nofisto.com/fast_download'

skipFiles=(
  #'Sounds/Announcer.uax'
  #'Sounds/RagePlayerVoice.uax'
  'System/Core.int'
  'System/D3DDrv.int'
  'System/Editor.int'
  'System/Engine.int'
  'System/Engine.u'
  'System/Galaxy.int'
  'System/IpDrv.int'
  'System/IpServer.int'
  'System/License.int'
  'System/Manifest.int'
  'System/MobileForcesEd.int'
  'System/MobileForces.int'
  'System/RageBrowser.int'
  'System/RageGame.int'
  'System/RageGfx.int'
  'System/Rage.int'
  'System/RageMenu.int'
  'System/RageWeapons.int'
  'System/Setup.int'
  'System/Startup.int'
  'System/UBrowser.int'
  'System/Window.int'
  'System/WinDrv.int'
  #'Textures/rage_warehouse.utx'
)

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

checkIfFilesExist() {
  for folder in System Maps Textures Physics Sounds Music; do
    if ! [ -d "../$folder" ]; then
      echo "Couldn't find $folder in parallel folders, can't continue"
      read -n 1
      exit 1
    fi
  done

  if ! [ -f '../System/UCC.exe' ]; then
    echo Couldn't find UCC.exe in System folder, can't continue
    read -n 1
    exit 1
  fi
}

downloadShasums() {
  echo Trying to download sha512.txt

  wget_cmd $url sha512.txt ||
  curl_cmd "${url}/?C=M;O=D" | grep_cmd '(?<=href=").+?\.sha512' |
    while read -r sha_file; do
      curl_cmd "${url}/${sha_file}"
    done > sha512.txt

  if ! [ -f sha512.txt ]; then
    echo Failed to download sha512.txt or recreate it
    read -n 1
    exit 1
  fi
}

setInfo() {
  if [[ -z $remoteHash ]]; then
    remoteHash=$word
    return 1

  elif [[ -z $filename ]]; then
    filename=$(echo $word | sed 's/.*\///')
    ext=$(echo $filename | sed 's/.*\.//')
  fi
}

clearInfo() {
  unset remoteHash
  unset filename
}

recognizeExtension() {
  case $ext in
    u)
      folder='System'
      textFile=0;;
    umf)
      folder='Maps'
      textFile=0;;
    int)
      folder='System'
      textFile=1;;
    utx | usx)
      folder='Textures'
      textFile=0;;
    uax)
      folder='Sounds'
      textFile=0;;
    umx)
      folder='Music'
      textFile=0;;
    COL | hnd2)
      folder='Physics'
      textFile=1;;
    *)
      echo "Unknown extension $ext, skipping";;
  esac
}

setLocalHash() {
  if [[ -a "../${folder}/${filename}" ]]; then
    localHash=$(sha256sum "../${folder}/${filename}" | sed 's/ .*//')
  elif [[ ! -z $localHash ]]; then
    unset localHash
  fi
}

checkHashes() {
  if [[ $localHash == $remoteHash ]]; then
    echo "$filename is up to date"
    clearInfo
    return 0

  elif [[ -z $localHash ]]; then
    echo "$filename is missing"
  else
    echo "$filename is mismatching"
    echo "Local file hash:  $localHash"
    echo "Remote file hash: $remoteHash"
  fi
  return 1
}

getFile() {
  if [[ $filename == 'Engine.u' || $filename == 'RageWeapons.u' ]]; then
    echo "$filename is assumed to be indecompressible"
    echo "Downloading $filename from the server"
    wget -q -c "https://mf.nofisto.com/fast_download/$filename" -O "$filename"
    mv "$filename" ../System
  elif (( ! $textFile )); then
    echo "Downloading ${filename}.uz from the server"
    wget -q -c "https://mf.nofisto.com/fast_download/${filename}.uz" -O "${filename}.uz"
    echo "Decompressing ${filename}.uz"
    cd "../System"
    wine UCC decompress "../Updater/${filename}.uz" 2> /dev/null
    cd "../Updater"

    if [[ $folder != 'System' ]]; then
      mv "../System/$filename" "../$folder"
    fi

    rm ${filename}.uz;
  else
    echo "Downloading $filename from the server"
    wget -q -c "https://mf.nofisto.com/fast_download/$filename" -O "$filename"
    mv "$filename" "../$folder"
  fi
}

checkIfFilesExist
downloadShasums

while read word; do
  setInfo

  if (( $? == 1 )); then
    continue
  fi

  recognizeExtension
  setLocalHash
  checkHashes

  if (( $? == 0 )); then
    continue
  fi

  getFile
  clearInfo
done < sha512.txt

echo Update finished
read -n 1
