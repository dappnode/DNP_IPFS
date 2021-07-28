#!/bin/bash

# This script will test the IPFS file system migration
# It will migrate volumes from an older IPFS version (e.g v0.6.0)
# to newer ones (e.g v0.9.1)

# VERSIONS TABLE: https://github.com/ipfs/fs-repo-migrations

# |     go-ipfs     | ipfs-repo  | DNP_IPFS |
# -------------------------------------------
# |  0.6.0 - 0.7.0  |    10      |  v0.2.14 |
# | 0.8.0 - current |    11      |  v0.2.15 |

# 1. Start container with older image to create old volumes
docker-compose build --build-arg UPSTREAM_VERSION=v0.6.0
docker-compose -f docker-compose.yml up -d
docker-compose down

# 2. Start container with newer image to migrate old volumes
docker-compose build --build-arg UPSTREAM_VERSION=v0.9.1
docker-compose -f docker-compose.yml up -d
docker-compose down
