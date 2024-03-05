#!/usr/bin/env bash

function update_file_perms() {
    echo "Fixing permissions..."
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        continue
      fi
      owner_name=$(echo "${line}" | awk '{print $1}' | cut -d':' -f1)
      group_name=$(echo "${line}" | awk '{print $1}' | cut -d':' -f2)
      file_perm=$(echo "${line}" | awk '{print $2}')
      file_path=$(echo "${line}" | awk '{print $3}')
      chown ${owner_name}:${group_name} $file_path
      chmod ${file_perm} $file_path
    done < "$1"
}

if [[ ! -f /etc/docker-image-ver ]]; then
  echo "ERROR: cannot run outside of docker image!"
  exit 1
fi

if [[ $(whoami) != 'root' ]]; then
  >&2 echo "ERROR: setup.sh must run from root!"
  exit 1
fi

echo "Environment Vars..."
echo "STATIC_ROOT = ${STATIC_ROOT}"

echo "Setting up vice image..."

## todo: ADD STATIC_ROOT gunicorn, node & cyverse .env.local

test -f /bin/sh && { rm /bin/sh && { echo "-01-"; } || { >&2 echo "ERROR -01-"; exit 1; } }
ln -s /bin/bash /bin/sh && { echo "-02-"; } || { >&2 echo "ERROR -02-"; exit 1; }
chmod u+x,g+x /entrypoint.sh && { echo "-03-"; } || { >&2 echo "ERROR -03-"; exit 1; }
mkdir -p /var/log/ttyd && { echo "-04-"; } || { >&2 echo "ERROR -04-"; exit 1; }
mkdir -p /mnt/dist/wheels && { echo "-05-"; } || { >&2 echo "ERROR -05-"; exit 1; }
mkdir /tmp/wheels && { echo "-06-"; } || { >&2 echo "ERROR -06-"; exit 1; }
chown cyverse:cyverse /var/log/ttyd && { echo "-07-"; } || { >&2 echo "ERROR -07-"; exit 1; }
chown gunicorn:gunicorn /mnt/dist/wheels && { echo "-08-"; } || { >&2 echo "ERROR -08-"; exit 1; }
chown gunicorn:gunicorn /tmp/wheels && { echo "-09-"; } || { >&2 echo "ERROR -09-"; exit 1; }
mkdir -p /mnt/dist/npms && { echo "-10-"; } || { >&2 echo "ERROR -10-"; exit 1; }
[ ! -d /tmp/npms ] && { mkdir /tmp/npms && { echo "-11-"; } || { >&2 echo "ERROR -11-"; exit 1; } || echo "-11- /tmp/npms exists!"; }
[ ! -d /home/node/.local/bin ] && { mkdir -p /home/node/.local/bin && { echo "-12-"; } || { >&2 echo "ERROR -12-"; exit 1; } }
chown node:node /mnt/dist/npms && { echo "-13-"; } || { >&2 echo "ERROR -13-"; exit 1; }
chown node:node /tmp/npms && { echo "-14-"; } || { >&2 echo "ERROR -14-"; exit 1; }
chown -Rvf node:node /home/node/.local && { echo "-15-"; } || { echo "ERROR -15-"; exit 1; }
mkdir /home/gunicorn/bin && { echo "-16-"; } || { echo "ERROR -16-"; exit 1; }
chown gunicorn:gunicorn /home/gunicorn/bin && { echo "-17-"; } || { echo "ERROR -17-"; exit 1; }
mkdir -p /run/node/sockets && { echo "-18-"; } || { echo "ERROR -18-"; exit 1; }
chown node:node /run/node && { echo "-19-"; } || { echo "ERROR -19-"; exit 1; }
chown node:www-data /run/node/sockets && { echo "-20-"; } || { echo "ERROR -20-"; exit 1; }
chmod g+sw,o-rx /run/node/sockets && { echo "-21-"; } || { echo "ERROR -21-"; exit 1; }
setfacl -d -m g:www-data:rwx /run/node/sockets && { echo "-22-"; } || { echo "ERROR -22-"; exit 1; }
setfacl -d -m o::--- /run/node/sockets && { echo "-23-"; } || { echo "ERROR -23-"; exit 1; }
pip install supervisor && { echo "-24-"; } || { echo "ERROR -24-"; exit 1; }
mkdir /ramdisk && { echo "-25-"; } || { echo "ERROR -25-"; exit 1; }
mkdir -p /run/ttyd/sockets && { echo "-26-"; } || { echo "ERROR -26-"; exit 1; }
chown cyverse:www-data /run/ttyd/sockets && { echo "-27-"; } || { echo "ERROR -27-"; exit 1; }
chmod g+sw,o-rx /run/ttyd/sockets && { echo "-28-"; } || { echo "ERROR -28-"; exit 1; }
setfacl -d -m g:www-data:rwx /run/ttyd/sockets && { echo "-29-"; } || { echo "ERROR -29-"; exit 1; }
setfacl -d -m o::--- /run/ttyd/sockets && { echo "-30-"; } || { echo "ERROR -30-"; exit 1; }
mkdir -p /usr/local/var/pulumi && { echo "-31-"; } || { echo "ERROR -31-"; exit 1; }
chown -f gunicorn:gunicorn /usr/local/var && { echo "-32-"; } || { echo "ERROR -32-"; exit 1; }
chmod -f g+sw /usr/local/var && { echo "-33-"; } || { echo "ERROR -33-"; exit 1; }
chown -f gunicorn:gunicorn /usr/local/var/pulumi && { echo "-34-"; } || { echo "ERROR -34-"; exit 1; }
chmod -f g+sw /usr/local/var/pulumi && { echo "-35-"; } || { echo "ERROR -35-"; exit 1; }
setfacl \
    -m u:cyverse:rwx,g:cyverse:rwx \
    -m d:cyverse:rwx,g:cyverse:rwx \
    -m o::r-x \
    -m d:o::r-x /usr/local/var && { echo "-36-"; } || { echo "ERROR -36-"; exit 1; }
setfacl \
    -m u:cyverse:rwx,g:cyverse:rwx \
    -m d:cyverse:rwx,g:cyverse:rwx \
    -m o::--- \
    -m d:o::--- /usr/local/var/pulumi && { echo "-37-"; } || { echo "ERROR -37-"; exit 1; }

update_file_perms '/file_perms.txt'
rm '/file_perms.txt'