/*
    SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "glide.h"

namespace KWin
{

KWIN_EFFECT_FACTORY_SUPPORTED(GlideEffect,
                              "metadata.json",
                              return GlideEffect::supported();)

} // namespace KWin

#include "main.moc"
