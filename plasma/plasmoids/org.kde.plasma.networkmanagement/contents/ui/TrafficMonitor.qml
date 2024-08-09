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

ColumnLayout {

    property string connectionTitle: ""
    property alias downloadSpeed: download.value
    property alias uploadSpeed: upload.value

    spacing: Kirigami.Units.smallSpacing


    PlasmaComponents3.Label {
        id: titleLabel
        //Layout.fillWidth: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.topMargin: -Kirigami.Units.smallSpacing*2
        //horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        text: connectionTitle + " " + i18n("Speed")
    }
    Item {
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: plotter.height + metricsLabel.implicitHeight

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
                // Align plotter lines with labels.
                topMargin: Math.round(metricsLabel.implicitHeight / 2) + Kirigami.Units.smallSpacing
            }
            height: Kirigami.Units.iconSizes.small * 8
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
            font: Kirigami.Theme.smallFont
            // Measure 888.8 KiB/s
            text: KCoreAddons.Format.formatByteSize(910131) + i18n("/s")
        }
    }
    QuickChartsControls.Legend {
        chart: plotter
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.mediumSpacing*2
        Layout.fillWidth: true
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
                font: Kirigami.Theme.smallFont
                text: model.name
            }
        }
    }
}
