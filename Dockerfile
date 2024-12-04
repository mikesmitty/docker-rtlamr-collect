FROM golang:1.23.4-bookworm as go-builder

WORKDIR /go/src/app

RUN go install github.com/bemasher/rtlamr-collect@latest
RUN go install github.com/bemasher/rtlamr@latest

FROM debian:bookworm-20231030-slim

COPY --from=go-builder /go/bin/rtlamr* /usr/bin/
COPY ./entrypoint.sh /usr/bin/

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -o Dpkg::Options::="--force-confnew" -y \
      ca-certificates \
      procps \
      psmisc \
    && apt-get --purge autoremove -y \
    && apt-get clean \
    && find /var/lib/apt/lists/ -type f -delete \
    && chmod 755 /usr/bin/entrypoint.sh \
    && rm -rf /usr/share/doc

ENV RTLAMR_FORMAT=json
ENV RTLAMR_MSGTYPE=idm

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
