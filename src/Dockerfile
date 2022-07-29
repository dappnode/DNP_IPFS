ARG UPSTREAM_VERSION
FROM ipfs/go-ipfs:${UPSTREAM_VERSION}
COPY dappnode_entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/dappnode_entrypoint.sh"]