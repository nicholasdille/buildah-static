FROM golang:1.16-alpine3.14 AS base
RUN apk add --update-cache --no-cache \
        git \
        make \
        gcc \
        pkgconf \
        musl-dev \
        btrfs-progs \
        btrfs-progs-dev \
        libassuan-dev \
        lvm2-dev \
        device-mapper \
        glib-static \
        libc-dev \
        gpgme-dev \
        protobuf-dev \
        protobuf-c-dev \
        libseccomp-dev \
        libseccomp-static \
        libselinux-dev \
        ostree-dev \
        openssl \
        iptables \
        bash \
        go-md2man

FROM base AS buildah
# renovate: datasource=github-releases depName=containers/buildah
ARG BUILDAH_VERSION=1.23.1
ARG BUILDAH_BUILDTAGS='seccomp apparmor exclude_graphdriver_devicemapper'
WORKDIR $GOPATH/src/github.com/containers/buildah
RUN test -n "${BUILDAH_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${BUILDAH_VERSION}" \
        https://github.com/containers/buildah .
ENV CGO_ENABLED=1
RUN make bin/buildah EXTRA_LDFLAGS="-s -w -extldflags '-static'" BUILDTAGS='${BUILDAH_BUILDTAGS}' \
 && mv bin/buildah /usr/local/bin/buildah
