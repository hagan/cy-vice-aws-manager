# dockerhub images

This directory (dockerhub) contains two docker images that can be built and uploaded to hub.docker.io to speed up compile time

Use this to generate a base image to upload into docker hub to generate project images from.
i.e.
```
  # pynode : the base image combining python 3.11 & node into one module
  # You must build both platforms and push to hub.docker.com (amd & arm)
  ## step one : Start Docker desktop if using it!

  ## Build pynode and upload
  cd .pynode/latest
  docker buildx create --name mybuilder --use
  docker buildx inspect --bootstrap
  docker login

  # NOTE: Update PYNODE_VERSION if we change anything in Dockerfile
  PYNODE_VERSION=alpine3-19v2 && docker buildx build --platform linux/amd64,linux/arm64 -t hagan/pynode:${PYNODE_VERSION} --push .

  # Note: Update AWSMGR_VERSION if anything changed in Dockerfile (and update Dockerfile if source image changed above)
  ## todo: update so we use build-arg and that's easier
  AWSMGR_VERSION=v0.0.2 && docker buildx build --platform linux/amd64,linux/arm64 -t hagan/awsmgr:${AWSMGR_VERSION} --push .
```
