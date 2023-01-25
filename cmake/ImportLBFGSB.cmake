#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_lbfgspp)
  # If the target already exists, do nothing
  if(NOT TARGET lbfgspp)
    find_package(lbfgspp QUIET)
    if(NOT TARGET lbfgspp)
      # Download it instead
      include(DownloadProject)
      download_project(PROJ lbfgspp
        GIT_REPOSITORY      https://github.com/yixuan/LBFGSpp
        GIT_TAG             v0.2.0
        UPDATE_DISCONNECTED 1
        QUIET
      )

      add_subdirectory(${lbfgspp_SOURCE_DIR} ${lbfgspp_BINARY_DIR})
    
    if(TARGET lbfgspp)
      message(STATUS "LBFGSB was not found in your PATH, so it was downloaded.")
    else()
      string(CONCAT error_msg
        "LBFGSB was not found in your PATH and could not be downloaded."
      )
      message(FATAL_ERROR ${error_msg})
    endif()
    endif()
  endif()
endmacro()

