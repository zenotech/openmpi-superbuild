#[==[.md
# Installation support

When creating packages, these functions may be used in order to ensure that the
resulting package includes the required executables as well as all runtime
dependencies. These are discovered using platform-specific utilties to find out
what libraries are required and then emulating the platform's library searching
logic in order to find dependent libraries. For more details, see each
platform's section.

Due to platform differences, each platform has its own set of functions for
use.
#]==]

set(_superbuild_install_cmake_dir "${CMAKE_CURRENT_LIST_DIR}")
set_property(GLOBAL PROPERTY
  superbuild_has_cleaned FALSE)

include(CMakeParseArguments)

# Find a Python executable to run the `fixup_bundle` scripts.
if (NOT superbuild_python_executable)
  find_package(PythonInterp 2.7)
  if (PYTHONINTERP_FOUND)
    set(superbuild_python_executable
      "${PYTHON_EXECUTABLE}")
  else ()
    message(FATAL_ERROR
      "Could not find a Python executable newer than 2.7; one is required "
      "to create packages on Linux and Windows.")
  endif ()
endif ()

# TODO: error on unrecognized arguments

# TODO: The functions in this file should be grouped and made OS-agnostic.
#       Keyword arguments should be used more and be uniform across all
#       platforms.

#[==[.md
## ELF (Linux)

The superbuild installs ELF binaries using a core function to construct a
command to run the `fixup_bundle.unix.py` script with the correct arguments. It
tries to emulate an ELF runtime loader to determine where to find dependent
files and it copies them to the installation directory.

Calling this function directory should not be necessary. Instead, using the
more specific functions documented later is recommended. The core function is
used as a single place to document the various common arguments available to
the other functions. If an argument is specified by a function, it should not
be passed as the remaining arguments to the function.

```
_superbuild_unix_install_binary(
  LIBDIR <libdir>
  BINARY <path>
  TYPE <module|executable>
  [CLEAN]
  [DESTINATION <destination>]
  [LOCATION <location>]
  [INCLUDE_REGEXES <include-regex>...]
  [EXCLUDE_REGEXES <exclude-regex>...]
  [LOADER_PATHS <loader-paths>...]
  [SEARCH_DIRECTORIES <search-directory>...])
```

A manifest file is kept in the binary directory of the packaging step. This
allows for a library to be installed just once for an entire package. It is
reset when the `CLEAN` argument is present. In addition, the install directory
is removed for non-install targets (based on `superbuild_is_install_target`)
when `CLEAN` is specified. Whether this is necessary or not is maintained
internally and it should almost never need to be provided.

The `DESTINATION` is the absolute path to the installation prefix, including
`DESTDIR`. It defaults to `\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}`. It is
escaped because we want CMake to expand its value at install time, not
configure time.

The `BINARY` argument is the path to the actual executable to install. It must
be an absolute path.

The `TYPE` argument specifies whether an executable or module (e.g., plugin or
standalone library) is being installed. For a module, the `LOCATION` argument
must be given. This is the path under the installation prefix to place the
module. Executables are always installed into `bin`. The libraries that are
found to be required by the installed binary are placed in the subdirectory of
the install destination given by the `LIBDIR` argument.

The `LOADER_PATHS` argument is a list of paths to use when installing a module
to search for libraries that are assumed to be available because of the loading
executable. This is intended to be where libraries assumed to be with an
executable live when installing a plugin for that executable.

The `SEARCH_DIRECTORIES` argument is a list of paths to search for libraries if
the library cannot be found due to rpaths in the binary, `LOADER_PATHS`, or
other runtime-loader logic. If these paths are required to find a library, a
warning is printed at install time.

