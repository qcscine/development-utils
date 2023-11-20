#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#

# Try to find GMock
find_package(GTest QUIET)
find_package(PkgConfig QUIET)
pkg_check_modules(PC_GMOCK QUIET gmock)
set(GMOCK_DEFINITIONS ${PC_GMOCK_CFLAGS_OTHER})

find_path(GMOCK_INCLUDE_DIR gmock.h
          HINTS ${GMOCK_ROOT}/include ${PC_GMOCK_INCLUDEDIR} ${PC_GMOCK_INCLUDE_DIRS}
          PATH_SUFFIXES gmock)

find_library(GMOCK_LIBRARY NAMES gmock libgmock
             HINTS ${GMOCK_ROOT}/lib ${GMOCK_ROOT}/lib64 ${PC_GMOCK_LIBDIR} ${PC_GMOCK_LIBRARY_DIRS} )

find_library(GMOCK_MAIN_LIBRARY NAMES gmock_main libgmock_main
             HINTS ${GMOCK_ROOT}/lib ${GMOCK_ROOT}/lib64 ${PC_GMOCK_LIBDIR} ${PC_GMOCK_LIBRARY_DIRS} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set GMOCK_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(GMock DEFAULT_MSG
                                  GMOCK_LIBRARY GMOCK_MAIN_LIBRARY GMOCK_INCLUDE_DIR GTEST_FOUND)

mark_as_advanced(GMOCK_INCLUDE_DIR GMOCK_LIBRARY GMOCK_MAIN_LIBRARY)

set(GMOCK_LIBRARIES ${GMOCK_LIBRARY} )
set(GMOCK_INCLUDE_DIRS ${GMOCK_INCLUDE_DIR} )
set(GMOCK_MAIN_LIBRARIES ${GMOCK_MAIN_LIBRARY} )

if (GMOCK_FOUND)
  if (NOT TARGET gmock)
    add_library(gmock IMPORTED STATIC GLOBAL)
    set_property(TARGET gmock PROPERTY IMPORTED_LOCATION ${GMOCK_LIBRARY})
    set_property(TARGET gmock PROPERTY INTERFACE_INCLUDE_DIRECTORY ${GMOCK_INCLUDE_DIR})
  endif()
  add_library(GMock::GMock ALIAS gmock)
  if (NOT TARGET gmock_main)
    add_library(gmock_main IMPORTED STATIC GLOBAL)
    set_property(TARGET gmock_main PROPERTY IMPORTED_LOCATION ${GMOCK_MAIN_LIBRARY})
    set_property(TARGET gmock_main PROPERTY INTERFACE_LINK_LIBRARIES GMock::GMock GTest::GTest)
  endif()
  add_library(GMock::Main ALIAS gmock_main)
endif()
