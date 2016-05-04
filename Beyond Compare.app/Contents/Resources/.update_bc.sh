#!/bin/bash
# $1 = Path to mounted dmg root
# $2 = Path to running app (including app name)

bash_file=$(basename $BASH_SOURCE)

dest_path=$2
dest_dir=$(dirname "$dest_path")
app_name=$(basename "$dest_path")
src_dir=$1

# Stop current app
foundit=$(ps -A | grep "$dest_path" | grep -v grep | wc -l)
if [ $foundit -gt 0 ]; then
  osascript -e "tell application \"$dest_path\" to quit"
  for count in 1 2 3 4 5 6 7 8 9 10; do
    sleep 3
    foundit=$(ps -A | grep "$dest_path" | grep -v grep | grep -v $bash_file | wc -l)
    if [ $foundit -eq 0 ]; then
      break
    else
      osascript -e "tell application \"$dest_path\" to quit"
    fi
  done
  if [ $count -eq 10 ]; then
    exit -1
  fi
fi

# cd to Source location and copy updated bundle to destination
cd "$src_dir"
cp -R "$app_name" "$dest_dir"

# call lsregister to notify OSX to re-examine bundle
lsrtail="Frameworks/LaunchServices.framework/Support/lsregister"
lsregister="/System/Library/Frameworks/CoreServices.framework/$lsrtail"
if [ ! -x "$lsregister" ]; then
  lsregister="/System/Library/Frameworks/ApplicationServices.framework/$lsrtail"
fi
$lsregister "$dest_path"

# relaunch
/usr/bin/open "$dest_path"

# force dmg to eject
if [[ "$src_dir" = /Volumes/* ]]; then
	/usr/bin/hdiutil detach "$src_dir" -force
else
	/bin/rm -rf "$src_dir"
fi