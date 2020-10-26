#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

# Figure out the name of a imported target's filename or the filename of an
# in-tree library target
macro(target_lib_filename target output)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "target_lib_filename passed target that does not exist")
  endif()

  get_target_property(_imported ${target} IMPORTED)
  if(_imported)
    foreach(BUILD_TYPE Debug;Release;MinSizeRel;RelWithDebInfo)
      string(TOUPPER "${BUILD_TYPE}" _upper_build_type)
      get_target_property(_name_attempt ${target} IMPORTED_SONAME_${_upper_build_type})
      if(_name_attempt)
        set(${output} ${_name_attempt})
        break()
      endif()
    endforeach()
    unset(_name_attempt)
    unset(_upper_build_type)

    if(NOT DEFINED ${output})
      message(FATAL_ERROR "Could not determine library filename from IMPORTED_SONAME_XXX")
    endif()
  else()
    get_target_property(_output_name ${target} OUTPUT_NAME)
    get_target_property(_type ${target} TYPE)
    if(${_type} STREQUAL "SHARED_LIBRARY")
      set(${output} "${CMAKE_SHARED_LIBRARY_PREFIX}${_output_name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    elseif(${_type} STREQUAL "STATIC_LIBRARY")
      set(${output} "${CMAKE_STATIC_LIBRARY_PREFIX}${_output_name}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    else()
      message(FATAL_ERROR "Could not determine library filename of in-tree target")
    endif()
    unset(_output_name)
    unset(_type)
  endif()
  unset(_imported)
endmacro()

# Figure out the directory where an imported target is and where a target
# built in-tree will be
macro(target_lib_directory target output)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "target_lib_directory passed target that does not exist")
  endif()

  get_target_property(_imported ${target} IMPORTED)
  if(_imported)
    foreach(BUILD_TYPE Debug;Release;MinSizeRel;RelWithDebInfo)
      string(TOUPPER "${BUILD_TYPE}" _upper_build_type)
      get_target_property(_name_attempt ${target} IMPORTED_LOCATION_${_upper_build_type})
      if(_name_attempt)
        get_filename_component(${output} ${_name_attempt} DIRECTORY)
        break()
      endif()
    endforeach()
    unset(_name_attempt)
    unset(_upper_build_type)

    if(NOT DEFINED ${output})
      message(FATAL_ERROR "Could not determine library directory from IMPORTED_LOCATION_XXX")
    endif()
  else()
    get_target_property(${output} ${target} BINARY_DIR)
  endif()
  unset(_imported)
endmacro()
