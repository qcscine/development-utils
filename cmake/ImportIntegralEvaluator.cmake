#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_integral_evaluator)
  # If the target already exists, do nothing
  if(NOT TARGET Scine::IntegralEvaluator)
    # Try to find the package locally
    find_package(ScineIntegralEvaluator QUIET)
    if(TARGET Scine::LibintIntegrals)
      message(STATUS "Scine::LibintIntegrals found locally at ${ScineIntegralEvaluator_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-integral-evaluator
        GIT_REPOSITORY https://github.com/qcscine/integralevaluator.git
        GIT_TAG        1.0.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-integral-evaluator_SOURCE_DIR} ${scine-integral-evaluator_BINARY_DIR})
      # Final check if all went well
      if(TARGET Scine::LibintIntegrals)
        message(STATUS
          "Scine::LibintIntegrals was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::LibintIntegrals was not found in your PATH and could not be "
          "downloaded. Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a candidate Scine installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()

