# install our .desktop file so the Applications menu will see it
install (FILES "desktop/indicator-kdeconnect.desktop" DESTINATION ${DATADIR}/applications/)

# install .contract file
install (FILES "extensions/kdeconnect.contract" DESTINATION ${DATADIR}/contractor/)

#install icons
install (FILES "icons/default/smartphone-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/tablet-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/computer-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/laptop-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
if(EXISTS ${DATADIR}/icons/ubuntu-mono-dark) 
install(DIRECTORY "icons/ubuntu-mono-dark" DESTINATION ${DATADIR}/icons)
endif()
if(EXISTS ${DATADIR}/icons/ubuntu-mono-light)
install(DIRECTORY "icons/ubuntu-mono-light" DESTINATION ${DATADIR}/icons)
endif()

#install FTW image
install (FILES "images/indicator.jpg" DESTINATION ${DATADIR}/indicator-kdeconnect/)
install (FILES "images/startup.jpg" DESTINATION ${DATADIR}/indicator-kdeconnect/)

#update icons cache
install(
	CODE
	"execute_process (COMMAND gtk-update-icon-cache -t -f ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)"
	CODE
	"message (STATUS \"Updated icon cache in ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor\")"
	)
