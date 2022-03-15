#!/bin/bash

set -euo pipefail

image=${*:-amz2-nccl}

if [ -e /dev/nvidiactl ] ; then
    GPUARGS="--gpus all"
fi

HOME_MNT=${HOME_MNT:-$HOME}
DEFAULT_USER=${DEFAULT_USER:-$USER}
MAP_PASSGRP=${MAP_PASSGRP:-"-v /etc/passwd:/etc/passwd -v /etc/group:/etc/group"}
RUN_NAME="--name $(whoami)-amz2 --hostname $(whoami)-amz2"
CLEAN_UP=${CLEAN_UP:-"--rm"}
# Map user supplied port to 8080 for jupyter
JUPYTER_PORT=""
if [ -n "${PORT:-}" ] ; then
    JUPYTER_PORT="-p ${PORT}:8080"
    echo "Using Port $PORT for jupyter server"
fi

if [ -z "$SSH_AUTH_SOCK" ] ; then
    echo "ERROR:  SSH_AUTH_SOCK is not set. ssh agent is not running"
    exit 1
fi

if [ -d /opt/arm/forge ] ; then
    SOFTWARE_MOUNTS=" -v /opt/arm/forge:/opt/arm/forge -v /home/${USER}/.allinea:/home/${DEFAULT_USER}/.allinea"
fi

DOCKER_DISPLAY=$(echo ${DISPLAY:-} | sed -e "s/$(hostname)/host.docker.internal/")

docker run --init -it ${CLEAN_UP} ${GPUARGS:-} ${RUN_NAME} -e DISPLAY=${DOCKER_DISPLAY:-} --add-host=host.docker.internal:host-gateway -v /var/run/docker.sock:/var/run/docker.sock --tmpfs /buildtmp:exec ${JUPYTER_PORT} -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent --privileged --security-opt seccomp=unconfined --cap-add=SYS_ADMIN --cap-add=SYS_PTRACE -u $(id -u ${USER}):$(id -g ${USER}) -e USER=${DEFAULT_USER} -v ${HOME_MNT}:/home/${DEFAULT_USER} -w /home/${DEFAULT_USER}/zCFD ${MAP_PASSGRP} -e HOME=/home/${DEFAULT_USER} ${SOFTWARE_MOUNTS} --shm-size=1g $image /bin/bash
