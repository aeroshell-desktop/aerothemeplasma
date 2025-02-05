import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects 1.0
import QtQuick.Controls as QQC2
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import SddmComponents 2.0


QQC2.Menu {
    id: sessionMenu
    signal valueChanged(int id)
    property int index
    horizontalPadding: 3
    verticalPadding: 3

    function createMenuItem() {
        return Qt.createQmlObject("import QtQuick.Controls; Action { property int index; }", sessionMenu);
    }
    function createMenuSeparator() {
        return Qt.createQmlObject(
            `   import QtQuick.Controls;
            import QtQuick;
            import org.kde.kirigami as Kirigami;

            Item {
                height: 8;
                Rectangle {
                    anchors.left: parent.left;
                    anchors.leftMargin: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.mediumSpacing;
                    anchors.right: parent.right;
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.verticalCenterOffset: 1;
                    height: 2;
                    color: \"white\";
                    Rectangle {
                        anchors.left: parent.left;
                        anchors.right: parent.right;
                        anchors.bottom: parent.bottom;
                        height: 1;
                        color: \"#e0e0e0\";
                    }
                }
            }`, sessionMenu);
    }
    contentItem: ListView {
        implicitHeight: contentHeight
        property bool hasCheckables: false
        property bool hasIcons: false
        model: sessionMenu.contentModel

        implicitWidth: {
            var maxWidth = 0;
            for (var i = 0; i < contentItem.children.length; ++i) {
                maxWidth = Math.max(maxWidth, contentItem.children[i].implicitWidth);
            }
            return maxWidth;
        }

        interactive: Window.window ? contentHeight + sessionMenu.topPadding + sessionMenu.bottomPadding > Window.window.height : false
        clip: true
        currentIndex: sessionMenu.currentIndex || 0
        keyNavigationEnabled: true
        keyNavigationWraps: true

        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}
    }

    delegate: MenuItem {}
    background: Rectangle {
        color: "#f0f0f0"
        border.color: "#979797"
        border.width: 1
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            border.width: 2
            border.color: "#f5f5f5"
            color: "transparent"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            anchors.leftMargin: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.mediumSpacing + 1
            width: 2
            color: "#e2e3e3"
            Rectangle {
                anchors.top: parent.top;
                anchors.right: parent.right;
                anchors.bottom: parent.bottom;
                width: 1;
                color: "white"
            }
        }
        /*layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 3
            verticalOffset: 3
            radius: 4.0
            color: "#60000000"
        }*/

    }

}
