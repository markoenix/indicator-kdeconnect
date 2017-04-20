# Copyright 2017 KDE Connect Indicator Developers
#
# This software is licensed under the GNU Lesser General Public License
# (version 2.1 or later).  See the COPYING file in this distribution.
#

function(find_python_module module)
	execute_process(
	COMMAND
      	python3 -c "from requests_oauthlib import OAuth2Session"
      	RESULT_VARIABLE PYTHON_module
	ERROR_QUIET
      	OUTPUT_STRIP_TRAILING_WHITESPACE
      	)

	if(NOT PYTHON_module)
		message ("-- Found requests_oauthlib")
	else(PYTHON_module)
		message (FATAL_ERROR "-- Not Found requests_oauthlib: install it first")
	endif()

endfunction(find_python_module)