By default, libraries from the "system" (basically standard `/lib` directories)
are ignored when installing. The `INCLUDE_REGEXES` and `EXCLUDE_REGEXES`
arguments are lists of Python regular expressions to either force-include or
force-exclude from installation. Inclusion overrides exclusion. The provided
regular expressions are also expected to match the full path of the library.
#]==]
function (_superbuild_unix_install_binary)
  set(options
    CLEAN)
  set(values
    DESTINATION
    LIBDIR
    LOCATION
    BINARY
    TYPE)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    LOADER_PATHS
    SEARCH_DIRECTORIES)
  cmake_parse_arguments(_install_binary "${options}" "${values}" "${multivalues}" ${ARGN})

  if (NOT _install_binary_BINARY)
    message(FATAL_ERROR "Cannot install a binary without a path.")
  endif ()

  if (NOT IS_ABSOLUTE "${_install_binary_BINARY}")
    message(FATAL_ERROR "Cannot install a binary without an absolute path (${_install_binary_BINARY}).")
  endif ()

  if (NOT _install_binary_DESTINATION)
    set(_install_binary_DESTINATION
      "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}")
  endif ()

  if (NOT _install_binary_LIBDIR)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} without knowing where to put dependent libraries.")
  endif ()

  if (NOT _install_binary_TYPE)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} without knowing its type.")
  endif ()

  if (_install_binary_TYPE STREQUAL "module" AND NOT _install_binary_LOCATION)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} as a module without knowing where to place it.")
  endif ()

  set(fixup_bundle_arguments)
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --destination ${_install_binary_DESTINATION}")
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --type ${_install_binary_TYPE}")
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --libdir ${_install_binary_LIBDIR}")

  get_property(superbuild_install_no_external_dependencies GLOBAL PROPERTY
    superbuild_install_no_external_dependencies)
  if (superbuild_install_no_external_dependencies)
    set(fixup_bundle_arguments "${fixup_bundle_arguments} --source-only")
  endif ()

  get_property(superbuild_has_cleaned GLOBAL PROPERTY
    superbuild_has_cleaned)
  if (_install_binary_CLEAN OR NOT superbuild_has_cleaned)
    set_property(GLOBAL PROPERTY
      superbuild_has_cleaned TRUE)
    if (superbuild_is_install_target)
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --new")
    else ()
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --clean --new")
    endif ()
  endif ()

  if (_install_binary_LOCATION)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --location \"${_install_binary_LOCATION}\"")
  endif ()

  foreach (include_regex IN LISTS _install_binary_INCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --include \"${include_regex}\"")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_binary_EXCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --exclude \"${exclude_regex}\"")
  endforeach ()

  foreach (loader_path IN LISTS _install_binary_LOADER_PATHS)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --loader-path \"${loader_path}\"")
  endforeach ()

  foreach (search_directory IN LISTS _install_binary_SEARCH_DIRECTORIES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --search \"${search_directory}\"")
  endforeach ()

  install(CODE
    "execute_process(
      COMMAND \"${superbuild_python_executable}\"
              \"${_superbuild_install_cmake_dir}/scripts/fixup_bundle.unix.py\"
              ${fixup_bundle_arguments}
              --manifest    \"${CMAKE_BINARY_DIR}/install.manifest\"
              --source      \"${superbuild_install_location}\"
              \"${_install_binary_BINARY}\"
      RESULT_VARIABLE res
      ERROR_VARIABLE  err)

    if (res)
      message(FATAL_ERROR \"Failed to install ${name}:\n\${err}\")
    endif ()"
    COMPONENT superbuild)
endfunction ()

# A convenience function for installing an executable.
function (_superbuild_unix_install_executable path libdir)
  _superbuild_unix_install_binary(
    BINARY      "${path}"
    LIBDIR      "${libdir}"
    TYPE        executable
    ${ARGN})
endfunction ()

# A convenience function for installing a module.
function (_superbuild_unix_install_module path subdir libdir)
  _superbuild_unix_install_binary(
    BINARY      "${path}"
    LOCATION    "${subdir}"
    LIBDIR      "${libdir}"
    TYPE        module
    ${ARGN})
endfunction ()

#[==[.md
### Forwarding executables

In the ParaView world, "forwarding" executables are used to make packages
standalone. This functionality is provided by KWSys. This creates a small
binary in `bin/` which finds its companion "real" executable under the
corresponding `lib/` directory. It then sets the `LD_LIBRARY_PATH` environment
variable accordingly and executes the real binary.

In order to install these kinds of executables, this function is provided:

```
superbuild_unix_install_program_fwd(<NAME> <LIBRARY PATHS> [<ARG>...])
```

Installs a binary named `NAME` to the package. The `LIBRARY PATHS` argument is
a list of directories to search for the real binary and its libraries. These
paths are assumed to be relative to `superbuild_install_location`. The
libraries are installed to the subdirectory the actual executable is found in.

Note that `LIBRARY PATHS` is a CMake list passed as a single argument.

The following arguments are set by calling this function:

  - `BINARY`
  - `LIBDIR`
  - `LOCATION`
  - `TYPE`
#]==]
function (superbuild_unix_install_program_fwd name paths)
  set(found FALSE)
  foreach (path IN LISTS paths)
    if (EXISTS "${superbuild_install_location}/${path}/${name}")
      _superbuild_unix_install_module("${superbuild_install_location}/${path}/${name}" "${path}" "${path}" ${ARGN})
      set(found TRUE)
      break ()
    endif ()
  endforeach ()

  if (NOT found)
    message(FATAL_ERROR "Unable to find the actual executable for ${name}")
  endif ()

  _superbuild_unix_install_executable("${superbuild_install_location}/bin/${name}" "lib")
endfunction ()

