
superbuild_set_selectable_source(openmpi
 SELECT 4.0.0	
  URL     "https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.bz2"
  URL_MD5 e3da67df1e968c8798827e0e5fe9a510
  SELECT 3.1.3 DEFAULT
  URL     "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.3.tar.bz2"
  URL_MD5 7456ab54a81b28d6670489a60c9ed23c
)
   
superbuild_set_revision(libfabric
  URL     "https://github.com/ofiwg/libfabric/archive/v1.7.0rc1.tar.gz"
  URL_MD5 9c23f3886e57b605115c6c3e7f64ba28)

superbuild_set_revision(ucx
  URL "https://github.com/openucx/ucx/archive/v1.4.0.tar.gz"
  URL_MD5 31bdc7cd5224ec6ff24427d46d288d6b) 

superbuild_set_revision(psm2
  URL     "https://github.com/intel/opa-psm2/archive/IFS_RELEASE_10_8_0_0_204.tar.gz"
  URL_MD5 bc6fabf0807109849124fdfa48d68ab4)

superbuild_set_revision(gdrcopy
  URL "https://github.com/NVIDIA/gdrcopy/archive/v1.3.tar.gz"
  URL_MD5 8ef139cd342cd2071d68de9bf7ba8b55)

superbuild_set_revision(nccl
  URL "https://github.com/NVIDIA/nccl/archive/v2.3.7-1.tar.gz"
  URL_MD5 bc6fabf0807109849124fdfa48d68ab4)

