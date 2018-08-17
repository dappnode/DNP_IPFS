FROM alpine

RUN apk update && \
    apk add bind-tools

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]