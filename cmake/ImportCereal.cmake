#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_cereal)
  # If the target already exists, do nothing
  if (NOT TARGET cereal::cereal)
    # Try to find the package locally
    find_package(cereal QUIET)
    if(TARGET cereal)
      message(STATUS "Cereal found locally at ${cereal_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(PROJ                cereal
                       GIT_REPOSITORY      https://gitlab.chab.ethz.ch/scine/cereal.git
                       GIT_TAG             v1.2.2
                       QUIET
                       UPDATE_DISCONNECTED 1
                       )
      set(JUST_INSTALL_CEREAL ON CACHE BOOL "") # Prevent cereal from building tests
      add_subdirectory(${cereal_SOURCE_DIR} ${cereal_BINARY_DIR})

      # Final check if all went well
      if(TARGET cereal)
        message(STATUS "Cereal was not found in your PATH, so it was downloaded.")
      else()
        string(CONCAT error_msg
          "Cereal was not found in your PATH and could not be downloaded. "
          "Try specifying cereal_DIR or altering CMAKE_PREFIX_PATH to "
          "point to a candidate cereal installation base directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
