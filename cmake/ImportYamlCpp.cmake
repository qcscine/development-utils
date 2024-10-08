#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_yamlcpp)
  # If the target already exists, do nothing
  if (NOT TARGET yaml-cpp)
    # If the target can be found, use it
    find_package(yaml-cpp QUIET NO_CMAKE_PACKAGE_REGISTRY)
    if (TARGET yaml-cpp)
      message(STATUS "Found package yaml-cpp at ${yaml-cpp_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      set(YAML_CPP_BUILD_TESTS OFF CACHE BOOL "" FORCE) # Prevent yaml-cpp from building tests

      download_project(PROJ                yamlcpp
                       GIT_REPOSITORY      https://github.com/jbeder/yaml-cpp.git
                       GIT_TAG             yaml-cpp-0.6.3
                       QUIET
                       UPDATE_DISCONNECTED 1
                       )
      add_subdirectory(${yamlcpp_SOURCE_DIR} ${yamlcpp_BINARY_DIR})

      # Final check if all went well
      if(TARGET yaml-cpp)
        if(NOT YAML_BUILD_SHARED_LIBS)
          # Static builds of yamlcpp need to be position-independent
          set_target_properties(yaml-cpp PROPERTIES POSITION_INDEPENDENT_CODE ON)
        endif()
        message(STATUS "yaml-cpp was not found in your PATH, so it was downloaded.")
      else()
        string(CONCAT error_msg
          "yaml-cpp was not found in your PATH and could not be downloaded. "
          "Try specifying yaml-cpp_DIR or altering CMAKE_PREFIX_PATH to "
          "point to a candidate yaml-cpp installation base directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
