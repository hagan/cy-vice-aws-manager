# Dockerfile.vice_python_base
# src: https://github.com/docker-library/python/blob/35d09c044857f7aef2bf24791027f3e3fe2c34dd/3.11/alpine3.18/Dockerfile
FROM hagan/pynode:alpine3.19

ARG DOCKER_NAME='viceamazonmgr'
ARG DOCKER_TAG='0.0.1'
ARG DOCKER_IMAGE=${DOCKER_NAME}:${DOCKER_TAG}

# relative path to our Dockerfile
ARG DOCKER_DIR='./src/vice/${DOCKER_TAG}'

# app specific paths internal to the image
ARG STATIC_ROOT='/var/www/static'

# save vars to our environment
RUN echo "DOCKER_NAME=${DOCKER_NAME}" > .env
RUN echo "DOCKER_TAG=${DOCKER_TAG}" >> .env
RUN echo "DOCKER_IMAGE=${DOCKER_IMAGE}" >> .env

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

# Build notes: re2/re2-dev/libffi/libffi-dev & openssl-dev required by grpcio
# which is required by our flask app.
# libffi-dev already installed
# WORKS TO HERE
RUN apk update \
  && apk add --no-cache \
    supervisor \
    build-base \
    re2 \
    re2-dev \
    libffi \
    libffi-dev \
    openssl-dev \
    python3-dev

# Install projects
RUN mkdir /tmp/wheels
RUN mkdir /tmp/npms

# Python updates
RUN pip install --upgrade pip

COPY ${DOCKER_DIR}/dist/flask/ /tmp/wheels/.
# Dependency cache mount to /root/.cache/pip!!
RUN --mount=type=cache,target=/root/.cache/pip wheel_file=$(ls -tp /tmp/wheels/*.whl | head -n1) && echo "wheel_file = $wheel_file" && pip install $wheel_file

COPY ${DOCKER_DIR}/dist/ui/ /tmp/npms/.

RUN ls /tmp/npms/

# END
EXPOSE 80
RUN mkdir /usr/src/awsmgr
WORKDIR /usr/src/awsmgr
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]