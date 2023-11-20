#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_mongocxx)
  # If the target already exists, do nothing
  if (NOT TARGET MongoDBCXX)
    find_package(libmongocxx QUIET)
    if(DEFINED LIBMONGOCXX_INCLUDE_DIRS)
      add_library(MongoDBCXX INTERFACE IMPORTED)
      set_target_properties(MongoDBCXX PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBMONGOCXX_INCLUDE_DIRS};${LIBBSONCXX_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES "${LIBMONGOCXX_LIBRARIES};${LIBBSONCXX_LIBRARIES}"
      )
    else()
      find_package(libmongocxx-static REQUIRED)
      add_library(MongoDBCXX INTERFACE IMPORTED)
      set_target_properties(MongoDBCXX PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBMONGOCXX_STATIC_INCLUDE_DIRS};${LIBBSONCXX_STATIC_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES "${LIBMONGOCXX_STATIC_LIBRARIES};${LIBBSONCXX_STATIC_LIBRARIES}"
      )
    endif()
  endif()
endmacro()
