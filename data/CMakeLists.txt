# install our .desktop file so the Applications menu will see it
install (FILES "desktop/indicator-kdeconnect.desktop" DESTINATION ${DATADIR}/applications/)

# install extensions
install (FILES "extensions/kdeconnect.contract" DESTINATION ${DATADIR}/contractor/)
install (FILES "extensions/kdeconnect-send-nautilus.py" DESTINATION ${DATADIR}/nautilus-python/extensions/)
install (FILES "extensions/kdeconnect-send-nemo.py" DESTINATION ${DATADIR}/nemo-python/extensions/)
install (FILES "extensions/kdeconnect-send-caja.py" DESTINATION ${DATADIR}/caja-python/extensions/)

#install icons
install (FILES "icons/default/smartphone-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/tablet-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/computer-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
install (FILES "icons/default/laptop-symbolic.svg" DESTINATION ${DATADIR}/icons/hicolor/scalable/devices/)
#-Ubuntu
if(EXISTS ${DATADIR}/icons/ubuntu-mono-dark) 
install (DIRECTORY "icons/ubuntu-mono-dark" DESTINATION ${DATADIR}/icons)
endif()
if(EXISTS ${DATADIR}/icons/ubuntu-mono-light)
install (DIRECTORY "icons/ubuntu-mono-light" DESTINATION ${DATADIR}/icons)
endif()
#-Elementary OS
if(EXISTS ${DATADIR}/icons/ubuntu-mono*)
install (DIRECTORY "icons/elementary" DESTINATION ${DATADIR}/icons)
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
