
set(PSM_OPTION)
if(ENABLE_psm2)
 set(PSM_OPTION "--enable-psm2=yes")
endif()

superbuild_add_project(
  libfabric
  DEPENDS_OPTIONAL psm2 
  BUILD_IN_SOURCE 1
  PATCH_COMMAND <SOURCE_DIR>/autogen.sh
  CONFIGURE_COMMAND <SOURCE_DIR>/configure 
                    --prefix=<INSTALL_DIR> 
                    --enable-tcp=yes 
		    --enable-verbs=dl
		    ${PSM_OPTION}
  BUILD_COMMAND make -j${SUPERBUILD_PROJECT_PARALLELISM} -l${SUPERBUILD_PROJECT_PARALLELISM}
  INSTALL_COMMAND make install
  )

