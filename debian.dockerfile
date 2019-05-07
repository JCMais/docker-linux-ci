FROM circleci/buildpack-deps:stretch-browsers

# Install missing packages
RUN sudo apt-get update \
  && sudo apt-get install -y \
        texinfo gperf ruby-ronn cmake libtool \
  && sudo rm -rf /var/lib/apt/lists/*

# Update automake
RUN echo "Downloading automake" && cd ~ && wget ftp://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.gz \
      && echo "Untar automake dist file" && tar -xzf automake-1.16.1.tar.gz && cd automake-1.16.1 \
      && echo "Building and installing automake" && ./configure && make && sudo make install

# Install nvm
ARG DEFAULT_NODEJS_VERSION="10"
ENV DEFAULT_NODEJS_VERSION=$DEFAULT_NODEJS_VERSION

SHELL ["/bin/bash", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

RUN echo $'\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' > ~/.bashrc

RUN source /home/circleci/.bashrc && nvm install $DEFAULT_NODEJS_VERSION

# Yarn
ENV YARN_VERSION 1.15.2

RUN for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && cd /home/circleci \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p ~/.yarn \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C ~/.yarn/ \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && echo "PATH=\$HOME/.yarn/yarn-v$YARN_VERSION/bin:\$PATH" >> ~/.bashrc

ENTRYPOINT [ "/bin/bash" ]
