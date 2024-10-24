/*
 * SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "smodglow.h"

namespace KWin
{
    KWIN_EFFECT_FACTORY_SUPPORTED(
        SmodGlowEffect, "metadata.json",
        {
            return SmodGlowEffect::supported();
        }
    )
}

#include "plugin.moc"
