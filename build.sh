#!/bin/bash


set -euo pipefail

workspace_dir=$(realpath $(dirname $0))

CMAKE_CMD=".buildkite/build.sh"

CMD="bash -c \"${CMAKE_CMD}\""

echo "${CMD}"

if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    # inside docker container
    exec bash -c "${CMAKE_CMD}"
else
    # outside docker container
    devcontainer up --remove-existing-container --workspace-folder "${workspace_dir}"

    exec devcontainer exec --workspace-folder "${workspace_dir}" bash -c "${CMAKE_CMD}"
fi

