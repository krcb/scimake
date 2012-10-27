# - SciSphinxFunctions: 
# Usefule functions for simplifying the setting up of sphinx targets
#
# All functions assume that FindSciSphinx was used and the following are
# defined:
#   Sphinx_EXECUTABLE     = The path to the sphinx command.
#   Sphinx_OPTS           = Options for sphinx
#

#################################################################
#
# $Id: SciSphinxFunctions.cmake 64 2012-09-22 14:48:08Z jrobcary $
#
#################################################################

include(CMakeParseArguments)

# SciSphinxTarget.cmake
# Define the target for making HTML
# Args:
#   TARGET:  Name to make the target.  Actual target will be #   ${TARGET_NAME}-html
#   RST_FILE_BASE:  Root name of Latex file.  From conf.py
#   SOURCE_DIR:  Directory containing the index.rst.  Defaults to CMAKE_CURRENT_SOURCE_DIR
#   SPHINX_ADDL_OPTS:  Additional options to Sphinx
#   FILE_DEPS:  Files that are the dependencies
#   SPHINX_BUILDS: Which builds to include.  Default is "html latex pdf "
#    Possible choices are "html latex pdf singlehtml man"
#   SPHINX_INSTALLS: Which builds to install.  Default is same as builds
#   NOWARN_NOTMATCH_DIR: Do not warn if file base does not match install dir
#   INSTALL_SUPERDIR: Name of installation directory up to this one.
#                     Should not be absolute (not include prefix).
#                     Overridden by INSTALL_SUBDIR.
#   INSTALL_SUBDIR:   Name of this subdir for installation.
#                   Should not be absolute (not include prefix).
#
macro(SciSphinxTarget)

