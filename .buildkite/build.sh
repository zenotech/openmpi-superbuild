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
export CC=icx
export CXX=icpx
export FC=ifx
cmake -DENABLE_openmpi=ON -DENABLE_libfabric=ON -DENABLE_cuda=ON -DENABLE_ucx=ON -DENABLE_efa=OFF -DENABLE_psm2=OFF -DENABLE_gdrcopy=OFF -DENABLE_nccl=OFF -DENABLE_awsofinccl=OFF ..
cmake --build . -- VERBOSE=true
ctest -R
popd
# Copy tarball
cp build/*.tar.gz .
# This will be owned by root so make it available to the buildkite user
chmod ugo+r *.tar.gz

# Cleanup the build tree
rm -rf build
