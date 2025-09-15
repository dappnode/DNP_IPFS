#!/bin/sh
set -e

echo "Starting IPFS post-config script..."

# List of config commands, one per line
CONFIG_COMMANDS='
ipfs bootstrap add /ip4/65.109.51.31/tcp/4001/p2p/12D3KooWLdrSru7LzYY4YDcfnJsrJeshTQooR2j38NkGvoj2yADp
ipfs bootstrap add /ip4/167.86.114.131/tcp/4001/p2p/12D3KooWCAx5zWejUDotqc7dcvpvNstM9eZRdtdne1oXZ1DpdLFb
ipfs swarm connect /ip4/65.109.51.31/tcp/4001/p2p/12D3KooWLdrSru7LzYY4YDcfnJsrJeshTQooR2j38NkGvoj2yADp
ipfs swarm connect /ip4/167.86.114.131/tcp/4001/p2p/12D3KooWCAx5zWejUDotqc7dcvpvNstM9eZRdtdne1oXZ1DpdLFb
'

# Wait for IPFS daemon to be ready, without locking ipfs.repo
until ipfs --api=/ip4/127.0.0.1/tcp/5001 id >/dev/null 2>&1; do
  echo "Waiting for IPFS daemon to be ready..."
  sleep 2
done


echo "Daemon is ready, applying IPFS config..."

# Run each config command, retrying until success
echo "$CONFIG_COMMANDS" | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue  # skip empty lines
  echo "Running: $cmd"
  until sh -c "$cmd"; do
    echo "Retrying: $cmd"
    sleep 2
  done
done

echo "Final bootstrap list:"
ipfs bootstrap list
