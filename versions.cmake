
superbuild_set_selectable_source(openmpi
  SELECT 4.0.3 DEFAULT
  URL     "https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.bz2"
  URL_MD5 851553085013939f24cdceb1af06b828
  SELECT 3.1.6
  URL     "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.6.tar.bz2"
  URL_MD5 d2b643de03d8f7d8064d7a35ad5b385d
)
   
superbuild_set_revision(libfabric
  URL     "https://github.com/ofiwg/libfabric/releases/download/v1.10.1/libfabric-1.10.1.tar.bz2"
  URL_MD5 4b1aed12bbf0569eaf9fcf5828f6d928)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/releases/download/v1.8.0-rc1/ucx-1.8.0.tar.gz"
  URL_MD5 7b0070c74136d223f479193dd8d0cf31)

superbuild_set_revision(psm2
  URL     "https://github.com/intel/opa-psm2/archive/IFS_RELEASE_10_8_0_0_204.tar.gz"
  URL_MD5 bc6fabf0807109849124fdfa48d68ab4)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/v1.3.tar.gz"
  URL_MD5 8ef139cd342cd2071d68de9bf7ba8b55)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/v2.4.2-1.tar.gz"
  URL_MD5 bc6fabf0807109849124fdfa48d68ab4)

