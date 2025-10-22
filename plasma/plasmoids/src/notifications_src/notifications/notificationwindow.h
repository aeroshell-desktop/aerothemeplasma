/*
  SPDX-FileCopyrightText: 2024 David Edmundson <davidedmundson@kde.org>
  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#pragma once

#include <PlasmaQuick/PlasmaWindow>

class NotificationWindow : public PlasmaQuick::PlasmaWindow
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool takeFocus READ takeFocus WRITE setTakeFocus NOTIFY takeFocusChanged)
    Q_PROPERTY(bool isCritical READ isCritical WRITE setIsCritical NOTIFY isCriticalChanged FINAL)
public:
    NotificationWindow();
    ~NotificationWindow() override;

    bool takeFocus() const;
    void setTakeFocus(bool takeFocus);

    bool isCritical() const;
    void setIsCritical(bool critical);

protected:
    bool event(QEvent *e) override;
    void moveEvent(QMoveEvent *) override;
Q_SIGNALS:
    void takeFocusChanged();
    void isCriticalChanged();

private:
    bool m_takeFocus = false;
    bool m_critial = false;
};
