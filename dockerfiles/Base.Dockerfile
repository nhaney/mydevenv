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

# create user and home directory
RUN apt-get install -y sudo
RUN adduser --disabled-password --gecos '' devuser
RUN adduser devuser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# install neovim dependencies
## setup locale
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8 

## install python3, pip
RUN apt-get install -y python3 python3-pip

## install xclip for clipboard
RUN apt-get install -y xsel

## ripgrep + fd for better searching
RUN apt-get install -y ripgrep
RUN apt-get install -y fd-find

USER devuser
WORKDIR /home/devuser

SHELL ["/bin/bash", "-c"]

# install python neovim provider
RUN python3 -m pip install pynvim

## install node + neovim node provider
RUN curl -fsSL https://fnm.vercel.app/install | bash
RUN source /home/devuser/.bashrc
RUN /home/devuser/.fnm/fnm install v18.7.0
RUN npm i -g neovim

# Add aliases
RUN echo "alias tmux='tmux -u'" >> .bashrc
RUN echo "alias vim='nvim'" >> .bashrc

# Configure Neovim

