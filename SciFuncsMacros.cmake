######################################################################
#
# SciFuncsMacros: Various functions and macros used by Tech-X scimake
#
# $Id$
#
# Copyright 2010-2014, Tech-X Corporation, Boulder, CO.
# Arbitrary redistribution allowed provided this copyright remains.
#
#
######################################################################

#
# SciPrintString: print a string in a status message as well as to
#   ${CONFIG_SUMMARY}
# Args:
#   str the string
#
macro(SciPrintString str)
  message(STATUS "${str}")
  if (DEFINED CONFIG_SUMMARY)
    file(APPEND "${CONFIG_SUMMARY}" "${str}\n")
  else ()
    message(WARNING "Variable CONFIG_SUMMARY is not defined, SciPrintString is unable to write to the summary file.")
  endif ()
endmacro()

#
# SciPrintVar: print a variable with standard formatting
# Args:
#   var the name of the variable
#
macro(SciPrintVar var)
  string(LENGTH "${var}" lens)
  math(EXPR lenb "35 - ${lens}")
  if (lenb GREATER 0)
    string(RANDOM LENGTH ${lenb} ALPHABET " " blstr)
  else ()
    set(blstr "")
  endif ()
  SciPrintString("  ${var}${blstr}= ${${var}}")
endmacro()

#
# Print all cmake variables generated by SciFindPackage
# Args:
#   pkg: the name of the package
#
macro(SciPrintCMakeResults pkg)
  # message("--------- RESULTS FOR ${pkg} ---------")
  SciPrintString("")
  SciPrintString("RESULTS FOR ${pkg}:")
  set(sfxs ROOT_DIR CONFIG_CMAKE CONFIG_VERSION_CMAKE PROGRAMS FILES INCLUDE_DIRS MODULE_DIRS LIBFLAGS LIBRARY_DIRS LIBRARY_NAMES LIBRARIES PLUGINS STLIBS)
  if (WIN32)
    set(sfxs ${sfxs} DLLS)
  elseif (APPLE)
    set(sfxs ${sfxs} FRAMEWORK_DIRS FRAMEWORK_NAMES FRAMEWORKS)
  endif ()
  set(sfxs ${sfxs} DEFINITIONS)
  foreach (varsfx ${sfxs})
    SciPrintVar(${pkg}_${varsfx})
  endforeach ()
endmacro()

#
# Print all autotools variables generated by SciFindPackage
# Args:
#   pkg: the name of the package
#
macro(SciPrintAutotoolsResults pkg)
  # message("--------- RESULTS FOR ${pkg} ---------")
  SciPrintString("")
  SciPrintString("RESULTS FOR ${pkg}:")
  foreach (varsfx ROOT_DIR DIR INCDIRS MODDIRS LIBS ALIBS)
    SciPrintVar(${pkg}_${varsfx})
  endforeach ()
  if (WIN32)
    SciPrintVar(${pkg}_DLLS)
  endif ()
endmacro()

#
# Install an executable in its own subdir
#
# EXECNAME: the name of the executable and also its installation subdir
# LIBSSFX: ${EXECNAME}_${LIBSSFX} holds the libraries that need to be installed
#
macro(SciInstallExecutable)
  set(oneValArgs EXECNAME LIBSSFX)
  cmake_parse_arguments(TIE_
    "${opts}" "${oneValArgs}" "${multiValArgs}" ${ARGN}
  )
  install(TARGETS ${TIE_EXECNAME}
    RUNTIME DESTINATION ${TIE_EXECNAME}/bin
    LIBRARY DESTINATION ${TIE_EXECNAME}/lib
    ARCHIVE DESTINATION ${TIE_EXECNAME}/lib
    PERMISSIONS OWNER_READ OWNER_WRITE
                GROUP_READ ${SCI_GROUP_WRITE}
                ${SCI_WORLD_FILE_PERMS}
    COMPONENT ${TIE_EXECNAME}
  )
  if (BUILD_SHARED_LIBS)
# Install libraries into each executable installation
    install(TARGETS txustd ${${TIE_EXECNAME}_${TIE_LIBSSFX}}
      RUNTIME DESTINATION ${TIE_EXECNAME}/bin
      LIBRARY DESTINATION ${TIE_EXECNAME}/lib
      ARCHIVE DESTINATION ${TIE_EXECNAME}/lib
      PERMISSIONS OWNER_READ OWNER_WRITE
                  GROUP_READ ${SCI_GROUP_WRITE}
                  ${SCI_WORLD_FILE_PERMS}
      COMPONENT ${TIE_EXECNAME}
    )
  endif ()
endmacro()

