#!/bin/bash
set -e

# This script will test the IPFS file system migration
# It will migrate volumes from an older IPFS version (e.g v0.6.0)
# to newer ones (e.g v0.9.1)

# VERSIONS TABLE: https://github.com/ipfs/fs-repo-migrations

# |     go-ipfs     | ipfs-repo  | DNP_IPFS |
# -------------------------------------------
# |  0.6.0 - 0.7.0  |    10      |  v0.2.14 |
# | 0.8.0 - current |    11      |  v0.2.15 |

# Envs:
IPFS_OLD=v0.6.0
IPFS_NEW=v0.9.1

# 0. Set-up
echo -e "\e[32m [INFO] Creating dncore_network if needed...\e[0m"
docker network create --driver bridge --subnet 172.33.0.0/16 dncore_network

# 1. Start container with older image to create old volumes
echo -e "\e[32m [INFO] Build old ipfs ${IPFS_OLD}\e[0m"
docker-compose build --build-arg UPSTREAM_VERSION=${IPFS_OLD}
docker-compose -f docker-compose.yml up -d
sleep 10
docker-compose down

# 2. Start container with newer image to migrate old volumes
echo -e "\e[32m [INFO] Build new ipfs ${IPFS_NEW}\e[0m"
docker-compose build --build-arg UPSTREAM_VERSION=${IPFS_NEW}
docker-compose -f docker-compose.yml up -d
sleep 10

echo -e "\e[32m [INFO] Check logs for migration\e[0m"
docker logs DAppNodeCore-ipfs-dnp.dappnode.eth
docker-compose down
