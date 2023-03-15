#!/bin/bash

set -euo pipefail

export HOME=/root
git fetch --tags

mkdir build
pushd build
cmake -DENABLE_openmpi=OFF -DENABLE_cuda=ON -DENABLE_ucx=OFF -DENABLE_efa=ON -DENABLE_psm2=OFF -DENABLE_nccl=ON -DENABLE_awsofinccl=ON ..
cmake --build . -- VERBOSE=true
ctest -R
popd

# This will be owned by root so make it available to the buildkite user
chmod ugo+r *.tar.gz

# Cleanup the build tree
rm -rf build
