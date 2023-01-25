cmake_minimum_required(VERSION 3.9)
#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

macro(download_spglib)
  include(DownloadProject)
  download_project(PROJ spglib
    GIT_REPOSITORY      https://github.com/spglib/spglib
    GIT_TAG             9458171a2eb9bea9036632a408da7b269ea07bbb
    UPDATE_DISCONNECTED 1
    QUIET
  )

  # Generate object only target to be fully subsumed
  set(spglib_SRC_DIR ${spglib_SOURCE_DIR}/src)
  set(spglib_SOURCES 
    ${spglib_SRC_DIR}/arithmetic.c
    ${spglib_SRC_DIR}/cell.c
    ${spglib_SRC_DIR}/debug.c
    ${spglib_SRC_DIR}/delaunay.c
    ${spglib_SRC_DIR}/determination.c
    ${spglib_SRC_DIR}/hall_symbol.c
    ${spglib_SRC_DIR}/kgrid.c
    ${spglib_SRC_DIR}/kpoint.c
    ${spglib_SRC_DIR}/magnetic_spacegroup.c
    ${spglib_SRC_DIR}/mathfunc.c
    ${spglib_SRC_DIR}/msg_database.c
    ${spglib_SRC_DIR}/niggli.c
    ${spglib_SRC_DIR}/overlap.c
    ${spglib_SRC_DIR}/pointgroup.c
    ${spglib_SRC_DIR}/primitive.c
    ${spglib_SRC_DIR}/refinement.c
    ${spglib_SRC_DIR}/site_symmetry.c
    ${spglib_SRC_DIR}/sitesym_database.c
    ${spglib_SRC_DIR}/spacegroup.c
    ${spglib_SRC_DIR}/spg_database.c
    ${spglib_SRC_DIR}/spglib.c
    ${spglib_SRC_DIR}/spin.c
    ${spglib_SRC_DIR}/symmetry.c
  )
  set_source_files_properties(${spglib_SOURCES} PROPERTIES SKIP_UNITY_BUILD_INCLUSION ON)
  add_library(symspg_objects OBJECT ${spglib_SOURCES})
  set_target_properties(symspg_objects PROPERTIES POSITION_INDEPENDENT_CODE ON)
  set(SYMSPG_INCLUDE_DIR PUBLIC ${spglib_SRC_DIR})

  # Final check if all went well
  if(EXISTS "${spglib_SOURCE_DIR}/CMakeLists.txt")
    message(STATUS
      "spglib was not found in your PATH, so it was downloaded."
    )
  else()
    message(FATAL_ERROR
      "spglib could not be downloaded."
    )
  endif()
endmacro()

macro(import_spglib)
  # check if we need to look
  if(TARGET symspg_objects)
  else()
    download_spglib()
  endif()
endmacro()

