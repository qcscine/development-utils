#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_check_compiler()
conan_set_libcxx()
set(CONAN_CMAKE_SILENT_OUTPUT ON)

# Googletest is another complicated case, so forward to a glue file
if(
  NOT TARGET GTest::GTest
  AND EXISTS ${CMAKE_CURRENT_BINARY_DIR}/FindGTest.cmake
)
  include(${CMAKE_CURRENT_LIST_DIR}/glue/gtest.cmake)
endif()

# A bunch of libraries generate non-namespaced targets, we can abstract over
# those here
set(_mock_libs yaml-cpp irc RingDecomposerLib nauty serenity)
foreach(_mock_lib ${_mock_libs})
  if(
    NOT TARGET ${_mock_lib}
    AND EXISTS "${CMAKE_CURRENT_BINARY_DIR}/Find${_mock_lib}.cmake"
  )
    find_package(${_mock_lib})
    add_library(${_mock_lib} INTERFACE IMPORTED)
    target_link_libraries(${_mock_lib} INTERFACE ${_mock_lib}::${_mock_lib})
  endif()
endforeach()

# Xtb has slightly different handling, the target name has to be different
if(
  NOT TARGET lib-xtb-static
  AND EXISTS "${CMAKE_CURRENT_BINARY_DIR}/Findxtb.cmake"
)
  find_package(xtb)
  add_library(lib-xtb-static INTERFACE IMPORTED)
  target_link_libraries(lib-xtb-static INTERFACE xtb::xtb)
endif()

# Mongo also has its own custom target name in our import logic
if(
  NOT TARGET MongoDBCXX
  AND EXISTS "${CMAKE_CURRENT_BINARY_DIR}/Findmongo-cxx-driver.cmake"
)
  find_package(mongo-cxx-driver)
  add_library(MongoDBCXX INTERFACE IMPORTED)
  target_link_libraries(MongoDBCXX INTERFACE mongo-cxx-driver::mongo-cxx-driver)
endif()

# Some extra behavior for serenity
if(TARGET serenity::serenity)
  # NOTE: This directory doesn't even exist in conan builds, but our CMake code
  # needs it all the same. The variable is supplied by the generated find module
  set(serenity_DIR "${serenity_LIB_DIRS}/cmake/serenity")
endif()

macro(make_target_from_conan target source var_prefix)
  if(NOT TARGET ${source})
    message(FATAL_ERROR "Cannot mimic target from non-existent conan target ${source}")
  endif()
  get_target_property(_source_loc ${source} IMPORTED_LOCATION)
  set_target_properties(${target} PROPERTIES
    IMPORTED_LOCATION ${_source_loc}
    INTERFACE_INCLUDE_DIRECTORIES "${${var_prefix}_INCLUDE_DIRS}"
    INTERFACE_LINK_DIRECTORIES "${${var_prefix}_LIB_DIRS}"
    INTERFACE_LINK_LIBRARIES "${${var_prefix}_LINK_LIBS};${${var_prefix}_LINKER_FLAGS_LIST}"
    INTERFACE_COMPILE_DEFINITIONS "${${var_prefix}_COMPILE_DEFINITIONS}"
    INTERFACE_COMPILE_OPTIONS "${${var_prefix}_COMPILE_OPTIONS_C};${${var_prefix}_COMPILE_OPTIONS_CXX}"
  )
endmacro()

# Scine target modifications for TargetLibName functions
if(
  NOT TARGET Scine::UtilsOS
  AND EXISTS "${CMAKE_CURRENT_BINARY_DIR}/FindScineUtilsOS.cmake"
)
  add_library(Scine::UtilsOS UNKNOWN IMPORTED)
  add_library(Scine::Core UNKNOWN IMPORTED)
  find_package(ScineUtilsOS)
  make_target_from_conan(Scine::UtilsOS CONAN_LIB::Scine_utilsos Scine_UtilsOS)
  make_target_from_conan(Scine::Core CONAN_LIB::Scine_core Scine_Core)
endif()

if(
  NOT TARGET Scine::Sparrow
  AND EXISTS "${CMAKE_CURRENT_BINARY_DIR}/FindScineSparrow.cmake"
)
  add_library(Scine::Sparrow UNKNOWN IMPORTED)
  find_package(ScineSparrow)
  make_target_from_conan(Scine::Sparrow CONAN_LIB::Scine_sparrow.module.so Scine_Sparrow)
endif()
