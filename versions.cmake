
superbuild_set_selectable_source(openmpi
  SELECT 4.1.4 DEFAULT
  URL     "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.4.tar.bz2"
  URL_MD5 f057e12aabaf7dd5a6a658180fca404e 
  SELECT 3.1.6
  URL     "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.6.tar.bz2"
  URL_MD5 d2b643de03d8f7d8064d7a35ad5b385d
)
   
superbuild_set_revision(libfabric
  URL     "https://github.com/ofiwg/libfabric/archive/refs/tags/v1.16.1.tar.gz"
  URL_MD5 082a8ec05a52529d1f7a0647740ace74)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/releases/download/v1.13.1/ucx-1.13.1.tar.gz"
  URL_MD5 38b74d923a4282d42ab4c4eeac971ada)

superbuild_set_revision(psm2
  URL     "https://github.com/intel/opa-psm2/archive/IFS_RELEASE_10_10_2_0_44.tar.gz"
  URL_MD5 08f5b34fc1e063f7faf0e0eef092309c)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.3.tar.gz"
  URL_MD5 7d41b560b8616eddde16662d7aa4e3a4)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/refs/tags/v2.15.5-1.tar.gz"
  URL_MD5 1e11ca0063b2b4bd384fa5080c36aee9)

superbuild_set_revision(awsofinccl
    GIT_REPOSITORY "https://github.com/aws/aws-ofi-nccl.git"
    GIT_TAG        "master")

  #URL "https://github.com/aws/aws-ofi-nccl/archive/v1.1.1.tar.gz"
  #URL_MD5 17e52db3937b347acd6171325e4ee4e9)

