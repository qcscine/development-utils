#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_xtb)
  # If the target already exists, do nothing
  if(TARGET Scine::Xtb)
    message(STATUS "Scine::Xtb present.")
  else()
    # Try to find the package locally
    find_package(ScineXtb QUIET)
    if(TARGET Scine::Xtb)
      message(STATUS "Scine::Xtb found locally at ${ScineXtb_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-xtb-wrapper
        GIT_REPOSITORY https://github.com/qcscine/xtb_wrapper.git
        GIT_TAG        3.0.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-xtb-wrapper_SOURCE_DIR} ${scine-xtb-wrapper_BINARY_DIR})

      # Final check if all went well
      if(TARGET Scine::Xtb)
        message(STATUS
          "Scine::Xtb was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::Xtb was not found in your PATH and could not be established "
          "through a download. Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a candidate Scine installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
