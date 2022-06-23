#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#
function(import_libint)
  #- `IMPORT_LIBINT_MAX_AM` is the maximum angular momentum
  #- `IMPORT_LIBINT_DERIV_ORDER_1BODY` is the maximum derivative order for 1-body integrals
  #- `IMPORT_LIBINT_DERIV_ORDER_ERI` is the maximum derivative order for electron repulsion integrals
  #- `IMPORT_LIBINT_DENS_FIT` flags the use of density fitting, enabling the corresponding integrals
  #- `IMPORT_LIBINT_G12` flags the use of explicitly correlated basis functions and enables the corresponding integrals
  # Set hard-coded parameters
  # If a library needs more than this, the file should be changed.
  set(IMPORT_LIBINT_MAX_AM "4")
  set(IMPORT_LIBINT_DERIV_ORDER_1BODY "1")
  set(IMPORT_LIBINT_DERIV_ORDER_ERI "1")
  list(APPEND IMPORT_LIBINT_DENS_FIT_FLAGS "--disable-eri2" "--disable-eri3")
  list(APPEND IMPORT_LIBINT_G12_FLAGS "--disable-g12" "--disable-g12dkh")
  # Uncomment this to enable density fitting up to IMPORT_LIBINT_DERIV_ORDER_ERI derivative.
  #list(IMPORT_LIBINT_DENS_FIT_FLAGS APPEND "--enable-eri2=${IMPORT_LIBINT_DERIV_ORDER_ERI}"
  #                   "--enable-eri3=${IMPORT_LIBINT_DERIV_ORDER_ERI}")
  # Uncomment this to enable explicit correlation G12
  #list(IMPORT_LIBINT_G12_FLAGS APPEND "--enable-g12=${IMPORT_LIBINT_DERIV_ORDER_ERI}"
  #              "--enable-g12dkh=${IMPORT_LIBINT_DERIV_ORDER_ERI}")

  # If the target already exists, do nothing
  if(NOT TARGET Libint2::cxx)
    # Try to find the package locally
    find_package(Libint2 QUIET)

    if(TARGET Libint2::cxx)
      message(STATUS "Libint2::cxx found locally at ${Libint2_DIR}")
    elseif(TARGET libint2_cxx)
      message(STATUS "libint2_cxx found locally at ${Libint2_DIR}")
      add_library(Libint2::cxx ALIAS libint2_cxx)
    else()
      set(Libint2_VERSION "2.7.0-beta.6")
      set(Libint2_TAG "v${Libint2_VERSION}")
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ  Libint2
        GIT_REPOSITORY https://github.com/evaleev/libint.git
        GIT_TAG        ${Libint2_TAG}
        QUIET
      )

    if (NOT EXISTS "${Libint2_SOURCE_DIR}/../libint_build/libint-${Libint2_VERSION}.tgz")
        string(CONCAT libint_msg
          "${Libint2_SOURCE_DIR}/../libint_build/libint-${Libint2_VERSION}.tgz"
          " was not found. The libint2 library will now be configured. This could take a while."
          "Please be patient."
        )

      execute_process(
        COMMAND
          ./autogen.sh
        COMMAND
        ${CMAKE_COMMAND} -E make_directory ../libint_build/
       WORKING_DIRECTORY
        ${Libint2_SOURCE_DIR}
      )


      execute_process(
       COMMAND
       ${Libint2_SOURCE_DIR}/configure --with-max-am=${IMPORT_LIBINT_MAX_AM}
                                       --enable-1body=${IMPORT_LIBINT_DERIV_ORDER_1BODY}
                                       --enable-eri=${IMPORT_LIBINT_DERIV_ORDER_ERI}
                                       ${IMPORT_LIBINT_DENS_FIT_FLAGS}
                                       ${IMPORT_LIBINT_G12_FLAGS}
                                       --enable-generic-code
       WORKING_DIRECTORY
       ${Libint2_SOURCE_DIR}/../libint_build
       )

     # Determine number of cores
     set(LIBINT_EXPORT_CORES 1 CACHE STRING "The number of cores to call make export with.")
     message(STATUS "Exporting the Libint2 library on " ${LIBINT_EXPORT_CORES} " parallel processes.")

      execute_process(
        COMMAND make export -j${LIBINT_EXPORT_CORES}
       WORKING_DIRECTORY
       ${Libint2_SOURCE_DIR}/../libint_build
       )
      endif() # Export library

      if (NOT EXISTS "${Libint2_SOURCE_DIR}/libint-${Libint2_VERSION}")
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xvf libint-${Libint2_VERSION}.tgz
           WORKING_DIRECTORY
         ${Libint2_SOURCE_DIR}/../libint_build
        )
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E copy_directory libint-${Libint2_VERSION} ${Libint2_SOURCE_DIR}/libint-${Libint2_VERSION}
           WORKING_DIRECTORY
         ${Libint2_SOURCE_DIR}/../libint_build
        )
      endif()

      set(Libint2_SOURCE_DIR "${Libint2_SOURCE_DIR}/libint-${Libint2_VERSION}")

      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      string(REPLACE " -Wpedantic" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
      add_subdirectory(${Libint2_SOURCE_DIR} ${Libint2_BINARY_DIR})
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wpedantic")

      # Final check if all went well
      if(TARGET libint2_cxx)
        message(STATUS
          "Libint2::cxx was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Libint2::cxx was not found in your PATH and could not be established "
          "through a download. Try specifying "
          "CMAKE_PREFIX_PATH to point to a candidate installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
      add_library(Libint2::cxx ALIAS libint2_cxx)
    endif()
  endif()
endfunction()
