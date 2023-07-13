#!/bin/sh

ARCHITECTURE=""
ARCH_URL=""

case $(uname -m) in
    "x86_64") ARCHITECTURE="amd64";;
    "i686") ARCHITECTURE="386";;
    "aarch64") ARCHITECTURE="arm64";;
    "armv7l") ARCHITECTURE="arm";;
    *)
        echo "Unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

ARCH_URL="https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-${ARCHITECTURE}.tar.gz"

echo "Architecture: ${ARCHITECTURE}"
echo "Downloading from URL: ${ARCH_URL}"

wget "${ARCH_URL}" && \
    tar -xvf "fs-repo-migrations_v2.0.2_linux-${ARCHITECTURE}.tar.gz" && \
    mv fs-repo-migrations/fs-repo-migrations /usr/local/bin/ && \
    rm -rf "fs-repo-migrations_v2.0.2_linux-${ARCHITECTURE}.tar.gz" fs-repo-migrations
