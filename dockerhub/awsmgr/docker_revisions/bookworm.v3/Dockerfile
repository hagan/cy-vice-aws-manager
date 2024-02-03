# Dockerfile.vice_python_base
# src: https://github.com/docker-library/python/blob/35d09c044857f7aef2bf24791027f3e3fe2c34dd/3.11/alpine3.18/Dockerfile

ARG AWSMGR_PARENT_IMAGE=hagan/pynode
ARG AWSMGR_PARENT_TAG=alpine3-19v2

FROM ${AWSMGR_PARENT_IMAGE}:${AWSMGR_PARENT_TAG}

RUN mkdir -p /usr/local/lib/node_modules
# RUN chown -R node:node /usr/local/lib/node_modules
# RUN chmod -R 0775 /usr/local/lib/node_modules

# pre install some packages locally for npm/node
USER root
# These packages are taken from the awsmgr package (pre install to save time)

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
    ccache \
    ncurses-base \
    # re2 \
    # re2-dev \
    # python3 \
    make \
    cmake \
    gcc \
    g++ \
    libjson-c-dev \
    libwebsockets-dev \
    libgcc-11-dev \
    # libffi \
    # libffi-dev \
    # openssl-dev \
    # gcompat
    linux-headers-amd64 \
    linux-headers-cloud-amd64 \
    binutils

# Create gunicorn user for Django/Flask api endpoints
# RUN adduser gunicorn \
#   --disabled-password --gecos "Gunicorn User" \
#   --system \
#   --group \
#   --uid 500 \
#   --shell /usr/bin/bash \
#   --home /home/gunicorn && \
#   usermod -aG gunicorn www-data && \
#   mkdir -p /run/gunicorn-awsmgr && \
#   chmod 0755 /run/gunicorn-awsmgr

# # Create node user for React/NextJS express server
# RUN adduser node \
#   --disabled-password --gecos "Node User" \
#   --system \
#   --group \
#   --uid 501 \
#   --shell /usr/bin/bash \
#   --home /home/node && \
#   usermod -aG node www-data && \
#   mkdir -p /run/node-awsmgr && \
#   chmod 0755 /run/node-awsmgr

# # ## Prefetch our libraries for our NextJS application
# USER node
# RUN npm install -g \
#   @fontsource/inter@5.0.16 \
#   @next/eslint-plugin-next@14.1.0 \
#   @storybook/addon-essentials@7.6.11 \
#   @storybook/addon-interactions@7.6.11 \
#   @storybook/addon-links@7.6.11 \
#   @storybook/blocks@7.6.11 \
#   @storybook/nextjs@7.6.11 \
#   @storybook/react@7.6.11 \
#   @storybook/test@7.6.11 \
#   @types/jest@29.5.11 \
#   @types/jsonwebtoken@9.0.5 \
#   @types/node@20.11.10 \
#   @types/react-dom@18.2.18 \
#   @types/react@18.2.48 \
#   @typescript-eslint/eslint-plugin@6.20.0 \
#   @typescript-eslint/parser@6.20.0 \
#   @vercel/ncc@0.38.1 \
#   autoprefixer@10.4.17 \
#   bootstrap@5.3.2 \
#   dotenv@16.4.1 \
#   eslint-config-next@14.1.0 \
#   eslint-plugin-next@0.0.0 \
#   eslint-plugin-react@7.33.2 \
#   eslint-plugin-storybook@0.6.15 \
#   eslint@8.56.0 \
#   express@4.18.2 \
#   husky@9.0.7 \
#   jest@29.7.0 \
#   jsonwebtoken@9.0.2 \
#   next-cli@1.0.0 \
#   next@14.1.0 \
#   nodemon@3.0.3 \
#   numeral@2.0.6 \
#   prettier@3.2.4 \
#   pretty-quick@4.0.0 \
#   react-bootstrap@2.10.0 \
#   react-dom@18.2.0 \
#   react@18.2.0 \
#   storybook@7.6.11 \
#   ts-jest@29.1.2 \
#   ts-node@10.9.2 \
#   typescript@5.3.3 \
#   sharp@0.32.6

USER root
# RUN chown -R node:node /usr/local/lib/node_modules
# RUN chmod -R 0775 /usr/local/lib/node_modules

# Build notes: re2/re2-dev/libffi/libffi-dev & openssl-dev required by grpcio
# which is required by our flask app.
# libffi-dev already installed
# WORKS TO HERE

# Python updates
# RUN pip install --upgrade pip
# COPY requirements.txt /root/.
# RUN pip install -r /root/requirements.txt

RUN mkdir -p /usr/src/awsmgr
WORKDIR /usr/src/awsmgr
