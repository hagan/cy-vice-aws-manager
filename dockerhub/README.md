# hagan/pynode:alpine-3.19

Use this to generate a base image to upload into docker hub to generate project images from.
i.e.
```
  docker build -t hagan/pynode:alpine3-19 image . --no-cache=true --platform=linux/amd64
  docker build -t hagan/pynode:alpine3-19 image . --no-cache=true --platform=linux/arm64
  docker push hagan/pynode:alpine-3.19
```
