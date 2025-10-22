/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#pragma once

#include <QObject>
#include <qqmlregistration.h>

class QAction;

class GlobalShortcuts : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit GlobalShortcuts(QObject *parent = nullptr);
    ~GlobalShortcuts() override;

    Q_INVOKABLE void showDoNotDisturbOsd(bool doNotDisturb) const;

Q_SIGNALS:
    void toggleDoNotDisturbTriggered();

private:
    QAction *m_toggleDoNotDisturbAction;
};
