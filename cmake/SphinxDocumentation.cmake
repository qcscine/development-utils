#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

define_property(
  TARGET PROPERTY SPHINX_OUTPUT_DIR
  BRIEF_DOCS "Sphinx output directory"
  FULL_DOCS "Sphinx documentation output directory"
)

function(test_is_sphinx_documentation resultvar target)
  set(${resultvar} FALSE PARENT_SCOPE)
  if(TARGET ${target})
    get_property(has_sphinx_output_dir
      TARGET ${target}
      PROPERTY SPHINX_OUTPUT_DIR SET
    )
    set(${resultvar} ${has_sphinx_output_dir} PARENT_SCOPE)
  endif()
endfunction()

function(gather_upstream_sphinxes)
  include(CMakeBackports)
  list_pop_front(ARGV resultvar)

  set(GATHER_TARGETS ${ARGV})
  while(GATHER_TARGETS)
    set(test_targets ${GATHER_TARGETS})
    set(GATHER_TARGETS "")
    foreach(target ${test_targets})
      test_is_sphinx_documentation(is_sphinx_doc ${target})
      if(is_sphinx_doc)
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

  set(${resultvar} ${UPSTREAM_TARGETS} PARENT_SCOPE)
endfunction()

# Usage:
# scine_sphinx_documentation(
#   TARGET <pybind module target or name>
#   CONFIGURATION <sphinx config file>
#   OUTPUT <output directory>
#   LINK <upstream sphinx documentation targets to link with intersphinx>
#   SOURCE_DIR <source directory for RST files and images to copy>
#   [DOCTEST] [DOCTEST_REQUIRES <python modules or target names doctest needs>]
# )
function(scine_sphinx_documentation)
  set(options DOCTEST)
  set(oneValueArgs TARGET CONFIGURATION OUTPUT)
  set(multiValueArgs LINK SOURCE_DIR DOCTEST_REQUIRES)
  cmake_parse_arguments(SPHINX
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN}
  )

  if(NOT SCINE_BUILD_DOCS)
    return()
  endif()

  include(FindPythonModule)
  find_python_module(sphinx QUIET)
  if(NOT PY_SPHINX)
    message(STATUS "Sphinx python package not found, cannot build python documentation")
    return()
  endif()

  # Copy sources
  file(GLOB SPHINX_SOURCES ${SPHINX_SOURCE_DIR}/*)
  file(COPY ${SPHINX_SOURCES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/sphinx)
  gather_upstream_sphinxes(SPHINX_UPSTREAM_LINKS ${SPHINX_LINK})

  foreach(target ${SPHINX_UPSTREAM_LINKS})
    get_target_property(DOC_NAME ${target} NAME)
    get_target_property(DOC_OUTPUT_DIR ${target} SPHINX_OUTPUT_DIR)
    file(RELATIVE_PATH REL_PATH ${CMAKE_CURRENT_BINARY_DIR}/sphinx ${DOC_OUTPUT_DIR})
    list(APPEND INTERSPHINX_MAPPINGS "\"${DOC_NAME}\": (\"${REL_PATH}\", None)")
    message(STATUS "${DOC_NAME}: ${REL_PATH}")
  endforeach()
  if(INTERSPHINX_MAPPINGS)
    list(JOIN INTERSPHINX_MAPPINGS ", " INTERSPHINX_MAPPING)
  else()
    set(INTERSPHINX_MAPPING "")
  endif()

  # Configure configuration file
  configure_file(
    ${SPHINX_CONFIGURATION}
    ${CMAKE_CURRENT_BINARY_DIR}/sphinx/conf.py
    @ONLY
  )

  if(TARGET ${SPHINX_TARGET})
    # Assume it's a python binding module and an upstream dependency of the
    # documentation
    get_target_property(PYTHON_MODULE_NAME ${SPHINX_TARGET} NAME)
  else()
    # Only use the specified argument as part of the target name instead
    set(PYTHON_MODULE_NAME ${SPHINX_TARGET})
  endif()

  add_custom_target(${PYTHON_MODULE_NAME}Documentation
    ALL
    COMMAND ${PYTHON_EXECUTABLE} -m sphinx -b html -a -E "sphinx" "${SPHINX_OUTPUT}"
    DEPENDS ${SPHINX_SOURCES}
    COMMENT "Generate python documentation with sphinx for ${PYTHON_MODULE_NAME}"
  )
  if(TARGET ${SPHINX_TARGET})
    add_dependencies(${PYTHON_MODULE_NAME}Documentation ${SPHINX_TARGET})
  endif()
  set_target_properties(${PYTHON_MODULE_NAME}Documentation PROPERTIES
    SPHINX_OUTPUT_DIR "${SPHINX_OUTPUT}"
  )

  foreach(target ${SPHINX_UPSTREAM_LINKS})
    add_dependencies(${PYTHON_MODULE_NAME}Documentation ${target})
  endforeach()

  if(SPHINX_DOCTEST AND SCINE_BUILD_TESTS)
    find_python_module(doctest QUIET)
    if(NOT PY_DOCTEST)
      message(WARNING "Python doctesting of ${PYTHON_MODULE_NAME} disabled: doctest module is missing")
      return()
    endif()

    foreach(dependency ${SPHINX_DOCTEST_REQUIRES})
      if(TARGET ${dependency})
        get_target_property(MODULE_BINARY_DIR ${dependency} BINARY_DIR)
        list(APPEND PYTHONPATH_EXTS ${MODULE_BINARY_DIR})
      else()
        find_python_module(${target} QUIET)
        if(NOT PY_${dependency})
          message(WARNING "Python doctesting of ${PYTHON_MODULE_NAME} disabled: ${dependency} module is missing")
          return()
        endif()
      endif()
    endforeach()

    add_test(
      NAME ${PYTHON_MODULE_NAME}Doctest
      COMMAND ${PYTHON_EXECUTABLE} -c "import sys, doctest, ${PYTHON_MODULE_NAME}; (f, _) = doctest.testmod(${PYTHON_MODULE_NAME}); sys.exit(f > 0)"
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    if(PYTHONPATH_EXTS)
      list(JOIN PYTHONPATH_EXTS ":" PYTHONPATH_EXT)
      set_tests_properties(${PYTHON_MODULE_NAME}Doctest PROPERTIES
        ENVIRONMENT PYTHONPATH=${PYTHONPATH_EXT}:$ENV{PYTHONPATH}
      )
    endif()
  endif()
endfunction()
