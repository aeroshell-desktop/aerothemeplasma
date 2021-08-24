/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef SEVENTASKS_H
#define SEVENTASKS_H


#include <Plasma/Applet>
#include <QColor>
#include <QPixmap>
#include <QImage>
#include <QRgb>
#include <QIcon>
#include <QVariant>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickItemGrabResult>

class SevenTasks : public Plasma::Applet
{
    Q_OBJECT
    //Q_PROPERTY(QColor dominantColor READ dominantColor CONSTANT)

public:
    SevenTasks( QObject *parent, const QVariantList &args );
    ~SevenTasks();
    Q_INVOKABLE QColor getDominantColor(QVariant src);
    //Q_INVOKABLE QColor getDominantColor(QQuickItem *item);

private:
    QColor m_dominantColor;
};

#endif
