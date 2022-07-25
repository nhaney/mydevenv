FROM ubuntu:latest

# The base dev container
#
# The goal of this container is to establish the base development environment with as few language specific tools as possible.
# The scope of this file is:
#   * Install general linux utilities
#   * Install tools that can be used in any project type
#   * Install neovim and neovim configs
#   * Install dotfiles

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

# Install neovim from source
RUN apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

RUN git clone https://github.com/neovim/neovim.git && cd neovim && make CMAKE_BUILD_TYPE=Release && make install

RUN apt-get install -y sudo

# create user and home directory
RUN adduser --disabled-password --gecos '' devuser
RUN adduser devuser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

# Install dotfiles
# RUN cd ~/ && git clone https://github.com/nhaney/dotfiles.git

# Add aliases
RUN echo "alias tmux='tmux -u'" >> .bashrc
RUN echo "alias vim='nvim'" >> .bashrc
