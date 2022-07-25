#!/bin/bash

# This does the following:
# * add user to docker group gid on the host (assumes docker group is named "docker")
# * persist changes to dev environment onto disk of host
# * allow devuser to use docker socket for docker based development
# * give devuser ssh config of the host
# * give devuser git config of the host
# * mount this directory for development of this directory inside container
docker run -it \
    --rm \
    --group-add $(getent group docker | cut -d : -f3) \
    --mount source=mydevenv-vol,target=/home/devuser \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=bind,source=/home/$(whoami)/.ssh,target=/home/devuser/.ssh \
    --mount type=bind,source=/home/$(whoami)/.gitconfig,target=/home/devuser/.gitconfig \
    --mount type=bind,source=$(pwd),target=/home/devuser/mydevenv \
    mydevenv:base \
    /bin/bash