FROM alpine:3.9

LABEL maintainer="Jonathan Cardoso Machado <https://twitter.com/_jonathancardos>"

RUN \
  apk --no-cache add --virtual .rundeps \
    # basic stuff
    bash ca-certificates curl docker git gnupg openssh-client openssl parallel \
    # gnu sort etc
    coreutils \
    # Node.js addon building
    python make g++ \
    # OpenSSL building
    perl linux-headers \
    # libssh2 building 
    libtool
