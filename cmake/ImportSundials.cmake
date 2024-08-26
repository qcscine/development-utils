#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_sundials)
  # If the target already exists, do nothing
  if(NOT TARGET sundials)
    find_package(sundials QUIET)
    if(TARGET SUNDIALS::cvode)
      message(STATUS "Found sundials at ${sundials_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ sundials
        URL https://github.com/LLNL/sundials/releases/download/v6.7.0/sundials-6.7.0.tar.gz
        QUIET
      )

      if(SCINE_PARALLELIZE)
        set(ENABLE_OPENMP ON)
      endif()
      set(BUILD_ARKODE OFF)

      add_subdirectory(${sundials_SOURCE_DIR} ${sundials_BINARY_DIR})

      # Final check if all went well
      if(EXISTS "${sundials_SOURCE_DIR}/CMakeLists.txt")
        message(STATUS
          "sundials was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "sundials could not be downloaded."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
