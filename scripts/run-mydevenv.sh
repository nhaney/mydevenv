docker run -it \
    --rm \
    --mount source=mydevenv-vol,target=/home/mydevenv \
    --mount type=bind,source=/home/nigel/.ssh,target=/home/mydevenv/.ssh \
    --mount type=bind,source=/home/nigel/.git,target=/home/mydevenv/.git \
    mydevenv:base \
    /bin/bash
