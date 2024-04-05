# Dockerfile.vice_python_base
# src: https://github.com/docker-library/python/blob/35d09c044857f7aef2bf24791027f3e3fe2c34dd/3.11/alpine3.18/Dockerfile

## src/vice/dockerhub/docker_revisions/bookworm.v3/Dockerfile

ARG AWSMGR_PARENT_IMAGE=hagan/pynode
ARG AWSMGR_PARENT_TAG=alpine3-19v2

FROM ${AWSMGR_PARENT_IMAGE}:${AWSMGR_PARENT_TAG}

ARG AWSMGR_PARENT_IMAGE
ENV AWSMGR_PARENT_IMAGE=${AWSMGR_PARENT_IMAGE}

ARG AWSMGR_PARENT_TAG
ENV AWSMGR_PARENT_TAG=${AWSMGR_PARENT_TAG}

ARG AWSMGR_NAME='pynode'
ARG AWSMGR_TAG='latest'
ARG DOCKER_IMAGE=${AWSMGR_NAME}:${AWSMGR_TAG}
ENV DOCKER_IMAGE=${DOCKER_IMAGE}

ARG CACHEBUST=1

## Docker buildx caching directories for yarn and pip
# ENV YARN_CACHE_FOLDER=/home/node/.yarn/cache

ENV GUNICORN_PIP_CACHE_DIR=/home/gunicorn/.cache/pip
ENV CYVERSE_PIP_CACHE_DIR=/home/cyverse/.cache/pip

USER root

RUN wget -O- https://packages.irods.org/irods-signing-key.asc \
  | gpg --dearmor > /usr/share/keyrings/irods-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/irods-archive-keyring.gpg] https://packages.irods.org/apt/ $(lsb_release -sc) main" \
  > /etc/apt/sources.list.d/renci-irods.list

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
    memcached \
    cron \
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
    netcat-traditional \
    binutils \
    acl \
    irods-icommands \
  && (cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && /tmp/aws/install \
    && rm awscliv2.zip \
    && rm -rvf /tmp/aws \
  ) \
  && pip install --root-user-action=ignore --upgrade pip \
  && adduser cyverse \
    --disabled-password --gecos "Cyverse User" \
    --uid 1000 \
    --shell /usr/bin/bash \
    --home /home/cyverse \
  && usermod -aG www-data cyverse \
  && usermod -aG sudo cyverse \
  && usermod -aG adm cyverse \
  && usermod -aG systemd-journal cyverse \
  && mkdir -p /usr/local/src/cyverse \
  && chown cyverse:cyverse /usr/local/src/cyverse \
  && chmod 0775 /usr/local/src/cyverse \
  && pip install --root-user-action=ignore --upgrade pip \
  && pip3 install supervisor pymemcache boto3 \
  && adduser gunicorn \
    --disabled-password --gecos "Gunicorn User" \
    --system \
    --group \
    --uid 500 \
    --shell /usr/bin/bash \
    --home /home/gunicorn \
  && usermod -aG gunicorn www-data \
  && usermod -aG gunicorn cyverse \
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
  && usermod -aG node cyverse \
  && mkdir -p /run/node-awsmgr \
  && chmod 0755 /run/node-awsmgr \
  && mkdir /run/node \
  && chown node:node /run/node \
  && chmod 0775 /run/node \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG CACHEBUST=1
COPY --chown=cyverse:cyverse ./requirements.txt /home/cyverse/.
COPY --chown=node:node [ "./yarn.lock", "/tmp/npms/" ]
COPY --chown=node:node ./package.json /home/node/.
# COPY --chown=node:node ./package-lock.json /home/node/.
COPY --chown=node:node [ "./*.tgz", "/tmp/npms/" ]
COPY --chown=node:node [ "./.yarn/", "/home/node/.yarn" ]
COPY --chown=node:node [ "./.yarnrc.yml", "/home/node/" ]

# setup user python environment
USER cyverse
WORKDIR /home/cyverse
RUN --mount=type=cache,target=${CYVERSE_PIP_CACHE_DIR},uid=1000,gid=1000,mode=0755 \
  cd /home/cyverse \
    && python -m venv envs/flask-env \
    && . /home/cyverse/envs/flask-env/bin/activate \
    && pip install -r /home/cyverse/requirements.txt \
    && pip install gunicorn~=21.2.0 \
    && rm /home/cyverse/requirements.txt

USER node
WORKDIR /home/node/

## Pre install packages into yarn's global dir aka 'yarn add /tmp/npms/awsmgr-v0.0.1.tgz'
RUN --mount=type=cache,target=${YARN_CACHE_FOLDER},uid=501,gid=501,mode=0755 \
  corepack enable \
  && yarn set version canary \
  && yarn init \
  && export LATEST_TGZ_APP=$(find /tmp/npms -name '*.tgz' -type f -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2- || true) \
  && test -f ${LATEST_TGZ_APP} && yarn add ${LATEST_TGZ_APP} \
  && echo "LATEST_TGZ_APP: ${LATEST_TGZ_APP}"

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

RUN \
    echo "Parent image name: ${AWSMGR_PARENT_IMAGE}:${AWSMGR_PARENT_TAG}" > /etc/docker-image-ver \
  && echo "Docker image name: ${DOCKER_IMAGE}" >> /etc/docker-image-ver \
  && echo "       built date: $(date '+%A %W %Y %X')" >> /etc/docker-image-ver