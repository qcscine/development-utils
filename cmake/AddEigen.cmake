#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#

# If the target already exists, do nothing
if(NOT TARGET Eigen3::Eigen)
  find_package(Eigen3 3.3.2 REQUIRED)
endif()

option(SCINE_USE_INTEL_MKL "Use the Intel MKL libraries with Eigen" ON)
option(SCINE_USE_STATIC_LINALG "Use static LAPACKE/LAPACK/BLAS libraries" ON)
option(SCINE_USE_LAPACKE "Use a LAPACKE library with Eigen" ON)
option(SCINE_USE_BLAS "Use a BLAS library with Eigen" ON)

# Attempt to find external linalg libraries that accelerate basic calls in
# the following order:
#
# 1. Intel MKL
# 2. LAPACKE + LAPACK + BLAS
# 3. BLAS
#
if(NOT ADD_EIGEN_SEARCHED_EXTERNAL_LINALG_LIBRARIES)
  if(SCINE_USE_INTEL_MKL)
    include(FindMKL)
  endif()

  if(MKL_FOUND)
    find_package(OpenMP REQUIRED)
    message(STATUS "Found MKL for use with Eigen3")
  else()
    # Save previous values of BLA_STATIC AND LAPACKE_STATIC
    set(_BLA_STATIC ${BLA_STATIC})
    set(_LAPACKE_STATIC ${LAPACKE_STATIC})
    # Overwrite with option
    set(BLA_STATIC ${SCINE_USE_STATIC_LINALG})
    set(LAPACKE_STATIC ${SCINE_USE_STATIC_LINALG})

    if(SCINE_USE_BLAS OR SCINE_USE_LAPACKE)
      find_package(BLAS QUIET)
    endif()

    if(SCINE_USE_LAPACKE)
      find_package(LAPACK QUIET)
      if(LAPACK_FOUND)
        find_package(LAPACKE QUIET)
      endif()
    endif()

    if(LAPACKE_FOUND)
      message(STATUS "Found LAPACKE for use with Eigen3")
    else()
      if(BLAS_FOUND)
        message(STATUS "Found BLAS for use with Eigen3")
      endif()
    endif()

    # Recover previous values of BLA_STATIC AND LAPACKE_STATIC
    set(BLA_STATIC ${_BLA_STATIC})
    set(LAPACKE_STATIC ${_LAPACKE_STATIC})
  endif()

  set(ADD_EIGEN_SEARCHED_EXTERNAL_LINALG_LIBRARIES TRUE)
endif()

function(add_eigen target_name mode)
  # Everything relating to the special case of object libraries can be
  # simplified down to the target_link_libraries command when the minimum cmake
  # version is bumped past 3.12.0
  if("${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.12.0")
    set(_CAN_LINK_OBJECT_LIBRARIES TRUE)
  endif()
  get_target_property(target_type ${target_name} TYPE)
  if("${target_type}" STREQUAL "OBJECT_LIBRARY")
    set(_IS_OBJECT_LIBRARY TRUE)
  endif()

  # Append the required properties to the passed target
  if(MKL_FOUND AND SCINE_USE_INTEL_MKL)
    # MKL AND EIGEN_USE_MKL_ALL
    if(_CAN_LINK_OBJECT_LIBRARIES OR NOT _IS_OBJECT_LIBRARY)
      target_link_libraries(${target_name} ${mode} Eigen3::Eigen ${MKL_LIBRARIES} OpenMP::OpenMP_CXX)
    else()
      target_include_directories(${target_name} ${mode} $<TARGET_PROPERTY:Eigen3::Eigen,INTERFACE_INCLUDE_DIRECTORIES>)
    endif()
    target_include_directories(${target_name} ${mode} ${MKL_INCLUDE_DIRS})
    target_compile_definitions(${target_name} ${mode} EIGEN_USE_MKL_ALL)
    target_compile_options(${target_name} ${mode} $<$<BOOL:${OpenMP_CXX_FOUND}>:${OpenMP_CXX_FLAGS}>)
  else()
    if(LAPACKE_FOUND AND SCINE_USE_LAPACKE)
      # LAPACKE and EIGEN_USE_LAPACKE + EIGEN_USE_BLAS
      if(_CAN_LINK_OBJECT_LIBRARIES OR NOT _IS_OBJECT_LIBRARY)
        target_link_libraries(${target_name} ${mode} Eigen3::Eigen ${LAPACKE_LIBRARIES} ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES})
      endif()
      target_compile_definitions(${target_name} ${mode}
        EIGEN_USE_LAPACKE
        EIGEN_USE_BLAS
        lapack_complex_float=std::complex<float>
        lapack_complex_double=std::complex<double>
      )
      target_include_directories(${target_name} ${mode} ${LAPACKE_INCLUDE_DIRS})
    else()
      if(BLAS_FOUND AND SCINE_USE_BLAS)
        # Blas and EIGEN_USE_BLAS
        if(_CAN_LINK_OBJECT_LIBRARIES OR NOT _IS_OBJECT_LIBRARY)
          target_link_libraries(${target_name} ${mode} Eigen3::Eigen ${BLAS_LIBRARIES})
        else()
          target_include_directories(${target_name} ${mode} $<TARGET_PROPERTY:Eigen3::Eigen,INTERFACE_INCLUDE_DIRECTORIES>)
        endif()
        target_compile_definitions(${target_name} ${mode} EIGEN_USE_BLAS)
      else()
        # Just Eigen, no definitions
        if(_CAN_LINK_OBJECT_LIBRARIES OR NOT _IS_OBJECT_LIBRARY)
          target_link_libraries(${target_name} ${mode} Eigen3::Eigen)
        else()
          target_include_directories(${target_name} ${mode} $<TARGET_PROPERTY:Eigen3::Eigen,INTERFACE_INCLUDE_DIRECTORIES>)
        endif()
      endif()
    endif()
  endif()
endfunction()
