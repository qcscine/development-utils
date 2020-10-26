#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

# Define properties that we can place on documentation custom targets to
# propagate information necessary for dependency modeling and tagfile inclusion
define_property(
  TARGET PROPERTY DOCUMENTATION_CROSSLINK_TAGFILE
  BRIEF_DOCS "Doxygen documentation tagfile"
  FULL_DOCS "Doxygen documentation tagfile for cross-linking separate documentations"
)

define_property(
  TARGET PROPERTY DOCUMENTATION_BINARY_DIR
  BRIEF_DOCS "Doxygen documentation output directory"
  FULL_DOCS "Doxygen documentation output directory"
)

function(test_is_doc_target resultvar target)
  set(${resultvar} FALSE PARENT_SCOPE)
  if(TARGET ${target})
    get_property(crosslink_set
      TARGET ${target}
      PROPERTY DOCUMENTATION_CROSSLINK_TAGFILE SET
    )
    set(${resultvar} ${crosslink_set} PARENT_SCOPE)
  endif()
endfunction()

function(scine_component_documentation)
  # Call this after all dependencies have been included in the component's
  # top-level directory CMakeLists.txt so that tagfiles are transitively
  # included. Pass any documentation dependency target names as arguments.

  # Eliminate DOXYGEN_INPUT if present to avoid clash with FindDoxygen.cmake
  if(NOT DOXYGEN_INPUT)
    set(SCINE_DOXYGEN_INPUT
      ${CMAKE_CURRENT_SOURCE_DIR}/src
      ${CMAKE_CURRENT_SOURCE_DIR}/dev/cmake
    )
  else()
    set(SCINE_DOXYGEN_INPUT ${DOXYGEN_INPUT})
    unset(DOXYGEN_INPUT)
  endif()

  # Find Doxygen and abort if not found
  find_package(Doxygen QUIET)
  if(NOT Doxygen_FOUND)
    message(STATUS "Doxygen not found - Documentation for ${PROJECT_NAME} will not be built.")
    return()
  endif()

  # SCINE default Doxygen settings
  if(NOT DOXYGEN_PROJECT_NAME)
    set(DOXYGEN_PROJECT_NAME "Scine::${PROJECT_NAME}")
  endif()
  if(NOT DOXYGEN_PROJECT_DESCRIPTION)
    set(DOXYGEN_PROJECT_DESCRIPTION "${PROJECT_DESCRIPTION}")
  endif()
  if(NOT DOXYGEN_FULL_PATH_NAMES)
    set(DOXYGEN_FULL_PATH_NAMES YES)
  endif()
  if(NOT DOXYGEN_BUILTIN_STL_SUPPORT)
    set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
  endif()
  if(NOT DOXYGEN_DISTRIBUTE_GROUP_DOC)
    set(DOXYGEN_DISTRIBUTE_GROUP_DOC YES)
  endif()
  if(NOT DOXYGEN_WARN_NO_PARAMDOC)
    set(DOXYGEN_WARN_NO_PARAMDOC YES)
  endif()
  if(NOT DOXYGEN_WARN_LOGFILE)
    set(DOXYGEN_WARN_LOGFILE "doxygen_warnings.txt")
  endif()
  if(NOT DOXYGEN_FILE_PATTERNS)
    set(DOXYGEN_FILE_PATTERNS *.cpp *.hpp *.hxx *.h *.dox *.py)
  endif()
  if(NOT DOXYGEN_RECURSIVE)
    set(DOXYGEN_RECURSIVE YES)
  endif()
  if(NOT DOXYGEN_GENERATE_TREEVIEW)
    set(DOXYGEN_GENERATE_TREEVIEW YES)
  endif()
  if(NOT DOXYGEN_GENERATE_TODOLIST)
    set(DOXYGEN_GENERATE_TODOLIST NO)
  endif()
  if(NOT DOXYGEN_GENERATE_TESTLIST)
    set(DOXYGEN_GENERATE_TESTLIST NO)
  endif()
  if(NOT DOXYGEN_USE_MATHJAX)
    set(DOXYGEN_USE_MATHJAX YES)
  endif()
  if(NOT DOXYGEN_GENERATE_LATEX)
    set(DOXYGEN_GENERATE_LATEX NO)
  endif()
  if(NOT DOXYGEN_UML_LOOK)
    set(DOXYGEN_UML_LOOK YES)
  endif()
  if(NOT DOXYGEN_TEMPLATE_RELATIONS)
    set(DOXYGEN_TEMPLATE_RELATIONS YES)
  endif()
  if(NOT DOXYGEN_OUTPUT_DIRECTORY)
    set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif()
  if(NOT DOXYGEN_GENERATE_TAGFILE)
    set(DOXYGEN_GENERATE_TAGFILE "${DOXYGEN_OUTPUT_DIRECTORY}/html/${PROJECT_NAME}.tag")
  endif()
  if(NOT DOXYGEN_QUIET)
    set(DOXYGEN_QUIET YES)
  endif()

  # Gather the full tree of documentation dependencies
  set(GATHER_TARGETS ${ARGV})
  while(GATHER_TARGETS)
    set(test_targets ${GATHER_TARGETS})
    set(GATHER_TARGETS "")
    foreach(target ${test_targets})
      test_is_doc_target(is_doc_target ${target})
      if(is_doc_target)
        list(APPEND UPSTREAM_TARGETS ${target})
        get_target_property(dependencies ${target} MANUALLY_ADDED_DEPENDENCIES)
        foreach(dependency ${dependencies})
          list(APPEND GATHER_TARGETS ${dependency})
        endforeach()
      endif()
    endforeach()
    list(REMOVE_DUPLICATES GATHER_TARGETS)
  endwhile()
  unset(GATHER_TARGETS)
  if(UPSTREAM_TARGETS)
    list(REMOVE_DUPLICATES UPSTREAM_TARGETS)
  endif()

  # Model tagfile dependencies for cross-linking of documentations
  if(NOT DOXYGEN_TAGFILES)
    foreach(target ${UPSTREAM_TARGETS})
      get_target_property(tagfile ${target} DOCUMENTATION_CROSSLINK_TAGFILE)
      get_target_property(output_dir ${target} DOCUMENTATION_BINARY_DIR)
      file(RELATIVE_PATH upstream_output_dir_rel ${DOXYGEN_OUTPUT_DIRECTORY}/html ${output_dir})
      list(APPEND DOXYGEN_TAGFILES "${tagfile}=${upstream_output_dir_rel}")
    endforeach()
  endif()

  # Add the target
  doxygen_add_docs(${PROJECT_NAME}Documentation ${SCINE_DOXYGEN_INPUT})
  set_target_properties(${PROJECT_NAME}Documentation PROPERTIES
    DOCUMENTATION_CROSSLINK_TAGFILE ${DOXYGEN_GENERATE_TAGFILE}
    DOCUMENTATION_BINARY_DIR ${DOXYGEN_OUTPUT_DIRECTORY}/html
  )

  # Enforce build order so upstream tagfiles are present
  foreach(target ${UPSTREAM_TARGETS})
    add_dependencies(${PROJECT_NAME}Documentation ${target})
  endforeach()

  # Install the result of the target
  #install(
  #  DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY}
  #  DESTINATION share/Scine/${PROJECT_NAME}/
  #)
endfunction()
