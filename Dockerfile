FROM nixos/nix:2.7.0 AS buildah
RUN apk add --update-cache --no-cache \
        make \
        go-md2man
# renovate: datasource=github-releases depName=containers/buildah
ARG BUILDAH_VERSION=1.24.2
ARG BUILDAH_BUILDTAGS='seccomp apparmor exclude_graphdriver_devicemapper'
WORKDIR $GOPATH/src/github.com/containers/buildah
RUN test -n "${BUILDAH_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${BUILDAH_VERSION}" \
        https://github.com/containers/buildah .
RUN mkdir -p /usr/local/share/man/man1 \
 && nix build -f nix \
 && make -C docs GOMD2MAN=go-md2man \
 && cp -rfp ./result/bin/buildah /usr/local/bin/ \
 && cp docs/*.1 /usr/local/share/man/man1

FROM scratch AS local
COPY --from=buildah /usr/local/bin/buildah ./bin/
COPY --from=buildah /usr/local/share/man ./share/man/
