# hagan/awsmgr:v0.0.1

Use this to generate a base image to upload into docker hub to generate project images from.
i.e.
```
  # build both platforms and push to hub.docker.com
  docker buildx create --name mybuilder --use
  docker buildx inspect --bootstrap
  docker login
  docker buildx build --platform linux/amd64,linux/arm64 -t hagan/awsmgr:v0.0.1 --push .
```
