#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_swoose)
  # If the target already exists, do nothing
  if(TARGET Scine::Swoose)
    message(STATUS "Scine::Swoose present.")
  else()
    # Try to find the package locally
    find_package(ScineSwoose QUIET)
    if(TARGET Scine::Swoose)
      message(STATUS "Scine::Swoose found locally at ${ScineSwoose_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-swoose
        GIT_REPOSITORY https://github.com/qcscine/swoose.git
        GIT_TAG        2.1.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-swoose_SOURCE_DIR} ${scine-swoose_BINARY_DIR})

      # Final check if all went well
      if(TARGET Scine::Swoose)
        message(STATUS
          "Scine::Swoose was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::Swoose was not found in your PATH and could not be downloaded. "
          "Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a candidate Scine installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()