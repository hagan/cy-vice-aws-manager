#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PATH=$HOME/node_modules/.bin:$PATH

echo "Version 0.0.5"

if [ "$(whoami)" != 'node' ]; then
  echo >&2 "ERROR: must run awsmgr-start as 'node' user. Currently running as: $(whoami)"
  exit 1
fi

pushd /home/node

if [ "$(pwd)" != '/home/node' ]; then
  echo >&2 "ERROR: must run under /home/node user directory / workspace"
  exit 1
fi

## wipe old workspace?
yarn init

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

>&2 echo "Installing: ${LATEST_TGZ_APP}"
if [[ -f "${LATEST_TGZ_APP}" ]]; then
  echo >&2 "Installing $LATEST_TGZ_APP via yarn..."
#   # SKIP_PREPARE=1
  yarn add $LATEST_TGZ_APP \
    && yarn cache clean \
    && echo >&2 "awsmgr installed"
  # Verify it installed (yarn 4+)
  AWSMGRCHK=$(\
    yarn why awsmgr --json | \
      jq 'select(.value == "node@workspace:.") | .children | keys[] | select(contains("awsmgr"))' | \
      awk -F'@' '{gsub(/"/,""); print $1}' \
    || true \
  )
  if [ -z "${AWSMGRCHK}" ]; then
    echo >&2 "ERROR: awsmgr did not successfully install."
    exit 1
  fi
else
  >&2 echo >&2 "ERROR: $LATEST_TGZ_APP doesn't exist!"
  exit 1
fi

popd
echo "Finished"