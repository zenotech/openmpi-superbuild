#!/bin/bash

# Check for the --clean argument
for arg in "$@"; do
	if [[ "$arg" == "--clean" ]]; then
		CLEAN=true
	fi
done

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as an error, and prevent errors in a pipeline from being masked
set -euo pipefail

# Set the home directory
export HOME_DIR=${HOME}

# This requires the passwd file to be mapped into the container
# export DEFAULT_USER=${DEFAULT_USER:-$USER}

# Set the default user to 'vscode'
export DEFAULT_USER=vscode

# Set the directory for DDT mounts and create it if it doesn't exist
export DDT_MOUNTS="/n/fdshome/${USER}/.allinea"
mkdir -p $DDT_MOUNTS/

# Check if HOME_MNT is set, if so, use it and set HOME_DIR accordingly
# Otherwise, set HOME_MNT to a default value
if [ -n "${HOME_MNT:-}" ]; then
	export HOME_MNT="${HOME_MNT}"
	export HOME_DIR=/home/${DEFAULT_USER}
else
	export HOME_MNT="/n/fdshome/${USER}"
fi

export GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get the directory of the current script
workspace_dir=$(dirname $0)

# If CLEAN is set, run the specified command and exit
if [ "${CLEAN:-}" = true ]; then
	echo "Cleaning dev container..."
	if docker ps -a --format '{{.Names}}' | grep -Eq "^$(whoami)-openmpi\$"; then
		echo "Docker container exists, running cleanup command..."
		docker kill $(whoami)-openmpi
		docker rm $(whoami)-openmpi
	else
		echo "Container does not exist, skipping cleanup."
	fi
fi

# Start the devcontainer with the specified workspace folder
devcontainer up --workspace-folder "${workspace_dir}"

# Execute a bash shell in the devcontainer
exec devcontainer exec --workspace-folder "${workspace_dir}" bash -l
