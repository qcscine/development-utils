#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#
macro(import_pugixml)
  # If the target already exists, do nothing
  if(NOT TARGET pugixml)
    find_package(pugixml QUIET)
    if(TARGET pugixml)
      message(STATUS "Found pugixml at ${pugixml_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ pugixml 
        URL https://github.com/zeux/pugixml/releases/download/v1.14/pugixml-1.14.tar.gz 
        QUIET
      )

      if(SCINE_PARALLELIZE)
        set(ENABLE_OPENMP ON)
      endif()
      set(BUILD_ARKODE OFF)

      add_subdirectory(${pugixml_SOURCE_DIR} ${pugixml_BINARY_DIR})

      # Final check if all went well
      if(EXISTS "${pugixml_SOURCE_DIR}/CMakeLists.txt")
        message(STATUS
          "pugixml was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "pugixml could not be downloaded."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()

