/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QDBusArgument>

#include "systemtraytypedefs.h"

const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusImageStruct &icon);
const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusImageStruct &icon);

const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusImageVector &iconVector);
const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusImageVector &iconVector);

const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusToolTipStruct &toolTip);
const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusToolTipStruct &toolTip);
