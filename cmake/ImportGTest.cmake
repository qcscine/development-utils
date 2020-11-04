#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_gtest)
  # If the target already exists, do nothing
  if((NOT TARGET GTest::GTest) OR (NOT TARGET GTest::Main) OR
     (NOT TARGET GMock::GMock) OR (NOT TARGET GMock::Main))
    set(INSTALL_GTEST OFF CACHE BOOL "Disable Gtests install" FORCE)
    # Try to find the package locally
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}")
    find_package(GTest 1.8.1 QUIET)
    find_package(GMock 1.8.1 QUIET)
    if((NOT TARGET GMock::GMock) OR (NOT TARGET GMock::Main))
      if((TARGET gmock) AND (TARGET gmock_main))
        add_library(GMock::GMock ALIAS gmock)
        add_library(GMock::Main ALIAS gmock_main)
      endif()
    endif()
    if((TARGET GTest::GTest) AND (TARGET GTest::Main) AND
       (TARGET GMock::GMock) AND (TARGET GMock::Main))
      message(STATUS "Found GTest locally at: ${GTEST_LIBRARIES}")
    else()
      # Download it instead
      message(STATUS "GTest and GMock were not found in your PATH, they are being downloaded.")
      include(DownloadProject)
      download_project(
        PROJ                googletest
        GIT_REPOSITORY      https://github.com/google/googletest.git
        GIT_TAG             release-1.10.0
        QUIET
        UPDATE_DISCONNECTED 1
      )
      # Prevent GoogleTest from overriding our compiler/linker options when
      # building with Visual Studio
      set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

      set(_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
      set(BUILD_SHARED_LIBS OFF)
      add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR})
      set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
      unset(_BUILD_SHARED_LIBS)
      add_library(GTest::GTest ALIAS gtest)
      add_library(GTest::Main ALIAS gtest_main)
      add_library(GMock::GMock ALIAS gmock)
      add_library(GMock::Main ALIAS gmock_main)

      # Final check if all went well
      if((TARGET GTest::GTest) AND (TARGET GTest::Main) AND
         (TARGET GMock::GMock) AND (TARGET GMock::Main))
        message(STATUS "GTest and GMock sources were downloaded.")
      else()
        string(CONCAT error_msg
          "GTest was not found in your PATH and could not be established through "
          "a download. Try specifying GTest_DIR or altering CMAKE_PREFIX_PATH to "
          "point to a candidate GTest installation base directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
