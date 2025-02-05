import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kcmutils as KCMUtils
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.sessions

Image {
    id: root

    height: screenGeometry.height
    width: screenGeometry.width

    source: "/usr/share/sddm/themes/sddm-theme-mod/bgtexture.jpg"

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal cancelRequested()
    signal lockScreenRequested()

    SessionManagement {
        id: sessMan
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: executable
        function onExited() {
            root.cancelRequested();
        }
    }

    QQC2.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    Rectangle {
        anchors.fill: parent

        color: "#1D5F7A"

        z: -1
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            id: mainColumn

            anchors.centerIn: parent
            anchors.verticalCenterOffset: Kirigami.Units.gridUnit*5

            spacing: 5

            Repeater {
                id: list

                function trigger(modelIndex) {
                    switch(modelIndex) {
                        case(0):
                            root.lockScreenRequested();
                            break;
                        case(1):
                            sessMan.switchUser();
                            root.cancelRequested();
                            break;
                        case(2):
                            root.logoutRequested();
                            break;
                        case(3):
                            KCMUtils.KCMLauncher.openSystemSettings("kcm_users");
                            root.cancelRequested();
                            break;
                        case(4):
                            executable.exec("ksysguard6 & disown");
                            break;
                    }
                }

                model: ListModel {
                    ListElement {
                        text: "Lock this computer"
                    }
                    ListElement {
                        text: "Switch User"
                    }
                    ListElement {
                        text: "Log off"
                    }
                    ListElement {
                        text: "Change a password..."
                    }
                    ListElement {
                        text: "Start Task Manager"
                    }
                }
                delegate: Item {
                    Layout.preferredWidth: delegateContent.implicitWidth
                    Layout.preferredHeight: 30

                    KSvg.FrameSvgItem {
                        anchors.fill: parent

                        imagePath: Qt.resolvedUrl("../svgs/command.svg");
                        prefix: delegateMa.containsMouse ? (delegateMa.containsPress ? "pressed" : "hover") : ""
                    }

                    MouseArea {
                        id: delegateMa

                        anchors.fill: parent

                        hoverEnabled: true
                        propagateComposedEvents: true

                        onClicked: list.trigger(model.index);
                    }

                    RowLayout {
                        id: delegateContent
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        Image {
                            id: delegateArrow

                            source: "../images/command-" + (delegateMa.containsMouse ? "hover" : "normal") + ".png"
                        }
                        QQC2.Label {
                            text: model.text
                            color: "white"
                            font.pointSize: 12
                            renderType: Text.NativeRendering
                            font.hintingPreference: Font.PreferFullHinting
                            font.kerning: false

                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 5
                                samples: 10
                                verticalOffset: 1
                                horizontalOffset: 1
                                color: Qt.rgba(0, 0, 0, 0.8)
                            }
                        }
                        Item {
                            Layout.preferredWidth: 10
                        }
                    }
                }
            }

            KSvg.FrameSvgItem {
                id: cancel

                property string state: {
                    if(cancelMa.containsMouse) return "hover"
                    else if(cancelMa.containsPress) return "pressed"
                    else return "normal"
                }

                Layout.preferredWidth: cancelText.implicitWidth + (Kirigami.Units.gridUnit * 3)
                Layout.preferredHeight: 28

                Layout.alignment: Qt.AlignHCenter

                Layout.topMargin: 35

                imagePath: Qt.resolvedUrl("../svgs/button.svg")
                prefix: (activeFocus ? "focus-" : "") + state

                QQC2.Label {
                    id: cancelText

                    anchors.centerIn: parent

                    text: "Cancel"
                    color: "white"
                    font.pointSize: 12
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferFullHinting
                    font.kerning: false

                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 5
                        samples: 10
                        verticalOffset: 1
                        horizontalOffset: 1
                        color: Qt.rgba(0, 0, 0, 0.5)
                    }
                }

                MouseArea {
                    id: cancelMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: root.cancelRequested()
                }
            }
        }

        RowLayout {
            anchors.rightMargin: 35
            anchors.leftMargin: 35
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: Kirigami.Units.gridUnit + (Kirigami.Units.smallSpacing * 4)

            KSvg.FrameSvgItem {
                id: access

                property string state: {
                    if(accessMa.containsPress) return "pressed"
                    else if(accessMa.containsMouse) return "hover"
                    else return "normal"
                }

                Layout.preferredWidth: 40
                Layout.preferredHeight: 28

                imagePath: Qt.resolvedUrl("../svgs/button.svg")
                prefix: (activeFocus ? "focus-" : "") + state

                Image { anchors.centerIn: parent; source: "../images/access-glyph.png" }

                MouseArea {
                    id: accessMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: {
                        KCMUtils.KCMLauncher.openSystemSettings("kcm_access");
                        root.cancelRequested();
                    }

                    z: 1
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Image {
                id: power

                property string state: {
                    if(powerMa.containsMouse) return "hover"
                    else if(powerMa.containsPress) return "pressed"
                    else return "normal"
                }

                Layout.rightMargin: -Kirigami.Units.smallSpacing - 1

                source: "../images/power-" + state + ".png"

                Image { anchors.centerIn: parent; source: "../images/power-glyph.png" }

                MouseArea {
                    id: powerMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: root.haltRequested()
                }
            }

            Image {
                id: powerRight

                property string state: {
                    if(powerRightMa.containsMouse) return "hover"
                    else if(powerRightMa.containsPress) return "pressed"
                    else return "normal"
                }

                source: "../images/powerRight-" + state + ".png"

                Image { anchors.centerIn: parent; source: "../images/powerRight-glyph.png" }

                MouseArea {
                    id: powerRightMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: root.rebootRequested()
                }
            }
        }
    }

    Image {
        anchors {
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.gridUnit + (Kirigami.Units.smallSpacing * 3)

            horizontalCenter: parent.horizontalCenter
        }

        source: "../images/watermark.png"
    }
}
