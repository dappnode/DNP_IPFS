# Create intermediate container for the fs-repo-migrations binary. Use a lightweight alpine image
FROM alpine:3.14.2 as fs-repo-migrations

# Copy the download migration script
COPY download_migration.sh /tmp/
RUN /tmp/download_migration.sh

ARG UPSTREAM_VERSION
FROM ipfs/kubo:${UPSTREAM_VERSION}
COPY dappnode_entrypoint.sh /usr/local/bin/
COPY --from=fs-repo-migrations /usr/local/bin/fs-repo-migrations /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/dappnode_entrypoint.sh"]
