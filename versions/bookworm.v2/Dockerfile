ARG VICE_PARENT_IMAGE=hagan/pynode
ARG VICE_PARENT_TAG=bookworm.v5
FROM ${VICE_PARENT_IMAGE}:${VICE_PARENT_TAG}

ENV CCACHE_DIR=/ccache

ARG VICE_NAME='viceawsmgr'
ARG VICE_VERSION='v0.0.1'
ARG DOCKER_IMAGE=${VICE_NAME}:${VICE_VERSION}

# relative path to our Dockerfile
ARG VICE_DIR="./src/vice/versions/${VICE_VERSION}"

# app specific paths internal to the image
ARG STATIC_ROOT='/var/www/static'

ARG NODE_SOCK='/run/nginx/node-nextjs.socket'
ENV NODE_SOCK=${NODE_SOCK}

# save vars to our environment
# RUN echo "DOCKER_NAME=${VICE_NAME}" > .env
# RUN echo "DOCKER_TAG=${VICE_VERSION}" >> .env
# RUN echo "DOCKER_IMAGE=${DOCKER_IMAGE}" >> .env

## SETUP NVM/NODE
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 21.6.1

    # \
  # && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
#   && . $NVM_DIR/nvm.sh
# RUN --mount=type=cache,target=/ccache . $NVM_DIR/nvm.sh \
#   && nvm install $NODE_VERSION \
#   && nvm alias default $NODE_VERSION \
#   && nvm use default

# Save environment vars for our application
RUN echo "STATIC_ROOT=${STATIC_ROOT}" >> .env
# COPY OUR entrypoint.sh script
COPY ${VICE_DIR}/entrypoint.sh /usr/local/bin/
RUN chmod u+x,g+x /usr/local/bin/entrypoint.sh \
  && ln -s /usr/local/bin/entrypoint.sh / # backwards compat

# supervisord
COPY ${VICE_DIR}/etc/supervisord.conf /etc/supervisord.conf
COPY ${VICE_DIR}/etc/supervisor.d/ /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor


# Nginx stuff
# RUN chown nginx:nginx /run/nginx && chmod 0775 /run/nginx
## !!!!! NEED TO FIX THIS SO OUR SOCKETS CANT WRITE node<->nginx..
## Fix: Move the socket to a better place like /run/node-awsmgr/express.sock

COPY ${VICE_DIR}/etc/nginx/proxy_params /etc/nginx/proxy_params
COPY ${VICE_DIR}/etc/nginx/sites-available/default /etc/nginx/sites-available/.


# # Gunicorn stuff
# RUN addgroup -g 1001 gunicorn \
#     && adduser -u 1001 -G gunicorn -s /bin/sh -D gunicorn
# COPY ${VICE_DIR}/etc/gunicorn/gunicorn-awsmgr.conf.py /etc/gunicorn/awsmgr.conf.py
# # Create directory for gunicorn!
# RUN mkdir -p /run/gunicorn-awsmgr
# RUN chown gunicorn:gunicorn /run/gunicorn-awsmgr
# RUN chmod 0775 /run/gunicorn-awsmgr
# ## let nginx read/write to the gunicorn socket
# RUN addgroup nginx gunicorn

COPY ${VICE_DIR}/etc/gunicorn/gunicorn-awsmgr.conf.py /etc/gunicorn/awsmgr.conf.py

# Create projects directories
RUN mkdir /tmp/wheels
RUN mkdir /tmp/npms
# RUN mkdir /usr/local/src/awsmgr

# Install Python Amazon Manager pacakge
COPY ./src/flask/dist/ /tmp/wheels/.
# Dependency cache mount to /root/.cache/pip!!
RUN --mount=type=cache,target=/root/.cache/pip wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) \
  && echo "wheel_file = $wheel_file" \
  && pip install $wheel_file

# Install NodeJS/NextJS Amazon package (eventually i'd like this to work from a package!)
# COPY ./src/ui/dist/ /tmp/npms/.
# RUN cd /usr/local/src/awsmgr \
#   && npm_pkg=$(ls -tp /tmp/npms/*.tgz | head -n1) \
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
COPY --chown=node:node ./src/ui/ /usr/local/src/awsmgr-ui/
# RUN find /usr/local/src/awsmgr-ui -type d -exec chmod g+w {} + && \
#   find /usr/local/src/awsmgr-ui -type f -executable -exec chmod g+w {} + && \
#   find /usr/local/src/awsmgr-ui -type f ! -executable -exec chmod g+w {} +
# USER node
# RUN --mount=type=cache,target=/root/.npm \
#   cd /usr/local/src/awsmgr-ui \
#   && npm install
# USER root

## we might not need to remove the node_modules, but seems to have issues with arm vs amd.
RUN test -d /usr/local/src/awsmgr-ui/node_modules && rm -rvf /usr/local/src/awsmgr-ui/node_modules && \
  test -f /usr/local/src/awsmgr-ui/package-log.json && rm /usr/local/src/awsmgr-ui/package-log.json && \
  test -f /usr/local/src/awsmgr-ui/.env.local && rm /usr/local/src/awsmgr-ui/.env.local || true

# USER www-data
# RUN --mount=type=cache,target=/root/.npm \
#   cd /usr/local/src/awsmgr-ui \
#   && PATH=/usr/local/bin:/usr/local/bin:/usr/bin:/bin \
#   # && . $NVM_DIR/nvm.sh \
#   && npm install
# USER root

# Create our lower privileged user for ttyd...
RUN groupadd --gid 1000 cyverse && \
  useradd cyverse \
  --comment "" \
  --uid 1000 \
  --gid 1000 \
  --shell /usr/bin/bash \
  --create-home --home-dir /home/cyverse && \
  usermod -aG cyverse www-data && \
  passwd -l cyverse && \
  mkdir -p /usr/local/src/cyverse && \
  chown cyverse:cyverse /usr/local/src/cyverse && \
  chmod 0775 /usr/local/src/cyverse

# TODO: convert this to builder staged in awsmgr image
USER cyverse
RUN cd /usr/local/src/cyverse && \
  git clone https://github.com/tsl0922/ttyd.git && \
  cd ttyd && mkdir build && cd build && \
  cmake .. && make 
USER root
RUN cd /usr/local/src/cyverse/ttyd/build && \
  make install && rm -rvf /usr/local/src/cyverse/ttyd


# END
EXPOSE 80

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]