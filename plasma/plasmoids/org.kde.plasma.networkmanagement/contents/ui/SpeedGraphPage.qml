/*
    SPDX-FileCopyrightText: 2023 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras

TrafficMonitor {
    id: trafficMonitorGraph
    Accessible.description: i18nc("@info:tooltip", "Current download speed is %1 kibibytes per second; current upload speed is %2 kibibytes per second", Math.round(rxSpeed / 1024), Math.round(txSpeed / 1024))
    //width: parent.width
}
