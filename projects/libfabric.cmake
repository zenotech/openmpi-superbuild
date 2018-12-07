
set(PSM_OPTION)
if(ENABLE_psm2)
	set(PSM_OPTION "--enable-psm2=dl --with-psm2-src=INSTALL_DIR>")
endif()

superbuild_add_project(
  libfabric
  DEPENDS ucx
  DEPENDS_OPTIONAL psm2 
  BUILD_IN_SOURCE 1
  PATCH_COMMAND <SOURCE_DIR>/autogen.sh
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --prefix=<INSTALL_DIR> 
                    --enable-tcp=yes 
		    --enable-verbs=dl
		    --enable-mlx=dl:<INSTALL_DIR>
		    #--with-mlx=<INSTALL_DIR>
		    ${PSM_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

