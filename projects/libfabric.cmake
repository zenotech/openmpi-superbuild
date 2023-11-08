
set(PSM_OPTION)
if(ENABLE_psm2)
	set(PSM_OPTION "--enable-psm2=dl:<INSTALL_DIR>/usr" --enable-psm3=dl)
endif()
set(UCX_OPTION)
if(ENABLE_ucx)
	set(UCX_OPTION "--enable-ucx=dl:<INSTALL_DIR>")
endif()
set(EFA_OPTION)
if(ENABLE_efa)
        set(EFA_OPTION "--enable-efa=dl")
endif()
set(VERBS_OPTION --enable-verbs=dl)
if(APPLE)
        set(VERBS_OPTION)
endif()
set(CUDA_OPTION)
if(ENABLE_cuda)
        set(CUDA_OPTION --enable-cuda-dlopen  --with-cuda=${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/../)
endif()
if(ENABLE_gdrcopy)
        set(CUDA_OPTION "${CUDA_OPTION} --with-gdrcopy=<INSTALL_DIR>")
endif()
set(ZE_OPTION)
if(ENABLE_ze)
        set(ZE_OPTION --with-ze=/usr/local/level-zero --enable-ze-dlopen)
endif()

superbuild_add_project(
  libfabric
  DEPENDS_OPTIONAL ucx psm2 cuda gdrcopy 
  BUILD_IN_SOURCE 1
  PATCH_COMMAND <SOURCE_DIR>/autogen.sh 
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --verbose
                    --prefix=<INSTALL_DIR> 
                    --enable-tcp=yes
                    ${VERBS_OPTION} 
                    ${EFA_OPTION}
		    ${UCX_OPTION}
		    ${PSM_OPTION}
                    ${CUDA_OPTION}
                    ${ZE_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

