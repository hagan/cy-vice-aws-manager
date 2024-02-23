ARG VICE_PARENT_IMAGE=hagan/pynode
ARG VICE_PARENT_TAG=bookworm.v5
ARG CACHEBUST=20240221F
FROM ${VICE_PARENT_IMAGE}:${VICE_PARENT_TAG}

ARG VICE_NAME='viceawsmgr'
ARG VICE_VERSION='v0.0.1'
ARG DOCKER_IMAGE=${VICE_NAME}:${VICE_VERSION}

# relative path to our Dockerfile
ARG VICE_DIR="./src/vice/versions/${VICE_VERSION}"
ARG FLASK_DIR="./src/flask"
ARG UI_DIR="./src/ui"

# app specific paths internal to the image
ARG STATIC_ROOT='/var/www/static'

ARG SOCKET_FILE='/run/node/sockets/express-nextjs.socket'
ENV SOCKET_FILE=${SOCKET_FILE} \
  CCACHE_DIR=/ccache \
  YARN_CACHE_FOLDER=/home/node/.yarn/cache \
  YARN_CACHE_VER=nodeapp_v1 \
  PIP_CACHE_DIR=/home/gunicorn/.cache/pip \
  NODE_VERSION=21.6.1 \
  NPM_CONFIG_PREFIX="/home/node/.local" \
  SKIP_YARN_INSTALL=1 \
  DEPLOY_TYPE=production

# COPY OUR entrypoint.sh script
COPY ${VICE_DIR}/entrypoint.sh /usr/local/bin/

# supervisord
COPY ${VICE_DIR}/etc/supervisord.conf /etc/supervisord.conf
COPY ${VICE_DIR}/etc/supervisor.d/ /etc/supervisor.d/

# Nginx stuff
COPY ${VICE_DIR}/etc/nginx/proxy_params /etc/nginx/proxy_params
COPY ${VICE_DIR}/etc/nginx/sites-available/default /etc/nginx/sites-available/.

COPY ${VICE_DIR}/etc/gunicorn/gunicorn-awsmgr.conf.py /etc/gunicorn/awsmgr.conf.py

# rsyslogd configuration
COPY ${VICE_DIR}/etc/rsyslog.conf /etc/.
COPY ${VICE_DIR}/etc/rsyslog.d/express.conf /etc/rsyslog.d/.

RUN echo "STATIC_ROOT=${STATIC_ROOT}" >> .env \
  && rm /bin/sh \
  && ln -s /bin/bash /bin/sh \
  && chmod u+x,g+x /usr/local/bin/entrypoint.sh \
  && ln -s /usr/local/bin/entrypoint.sh / \
  && [ -d /var/log/supervisor ] || mkdir -p /var/log/supervisor \
  && [ -d /mnt/dist/wheels ] || mkdir -p /mnt/dist/wheels \
  && [ -d /tmp/wheels ] || mkdir /tmp/wheels \
  && chown gunicorn:gunicorn /mnt/dist/wheels \
  && chown gunicorn:gunicorn /tmp/wheels \
  && [ -d /mnt/dist/npms ] || mkdir -p /mnt/dist/npms \
  && [ -d /tmp/npms ] || mkdir /tmp/npms \
  && [ -d /home/node/.local/bin ] || mkdir -p /home/node/.local/bin \
  && chown node:node /mnt/dist/npms \
  && chown node:node /tmp/npms \
  && chown -Rvf node:node /home/node/.local \
  && [ -d /home/gunicorn/bin ] || mkdir /home/gunicorn/bin \
  && chown gunicorn:gunicorn /home/gunicorn/bin \
  && mkdir -p /run/node/sockets \
  && chown node:node /run/node \
  && chown node:www-data /run/node/sockets \
  && chmod g+sw,o-rx /run/node/sockets \
  && setfacl -d -m g:www-data:rwx /run/node/sockets \
  && setfacl -d -m o::--- /run/node/sockets \
  && pip install supervisor

COPY --chown=gunicorn:gunicorn ${FLASK_DIR}/dist/ /tmp/wheels/.
COPY --chown=node:node ${UI_DIR}/dist/ /tmp/npms/.
COPY --chown=node:node ${VICE_DIR}/usr/local/bin/update-npm.sh /usr/local/bin/.
COPY --chown=node:node ${VICE_DIR}/usr/local/bin/cleanup-express-socket.py /usr/local/bin/.
COPY --chown=gunicorn:gunicorn ${VICE_DIR}/usr/local/bin/update-wheel.sh /usr/local/bin/.

# Dependency cache mount to /root/.cache/pip!!
USER gunicorn
COPY ${VICE_DIR}/home/gunicorn/ /home/gunicorn/.
# COPY ${VICE_DIR}/usr/local/bin/update-wheel.sh /home/gunicorn/bin/.

