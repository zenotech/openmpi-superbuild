#=========================================================================
#
#  Program:   ParaView
#
#  Copyright (c) Kitware, Inc.
#  All rights reserved.
#  See Copyright.txt or http://www.paraview.org/HTML/Copyright.html for details.
#
#     This software is distributed WITHOUT ANY WARRANTY; without even
#     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#     PURPOSE.  See the above copyright notice for more information.
#
#=========================================================================

find_package(Git)

#[==[.md
# Detect the version of a source tree

When creating packages, it can be useful to know the specific version of the
source that is being built. To that end, this module provides functions which
determine a version number for a source based on its source selection. It uses
the `<NAME>_SOURCE_DIR` (for a `source` selection) or the build tree location
(for a `git` selection) to query the version of the checked out code using `git
describe`.

If it turns out that Git is either not available or the source directory is not
a Git checkout, it reads a file in the source tree if available and if all else
fails, falls back to a static string.
#]==]

function (_superbuild_detect_version_git var source_dir default version_file)
  set(major)
  set(minor)
  set(patch)
  set(full)
  set(patch_extra)
  set(result -1)

  if (GIT_FOUND AND source_dir)
    execute_process(
      COMMAND         "${GIT_EXECUTABLE}"
                      rev-parse
                      --is-inside-work-tree
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
      WORKING_DIRECTORY "${source_dir}"
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    if (NOT result)
      execute_process(
        COMMAND         "${GIT_EXECUTABLE}"
                        describe
                        --tags
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        WORKING_DIRECTORY "${source_dir}"
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif ()
  endif ()

  # If `git describe` failed, check for a version file.
  if (result)
    set(version_path "${source_dir}/${version_file}")
    if (source_dir AND version_file AND EXISTS "${version_path}")
      # Read the first line from the version file as the version number.
      file(STRINGS "${version_path}" output
        LIMIT_COUNT 1)
    else ()
      set(output "${default}")
    endif ()
  endif ()

  # Split the version number into fields.
  if (output MATCHES "([0-9]+)\\.([0-9]+)\\.([0-9]+)-?(.*)")
    message(STATUS "Determined source version for ${project}: ${CMAKE_MATCH_0}")
    set(full "${CMAKE_MATCH_0}")
    set(major "${CMAKE_MATCH_1}")
    set(minor "${CMAKE_MATCH_2}")
    set(patch "${CMAKE_MATCH_3}")
    set(patch_extra "${CMAKE_MATCH_4}")
  else ()
    message(FATAL_ERROR
      "Failed to determine the version for ${var}; got ${output}")
  endif ()

  # Set variables in the parent scope if they're available.
  if (full)
    set("${var}_VERSION" "${major}.${minor}" PARENT_SCOPE)
    set("${var}_VERSION_MAJOR" "${major}" PARENT_SCOPE)
    set("${var}_VERSION_MINOR" "${minor}" PARENT_SCOPE)
    set("${var}_VERSION_PATCH" "${patch}" PARENT_SCOPE)
    set("${var}_VERSION_PATCH_EXTRA" "${patch_extra}" PARENT_SCOPE)
    set("${var}_VERSION_FULL" "${full}" PARENT_SCOPE)
    if (patch_extra)
      set("${var}_VERSION_IS_RELEASE" FALSE PARENT_SCOPE)
    else ()
      set("${var}_VERSION_IS_RELEASE" TRUE PARENT_SCOPE)
    endif ()
  endif ()
endfunction ()

# Set a variable in the parent scope properly while still making it available
# in the current scope..
macro (_superbuild_set_up variable value)
  set("${variable}" "${value}"
    PARENT_SCOPE)
  set("${variable}" "${value}")
endmacro ()

#[==[.md
```
superbuild_set_version_variables(<PROJECT> <DEFAULT> <INCLUDE FILE> [<VERSION FILE>])
```

This will write out a file to `<INCLUDE FILE>` which may be `include`'d after
this function to set variables related to the versions of the given
`<PROJECT>`. If the version cannot be determined (e.g., because the project
will be cloned during the build), the given `DEFAULT` version will be used.

If there is a source directory to be used for the project, the `<VERSION FILE>`
will be used to get the version number. If it is empty or not provided, the
default will be used instead.

The variables available after inclusion are:

 `<PROJECT>_version` (as `<major>.<minor>`)
 `<PROJECT>_version_major`
 `<PROJECT>_version_minor`
 `<PROJECT>_version_patch`
 `<PROJECT>_version_patch_extra` (e.g., `rc1`)
 `<PROJECT>_version_suffix` (equivalent to `-<patch_extra>` if `patch_extra` is non-empty)
 `<PROJECT>_version_full`
 `<PROJECT>_version_is_release` (`TRUE` if the suffix is empty, `FALSE` otherwise)
#]==]
function (superbuild_set_version_variables project default include_file)
  set(source_dir "")
  if ((NOT ${project}_FROM_GIT AND ${project}_FROM_SOURCE_DIR) OR ${project}_SOURCE_SELECTION STREQUAL "source")
    set(source_dir "${${project}_SOURCE_DIR}")
  elseif (${project}_SOURCE_SELECTION STREQUAL "git")
    set(source_dir "${CMAKE_BINARY_DIR}/superbuild/${project}/src")
  endif ()
  _superbuild_detect_version_git("${project}" "${source_dir}" "${default}" "${ARGV3}")

  _superbuild_set_up("${project}_version" "${${project}_VERSION}")
  _superbuild_set_up("${project}_version_major" "${${project}_VERSION_MAJOR}")
  _superbuild_set_up("${project}_version_minor" "${${project}_VERSION_MINOR}")
  _superbuild_set_up("${project}_version_patch" "${${project}_VERSION_PATCH}")
  _superbuild_set_up("${project}_version_patch_extra" "${${project}_VERSION_PATCH_EXTRA}")
  if (${project}_version_patch_extra)
    _superbuild_set_up("${project}_version_suffix" "-${${project}_version_patch_extra}")
  else ()
    _superbuild_set_up("${project}_version_suffix" "")
  endif ()
  _superbuild_set_up("${project}_version_full" "${${project}_VERSION_FULL}")
  _superbuild_set_up("${project}_version_is_release" "${${project}_VERSION_IS_RELEASE}")

  if (include_file)
    file(WRITE "${_superbuild_module_gen_dir}/${include_file}" "")
    foreach (variable IN ITEMS "" _major _minor _patch _patch_extra _suffix _full _is_release)
      file(APPEND "${_superbuild_module_gen_dir}/${include_file}"
        "set(\"${project}_version${variable}\" \"${${project}_version${variable}}\")\n")
    endforeach ()
  endif ()
endfunction ()
