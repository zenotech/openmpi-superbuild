
set(DSO_LIST "common-ofi,mtl-ofi,btl-ofi,btl-openib,pml-ucx")

set(CUDA_OPTION)
if(CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
  set(CUDA_OPTION "--with-cuda=${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/../")
  set(DSO_LIST "${DSO_LIST},btl-smcuda,rcache-rgpusm,rcache-gpusm,accelerator-cuda")
endif()

set(UCX_OPTION)
if(ENABLE_ucx)
  set(UCX_OPTION "--with-ucx=<INSTALL_DIR>")
endif()

set(PSM_OPTION)
if(ENABLE_psm2)
    set(PSM_OPTION --with-psm2=<INSTALL_DIR>/usr --with-psm2-libdir=<INSTALL_DIR>/usr/lib64)
endif()

set(VERBS_OPTION --with-verbs)
if(APPLE)
     set(VERBS_OPTION)
endif()

superbuild_add_project(
  openmpi
  DEPENDS libfabric
  DEPENDS_OPTIONAL cuda ucx
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --prefix=<INSTALL_DIR> 
		    --with-ofi=<INSTALL_DIR> 
		    --enable-orterun-prefix-by-default 
		    --with-io-romio-flags=--with-file-system=nfs+ufs+gpfs+lustre
		    --enable-mpi1-compatibility
                    --enable-mca-dso=${DSO_LIST}
                    --with-hwloc=internal --with-libevent=internal
                    ${VERBS_OPTION}
                    ${CUDA_OPTION}
		    ${UCX_OPTION}
		    ${PSM_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
)

