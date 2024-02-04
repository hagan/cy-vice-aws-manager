#!/usr/bin/env sh

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

LATEST_TGZ_APP=$(ls -lhtp /tmp/npms/*.tgz | head -n1 | awk '{print $9}')

if [ ! -f $LATEST_TGZ_APP ]; then
   echo "No npm package to install in /tmp!"
   exit 1
else
  echo "Installing $LATEST_TGZ_APP"
  npm uninstall awsmgr
  npm install $LATEST_TGZ_APP
  exit 0
fi
