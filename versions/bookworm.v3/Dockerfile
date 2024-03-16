ARG VICE_PARENT_IMAGE=hagan/awsmgr
ARG VICE_PARENT_TAG=latest

FROM ${VICE_PARENT_IMAGE}:${VICE_PARENT_TAG}

ARG VICE_PARENT_IMAGE
ENV VICE_PARENT_IMAGE=${VICE_PARENT_IMAGE}

ARG VICE_PARENT_TAG
ENV VICE_PARENT_TAG=${VICE_PARENT_TAG}

ARG CACHEBUST=1

ARG VICE_NAME='viceawsmgr'
ARG VICE_TAG='latest'
ARG DOCKER_IMAGE=${VICE_NAME}:${VICE_TAG}

ARG CACHEBUST=1

# relative path to our Dockerfile
ARG VICE_DKR_DIR="${VICE_DKR_DIR}"
ARG FLASK_DIR="./src/flask"
ARG UI_DIR="./src/ui"

# app specific paths internal to the image
ARG STATIC_ROOT='/var/www/static'

## removed (not compatible with yarn 4+)
# YARN_CACHE_FOLDER=/home/node/.yarn/cache \
#   YARN_CACHE_VER=nodeapp_v1 \

ARG EXPRESS_SOCKET_FILE='/run/node/sockets/express-nextjs.socket'
ARG GUNICORN_SOCKET_FILE='/run/gunicorn/flask-awsmgr.sock'
ARG DEPLOY_TYPE=production
ARG EXPRESS_DEBUG_CLEANUP=false

ENV EXPRESS_SOCKET_FILE=${EXPRESS_SOCKET_FILE} \
  GUNICORN_SOCKET_FILE=${GUNICORN_SOCKET_FILE} \
  CCACHE_DIR=/ccache \
  DEPLOY_TYPE=${DEPLOY_TYPE} \
  CACHEBUST=${CACHEBUST} \
  EXPRESS_DEBUG_CLEANUP=${EXPRESS_DEBUG_CLEANUP}

USER root
WORKDIR /
COPY --chown=root:root ${VICE_DKR_DIR}/package.tar.gz .
RUN echo "CACHEBUST=$CACHEBUST" && tar xfz package.tar.gz && rm package.tar.gz

RUN /setup.sh

COPY --chown=gunicorn:gunicorn ${FLASK_DIR}/dist/ /tmp/wheels/.
COPY --chown=node:node ${UI_DIR}/dist/ /tmp/npms/.

## Install our awsmgr flask app into cyverse
USER cyverse
ENV CYVERSE_PIP_CACHE_DIR=/home/cyverse/.cache/pip
# COPY --chown=cyverse:cyverse ${VICE_DKR_DIR}/home/cyverse/ /home/cyverse/.
RUN --mount=type=cache,target=${CYVERSE_PIP_CACHE_DIR},uid=1000,gid=1000,mode=0755 wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) \
  && echo "wheel_file = $wheel_file" \
  && . /home/cyverse/envs/flask-env/bin/activate \
  && pip install --cache-dir=${CYVERSE_PIP_CACHE_DIR} $wheel_file \
  && mkdir -p /home/cyverse/.irods

## ## Install our awsmgr flask app into gunicorn
# Dependency cache mount to /root/.cache/pip!!
USER gunicorn
ENV GUNICORN_SOCKET_FILE=${GUNICORN_SOCKET_FILE} \
  GUNICORN_PIP_CACHE_DIR=/home/gunicorn/.cache/pip \
  DEPLOY_TYPE=${DEPLOY_TYPE}

# NOTE: /tmp/wheels is used during Dockerfile build, /mnt/dist/wheels while running
RUN --mount=type=cache,target=${GUNICORN_PIP_CACHE_DIR},uid=500,gid=500,mode=0755 \
  wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) \
  && echo "wheel_file = $wheel_file" \
  && . /home/gunicorn/envs/flask-env/bin/activate \
  && pip install --cache-dir=${GUNICORN_PIP_CACHE_DIR} $wheel_file \
  && pip install gunicorn~=21.2.0 \
  && echo -e "GUNICORN_SOCKET_FILE='${GUNICORN_SOCKET_FILE}'\n" > /home/gunicorn/.env.local || echo "failed GUNICORN_SOCKET_FILE" \
  && echo -e "DEPLOY_TYPE='${DEPLOY_TYPE}'" >> /home/gunicorn/.env.local || echo "failed DEPLOY_TYPE" \
  && mkdir -p /home/gunicorn/.irods

USER node
ENV EXPRESS_SOCKET_FILE=${EXPRESS_SOCKET_FILE} \
  DEPLOY_TYPE=${DEPLOY_TYPE} \
  NODE_VERSION=21.6.1 \
  NPM_CONFIG_PREFIX="/home/node/.local"
# COPY --chown=node:node ${VICE_DKR_DIR}/home/node/ /home/node/.
## Need to map our npm global -> ~/.local/bin & ~/.local/lib etc...
WORKDIR /home/node
## tell the update-npm.sh to skill "yarn install" step / moved into awsmgr step
## --mount=type=cache,id=${YARN_CACHE_VER},target=${YARN_CACHE_FOLDER},uid=501,gid=501,mode=0755
RUN \
  echo -e "EXPRESS_SOCKET_FILE='${EXPRESS_SOCKET_FILE}'\n" > /home/node/.env.local || echo "failed EXPRESS_SOCKET_FILE" \
  && echo -e "DEPLOY_TYPE='${DEPLOY_TYPE}'" >> /home/node/.env.local || echo "failed DEPLOY_TYPE" \
  && cd /home/node || echo "failed cd /home/node" \
  && /usr/local/bin/update-npm.sh || echo "failed to update npm" \
  && mkdir -p /home/node/.irods

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
# RUN echo "EXPRESS_SOCKET_FILE=$EXPRESS_SOCKET_FILE" > /usr/local/src/awsmgr-ui/.env.local \
#   && mkdir /home/node/bin
# COPY ${VICE_DKR_DIR}/update-npm.sh /home/node/bin/.
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

RUN \
  echo "Parent image name: ${VICE_PARENT_IMAGE}:${VICE_PARENT_TAG}" >> /etc/docker-image-ver \
  && echo "Docker image name: ${DOCKER_IMAGE}" >> /etc/docker-image-ver \
  && echo "       built date: $(date '+%A %W %Y %X')" >> /etc/docker-image-ver

EXPOSE 80

ENTRYPOINT ["sh", "/entrypoint.sh"]
