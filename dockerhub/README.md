# dockerhub images

This directory (dockerhub) contains two docker images that can be built and uploaded to hub.docker.io to speed up compile time

Use this to generate a base image to upload into docker hub to generate project images from.
i.e.
```
  # pynode : the base image combining python 3.11 & node into one module
  # You must build both platforms and push to hub.docker.com (amd & arm)
  ## step one : Start Docker desktop if using it!

  # Setup our builder environment
  docker buildx create --name mybuilder --use
  docker buildx inspect --bootstrap
  docker login

  # Setup our environment vars
  export PYNODE_VERSION=alpine3.19v2
  export AWSMGR_VERSION=v0.0.2 \
  export PULUMI_VERSION=v0.0.1

  ## Build pynode and upload
  cd [vice project root]/dockerhub/pynode/latest

  ## for local amd64 testing
  docker build --label pynode --platform linux/amd64 -t hagan/pynode:${PYNODE_VERSION} .
  docker run --rm -it hagan/pynode:${PYNODE_VERSION} bash

  # TODO: This took 3 hours, 40 minutes on a 16 core cpu. need to look into ccache!
  [ "x${PYNODE_VERSION}" != "x" ] && docker buildx build --label pynode --platform linux/amd64,linux/arm64 -t hagan/pynode:${PYNODE_VERSION} --push . || echo "PYNODE_VERSION is unset"
  docker buildx push --platform linux/amd64,linux/arm64 -t hagan/pulumi:${PYNODE_VERSION}

  cd [vice project root]/dockerhub/pulumi/latest
  ## for local amd64 testing
  docker build --label pulumi --platform linux/amd64 -t hagan/pulumi:${PULUMI_VERSION} .
  docker run --rm -it hagan/pulumi:${PULUMI_VERSION} bash
  ## builderx (arm64/amd64)
  docker buildx build --label pulumi --platform linux/amd64,linux/arm64 -t hagan/pulumi:${PULUMI_VERSION} --push .
  
  ## Build awsmgr for our project
  cd [vice project root]/dockerhub/awsmgr/latest
  docker build --label awsmgr --platform linux/amd64 -t hagan/awsmgr:${AWSMGR_VERSION} .
  docker run --rm -it hagan/awsmgr:${AWSMGR_VERSION} /bin/bash

  docker buildx build \
    --build-arg AWSMGR_PARENT_IMAGE=hagan/pulumi \
    --build-arg AWSMGR_PARENT_TAG=${PULUMI_VERSION} \
    --platform linux/amd64,linux/arm64 -t hagan/awsmgr:${AWSMGR_VERSION} --push .

  # Note: Update AWSMGR_VERSION if anything changed in Dockerfile (and update Dockerfile if source image changed above)
  ## todo: update so we use build-arg and that's easier
  docker buildx build --build-arg PYNODE_VERSION=${PYNODE_VERSION} --platform linux/amd64,linux/arm64 -t hagan/awsmgr:${AWSMGR_VERSION} --push .
```

### TODOs

Need to integrate ccache to speedup compile time.. over ~2 hours for the base image