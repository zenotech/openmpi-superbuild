
superbuild_set_selectable_source(openmpi
  SELECT 4.0.3 DEFAULT
  URL     "https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.bz2"
  URL_MD5 851553085013939f24cdceb1af06b828
  SELECT 3.1.6
  URL     "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.6.tar.bz2"
  URL_MD5 d2b643de03d8f7d8064d7a35ad5b385d
)
   
superbuild_set_revision(libfabric
  URL     "https://github.com/ofiwg/libfabric/releases/download/v1.12.1/libfabric-1.12.1.tar.bz2"
  URL_MD5 2bf00190cd1da8de4a9d63143d387ab8)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/releases/download/v1.9.0/ucx-1.9.0.tar.gz"
  URL_MD5 4c9ce14fd8e141a5c1e105475bd3b185)

superbuild_set_revision(psm2
  URL     "https://github.com/intel/opa-psm2/archive/IFS_RELEASE_10_10_2_0_44.tar.gz"
  URL_MD5 08f5b34fc1e063f7faf0e0eef092309c)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/v1.3.tar.gz"
  URL_MD5 8ef139cd342cd2071d68de9bf7ba8b55)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/v2.8.4-1.tar.gz"
  URL_MD5 900666558c5bc43e0a5e84045b88a06f)

superbuild_set_revision(awsofinccl
    GIT_REPOSITORY "https://github.com/aws/aws-ofi-nccl.git"
    GIT_TAG        "master")

  #URL "https://github.com/aws/aws-ofi-nccl/archive/v1.1.1.tar.gz"
  #URL_MD5 17e52db3937b347acd6171325e4ee4e9)

