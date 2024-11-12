import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
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

    FileDialog {
        id: iconDialog
        onAccepted: {
            var str = selectedFile.toString().toLowerCase();
            console.log(str);
            if(str.endsWith(".png")) {
                iconPreview.source = selectedFile; //iconName
                iconChanged(selectedFile);

            } else {
                selectedFile = "";
            }
        }
        nameFilters: ["PNG files (*.png)"]
        fileMode: FileDialog.OpenFile
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
}
