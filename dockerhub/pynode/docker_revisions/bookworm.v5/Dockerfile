# Starting with python and adding our packages
ARG PYNODE_PARENT_IMAGE=python
ARG PYNODE_PARENT_TAG=3.11.9-bookworm
## Build stage for ttyd

FROM debian:bookworm AS build
# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libjson-c-dev \
    libwebsockets-dev \
    && rm -rf /var/lib/apt/lists/*
# Clone ttyd repository
RUN git clone https://github.com/tsl0922/ttyd.git
# Build ttyd from source
WORKDIR /ttyd/build
RUN cmake .. \
    && make \
    && make install

## Starting point (python 3.11 bookworm)
FROM ${PYNODE_PARENT_IMAGE}:${PYNODE_PARENT_TAG}


ARG PYNODE_PARENT_IMAGE
ENV PYNODE_PARENT_IMAGE=${PYNODE_PARENT_IMAGE}

ARG PYNODE_PARENT_TAG
ENV PYNODE_PARENT_TAG=${PYNODE_PARENT_TAG}

ARG PYNODE_NAME='pynode'
ARG PYNODE_TAG='latest'
ARG DOCKER_IMAGE=${PYNODE_NAME}:${PYNODE_TAG}
ENV DOCKER_IMAGE=${DOCKER_IMAGE}

ARG CACHEBUST=1

# INCLUDE node:21.6.1-bookworm
# INCLUDE python:3.11.7-bookworm
# INCLUDE golang:1.21.6-bookworm

LABEL org.label-schema.name="CyVerse VICE AWS Mangager" \
    org.label-schema.description="Built from Debian bookworm w/ Python, Node and Go" \
    org.label-schema.url="https://cyverse.org" \
    org.label-schema.vcs-url="e.g. https://github.com/hagan/cy-aws-manager" \
    org.label-schema.vendor="CyVerse" \
    org.label-schema.schema-version="1.0.0"

USER root

# Add sudo to user
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # services
    nginx \
    rsyslog \
    supervisor \
    openssl \
    # system utils
    util-linux \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    lsb-release \
    # user utils
    less \
    locales \
    findutils \
    wget \
    curl \
    git \
    bzip2 \
    unzip \
    gnupg \
    coreutils \
    bash \
    zsh \
    sudo \
    grep \
    neovim \
    tmux \
    jq \
    gettext-base \
    libjson-c-dev \
    libwebsockets-dev \
    libevent-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## copy ttyd from build step
COPY --from=build /usr/local/bin/ttyd /usr/local/bin/ttyd

# Install MiniConda and Tini
ENV TZ America/Phoenix
# Setup timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
# Setup locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install ttyd (1.6.3)
# RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64" > ttyd && \
#     chmod a+x ttyd && \
#     mv ttyd /usr/local/bin/ttyd

# RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64" > ttyd && \
#     chmod a+x ttyd && \
#     mv ttyd /usr/local/bin/ttyd

## cleanup / in case we missed something
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn-archive-keyring.gpg
#   && echo "deb [signed-by=/etc/apt/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
#   && echo "# deb-src [signed-by=/etc/apt/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee -a /etc/apt/sources.list.d/yarn.list
#   curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg &&
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg]  https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list &&
#   echo "# deb-src [signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee -a /etc/apt/sources.list.d/docker.list &&
#   curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/google-cloud-archive-keyring.gpg &&
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-cloud-archive-keyring.gpg] http://packages.cloud.google.com/apt cloud-sdk-$(. /etc/os-release && echo "$VERSION_CODENAME") main" | tee /etc/apt/sources.list.d/google-cloud.list &&
#   echo "# deb-src [signed-by=/etc/apt/keyrings/google-cloud-archive-keyring.gpg] http://packages.cloud.google.com/apt cloud-sdk-$(. /etc/os-release && echo "$VERSION_CODENAME") main" | tee -a /etc/apt/sources.list.d/google-cloud.list &&
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-cloud-archive-keyring.gpg] http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list &&
#   echo "# deb-src [signed-by=/etc/apt/keyrings/google-cloud-archive-keyring.gpg] http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list &&
#   curl -sS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft-archive-keyring.gpg &&
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/microsoft.list &&

RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash -
## setup nodejs v21.6.2 & yarn 4.1.0
RUN apt-get update -y \
  && apt-get install -y nodejs \
  && corepack enable \
  && yarn set version canary \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

## NOTE: removed the following packages from this: azure-cli=2.33.1-1~bullseye, docker-ce, google-cloud-sdk,
## google-cloud-sdk-gke-gcloud-auth-plugin, & kubectl
RUN touch /etc/docker-image-ver \
  && echo "Parent image name: ${PYNODE_PARENT_IMAGE}:${PYNODE_PARENT_TAG}" >> /etc/docker-image-ver \
  && echo "Docker image name: ${DOCKER_IMAGE}" >> /etc/docker-image-ver \
  && echo "       built date: $(date '+%A %W %Y %X')" >> /etc/docker-image-ver