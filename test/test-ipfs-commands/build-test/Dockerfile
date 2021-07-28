FROM alpine

RUN apk update && \
    apk add curl && \
    apk add jq

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]