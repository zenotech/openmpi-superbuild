

superbuild_add_project(
  awsofinccl 
  DEPENDS cuda nccl libfabric openmpi
  BUILD_IN_SOURCE 1
  PATCH_COMMAND <SOURCE_DIR>/autogen.sh 
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --prefix=<INSTALL_DIR>
                    --with-libfabric=<INSTALL_DIR> 
                    --with-nccl=<INSTALL_DIR>
                    --with-cuda=${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/../
                    --with-mpi=<INSTALL_DIR>
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
  )

