######################################################################
#
# SciUnitTestMacros: Macros for adding unit tests of various types.
#
# $Id$
#
# Copyright 2014-2015, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
#
######################################################################

# Add the specified directories to the shared libraries path
macro(SciAddSharedLibDirs)
# parse the path argument
  set(multiValArgs ADDPATH)
  cmake_parse_arguments(SHLIB_DIRS "${opts}" "${oneValArgs}" "${multiValArgs}" ${ARGN})
# if 1+ directories were specified add it/them to the path in the parent scope
  if (SHLIB_DIRS_ADDPATH)
    set(SHLIB_CMAKE_PATH_VAL ${SHLIB_DIRS_ADDPATH} ${SHLIB_CMAKE_PATH_VAL})
    if (NOT "${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")
# it only makes sense to set the variable in the parent scope if not
# in the top level directory
      set(SHLIB_CMAKE_PATH_VAL "${SHLIB_CMAKE_PATH_VAL}" PARENT_SCOPE)
    endif (NOT "${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")

# make a system native path var containing all of the shared libraries
# directories
    makeNativePath(INPATH "${SHLIB_CMAKE_PATH_VAL}" OUTPATH SCIMAKE_SHLIB_NATIVE_PATH_VAL)
  endif (SHLIB_DIRS_ADDPATH)
endmacro()

# Add current binary dir to shared lib path var. This is needed when doing
# shared builds in order for executables to run.
macro(SciAddCurrentBinaryDir)
  SciAddSharedLibDirs(ADDPATH "${CMAKE_CURRENT_BINARY_DIR}")
endmacro()

# make a macro for converting a cmake path into a platform specific path
macro(makeNativePath)
  set(oneValArgs OUTPATH)
  set(multiValArgs INPATH)
  cmake_parse_arguments(TO_NATIVE "${opts}" "${oneValArgs}" "${multiValArgs}" ${ARGN})
  file(TO_NATIVE_PATH "${TO_NATIVE_INPATH}" NATIVE_OUTPATH)
  if (WIN32)
    string(REPLACE ";" "\\;" ${TO_NATIVE_OUTPATH} "${NATIVE_OUTPATH}")
  else ()
    string(REPLACE ";" ":" ${TO_NATIVE_OUTPATH} "${NATIVE_OUTPATH}")
  endif ()
endmacro()

message("")
message("--------- Setting up testing ---------")

# Set test environment
if (WIN32)
  set(SHLIB_PATH_VAR PATH)
elseif (APPLE)
  set(SHLIB_PATH_VAR DYLD_LIBRARY_PATH)
elseif (LINUX)
  set(SHLIB_PATH_VAR LD_LIBRARY_PATH)
endif ()
message(STATUS "SHLIB_PATH_VAR = ${SHLIB_PATH_VAR}.")

file(TO_CMAKE_PATH "$ENV{${SHLIB_PATH_VAR}}" SHLIB_CMAKE_PATH_VAL)
makeNativePath(INPATH "${SHLIB_CMAKE_PATH_VAL}" OUTPATH SCIMAKE_SHLIB_NATIVE_PATH_VAL)

message(STATUS "In SciAddUnitTestMacros.cmake, SHLIB_CMAKE_PATH_VAL = ${SHLIB_CMAKE_PATH_VAL}")

# Add a unit test. If the test needs to compare its results against some
# expected results, then RESULTS_DIR and RESULTS (or STDOUT) must be set.
#
# Args
#
#   NAME          = the name of this test (which may or may not be the same
#                   as the executable)
#   COMMAND       = test executable (typically same as NAME, but need not be)
#   SOURCES       = 1+ source files to be compiled
#   LIBS          = libraries needed to link test
#   ARGS          = arguments to run the executable with
#   DIFFER        = Name of executable to do diff.  If not given, assumed to
#                   be "diff --strip-trailing-cr" in SciTextCompare.
#   SORTER        = Name of executable to sort output with before comparing. If
#                   not specified, no sorting is done.
#   TEST_DIR      = Where the test files are generated.  Defaults to current
#                   binary dir.
#   DIFF_DIR      = Where the golden files are located.  Defaults to current
#                   source dir.
#   RESULTS_DIR   = Backward compatible way of specifying DIFF_DIR.
#   STDOUT_FILE   = Name of file into which stdout should be captured. This
#                   will be compared against a same named file in ${DIFF_DIR}.
#   TEST_FILES    = Additional test generated files
#   DIFF_FILES    = Golden generated files.  Should be same-length vector.
#                   Defaults to TEST_FILES.
#   MPIEXEC_PROG  = File to preface executable with for parallel run.
#   NUMPROCS      = Number of processors to specify for parallel run.
#   USE_CUDA_ADD  = Add libraries and executables using cuda
#   LABELS        = Add these labels to the unit test

