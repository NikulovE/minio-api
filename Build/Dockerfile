FROM alpine:3.19 AS builder
RUN apk add --no-cache minio ca-certificates
# Enable health and metrics support
COPY ./bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
EXPOSE 9000
# Persist the configuration, data and log directories
VOLUME ["/data"]
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]