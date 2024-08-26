#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_dftbplus)
  # If the target already exists, do nothing
  if(TARGET Scine::Dftbplus)
    message(STATUS "Scine::Dftbplus present.")
  else()
    # Try to find the package locally
    find_package(ScineDftbplus QUIET)
    if(TARGET Scine::Dftbplus)
      message(STATUS "Scine::Dftbplus found locally at ${ScineDftbplus_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-dftbplus
        GIT_REPOSITORY https://github.com/qcscine/dftbplus_wrapper.git
        GIT_TAG        1.0.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-dftbplus_SOURCE_DIR} ${scine-dftbplus_BINARY_DIR})

      # Final check if all went well
      if(TARGET Scine::Dftbplus)
        message(STATUS
          "Scine::Dftbplus was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::Dftbplus was not found in your PATH and could not be downloaded. "
          "Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a "
          "candidate SCINE installation base directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
