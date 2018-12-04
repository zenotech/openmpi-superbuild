
set(CUDA_OPTION)
if(CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
  set(CUDA_OPTION "-with-cuda=${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/../")
endif()

superbuild_add_project(
  openmpi
  DEPENDS libfabric
  DEPENDS_OPTIONAL cuda
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --prefix=<INSTALL_DIR> 
		    --with-ofi=<INSTALL_DIR> 
		    --with-verbs 
		    --enable-orterun-prefix-by-default 
		    --with-io-romio-flags=--with-file-system=nfs+ufs+gpfs+lustre
                    ${CUDA_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

