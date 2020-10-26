#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_set_find_paths()
conan_set_find_library_paths()
conan_set_libcxx()
conan_check_compiler()