# NOTE: /tmp/wheels is used during Dockerfile build, /mnt/dist/wheels while running
RUN --mount=type=cache,target=${PIP_CACHE_DIR},uid=500,gid=500,mode=0755 wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) \
  && echo "wheel_file = $wheel_file" \
  && . /home/gunicorn/envs/flask-env/bin/activate \ 
  && pip install --cache-dir=${PIP_CACHE_DIR} $wheel_file

USER node

COPY ${VICE_DIR}/home/node/ /home/node/.
## Need to map our npm global -> ~/.local/bin & ~/.local/lib etc...
WORKDIR /home/node
## tell the update-npm.sh to skill "yarn install" step / moved into awsmgr step
## CACHE FUCKUP? 
## --mount=type=cache,id=${YARN_CACHE_VER},target=${YARN_CACHE_FOLDER},uid=501,gid=501,mode=0755
RUN \
  echo -e "SOCKET_FILE='${SOCKET_FILE}'\n" > /home/node/.env.local \
  && echo -e "DEPLOY_TYPE='${DEPLOY_TYPE}'" >> /home/node/.env.local \
  && [ -d /home/node/.npm ] \
  || mkdir /home/node/.npm \
  && [ -d $NPM_CONFIG_PREFIX ] \
  || mkdir -p $NPM_CONFIG_PREFIX \
  && cd /home/node \
  && /usr/local/bin/update-npm.sh

## Must "bootstrap" NextJS/ExpressJS apps with yarn
# RUN --mount=type=cache,target=/root/.npm \
#   cd /home/node/node_modules/awsmgr && \
#   export PATH=$HOME/node_modules/.bin:$PATH \
#   && yarn install

# RUN cd /usr/local/src/awsmgr \
#   && npm_pkg=$(ls -tp /mnt/dist/npms/*.tgz | head -n1) \
#   && echo "npm_pkg = $npm_pkg" \
#   && . $NVM_DIR/nvm.sh \
#   && npm install -g $npm_pkg
# # Install dependencies for the npm package
# RUN cd /usr/local/src/awsmgr \
#   && npm_pkg_dir=$(. $NVM_DIR/nvm.sh && npm list -g awsmgr --parseable) \
#   && echo "npm_kg_dir = $npm_pkg_dir" \
#   && cd $npm_pkg_dir \
#   && . $NVM_DIR/nvm.sh \
#   && npm install -g

# copy NextJS project from source
# RUN mkdir -p /usr/local/src/awsmgr-ui && \
#   chown www-data:www-data /usr/local/src/awsmgr-ui & \
#   chmod 0775 /usr/local/src/awsmgr-ui
### vv WORKING
# COPY --chown=node:node ./src/ui/ /usr/local/src/awsmgr-ui/
### ^^ WORKING
# RUN find /usr/local/src/awsmgr-ui -type d -exec chmod g+w {} + && \
#   find /usr/local/src/awsmgr-ui -type f -executable -exec chmod g+w {} + && \
#   find /usr/local/src/awsmgr-ui -type f ! -executable -exec chmod g+w {} +
### vv WORKING
# USER node
# RUN echo "SOCKET_FILE=$SOCKET_FILE" > /usr/local/src/awsmgr-ui/.env.local \
#   && mkdir /home/node/bin
# COPY ${VICE_DIR}/update-npm.sh /home/node/bin/.
# RUN --mount=type=cache,target=/root/.npm \
#   cd /usr/local/src/awsmgr-ui \
#   && npm install
# USER root
### ^^ WORKING
## we might not need to remove the node_modules, but seems to have issues with arm vs amd.
# RUN test -d /usr/local/src/awsmgr-ui/node_modules && rm -rvf /usr/local/src/awsmgr-ui/node_modules && \
#   test -f /usr/local/src/awsmgr-ui/package-log.json && rm /usr/local/src/awsmgr-ui/package-log.json && \
#   test -f /usr/local/src/awsmgr-ui/.env.local && rm /usr/local/src/awsmgr-ui/.env.local

# USER www-data
# RUN --mount=type=cache,target=/root/.npm \
#   cd /usr/local/src/awsmgr-ui \
#   && PATH=/usr/local/bin:/usr/local/bin:/usr/bin:/bin \
#   # && . $NVM_DIR/nvm.sh \
#   && npm install
USER root

# Create our lower privileged user for ttyd...
RUN adduser cyverse \
  --disabled-password --gecos "Gunicorn User" \
  --system \
  --group \
  --uid 1000 \
  --shell /usr/bin/bash \
  --home /home/cyverse && \
  usermod -aG cyverse www-data && \
  usermod -aG cyverse node && \
  usermod -aG cyverse gunicorn && \
  mkdir -p /usr/local/src/cyverse && \
  chown cyverse:cyverse /usr/local/src/cyverse && \
  chmod 0775 /usr/local/src/cyverse


# END
EXPOSE 80

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]