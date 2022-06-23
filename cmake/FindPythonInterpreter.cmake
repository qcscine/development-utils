#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

# Try finding the Python interpreter and library in order of
# 1) user command via -DPYTHON_EXECUTABLE
# 2) environment
# 3) system paths
# after the call ${PYTHON_EXECUTABLE} should contain the correct path
function(find_python_interpreter)
  if(NOT DEFINED Python_FIND_STRATEGY)
    set(Python_FIND_STRATEGY LOCATION)
  endif()
  if(NOT DEFINED Python_FIND_REGISTRY)
    set(Python_FIND_REGISTRY LAST)
  endif()
  if(NOT DEFINED Python_FIND_VIRTUALENV)
    set(Python_FIND_VIRTUALENV STANDARD)
  endif()
  find_package(Python COMPONENTS Interpreter Development)

  # Python_ set by FindPython and PYTHON_ set by user via -DPYTHON_EXECUTABLE or set by FindPythonInterp, which is deprecated
  # Prefer PYTHON over Python
  if(Python_EXECUTABLE AND NOT PYTHON_EXECUTABLE)
    set(PYTHON_EXECUTABLE ${Python_EXECUTABLE})
  endif()

  if(NOT PYTHON_EXECUTABLE)
    message(FATAL_ERROR # executable variable is empty, give proper error here instead at install
            "Unable to find Python interpreter, required for Python bindings. Please install Python or specify the PYTHON_EXECUTABLE CMake variable.")
  endif()
  message(STATUS "Found Python interpreter ${PYTHON_EXECUTABLE}")
endfunction()
