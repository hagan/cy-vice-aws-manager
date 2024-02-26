# Dockerfile.vice_python_base
# src: https://github.com/docker-library/python/blob/35d09c044857f7aef2bf24791027f3e3fe2c34dd/3.11/alpine3.18/Dockerfile

## src/vice/dockerhub/docker_revisions/bookworm.v3/Dockerfile

ARG AWSMGR_PARENT_IMAGE=hagan/pynode
ARG AWSMGR_PARENT_TAG=alpine3-19v2

FROM ${AWSMGR_PARENT_IMAGE}:${AWSMGR_PARENT_TAG}

## Docker buildx caching directories for yarn and pip
ENV YARN_CACHE_FOLDER=/home/node/.yarn/cache
ENV GUNICORN_PIP_CACHE_DIR=/home/gunicorn/.cache/pip
ENV CYVERSE_PIP_CACHE_DIR=/home/cyverse/.cache/pip

USER root

# RUN mkdir -p /usr/local/lib/node_modules
# RUN chown -R node:node /usr/local/lib/node_modules
# RUN chmod -R 0775 /usr/local/lib/node_modules

# pre install some packages locally for npm/node

# These packages are taken from the awsmgr package (pre install to save time)
# Build notes: re2/re2-dev/libffi/libffi-dev & openssl-dev required by grpcio
# which is required by our flask app.
# libffi-dev already installed
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
    ccache \
    ncurses-base \
    ## re2 \
    ## re2-dev \
    ## python3 \
    # make \
    # cmake \
    # gcc \
    # g++ \
    # libjson-c-dev \
    # libwebsockets-dev \
    # libgcc-11-dev \
    ## libffi \
    ## libffi-dev \
    ## openssl-dev \
    ## gcompat
    # linux-headers-amd64 \
    # linux-headers-cloud-amd64 \
    binutils \
    acl \
  && pip install --root-user-action=ignore --upgrade pip \
  && adduser cyverse \
    --disabled-password --gecos "Cyverse User" \
    --uid 1000 \
    --shell /usr/bin/bash \
    --home /home/cyverse \
  && usermod -aG cyverse www-data \
  && mkdir -p /usr/local/src/cyverse \
  && chown cyverse:cyverse /usr/local/src/cyverse \
  && chmod 0775 /usr/local/src/cyverse \
  && pip install --root-user-action=ignore --upgrade pip \
  && adduser gunicorn \
    --disabled-password --gecos "Gunicorn User" \
    --system \
    --group \
    --uid 500 \
    --shell /usr/bin/bash \
    --home /home/gunicorn \
  && usermod -aG gunicorn www-data \
  && usermod -aG cyverse gunicorn \
  && mkdir -p /run/gunicorn-awsmgr \
  && chmod 0755 /run/gunicorn-awsmgr \
  && mkdir /run/gunicorn \
  && chown gunicorn:gunicorn /run/gunicorn \
  && chmod 0775 /run/gunicorn \
  && adduser node \
    --disabled-password --gecos "Node User" \
    --system \
    --group \
    --uid 501 \
    --shell /usr/bin/bash \
    --home /home/node \
  && usermod -aG www-data node \
  && usermod -aG cyverse node \
  && mkdir -p /home/node/.yarn/cache \
  && chown -R node:node /home/node/.yarn \
  && mkdir -p /run/node-awsmgr \
  && chmod 0755 /run/node-awsmgr \
  && mkdir /run/node \
  && chown node:node /run/node \
  && chmod 0775 /run/node \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --chown=cyverse:cyverse ./requirements.txt /home/cyverse/.
COPY --chown=node:node ./yarn.lock /home/node/.
COPY --chown=node:node ./package.json /home/node/.

# setup user python environment
USER cyverse
WORKDIR /home/cyverse
RUN --mount=type=cache,target=${CYVERSE_PIP_CACHE_DIR},uid=1000,gid=1000,mode=0755 \
  cd /home/cyverse \
  && python -m venv envs/flask-env \
  && . /home/cyverse/envs/flask-env/bin/activate \
  && pip install -r /home/cyverse/requirements.txt \
  && rm /home/cyverse/requirements.txt

USER node
WORKDIR /home/node/

## Pre install packages needed for UI into node's global space
RUN --mount=type=cache,target=${YARN_CACHE_FOLDER},uid=501,gid=501,mode=0755 \
  mkdir -p $(yarn global dir) \
  && mv /home/node/yarn.lock $(yarn global dir)/. \
  && mv /home/node/package.json $(yarn global dir)/. \
  && cd $(yarn global dir) \
  && SKIP_PREPARE=1 yarn install --cache-folder=${YARN_CACHE_FOLDER} --frozen-lockfile

USER root
COPY --chown=gunicorn:gunicorn ./requirements.txt /home/gunicorn/.

USER gunicorn
WORKDIR /home/gunicorn
RUN --mount=type=cache,target=${GUNICORN_PIP_CACHE_DIR},uid=500,gid=500,mode=0755 \
  cd /home/gunicorn \
  && python -m venv envs/flask-env \
  && . /home/gunicorn/envs/flask-env/bin/activate \
  && pip install -r /home/gunicorn/requirements.txt

USER root
RUN mkdir -p /usr/src/awsmgr && \
  chown gunicorn:gunicorn /usr/src/awsmgr
WORKDIR /usr/src/awsmgr
