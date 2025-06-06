ARG UPSTREAM_VERSION

# Create intermediate container for the fs-repo-migrations binary. Use a lightweight alpine image
FROM alpine:3.14.2 as fs-repo-migrations
# copy the migrations binary from the url https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_darwin-arm64.tar.gz
# to the container and extract it
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "WARN: Unsupported architecture: $ARCH, falling back to amd64..." && \
        ARCH="amd64"; \
    fi && \
    echo "Using architecture: $ARCH" && \
    wget https://dist.ipfs.tech/fs-repo-migrations/v2.0.2/fs-repo-migrations_v2.0.2_linux-$ARCH.tar.gz && \
    tar -xvf fs-repo-migrations_v2.0.2_linux-$ARCH.tar.gz && \
    mv fs-repo-migrations/fs-repo-migrations /usr/local/bin/ && \
    rm -rf fs-repo-migrations_v2.0.2_linux-$ARCH.tar.gz fs-repo-migrations

FROM ipfs/kubo:${UPSTREAM_VERSION}

# Copy the fs-repo-migrations binary from the intermediate container
COPY --from=fs-repo-migrations /usr/local/bin/fs-repo-migrations /usr/local/bin/fs-repo-migrations

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Override the default entrypoint to use our wrapper script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["daemon","--migrate=true","--agent-version-suffix=docker"]