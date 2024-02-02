#syntax=bergkvist/includeimage

## Note this only supports amd64 according to github:bergkvist/includeimage
## eventually look into this: https://nix.dev/tutorials/nixos/building-and-running-docker-images

ARG PYNODE_PARENT_IMAGE=alpine
ARG PYNODE_PARENT_TAG=3.18

FROM ${PYNODE_PARENT_IMAGE}:${PYNODE_PARENT_TAG}

INCLUDE node:21.6.1-alpine3.18
INCLUDE python:3.11.7-alpine3.18
INCLUDE golang:1.21.6-alpine3.18
