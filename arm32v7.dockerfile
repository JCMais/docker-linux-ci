# This Dockerfile is based on CircleCI image:
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/ea744c59/buildpack-deps/images/stretch/Dockerfile
FROM arm32v7/buildpack-deps:focal

LABEL maintainer="Jonathan Cardoso Machado <https://twitter.com/_jonathancardos>"

COPY ./qemu-arm-static /usr/bin/qemu-arm-static

# make Apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

ENV DEBIAN_FRONTEND=noninteractive

# Make sure PATH includes ~/.local/bin
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=839155
# RUN echo 'PATH="$HOME/.local/bin:$PATH"' >> /etc/profile.d/user-local-path.sh

# man directory is missing in some base images
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
# RUN apt-get update \
#   && mkdir -p /usr/share/man/man1 \
#   && apt-get install -y \
#     git mercurial xvfb apt \
#     locales sudo openssh-client ca-certificates tar gzip parallel \
#     net-tools netcat unzip zip bzip2 gnupg curl wget
RUN apt-get update \
  && apt-get install -y \
    git xvfb apt \
    locales sudo openssh-client ca-certificates tar gzip parallel \
    net-tools netcat unzip zip bzip2 gnupg curl wget \
    texinfo gperf ruby-ronn cmake libtool python3 \
  && sudo rm -rf /var/lib/apt/lists/*

# Update automake
RUN echo "Downloading automake" && cd ~ && wget ftp://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz \
      && echo "Untar automake dist file" && tar -xzf automake-1.16.5.tar.gz && cd automake-1.16.5 \
      && echo "Building and installing automake" && ./configure && make && sudo make install

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# Install Docker
RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/armhf/ | grep -o -e 'docker-[.0-9]*\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/armhf/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

USER circleci

# nvm
ARG DEFAULT_NODEJS_VERSION="20"
ENV DEFAULT_NODEJS_VERSION=$DEFAULT_NODEJS_VERSION

SHELL ["/bin/bash", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

RUN echo $'\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' > ~/.bashrc

RUN source /home/circleci/.bashrc \
    && nvm install 18 \
    && nvm install 20 \
    && nvm install 21 \
    && nvm use $DEFAULT_NODEJS_VERSION

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
     "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
     sudo apt update && sudo apt install --no-install-recommends yarn && \
     echo 'export PATH="$(yarn global bin):$PATH"' >> ~/.bashrc
  
RUN yarn --version

USER root
RUN rm /usr/bin/qemu-arm-static
USER circleci

CMD ["/bin/sh"]
