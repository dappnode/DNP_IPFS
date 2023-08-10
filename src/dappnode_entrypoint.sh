#!/bin/sh

# This is a copy of the original_entrypoint.sh script

set -e

# IPFS_PATH=/data/ipfs
repo="$IPFS_PATH"

fs-repo-migrations -y

# 2nd invocation with regular user
ipfs version

# ipfs init will create the config file /data/ipfs/config
if [ -e "$repo/config" ]; then
    echo "Found IPFS fs-repo at $repo"
else
    ipfs init
fi

# Check profile set
if [ "$PROFILE" != "custom" ] && [ "$PROFILE" != "none" ]; then
    # Regular profile in ipfs: https://docs.ipfs.io/how-to/configure-node/#profiles
    ipfs config profile apply $PROFILE
elif [ "$PROFILE" == "none" ]; then
    # Custom profile created by dappnode
    ipfs config Routing.Type none
else
    # None profile created by dappnode
    ipfs config Routing.Type "${ROUTING}"
    ipfs config --json Discovery.MDNS.Enabled ${DISCOVERY_MDNS_ENABLED}
    ipfs config --json Swarm.DisableNatPortMap ${SWARM_DISABLENATPORTMAP}
    ipfs config --json Reprovider.Interval "\"${REPROVIDER_INTERVAL}\""
    ipfs config --json Swarm.ConnMgr.LowWater "${SWARM_CONNMGR_LOWWATER}"
    ipfs config --json Swarm.ConnMgr.HighWater "${SWARM_CONNMGR_HIGHWATER}"
    ipfs config --json Swarm.ConnMgr.GracePeriod "\"${SWARM_CONNMGR_GRACEPERIOD}\""
fi

ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
# More networking configuration from dappnode
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST"]'
ipfs config --json Datastore.StorageMax "\"$DATASTORE_STORAGEMAX\""
ipfs config --json Datastore.StorageMax "\"$DATASTORE_STORAGEMAX\""

## Provides origin isolation between content roots: https://github.com/ipfs/kubo/blob/master/docs/config.md#gatewaypublicgateways-usesubdomains
ipfs config --json Gateway.PublicGateways '{"ipfs.dappnode": { "NoDNSLink": false, "Paths": [ "/ipfs" , "/ipns" ], "UseSubdomains": true }}'

# Possible values for EXTRA_OPTS (must have --): https://docs.ipfs.io/reference/cli/#ipfs-daemon
# Join arguments with EXTRA_OPTS if var not empty.
if [ ! -z $EXTRA_OPTS ]; then
    set -- "$@" "$EXTRA_OPTS"
fi

# Execute the daemon subcommand by default
exec /sbin/tini -- /usr/local/bin/start_ipfs daemon --migrate=true --agent-version-suffix=docker "$@"
