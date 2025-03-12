#!/bin/bash

# Exit immediately if a command exits with a non-zero status, 
# treat unset variables as an error, and prevent errors in a pipeline from being masked
set -euo pipefail

# Get the absolute path of the directory containing this script
workspace_dir=$(realpath $(dirname $0))

# Command to build the project
BUILD_CMD=".buildkite/build.sh"

# Command to be executed
CMD="bash -c \"${BUILD_CMD}\""

# Print the command to be executed
echo "${CMD}"

# Check if the script is running inside a Docker container
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    # If inside a Docker container, execute the build command
    exec bash -c "${BUILD_CMD}"
else

    # Set the home directory
    export HOME_DIR=${HOME}

    # This requires the passwd file to be mapped into the container
    # export DEFAULT_USER=${DEFAULT_USER:-$USER}

    # Set the default user to 'vscode'
    export DEFAULT_USER=vscode

    # Set the directory for DDT mounts and create it if it doesn't exist
    export DDT_MOUNTS="${HOME}/.allinea"
    mkdir -p $DDT_MOUNTS/

    # Check if HOME_MNT is set, if so, use it and set HOME_DIR accordingly
    # Otherwise, set HOME_MNT to a default value
    if [ -n "${HOME_MNT:-}" ]; then
        export HOME_MNT="${HOME_MNT}"
        export HOME_DIR=/home/${DEFAULT_USER}
    else
        export HOME_MNT=${HOME}
    fi

    # If outside a Docker container, start a dev container with the specified workspace folder
    devcontainer up --remove-existing-container --workspace-folder "${workspace_dir}"

    # Execute the build command inside the dev container
    exec devcontainer exec --workspace-folder "${workspace_dir}" bash -c "${BUILD_CMD}"
fi
