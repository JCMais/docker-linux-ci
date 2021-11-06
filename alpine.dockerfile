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
    python python3 py3-pip make g++ \
    # OpenSSL building
    perl linux-headers \
    # libssh2 building 
    autoconf automake libtool \
    # kerberos related
    texinfo flex bison build-base libedit-dev mdocml-soelim

COPY --from=node:10-alpine3.9 /usr/local/bin/node /usr/local/bin/node10
RUN /usr/local/bin/node10 -e 'console.log(process.versions)'

COPY --from=node:12-alpine3.9 /usr/local/bin/node /usr/local/bin/node12
RUN /usr/local/bin/node12 -e 'console.log(process.versions)'

COPY --from=node:13-alpine3.10 /usr/local/bin/node /usr/local/bin/node13
RUN /usr/local/bin/node13 -e 'console.log(process.versions)'

COPY --from=node:14-alpine3.10 /usr/local/bin/node /usr/local/bin/node14
RUN /usr/local/bin/node14 -e 'console.log(process.versions)'

COPY --from=node:15-alpine3.10 /usr/local/bin/node /usr/local/bin/node15
RUN /usr/local/bin/node15 -e 'console.log(process.versions)'

COPY --from=node:16-alpine3.11 /usr/local/bin/node /usr/local/bin/node16
RUN /usr/local/bin/node16 -e 'console.log(process.versions)'

COPY --from=node:17-alpine3.12 /usr/local/bin/node /usr/local/bin/node17
RUN /usr/local/bin/node17 -e 'console.log(process.versions)'

################################
# Install Yarn
################################
COPY --from=node:17-alpine3.12 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:17-alpine3.12 /opt/ /opt/
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -sf /opt/yarn*/bin/yarn /usr/local/bin/yarn \
  && ln -sf /opt/yarn*/bin/yarnpkg /usr/local/bin/yarnpkg
