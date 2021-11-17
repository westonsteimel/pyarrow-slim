FROM ghcr.io/westonsteimel/python:3.10-slim-bookworm

ARG TARGETPLATFORM
ENV TARGETPLATFORM="${TARGETPLATFORM}"

RUN apt update \
    && apt install -y \
    zip \
    pcregrep \
    binutils \
    bash

WORKDIR /build

COPY slimify.sh /build/

CMD ["/build/slimify.sh"]
