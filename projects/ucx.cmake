
set(CUDA_OPTION)
if(CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
	set(CUDA_OPTION "--with-cuda=${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/../")
endif()
if(ENABLED_gdrcopy)
	set(CUDA_OPTION "${CUDA_OPTION} --with-gdrcopy=<INSTALL_DIR>")
endif()

superbuild_add_project(
  ucx
  DEPENDS_OPTIONAL cuda gdrcopy
  BUILD_IN_SOURCE 1
  PATCH_COMMAND     <SOURCE_DIR>/autogen.sh
  CONFIGURE_COMMAND <SOURCE_DIR>/contrib/configure-release
                    --prefix=<INSTALL_DIR>
                    --without-mpi
                    --enable-mt
                    --enable-optimizations
                    ${CUDA_OPTION}
                    MPICC=
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

