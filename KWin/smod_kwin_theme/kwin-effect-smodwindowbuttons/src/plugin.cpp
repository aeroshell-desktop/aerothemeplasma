/*
 * SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "smodwindowbuttons.h"

namespace KWin
{
    KWIN_EFFECT_FACTORY_SUPPORTED(
        SmodWindowButtonsEffect, "smodwindowbuttons.json",
        {
            return SmodWindowButtonsEffect::supported();
        }
    )
}

#include "plugin.moc"
