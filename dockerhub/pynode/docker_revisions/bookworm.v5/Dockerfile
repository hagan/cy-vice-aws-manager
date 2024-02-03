#syntax=bergkvist/includeimage

## Note this only supports amd64 according to github:bergkvist/includeimage
## eventually look into this: https://nix.dev/tutorials/nixos/building-and-running-docker-images

ARG PYNODE_PARENT_IMAGE=debian
ARG PYNODE_PARENT_TAG=bookworm

FROM ${PYNODE_PARENT_IMAGE}:${PYNODE_PARENT_TAG}

INCLUDE node:21.6.1-bookworm
INCLUDE python:3.11.7-bookworm
INCLUDE golang:1.21.6-bookworm