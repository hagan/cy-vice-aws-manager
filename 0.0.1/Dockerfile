# Dockerfile.vice_python_base
# src: https://github.com/docker-library/python/blob/35d09c044857f7aef2bf24791027f3e3fe2c34dd/3.11/alpine3.18/Dockerfile
FROM python:3.11-alpine
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

# build-essential(debian) / alpine-sdk(alpine)
RUN apk update \
    && apk add --no-cache \
        util-linux \
        supervisor \
        bash \
        ttyd \
        nginx \
        rsyslog \
        curl \
        vim \
        alpine-sdk \ 
        procps
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache \
    python3 \
    python3-dev \
    && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools


# Create a directory to store PID files and run directories
# RUN rc-update add rsyslog default \
#   &&  mkdir /run/openrc \
#   && touch /run/openrc/softlevel

# Set up OpenRC
# RUN rc-update add devfs default
# RUN rc-update add nginx default
# RUN rc-update add rsyslog default
# RUN mkdir /run/openrc && touch /run/openrc/softlevel

COPY ${DOCKER_DIR}/entrypoint.sh /usr/local/bin/
RUN chmod u+x,g+x /usr/local/bin/entrypoint.sh \
  && ln -s /usr/local/bin/entrypoint.sh / # backwards compat

# setup gunicorn
RUN mkdir /run/gunicorn-awsmgr
RUN mkdir /tmp/wheels
RUN mkdir ${STATIC_ROOT}
RUN mkdir /usr/src/awsmgr

# COPY ${BASE_DOCKER_DIR}/gunicorn/gunicorn-helloworld.conf.py /etc/gunicorn/helloworld.conf.py
# COPY ${BASE_DOCKER_DIR}/gunicorn/helloworld_app.py /usr/src/helloworld/app.py
# COPY ${BASE_DOCKER_DIR}/gunicorn/gunicorn-helloworld /etc/init.d/gunicorn-helloworld

# RUN chmod u+x,g+x /etc/init.d/gunicorn-helloworld && rc-update add gunicorn-helloworld default

WORKDIR /usr/src/awsmgr

EXPOSE 80

# COPY ${BASE_DOCKER_DIR}/requirements-base.txt ./
# RUN pip install --no-cache-dir -r requirements-base.txt

RUN apk update && apk upgrade

# supervisord
COPY ${DOCKER_DIR}/etc/supervisord.conf /etc/supervisord.conf
COPY ${DOCKER_DIR}/etc/supervisor.d/ /etc/supervisor.d/
# nginx
COPY ${DOCKER_DIR}/etc/nginx/proxy_params /etc/nginx/proxy_params
COPY ${DOCKER_DIR}/etc/nginx/http.d/ /etc/nginx/http.d/
# gunicorn
COPY ${DOCKER_DIR}/etc/gunicorn/gunicorn-awsmgr.conf.py /etc/gunicorn/awsmgr.conf.py

# Create directory for gunicorn!
RUN mkdir -p /run/gunicorn-awsmgr
RUN chown nginx:www-data /run/gunicorn-awsmgr
RUN chmod g+rw /run/gunicorn-awsmgr

# Create directory and logs for supervisord
RUN mkdir -p /var/log/supervisor
RUN touch /var/log/gunicorn.log
RUN chown nginx:www-data /var/log/gunicorn.log
RUN chmod g+rw /var/log/gunicorn.log


## Using untracked dist (must manually add after updates)
COPY ${DOCKER_DIR}/dist/ /tmp/wheels/.
## maybe do a compile from source option?
# ....

# COPY ${DOCKER_DIR}/wheels/${PIP_WHEEL_FILENAME} /tmp/wheels/.
# RUN pip install /tmp/wheels/${PIP_WHEEL_FILENAME}
# RUN flask collectstatic --no-input
# ls -1t dist/*.whl | head -n 1
RUN $wheel_file=$(find /tmp/wheels -type f -name "*.whl" -printf '%T+ %p\n' | sort -r | awk '{ $1=""; print substr($0,2) }') && pip install $wheel_file

# COPY . .

# CMD [ "python", "./your-daemon-or-script.py" ]

# CMD [ "openrc", "default" ]
# CMD tail -f /dev/null

# CMD bash
## A neat trick to keep this docker instance running..
# CMD tail -f /dev/null

## Add our "normal" cyverse user
RUN adduser -D cyverse
RUN passwd -u cyverse

# COPY ${DOCKER_DIR}/cyverse_sudo  /etc/sudoers.d/cyverse_sudo
# RUN chmod 0440 /etc/sudoers.d/cyverse_sudo

ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]