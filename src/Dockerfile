ARG UPSTREAM_VERSION
FROM ipfs/kubo:${UPSTREAM_VERSION}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY configure-ipfs.sh /usr/local/bin/configure-ipfs.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/configure-ipfs.sh


# Override the default entrypoint to use our wrapper script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["daemon","--migrate=true","--agent-version-suffix=docker"]