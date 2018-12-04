#[==[.md
# Packaging support

One use case of the superbuild is to build packages for projects in order to
distribute for use as release binaries. The superbuild creates these packages
as tests. The reason it isn't done as a CPack step of the build is because
CPack only supports a single package per build. Multiple formats are supported,
but not distinct packages. Another reason is that CPack runs the `install` step
of a project which redoes a build of all targets. The superbuild may have "use
master" sources and when making a package, we don't want to change what is
being packaged.

The general strategy for the tests is to have a CMake project generated in the
build tree which includes the necessary `.bundle.cmake` files. These files
contain install code and can use CPack variables to change the generated
package.
#]==]

set(_superbuild_packaging_cmake_dir "${CMAKE_CURRENT_LIST_DIR}")

# TODO: link to the right section in SuperbuildVariables.md
#[==[.md
## Adding a package test

The `superbuild_add_extra_package_test` function handles the logic for adding a
test which builds the package. Due to the way CPack works, only one packaging
test may be run concurrently.

```
superbuild_add_extra_package_test(<NAME> <GENERATOR>
  [<PROPERTY> <VALUE>]...)
```

Adds a test with the name `cpack-NAME-GENERATOR`. The packaging rules are
handled by including a `NAME.bundle.cmake` file. The same include paths used in
the build are available in the packaging steps. By default, only the variables
in the [SuperbuildVariables][] packaging section are available. Other variables
may be passed to the packaging step by adding the variable name to the
`superbuild_export_variables` list. The value of the variable available when
adding the test is used.

All other arguments are set as properties on the tests. The only reserved
property is the `RESOURCE_LOCK` property.

[SuperbuildVariables]: SuperbuildVariables.md
#]==]

# TODO: use a PROPERTIES argument
# TODO: use a VARIABLES argument
function (superbuild_add_extra_package_test name generator)
  set(superbuild_extra_variables)
  foreach (variable IN LISTS superbuild_export_variables)
    set(superbuild_extra_variables
      "${superbuild_extra_variables}set(\"${variable}\" \"${${variable}}\")\n")
  endforeach ()

  set(cpack_source_dir "${CMAKE_BINARY_DIR}/cpack/${name}/${generator}")
  # Create a build directory so that the installation variant doesn't conflict.
  set(cpack_build_dir "${cpack_source_dir}/build")
  configure_file(
    "${_superbuild_packaging_cmake_dir}/superbuild_package_cmakelists.cmake.in"
    "${cpack_source_dir}/CMakeLists.txt"
    @ONLY)

  file(MAKE_DIRECTORY "${cpack_build_dir}")

  set_property(GLOBAL APPEND
    PROPERTY
      _superbuild_packages "${name}/${generator}")

  add_test(
    NAME    "cpack-${name}-${generator}"
    COMMAND "${CMAKE_COMMAND}"
            -Dname=${name}
            -Dcmake_generator=${CMAKE_GENERATOR}
            -Dcpack_generator=${generator}
            -Doutput_directory=${CMAKE_BINARY_DIR}
            -Dsource_directory=${cpack_source_dir}
            -Dbuild_directory=${cpack_build_dir}
            -P "${_superbuild_packaging_cmake_dir}/scripts/package_test.cmake"
    WORKING_DIRECTORY "${cpack_build_dir}")

  set_tests_properties("cpack-${name}-${generator}"
    PROPERTIES
      RESOURCE_LOCK cpack
      ${ARGN})
endfunction ()

#[==[.md
In addition to packages, a package may be used as a template for the `install`
target of the superbuild.

```
superbuild_enable_install_target(<DEFAULT>)
```

This uses a user-selectable `.bundle.cmake` to control the `install` target of
the superbuild. The default should be in the form `<NAME>/<GENERATOR>`. An
error is produced if the test for the package does not exist.
#]==]

function (superbuild_enable_install_target default)
  get_property(all_packages GLOBAL
    PROPERTY _superbuild_packages)

  set(SUPERBUILD_DEFAULT_INSTALL "${default}"
    CACHE STRING "The package to install by default")
  set_property(CACHE SUPERBUILD_DEFAULT_INSTALL
    PROPERTY
      STRINGS "${all_packages}")

  if (SUPERBUILD_DEFAULT_INSTALL)
    set(cpack_source_dir "${CMAKE_BINARY_DIR}/cpack/${SUPERBUILD_DEFAULT_INSTALL}")
    set(cpack_build_dir "${cpack_source_dir}/install")
    file(MAKE_DIRECTORY "${cpack_build_dir}")

    if (NOT EXISTS "${cpack_source_dir}")
      message(FATAL_ERROR
        "The ${SUPERBUILD_DEFAULT_INSTALL} package does not exist; it cannot "
        "be used as the default \"install\" target.")
    endif ()

    install(CODE
      "file(MAKE_DIRECTORY \"${cpack_build_dir}\")
  execute_process(
    COMMAND \"${CMAKE_COMMAND}\"
            \"-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}\"
            \"-Dsuperbuild_is_install_target:BOOL=ON\"
            \"${cpack_source_dir}\"
    RESULT_VARIABLE   res
    WORKING_DIRECTORY \"${cpack_build_dir}\")

  if (res)
    message(FATAL_ERROR \"Failed to configure the ${SUPERBUILD_DEFAULT_INSTALL} package.\")
  endif ()

  execute_process(
    COMMAND \"${CMAKE_COMMAND}\"
            --build \"${cpack_build_dir}\"
            --target install
    RESULT_VARIABLE res)

  if (res)
    message(FATAL_ERROR \"Failed to install the ${SUPERBUILD_DEFAULT_INSTALL} package.\")
  endif ()"
      COMPONENT install)
  endif ()
endfunction ()
