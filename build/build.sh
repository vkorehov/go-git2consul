#!/bin/sh
set -x
set -e

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export BUILDPATH=${GOPATH}/src/github.com/vkorehov/go-git2consul
export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/local/lib/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/tmp/libgit2/install/lib/pkgconfig:/tmp/openssl/install/lib/pkgconfig:/tmp/libssh2/build/src"

FLAGS=$(pkg-config --static --libs --cflags libssh2 libgit2) || exit 1
export CGO_LDFLAGS="/tmp/libgit2/build/libgit2.a /tmp/openssl/libcrypto.a /tmp/openssl/libssl.a /tmp/libssh2/build/src/libssh2.a -L/tmp/libgit2/build ${FLAGS}"
export CGO_CFLAGS="-I/tmp/libgit2/include"

# Get git commit information
GIT_COMMIT=$(git rev-parse HEAD)
GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)

# Build git2consul
cd ${BUILDPATH}
go get -v -d
GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -v -linkmode=external -extldflags '-static'" -o /build/bin/git2consul.linux.amd64 .
# GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -o /build/bin/git2consul.darwin.amd64 .
