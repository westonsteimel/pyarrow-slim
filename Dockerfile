FROM python:3-slim

RUN apt update \
    && apt install -y \
    zip \
    pcregrep \
    binutils \
    bash

WORKDIR /build

COPY slimify.sh /build/

CMD ["/build/slimify.sh"]
