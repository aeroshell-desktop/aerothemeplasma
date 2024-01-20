import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: sidePanelDelegate
    objectName: "SidePanelItemSeparator"
    //icon: itemIcon

    //For some reason this is the only thing that prevents a width reduction bug, despite it being UB in QML
    anchors.left: parent.left;
    anchors.right: parent.right;
    height: 2;

    PlasmaCore.SvgItem {
        id: itemFrame
        anchors.fill: parent
        anchors.leftMargin: units.smallSpacing*2;
        anchors.rightMargin: units.smallSpacing*2;
        svg: separatorSvg
        elementId: "separator-line"
    }
}
