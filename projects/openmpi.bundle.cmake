include(openmpi-version)

set(CPACK_PACKAGE_NAME "openmpi")
  set(CPACK_PACKAGE_VENDOR "OpenMPI")
  set(CPACK_PACKAGE_VERSION_MAJOR "${openmpi_version_major}")
  set(CPACK_PACKAGE_VERSION_MINOR "${openmpi_version_minor}")
  set(CPACK_PACKAGE_VERSION_PATCH "${openmpi_version_patch}${openmpi_version_suffix}")
  
  set(CPACK_PACKAGE_FILE_NAME
     "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

# Install etc
install(DIRECTORY "${superbuild_install_location}/etc/"
    DESTINATION "etc"
    USE_SOURCE_PERMISSIONS
    COMPONENT superbuild)

# Install share
install(DIRECTORY "${superbuild_install_location}/share/"
    DESTINATION "share"
    USE_SOURCE_PERMISSIONS
    COMPONENT superbuild)

# Install bin
install(DIRECTORY "${superbuild_install_location}/bin/"
    DESTINATION "bin"
    USE_SOURCE_PERMISSIONS
    COMPONENT superbuild)

# Install lib
install(DIRECTORY "${superbuild_install_location}/lib/"
    DESTINATION "lib"
    USE_SOURCE_PERMISSIONS
    COMPONENT superbuild)

# Install include
install(DIRECTORY "${superbuild_install_location}/include/"
    DESTINATION "include"
    USE_SOURCE_PERMISSIONS
    COMPONENT superbuild)
