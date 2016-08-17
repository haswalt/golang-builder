FROM golang:1.6-alpine

RUN apk add --no-cache bash ca-certificates curl openssh git

RUN curl -sL https://github.com/Masterminds/glide/releases/download/0.10.2/glide-0.10.2-linux-amd64.tar.gz | tar -xz \
    && mv linux-amd64/glide /usr/local/bin && chmod +x /usr/local/bin/glide \
    && go get github.com/mattn/gom

VOLUME /src
WORKDIR /src

COPY build_environment.sh /
COPY build.sh /

ENTRYPOINT ["/build.sh"]
