# install our .desktop file so the Applications menu will see it
install (FILES "desktop/indicator-kdeconnect.desktop" DESTINATION ${DATADIR}/applications/)

# install extensions
install (FILES "extensions/kdeconnect.contract" DESTINATION ${DATADIR}/contractor/)
install (FILES "extensions/kdeconnect-send-nautilus.py" DESTINATION ${DATADIR}/nautilus-python/extensions/)
install (FILES "extensions/kdeconnect-send-nemo.py" DESTINATION ${DATADIR}/nemo-python/extensions/)
install (FILES "extensions/kdeconnect-send-caja.py" DESTINATION ${DATADIR}/caja-python/extensions/)
install (FILES "extensions/kdeconnect-send-thunar.desktop" DESTINATION ${DATADIR}/Thunar/sendto/)

#-Ubuntu
if(EXISTS ${DATADIR}/icons/ubuntu-mono-dark) 
install (DIRECTORY "icons/ubuntu-mono-dark" DESTINATION ${DATADIR}/icons)
endif()
if(EXISTS ${DATADIR}/icons/ubuntu-mono-light)
install (DIRECTORY "icons/ubuntu-mono-light" DESTINATION ${DATADIR}/icons)
endif()
#-Adwaita status panel icons
if(EXISTS ${DATADIR}/icons/Adwaita)
install (DIRECTORY "icons/Adwaita" DESTINATION ${DATADIR}/icons)
endif()
#-Elementary OS
if(EXISTS ${DATADIR}/icons/elementary)
install (DIRECTORY "icons/elementary" DESTINATION ${DATADIR}/icons)
endif()

#install FTW image
install (FILES "images/indicator.jpg" DESTINATION ${DATADIR}/indicator-kdeconnect/)
install (FILES "images/startup.jpg" DESTINATION ${DATADIR}/indicator-kdeconnect/)

#install appdata
install(FILES "data/com.bajoja.indicator-kdeconnect.appdata.xml"
        DESTINATION share/metainfo)

#update icons cache
install(
	CODE
	"execute_process (COMMAND gtk-update-icon-cache -t -f ${CMAKE_INSTALL_PREFIX}/share/icons)"
	CODE
	"message (STATUS \"Updated icon cache in ${CMAKE_INSTALL_PREFIX}/share/icons\")"
	)
