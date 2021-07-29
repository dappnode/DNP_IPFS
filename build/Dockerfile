ARG UPSTREAM_VERSION

# Ipfs migration tool
FROM debian:buster-slim as fs-repo-migrations
WORKDIR /usr/src/app
# Update and install deps
RUN apt update && apt install curl -y && apt install tar -y
# Fetch ipfs migration tool
# Dir destin: /usr/src/app/fs-repo-migrations/fs-repo-migrations
# Source: https://dist.ipfs.io/#fs-repo-migrations
RUN if [ "$(arch)" == "x86_64" ]; then  export ARCH="amd64"; else export ARCH="arm64"; fi && curl https://dist.ipfs.io/fs-repo-migrations/v2.0.1/fs-repo-migrations_v2.0.1_linux-${ARCH}.tar.gz -o fs-repo-migrations.tar.gz \
    && tar -zxvf fs-repo-migrations.tar.gz

# Use official ipfs docker image
FROM ipfs/go-ipfs:$UPSTREAM_VERSION

# Copy fs-repo-migrations from previous stage in /usr/local/bin/fs-repo-migrations
COPY --from=fs-repo-migrations /usr/src/app/fs-repo-migrations/fs-repo-migrations /usr/local/bin/fs-repo-migrations

# Override entrypoint: https://github.com/ipfs/go-ipfs/blob/0eb50454db566f239df758613c8df16759e1d31f/Dockerfile#L107
COPY ./dappnode_entrypoint.sh /usr/local/bin/dappnode_entrypoint

# Scripts executable
RUN chmod +x /usr/local/bin/dappnode_entrypoint

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/dappnode_entrypoint" ]
CMD [ "daemon", "--migrate=true" ]
