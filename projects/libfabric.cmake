
set(PSM_OPTION)
if(ENABLE_psm2)
	set(PSM_OPTION "--enable-psm2=dl:<INSTALL_DIR>/usr")
endif()
set(UCX_OPTION)
if(ENABLE_ucx)
	set(UCX_OPTION "--enable-mlx=dl:<INSTALL_DIR>")
endif()
if(ENABLE_efa)
        set(EFA_OPTION "--enable-efa=dl")
endif()

superbuild_add_project(
  libfabric
  DEPENDS_OPTIONAL ucx psm2 
  BUILD_IN_SOURCE 1
  PATCH_COMMAND "" 
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --verbose
                    --prefix=<INSTALL_DIR> 
                    --enable-tcp=yes 
		    --enable-verbs=dl
                    ${EFA_OPTION}
		    ${UCX_OPTION}
		    ${PSM_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

