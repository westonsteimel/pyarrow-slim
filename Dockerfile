FROM python:3-slim

RUN apt update \
    && apt install \
    zip \
    pcregrep \
    bash

WORKDIR /build

COPY slimify.sh /build/

CMD ["/build/slimify.sh"]
