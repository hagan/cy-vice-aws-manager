#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PATH=$HOME/node_modules/.bin:$PATH
NODE_GLOBAL_MODULE_DIR=$(npm -g root)

echo "NPM_CONFIG_PREFIX: ${NPM_CONFIG_PREFIX}"
echo "npm -g root: ${NODE_GLOBAL_MODULE_DIR}"

if [ -z $NODE_GLOBAL_MODULE_DIR ]; then
  echo "ERROR: NODE_GLOBAL_MODULE_DIR is unset!"
  exit 1
elif [ ! -d $NODE_GLOBAL_MODULE_DIR ]; then
  echo "Creating directory $NODE_GLOBAL_MODULE_DIR"
  mkdir -p $NODE_GLOBAL_MODULE_DIR
else
  echo "$NODE_GLOBAL_MODULE_DIR already exists"
fi

if [ $(whoami) != 'node' ]; then
  echo "ERROR: must run awsmgr-start as 'node' user. Currently running as: $(whoami)"
  exit 1
fi

if [ ! -d "$HOME/.npm" ]; then
  echo "ERROR: During build, '$HOME/.npm' is missing!"
  echo "In the Dockerfile: RUN --mount=type=cache,target=/home/node/.npm <COMMAND HERE> may be needed."
  exit 1
fi

LATEST_TGZ_APP=$(ls -lhtp /tmp/npms/*.tgz | head -n1 | awk '{print $9}')
if [ ! -f $LATEST_TGZ_APP ]; then
   echo "No npm package to install in /tmp!"
   exit 1
fi

echo "Installing $LATEST_TGZ_APP"
npm install -g $LATEST_TGZ_APP
AWSMGR_DIR=$(npm -g list awsmgr --parseable)

if [ -z "${AWSMGR_DIR}" ] || [ ! -d "${AWSMGR_DIR}" ]; then
  echo "ERROR: awsmgr did not successfully install."
  exit 1
fi

pushd ${AWSMGR_DIR}
## how can we speed this up?
# npm ci
if [ "${SKIP_YARN_INSTALL:-0}" -ne 1 ]; then
  SKIP_PREPARE=1 yarn install --frozen-lockfile
fi
popd
