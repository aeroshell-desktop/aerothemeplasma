/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.coreaddons as KCoreAddons
import org.kde.quickcharts as QuickCharts
import org.kde.quickcharts.controls as QuickChartsControls
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
    id: speedGraph
    property string connectionTitle: ""
    property alias downloadSpeed: download.value
    property alias uploadSpeed: upload.value

    spacing: Kirigami.Units.largeSpacing

    property var connectionModel: null
    Accessible.description: i18nc("@info:tooltip", "Current download speed is %1 kibibytes per second; current upload speed is %2 kibibytes per second", Math.round(download.value / 1024), Math.round(upload.value / 1024))

    property string networkName: ""
    property string uuid: ""
    property var modelIndex: -1
    Component.onCompleted: {
        if(uuid !== "" && connectionModel) {
            modelIndex = connectionModel.match(connectionModel.index(0, 0), PlasmaNM.NetworkModel.UuidRole, uuid)[0];
        } else if(networkName !== "" && connectionModel) {
            modelIndex = connectionModel.match(connectionModel.index(0, 0), PlasmaNM.NetworkModel.ItemUniqueNameRole, networkName)[0];
        }
    }
    Timer {
        id: reloadTimer
        interval: 2000
        repeat: true
        running: parent.modelIndex !== -1
        // property int can overflow with the amount of bytes.
        triggeredOnStart: true
        property double prevRxBytes: 0
        property double prevTxBytes: 0
        onTriggered: {
            var sendData = speedGraph.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.TxBytesRole);
            var recvData = speedGraph.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.RxBytesRole);
            var nameData = speedGraph.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.ItemUniqueNameRole);
            connectionTitle = nameData;
            download.value = prevRxBytes === 0 ? 0 : (recvData - prevRxBytes) * 1000 / interval
            upload.value = prevTxBytes === 0 ? 0 : (sendData - prevTxBytes) * 1000 / interval
            prevRxBytes = recvData
            prevTxBytes = sendData
        }
    }
    RowLayout {
        id: connectionText
        spacing: Kirigami.Units.largeSpacing+1
        //Layout.topMargin: -Kirigami.Units.smallSpacing+1
        PlasmaComponents3.Label {
            font: Kirigami.Theme.defaultFont
            text: "Graph"
            textFormat: Text.PlainText
            color: "black"
        }
        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: "#a0a0a0"
        }
    }

    Item {
        Layout.leftMargin: Kirigami.Units.largeSpacing*2-1
        Layout.rightMargin: Kirigami.Units.largeSpacing*2-1
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit*6
        Layout.alignment: Qt.AlignTop

        QuickChartsControls.AxisLabels {
            id: verticalAxisLabels
            anchors {
                left: parent.left
                top: plotter.top
                bottom: plotter.bottom
            }
            width: metricsLabel.implicitWidth
            constrainToBounds: false
            direction: QuickChartsControls.AxisLabels.VerticalBottomTop
            delegate: PlasmaComponents3.Label {
                text: KCoreAddons.Format.formatByteSize(QuickChartsControls.AxisLabels.label) + i18n("/s")
                font: metricsLabel.font
                color: "black"
            }
            source: QuickCharts.ChartAxisSource {
                chart: plotter
                axis: QuickCharts.ChartAxisSource.YAxis
                itemCount: 5
            }
        }
        QuickChartsControls.GridLines {
            anchors.fill: plotter
            direction: QuickChartsControls.GridLines.Vertical
            minor.visible: false
            major.count: 3
            major.lineWidth: 1
            // Same calculation as Kirigami Separator
            major.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.4)
        }
        QuickCharts.LineChart {
            id: plotter
            anchors {
                left: verticalAxisLabels.right
                leftMargin: Kirigami.Units.smallSpacing
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                //bottomMargin: -Kirigami.Units.gridUnit*2
                // Align plotter lines with labels.
                topMargin: Math.round(metricsLabel.implicitHeight / 2) + Kirigami.Units.smallSpacing
            }
            //height: Kirigami.Units.iconSizes.small * 8
            interpolate: true
            direction: QuickCharts.XYChart.ZeroAtEnd
            yRange {
                minimum: 100 * 1024
                increment: 100 * 1024
            }
            valueSources: [
                QuickCharts.HistoryProxySource {
                    source: QuickCharts.SingleValueSource {
                        id: upload
                    }
                    maximumHistory: 40
                    fillMode: QuickCharts.HistoryProxySource.FillFromStart
                },
                QuickCharts.HistoryProxySource {
                    source: QuickCharts.SingleValueSource {
                        id: download
                    }
                    maximumHistory: 40
                    fillMode: QuickCharts.HistoryProxySource.FillFromStart
                }
            ]
            nameSource: QuickCharts.ArraySource {
                array: [i18n("Upload"), i18n("Download")]
            }
            colorSource: QuickCharts.ArraySource {
                // Array.reverse() mutates the array but colors.colors is read-only.
                array: [colors.colors[1], colors.colors[0]]
            }
            fillColorSource: QuickCharts.ArraySource  {
                array: plotter.colorSource.array.map(color => Qt.lighter(color, 1.5))
            }
            QuickCharts.ColorGradientSource {
                id: colors
                baseColor:  Kirigami.Theme.highlightColor
                itemCount: 2
            }
        }
        // Note: TextMetrics might be using a different renderType by default,
        // so we need a Label instance anyway.
        PlasmaComponents3.Label {
            id: metricsLabel
            visible: false
            font: Kirigami.Theme.defaultFont
            // Measure 888.8 KiB/s
            text: KCoreAddons.Format.formatByteSize(910131) + i18n("/s")
            color: "black"
        }
    }

    QuickChartsControls.Legend {
        chart: plotter
        Layout.leftMargin: Kirigami.Units.largeSpacing*2-1 + Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing*2-1
        Layout.topMargin: Kirigami.Units.mediumSpacing
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: Kirigami.Units.largeSpacing
        delegate: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QuickChartsControls.LegendLayout.maximumWidth: implicitWidth

            Rectangle {
                color: model.color
                width: Kirigami.Units.smallSpacing
                height: legendLabel.height
            }
            PlasmaComponents3.Label {
                id: legendLabel
                font: Kirigami.Theme.defaultFont
                text: model.name
                color: "black"
            }
        }
    }

    RowLayout {
        id: statusText
        spacing: Kirigami.Units.largeSpacing+1
        PlasmaComponents3.Label {
            font: Kirigami.Theme.defaultFont
            text: "Status"
            textFormat: Text.PlainText
            color: "black"
        }
        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: "#a0a0a0"
        }
    }

    GridLayout {
        id: detailsGrid
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing*2-1
        Layout.rightMargin: Kirigami.Units.largeSpacing*2-1
        columns: 2

        Text {
            text: i18n("Download") + ":"
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text: KCoreAddons.Format.formatByteSize(download.value) + "/s"
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
        }
        Text {
            text: i18n("Upload") + ":"
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text: KCoreAddons.Format.formatByteSize(upload.value) + "/s"
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
