#
# This file is licensed under the 3-clause BSD license.
# Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
# See LICENSE.txt for details.
#

macro(cmessage_format)
  string(CONCAT _msg ${ARGV})
  string(STRIP ${_msg} _msg)
  string(REGEX REPLACE "[\r\n]" "" formatted "${_msg}")
  unset(_msg)
endmacro()

function(cmessage)
  if(NOT WIN32)
    string(ASCII 27 Esc)
    set(ColorReset "${Esc}[m")
    set(ColorBold  "${Esc}[1m")
    set(Red         "${Esc}[31m")
    set(Green       "${Esc}[32m")
    set(Yellow      "${Esc}[33m")
    set(Blue        "${Esc}[34m")
    set(Magenta     "${Esc}[35m")
    set(Cyan        "${Esc}[36m")
    set(White       "${Esc}[37m")
    set(BoldRed     "${Esc}[1;31m")
    set(BoldGreen   "${Esc}[1;32m")
    set(BoldYellow  "${Esc}[1;33m")
    set(BoldBlue    "${Esc}[1;34m")
    set(BoldMagenta "${Esc}[1;35m")
    set(BoldCyan    "${Esc}[1;36m")
    set(BoldWhite   "${Esc}[1;37m")
  endif()

  list(GET ARGV 0 MessageType)
  if(MessageType STREQUAL FATAL_ERROR OR MessageType STREQUAL SEND_ERROR)
    list(REMOVE_AT ARGV 0)
    cmessage_format(${ARGV})
    message(${MessageType} "${BoldRed}${formatted}${ColorReset}")
  elseif(MessageType STREQUAL WARNING)
    list(REMOVE_AT ARGV 0)
    cmessage_format(${ARGV})
    message(STATUS "${Yellow}${formatted}${ColorReset}")
  elseif(MessageType STREQUAL AUTHOR_WARNING)
    list(REMOVE_AT ARGV 0)
    cmessage_format(${ARGV})
    message(STATUS "${BoldCyan}${formatted}${ColorReset}")
  elseif(MessageType STREQUAL STATUS)
    list(REMOVE_AT ARGV 0)
    cmessage_format(${ARGV})
    message(${MessageType} "${Green}${formatted}${ColorReset}")
  else()
    cmessage_format(${ARGV})
    message("${formatted}")
  endif()
endfunction()