macro(SciAddUnitTest)
  set(opts USE_CUDA_ADD)
  set(oneValArgs NAME COMMAND ARGS TEST_DIR DIFF_DIR RESULTS_DIR STDOUT_FILE NUMPROCS MPIEXEC_PROG)
  set(multiValArgs SORTER DIFFER RESULTS_FILES TEST_FILES DIFF_FILES
      SOURCES LIBS LABELS
      PROPERTIES ATTACHED_FILES)
  cmake_parse_arguments(TEST
      "${opts}" "${oneValArgs}" "${multiValArgs}" ${ARGN}
  )
  if (NOT TEST_COMMAND)
    set (TEST_COMMAND ${TEST_NAME})
  endif ()
  if (IS_ABSOLUTE ${TEST_COMMAND})
    set(TEST_EXECUTABLE "${TEST_COMMAND}")
  else ()
    set(TEST_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/${TEST_COMMAND}")
  endif ()
# Backward compatible specification of goldern results localtion
  if (NOT TEST_RESULTS_DIR)
    set(TEST_RESULTS_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  endif ()
# Actual golden results location
  if (NOT TEST_DIFF_DIR)
    set(TEST_DIFF_DIR ${TEST_RESULTS_DIR})
  endif ()
# Location of test files
  if (NOT TEST_TEST_DIR)
    set(TEST_TEST_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif ()
# make sure there are test and diff files
  if (NOT TEST_TEST_FILES)
    set(TEST_TEST_FILES ${TEST_RESULTS_FILES})
  endif ()
  if (NOT TEST_DIFF_FILES)
    foreach (fname ${TEST_TEST_FILES})
      get_filename_component(TEST_DIFF_FILE "${fname}" NAME)
      set(TEST_DIFF_FILES ${TEST_DIFF_FILES} "${TEST_DIFF_FILE}")
    endforeach ()
  endif ()
# if parallel set the mpiexec argument
  if (TEST_NUMPROCS AND ENABLE_PARALLEL AND MPIEXEC)
    set(TEST_MPIEXEC "${MPIEXEC} -np ${TEST_NUMPROCS}")
  else ()
    set(TEST_MPIEXEC)
  endif (TEST_NUMPROCS AND ENABLE_PARALLEL AND MPIEXEC)
  if (TEST_SOURCES)
    if (TEST_USE_CUDA_ADD)
      cuda_add_executable(${TEST_COMMAND} ${TEST_SOURCES})
    else ()
      add_executable(${TEST_COMMAND} ${TEST_SOURCES})
    endif ()
  endif ()
  if (TEST_LIBS)
    target_link_libraries(${TEST_COMMAND} ${TEST_LIBS})
  endif ()
  add_test(NAME ${TEST_NAME} COMMAND ${CMAKE_COMMAND}
      "-DTEST_SORTER:BOOL=${TEST_SORTER}"
      "-DTEST_DIFFER:STRING=${TEST_DIFFER}"
      -DTEST_PROG:FILEPATH=${TEST_EXECUTABLE}
      -DTEST_MPIEXEC:STRING=${TEST_MPIEXEC}
      -DTEST_ARGS:STRING=${TEST_ARGS}
      -DTEST_STDOUT_FILE:STRING=${TEST_STDOUT_FILE}
      -DTEST_TEST_DIR:PATH=${TEST_TEST_DIR}
      -DTEST_TEST_FILES:STRING=${TEST_TEST_FILES}
      -DTEST_DIFF_DIR:PATH=${TEST_DIFF_DIR}
      -DTEST_DIFF_FILES:STRING=${TEST_DIFF_FILES}
      -DTEST_SCIMAKE_DIR:PATH=${SCIMAKE_DIR}
      -P ${SCIMAKE_DIR}/SciTextCompare.cmake
  )
  if (TEST_LABELS)
    set_tests_properties(${TEST_NAME} PROPERTIES LABELS "${TEST_LABELS}")
  endif ()

# ATTACHED_FILES is a list of files to attach and if non-empty, it
# overrides the default, which is ${TEST_RESULTS_FILES}.
  if (TEST_ATTACHED_FILES)
    set(FILES_TO_ATTACH ${TEST_ATTACHED_FILES})
  else ()
    set(FILES_TO_ATTACH ${TEST_RESULTS_FILES})
  endif ()
  set_tests_properties(${TEST_NAME}
    PROPERTIES ENVIRONMENT
      "${SHLIB_PATH_VAR}=${SCIMAKE_SHLIB_NATIVE_PATH_VAL}" ${TEST_PROPERTIES}
    ATTACHED_FILES_ON_FAIL "${FILES_TO_ATTACH}"
  )

# Add command to replace results
  add_custom_target(${TEST_NAME}ReplaceResults)
  string(REPLACE " " ";" resfiles "${TEST_RESULTS_FILES}")
  foreach (file ${TEST_STDOUT_FILE} ${resfiles})
    add_custom_command(TARGET ${TEST_NAME}ReplaceResults
      COMMAND ${CMAKE_COMMAND} -E copy ${file} ${TEST_DIFF_DIR}
      WORKING_DIRECTORY ${TEST_TEST_DIR}
    )
  endforeach ()

endmacro()

#
# Check the source with cppcheck
#
macro(SciCppCheckSource build)
  if (("${build}" STREQUAL "") OR (CppCheck_cppcheck AND ${CMAKE_INSTALL_PREFIX} MATCHES "${build}$"))
    message(STATUS "Source code checking enabled.")
    add_test(NAME cppcheck COMMAND ${CMAKE_COMMAND}
      -DCppCheck_cppcheck:FILEPATH=${CppCheck_cppcheck}
      -DCPPCHECK_SOURCE_DIR:PATH=${CMAKE_SOURCE_DIR}
      -P ${SCIMAKE_DIR}/SciCppCheck.cmake
    )
    set_tests_properties(cppcheck
      PROPERTIES ENVIRONMENT
        "${SHLIB_PATH_VAR}=${SCIMAKE_SHLIB_NATIVE_PATH_VAL}"
    )
  else ()
    message(STATUS "Source code checking not enabled.")
  endif ()
endmacro()

