/*
 * SPDX-FileCopyrightText: 2024 Souris
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "smodsnap.h"

namespace KWin
{
    KWIN_EFFECT_FACTORY_SUPPORTED(
        SmodSnapEffect, "metadata.json",
        {
            return SmodSnapEffect::supported();
        }
    )
}

#include "plugin.moc"
