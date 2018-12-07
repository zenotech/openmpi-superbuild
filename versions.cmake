
superbuild_set_selectable_source(openmpi
 SELECT 4.0.0 DEFAULT	
  URL     "https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.bz2"
  URL_MD5 e3da67df1e968c8798827e0e5fe9a510
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
