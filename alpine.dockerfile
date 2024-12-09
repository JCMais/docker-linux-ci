# This image contains multiple versions of nodejs, they are located on
#  /usr/local/bin/node${version-major}
# No bin is linked to /user/local/bin/node
FROM alpine:3.20

LABEL maintainer="Jonathan Cardoso Machado <https://twitter.com/_jonathancardos>"

# First install stuff that will be needed
RUN \
  apk update && apk --no-cache add --virtual .rundeps \
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
RUN python -V
RUN python3 -V

COPY --from=node:18-alpine3.20 /usr/local/bin/node /usr/local/bin/node18
RUN /usr/local/bin/node18 -e 'console.log(process.versions)'

COPY --from=node:20-alpine3.20 /usr/local/bin/node /usr/local/bin/node20
RUN /usr/local/bin/node20 -e 'console.log(process.versions)'

COPY --from=node:21-alpine3.20 /usr/local/bin/node /usr/local/bin/node21
RUN /usr/local/bin/node21 -e 'console.log(process.versions)'

COPY --from=node:22-alpine3.20 /usr/local/bin/node /usr/local/bin/node22
RUN /usr/local/bin/node22 -e 'console.log(process.versions)'

COPY --from=node:23-alpine3.20 /usr/local/bin/node /usr/local/bin/node23
RUN /usr/local/bin/node23 -e 'console.log(process.versions)'

################################
# Install Yarn
################################
COPY --from=node:22-alpine3.20 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:22-alpine3.20 /opt/ /opt/
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -sf /opt/yarn*/bin/yarn /usr/local/bin/yarn \
  && ln -sf /opt/yarn*/bin/yarnpkg /usr/local/bin/yarnpkg
