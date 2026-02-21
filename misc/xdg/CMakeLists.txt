set(configs
    ksplashrc
    kwinrc
    kdeglobals
    kvantum.kvconfig
    kcm-about-distrorc
    klaunchrc
    kscreenlockerrc
    ksmserverrc
    kcminputrc
)

foreach(conf IN LISTS configs)
    install(FILES ${conf} DESTINATION ${KDE_INSTALL_SYSCONFDIR}/xdg/aerothemeplasma/)
endforeach()

install(FILES autostart/x-atpootb.desktop DESTINATION ${KDE_INSTALL_SYSCONFDIR}/xdg/autostart/)
