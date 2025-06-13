#!/bin/sh
set -e

echo "Starting IPFS post-config script..."

CONFIG_COMMANDS="
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '[\"*\"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '[\"PUT\", \"GET\", \"POST\"]'
  ipfs config --json Gateway.PublicGateways '{\"ipfs.dappnode\": { \"NoDNSLink\": false, \"Paths\": [ \"/ipfs\" , \"/ipns\" ], \"UseSubdomains\": false }}'
  ipfs bootstrap add /ip4/65.109.51.31/tcp/4001/p2p/12D3KooWLdrSru7LzYY4YDcfnJsrJeshTQooR2j38NkGvoj2yADp
  ipfs bootstrap add /ip4/167.86.114.131/tcp/4001/p2p/12D3KooWCAx5zWejUDotqc7dcvpvNstM9eZRdtdne1oXZ1DpdLFb
"

until ipfs id >/dev/null 2>&1; do
  echo "Waiting for IPFS daemon to be ready..."
  sleep 2
done

echo "Daemon is ready, applying IPFS config..."

for cmd in "$CONFIG_COMMANDS"; do
  echo "Running: $cmd"
  sh -c "$cmd" || echo "Failed: $cmd (retrying later)"
done

echo "Listing final bootstrap peers:"
ipfs bootstrap list
