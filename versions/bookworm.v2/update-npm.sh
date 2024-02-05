#!/usr/bin/env sh

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

if [ $(whoami) != 'node' ]; then
  echo "ERROR: must run awsmgr-start as 'node' user. Currently running as: $(whoami)"
  exit 1
fi

LATEST_TGZ_APP=$(ls -lhtp /tmp/npms/*.tgz | head -n1 | awk '{print $9}')

if [ ! -f $LATEST_TGZ_APP ]; then
   echo "No npm package to install in /tmp!"
   exit 1
else
  export PATH=$HOME/node_modules/.bin:$PATH
  echo "Installing $LATEST_TGZ_APP"
  npm uninstall awsmgr
  npm install $LATEST_TGZ_APP
  exit 0
fi
