
## THIS IS SOURCED FROM : https://github.com/pulumi/pulumi-docker-containers/blob/main/docker/pulumi/Dockerfile

## used to build an executable "pulumi".. This needs refactoring, >1.5Gb added to image

ARG PULUMI_PARENT_IMAGE=debian
ARG PULUMI_PARENT_TAG=bookworm

FROM ${PULUMI_PARENT_IMAGE}:${PULUMI_PARENT_TAG}

ARG PULUMI_PARENT_IMAGE=debian
ENV PULUMI_PARENT_IMAGE=${PULUMI_PARENT_IMAGE}

ARG PULUMI_PARENT_TAG=bookworm
ENV PULUMI_PARENT_TAG=${PULUMI_PARENT_TAG}

ARG PULUMI_NAME='pynode'
ARG PULUMI_TAG='latest'
ARG DOCKER_IMAGE=${PULUMI_NAME}:${PULUMI_TAG}
ENV DOCKER_IMAGE=${DOCKER_IMAGE}

ARG CACHEBUST=1

# ENV GOLANG_VERSION 1.21.6

ENV NODE_MAJOR=21

## Notes: Removing Java, Dotnet, Helm & Go stuff

# Install Java
# RUN apt-get update -y && \
#   apt-get install -y --no-install-recommends \
#       gradle \
#       maven

# Install dotnet 6.0 using instructions from:
# https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
# RUN curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- -channel 6.0 -InstallDir /usr/share/dotnet
# ENV PATH "/usr/share/dotnet:/pulumi/bin:${PATH}"
# ENV DOTNET_ROOT /usr/share/dotnet
# ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
# # Allow newer dotnet version (e.g. 6) to build projects targeting older frameworks (v3.1)
# ENV DOTNET_ROLL_FORWARD Major

# Install Helm (kubernetes package manager)
# Explicitly set env variables that helm reads to their defaults, so that subsequent calls to
# helm will find the stable repo even if $HOME points to something other than /root
# (e.g. in GitHub actions where $HOME points to /github/home).
# ENV XDG_CONFIG_HOME=/root/.config
# ENV XDG_CACHE_HOME=/root/.cache
# RUN curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
#   helm repo add stable https://charts.helm.sh/stable && \
#   helm repo update

# Passing --build-arg PULUMI_VERSION=vX.Y.Z will use that version
# of the SDK. Otherwise, we use whatever get.pulumi.com thinks is
# the latest 3.107.0
ARG PULUMI_VERSION

# Install the Pulumi SDK, including the CLI and language runtimes.
RUN curl -fsSL https://get.pulumi.com/ | bash -s -- --version $PULUMI_VERSION && \
  mv ~/.pulumi/bin/* /usr/bin

# https://github.com/pulumi/pulumictl/releases
ENV PULUMICTL_VERSION 0.0.32
# https://github.com/golangci/golangci-lint/releases
# ENV GOLANGCI_LINT_VERSION 1.49.0
# https://github.com/goreleaser/goreleaser/releases
# ENV GORELEASER_VERSION 1.11.4

RUN curl \
    --proto "=https" \
    --tlsv1.2 \
    --location \
    --fail \
    --verbose \
    --output "pulumictl.tar.gz" \
    "https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-linux-amd64.tar.gz" && \
    mkdir pulumictl_extraction && \
    tar --extract --gunzip --verbose --directory pulumictl_extraction --file pulumictl.tar.gz && \
    mv pulumictl_extraction/pulumictl /usr/local/bin/pulumictl && \
    chmod a+x /usr/local/bin/pulumictl && \
    rm -Rf pulumictl_extraction && \
    rm pulumictl.tar.gz 
    #&& \
    # # Install golangci-lint
    # curl --proto "=https" \
    # --tlsv1.2 \
    # --silent \
    # --show-error \
    # --fail \
    # --location \
    # https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    # | sh -s -- -b "$(go env GOPATH)/bin" "v${GOLANGCI_LINT_VERSION}" && \
    # # Install goreleaser
    # curl \
    # --proto "=https" \
    # --tlsv1.2 \
    # --location \
    # --fail \
    # --verbose \
    # --output "goreleaser.tar.gz" \
    # "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz" && \
    # mkdir goreleaser_extraction && \
    # tar --extract --gunzip --verbose --directory goreleaser_extraction --file goreleaser.tar.gz && \
    # mv goreleaser_extraction/goreleaser /usr/local/bin/goreleaser && \
    # chmod a+x /usr/local/bin/goreleaser && \
    # rm -Rf goreleaser_extraction && \
    # rm goreleaser.tar.gz

RUN \
    echo "Parent image name: ${PULUMI_PARENT_IMAGE}:${PULUMI_PARENT_TAG}" > /etc/docker-image-ver \
  && echo "Docker image name: ${DOCKER_IMAGE}" >> /etc/docker-image-ver \
  && echo "       built date: $(date '+%A %W %Y %X')" >> /etc/docker-image-ver