#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

# Adapted from Serenity
include(FindPackageHandleStandardArgs)

if ("${MKL_ROOT}" STREQUAL "")  # if not set by user we overwrite with MKLROOT from env
  set(MKL_ROOT $ENV{MKLROOT} CACHE PATH "Folder contains MKL" FORCE)
endif()

set(MKL_FOUND TRUE)

# Find include dir
find_path(MKL_INCLUDE_DIRS mkl.h
          PATHS $ENV{MKL_INCLUDE_DIRS};${MKL_ROOT}/include;${INCLUDE};${INCLUDE}/mkl)

# Detect architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(SYSTEM_BIT "64")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(SYSTEM_BIT "32")
endif()

# Set path according to architecture
if ("${SYSTEM_BIT}" STREQUAL "64")
  set(MKL_LIB_ARCH lib/intel64/)
else()
  set(MKL_LIB_ARCH lib/ia32/)
endif()

set(MKL_LOOKUP_PATHS "${MKL_ROOT}/${MKL_LIB_ARCH};${MKL_ROOT};${LIBRARY_PATH}/${MKL_LIB_ARCH};${LIBRARY_PATH};${LD_LIBRARY_PATH}/${MKL_LIB_ARCH};${LD_LIBRARY_PATH}" PATH)

# Find libraries
if ("${SYSTEM_BIT}" STREQUAL "64")
  find_library(MKL_INTERFACE_LIBRARY NAMES libmkl_intel_lp64.so libmkl_intel_lp64.so.1 libmkl_intel_lp64.so.2 PATHS ${MKL_LOOKUP_PATHS})
else()
  find_library(MKL_INTERFACE_LIBRARY NAMES libmkl_intel.so libmkl_intel.so.1 libmkl_intel.so.2 PATHS ${MKL_LOOKUP_PATHS})
endif()

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel")
  find_library(MKL_THREADING_LIBRARY NAMES libmkl_intel_thread.so libmkl_intel_thread.so.1 libmkl_intel_thread.so.2 PATHS ${MKL_LOOKUP_PATHS})
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
  find_library(MKL_THREADING_LIBRARY NAMES libmkl_gnu_thread.so libmkl_gnu_thread.so.1 libmkl_gnu_thread.so.2 PATHS ${MKL_LOOKUP_PATHS})
else()
  unset(MKL_FOUND)
endif()

find_library(MKL_CORE_LIBRARY NAMES libmkl_core.so libmkl_core.so.1 libmkl_core.so.2 PATHS ${MKL_LOOKUP_PATHS})
find_library(MKL_AVX2_LIBRARY NAMES libmkl_avx2.so libmkl_avx2.so.1 libmkl_avx2.so.2 PATHS ${MKL_LOOKUP_PATHS})
find_library(MKL_VML_AVX2_LIBRARY NAMES libmkl_vml_avx2.so libmkl_vml_avx2.so.1 libmkl_vml_avx2.so.2 PATHS ${MKL_LOOKUP_PATHS})

set(MKL_LIBRARIES ${MKL_AVX2_LIBRARY} ${MKL_VML_AVX2_LIBRARY} ${MKL_INTERFACE_LIBRARY} ${MKL_THREADING_LIBRARY} ${MKL_CORE_LIBRARY})

find_package_handle_standard_args(MKL DEFAULT_MSG MKL_INCLUDE_DIRS MKL_LIBRARIES)

if(MKL_FOUND)
  message("-- Found Intel MKL libraries:")
  message("-- ${MKL_INCLUDE_DIRS} ")
  message("-- ${MKL_AVX2_LIBRARY} ")
  message("-- ${MKL_VML_AVX2_LIBRARY} ")
  message("-- ${MKL_CORE_LIBRARY} ")
  message("-- ${MKL_INTERFACE_LIBRARY} ")
  message("-- ${MKL_THREADING_LIBRARY} ")
else()
  set(MKL_LIBRARIES "MKL_LIBRARIES-NOTFOUND")
endif()
