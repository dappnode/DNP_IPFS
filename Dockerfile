ARG UPSTREAM_VERSION

FROM ipfs/kubo:${UPSTREAM_VERSION}

RUN ipfs config --json Gateway.PublicGateways '{"ipfs.dappnode": { "NoDNSLink": false, "Paths": [ "/ipfs" , "/ipns" ], "UseSubdomains": false }}'