#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

include(ColorMessages)

function(download_file source_file target_file)
  if(NOT EXISTS ${target_file})
    file(DOWNLOAD ${source_file} ${target_file} STATUS PULL_STATUS)
    list(GET PULL_STATUS 0 PULL_RESULT)
    if(NOT ${PULL_RESULT} EQUAL 0)
      if(EXISTS ${target_file})
        file(REMOVE ${target_file})
      endif()
      list(GET PULL_STATUS 1 PULL_ERROR)
      cmessage(FATAL_ERROR
        "Could not download file: ${PULL_ERROR} "
        "Please download the file at ${source_file} "
        "and place it in your build tree at ${target_file}"
      )
    endif()
  endif()
endfunction()

function(try_resource_dir)
  set(options "")
  set(oneValueArgs DESTINATION)
  set(multiValueArgs SOURCE)
  cmake_parse_arguments(RESOURCE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # for backwards compatibility
  if(DEFINED MOLASSEMBLER_OFFLINE_RESOURCE_DIR)
    if (DEFINED SCINE_OFFLINE_RESOURCE_DIR AND
        NOT "${SCINE_OFFLINE_RESOURCE_DIR}" STREQUAL "${MOLASSEMBLER_OFFLINE_RESOURCE_DIR}")
      message(FATAL_ERROR "Cannot define both SCINE_OFFLINE_RESOURCE_DIR and MOLASSEMBLER_OFFLINE_RESOURCE_DIR")
    endif()
    set(SCINE_OFFLINE_RESOURCE_DIR MOLASSEMBLER_OFFLINE_RESOURCE_DIR)
  endif()

  if(DEFINED SCINE_OFFLINE_RESOURCE_DIR)
    if(NOT IS_ABSOLUTE ${SCINE_OFFLINE_RESOURCE_DIR})
      cmessage(FATAL_ERROR "SCINE_OFFLINE_RESOURCE_DIR must be specified as an absolute path!")
    endif()

    # Check if all files are already in the target directory
    set(ALL_FOUND TRUE)
    foreach(source ${RESOURCE_SOURCE})
      if(NOT EXISTS ${RESOURCE_DESTINATION}/${source})
        set(ALL_FOUND FALSE)
      endif()
    endforeach()

    if(ALL_FOUND)
      return()
    endif()

    # Look in the resource dir if all sources are present
    set(ALL_FOUND TRUE)
    foreach(source ${RESOURCE_SOURCE})
      set(source_path ${SCINE_OFFLINE_RESOURCE_DIR}/${source})
      if(NOT EXISTS ${source_path})
        cmessage(WARNING "Could not find resource ${source_path} with SCINE_OFFLINE_RESOURCE_DIR")
        set(ALL_FOUND FALSE)
      endif()
    endforeach()

    if(ALL_FOUND)
      foreach(source ${RESOURCE_SOURCE})
        file(
          COPY ${SCINE_OFFLINE_RESOURCE_DIR}/${source}
          DESTINATION ${RESOURCE_DESTINATION}
        )
      endforeach()
    else()
      cmessage(FATAL_ERROR "SCINE_OFFLINE_RESOURCE_DIR was set, but not all resources were found.")
    endif()
  endif()
endfunction()
