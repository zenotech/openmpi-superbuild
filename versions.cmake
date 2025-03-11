
superbuild_set_selectable_source(openmpi
  SELECT 5.0.7 DEFAULT
  URL "https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.7.tar.bz2"
  URL_MD5 0529027472015810e5f0d749136ca0a3 
  SELECT 4.1.6
  URL "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz"
  URL_MD5 e478b1d886935e5f836a9164ad4806d0 
)
   
superbuild_set_revision(libfabric
  URL "https://github.com/ofiwg/libfabric/archive/refs/tags/v2.0.0.tar.gz"
  URL_MD5 bee7f0a4cc189db416a46fa751b8199a)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/releases/download/v1.18.0/ucx-1.18.0.tar.gz"
  URL_MD5 b32a56b2c5e9dc24687b8ea0eb0c0ab7)

superbuild_set_revision(psm2
  URL     "https://github.com/cornelisnetworks/opa-psm2/archive/refs/tags/PSM2_12.0.1.tar.gz"
  URL_MD5 08f5b34fc1e063f7faf0e0eef092309c)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.4.4.tar.gz"
  URL_MD5 7d41b560b8616eddde16662d7aa4e3a4)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/refs/tags/v2.25.1-1.tar.gz"
  URL_MD5 ba8313dfd12a92c790abc5a9afee093f)

superbuild_set_revision(awsofinccl
    GIT_REPOSITORY "https://github.com/aws/aws-ofi-nccl.git"
    GIT_TAG        "master")

  #URL "https://github.com/aws/aws-ofi-nccl/archive/v1.1.1.tar.gz"
  #URL_MD5 17e52db3937b347acd6171325e4ee4e9)

