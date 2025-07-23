
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import QtCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons // kuser
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
            name: "Home directory",
            itemText: Plasmoid.configuration.useFullName ? kuser.fullName : kuser.loginName,
            description: "Open your personal folder.",
            itemIcon: "user-home",
            itemIconFallback: "unknown",
            executableString: StandardPaths.writableLocation(StandardPaths.HomeLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Documents",
            itemText: "Documents",
            description: "Access letters, reports, notes and other kinds of documents.",
            itemIcon: "library-txt",
            itemIconFallback: "folder-library",
            executableString: StandardPaths.writableLocation(StandardPaths.DocumentsLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Pictures",
            itemText: "Pictures",
            description: "View and organize digital pictures",
            itemIcon: "library-images",
            itemIconFallback: "folder-image",
            executableString: StandardPaths.writableLocation(StandardPaths.PicturesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Music",
            itemText: "Music",
            description: "Play music and other audio files.",
            itemIcon: "library-music",
            itemIconFallback: "folder-music",
            executableString: StandardPaths.writableLocation(StandardPaths.MusicLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Videos",
            itemText: "Videos",
            description: "Watch home movies and other digital videos.",
            itemIcon: "library-video",
            itemIconFallback: "folder-videos",
            executableString: StandardPaths.writableLocation(StandardPaths.MoviesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Downloads",
            itemText: "Downloads",
            description: "Find Internet downloads and links to favorite websites.",
            itemIcon: "folder-download",
            itemIconFallback: "folder-download",
            executableString: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Downloads",
            menuModel: null,
            executeProgram: false
        },

    ]
    property var secondCategory:
    [
        {
            name: "Games",
            itemText: "Games",
            description: "Play and manage games on your computer.",
            itemIcon: "applications-games",
            itemIconFallback: "folder-games",
            executableString: "applications:///Games/",
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Recent Items",
            itemText: "Recent Items",
            description: "",
            itemIcon: "document-open-recent",
            itemIconFallback: "folder-documents",
            executableString: "recentlyused:/",
            menuModel: fileUsageModel,
            executeProgram: false
        },
        {
            name: "Computer",
            itemText: "Computer",
            description: "See the disk drives and other hardware connected to your computer.",
            itemIcon: "computer",
            itemIconFallback: "unknown",
            executableString: "file:///.",
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Network",
            itemText: "Network",
            description: "Access the computers and devices that are on your network.",
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
            name: "Control Panel",
			itemText: "Control Panel",
            description: "Change settings and customize the functionality of your computer.",
			itemIcon: "preferences-system",
			itemIconFallback: "preferences-desktop",
			executableString: "systemsettings",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Devices and Printers",
			itemText: "Devices and Printers",
            description: "View and manage devices, printers and print jobs",
			itemIcon: "input_devices_settings",
			itemIconFallback: "printer",
			executableString: "systemsettings kcm_printer_manager",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Default Programs",
			itemText: "Default Programs",
            description: "Choose default programs for web browsing, e-mail, playing music, and other activities.",
			itemIcon: "preferences-desktop-default-applications",
			itemIconFallback: "application-x-executable",
			executableString: "systemsettings kcm_componentchooser",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Help and Support",
			itemText: "Help and Support",
            description: "Find Help topics, tutorials, troubleshooting, and other support services.",
			itemIcon: "help-browser",
			itemIconFallback: "system-help",
			executableString: "https://develop.kde.org/docs/",
			executeProgram: false,
            menuModel: null,
        },
        {
            name: "Run",
			itemText: "Run...",
            description: "Opens a program, folder, document, or web site.",
			itemIcon: "krunner",
			itemIconFallback: "system-run",
			executableString: "krunner --replace",
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
