/*

    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QByteArray>
#include <QList>
#include <QMetaType>
#include <QString>

struct KDbusImageStruct {
    int width;
    int height;
    QByteArray data;
};

typedef QList<KDbusImageStruct> KDbusImageVector;

struct KDbusToolTipStruct {
    QString icon;
    KDbusImageVector image;
    QString title;
    QString subTitle;
};
