import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami 2.3 as Kirigami

// basically taken from kickoff
RowLayout {
    id: iconButton

    property string currentIcon
    property string defaultIcon

    signal iconChanged(string iconName)

    //Layout.minimumWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
    //Layout.maximumWidth: Layout.minimumWidth
    //Layout.minimumHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
    //Layout.maximumHeight: Layout.minimumWidth

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: iconName => {
            iconPreview.source = iconName
            iconChanged(iconName)
        }
    }
    Layout.fillWidth: true
    ColumnLayout {

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
            text: "Customize the way the menu orb looks like using ClassicShell/OpenShell-compatible PNG resources.\nOnly orb textures with three frames are supported."
        }
        RowLayout {
            Button {
                text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
                onClicked: iconDialog.open()
            }
            Button {
                text: i18nc("@item:inmenu Reset icon to default", "Reset")
                onClicked: setDefaultIcon()
            }
        }
    }

    KSvg.FrameSvgItem {
        id: previewFrame
        //anchors.centerIn: parent
        imagePath: Plasmoid.location === PlasmaCore.Types.Vertical || Plasmoid.location === PlasmaCore.Types.Horizontal
                    ? "widgets/panel-background" : "widgets/background"
        Layout.preferredWidth: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
        Layout.preferredHeight: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom
        Layout.bottomMargin: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            id: iconPreview
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.large
            height: width
            source: currentIcon
        }
    }

    function setDefaultIcon() {
        iconPreview.source = defaultIcon
        iconChanged(defaultIcon)
    }


    // QQC Menu can only be opened at cursor position, not a random one
    /*PlasmaExtras.Menu {
        id: iconMenu


        PlasmaExtras.MenuItem {
            text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
            icon: "document-open-folder"
            onClicked: iconDialog.open()
        }
        PlasmaExtras.MenuItem {
            text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
            icon: "edit-clear"
            onClicked: setDefaultIcon()
        }
    }*/
}
