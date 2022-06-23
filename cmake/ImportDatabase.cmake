#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_database)
  # If the target already exists, do nothing
  if(NOT TARGET Scine::Database)
    # Try to find the package locally
    find_package(ScineDatabase QUIET)
    if(TARGET Scine::Database)
      message(STATUS "Scine::Database found locally at ${ScineDatabase_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-database
        GIT_REPOSITORY https://github.com/qcscine/database.git
        GIT_TAG        1.0.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-database_SOURCE_DIR} ${scine-database_BINARY_DIR})

      # Final check if all went well
      if(TARGET Scine::Database)
        message(STATUS
          "Scine::Database was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::Database was not found in your PATH and could not be established "
          "through a download. Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a candidate Scine installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
