FROM golang:1.21.3-bookworm as go-builder

WORKDIR /go/src/app

RUN go install github.com/bemasher/rtlamr-collect@latest

FROM debian:bookworm-20231030-slim

COPY --from=go-builder /go/bin/rtlamr* /usr/bin/
COPY ./entrypoint.sh /usr/bin/

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -o Dpkg::Options::="--force-confnew" -y \
      mosquitto-clients \
      procps \
      psmisc \
    && apt-get --purge autoremove -y \
    && apt-get clean \
    && find /var/lib/apt/lists/ -type f -delete \
    && chmod 755 /usr/bin/entrypoint.sh \
    && rm -rf /usr/share/doc

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
