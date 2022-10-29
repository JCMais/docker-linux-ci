# This image contains Node 8, 10 and 11, they are located on
#  /usr/local/bin/node${version-major}
# No bin is linked to /user/local/bin/node
FROM alpine:3.16

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
    python3 py3-pip make g++ \
    # OpenSSL building
    perl linux-headers \
    # libssh2 building 
    autoconf automake libtool \
    # kerberos related
    texinfo flex bison build-base libedit-dev mandoc-soelim

COPY --from=node:14-alpine3.16 /usr/local/bin/node /usr/local/bin/node14
RUN /usr/local/bin/node14 -e 'console.log(process.versions)'

COPY --from=node:16-alpine3.16 /usr/local/bin/node /usr/local/bin/node16
RUN /usr/local/bin/node16 -e 'console.log(process.versions)'

COPY --from=node:18-alpine3.16 /usr/local/bin/node /usr/local/bin/node18
RUN /usr/local/bin/node18 -e 'console.log(process.versions)'

COPY --from=node:19-alpine3.16 /usr/local/bin/node /usr/local/bin/node19
RUN /usr/local/bin/node19 -e 'console.log(process.versions)'

################################
# Install Yarn
################################
COPY --from=node:18-alpine3.16 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:18-alpine3.16 /opt/ /opt/
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -sf /opt/yarn*/bin/yarn /usr/local/bin/yarn \
  && ln -sf /opt/yarn*/bin/yarnpkg /usr/local/bin/yarnpkg
