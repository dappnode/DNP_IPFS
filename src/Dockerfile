ARG UPSTREAM_VERSION

# Create intermediate container for the fs-repo-migrations binary. Use a lightweight alpine image
FROM alpine:3.14.2 as fs-repo-migrations
# copy the migrations binary from the url https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_darwin-arm64.tar.gz
# to the container and extract it
RUN wget https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-amd64.tar.gz && \
    tar -xvf fs-repo-migrations_v2.0.2_linux-amd64.tar.gz && \
    mv fs-repo-migrations/fs-repo-migrations /usr/local/bin/ && \
    rm -rf fs-repo-migrations_v2.0.2_linux-amd64.tar.gz fs-repo-migrations


FROM ipfs/kubo:${UPSTREAM_VERSION}
COPY dappnode_entrypoint.sh /usr/local/bin/
COPY --from=fs-repo-migrations /usr/local/bin/fs-repo-migrations /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/dappnode_entrypoint.sh"]