# Parse out the args
  set(opts DEBUG;NOWARN_NOTMATCH_DIR) # no-value args
  set(oneValArgs RST_FILE_BASE;TARGET;SPHINX_ADDL_OPTS;SOURCE_DIR;INSTALL_SUPERDIR;INSTALL_SUBDIR)
  set(multValArgs FILE_DEPS;ALL_BUILDS) # e.g., lists
  cmake_parse_arguments(FD "${opts}" "${oneValArgs}" "${multValArgs}" ${ARGN})

  ###
  ## Defaults
  #
  if(NOT DEFINED FD_SOURCE_DIR)
    set(FD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  if(NOT DEFINED FD_SPHINX_BUILDS)
    set(FD_SPHINX_BUILDS)
    list(APPEND FD_SPHINX_BUILDS html latex pdf)
  endif()
  if(NOT DEFINED FD_SPHINX_INSTALLS)
    set(FD_SPHINX_INSTALLS ${FD_SPHINX_BUILDS})
  endif()
  if (FD_INSTALL_SUBDIR)
    set(instdir ${DOC_INSTALL_SUBDIR})
  elseif (DOC_INSTALL_SUPERDIR)
    set(instdir ${DOC_INSTALL_SUPERDIR}/${thissubdir})
  else ()
    set(instdir share)
  endif ()
  ###
  ##  Basic sanity checks
  #
  get_filename_component(thissubdir ${CMAKE_CURRENT_SOURCE_DIR} NAME)
  if (NOT NOWARN_NOTMATCH_DIR)
    set(WARN_NOTMATCH_DIR)
  endif ()
  if (WARN_NOTMATCH_DIR)
    if (NOT "${thissubdir}" STREQUAL "${FD_RST_FILE_BASE}")
      message(WARNING "Main rst file base, ${FD_RST_FILE_BASE}, does not match subdirectory name, ${thissubdir}.")
    endif ()
  endif ()

  if(NOT DEFINED FD_TARGET)
     message(WARNING "SciSphinxTarget called without specifying the target name")
     return()
  endif()
  if(NOT DEFINED FD_FILE_DEPS)
     message(WARNING "SciSphinxTarget called without specifying the file dependencies")
     return()
  endif()
  if(NOT DEFINED FD_RST_FILE_BASE)
     message(WARNING "SciSphinxTarget called without specifying the latex root from conf.py")
     return()
  endif()
  if(NOT DEFINED Sphinx_EXECUTABLE)
     message(WARNING "SciSphinxTarget called without defining Sphinx_EXECUTABLE")
     return()
  endif()
  if (FD_DEBUG)
    message("")
    message("--------- SciSphinxTarget defining ${FD_TARGET}-html ---------")
    message(STATUS "[SciSphinxFunctions]: TARGET= ${FD_TARGET} ")
    message(STATUS "[SciSphinxFunctions]: RST_FILE_BASE= ${FD_RST_FILE_BASE} ")
    message(STATUS "[SciSphinxFunctions]: Sphinx_EXECUTABLE= ${Sphinx_EXECUTABLE} ")
    message(STATUS "[SciSphinxFunctions]: Sphinx_OPTS= ${Sphinx_OPTS} ")
    message(STATUS "[SciSphinxFunctions]: SPHINX_ADDL_OPTS= ${FD_SPHINX_ADDL_OPTS} ")
  endif()
  ###
  ##  Do the standard builds
  #
  set(html_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/html/index.html)
  set(singlehtml_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/singlehtml/index.html)
  set(latex_OUTPUT ${BLDDIR}/pdf/${FD_RST_FILE_BASE}.tex)
  set(pdf_OUTPUT ${BLDDIR}/pdf/${FD_RST_FILE_BASE}.pdf)
  set(man_OUTPUT ${BLDDIR}/man/index.man)

  foreach (build ${FD_SPHINX_BUILDS})
    set (${build}_DIR ${CMAKE_CURRENT_BINARY_DIR}/${build})
    # Latex is actually for pdf which is below
    if(${build} STREQUAL latex)
      set (${build}_DIR ${CMAKE_CURRENT_BINARY_DIR}/pdf)
    endif()
    
    # There is something weird about passing blank spaces into COMMAND 
    # so this method fixes the problems that arise if Sphinx_OPTS is not defined
    set(all_opts -b ${build} ${Sphinx_OPTS} ${FD_SPHINX_ADDL_OPTS})

    if(NOT ${build} STREQUAL pdf)
      add_custom_command(
        OUTPUT ${${build}_OUTPUT}
        COMMAND ${Sphinx_EXECUTABLE} ${all_opts} ${FD_SOURCE_DIR} ${${build}_DIR}
        DEPENDS ${FD_FILE_DEPS}
      )
      add_custom_target(${FD_TARGET}-${build} DEPENDS ${${build}_OUTPUT})
    endif()
  endforeach()

  ###
  ##  PDF is special
  ##   This must be make, as sphinx generates a unix makefile
  #
  add_custom_command(
    OUTPUT ${pdf_OUTPUT}
    COMMAND make all-pdf
    DEPENDS ${latex_OUTPUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/pdf
  )
  add_custom_target(${FD_TARGET}-pdf DEPENDS ${pdf_OUTPUT})

  ###
  ##  Each install is a one-off
  # 
  list(FIND SPHINX_INSTALLS "pdf" indx)
  if (NOT indx EQUAL -1)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/pdf/${FD_RST_FILE_BASE}.pdf
      DESTINATION "${instdir}"
      PERMISSIONS OWNER_WRITE OWNER_READ GROUP_WRITE GROUP_READ WORLD_READ
    )
  endif ()
  list(FIND SPHINX_INSTALLS "html" indx)
  if (NOT indx EQUAL -1)
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html
      DESTINATION ${instdir}
      FILE_PERMISSIONS OWNER_WRITE OWNER_READ GROUP_WRITE GROUP_READ WORLD_READ
    )
  endif ()
  list(FIND SPHINX_INSTALLS "man" indx)
  if (NOT indx EQUAL -1)
    install(
      DIRECTORY ${BLDDIR}/man
      OPTIONAL
      DESTINATION ${instdir}/man
      COMPONENT userdocs
    )
  endif ()
endmacro()
