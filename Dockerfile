FROM ubuntu:22.04@sha256:26c68657ccce2cb0a31b330cb0be2b5e108d467f641c62e13ab40cbec258c68d AS clone
# renovate: datasource=github-releases depName=containers/buildah
ARG BUILDAH_VERSION=1.24.2
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        git \
        ca-certificates
WORKDIR /tmp/buildah
RUN test -n "${BUILDAH_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${BUILDAH_VERSION}" \
        https://github.com/containers/buildah .

FROM nixos/nix:2.7.0 AS binaries
COPY --from=clone /tmp/buildah /tmp/buildah
WORKDIR /tmp/buildah
RUN nix build -f nix --extra-experimental-features nix-command \
 && cp -rfp ./result/bin/buildah /usr/local/bin/

FROM alpine:3.15 AS manpages
RUN apk add --update-cache --no-cache \
        make \
        go-md2man
COPY --from=clone /tmp/buildah /tmp/buildah
WORKDIR /tmp/buildah
RUN mkdir -p /usr/local/share/man/man1 \
 && make -C docs GOMD2MAN=go-md2man \
 && cp docs/*.1 /usr/local/share/man/man1

FROM scratch AS local
COPY --from=binaries /usr/local/bin/buildah ./bin/
COPY --from=manpages /usr/local/share/man ./share/man/
