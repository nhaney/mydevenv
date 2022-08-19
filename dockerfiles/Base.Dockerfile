FROM ubuntu:latest

# The base dev container
#
# The goal of this container is to establish the base development environment with as few language specific tools as possible.
# The scope of this file is:
#   * Install general linux utilities
#   * Install tools that can be used in any project type, for example:
#       * git
#       * tmux
#       * curl
#       * ssh
#       * New school cli tools like rg and fd
#       * docker so docker in docker can be used
#   * Install neovim and neovim configs

SHELL ["/bin/bash", "-c"]

# Install generic linux utilities
RUN apt-get update && \
    apt-get install -y \ 
        git \
        tmux \
        jq \
        curl \
        ssh

# Install docker
RUN curl -sSL https://get.docker.com/ | sh

# create user and home directory
RUN apt-get install -y sudo
RUN adduser --disabled-password --gecos '' devuser
RUN adduser devuser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install neovim from source
RUN apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
RUN git clone https://github.com/neovim/neovim.git && cd neovim && git checkout release-0.7 && make CMAKE_BUILD_TYPE=Release && make install

# install neovim dependencies
## setup locale to english and utf8
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8 

## install python3, pip
RUN apt-get install -y python3 python3-pip

## install node
ARG NODE_VERSION=16.9.0
ARG NODE_PACKAGE=node-v$NODE_VERSION-linux-x64
ARG NODE_HOME=/opt/$NODE_PACKAGE
ENV NODE_PATH $NODE_HOME/lib/node_modules
ENV PATH $NODE_HOME/bin:$PATH

RUN curl https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE.tar.gz | tar -xzC /opt/

# install node neovim provider
RUN npm i -g neovim

## install xclip for clipboard
RUN apt-get install -y xsel

## ripgrep + fd for better searching with neovim telescope
RUN apt-get install -y ripgrep
RUN apt-get install -y fd-find

USER devuser
WORKDIR /home/devuser

# install python neovim provider
RUN python3 -m pip install pynvim

# Add aliases
RUN echo "alias tmux='tmux -u'" >> .bashrc
RUN echo "alias vim='nvim'" >> .bashrc
RUN echo "alias fd='fdfind'" >> .bashrc

# change terminal to be 256 color
ENV TERM xterm-256color

# Configure Neovim
RUN git clone https://github.com/nhaney/nvim-basic-ide.git ~/.config/nvim

# Configure other dotfiles
RUN git clone https://github.com/nhaney/dotfiles.git ~/.config/dotfiles && cd ~/.config/dotfiles && ./installdotfiles.sh

