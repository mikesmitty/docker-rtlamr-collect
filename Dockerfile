FROM golang:1.21.3-bookworm as go-builder

WORKDIR /go/src/app

RUN go install github.com/bemasher/rtlamr-collect@latest
RUN go install github.com/bemasher/rtlamr@latest \
    && apt-get update \
    && apt-get install -y libusb-1.0-0-dev build-essential git cmake \
    && git clone git://git.osmocom.org/rtl-sdr.git \
    && cd rtl-sdr \
    && mkdir build && cd build \
    && cmake .. -DDETACH_KERNEL_DRIVER=ON -DENABLE_ZEROCOPY=ON -Wno-dev \
    && make \
    && make install

FROM debian:bookworm-20231030-slim

COPY --from=go-builder /usr/local/lib/librtl* /lib/
COPY --from=go-builder /usr/local/bin/rtl* /usr/bin/
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

ENV RTLAMR_FORMAT=json
ENV RTLAMR_MSGTYPE=idm

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