#[==[.md
### Executables

Non-forwarding executables are binaries that may not work in the package
without the proper rpaths or `LD_LIBRARY_PATH` set when running the executable.

```
superbuild_unix_install_program(<PATH> <LIBRARY DIR> [<ARG>...])
```

Installs a program at `PATH` into `bin/` and its dependent libraries into
`LIBRARY DIR` under the install destination. The program must be an absolute
path.

The following arguments are set by calling this function:

  - `BINARY`
  - `LIBDIR`
  - `TYPE` (`executable`)
#]==]
function (superbuild_unix_install_program name libdir)
  _superbuild_unix_install_executable("${name}" "${libdir}" ${ARGN})
endfunction ()

#[==[.md
### Plugins

Plugins include libraries that are meant to be loaded at runtime. It also
includes libraries that are linked to, but need to be installed separately.

```
superbuild_unix_install_plugin(<PATH> <LIBRARY DIR> <SEARCH PATHS> [<ARG>...])
```

Installs a library at `PATH` into `bin/` and its dependent libraries into
`LIBRARY DIR` under the install destination. If the path is not absolute, it is
searched for underneath `superbuild_install_location` with the given `PATH`
under each path in the `SEARCH PATHS` argument.

Note that `SEARCH PATHS` is a CMake list passed as a single argument.

The following arguments are set by calling this function:

  - `BINARY`
  - `LIBDIR`
  - `TYPE` (`module`)
#]==]
function (superbuild_unix_install_plugin name libdir paths)
  if (IS_ABSOLUTE "${name}")
    _superbuild_unix_install_module("${name}" "${paths}" "${libdir}" ${ARGN})
    return ()
  endif ()

  set(found FALSE)
  foreach (path IN LISTS paths)
    if (EXISTS "${superbuild_install_location}/${path}/${name}")
      _superbuild_unix_install_module("${superbuild_install_location}/${path}/${name}" "${path}" "${libdir}" ${ARGN})
      set(found TRUE)
      break ()
    endif ()
  endforeach ()

  if (NOT found)
    string(REPLACE ";" ", " paths_list "${paths}")
    message(FATAL_ERROR "Unable to find the ${name} plugin in ${paths_list}")
  endif ()
endfunction ()

#[==[.md
### Python packages

The superbuild also provides functions to install Python modules and packages.

```
superbuild_unix_install_python(
  MODULES <module>...
  LIBDIR <libdir>
  MODULE_DIRECTORIES <module-path>...
  [MODULE_DESTINATION <destination>]
  [INCLUDE_REGEXES <include-regex>...]
  [EXCLUDE_REGEXES <exclude-regex>...]
  [LOADER_PATHS <loader-paths>...]
  [SEARCH_DIRECTORIES <library-path>...])
```

The list of modules to installed is given to the `MODULES` argument. These
modules (or packages) are searched for at install time in the paths given to
the `MODULE_DIRECTORIES` argument.

Modules are placed in the `MODULE_DESTINATION` under the expected Python module
paths in the package (`lib/python2.7`). By default, `/site-packages` is used.

The `INCLUDE_REGEXES`, `EXCLUDE_REGEXES`, `LOADER_PATHS`, and
`SEARCH_DIRECTORIES` arguments used when installing compiled Python modules
through an internal `superbuild_unix_install_plugin` call.

