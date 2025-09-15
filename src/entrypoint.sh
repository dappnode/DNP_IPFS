#!/bin/sh
set -e

user=ipfs
repo="$IPFS_PATH"

echo "Starting IPFS entrypoint script"

if [ "$(id -u)" -eq 0 ]; then
  echo "Changing user to $user"
  # ensure folder is writable
  gosu "$user" test -w "$repo" || chown -R -- "$user" "$repo"
  # restart script with new privileges
  exec gosu "$user" "$0" "$@"
fi

echo "Running as user: $(id -un)"

# 2nd invocation with regular user
ipfs version

if [ -e "$repo/config" ]; then
  echo "Found IPFS fs-repo at $repo"
else
  # Set Config options before starting the daemon
  ipfs init ${IPFS_PROFILE:+"--profile=$IPFS_PROFILE"}
  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST"]'
  ipfs config --json Gateway.PublicGateways "{\"ipfs.dappnode\": { \"NoDNSLink\": false, \"Paths\": [ \"/ipfs\" , \"/ipns\" ], \"UseSubdomains\": false }}"

  # Set up the swarm key, if provided

  SWARM_KEY_FILE="$repo/swarm.key"
  SWARM_KEY_PERM=0400

  # Create a swarm key from a given environment variable
  if [ -n "$IPFS_SWARM_KEY" ] ; then
    echo "Copying swarm key from variable..."
    printf "%s\n" "$IPFS_SWARM_KEY" >"$SWARM_KEY_FILE" || exit 1
    chmod $SWARM_KEY_PERM "$SWARM_KEY_FILE"
  fi

  # Unset the swarm key variable
  unset IPFS_SWARM_KEY

  # Check during initialization if a swarm key was provided and
  # copy it to the ipfs directory with the right permissions
  # WARNING: This will replace the swarm key if it exists
  if [ -n "$IPFS_SWARM_KEY_FILE" ] ; then
    echo "Copying swarm key from file..."
    install -m $SWARM_KEY_PERM "$IPFS_SWARM_KEY_FILE" "$SWARM_KEY_FILE" || exit 1
  fi

  # Unset the swarm key file variable
  unset IPFS_SWARM_KEY_FILE
fi

# Start ipfs config script in background
configure-ipfs.sh &

find /container-init.d -maxdepth 1 -type f -iname '*.sh' -print0 | sort -z | xargs -n 1 -0 -r container_init_run

exec ipfs "$@"