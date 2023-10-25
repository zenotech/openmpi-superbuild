
set(PSM_OPTION)
if(ENABLE_psm2)
	set(PSM_OPTION "--enable-psm2=dl:<INSTALL_DIR>/usr")
endif()
set(UCX_OPTION)
if(ENABLE_ucx)
	set(UCX_OPTION "--enable-mlx=dl:<INSTALL_DIR>")
endif()
set(EFA_OPTION)
if(ENABLE_efa)
        set(EFA_OPTION "--enable-efa=dl")
endif()
set(VERBS_OPTION --enable-verbs=dl)
if(APPLE)
        set(VERBS_OPTION)
endif()

superbuild_add_project(
  libfabric
  DEPENDS_OPTIONAL ucx psm2 
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
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

