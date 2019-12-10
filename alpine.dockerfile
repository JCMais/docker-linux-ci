# This image contains Node 8, 10 and 11, they are located on
#  /usr/local/bin/node${version-major}
# No bin is linked to /user/local/bin/node
FROM alpine:3.9

LABEL maintainer="Jonathan Cardoso Machado <https://twitter.com/_jonathancardos>"

# First install stuff that will be needed
RUN \
  apk --no-cache add --virtual .rundeps \
    # general stuff
    bash ca-certificates cmake curl docker git \
    gnupg openssh-client openssl parallel pkgconfig \
    # gnu sort etc
    coreutils \
    # Node.js addon building
    python make g++ \
    # OpenSSL building
    perl linux-headers \
    # libssh2 building 
    autoconf automake libtool \
    # kerberos related
    texinfo flex bison build-base libedit-dev mdocml-soelim

COPY --from=node:8-alpine3.9 /usr/local/bin/node /usr/local/bin/node8
COPY --from=node:10-alpine3.9 /usr/local/bin/node /usr/local/bin/node10
COPY --from=node:12-alpine3.9 /usr/local/bin/node /usr/local/bin/node12
COPY --from=node:13-alpine3.9 /usr/local/bin/node /usr/local/bin/node13

ENV YARN_VERSION 1.15.2

RUN for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz
