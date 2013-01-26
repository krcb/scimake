include(FindPackageHandleStandardArgs)

find_program(RST2HTML_EXECUTABLE NAMES rst2html rst2html.py)
find_package_handle_standard_args(Docutils DEFAULT_MSG RST2HTML_EXECUTABLE)

find_program(RST2LATEX_EXECUTABLE NAMES rst2latex rst2latex.py)
find_package_handle_standard_args(Docutils DEFAULT_MSG RST2LATEX_EXECUTABLE)