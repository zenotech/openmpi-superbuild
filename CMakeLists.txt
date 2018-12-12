cmake_minimum_required(VERSION 3.6.1)

project(openmpi-superbuild)

list(INSERT CMAKE_MODULE_PATH 0
  "${CMAKE_CURRENT_LIST_DIR}/cmake")

macro (superbuild_setup_variables)
  include(SuperbuildVersionMacros)
  #The selection is the version number; use it.
  set(openmpi_default_version "${openmpi_SOURCE_SELECTION}")
  superbuild_set_version_variables(openmpi ${openmpi_default_version} "openmpi-version.cmake" "version.txt")
  set(openmpi_version "${openmpi_version_major}.${openmpi_version_minor}")
endmacro ()

function (superbuild_find_projects var)

  set(projects
    openmpi
    libfabric
    ucx
    psm2
    gdrcopy
    cuda)

  set("${var}"
    ${projects}
    PARENT_SCOPE)
endfunction ()

function (superbuild_sanity_check)
endfunction ()

function (superbuild_add_packaging)
  if (WIN32)
    set(generators
      ZIP
      NSIS)
  elseif (APPLE)
    set(generators
      DragNDrop)
  else ()
    set(generators
      TGZ
      )
  endif ()
  list(GET generators 0 default_generator)

  set(default_package "openmpi")
  foreach (generator IN LISTS generators)	  
    superbuild_add_extra_package_test(openmpi "${generator}"
        LABELS  "openmpi"
        TIMEOUT 6400)
  endforeach()
  if (default_package)
    superbuild_enable_install_target("${default_package}/${default_generator}")
  endif ()
endfunction ()

function (superbuild_add_tests)
  add_subdirectory("${CMAKE_SOURCE_DIR}/tests" "${CMAKE_BINARY_DIR}/tests")
endfunction ()

list(APPEND superbuild_version_files
  "${CMAKE_CURRENT_LIST_DIR}/versions.cmake")
#list(APPEND superbuild_ctest_custom_files
#  "${CMAKE_CURRENT_LIST_DIR}/cmake/CTestCustom.cmake")
list(APPEND superbuild_project_roots
  "${CMAKE_CURRENT_LIST_DIR}/projects")

# set the default arguments used for "git clone"
set(_git_clone_arguments_default --progress)

# set the default for cxx11 to be enabled for this project
set(_superbuild_default_cxx11 ON)

add_subdirectory(superbuild)
