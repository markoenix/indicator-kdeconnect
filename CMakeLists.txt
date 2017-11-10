# project name
project (indicator-kdeconnect)
# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)
# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (LOCALEDIR ${CMAKE_INSTALL_PREFIX}/share/locale)
# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/indicator-kdeconnect")
set (RELEASE_NAME "beta")
set (VERSION_INFO "Indicator for KDE Connect daemon")
set (VERSION "0.9.3")

# set gettexttranslate
set (GettextTranslate_GMO_BINARY TRUE)
set (GettextTranslate_ALL TRUE)

set (CONSTANTS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/Constants.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/Constants.vala.cmake ${CONSTANTS_FILE})
# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)
# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED gtk+-3.0 appindicator3-0.1)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})
# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.20" MINIMUM)
# files we want to compile
include(ValaPrecompile)
# make sure we use GettextTranslate
include(GettextTranslate)
# ensure python dependencies are satisfied
#include(FindPythonModule)
#find_python_module(requests_oauthlib)


#indicator
set (INDICATOR_EXEC "indicator-kdeconnect")
vala_precompile(INDICATOR_VALA_C ${INDICATOR_EXEC}
	# TODO: dont know why but this one doenst work
	# ${CONSTANTS_FILE}
	src/Constants.vala
	src/main.vala
	src/Device.vala
	src/KDEConnectManager.vala
	src/DeviceIndicator.vala
	src/FirstTimeWizard.vala
	src/StartupManager.vala
	src/settings/InOut.vala
	PACKAGES
	gtk+-3.0
	appindicator3-0.1
	       )

# tell cmake what to call the executable we just made
add_definitions(-Wno-deprecated-declarations)
add_definitions(-Wno-incompatible-pointer-types)
add_definitions(-Wformat)
add_definitions(-Wformat-security)
add_definitions(-DGETTEXT_PACKAGE="${PROJECT_NAME}")
add_definitions(-DLOCALEDIR="${LOCALEDIR}")
add_executable(${INDICATOR_EXEC} ${INDICATOR_VALA_C})
# install the binaries we just made
install (TARGETS ${INDICATOR_EXEC} RUNTIME DESTINATION bin)

# contractor binary
set (CONTRACTOR_EXEC "kdeconnect-send")
vala_precompile(VALA_C ${CONTRACTOR_EXEC}
	src/kdeconnectsend/KDEConnectSend.vala
	src/Device.vala
	PACKAGES
	gtk+-3.0
)

add_definitions(-Wno-deprecated-declarations)
add_definitions(-Wno-incompatible-pointer-types)
add_definitions(-Wformat)
add_definitions(-Wformat-security)
add_executable(${CONTRACTOR_EXEC} ${VALA_C})
install (TARGETS ${CONTRACTOR_EXEC} RUNTIME DESTINATION bin)

# settings binary
set (SETTINGS_EXEC "indicator-kdeconnect-settings")
vala_precompile(VALA_C ${SETTINGS_EXEC}
	src/settings/Settings.vala
	src/settings/InOut.vala
	PACKAGES
	gtk+-3.0
)

add_definitions(-Wno-deprecated-declarations)
add_definitions(-Wno-incompatible-pointer-types)
add_definitions(-Wformat)
add_definitions(-Wformat-security)
add_executable(${SETTINGS_EXEC} ${VALA_C})
install (TARGETS ${SETTINGS_EXEC} RUNTIME DESTINATION bin)


install (FILES "src/sms/Sms.py"
         DESTINATION ${DATADIR}/indicator-kdeconnect
         PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ
         GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# install data files
add_subdirectory(data)

# Translation files
add_subdirectory(po)

# Uninstall target
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

add_custom_target(uninstall
COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake)
