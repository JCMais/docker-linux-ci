FROM cimg/base:2022.10

LABEL maintainer="Jonathan Cardoso Machado <https://twitter.com/_jonathancardos>"

# Install missing packages
RUN sudo apt-get update \
  && sudo apt-get install -y \
        texinfo gperf ruby-ronn cmake libtool python3 \
  && sudo rm -rf /var/lib/apt/lists/*

# Update automake
RUN echo "Downloading automake" && cd ~ && wget ftp://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz \
      && echo "Untar automake dist file" && tar -xzf automake-1.16.5.tar.gz && cd automake-1.16.5 \
      && echo "Building and installing automake" && ./configure && make && sudo make install

# Install nvm
ARG DEFAULT_NODEJS_VERSION="18"
ENV DEFAULT_NODEJS_VERSION=$DEFAULT_NODEJS_VERSION

SHELL ["/bin/bash", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

RUN echo $'\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' > ~/.bashrc

RUN source /home/circleci/.bashrc \
      && nvm install 14 \
      && nvm install 16 \
      && nvm install 18 \
      && nvm install 19 \
      && nvm use $DEFAULT_NODEJS_VERSION

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
     echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
     sudo apt-get update && sudo apt-get install --no-install-recommends yarn && \
     echo 'export PATH="$(yarn global bin):$PATH"' >> ~/.bashrc
