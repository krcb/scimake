# - FindSciMathJax: This module looks for MathJax java code.
# MathJax is a web capable, javascript display engine for mathematics.
# See http://www.mathjax.org
#
# This module works from the variable
#
#  MATHJAXJS =  the full path or url to MathJax.js
#
# This modules defines the following variables:
#
#  MathJax_MathJax_js = the full path or url to MathJax.js
#  MathJax_DIR        = If not a url, the directory containing MathJax.js
#

# if MATHJAXJS is defined, use that
if (MATHJAXJS)
  message(STATUS "MATHJAXJS = ${MATHJAXJS}.  Will use that.")
  set(MathJax_MathJax_js ${MATHJAXJS})
  if (NOT "${MATHJAXJS}" MATCHES "^http")
    get_filename_component(MathJax_DIR ${MathJax_MathJax_js}/.. REALPATH)
  endif ()
  set(MATHJAX_FOUND TRUE)
else ()
  message(STATUS "MATHJAXJS not defined.  Will have to find it.")
# Key of build to find same kind
  message(STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}.")
  if ("${CMAKE_INSTALL_PREFIX}" MATCHES "-lite\$")
    SciFindPackage(PACKAGE MathJax INSTALL_DIRS MathJax-lite FILES MathJax.js)
  else ()
    SciFindPackage(PACKAGE MathJax INSTALL_DIRS MathJax FILES MathJax.js)
  endif ()
  get_filename_component(MathJax_DIR ${MathJax_MathJax_js}/.. REALPATH)
endif ()
message(STATUS "  MathJax_DIR          = ${MathJax_DIR}")
message(STATUS "  MathJax_MathJax_js   = ${MathJax_MathJax_js}")

