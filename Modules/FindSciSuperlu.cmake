# - FindSciSuperlu: Module to find include directories and libraries
#   for Superlu. This module was implemented as there is no stock
#   CMake module for Superlu.
#
#   This handles the fact that if ENABLE_PARALLEL is set, we are looking
#   for superlu_dist, whereas serial is just superlu.  Specifically,
#   bilder will link the packages as:
#     $INSTALL_DIR/superlu
#     $INSTALL_DIR/superlu-sersh
#     $INSTALL_DIR/superlu_dist-par
#     $INSTALL_DIR/superlu_dist-parcomm
#     $INSTALL_DIR/superlu_dist-parcommsh
#     $INSTALL_DIR/superlu_dist-parsh
#   where comm denotes "commercial builds"; i.e., builds that are free
#   of GPL code
#   The default is to grab superlu or superlu_dist based on whether
#   ENABLE_PARALLEL is set.  To choose another, use SUPERLU_FIND_VERSION
#   which will search for 
#      superlu${SUPERLU_FIND_VERSION} or 
#      superlu_dist${SUPERLU_FIND_VERSION}
#
# This module can be included in CMake builds in find_package:
#   find_package(SciSuperlu REQUIRED)
#
# This module will define the following variables:
#  HAVE_SUPERLU         = Whether have the Superlu library
#  Superlu_INCLUDE_DIRS = Location of Superlu includes
#  Superlu_LIBRARY_DIRS = Location of Superlu libraries
#  Superlu_LIBRARIES    = Required libraries
#  Superlu_STLIBS       = Location of Superlu static library

######################################################################
#
# SciFindSuperlu: find includes and libraries for Superlu.
#
# $Id$
#
# Copyright 2010-2012 Tech-X Corporation.
# Arbitrary redistribution allowed provided this copyright remains.
#
######################################################################
set(SUPRA_SEARCH_PATH ${SUPRA_SEARCH_PATH})

if (DEFINED SUPERLU_FIND_VERSION)
  if(ENABLE_PARALLEL) 
    set(Superlu_SEARCH "superlu_dist${SUPERLU_FIND_VERSION}")
  else()
    set(Superlu_SEARCH "superlu${SUPERLU_FIND_VERSION}")
  endif()
else()
  if(ENABLE_PARALLEL) 
    set(Superlu_SEARCH "superlu_dist")
  else()
    set(Superlu_SEARCH "superlu")
  endif()
endif()

###
##  Define what to search for
#
if(ENABLE_PARALLEL) 
  set(Superlu_MESSAGE_SEARCH "superlu_dist")
  if(NOT DEFINED Superlu_SEARCH_HEADERS)
    set(Superlu_SEARCH_HEADERS "superlu_defs.h;superlu_zdefs.h")
  endif()
  if(NOT DEFINED Superlu_SEARCH_LIBS)
    set(Superlu_SEARCH_LIBS "libsuperlu_dist.a")
  endif()
else()
  set(Superlu_MESSAGE_SEARCH "superlu")
  if(NOT DEFINED Superlu_SEARCH_HEADERS)
    set(Superlu_SEARCH_HEADERS "slu_util.h;slu_cdefs.h")
  endif()
  if(NOT DEFINED Superlu_SEARCH_LIBS)
    set(Superlu_SEARCH_LIBS "libsuperlu.a")
  endif()
endif()

SciFindPackage(PACKAGE "Superlu"
              INSTALL_DIR ${Superlu_SEARCH}
              HEADERS  ${Superlu_SEARCH_HEADERS}
              LIBRARIES ${Superlu_SEARCH_LIBS}
              )

if (SUPERLU_FOUND)
  message(STATUS "Found ${Superlu_MESSAGE_SEARCH}")
  set(HAVE_SUPERLU 1 CACHE BOOL "Whether have the ${Superlu_MESSAGE_SEARCH} library")
else ()
  message(STATUS "Did not find ${Superlu_MESSAGE_SEARCH}.  Use -DSUPERLU_DIR to specify the installation directory.")
  if (SciSuperlu_FIND_REQUIRED)
    message(FATAL_ERROR "Failed.")
  endif ()
endif ()
