
superbuild_set_selectable_source(openmpi
  SELECT 5.0.0 DEFAULT
  URL "https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.0.tar.bz2"
  URL_MD5 5c4fae19e1d853abeb1bdadd10a59466
  SELECT 4.1.6
  URL "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz"
  URL_MD5 e478b1d886935e5f836a9164ad4806d0 
)
   
superbuild_set_revision(libfabric
  URL "https://github.com/ofiwg/libfabric/releases/download/v1.19.0/libfabric-1.19.0.tar.bz2"
  URL_MD5 d6275f6990a26dc144a1d43899c20a2d)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/releases/download/v1.15.0/ucx-1.15.0.tar.gz"
  URL_MD5 bb141973027ba522b397f89272681cee)

superbuild_set_revision(psm2
  URL     "https://github.com/intel/opa-psm2/archive/IFS_RELEASE_10_10_2_0_44.tar.gz"
  URL_MD5 08f5b34fc1e063f7faf0e0eef092309c)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.3.tar.gz"
  URL_MD5 7d41b560b8616eddde16662d7aa4e3a4)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/refs/tags/v2.19.3-1.tar.gz"
  URL_MD5 ba8313dfd12a92c790abc5a9afee093f)

superbuild_set_revision(awsofinccl
    GIT_REPOSITORY "https://github.com/aws/aws-ofi-nccl.git"
    GIT_TAG        "master")

  #URL "https://github.com/aws/aws-ofi-nccl/archive/v1.1.1.tar.gz"
  #URL_MD5 17e52db3937b347acd6171325e4ee4e9)

