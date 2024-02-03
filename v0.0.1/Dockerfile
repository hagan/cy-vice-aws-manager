ARG VICE_PARENT_IMAGE=hagan/pynode
ARG VICE_PARENT_TAG=alpine3.19v2
FROM ${VICE_PARENT_IMAGE}:${VICE_PARENT_TAG}

ENV CCACHE_DIR=/ccache

ARG DOCKER_NAME='viceawsmgr'
ARG DOCKER_TAG='v0.0.1'
ARG DOCKER_IMAGE=${DOCKER_NAME}:${DOCKER_TAG}

# relative path to our Dockerfile
ARG DOCKER_DIR="./src/vice/${DOCKER_TAG}"

# app specific paths internal to the image
ARG STATIC_ROOT='/var/www/static'

ARG NODE_SOCK='/run/nginx/node-nextjs.socket'
ENV NODE_SOCK=${NODE_SOCK}

# save vars to our environment
RUN echo "DOCKER_NAME=${DOCKER_NAME}" > .env
RUN echo "DOCKER_TAG=${DOCKER_TAG}" >> .env
RUN echo "DOCKER_IMAGE=${DOCKER_IMAGE}" >> .env

## SETUP NVM/NODE
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 21.6.1

RUN mkdir -p $NVM_DIR \
  && apk update \
  && apk add -U \
    ccache \
    curl \
    bash \
    ca-certificates \
    openssl \
    ncurses \
    coreutils \
    python3 \
    make \
    gcc \
    g++ \
    libgcc \
    linux-headers \
    grep \
    util-linux \
    binutils \
    findutils \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && . $NVM_DIR/nvm.sh
RUN --mount=type=cache,target=/ccache . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default


# Save environment vars for our application
RUN echo "STATIC_ROOT=${STATIC_ROOT}" >> .env
# COPY OUR entrypoint.sh script
COPY ${DOCKER_DIR}/entrypoint.sh /usr/local/bin/
RUN chmod u+x,g+x /usr/local/bin/entrypoint.sh \
  && ln -s /usr/local/bin/entrypoint.sh / # backwards compat

# supervisord
COPY ${DOCKER_DIR}/etc/supervisord.conf /etc/supervisord.conf
COPY ${DOCKER_DIR}/etc/supervisor.d/ /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor

# Nginx stuff
RUN chown nginx:nginx /run/nginx && chmod 0775 /run/nginx
## !!!!! NEED TO FIX THIS SO OUR SOCKETS CANT WRITE node<->nginx..
## Fix: Move the socket to a better place like /run/node-awsmgr/express.sock

RUN addgroup -g 102 node \
    && adduser -u 102 -G node -s /bin/sh -D node \
    && addgroup node nginx \
    && addgroup nginx node
COPY ${DOCKER_DIR}/etc/nginx/proxy_params /etc/nginx/proxy_params
COPY ${DOCKER_DIR}/etc/nginx/http.d/ /etc/nginx/http.d/

# Gunicorn stuff
RUN addgroup -g 1001 gunicorn \
    && adduser -u 1001 -G gunicorn -s /bin/sh -D gunicorn
COPY ${DOCKER_DIR}/etc/gunicorn/gunicorn-awsmgr.conf.py /etc/gunicorn/awsmgr.conf.py
# Create directory for gunicorn!
RUN mkdir -p /run/gunicorn-awsmgr
RUN chown gunicorn:gunicorn /run/gunicorn-awsmgr
RUN chmod 0775 /run/gunicorn-awsmgr
## let nginx read/write to the gunicorn socket
RUN addgroup nginx gunicorn

# Create projects directories
RUN mkdir /tmp/wheels
RUN mkdir /tmp/npms
# RUN mkdir /usr/src/awsmgr

# Install Python Amazon Manager pacakge
COPY ./src/flask/dist/ /tmp/wheels/.
# Dependency cache mount to /root/.cache/pip!!
RUN --mount=type=cache,target=/root/.cache/pip wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) \
  && echo "wheel_file = $wheel_file" \
  && pip install $wheel_file

# Install NodeJS/NextJS Amazon package (eventually i'd like this to work from a package!)
# COPY ./src/ui/dist/ /tmp/npms/.
# RUN cd /usr/src/awsmgr \
#   && npm_pkg=$(ls -tp /tmp/npms/*.tgz | head -n1) \
#   && echo "npm_pkg = $npm_pkg" \
#   && . $NVM_DIR/nvm.sh \
#   && npm install -g $npm_pkg
# # Install dependencies for the npm package
# RUN cd /usr/src/awsmgr \
#   && npm_pkg_dir=$(. $NVM_DIR/nvm.sh && npm list -g awsmgr --parseable) \
#   && echo "npm_kg_dir = $npm_pkg_dir" \
#   && cd $npm_pkg_dir \
#   && . $NVM_DIR/nvm.sh \
#   && npm install -g

## copy NextJS project from source
COPY ./src/ui/ /usr/src/awsmgr-ui/
RUN find /usr/src/awsmgr-ui -type f -executable -exec chmod 0775 {} \; && \
  find /usr/src/awsmgr-ui -type f ! -executable -exec chmod 0664 {} \; && \
  find /usr/src/awsmgr-ui -type d -exec chmod 0775 {} \; && \
  chown -R node:node /usr/src/awsmgr-ui

# ## we might not need to remove the node_modules, but seems to have issues with arm vs amd.
RUN test -d /usr/src/awsmgr-ui/node_modules && rm -rvf /usr/src/awsmgr-ui/node_modules && \
  test -f /usr/src/awsmgr-ui/package-log.json && rm /usr/src/awsmgr-ui/package-log.json && \
  test -f /usr/src/awsmgr-ui/.env.local && rm /usr/src/awsmgr-ui/.env.local || true

USER node
RUN --mount=type=cache,target=/root/.npm \
  cd /usr/src/awsmgr-ui \
  && PATH=/usr/local/bin:/usr/local/bin:/usr/bin:/bin \
  && . $NVM_DIR/nvm.sh \
  && npm install
USER root

# Create our lower privileged user for ttyd...
RUN addgroup -g 1002 cyverse && \
  adduser -u 1002 -G cyverse -s /bin/sh -D cyverse
RUN passwd -u cyverse

# END
EXPOSE 80

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]