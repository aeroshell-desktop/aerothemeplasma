
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import QtCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons as KCoreAddons // kuser
import org.kde.kitemmodels as KItemModels


Item {
    id: models
    KCoreAddons.KUser {   id: kuser  }  // Used for getting the username and icon.
    Kicker.RecentUsageModel {
        id: fileUsageModel
        ordering: 0
        shownItems: Kicker.RecentUsageModel.OnlyDocs
    }

    property var firstCategory:
    [
        {
            name: i18n("Home directory"),
            itemText: Plasmoid.configuration.useFullName ? kuser.fullName : kuser.loginName,
            description: i18n("Open your personal folder."),
            itemIcon: "user-home",
            itemIconFallback: "unknown",
            executableString: StandardPaths.writableLocation(StandardPaths.HomeLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Documents"),
            itemText: i18n("Documents"),
            description: i18n("Access letters, reports, notes and other kinds of documents."),
            itemIcon: "library-txt",
            itemIconFallback: "folder-library",
            executableString: StandardPaths.writableLocation(StandardPaths.DocumentsLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Pictures"),
            itemText: i18n("Pictures"),
            description: i18n("View and organize digital pictures"),
            itemIcon: "library-images",
            itemIconFallback: "folder-image",
            executableString: StandardPaths.writableLocation(StandardPaths.PicturesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Music"),
            itemText: i18n("Music"),
            description: i18n("Play music and other audio files."),
            itemIcon: "library-music",
            itemIconFallback: "folder-music",
            executableString: StandardPaths.writableLocation(StandardPaths.MusicLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Videos"),
            itemText: i18n("Videos"),
            description: i18n("Watch home movies and other digital videos."),
            itemIcon: "library-video",
            itemIconFallback: "folder-videos",
            executableString: StandardPaths.writableLocation(StandardPaths.MoviesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Downloads"),
            itemText: i18n("Downloads"),
            description: i18n("Find Internet downloads and links to favorite websites."),
            itemIcon: "folder-download",
            itemIconFallback: "folder-download",
            executableString: StandardPaths.writableLocation(StandardPaths.DownloadLocation),
            menuModel: null,
            executeProgram: false
        },

    ]
    property var secondCategory:
    [
        {
            name: i18n("Games"),
            itemText: i18n("Games"),
            description: i18n("Play and manage games on your computer."),
            itemIcon: "applications-games",
            itemIconFallback: "folder-games",
            executableString: "applications:///Games/",
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Recent Items"),
            itemText: i18n("Recent Items"),
            description: "",
            itemIcon: "document-open-recent",
            itemIconFallback: "folder-documents",
            executableString: "recentlyused:/",
            menuModel: fileUsageModel,
            executeProgram: false
        },
        {
            name: i18n("Computer"),
            itemText: i18n("Computer"),
            description: i18n("See the disk drives and other hardware connected to your computer."),
            itemIcon: "computer",
            itemIconFallback: "unknown",
            executableString: "file:///.",
            menuModel: null,
            executeProgram: false
        },
        {
            name: i18n("Network"),
            itemText: i18n("Network"),
            description: i18n("Access the computers and devices that are on your network."),
            itemIcon: "folder-network",
            itemIconFallback: "network-server",
            executableString: "remote:/",
            menuModel: null,
            executeProgram: false
        },
    ]
    property var thirdCategory:
    [
        {
            name: i18n("Control Panel"),
			itemText: i18n("Control Panel"),
            description: i18n("Change settings and customize the functionality of your computer."),
			itemIcon: "preferences-system",
			itemIconFallback: "preferences-desktop",
			executableString: "systemsettings",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: i18n("Devices and Printers"),
			itemText: i18n("Devices and Printers"),
            description: i18n("View and manage devices, printers and print jobs"),
			itemIcon: "input_devices_settings",
			itemIconFallback: "printer",
			executableString: "systemsettings kcm_printer_manager",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: i18n("Default Programs"),
			itemText: i18n("Default Programs"),
            description: i18n("Choose default programs for web browsing, e-mail, playing music, and other activities."),
			itemIcon: "preferences-desktop-default-applications",
			itemIconFallback: "application-x-executable",
			executableString: "systemsettings kcm_componentchooser",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: i18n("Help and Support"),
			itemText: i18n("Help and Support"),
            description: i18n("Find Help topics, tutorials, troubleshooting, and other support services."),
			itemIcon: "help-browser",
			itemIconFallback: "system-help",
			executableString: "https://develop.kde.org/docs/",
			executeProgram: false,
            menuModel: null,
        },
        {
            name: i18n("Run"),
			itemText: i18n("Run..."),
            description: i18n("Opens a program, folder, document, or web site."),
			itemIcon: "krunner",
			itemIconFallback: "system-run",
			executableString: Plasmoid.configuration.defaultRunnerApp,
			executeProgram: true,
            menuModel: null,
        },
        /*{
            name: "Donate",
			itemText: "Donate",
			itemIcon: "favorites",
			itemIconFallback: "emblem-favorite",
			executableString: "https://ko-fi.com/M4M2NJ9PJ",
			executeProgram: false,
            menuModel: null,
        },*/
    ]

}
