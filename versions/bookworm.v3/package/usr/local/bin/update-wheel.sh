#!/usr/bin/env sh

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

# if [ $(whoami) != 'gunicorn' ]; then
#   echo "ERROR: must run awsmgr-start as 'gunicorn' user. Currently running as: $(whoami)"
#   exit 1
# fi

FLASK_VIRTUAL_ENV="$HOME/envs/flask-env/bin/activate"
LATEST_WHL_APP=$(ls -lhtp /mnt/dist/wheels/*.whl | head -n1 | awk '{print $9}')

if [ ! -f $LATEST_WHL_APP ]; then
   >&2 echo "ERROR: No packages in /mnt/dist/wheels to install!"
   exit 1
elif [ -f $FLASK_VIRTUAL_ENV ]; then
  echo "Installing $LATEST_WHL_APP"
  echo "Current virtualenv -> $FLASK_VIRTUAL_ENV"
  whoami
  . $FLASK_VIRTUAL_ENV && pip install --force-reinstall --no-deps $LATEST_WHL_APP
  exit $?
elif [ ! -z $VIRTUAL_ENV ]; then
  pip install  --force-reinstall --no-deps $LATEST_WHL_APP
  exit $?
else
  >&2 echo "ERROR: No virtualenv set or available to run in!"
  exit 1
fi
