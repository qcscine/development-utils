#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

cmake_minimum_required(VERSION 3.9)
set(BOOST_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/boost.txt")
set(CEREAL_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/cereal.txt")
set(EIGEN_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/eigen.txt")
set(GTEST_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/gtest.txt")
set(LIBIRC_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/libirc.txt")
set(MONGOCXX_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/mongocxx.txt")
set(PYBIND_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/pybind.txt")
set(XTB_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/xtb.txt")
set(YAMLCPP_LICENSE_FILE "${CMAKE_CURRENT_LIST_DIR}/licenses/yamlcpp.txt")

set(_DEPENDENCIES BOOST CEREAL EIGEN GTEST LIBIRC MONGOCXX PYBIND YAMLCPP)
foreach(DEPNAME ${_DEPENDENCIES})
  list(APPEND ALL_LICENSE_FILES ${${DEPNAME}_LICENSE_FILE})
endforeach()

# Writes a list of external license files depending on what targets exist
# Call **after** your find_package calls
macro (get_license_files)
  set(EXTERNAL_LICENSE_FILES "")
  if(TARGET Boost::boost)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${BOOST_LICENSE_FILE})
  endif()
  if(TARGET cereal::cereal)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${CEREAL_LICENSE_FILE})
  endif()
  if(TARGET Eigen3::Eigen)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${EIGEN_LICENSE_FILE})
  endif()
  if(TARGET gtest)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${GTEST_LICENSE_FILE})
  endif()
  if(DEFINED ${LIBIRC_INCLUDE_DIR})
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${LIBIRC_LICENSE_FILE})
  endif()
  if(TARGET MongoDBCXX)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${MONGOCXX_LICENSE_FILE})
  endif()
  if(TARGET pybind11)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${PYBIND_LICENSE_FILE})
  endif()
  if(TARGET xtb_static)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${XTB_LICENSE_FILE})
  endif()
  if(TARGET yaml-cpp)
    set(EXTERNAL_LICENSE_FILES "${EXTERNAL_LICENSE_FILES}" ${YAMLCPP_LICENSE_FILE})
  endif()
endmacro()
