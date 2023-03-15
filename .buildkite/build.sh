#!/bin/bash

set -euo pipefail

export HOME=/root
git fetch --tags

mkdir build
pushd build
CMAKE_VERSION=3.25.2
DOWNLOAD_DIR=${PWD}
if [ ! -f ${PWD}/cmake-${CMAKE_VERSION}-linux-x86_64/bin/cmake ]; then
  if [ ! -f ${DOWNLOAD_DIR}/cmake-${CMAKE_VERSION}-linux-x86_64.sh ]; then
    wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh -O ${DOWNLOAD_DIR}/cmake-${CMAKE_VERSION}-linux-x86_64.sh
  fi
  sh ${DOWNLOAD_DIR}/cmake-${CMAKE_VERSION}-linux-x86_64.sh --prefix=${PWD} --include-subdir
fi
export PATH=${PWD}/cmake-${CMAKE_VERSION}-linux-x86_64/bin:${PATH}
cmake -DENABLE_openmpi=OFF -DENABLE_cuda=ON -DENABLE_ucx=OFF -DENABLE_efa=ON -DENABLE_psm2=OFF -DENABLE_nccl=ON -DENABLE_awsofinccl=ON ..
cmake --build . -- VERBOSE=true
ctest -R
popd

# This will be owned by root so make it available to the buildkite user
chmod ugo+r *.tar.gz

# Cleanup the build tree
rm -rf build
