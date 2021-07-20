ARG UPSTREAM_VERSION

# Use official ipfs docker image
FROM ipfs/go-ipfs:UPSTREAM_VERSION

# Override entrypoint: https://github.com/ipfs/go-ipfs/blob/0eb50454db566f239df758613c8df16759e1d31f/Dockerfile#L107
COPY ./dappnode_entrypoint.sh /usr/local/bin/dappnode_entrypoint
ENTRYPOINT ["/usr/bin/env"]
CMD [ "/sbin/tini", "--", "/usr/local/bin/entrypoint", "daemon", "--migrate=true" ]