Note that modules in the list which cannot be found are ignored. This function
also assumes Python 2.7 for now.
#]==]
function (superbuild_unix_install_python)
  set(values
    MODULE_DESTINATION
    LIBDIR)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    LOADER_PATHS
    SEARCH_DIRECTORIES
    MODULE_DIRECTORIES
    MODULES)
  cmake_parse_arguments(_install_python "${options}" "${values}" "${multivalues}" ${ARGN})

  if (NOT _install_python_LIBDIR)
    message(FATAL_ERROR "Cannot install Python modules without knowing where to put dependent libraries.")
  endif ()

  if (NOT _install_python_MODULES)
    message(FATAL_ERROR "No modules specified.")
  endif ()

  if (NOT _install_python_MODULE_DIRECTORIES)
    message(FATAL_ERROR "No modules search paths specified.")
  endif ()

  set(fixup_bundle_arguments)

  if (NOT _install_python_MODULE_DESTINATION)
    set(_install_python_MODULE_DESTINATION "/site-packages")
  endif ()

  foreach (include_regex IN LISTS _install_python_INCLUDE_REGEXES)
    list(APPEND fixup_bundle_arguments
      --include "${include_regex}")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_python_EXCLUDE_REGEXES)
    list(APPEND fixup_bundle_arguments
      --exclude "${exclude_regex}")
  endforeach ()

  foreach (search_directory IN LISTS _install_python_SEARCH_DIRECTORIES)
    list(APPEND fixup_bundle_arguments
      --search "${search_directory}")
  endforeach ()

  foreach (loader_path IN LISTS _install_python_LOADER_PATHS)
    list(APPEND fixup_bundle_arguments
      --loader-path "${loader_path}")
  endforeach ()

  get_property(superbuild_install_no_external_dependencies GLOBAL PROPERTY
    superbuild_install_no_external_dependencies)
  if (superbuild_install_no_external_dependencies)
    list(APPEND fixup_bundle_arguments --source-only)
  endif ()

  install(CODE
    "set(superbuild_python_executable \"${superbuild_python_executable}\")
    set(superbuild_install_location \"${superbuild_install_location}\")
    include(\"${_superbuild_install_cmake_dir}/scripts/fixup_python.unix.cmake\")
    set(python_modules \"${_install_python_MODULES}\")
    set(module_directories \"${_install_python_MODULE_DIRECTORIES}\")

    set(fixup_bundle_arguments \"${fixup_bundle_arguments}\")
    set(bundle_destination \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}\")
    set(bundle_manifest \"${CMAKE_BINARY_DIR}/install.manifest\")
    set(libdir \"${_install_python_LIBDIR}\")

    foreach (python_module IN LISTS python_modules)
      superbuild_unix_install_python_module(\"\${CMAKE_INSTALL_PREFIX}\"
        \"\${python_module}\" \"\${module_directories}\" \"lib/python2.7${_install_python_MODULE_DESTINATION}\")
    endforeach ()"
    COMPONENT superbuild)
endfunction ()

#[==[.md
## Mach-O (macOS)

The superbuild installs Mach-O binaries using a core function to construct an
`.app` bundle using the `fixup_bundle.apple.py` script with the correct
arguments. It tries to emulate an Mach-O runtime loader to determine where to
find dependent files and it copies them to the installation directory. It also
fixes up internal library references so that the resulting package is
self-contained and relocatable.

### Create an application bundle.

```
superbuild_apple_create_app(<DESTINATION> <NAME> <BINARY>
  [INCLUDE_REGEXES <regex>...]
  [EXCLUDE_REGEXES <regex>...]
  [SEARCH_DIRECTORIES <library-path>...]
  [PLUGINS <plugin>...]
  [FAKE_PLUGIN_PATHS] [CLEAN])
```

Creates a `<NAME>.app` bundle. The bundle is placed in `<DESTINATION>` with
`<BINARY>` (an absolute path) as a main executable for the bundle (under the
`MacOS/` directory). Libraries are searched for and placed into the bundle from
the `SEARCH_DIRECTORIES` specified. Library IDs and link paths are rewritten to
use `@executable_path` or `@loader_path` as necessary.

To exclude libraries from the bundle, use Python regular expressions as
arguments to the `EXCLUDE_REGEXES` keyword. To include any otherwise-excluded
libraries, use `INCLUDE_REGEXES`. System libraries and frameworks are excluded
by default.

The `CLEAN` argument starts a new bundle, otherwise the bundle is left as-is
(and is expected to have been created by this call).

Plugins may be listed under the `PLUGINS` keyword and will be installed to the
`Plugins/` directory in the bundle. These are full paths to the plugin
binaries. If `FAKE_PLUGIN_PATHS` is given, the plugin is treated as its own
`@executable_path` which is useful when packaging plugins which may be used for
multiple applications and may require additional libraries depending on the
application.
#]==]
function (superbuild_apple_create_app destination name binary)
  set(options
    CLEAN
    FAKE_PLUGIN_PATHS)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    SEARCH_DIRECTORIES
    PLUGINS)
  cmake_parse_arguments(_create_app "${options}" "" "${multivalues}" ${ARGN})

  set(fixup_bundle_arguments)

  if (_create_app_CLEAN)
    if (superbuild_is_install_target)
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --new")
    else ()
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --clean --new")
    endif ()
  endif ()

  if (_create_app_FAKE_PLUGIN_PATHS)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --fake-plugin-paths")
  endif ()

  foreach (include_regex IN LISTS _create_app_INCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --include \"${include_regex}\"")
  endforeach ()

  foreach (exclude_regex IN LISTS _create_app_EXCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --exclude \"${exclude_regex}\"")
  endforeach ()

  foreach (search_directory IN LISTS _create_app_SEARCH_DIRECTORIES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --search \"${search_directory}\"")
  endforeach ()

  foreach (plugin IN LISTS _create_app_PLUGINS)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --plugin \"${plugin}\"")
  endforeach ()

  install(CODE
    "execute_process(
      COMMAND \"${_superbuild_install_cmake_dir}/scripts/fixup_bundle.apple.py\"
              --bundle      \"${name}\"
              --destination \"${destination}\"
              ${fixup_bundle_arguments}
              --manifest    \"${CMAKE_BINARY_DIR}/${name}.manifest\"
              --type        executable
              \"${binary}\"
      RESULT_VARIABLE res
      ERROR_VARIABLE  err)

    if (res)
      message(FATAL_ERROR \"Failed to install ${name}:\n\${err}\")
    endif ()"
    COMPONENT superbuild)
endfunction ()

#[==[.md
### Utility executables

```
superbuild_apple_install_utility(<DESTINATION> <NAME> <BINARY>
  [INCLUDE_REGEXES <regex>...]
  [EXCLUDE_REGEXES <regex>...]
  [SEARCH_DIRECTORIES <library-path>...])
```

Adds a binary to the `bin/` path of the bundle. Required libraries are
installed and fixed up using `@executable_path`.

A previous call must have been made with matching `DESTINATION` and `NAME`
arguments; this call will not create a new application bundle.

The `INCLUDE_REGEXES`, `EXCLUDE_REGEXES`, and `SEARCH_DIRECTORIES` arguments
are the same as those for `superbuild_apple_create_app`.
#]==]
function (superbuild_apple_install_utility destination name binary)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    SEARCH_DIRECTORIES)
  cmake_parse_arguments(_install_utility "" "" "${multivalues}" ${ARGN})

  set(fixup_bundle_arguments)

  foreach (include_regex IN LISTS _install_utility_INCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --include \"${include_regex}\"")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_utility_EXCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --exclude \"${exclude_regex}\"")
  endforeach ()

  foreach (search_directory IN LISTS _install_utility_SEARCH_DIRECTORIES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --search \"${search_directory}\"")
  endforeach ()

  install(CODE
    "execute_process(
      COMMAND \"${_superbuild_install_cmake_dir}/scripts/fixup_bundle.apple.py\"
              --bundle      \"${name}\"
              --destination \"${destination}\"
              ${fixup_bundle_arguments}
              --manifest    \"${CMAKE_BINARY_DIR}/${name}.manifest\"
              --type        utility
              \"${binary}\"
      RESULT_VARIABLE res
      ERROR_VARIABLE  err)

    if (res)
      message(FATAL_ERROR \"Failed to install ${name}:\n\${err}\")
    endif ()"
    COMPONENT superbuild)
endfunction ()

#[==[.md
### Module libraries

```
superbuild_apple_install_module(<DESTINATION> <NAME> <BINARY> <LOCATION>
  [INCLUDE_REGEXES <regex>...]
  [EXCLUDE_REGEXES <regex>...]
  [SEARCH_DIRECTORIES <library-path>...])
```

Adds a library to the `<LOCATION>` path of the bundle. Required libraries which
have not been installed by previous executable installs are installed and fixed
up using `@loader_path`. Use this to install things such as compiled language
modules and the like.

A previous call must have been made with matching `DESTINATION` and `NAME`
arguments; this call will not create a new application bundle.

The `INCLUDE_REGEXES`, `EXCLUDE_REGEXES`, and `SEARCH_DIRECTORIES` arguments
are the same as those for `superbuild_apple_create_app`.
#]==]
function (superbuild_apple_install_module destination name binary location)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    SEARCH_DIRECTORIES)
  cmake_parse_arguments(_install_module "" "" "${multivalues}" ${ARGN})

  set(fixup_bundle_arguments)

  foreach (include_regex IN LISTS _install_module_INCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --include \"${include_regex}\"")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_module_EXCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --exclude \"${exclude_regex}\"")
  endforeach ()

  foreach (search_directory IN LISTS _install_module_SEARCH_DIRECTORIES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --search \"${search_directory}\"")
  endforeach ()

  install(CODE
    "execute_process(
      COMMAND \"${_superbuild_install_cmake_dir}/scripts/fixup_bundle.apple.py\"
              --bundle      \"${name}\"
              --destination \"${destination}\"
              ${fixup_bundle_arguments}
              --manifest    \"${CMAKE_BINARY_DIR}/${name}.manifest\"
              --location    \"${location}\"
              --type        module
              \"${binary}\"
      RESULT_VARIABLE res
      ERROR_VARIABLE  err)

    if (res)
      message(FATAL_ERROR \"Failed to install ${name}:\n\${err}\")
    endif ()"
    COMPONENT superbuild)
endfunction ()

#[==[.md
### Python packages

The superbuild also provides functions to install Python modules and packages.

```
superbuild_apple_install_python(<DESTINATION> <NAME>
  MODULES <module>...
  MODULE_DIRECTORIES <module-path>...
  [SEARCH_DIRECTORIES <library-path>...])
```

The list of modules to installed is given to the `MODULES` argument. These
modules (or packages) are searched for at install time in the paths given to
the `MODULE_DIRECTORIES` argument.

Modules are placed in the `Python/` directory in the given application bundle.

A previous call must have been made with matching `DESTINATION` and `NAME`
arguments; this call will not create a new application bundle.

Note that modules in the list which cannot be found are ignored.
#]==]
function (superbuild_apple_install_python destination name)
  set(multivalues
    SEARCH_DIRECTORIES
    MODULE_DIRECTORIES
    MODULES)
  cmake_parse_arguments(_install_python "" "" "${multivalues}" ${ARGN})

  if (NOT _install_python_MODULES)
    message(FATAL_ERROR "No modules specified.")
  endif ()

  if (NOT _install_python_MODULE_DIRECTORIES)
    message(FATAL_ERROR "No modules search paths specified.")
  endif ()

  set(fixup_bundle_arguments)

  foreach (search_directory IN LISTS _install_python_SEARCH_DIRECTORIES)
    list(APPEND fixup_bundle_arguments
      --search "${search_directory}")
  endforeach ()

  install(CODE
    "include(\"${_superbuild_install_cmake_dir}/scripts/fixup_python.apple.cmake\")
    set(python_modules \"${_install_python_MODULES}\")
    set(module_directories \"${_install_python_MODULE_DIRECTORIES}\")

    set(fixup_bundle_arguments \"${fixup_bundle_arguments}\")
    set(bundle_destination \"${destination}\")
    set(bundle_name \"${name}\")
    set(bundle_manifest \"${CMAKE_BINARY_DIR}/${name}.manifest\")

    foreach (python_module IN LISTS python_modules)
      superbuild_apple_install_python_module(\"\${bundle_destination}/\${bundle_name}\"
        \"\${python_module}\" \"\${module_directories}\" \"Contents/Python\")
    endforeach ()"
    COMPONENT superbuild)
endfunction ()

#[==[.md
## PE-COFF (Windows)

The superbuild installs PE-COFF binaries using a core function to construct a
command to run the `fixup_bundle.windows.py` script with the correct arguments.
It tries to emulate the runtime loader to determine where to find dependent
files and it copies them to the installation directory.

Calling this function directory should not be necessary. Instead, using the
more specific functions documented later is recommended. The core function is
used as a single place to document the various common arguments available to
the other functions. If an argument is specified by a function, it should not
be passed as the remaining arguments to the function.

```
_superbuild_windows_install_binary(
  LIBDIR <libdir>
  BINARY <path>
  TYPE <module|executable>
  [CLEAN]
  [DESTINATION <destination>]
  [LOCATION <location>]
  [INCLUDE_REGEXES <include-regex>...]
  [EXCLUDE_REGEXES <exclude-regex>...]
  [BINARY_LIBDIR <binary_libdirs>...]
  [SEARCH_DIRECTORIES <search-directory>...])
```

A manifest file is kept in the binary directory of the packaging step. This
allows for a library to be installed just once for an entire package. It is
reset when the `CLEAN` argument is present. In addition, the install directory
is removed for non-install targets (based on `superbuild_is_install_target`)
when `CLEAN` is specified. Whether this is necessary or not is maintained
internally and it should almost never need to be provided.

The `DESTINATION` is the absolute path to the installation prefix, including
`DESTDIR`. It defaults to `\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}`. It is
escaped because we want CMake to expand its value at install time, not
configure time.

The `BINARY` argument is the path to the actual executable to install. It must
be an absolute path.

The `TYPE` argument specifies whether an executable or module (e.g., plugin or
standalone library) is being installed. For a module, the `LOCATION` argument
must be given. This is the path under the installation prefix to place the
module. Executables are always installed into `bin`. The libraries that are
found to be required by the installed binary are placed in the subdirectory of
the install destination given by the `LIBDIR` argument.

The `BINARY_LIBDIR` argument is a list of paths which the binary is assumed to
already be searching when loading a module.

The `SEARCH_DIRECTORIES` argument is a list of paths to search for libraries if
the library cannot be found due to rpaths in the binary, `LOADER_PATHS`, or
other runtime-loader logic. If these paths are required to find a library, a
warning is printed at install time.

By default, Microsoft's C runtime libraries are ignored when installing. The
`INCLUDE_REGEXES` and `EXCLUDE_REGEXES` arguments are lists of Python regular
expressions to either force-include or force-exclude from installation.
Inclusion overrides exclusion. The provided regular expressions are also
expected to match the full path of the library.
#]==]
function (_superbuild_windows_install_binary)
  set(options
    CLEAN)
  set(values
    DESTINATION
    LIBDIR
    LOCATION
    BINARY
    TYPE)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    BINARY_LIBDIR
    SEARCH_DIRECTORIES)
  cmake_parse_arguments(_install_binary "${options}" "${values}" "${multivalues}" ${ARGN})

  if (NOT _install_binary_BINARY)
    message(FATAL_ERROR "Cannot install a binary without a path.")
  endif ()

  if (NOT IS_ABSOLUTE "${_install_binary_BINARY}")
    message(FATAL_ERROR "Cannot install a binary without an absolute path (${_install_binary_BINARY}).")
  endif ()

  if (NOT _install_binary_DESTINATION)
    set(_install_binary_DESTINATION
      "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}")
  endif ()

  if (NOT _install_binary_LIBDIR)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} without knowing where to put dependent libraries.")
  endif ()

  if (NOT _install_binary_TYPE)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} without knowing its type.")
  endif ()

  if (_install_binary_TYPE STREQUAL "module" AND NOT _install_binary_LOCATION)
    message(FATAL_ERROR "Cannot install ${_install_binary_BINARY} as a module without knowing where to place it.")
  endif ()

  if (NOT _install_binary_BINARY_LIBDIR)
    list(APPEND _install_binary_BINARY_LIBDIR "bin")
  endif()

  set(fixup_bundle_arguments)
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --destination ${_install_binary_DESTINATION}")
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --type ${_install_binary_TYPE}")
  set(fixup_bundle_arguments
    "${fixup_bundle_arguments} --libdir ${_install_binary_LIBDIR}")

  get_property(superbuild_has_cleaned GLOBAL PROPERTY
    superbuild_has_cleaned)
  if (_install_binary_CLEAN OR NOT superbuild_has_cleaned)
    set_property(GLOBAL PROPERTY
      superbuild_has_cleaned TRUE)
    if (superbuild_is_install_target)
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --new")
    else ()
      set(fixup_bundle_arguments
        "${fixup_bundle_arguments} --clean --new")
    endif ()
  endif ()

  if (_install_binary_LOCATION)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --location \"${_install_binary_LOCATION}\"")
  endif ()

  foreach (include_regex IN LISTS _install_binary_INCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --include \"${include_regex}\"")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_binary_EXCLUDE_REGEXES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --exclude \"${exclude_regex}\"")
  endforeach ()

  foreach(binary_libdir IN LISTS _install_binary_BINARY_LIBDIR)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --binary-libdir \"${binary_libdir}\"")
  endforeach()

  foreach (search_directory IN LISTS _install_binary_SEARCH_DIRECTORIES)
    set(fixup_bundle_arguments
      "${fixup_bundle_arguments} --search \"${search_directory}\"")
  endforeach ()

  install(CODE
    "execute_process(
      COMMAND \"${superbuild_python_executable}\"
              \"${_superbuild_install_cmake_dir}/scripts/fixup_bundle.windows.py\"
              ${fixup_bundle_arguments}
              --manifest    \"${CMAKE_BINARY_DIR}/install.manifest\"
              \"${_install_binary_BINARY}\"
      RESULT_VARIABLE res
      ERROR_VARIABLE  err)

    if (res)
      message(FATAL_ERROR \"Failed to install ${name}:\n\${err}\")
    endif ()"
    COMPONENT superbuild)
endfunction ()

# A convenience function for installing an executable.
function (_superbuild_windows_install_executable path libdir)
  _superbuild_windows_install_binary(
    BINARY      "${path}"
    LIBDIR      "${libdir}"
    TYPE        executable
    ${ARGN})
endfunction ()

# A convenience function for installing a module.
function (_superbuild_windows_install_module path subdir libdir)
  _superbuild_windows_install_binary(
    BINARY      "${path}"
    LOCATION    "${subdir}"
    LIBDIR      "${libdir}"
    TYPE        module
    ${ARGN})
endfunction ()

#[==[.md
### Executables

Non-forwarding executables are binaries that may not work in the package
without the proper rpaths or `LD_LIBRARY_PATH` set when running the executable.

```
superbuild_windows_install_program(<NAME> <LIBDIR>)
```

Installs a program at `NAME` into `bin/` and its dependent libraries into
`LIBDIR` under the install destination. The program is assumed to be in the
installation prefix as `bin/<NAME>.exe`.

The following arguments are set by calling this function:

  - `BINARY`
  - `LIBDIR`
  - `TYPE` (`executable`)
#]==]
function (superbuild_windows_install_program name libdir)
  _superbuild_windows_install_executable("${superbuild_install_location}/bin/${name}.exe" "${libdir}" ${ARGN})
endfunction ()

#[==[.md
### Plugins

Plugins include libraries that are meant to be loaded at runtime. It also
includes libraries that are linked to, but need to be installed separately.

```
superbuild_windows_install_plugin(<FILENAME> <LIBDIR> <SEARCH PATHS> [<ARG>...])
```

Installs a library named `FILENAME` into `bin/` and its dependent libraries
into `LIBDIR` under the install destination. The given filename is searched for
under each path in the `SEARCH PATHS` argument.

Note that `SEARCH PATHS` is a CMake list passed as a single argument.

The following arguments are set by calling this function:

  - `BINARY`
  - `LIBDIR`
  - `LOCATION`
  - `TYPE` (`module`)
#]==]
function (superbuild_windows_install_plugin name libdir paths)
  if (IS_ABSOLUTE "${name}")
    _superbuild_windows_install_module("${name}" "${paths}" "${libdir}" ${ARGN})
    return ()
  endif ()

  set(found FALSE)
  foreach (path IN LISTS paths)
    if (EXISTS "${superbuild_install_location}/${path}/${name}")
      _superbuild_windows_install_module("${superbuild_install_location}/${path}/${name}" "${path}" "${libdir}" ${ARGN})
      set(found TRUE)
      break ()
    endif ()
  endforeach ()

  if (NOT found)
    string(REPLACE ";" ", " paths_list "${paths}")
    message(FATAL_ERROR "Unable to find the ${name} plugin in ${paths_list}")
  endif ()
endfunction ()

#[==[.md
### Python packages

The superbuild also provides functions to install Python modules and packages.

```
superbuild_windows_install_python(
  MODULES <module>...
  MODULE_DIRECTORIES <module-path>...
  [MODULE_DESTINATION <destination>]
  [INCLUDE_REGEXES <include-regex>...]
  [EXCLUDE_REGEXES <exclude-regex>...]
  [SEARCH_DIRECTORIES <library-path>...])
```

The list of modules to installed is given to the `MODULES` argument. These
modules (or packages) are searched for at install time in the paths given to
the `MODULE_DIRECTORIES` argument.

Modules are placed in the `MODULE_DESTINATION` under the expected Python module
paths in the package (`bin/Lib`). By default, `/site-packages` is used.

The `INCLUDE_REGEXES`, `EXCLUDE_REGEXES`, and `SEARCH_DIRECTORIES` used when
installing compiled Python modules through `superbuild_windows_install_plugin`.

Note that modules in the list which cannot be found are ignored.
#]==]
function (superbuild_windows_install_python)
  set(values
    MODULE_DESTINATION)
  set(multivalues
    INCLUDE_REGEXES
    EXCLUDE_REGEXES
    SEARCH_DIRECTORIES
    MODULE_DIRECTORIES
    MODULES)
  cmake_parse_arguments(_install_python "${options}" "${values}" "${multivalues}" ${ARGN})

  if (NOT _install_python_MODULES)
    message(FATAL_ERROR "No modules specified.")
  endif ()

  if (NOT _install_python_MODULE_DIRECTORIES)
    message(FATAL_ERROR "No modules search paths specified.")
  endif ()

  set(fixup_bundle_arguments)

  if (NOT _install_python_MODULE_DESTINATION)
    set(_install_python_MODULE_DESTINATION "/site-packages")
  endif ()

  foreach (include_regex IN LISTS _install_python_INCLUDE_REGEXES)
    list(APPEND fixup_bundle_arguments
      --include "${include_regex}")
  endforeach ()

  foreach (exclude_regex IN LISTS _install_python_EXCLUDE_REGEXES)
    list(APPEND fixup_bundle_arguments
      --exclude "${exclude_regex}")
  endforeach ()

  foreach (search_directory IN LISTS _install_python_SEARCH_DIRECTORIES)
    list(APPEND fixup_bundle_arguments
      --search "${search_directory}")
  endforeach ()

  install(CODE
    "set(superbuild_python_executable \"${superbuild_python_executable}\")
    include(\"${_superbuild_install_cmake_dir}/scripts/fixup_python.windows.cmake\")
    set(python_modules \"${_install_python_MODULES}\")
    set(module_directories \"${_install_python_MODULE_DIRECTORIES}\")

    set(fixup_bundle_arguments \"${fixup_bundle_arguments}\")
    set(bundle_destination \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}\")
    set(bundle_manifest \"${CMAKE_BINARY_DIR}/install.manifest\")

    foreach (python_module IN LISTS python_modules)
      superbuild_windows_install_python_module(\"\${CMAKE_INSTALL_PREFIX}\"
        \"\${python_module}\" \"\${module_directories}\" \"bin/Lib${_install_python_MODULE_DESTINATION}\")
    endforeach ()"
    COMPONENT superbuild)
endfunction ()
