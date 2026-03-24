/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef SEVENSTART_H
#define SEVENSTART_H

#include <QFileInfo>
#include <QUrl>
#include <QPixmap>
#include <QVariant>
#include <QtQuick/QQuickWindow>
#include <QBitmap>
#include <QWindow>
#include <QVariantList>

#include <kwindowsystem.h>
#include <kx11extras.h>

#include <Plasma/Applet>

class SevenStart : public Plasma::Applet
{
    Q_OBJECT

public:
    SevenStart(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args);
    ~SevenStart();

    Q_INVOKABLE bool fileExists(QUrl path);

    Q_INVOKABLE void setOrb(QQuickWindow* w);
    Q_INVOKABLE void setMask(QString mask, bool overrideMask);

    // Uses QWindow::setMask(QRegion) to set a X11 input mask which also defines an arbitrary window shape.
    Q_INVOKABLE void setTransparentWindow();
    Q_INVOKABLE void setActiveWin(QQuickWindow* w);

Q_SIGNALS:
    void defaultsChanged();

public Q_SLOTS:
    void onCompositingChanged(bool enabled);
    void onShowingDesktopChanged(bool enabled);

protected:
    QBitmap* inputMaskCache = nullptr;
    QQuickWindow* orb = nullptr;
    QQuickWindow* dashWindow = nullptr;
};

#endif
