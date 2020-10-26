#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

function(list_pop_front listname resultname)
  if(${CMAKE_VERSION} VERSION_LESS "3.15.0")
    if(${listname})
      list(GET ${listname} 0 firstElement)
      set(${resultname} ${firstElement} PARENT_SCOPE)
      list(REMOVE_AT ${listname} 0)
      set(${listname} ${${listname}} PARENT_SCOPE)
    endif()
  else()
    list(POP_FRONT ${listname} ${resultname})
    set(${resultname} ${${resultname}} PARENT_SCOPE)
    set(${listname} ${${listname}} PARENT_SCOPE)
  endif()
endfunction()

function(list_pop_back listname resultname)
  if(${CMAKE_VERSION} VERSION_LESS "3.15.0")
    if(${listname})
      list(LENGTH ${listname} listlength)
      math(EXPR lastElementIndex ${listlength}-1)
      list(GET ${listname} ${lastElementIndex} lastElement)
      set(${resultname} ${lastElement} PARENT_SCOPE)
      list(REMOVE_AT ${listname} ${lastElementIndex})
      set(${listname} ${${listname}} PARENT_SCOPE)
    endif()
  else()
    list(POP_BACK ${listname} ${resultname})
    set(${resultname} ${${resultname}} PARENT_SCOPE)
    set(${listname} ${${listname}} PARENT_SCOPE)
  endif()
endfunction()
