#!/bin/sh

case $(uname -m) in
    "x86_64") ARCHITECTURE=amd64; export ARCHITECTURE; ARCH_URL="https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-amd64.tar.gz"; export ARCH_URL;;
    "i686") ARCHITECTURE=386; export ARCHITECTURE; ARCH_URL="https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-386.tar.gz"; export ARCH_URL;;
    "aarch64") ARCHITECTURE=arm64; export ARCHITECTURE; ARCH_URL="https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-arm64.tar.gz"; export ARCH_URL;;
    "armv7l") ARCHITECTURE=arm; export ARCHITECTURE; ARCH_URL="https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-arm.tar.gz"; export ARCH_URL;;
    *) echo "Unsupported architecture: $(uname -m)" && exit 1;;
esac

echo "Architecture: ${ARCHITECTURE}"
echo "Downloading from URL: ${ARCH_URL}"

wget ${ARCH_URL} && \
    tar -xvf "fs-repo-migrations_v2.0.2_linux-${ARCHITECTURE}.tar.gz" && \
    mv fs-repo-migrations/fs-repo-migrations /usr/local/bin/ && \
    rm -rf "fs-repo-migrations_v2.0.2_linux-${ARCHITECTURE}.tar.gz" fs-repo-migrations
