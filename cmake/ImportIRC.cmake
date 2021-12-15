#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_irc)
  # If the target already exists, do nothing
  if(NOT TARGET irc)
    find_package(irc QUIET)
    if(NOT TARGET irc)
      # Download it instead
      include(DownloadProject)
      download_project(PROJ irc
        GIT_REPOSITORY      https://github.com/rmeli/irc.git
        GIT_TAG             6d5c7c372d02ecdbd50f8981669c46ddae0638ac
        UPDATE_DISCONNECTED 1
        QUIET
      )

      if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13.0")
        set(_CMP0077_DEFAULT ${CMAKE_POLICY_DEFAULT_CMP0077})
        set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
        set(WITH_EIGEN TRUE)
        set(BUILD_TESTS FALSE)
        add_subdirectory(${irc_SOURCE_DIR} ${irc_BINARY_DIR})
        unset(WITH_EIGEN)
        unset(BUILD_TESTS)
        set(CMAKE_POLICY_DEFAULT_CMP0077 ${_CMP0077_DEFAULT})
      else()
        # Before 3.13, we can't control options in irc's CMakeLists because
        # CMP0077 is unknown. So we do this awkward dance of intrusive
        # interface library generation.
        add_library(irc INTERFACE)
        target_include_directories(irc INTERFACE
          $<BUILD_INTERFACE:${irc_SOURCE_DIR}/include>
          $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>
        )
        target_compile_definitions(irc INTERFACE
          -DHAVE_EIGEN3
          -DEIGEN_MATRIX_PLUGIN="libirc/plugins/eigen/Matrix_initializer_list.h"
        )
        # NOTE: we have not taken care of Boost and Eigen dependencies, and are
        # assuming you are linking against these yourself.
        install(DIRECTORY ${irc_SOURCE_DIR}/include/ DESTINATION include)
        install(TARGETS irc EXPORT ircTargets)
        include(CMakePackageConfigHelpers)
        write_basic_package_version_file(
          ${irc_BINARY_DIR}/irc-config-version.cmake
          VERSION 0.1.0
          COMPATIBILITY AnyNewerVersion
        )
        configure_package_config_file(
          ${irc_SOURCE_DIR}/config.cmake.in
          ${irc_BINARY_DIR}/irc-config.cmake
          INSTALL_DESTINATION lib/cmake/irc
        )
        # Targets files
        install(
          EXPORT ircTargets
          FILE irc-targets.cmake
          DESTINATION lib/cmake/irc
        )
        export(EXPORT ircTargets FILE irc-targets.cmake)
        install(
          FILES
            ${irc_BINARY_DIR}/irc-config.cmake
            ${irc_BINARY_DIR}/irc-config-version.cmake
          DESTINATION lib/cmake/irc
        )
      endif()

      if(TARGET irc)
        message(STATUS "IRC was not found in your PATH, so it was downloaded.")
      else()
        string(CONCAT error_msg
          "IRC was not found in your PATH and could not be established through "
          "a download. Try specifying irc_DIR or altering CMAKE_PREFIX_PATH to "
          "point to a candidate irc installation base directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
