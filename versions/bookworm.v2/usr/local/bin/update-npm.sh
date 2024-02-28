#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PATH=$HOME/node_modules/.bin:$PATH
# NODE_GLOBAL_MODULE_DIR=$(npm -g root)

echo "NPM_CONFIG_PREFIX: ${NPM_CONFIG_PREFIX}"
# echo "npm -g root: ${NODE_GLOBAL_MODULE_DIR}"

# if [ -z $NODE_GLOBAL_MODULE_DIR ]; then
#   echo "ERROR: NODE_GLOBAL_MODULE_DIR is unset!"
#   exit 1
# elif [ ! -d $NODE_GLOBAL_MODULE_DIR ]; then
#   echo "Creating directory $NODE_GLOBAL_MODULE_DIR"
#   mkdir -p $NODE_GLOBAL_MODULE_DIR
# else
#   echo "$NODE_GLOBAL_MODULE_DIR already exists"
# fi

if [ $(whoami) != 'node' ]; then
  echo "ERROR: must run awsmgr-start as 'node' user. Currently running as: $(whoami)"
  exit 1
fi

# if [ ! -d "$HOME/.npm" ]; then
#   echo "ERROR: During build, '$HOME/.npm' is missing!"
#   echo "In the Dockerfile: RUN --mount=type=cache,target=/home/node/.npm <COMMAND HERE> may be needed."
#   exit 1
# fi

## this tries mounted /mnt/dist/npms for development, falls back to /tmp/npms to install
LATEST_TGZ_APP=$(ls -lhtp /mnt/dist/npms/*.tgz 2>/dev/null | head -n1 | awk '{print $9}')
if [[ -z "${LATEST_TGZ_APP}" ]]; then
  # fallback to /tmp/npms
  echo "Did not find package in /mnt/dist/npms..."
  LATEST_TGZ_APP=$(ls -lhtp /tmp/npms/*.tgz 2>/dev/null | head -n1 | awk '{print $9}')
  if [ -z "${LATEST_TGZ_APP}" ]; then
    echo "No npm/yarn package to install! Tried /mnt/dist/npms & /tmp/npms"
    exit 1
  fi
fi
# yarn list --pattern awsmgr --depth=0 --json --non-interactive --no-progress | jq -r '.data.trees[].name'
AWSMGRCHK=$(\
    yarn global list \
      --pattern awsmgr \
      --depth=0 \
      --json \
      --non-interactive \
      --no-progress \
      | jq -r 'select(.type == "info") | .data | split("\"")[1]' \
      | awk -F'@' '{print $1}' \
    || true\
  )
if [ ! -z "${AWSMGRCHK}" ]; then
  # echo "Issue: awsmgr already exists in image?"
  # exit 1
  yarn global remove $LATEST_TGZ_APP
fi

## BUG: weird in that yarn seems to cache files even when we have them locally?! (cannot do during build step :`(
[ ${YARNCACHECLEAN-0} -eq 1 ] && { yarn cache clean; echo "~~~~~~~~~~~~~~  CLEARED YARN CACHE ~~~~~~~~~~~~~~"; }

echo "Installing: ${LATEST_TGZ_APP}"
if [[ -f "${LATEST_TGZ_APP}" ]]; then
  echo "Installing $LATEST_TGZ_APP via yarn..."
  SKIP_PREPARE=1 yarn global add --production $LATEST_TGZ_APP && yarn cache clean
  # Verify it installed
  AWSMGRCHK=$(\
    yarn global list \
      --pattern awsmgr \
      --depth=0 \
      --json \
      --non-interactive \
      --no-progress \
      | jq -r 'select(.type == "info") | .data | split("\"")[1]' \
      | awk -F'@' '{print $1}' \
    || true\
  )
  if [ -z "${AWSMGRCHK}" ]; then
    echo "ERROR: awsmgr did not successfully install."
    exit 1
  fi
else
  >&2 echo "ERROR: $LATEST_TGZ_APP doesn't exist!"
  exit 1
fi

# pushd ${AWSMGR_DIR}
## how can we speed this up?
# npm ci
# +
# popd
