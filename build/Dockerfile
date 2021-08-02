FROM golang:1.15-buster

ENV SRC_DIR /go-ipfs

ARG UPSTREAM_VERSION

# Install deps
RUN apt-get update && apt-get install -y \
  libssl-dev \
  ca-certificates \
  fuse

# Preload an in-tree but disabled-by-default plugin by adding it to the IPFS_PLUGINS variable
# e.g. docker build --build-arg IPFS_PLUGINS="foo bar baz"
ARG IPFS_PLUGINS

RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  "amd64" | "arm64") true ;;\
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  mkdir -p ${SRC_DIR} \
  && cd $SRC_DIR \
  && wget https://github.com/ipfs/go-ipfs/releases/download/${UPSTREAM_VERSION}/go-ipfs_${UPSTREAM_VERSION}_linux-${dpkgArch}.tar.gz -O $SRC_DIR/go-ipfs_${UPSTREAM_VERSION}_linux-${dpkgArch}.tar.gz \
  && tar -xzvf go-ipfs_${UPSTREAM_VERSION}_linux-${dpkgArch}.tar.gz

# Get su-exec, a very minimal tool for dropping privileges,
# and tini, a very minimal init daemon for containers
ENV SUEXEC_VERSION v0.2
ENV TINI_VERSION v0.19.0
RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  "amd64" | "arm64") tiniArch="tini-$dpkgArch" ;;\
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  cd /tmp \
  && git clone https://github.com/ncopa/su-exec.git \
  && cd su-exec \
  && git checkout -q $SUEXEC_VERSION \
  && make su-exec-static \
  && cd /tmp \
  && wget -q -O tini https://github.com/krallin/tini/releases/download/$TINI_VERSION/$tiniArch \
  && chmod +x tini

COPY dappnode_entrypoint.sh $SRC_DIR/bin/dappnode_entrypoint

# Ipfs migration tool
FROM golang:1.15-buster as fs-repo-migrations
WORKDIR /usr/src/app
# Update and install deps
RUN apt update && apt install curl -y && apt install tar -y
# Fetch ipfs migration tool
# Dir destin: /usr/src/app/fs-repo-migrations/fs-repo-migrations
# Source: https://dist.ipfs.io/#fs-repo-migrations
RUN curl https://dist.ipfs.io/fs-repo-migrations/v2.0.1/fs-repo-migrations_v2.0.1_linux-${TARGETARCH:-amd64}.tar.gz -o fs-repo-migrations.tar.gz \
    && tar -zxvf fs-repo-migrations.tar.gz


# Now comes the actual target image, which aims to be as small as possible.
FROM busybox:1.31.1-glibc

# Get the ipfs binary, entrypoint script, and TLS CAs from the build container.
ENV SRC_DIR /go-ipfs

COPY --from=0 $SRC_DIR/go-ipfs/ipfs /usr/local/bin/ipfs
COPY --from=0 $SRC_DIR/bin/dappnode_entrypoint /usr/local/bin/dappnode_entrypoint
COPY --from=0 /tmp/su-exec/su-exec-static /sbin/su-exec
COPY --from=0 /tmp/tini /sbin/tini
COPY --from=0 /bin/fusermount /usr/local/bin/fusermount
COPY --from=0 /etc/ssl/certs /etc/ssl/certs

# Copy fs-repo-migrations from previous stage in /usr/local/bin/fs-repo-migrations
COPY --from=fs-repo-migrations /usr/src/app/fs-repo-migrations/fs-repo-migrations /usr/local/bin/fs-repo-migrations

# Add suid bit on fusermount so it will run properly
RUN chmod 4755 /usr/local/bin/fusermount

# Fix permissions on dappnode_entrypoint (ignore the build machine's permissions)
RUN chmod 0755 /usr/local/bin/dappnode_entrypoint

# This shared lib (part of glibc) doesn't seem to be included with busybox.
COPY --from=0 /lib/*-linux-gnu*/libdl.so.2 /lib/

# Copy over SSL libraries.
COPY --from=0 /usr/lib/*-linux-gnu*/libssl.so* /usr/lib/
COPY --from=0 /usr/lib/*-linux-gnu*/libcrypto.so* /usr/lib/

# Swarm TCP; should be exposed to the public
EXPOSE 4001
# Swarm UDP; should be exposed to the public
EXPOSE 4001/udp
# Daemon API; must not be exposed publicly but to client services under you control
EXPOSE 5001
# Web Gateway; can be exposed publicly with a proxy, e.g. as https://ipfs.example.org
EXPOSE 8080
# Swarm Websockets; must be exposed publicly when the node is listening using the websocket transport (/ipX/.../tcp/8081/ws).
EXPOSE 8081

# Create the fs-repo directory and switch to a non-privileged user.
ENV IPFS_PATH /data/ipfs
RUN mkdir -p $IPFS_PATH \
  && adduser -D -h $IPFS_PATH -u 1000 -G users ipfs \
  && chown ipfs:users $IPFS_PATH

# Create mount points for `ipfs mount` command
RUN mkdir /ipfs /ipns \
  && chown ipfs:users /ipfs /ipns

# Expose the fs-repo as a volume.
# start_ipfs initializes an fs-repo if none is mounted.
# Important this happens after the USER directive so permissions are correct.
VOLUME $IPFS_PATH

# The default logging level
ENV IPFS_LOGGING ""

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/dappnode_entrypoint" ]

# Execute the daemon subcommand by default
CMD [ "daemon", "--migrate=true" ]